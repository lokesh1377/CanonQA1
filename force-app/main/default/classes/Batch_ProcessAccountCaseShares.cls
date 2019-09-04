/**
    * This batch job will run nightly
    * Retrieves Account Cases where Process Account Shares field on the Account equals true
    * For each Account Case will build CaseShare records
        * Will add shares for Contacts on the Account, Contacts going up the Parent Account hierarchy and also Contacts going down the Child Account hierarchy
        * Case shares will be updated
    * When complete, will start Batch_ProcessAccountContractShares
    * Batch_ProcessAccountCaseShares, Batch_ProcessAccountContractShares and Batch_ProcessAccountShares have similar logic flow,
    * make sure to check to see if any updates to the code will need to be replicated to the to other batch code classes.
    
    * Database.executeBatch(new Batch_ProcessAccountCaseShares());
 
    @author NTT Data: Louis Wooldridge
    @date Dec 2, 2015
    @update Feb 1, 2016 - Added check for idParents by HK
 **/
global class Batch_ProcessAccountCaseShares implements Database.Batchable<sObject>, Database.Stateful {
    @TestVisible private Boolean bIsSuccess {get;set;}
    @TestVisible private String sErrorMessage {get;set;}
    @TestVisible private String sAccountId {get;set;}
    private Map<String, Id> mProfiles = new Map<String, Id>();
    
    global Batch_ProcessAccountCaseShares() {
        bIsSuccess = true;
        sErrorMessage = '';
        
        //Retrieving Portal Profile Ids
        for(Profile oProfile : [Select Id, Name From Profile Where UserType = 'PowerCustomerSuccess' And Name Like 'TAMS - Customer Portal %']){
            if(oProfile.Name.contains('Admin')){
                mProfiles.put('Admin', oProfile.Id);
            }else{
                mProfiles.put('Standard', oProfile.Id);
            }
        }
    }
    
    global Database.QueryLocator start(Database.BatchableContext BC) {
        if(test.isRunningTest() == true){
            return Database.getQueryLocator([Select Subject, Standard_Portal_Share__c, Modality__c, 
                Install_Base__c, ContactId, Admin_Portal_Share__c, Account.Process_Account_Shares__c, 
                Account.ParentId, AccountId From Case Limit 1]);
        }else{
            return Database.getQueryLocator([Select Subject, Standard_Portal_Share__c, Modality__c, 
                Install_Base__c, ContactId, Admin_Portal_Share__c, Account.Process_Account_Shares__c, 
                Account.ParentId, AccountId From Case 
                Where Account.Process_Account_Shares__c = true]);
        }
    }
    
    global void execute(Database.BatchableContext BC, List<sObject> lSobjects) {
        //Collecting the distinct Account Ids related to the Cases that are being processed
        //Converting sObject list to list of Case objects
        Map<Id, Id> mAccountAndParentIds = new Map<Id, Id>();
        List<Case> lCases = new List<Case>();
        for(sObject oCaseObject : lSobjects){
            Case oCase = (Case)oCaseObject;
            lCases.add(oCase);
            mAccountAndParentIds.put(oCase.AccountId, oCase.Account.ParentId);
        }
        
        //Creating a lookup map of List Cases by AccountId
        Map<Id, List<Case>> mAccountCases = new Map<Id, List<Case>>();
        for(Id idAccount : mAccountAndParentIds.keySet()){
            List<Case> lAccountCases = new List<Case>();
            for(Case oCase : lCases){
                if(oCase.AccountId == idAccount){
                    lAccountCases.add(oCase);
                }
            }
            mAccountCases.put(idAccount, lAccountCases);
        }
        
        List<CaseShare> lInsertCaseShares = new List<CaseShare>();
        List<CaseShare> lDeleteCaseShares = new List<CaseShare>();
        
        //Looping thru each distinct Account to process the related Account Cases
        for(Id idPrimaryAccountId : mAccountAndParentIds.keySet()){
            List<Id> lContactIds = new List<Id>();
            
            //Traverse up the hierarchy, making sure that 
            //Parent Account Admins have access to current Account
            Id idParent = mAccountAndParentIds.get(idPrimaryAccountId);
            
            //Retrieving Primary Account Contacts 
            for(Contact oContact : [Select Id From Contact Where AccountId = :idPrimaryAccountId]){
                lContactIds.add(oContact.Id);
            }
            //Retrieving Contacts from higher level accounts
            while(idParent != null){
                //Added by HK for reset the While loop condition 
                String idParents = null; 
                for(Contact oContact : [Select Id, Account.ParentId From Contact Where AccountId = :idParent]){
                    lContactIds.add(oContact.Id);
                    idParents = oContact.Account.ParentId;
                }
                //Added by HK for reset the While loop condition 
                idParent = idParents;
            }
            system.debug('Contacts: ' + lContactIds);
            
            //Putting the Cases for the Account into a Map for processing
            Map<Id, Case> mCases = new Map<Id, Case>();
            for(Case oCase : mAccountCases.get(idPrimaryAccountId)){
                mCases.put(oCase.Id, oCase);
            }
            
            //Sharing primary Account with Contacts on higher level Accounts
            if(lContactIds.isEmpty() == false){
                Map<Id, User> mUsers = new Map<Id, User>();
                for(User oUser : [Select Id, Name, ProfileId, Contact.Modality__c From User Where ProfileId = :mProfiles.values()
                And ContactId In:lContactIds And IsActive = true]){
                    mUsers.put(oUser.Id, oUser);
                }
                system.debug('DELETE SHARES');
                system.debug('Users: ' + mUsers);
                system.debug('Cases' + mCases);
                //Retrieving existing Case shares for deletion
                for(CaseShare oCaseShare : [Select Id From CaseShare Where RowCause = 'Manual' 
                And CaseId In:mCases.keySet() And UserOrGroupId In:mUsers.keySet()]){
                    lDeleteCaseShares.add(oCaseShare);
                }
                
                for(User oUser : mUsers.values()){
                    //Creating Case Shares
                    for(Case oCase : mCases.values()){
                        Boolean bCreateShare = false;
                        
                        //Checking Case Admin Share flag and if User is an Admin
                        if((oCase.Admin_Portal_Share__c == true)&&(oUser.ProfileId == mProfiles.get('Admin'))){
                            bCreateShare = true;
                        }else if((oCase.Standard_Portal_Share__c == true)&&(oUser.ProfileId == mProfiles.get('Standard'))){
                            bCreateShare = true;
                        }
                        //For Cases related to Equipment, Case Modality needs to match the User Modality
                        if((oCase.Install_Base__c != null)&&(oUser.Contact.Modality__c != null)&&(oCase.Modality__c != null)){
                            if(oUser.Contact.Modality__c.contains(oCase.Modality__c) == false){
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
            
            //Traverse down the hierarchy, making sure that
            //Current Account Admins have access to children Accounts
            List<Id> lAllAccountIds = new List<Id>();
            
            Set<Id> sAcctQueryIds = new Set<Id>();
            Boolean bFoundAllChildren = false;
            sAcctQueryIds.add(idPrimaryAccountId);
            Map<Id, Case> mChildCases = new Map<Id, Case>();
            
            while(bFoundAllChildren == false){
                List<Account> lChildAccounts = new List<Account>([Select Id,
                        (Select Id, ContactId, AccountId, Admin_Portal_Share__c, Standard_Portal_Share__c, Modality__c, Install_Base__c From Cases)
                        From Account Where ParentId In:sAcctQueryIds]);
                if(lChildAccounts.isEmpty() == true){
                    bFoundAllChildren = true;
                }else{
                    sAcctQueryIds.clear();
                    
                    for(Account oAccount : lChildAccounts){
                        lAllAccountIds.add(oAccount.Id);
                        sAcctQueryIds.add(oAccount.Id);
                        
                        for(Case oChildCase : oAccount.Cases){
                            mChildCases.put(oChildCase.Id, oChildCase);
                        }
                    }
                }
            }
            
            if(lAllAccountIds.isEmpty() == false){
                Map<Id, User> mUsers = new Map<Id, User>();
                for(User oUser : [Select Id, ProfileId, Contact.Modality__c From User Where ProfileId = :mProfiles.values()
                And Contact.AccountId = :idPrimaryAccountId And IsActive = true]){
                    mUsers.put(oUser.Id, oUser);
                }
                //Retrieving existing Case shares for deletion
                for(CaseShare oCaseShare : [Select Id From CaseShare Where RowCause = 'Manual' 
                And CaseId In:mChildCases.keySet() And UserOrGroupId In:mUsers.keySet()]){
                    lDeleteCaseShares.add(oCaseShare);
                }
                
                for(User oUser : mUsers.values()){
                    //Creating Case Shares
                    for(Case oCase : mChildCases.values()){
                        Boolean bCreateShare = false;
                        
                        //Checking Case Admin Share flag and if User is an Admin
                        if((oCase.Admin_Portal_Share__c == true)&&(oUser.ProfileId == mProfiles.get('Admin'))){
                            bCreateShare = true;
                        }else if((oCase.Standard_Portal_Share__c)&&(oUser.ProfileId == mProfiles.get('Standard'))){
                            bCreateShare = true;
                        }
                        //For Cases related to Equipment, Case Modality needs to match the User Modality
                        if((oCase.Install_Base__c != null)&&(oUser.Contact.Modality__c != null)&&(oCase.Modality__c != null)){
                            if(oUser.Contact.Modality__c.contains(oCase.Modality__c) == false){
                                bCreateShare = false;
                            }
                        }
                        
                        if(bCreateShare == true){
                            CaseShare oShare = new CaseShare();
                            oShare.UserOrGroupId = oUser.Id;
                            oShare.CaseId = oCase.Id;
                            oShare.CaseAccessLevel = 'Edit';
                            lInsertCaseShares.add(oShare);
                        }
                    }
                }
            }
        }
        
        //Deleting existing shares before inserting new shares
        if(lDeleteCaseShares.isEmpty() == false){
            delete lDeleteCaseShares;
        }
        //Inserting new shares
        if(lInsertCaseShares.isEmpty() == false){
            insert lInsertCaseShares;
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
            oMail.setSubject('Batch_ProcessAccountCaseShares job failed, status: ' + oJob.Status + ' (' + oJob.NumberOfErrors + ' errors out of '+ oJob.JobItemsProcessed + ' batches)');
            oMail.setPlainTextBody('Error Message: ' + sErrorMessage);
            Messaging.sendEmail(new Messaging.SingleEmailMessage[] { oMail });
        }
        
        if(test.isRunningTest() == false) {
            //Kicking off next Batch Job to process Contract Sharing
            system.scheduleBatch(new Batch_ProcessAccountContractShares(), 'Process Service Contract Sharing', 2);
        }
    }
}