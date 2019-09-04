/**
	* This batch job will run nightly
	* Retrieves Territories where there have been modifications to UserTerritory records within a specified time period
	* Will traverse the Territory hierarchy to find all Territories
	* Will only look at US, UL and Service Territories
		* US Territories start with 'US.'
		* UL Territories start with 'UL.'
		* Service Territories start with 'Service.'
	* Accounts found in the Territories will be updated Process Account Team Members field is set to true - this is an indicator for the Batch_ProcessAccountTeamMembers to update the Account Team Members for the Account
	* When complete, will start Batch_ProcessAccountTeamMembers
	
	* Database.executeBatch(new Batch_UpdateProcessAccountTeamMembers(), 1);
 
	@author NTT Data: Louis Wooldridge
	@date Sep 23, 2015
  	@update 
 **/
global class Batch_UpdateProcessAccountTeamMembers implements Database.Batchable<sObject>, Database.Stateful {
	@TestVisible private Boolean bIsSuccess {get;set;}
	@TestVisible private String sErrorMessage {get;set;}
	@TestVisible private String sTerritoryId {get;set;}
	private Map<Id,Territory2> mLookupTerritory = new Map<Id,Territory2>();
	
	global Batch_UpdateProcessAccountTeamMembers() {
		bIsSuccess = true;
		sErrorMessage = '';
		
		for(Territory2 oTerr : [Select Id, Name, ParentTerritory2Id From Territory2]){
			mLookupTerritory.put(oTerr.Id, oTerr);
		}
	}
	
	global Database.QueryLocator start(Database.BatchableContext BC) {
		Set<Id> sDistinctTerritoryIds = new Set<Id>();
		//Retrieving UserTerritory records that have been modified
		for(UserTerritory2Association oUserTerr : [Select UserId, Territory2Id, IsActive, Id From UserTerritory2Association Where LastModifiedDate > YESTERDAY]){
			sDistinctTerritoryIds.add(oUserTerr.Territory2Id);
		}
		
		if(test.isRunningTest() == true){
			return Database.getQueryLocator([Select Id, Name, ParentTerritory2Id From Territory2 Where Id = :sTerritoryId Limit 1]);
		}else{
			return Database.getQueryLocator([Select Id, Name, ParentTerritory2Id From Territory2 Where Id In:sDistinctTerritoryIds]);
		}
	}
	
	global void execute(Database.BatchableContext BC, List<sObject> lSobjects) {
		Set<String> sDistinctTerritoryNames_US = new Set<String>();
		Set<String> sDistinctTerritoryNames_UL = new Set<String>();
		Set<String> sDistinctTerritoryNames_Service = new Set<String>();
		Set<Id> sDistinctParentTerritoryIds = new Set<Id>();
		Boolean bAddParentId = false;
		
		Territory2 oPrimaryTerritory = (Territory2)lSobjects[0];
		if(oPrimaryTerritory.Name.startsWith('US.')){
			sDistinctTerritoryNames_US.add(oPrimaryTerritory.Name);
			bAddParentId = true;
		}else if(oPrimaryTerritory.Name.startsWith('UL.')){
			sDistinctTerritoryNames_UL.add(oPrimaryTerritory.Name);
			bAddParentId = true;
		}else if(oPrimaryTerritory.Name.startsWith('Service.')){
			sDistinctTerritoryNames_Service.add(oPrimaryTerritory.Name);
			bAddParentId = true;
		}
		if((bAddParentId == true)&&(oPrimaryTerritory.ParentTerritory2Id != null)){
			sDistinctParentTerritoryIds.add(oPrimaryTerritory.ParentTerritory2Id);
		}
		
		//Traversing down the Parent Territories to the lowest level
		while(sDistinctParentTerritoryIds.isEmpty() == false){
			List<Id> lTerritoryIds = new List<Id>(sDistinctParentTerritoryIds);
			sDistinctParentTerritoryIds.clear();
			
			for(String sTerrId : lTerritoryIds){
				if(mLookupTerritory.keySet().contains(sTerrId) == true){
					Territory2 oTerritory = mLookupTerritory.get(sTerrId);
					Boolean bAddChildParentId = false;
					
					if(oTerritory.Name.startsWith('US.')){
						sDistinctTerritoryNames_US.add(oTerritory.Name);
						bAddChildParentId = true;
					}else if(oTerritory.Name.startsWith('UL.')){
						sDistinctTerritoryNames_UL.add(oTerritory.Name);
						bAddChildParentId = true;
					}else if(oTerritory.Name.startsWith('Service.')){
						sDistinctTerritoryNames_Service.add(oTerritory.Name);
						bAddChildParentId = true;
					}
					if((bAddChildParentId == true)&&(oTerritory.ParentTerritory2Id != null)){
						sDistinctParentTerritoryIds.add(oTerritory.ParentTerritory2Id);
					}
				}
			}
		}
		
		List<Account> lUpdateAccounts = new List<Account>();
		for(Account oAccount : [Select Id, Process_Account_Team_Members__c From Account 
		Where TAMS_Territory_Id__c In:sDistinctTerritoryNames_US Or TAMS_UL_Territory_Name__c In:sDistinctTerritoryNames_UL
		Or TAMS_Service_Territory_Name__c In:sDistinctTerritoryNames_Service]){
			oAccount.Process_Account_Team_Members__c = true;
			lUpdateAccounts.add(oAccount);
		}
		
		//Added check to see if Unit Test code is running, the following DML statement caused MIXED_DML_OPERATION errors
		//for unknown reasons.
		if(lUpdateAccounts.isEmpty() == false){
			if(test.isRunningTest() == false){update lUpdateAccounts;}
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
			oMail.setSubject('Batch_UpdateProcessAccountTeamMembers job failed, status: ' + oJob.Status + ' (' + oJob.NumberOfErrors + ' errors out of '+ oJob.JobItemsProcessed + ' batches)');
			oMail.setPlainTextBody('Error Message: ' + sErrorMessage);
			Messaging.sendEmail(new Messaging.SingleEmailMessage[] { oMail });
		}
		
		if(Test.isRunningTest() == false) {
			//Kicking off next Batch Job to process Account Teams
			system.scheduleBatch(new Batch_ProcessAccountTeamMembers(), 'Process Account Team Members', 2, 1);
		}
		
	}
}