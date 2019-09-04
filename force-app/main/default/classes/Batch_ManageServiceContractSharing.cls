/**
    * This batch job will run nightly and will be started by Batch_ProcessAccountShares when it completes
    * Retrieves Service Contracts that have been modified within a specified time period
        * Service Contract Modality cannot be null
    * For each Service Contract will build Service Contract shares
        * Builds read-only share records for the Contacts and Affiliated Users related to the Account specified on the Service Contract
        * Modality on the Contact & Affiliated Users needs to match the Modality on the Service Contract
    * When complete, will start Batch_ProcessCaseSharing
    
    * Batch_ManageServiceContractSharing b = new Batch_ManageServiceContractSharing();
    * b.bProcessAllCases = true;
    * Database.executeBatch(b, 1);
 
    @author NTT Data: Louis Wooldridge
    @date Sep 23, 2015
    @update Dec 16, 2015 - Added ability to process all Contracts by setting new parameter bProcessAllCase = true
                            Added check for if(oContract.Is_Exception__c == false)
    @Hemant Kumar - 03/12/2019 - Checked for Active User                            
 **/
global class Batch_ManageServiceContractSharing implements Database.Batchable<SObject>,Database.Stateful{
    @TestVisible private Boolean bIsSuccess {get;set;}
    @TestVisible private String sErrorMessage {get;set;}
    @TestVisible private String sServiceContractId {get;set;}
    public Boolean bProcessAllCases {get;set;}
    
    global Batch_ManageServiceContractSharing(){
        bIsSuccess = true;
        sErrorMessage = '';
        bProcessAllCases = false;
    }
    
    global Database.QueryLocator start(Database.BatchableContext BC) {
        if(test.isRunningTest() == true){
            return Database.getQueryLocator([Select Id, AccountId, Is_Exception__c, Modality__c 
                From ServiceContract Where Modality__c != null And Id = :sServiceContractId Limit 1]);
        }else{
            if(bProcessAllCases == true){
                return Database.getQueryLocator([Select Id, AccountId, Is_Exception__c, Modality__c 
                    From ServiceContract Where Modality__c != null]);
            }else{
                return Database.getQueryLocator([Select Id, AccountId, Is_Exception__c, Modality__c 
                    From ServiceContract Where Modality__c != null And LastModifiedDate > YESTERDAY]);
            }
        }
    }
    
    global void execute(Database.BatchableContext BC, List<sObject> lSobjects) {
        Map<Id, ServiceContract> mAllServiceContracts = new Map<Id, ServiceContract>();
        Set<Id> sDistinctAccountIds = new Set<Id>();
        
        for(Sobject obj : lSobjects){
            ServiceContract oServiceContract = (ServiceContract)obj;
            mAllServiceContracts.put(oServiceContract.Id, oServiceContract);
            sDistinctAccountIds.add(oServiceContract.AccountId);
        }
        
        //Retrieving Account Affiliation Users
        Set<String> sAffiliations = new Set<String>();
        Map<Id, Id> mLookupAccountId = new Map<Id, Id>();
        for(TAMS_Affiliation__c oAff : [Select User__c, Account__c From TAMS_Affiliation__c Where Account__c In:sDistinctAccountIds]){
            sAffiliations.add(oAff.User__c + '-' + oAff.Account__c);
            mLookupAccountId.put(oAff.User__c, oAff.Account__c);
        }
        Map<Id, User> mAffiliatedUsers = new Map<Id, User>([Select Id, ContactId, Contact.Modality__c, IsPortalEnabled 
                                                            From User Where Id In:mLookupAccountId.keySet() 
                                                            And Contact.Modality__c != null And IsPortalEnabled = true
                                                            And IsActive = true]);
        //Retrieving all portal users for each Account
        Map<Id, User> mPortalUsers = new Map<Id, User>([Select Id, ContactId, Contact.AccountId, Contact.Modality__c, IsPortalEnabled 
                                                            From User Where Contact.AccountId In:sDistinctAccountIds
                                                            And Contact.Modality__c != null And IsPortalEnabled = true
                                                            And IsActive = true]);
                                                            
        //Deleting existing ServiceContractShares
        List<ServiceContractShare> lDeleteContractShares = new List<ServiceContractShare>();
        for(ServiceContractShare oContractShare : [Select Id, ParentId, UserOrGroupId From ServiceContractShare 
        Where ParentId In:mAllServiceContracts.keySet() And RowCause = 'Manual']){
            if(mPortalUsers.keySet().contains(oContractShare.UserOrGroupId) == true){
                if(mPortalUsers.get(oContractShare.UserOrGroupId).Contact.AccountId == mAllServiceContracts.get(oContractShare.ParentId).AccountId){
                    lDeleteContractShares.add(oContractShare);
                }
            }
            if(sAffiliations.contains(oContractShare.UserOrGroupId + '-' + mAllServiceContracts.get(oContractShare.ParentId).AccountId) == true){
                lDeleteContractShares.add(oContractShare);
            }
        }
        
        if(lDeleteContractShares.isEmpty() == false){
            delete lDeleteContractShares;
        }
        
        List<ServiceContractShare> lInsertContractShares = new List<ServiceContractShare>();
        //Creating new Contract Share records Account Portal Users
        for(ServiceContract oContract : mAllServiceContracts.values()){
            if(oContract.Is_Exception__c == false){
                for(User oUser : mPortalUsers.values()){
                    if((mPortalUsers.get(oUser.Id).Contact.Modality__c != null)&&(oContract.Modality__c != null)){
                        if((mPortalUsers.get(oUser.Id).Contact.Modality__c.contains(oContract.Modality__c))&&(oUser.Contact.AccountId == oContract.AccountId)){
                            ServiceContractShare oNewShare = new ServiceContractShare();
                            oNewShare.AccessLevel = 'Read';
                            oNewShare.ParentId = oContract.Id;
                            oNewShare.UserOrGroupId = oUser.Id;
                            lInsertContractShares.add(oNewShare);
                        }
                    }
                }
                
                for(User oUser : mAffiliatedUsers.values()){
                    if((sAffiliations.contains(oUser.Id + '-' + mAllServiceContracts.get(oContract.Id).AccountId) == true)&&(oContract.Modality__c != null)){
                        if(mAffiliatedUsers.get(oUser.Id).Contact.Modality__c.contains(oContract.Modality__c)){
                            ServiceContractShare oNewShare = new ServiceContractShare();
                            oNewShare.AccessLevel = 'Read';
                            oNewShare.ParentId = oContract.Id;
                            oNewShare.UserOrGroupId = oUser.Id;
                            lInsertContractShares.add(oNewShare);
                        }
                    }
                }
            }
        }
        
        if(lInsertContractShares.isEmpty() == false){
            insert lInsertContractShares;
        }
    }
        
    global void finish(Database.BatchableContext BC){
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
            oMail.setSubject('Batch_ManageServiceContractSharing job failed, status: ' + oJob.Status + ' (' + oJob.NumberOfErrors + ' errors out of '+ oJob.JobItemsProcessed + ' batches)');
            oMail.setPlainTextBody('Error Message: ' + sErrorMessage);
            Messaging.sendEmail(new Messaging.SingleEmailMessage[] { oMail });
        }
        
        if(test.isRunningTest() == false) {
            //Kicking off next Batch Job to process Case Sharing
            system.scheduleBatch(new Batch_ProcessCaseSharing(), 'Process Case Sharing', 2);
        }
    }
    
}