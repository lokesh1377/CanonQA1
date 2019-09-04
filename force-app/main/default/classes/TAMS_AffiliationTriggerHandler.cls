/**
  * Class object for trigger.
  *
  * Used By: TAMS_Affiliation_Trigger
  * 
  * @author NTT Data: Louis Wooldridge
  * @date August 7, 2015
  *
  * @update Hemant Kumar March 4th 2016
  */
public class TAMS_AffiliationTriggerHandler {
    private static Map<String, Id> mProfiles = new Map<String, Id>();
    
    public TAMS_AffiliationTriggerHandler(){
        //Retrieving Portal Profile Ids
        for(Profile oProfile : [Select Id, Name From Profile Where UserType = 'PowerCustomerSuccess' 
        And Name Like 'TAMS - Customer Portal %']){
            if(oProfile.Name.contains('Admin')){
                mProfiles.put('Admin', oProfile.Id);
                system.debug('HK - Admin Profile: '+oProfile.Id);
            }else{
                mProfiles.put('Standard', oProfile.Id);
                system.debug('HK - Standard Profile: '+oProfile.Id);
            }
        }
    }
    
    public void UpdateContact(List<TAMS_Affiliation__c> newAffiliations){
        Set<Id> sDistinctUserIds = new Set<Id>();
        Set<Id> sDistinctAccountIds = new Set<Id>();
        Map<Id, Id> mLookupUserContact = new Map<Id, Id>();
        
        for(TAMS_Affiliation__c oAffiliation : newAffiliations){
            sDistinctUserIds.add(oAffiliation.User__c);
            sDistinctAccountIds.add(oAffiliation.Account__c);
            system.debug('HK - Accounts of Affiliation: '+oAffiliation.Account__c);
        }
        
        //Retrieving User records for the distinct Ids on the Affiliation records
        for(User oUser : [Select Id, ContactId From User Where Id In:sDistinctUserIds]){
            mLookupUserContact.put(oUser.Id, oUser.ContactId);
            system.debug('HK - User    : '+oUser.Id );
            system.debug('HK - Contact : '+oUser.ContactId);
        }
        
        //Retrieving the Service Contracts & Cases for the Account
        List<ServiceContract> lContracts = new List<ServiceContract>();
        List<Case> lCases = new List<Case>();
        system.debug('HK - Retrieving the Service Contracts & Cases for the Account: '+sDistinctAccountIds);
        for(Account oAcct : [Select Id, (Select Id, AccountId, Modality__c From ServiceContracts Where Is_Exception__c = false), 
            (Select Id, AccountId, Admin_Portal_Share__c, Standard_Portal_Share__c, Modality__c, Install_Base__c From Cases) 
            From Account Where Id In:sDistinctAccountIds]){
            //lContracts.addAll(oAcct.ServiceContracts);     HK       
            //lCases.addAll(oAcct.Cases);  HK
            Integer cntractcnt=0;
            for (ServiceContract sc : oAcct.ServiceContracts){
                lContracts.add(sc);
                cntractcnt++;
               }
            system.debug('HK - Retrieved Service Contracts for the Account: '+cntractcnt);     
            Integer casecnt=0;
            for (Case c : oAcct.Cases){
                lCases.add(c);
                casecnt++;
            }
            system.debug('HK - Retrieved Cases for the Account: '+casecnt); 
        }
        
        system.debug('HK - Updating lookup ContactId field for linked User: ');
        //Updating lookup ContactId field for linked User
        List<TAMS_Affiliation__c> lUpdateAffiliations = new List<TAMS_Affiliation__c>();
        for(TAMS_Affiliation__c oAffiliation : newAffiliations){
            oAffiliation.Contact__c = mLookupUserContact.get(oAffiliation.User__c);
        }
        
        //Inserting User & Contract Share Records
        List<AccountShare> lInsertAccountShares = new List<AccountShare>();
        List<ServiceContractShare> lInsertContractShares = new List<ServiceContractShare>();
        List<CaseShare> lInsertCaseShares = new List<CaseShare>();
        
        //Creating/Inserting new share records based on Affiliations
        for(TAMS_Affiliation__c oAffiliation : newAffiliations){
            AccountShare oAcctShare = new AccountShare();
            oAcctShare.UserOrGroupId = oAffiliation.User__c;
            oAcctShare.AccountId = oAffiliation.Account__c;
            User oUser = [Select ProfileId, Contact.Modality__c From User Where Id = : oAffiliation.User__c];
            if(oUser.ProfileId == mProfiles.get('Admin')){
                oAcctShare.AccountAccessLevel = 'Edit';
            }else{
                oAcctShare.AccountAccessLevel = 'Read';
            }
            oAcctShare.OpportunityAccessLevel = 'None';
            lInsertAccountShares.add(oAcctShare);
            
            //Creating ServiceContract Shares
            for(ServiceContract oContract : lContracts){
                if((oUser.Contact.Modality__c != null)&&(oContract.Modality__c != null)){
                    if(oUser.Contact.Modality__c.contains(oContract.Modality__c) == true){
                        ServiceContractShare oContractShare = new ServiceContractShare();
                        oContractShare.AccessLevel = 'Read';
                        oContractShare.ParentId = oContract.Id;
                        oContractShare.UserOrGroupId = oUser.Id;
                        lInsertContractShares.add(oContractShare);
                    }
                }
            }
            
            //Create Case Shares
            for(Case oCase : lCases){
                if(oCase.AccountId == oAffiliation.Account__c){
                    Boolean bCreateShare = false;
                    
                    if((oCase.Admin_Portal_Share__c == true)&&(oUser.ProfileId == mProfiles.get('Admin'))){
                        bCreateShare = true;
                    }else if(oCase.Standard_Portal_Share__c){
                        bCreateShare = true;
                    }
                    //For Cases related to Equipment, Case Modality needs to match the User Modality
                    if((oCase.Install_Base__c != null)&&(oAffiliation.Contact__r.Modality__c != null)&&(oCase.Modality__c != null)){
                        if(oAffiliation.Contact__r.Modality__c.contains(oCase.Modality__c) == false){
                            bCreateShare = false;
                        }
                    }
                    
                    if(bCreateShare == true){
                        CaseShare oCaseShare = new CaseShare();
                        oCaseShare.UserOrGroupId = oUser.Id;
                        oCaseShare.CaseId = oCase.Id;
                        oCaseShare.CaseAccessLevel = 'Edit';
                        lInsertCaseShares.add(oCaseShare);
                    }
                }
            }
        }
        
        if(lInsertAccountShares.isEmpty() == false){
            insert lInsertAccountShares;
        }
        if(lInsertContractShares.isEmpty() == false){
            insert lInsertContractShares;
        }
        if(lInsertCaseShares.isEmpty() == false){
            insert lInsertCaseShares;
        }
    }
    
