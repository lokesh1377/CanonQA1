@isTest
public class TamsCaseStatusTrgTEST {
	public static testMethod void testStatusTrigger()
	{
		Account a = new Account();
        a.Name = 'Test';        
        insert a;

        Id RecTypeCIB = 
        	[Select 
        		Id  
        	 From 
        	 	RecordType 
        	 Where 
        	 	SobjectType = 'Install_Base_TAMS__c' 
        	 And IsActive = true 
        	 And Name = 'TAMS Install Base'].Id;
        

        Install_Base_TAMS__c ib = new Install_Base_TAMS__c
        										(Account_Name__c = a.Id, 
        										 Modality_ALL__c = 'MR', 
        										 Manufacturer_ALL__c = 'GE', 
        										 Active_IB__c = true,
        										 RecordTypeId = RecTypeCIB,
        										 Nickname__c = 'Test',
        										 Name = 'Test',
        										 Install_Year_Comp__c = '2012');
		insert ib;        		

		Case c = new Case();
		c.AccountId = a.ID;
		c.Install_Base__c = ib.ID;
		c.Subject = 'Test Case';										
		c.Status = 'New';
		c.Internal_status__c = 'Open';

		insert c;

		TAMS_Case_Task__c t = new TAMS_Case_Task__c();
		t.Case__c = c.ID;
		t.Task_Status__c = 'Accepted';

		insert t;
	}
}