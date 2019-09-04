/**
    * This batch job will run nightly
    * Retrieves Accounts where Process Account Shares field equals true
    * For each Account will build AccountShare records
        * Will add shares for Contacts on the Account, Contacts going up the Parent Account hierarchy and also Contacts going down the Child Account hierarchy
        * Account shares will be updated
    * When complete, will start Batch_ManageServiceContractSharing
    * Batch_ProcessAccountCaseShares, Batch_ProcessAccountContractShares and Batch_ProcessAccountShares have similar logic flow,
    * make sure to check to see if any updates to the code will need to be replicated to the to other batch code classes.
    
    * Database.executeBatch(new Batch_ProcessAccountShares());
 
    @author NTT Data: Louis Wooldridge
    @date Sep 23, 2015
    @update Dec 2, 2015 - Batch re-written and broken up into three separate batch jobs to avoid governor limits
    @update Feb 1, 2016 - Added check for idParents by HK
 **/
global class Batch_ProcessAccountShares implements Database.Batchable<sObject>, Database.Stateful {
    @TestVisible private Boolean bIsSuccess {get;set;}
    @TestVisible private String sErrorMessage {get;set;}
    @TestVisible private String sAccountId {get;set;}
    private Map<String, Id> mProfiles = new Map<String, Id>();
    
    global Batch_ProcessAccountShares() {
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
            return Database.getQueryLocator([Select Name, Process_Account_Shares__c, Id, 
                                                (Select Id From Contacts),
                                                ParentId ,
                                                Parent.ParentId,
                                                Parent.Parent.ParentId,
                                                Parent.Parent.Parent.ParentId,
                                                Parent.Parent.Parent.Parent.ParentId,
                                                Parent.Parent.Parent.Parent.Parent.ParentId
                                        From Account Where Id = :sAccountId Limit 1]); 
        }else{
            return Database.getQueryLocator([Select Name, Process_Account_Shares__c, Id, 
                                                (Select Id From Contacts),
                                                ParentId ,
                                                Parent.ParentId,
                                                Parent.Parent.ParentId,
                                                Parent.Parent.Parent.ParentId,
                                                Parent.Parent.Parent.Parent.ParentId,
                                                Parent.Parent.Parent.Parent.Parent.ParentId                                            
                                            From Account Where Process_Account_Shares__c = true]);
        }
    }
    
    global void execute(Database.BatchableContext BC, List<sObject> lSobjects) {
        List<Account> lUpdateAccounts = new List<Account>();
        List<AccountShare> lInsertAccountShares = new List<AccountShare>();
        
        //Converting sObject list to List of Accounts to be processed
        List<Account> lAccountsToProcess = new List<Account>();
        for(sObject oAccountSobject : lSobjects){
            Account oAccount = (Account)oAccountSobject;
            lAccountsToProcess.add(oAccount);
        }
        
        for(Account oAccount : lAccountsToProcess){
            system.debug('Processing Account: ' + oAccount);
            List<Id> lContactIds = new List<Id>();
            
            //Traverse up the hierarchy, making sure that 
            //Parent Account Admins have access to current Account
            Id idParent = oAccount.ParentId;
            
            Set<Id> parentIds = new Set<Id>();
            Id parentId1 = oAccount.ParentId;
            Id topParentId;
            If(parentId1 != null){
                parentIds.add(parentId1);    
                topParentId = parentId1;
            }

            Id parentId2 = oAccount.Parent.ParentId;
            If(parentId2 != null){
                parentIds.add(parentId2);    
                topParentId = parentId2;
            }

            Id parentId3 = oAccount.Parent.Parent.ParentId;
            If(parentId3 != null){
                parentIds.add(parentId3);    
                topParentId = parentId3;
            }

            Id parentId4 = oAccount.Parent.Parent.Parent.ParentId;
            If(parentId4 != null){
                parentIds.add(parentId4);    
                topParentId = parentId4;
            }

            Id parentId5 = oAccount.Parent.Parent.Parent.Parent.ParentId;
            If(parentId5 != null){
                parentIds.add(parentId5);
                topParentId = parentId5;    
            }
            Id parentId6 = oAccount.Parent.Parent.Parent.Parent.Parent.ParentId;
            If(parentId6 != null){
                parentIds.add(parentId6);
                topParentId = parentId6;    
            }
            
            //Retrieving Primary Account Contacts 
            //for(Contact oContact : [Select Id From Contact Where AccountId = :oAccount.Id]){
            //    lContactIds.add(oContact.Id);
            //}

            for(Contact oContact: oAccount.contacts){
                lContactIds.add(oContact.Id);    
            }

            //Retrieving Contacts from higher level accounts
            while( parentIds.size() > 0 ){
                     
                for(Contact oContact : [Select 
                                          Id
                                        From Contact 
                                        Where AccountId 
                                        IN :parentIds]){
                    lContactIds.add(oContact.Id);
                }

                List<Account> accounts = [SELECT 
                                            ParentId,
                                            Parent.ParentId,
                                            Parent.Parent.ParentId,
                                            Parent.Parent.Parent.ParentId,
                                            Parent.Parent.Parent.Parent.ParentId,
                                            Parent.Parent.Parent.Parent.Parent.ParentId
                                          FROM Account
                                          WHERE Id = :topParentId ];
                for(Account acct: accounts){                          
                    parentIds.clear();
                    parentId1 = acct.ParentId;
                    If(parentId1 != null){
                        parentIds.add(parentId1);    
                        topParentId = parentId1;
                    }

                    parentId2 = acct.Parent.ParentId;
                    If(parentId2 != null){
                        parentIds.add(parentId2);
                        topParentId = parentId2;    
                    }

                    parentId3 = acct.Parent.Parent.ParentId;
                    If(parentId3 != null){
                        parentIds.add(parentId3);    
                        topParentId = parentId3;
                    }

                    parentId4 = acct.Parent.Parent.Parent.ParentId;
                    If(parentId4 != null){
                        parentIds.add(parentId4);
                        topParentId = parentId4;    
                    }

                    parentId5 = acct.Parent.Parent.Parent.Parent.ParentId;
                    If(parentId5 != null){
                        parentIds.add(parentId5);
                        topParentId = parentId5;    
                    }
                    parentId6 = acct.Parent.Parent.Parent.Parent.Parent.ParentId;
                    If(parentId6 != null){
                        parentIds.add(parentId6);
                        topParentId = parentId6;    
                    }                    
                }
            }
            system.debug('Contacts: ' + lContactIds);
            
            //Sharing primary Account with Contacts on higher level Accounts
            if(lContactIds.isEmpty() == false){
                Map<Id, User> mUsers = new Map<Id, User>();
                for(User oUser : [Select Id, Name, ProfileId, Contact.Modality__c From User Where ProfileId = :mProfiles.values()
                And ContactId In :lContactIds And IsActive = true]){
                    mUsers.put(oUser.Id, oUser);
                }
                system.debug('Users: ' + mUsers);
                
                for(User oUser : mUsers.values()){
                    AccountShare oShare = new AccountShare();
                    oShare.UserOrGroupId = oUser.Id;
                    oShare.AccountId = oAccount.Id;
                    if(oUser.ProfileId == mProfiles.get('Admin')){
                        oShare.AccountAccessLevel = 'Edit';
                    }else{
                        oShare.AccountAccessLevel = 'Read';
                    }
                    oShare.OpportunityAccessLevel = 'None';
                    lInsertAccountShares.add(oShare);
                }
            }
            
            //Traverse down the hierarchy, making sure that
            //Current Account Admins have access to children Accounts
            List<Id> lAllAccountIds = new List<Id>();
            
            Set<Id> sAcctQueryIds = new Set<Id>();
            Boolean bFoundAllChildren = false;
            sAcctQueryIds.add(oAccount.Id);


            
            while(bFoundAllChildren == false){
                List<Account> lChildAccounts = new List<Account>([Select Id
                        From Account Where ParentId In:sAcctQueryIds]);
                if(lChildAccounts.isEmpty() == true){
                    bFoundAllChildren = true;
                }else{
                    sAcctQueryIds.clear();
                    
                    for(Account oChildAccount : lChildAccounts){
                        lAllAccountIds.add(oChildAccount.Id);
                        sAcctQueryIds.add(oChildAccount.Id);
                    }
                }
            }
            
            if(lAllAccountIds.isEmpty() == false){
                Map<Id, User> mUsers = new Map<Id, User>();
                for(User oUser : [Select Id, ProfileId, Contact.Modality__c From User Where ProfileId = :mProfiles.values()
                And Contact.AccountId = :oAccount.Id And IsActive = true]){
                    mUsers.put(oUser.Id, oUser);
                }
                
                for(User oUser : mUsers.values()){
                    for(Id idAccount : lAllAccountIds){
                        AccountShare oShare = new AccountShare();
                        oShare.UserOrGroupId = oUser.Id;
                        oShare.AccountId = idAccount;
                        if(oUser.ProfileId == mProfiles.get('Admin')){
                            oShare.AccountAccessLevel = 'Edit';
                        }else{
                            oShare.AccountAccessLevel = 'Read';
                        }
                        oShare.OpportunityAccessLevel = 'None';
                        lInsertAccountShares.add(oShare);
                    }
                }
            }
            
            //Reseting flag
            oAccount.Process_Account_Shares__c = false;
            lUpdateAccounts.add(oAccount);
        }
        
        //Inserting new shares
        if(lInsertAccountShares.isEmpty() == false){
            insert lInsertAccountShares;
        }
        
        //Updating Accounts to reset process flag
        update lUpdateAccounts;
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
            oMail.setSubject('Batch_ProcessAccountShares job failed, status: ' + oJob.Status + ' (' + oJob.NumberOfErrors + ' errors out of '+ oJob.JobItemsProcessed + ' batches)');
            oMail.setPlainTextBody('Error Message: ' + sErrorMessage);
            Messaging.sendEmail(new Messaging.SingleEmailMessage[] { oMail });
        }
        
        if(test.isRunningTest() == false) {
            //Kicking off next Batch Job to process Contract Sharing
            system.scheduleBatch(new Batch_ManageServiceContractSharing(), 'Process Manage Service Contract Sharing', 2, 1);
        }
    }
}