    public void UpdateContact(List<TAMS_Affiliation__c> newAffiliations, Map<Id,TAMS_Affiliation__c> oldAffiliations){
        List<TAMS_Affiliation__c> lModifiedAffiliations = new List<TAMS_Affiliation__c>();
        List<TAMS_Affiliation__c> lOldAffiliations = new List<TAMS_Affiliation__c>();
        
        for(TAMS_Affiliation__c oAffiliation : newAffiliations){
            TAMS_Affiliation__c oOldAffiliations = oldAffiliations.get(oAffiliation.Id);
            
            if(oAffiliation.User__c != oOldAffiliations.User__c){
                lModifiedAffiliations.add(oAffiliation);
                lOldAffiliations.add(oOldAffiliations);
            }
        }
        
        if(lOldAffiliations.isEmpty() == false){
            DeleteShares(lOldAffiliations);
        }
        if(lModifiedAffiliations.isEmpty() == false){
            UpdateContact(lModifiedAffiliations);
        }
    }
    
    public void DeleteShares(List<TAMS_Affiliation__c> oldAffiliations){
        List<ServiceContractShare> lDeleteServiceShares = new List<ServiceContractShare>();
        List<AccountShare> lDeleteAccountShares = new List<AccountShare>();
        Set<Id> sDistinctAccountIds = new Set<Id>();
        Set<Id> sDistinctUserIds = new Set<Id>();
        Set<String> sDistinctAcctUserIds = new Set<String>();
        
        for(TAMS_Affiliation__c oAffiliation : oldAffiliations){
            sDistinctAcctUserIds.add(oAffiliation.Account__c + '-' + oAffiliation.User__c);
            sDistinctAccountIds.add(oAffiliation.Account__c);
            sDistinctUserIds.add(oAffiliation.User__c);
        }
        
        for(AccountShare oAccountShare : [Select Id, AccountId, UserOrGroupId From AccountShare
        Where AccountId In:sDistinctAccountIds And RowCause = 'Manual']){
            if(sDistinctAcctUserIds.contains(oAccountShare.AccountId + '-' + oAccountShare.UserOrGroupId)){
                lDeleteAccountShares.add(oAccountShare);
            }
        }
        
        if(lDeleteAccountShares.isEmpty() == false){
            delete lDeleteAccountShares;
        }
        
        //Retrieving the Service Contracts for the Accounts
        List<ServiceContractShare> lDeleteServiceContractShares = new List<ServiceContractShare>();
        List<String> lContractIds = new List<String>();
        
        for(ServiceContract oContract : [Select Id, Modality__c, AccountId From ServiceContract 
        Where AccountId In:sDistinctAccountIds]){
            lContractIds.add(oContract.Id);
        }
        
        for(ServiceContractShare oContractShare : [Select Id, ParentId, UserOrGroupId From ServiceContractShare
        Where ParentId In:lContractIds And RowCause = 'Manual']){
            if(sDistinctUserIds.contains(oContractShare.UserOrGroupId) == true){
                lDeleteServiceContractShares.add(oContractShare);
            }
        }
        
        if(lDeleteServiceContractShares.isEmpty() == false){
            delete lDeleteServiceContractShares;
        }
        
        //Retrieving the Cases for the Accounts
        List<CaseShare> lDeleteCaseShares = new List<CaseShare>();
        List<String> lCaseIds = new List<String>();
        for(Case oCase : [Select Id, AccountId From Case 
        Where AccountId In:sDistinctAccountIds]){
            lCaseIds.add(oCase.Id);
        }
        for(CaseShare oCaseShare : [Select Id, CaseId, UserOrGroupId From CaseShare
        Where CaseId In:lCaseIds And RowCause = 'Manual']){
            if(sDistinctUserIds.contains(oCaseShare.UserOrGroupId) == true){
                lDeleteCaseShares.add(oCaseShare);
            }
        }
        
        if(lDeleteCaseShares.isEmpty() == false){
            delete lDeleteCaseShares;
        }
    }
}