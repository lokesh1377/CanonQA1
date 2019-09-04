/**
    * This batch job will run nightly and will be started by Batch_ManageServiceContractSharing when it completes
    * Retrieves Cases that have been modified within a specified time period
    * For each Case will build Case shares
        * Build share records for the Contacts and Affiliated Users related to the Account specified on the Case
    
    * Batch_ProcessCaseSharing b = new Batch_ProcessCaseSharing();
    * b.bProcessAllCases = true;
    * Database.executeBatch(b);
 
    @author NTT Data: Louis Wooldridge
    @date Sep 23, 2015
    @update 
 **/
global class Batch_ProcessCaseSharing implements Database.Batchable<sObject>, Database.Stateful {
    @TestVisible private Boolean bIsSuccess {get;set;}
    @TestVisible private String sErrorMessage {get;set;}
    @TestVisible private String sCaseId {get;set;}
    private Map<String, Id> mProfiles = new Map<String, Id>();
    public Boolean bProcessAllCases {get;set;}
    
    global Batch_ProcessCaseSharing(){
        bIsSuccess = true;
        sErrorMessage = '';
        bProcessAllCases = false;
        
        //Retrieving Portal Profile Ids
        for(Profile oProfile : [Select Id, Name From Profile Where Name Like 'TAMS - Customer Portal %']){
            if(oProfile.Name.contains('Admin')){
                mProfiles.put('Admin', oProfile.Id);
            }else{
                mProfiles.put('Standard', oProfile.Id);
            }
        }
    }
    
    global Database.QueryLocator start(Database.BatchableContext BC) {
        if(test.isRunningTest() == true){
            return Database.getQueryLocator([Select AccountId,  
                Id, Standard_Portal_Share__c, Admin_Portal_Share__c, ContactId, Install_Base__c, Modality__c
                From Case Where Id = :sCaseId Limit 1]);
        }else{
            if(bProcessAllCases == true){
                return Database.getQueryLocator([Select AccountId, 
                    Id, Standard_Portal_Share__c, Admin_Portal_Share__c, ContactId, Install_Base__c, Modality__c
                    From Case]);
            }else{
                return Database.getQueryLocator([Select AccountId, 
                    Id, Standard_Portal_Share__c, Admin_Portal_Share__c, ContactId, Install_Base__c, Modality__c
                    From Case Where LastModifiedDate > YESTERDAY]);
            }
        }
    }
    
    global void execute(Database.BatchableContext BC, List<sObject> lSobjects) {
        Map<Id, Account> mDistinctAccounts = new Map<Id, Account>();
        Map<Id, User> mLookupContactUser = new Map<Id, User>();
        Set<Id> sDistinctUserIds = new Set<Id>();
        Set<Id> sDistinctCaseIds = new Set<Id>();
        Set<Id> sAccountIds = new Set<Id>(); //Added by Prabheet Singh 05/09/2017
        Map<Id, List<Id>> mAccountContacts = new Map<Id, List<Id>>();
        Map<Id, List<Id>> mAccountCases = new Map<Id, List<Id>>();
        
        List<Case> lCases = new List<Case>();
        for(sObject obj : lSobjects){
            Case oCase = (Case)obj;
            lCases.add(oCase);
            //commented by Prabheet Singh 05/09/2017
            //mAccountContacts.put(oCase.AccountId, null);
            //mAccountCases.put(oCase.AccountId, null);
            sAccountIds.add(oCase.AccountId);
            sDistinctCaseIds.add(oCase.Id);
        }
        
        //Retrieving Users linked to the Account Contacts
        System.debug('lCases.size():'+lCases.size());
        System.debug('sDistinctCaseIds.size():'+sDistinctCaseIds.size());
        System.debug('sAccountIds:'+sAccountIds);

        for(User oUser : [Select ProfileId, Id, ContactId, Contact.Modality__c 
        From User Where IsActive = true And Contact.AccountId In :sAccountIds]){
            mLookupContactUser.put(oUser.ContactId, oUser);
            sDistinctUserIds.add(oUser.Id);
        }

        System.debug('sDistinctUserIds values:'+sDistinctUserIds);
        System.debug('mLookupContactUser values:'+mLookupContactUser);
        //Changed the SOQL For loop for heap size Prabhjeet 05/04/17
        //Added by Prabheet Singh 05/09/2017
        //Added and User__r.IsActive = true by Hemant Kumar on 2/14/2019
        for(Contact contactRec : [Select Id,AccountId From Contact 
                                            Where AccountId In :sAccountIds and Status_TAMS__c = 'Active']){
            if(mAccountContacts.containsKey(contactRec.AccountId)){
                //System.debug('Key exists. Adding contact ID');
                List<ID> contactIds =  mAccountContacts.get(contactRec.AccountId);
                contactIds.add(contactRec.Id);
                mAccountContacts.put(contactRec.AccountId,contactIds);
            }
            else{
                //System.debug('Key NOT exists. Adding contact ID');
                List<ID> contactIds =  new List<Id>();
                contactIds.add(contactRec.Id);
                mAccountContacts.put(contactRec.AccountId,contactIds);              
            }           

        }
        System.debug('mAccountContacts size:'+mAccountContacts.size());
        System.debug('mAccountContacts keySet:'+mAccountContacts.keySet());
        System.debug('mAccountContacts values:'+mAccountContacts.values());
        //Added by Prabheet Singh 05/09/2017
        for(Case caseRec : [Select Id,AccountId From Case 
                                            Where AccountId In :sAccountIds]){
            if(mAccountCases.containsKey(caseRec.AccountId)){
                //System.debug('Key exists. Adding case ID');
                List<ID> caseIds =  mAccountCases.get(caseRec.AccountId);
                caseIds.add(caseRec.Id);
                mAccountCases.put(caseRec.AccountId,caseIds);
            }
            else{
                //System.debug('Key NOT exists. Adding case ID');
                List<ID> caseIds =  new List<Id>();
                caseIds.add(caseRec.Id);
                mAccountCases.put(caseRec.AccountId,caseIds);               
            }


        }
        System.debug('mAccountCases size:'+mAccountContacts.size());
        System.debug('mAccountCases keySet:'+mAccountContacts.keySet());
        System.debug('mAccountCases values:'+mAccountContacts.values());

        //commented by Prabheet Singh 05/09/2017
/*      
        for(List<Account> oListAccount : [Select Id, (Select Id, Modality__c From Contacts), (Select Id, Modality__c From Cases) 
        From Account Where Id In:mAccountContacts.keySet()]){
            for(Account oAccount:oListAccount){
                List<Id> lContactIds = new List<Id>();
                List<Id> lCaseIds = new List<Id>();
                System.debug('SOQL count:'+Limits.getQueries());
                for(Contact oContact : oAccount.Contacts){
                    lContactIds.add(oContact.Id);
                }
                for(Case oCase : oAccount.Cases){
                    lCaseIds.add(oCase.Id);
                }
                mAccountContacts.put(oAccount.Id, lContactIds);
                mAccountCases.put(oAccount.Id, lCaseIds);
            }
        }
*/
        //Create Sharing with Account Portal Users
        List<CaseShare> lInsertShares = new List<CaseShare>();
        //Delete existing shares first
        List<CaseShare> lDeleteShares = new List<CaseShare>();
        System.debug('DistinctCaseIds values:'+sDistinctCaseIds);
        System.debug('sDistinctUserIds values:'+sDistinctUserIds);
        for(CaseShare oCaseShare : [Select Id From CaseShare Where RowCause = 'Manual' 
        And UserOrGroupId = :sDistinctUserIds And CaseId = :sDistinctCaseIds]){
            lDeleteShares.add(oCaseShare);
        }
        
        for(Case oCase : lCases){
            if(mAccountContacts.containsKey(oCase.AccountId)){
                if(mAccountContacts.get(oCase.AccountId) != null){
                    for(Id idContact : mAccountContacts.get(oCase.AccountId)){
                        if(mLookupContactUser.keySet().contains(idContact) == true){
                            Boolean bCreateShare = false;
                            User oShareUser = mLookupContactUser.get(idContact);
                            
                            if(oCase.ContactId != idContact){
                                //Checking Case Admin Share flag and if User is an Admin
                                if((oCase.Admin_Portal_Share__c == true)&&(oShareUser.ProfileId == mProfiles.get('Admin'))){
                                    bCreateShare = true;
                                }else if((oCase.Standard_Portal_Share__c)&&(oShareUser.ProfileId == mProfiles.get('Standard'))){
                                    bCreateShare = true;
                                }
                                //For Cases related to Equipment, Case Modality needs to match the User Modality
                                if((oCase.Install_Base__c != null)&&(oShareUser.Contact.Modality__c != null)&&(oCase.Modality__c != null)){
                                    if(oShareUser.Contact.Modality__c.contains(oCase.Modality__c) == false){
                                        bCreateShare = false;
                                    }
                                }
                                
                                if(bCreateShare == true){
                                    CaseShare oShare = new CaseShare();
                                    oShare.UserOrGroupId = oShareUser.Id;
                                    oShare.CaseId = oCase.Id;
                                    oShare.CaseAccessLevel = 'Edit';
                                    lInsertShares.add(oShare);
                                }
                            }
                        }
                    }
                }
            }
        }
        
        //Create Sharing for Affiliated Users
        //Added User__r.IsActive = true by Hemant on 2/14/2019
        for(TAMS_Affiliation__c oAffiliation : [Select User__r.ProfileId, User__c, Contact__c, Contact__r.Modality__c, Account__c 
        From TAMS_Affiliation__c Where Account__c In :sAccountIds and User__r.IsActive = true]){
            for(Case oCase : lCases){
                if(oCase.AccountId == oAffiliation.Account__c){
                    Boolean bCreateShare = false;
                    
                    if((oCase.Admin_Portal_Share__c == true)&&(oAffiliation.User__r.ProfileId == mProfiles.get('Admin'))){
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
                        CaseShare oShare = new CaseShare();
                        oShare.UserOrGroupId = oAffiliation.User__c;
                        oShare.CaseId = oCase.Id;
                        oShare.CaseAccessLevel = 'Edit';
                        lInsertShares.add(oShare);
                    }
                }
            }
        }
        
        if(lDeleteShares.isEmpty() == false){
            delete lDeleteShares;
        }
        if(lInsertShares.isEmpty() == false){
            insert lInsertShares;
        }
    }
    
    global void finish(Database.BatchableContext BC) {
        AsyncApexJob oJob = [Select Id, Status, NumberOfErrors, ExtendedStatus, JobItemsProcessed, CreatedBy.Email 
            From AsyncApexJob Where Id = :BC.getJobId()];
        
        if(oJob.NumberOfErrors > 0){
            bIsSuccess = false;
            sErrorMessage = oJob.ExtendedStatus;
        }
        if(bIsSuccess == false){
            //Sending Error Msg to Job Submitter
            Messaging.SingleEmailMessage oMail = new Messaging.SingleEmailMessage();
            String[] toAddresses = new String[] {oJob.CreatedBy.Email};
            oMail.setToAddresses(toAddresses);
            oMail.setSubject('Batch_ProcessCaseSharing job failed, status: ' + oJob.Status + ' (' + oJob.NumberOfErrors + ' errors out of '+ oJob.JobItemsProcessed + ' batches)');
            oMail.setPlainTextBody('Error Message: ' + sErrorMessage);
            Messaging.sendEmail(new Messaging.SingleEmailMessage[] { oMail });
        }
    }
}