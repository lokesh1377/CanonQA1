/**
    * This batch job will run nightly
    * Retrieves Account Service Contracts where Process Account Shares field on the Account equals true
    * For each Account Service Contract will build ServiceContractShare records
        * Will add shares for Contacts on the Account, Contacts going up the Parent Account hierarchy and also Contacts going down the Child Account hierarchy
        * Service Contract shares will be updated
    * When complete, will start Batch_ProcessAccountShares
    * Batch_ProcessAccountCaseShares, Batch_ProcessAccountContractShares and Batch_ProcessAccountShares have similar logic flow,
    * make sure to check to see if any updates to the code will need to be replicated to the to other batch code classes.
    
    * Database.executeBatch(new Batch_ProcessAccountContractShares());
 
    @author NTT Data: Louis Wooldridge
    @date Dec 2, 2015
    @update Dec 16, 2015 - Added check for if(oContract.Is_Exception__c == false)
    @update Feb 1, 2016 - Added check for idParents by HK
    
 **/
global class Batch_ProcessAccountContractShares implements Database.Batchable<sObject>, Database.Stateful {
    @TestVisible private Boolean bIsSuccess {get;set;}
    @TestVisible private String sErrorMessage {get;set;}
    @TestVisible private String sAccountId {get;set;}
    private Map<String, Id> mProfiles = new Map<String, Id>();
    
    global Batch_ProcessAccountContractShares() {
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
            return Database.getQueryLocator([Select Name, Modality__c, Is_Exception__c,
                Account.Process_Account_Shares__c, Account.ParentId, AccountId 
                From ServiceContract Limit 1]); 
        }else{
            return Database.getQueryLocator([Select Name, Modality__c, Is_Exception__c,
                Account.Process_Account_Shares__c, Account.ParentId, AccountId 
                From ServiceContract Where Account.Process_Account_Shares__c = true]);
        }
    }
    
    global void execute(Database.BatchableContext BC, List<sObject> lSobjects) {
        //Collecting the distinct Account Ids related to the Contracts that are being processed
        //Converting sObject list to list of ServiceContract objects
        Map<Id, Id> mAccountAndParentIds = new Map<Id, Id>();
        List<ServiceContract> lServiceContracts = new List<ServiceContract>();
        for(sObject oServiceContractObject : lSobjects){
            ServiceContract oServiceContract = (ServiceContract)oServiceContractObject;
            lServiceContracts.add(oServiceContract);
            mAccountAndParentIds.put(oServiceContract.AccountId, oServiceContract.Account.ParentId);
        }
        
        //Creating a lookup map of List ServiceContracts by AccountId
        Map<Id, List<ServiceContract>> mAccountServiceContracts = new Map<Id, List<ServiceContract>>();
        for(Id idAccount : mAccountAndParentIds.keySet()){
            List<ServiceContract> lAccountServiceContracts = new List<ServiceContract>();
            for(ServiceContract oServiceContract : lServiceContracts){
                if(oServiceContract.AccountId == idAccount){
                    lAccountServiceContracts.add(oServiceContract);
                }
            }
            mAccountServiceContracts.put(idAccount, lAccountServiceContracts);
        }
        
        List<ServiceContractShare> lInsertContractShares = new List<ServiceContractShare>();
        List<ServiceContractShare> lDeleteContractShares = new List<ServiceContractShare>();
        
        //Looping thru each distinct Account to process the related Account ServiceContracts
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
            
            //Putting Service Contracts for the Account into a Map for processing
            Map<Id, ServiceContract> mContracts = new Map<Id, ServiceContract>();
            for(ServiceContract oServiceContract : mAccountServiceContracts.get(idPrimaryAccountId)){
                mContracts.put(oServiceContract.Id, oServiceContract);
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
                system.debug('Contracts' + mContracts);
                //Retrieving existing Contract shares for deletion
                for(ServiceContractShare oContractShare : [Select Id From ServiceContractShare 
                Where ParentId In:mContracts.keySet() And UserOrGroupId In:mUsers.keySet() And RowCause = 'Manual']){
                    lDeleteContractShares.add(oContractShare);
                }
                
                for(User oUser : mUsers.values()){
                    //Creating ServiceContract Shares
                    for(ServiceContract oContract : mContracts.values()){
                        if(oContract.Is_Exception__c == false){
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
                    }
                }
            }
            
            //Traverse down the hierarchy, making sure that
            //Current Account Admins have access to children Accounts
            List<Id> lAllAccountIds = new List<Id>();
            
            Set<Id> sAcctQueryIds = new Set<Id>();
            Boolean bFoundAllChildren = false;
            sAcctQueryIds.add(idPrimaryAccountId);
            Map<Id, ServiceContract> mChildContracts = new Map<Id, ServiceContract>();
            
            while(bFoundAllChildren == false){
                List<Account> lChildAccounts = new List<Account>([Select Id,
                        (Select Id, AccountId, Modality__c, Is_Exception__c From ServiceContracts Where Is_Exception__c = false)
                        From Account Where ParentId In:sAcctQueryIds]);
                if(lChildAccounts.isEmpty() == true){
                    bFoundAllChildren = true;
                }else{
                    sAcctQueryIds.clear();
                    
                    for(Account oAccount : lChildAccounts){
                        lAllAccountIds.add(oAccount.Id);
                        sAcctQueryIds.add(oAccount.Id);
                        
                        for(ServiceContract oChildContract : oAccount.ServiceContracts){
                            mChildContracts.put(oChildContract.Id, oChildContract);
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
                //Retrieving existing Contract shares for deletion
                for(ServiceContractShare oContractShare : [Select Id From ServiceContractShare 
                Where ParentId In:mChildContracts.keySet() And UserOrGroupId In:mUsers.keySet() And RowCause = 'Manual']){
                    lDeleteContractShares.add(oContractShare);
                }
                
                for(User oUser : mUsers.values()){
                    //Creating ServiceContract Shares
                    for(ServiceContract oContract : mChildContracts.values()){
                        if(oContract.Is_Exception__c == false){
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
                    }
                }
            }
        }
                
        //Deleting existing shares before inserting new shares
        if(lDeleteContractShares.isEmpty() == false){
            delete lDeleteContractShares;
        }
        //Inserting new shares
        if(lInsertContractShares.isEmpty() == false){
            insert lInsertContractShares;
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
            oMail.setSubject('Batch_ProcessAccountContractShares job failed, status: ' + oJob.Status + ' (' + oJob.NumberOfErrors + ' errors out of '+ oJob.JobItemsProcessed + ' batches)');
            oMail.setPlainTextBody('Error Message: ' + sErrorMessage);
            Messaging.sendEmail(new Messaging.SingleEmailMessage[] { oMail });
        }
        
        if(test.isRunningTest() == false) {
            //Kicking off next Batch Job to process Contract Sharing
            system.scheduleBatch(new Batch_ProcessAccountShares(), 'Process Account Sharing', 2);
        }
    }
}