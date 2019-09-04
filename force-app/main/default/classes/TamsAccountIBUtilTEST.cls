@isTest
public class TamsAccountIBUtilTEST {
	public static testMethod void testIBUtilization() {
		PageReference IBUtilizationPage = Page.TamsAccountIBUtilizationChartVF;
		Test.setCurrentPage(IBUtilizationPage);

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
        	 And Name = 'Competitor Install Base'].Id;
        
        Account acc = new Account(Name = 'Test Account');
        insert acc;

        Install_Base_TAMS__c ib = new Install_Base_TAMS__c
        										(Account_Name__c = acc.Id, 
        										 Modality_ALL__c = 'MR', 
        										 Manufacturer_ALL__c = 'GE', 
        										 Active_IB__c = true,
        										 RecordTypeId = RecTypeCIB,
        										 Nickname__c = 'Test',
        										 Name = 'Test',
        										 Install_Year_Comp__c = '2012');
        insert ib; 
        TAMS_System_Utilization__c sysUtil1 = new TAMS_System_Utilization__c
        											(Account__c = acc.ID,
        											 Equipment_Lookup__c = ib.ID,
        											 Study_Date__c = SYSTEM.today() - 5
        											 );
        insert 	sysUtil1;										
        TAMS_System_Utilization__c sysUtil2 = new TAMS_System_Utilization__c
        											(Account__c = acc.ID,
        											 Equipment_Lookup__c = ib.ID,
        											 Study_Date__c = SYSTEM.today() - 5
        											 );        											
		insert 	sysUtil2;        											
        TAMS_System_Utilization__c sysUtil3 = new TAMS_System_Utilization__c
        											(Account__c = acc.ID,
        											 Equipment_Lookup__c = ib.ID,
        											 Study_Date__c = SYSTEM.today() - 4
        											 );
        insert 	sysUtil3;											
        TAMS_System_Utilization__c sysUtil4 = new TAMS_System_Utilization__c
        											(Account__c = acc.ID,
        											 Equipment_Lookup__c = ib.ID,
        											 Study_Date__c = SYSTEM.today() - 4
        											 );
        insert 	sysUtil4;											
        TAMS_System_Utilization__c sysUtil7 = new TAMS_System_Utilization__c
        											(Account__c = acc.ID,
        											 Equipment_Lookup__c = ib.ID,
        											 Study_Date__c = SYSTEM.today() - 4
        											 );
        insert 	sysUtil7;											
        TAMS_System_Utilization__c sysUtil5 = new TAMS_System_Utilization__c
        											(Account__c = acc.ID,
        											 Equipment_Lookup__c = ib.ID,
        											 Study_Date__c = SYSTEM.today() - 3
        											 );
        insert 	sysUtil5;											
        TAMS_System_Utilization__c sysUtil6 = new TAMS_System_Utilization__c
        											(Account__c = acc.ID,
        											 Equipment_Lookup__c = ib.ID,
        											 Study_Date__c = SYSTEM.today() - 2
        											 );        
	insert 	sysUtil6;        											
	ApexPages.StandardController stdCont = new ApexPages.StandardController(acc); 
	TamsAccountIBUtilizationChartCTRL utilCtrl = new TamsAccountIBUtilizationChartCTRL(stdCont);        											
	PageReference pageRef = utilCtrl.refreshChart();		
	pageRef = utilCtrl.returnBack();	

	}
}