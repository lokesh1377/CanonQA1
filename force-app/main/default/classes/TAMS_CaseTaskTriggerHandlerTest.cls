@isTest
private class TAMS_CaseTaskTriggerHandlerTest {

    static testMethod void testUpdateCaseOwner() {
    	User oCurrentUser = [Select Id From User Where Id = :UserInfo.getUserId()];
    	User oTestUser;
    	User oTestUser2;
    	
    	System.runAs(oCurrentUser){
	        //Creating test Users
	        Profile p = [select id from profile where name='TAMS - Service Agent User'];
	        oTestUser = new User(alias='stnd', email='testNewCase@test.com', profileid=p.Id,
	            emailencodingkey='UTF-8', firstname='Standard', lastname='lastname', languagelocalekey='en_US', 
	            localesidkey='en_US', EmployeeNumber='88888888', isactive=true,
	            timezonesidkey='America/Los_Angeles', username='testNewCase@test.com');
			insert oTestUser;
	        oTestUser2 = new User(alias='stnd2', email='testNewCase2@test.com', profileid=p.Id,
	            emailencodingkey='UTF-8', firstname='Standard2', lastname='lastname2', languagelocalekey='en_US', 
	            localesidkey='en_US', EmployeeNumber='99999999', isactive=true,
	            timezonesidkey='America/Los_Angeles', username='testNewCase2@test.com');
			insert oTestUser2;
    	}
		
        //Creating a test case
        String sCaseRT = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Install').getRecordTypeId();
        Case oTestCase = new Case();
        oTestCase.Subject = 'Test Case';
        oTestCase.Description = 'Test Case Description';
        oTestCase.Type = 'Install';
        oTestCase.RecordTypeId = sCaseRT;
        oTestCase.Primary_Contact_Last_Name__c = 'Last Name';
        oTestCase.Primary_Contact_First_Name__c = 'First Name';
        oTestCase.Primary_Contact_Email__c = 'first.last@test.com';
        oTestCase.Origin = 'Portal';
        insert oTestCase;
        
        test.startTest();
        TAMS_Case_Task__c oTask = new TAMS_Case_Task__c();
        oTask.Task_Type__c = 'External Support';
        oTask.Task_Subject__c = 'Test Task';
        oTask.Task_Status__c = 'Accepted';
        oTask.Task_Priority__c = '4High';
        oTask.Task_Description__c = 'Test Task';
        oTask.Employee_Number__c = '88888888';
        oTask.Case__c = oTestCase.Id;
        insert oTask;
        system.assertEquals(oTestUser.Id, [Select OwnerId From TAMS_Case_Task__c Where Id = :oTask.Id].OwnerId);
        
        oTask.Employee_Number__c = '99999999';
        update oTask;
        system.assertEquals(oTestUser2.Id, [Select OwnerId From TAMS_Case_Task__c Where Id = :oTask.Id].OwnerId);
        test.stopTest();
    }
}