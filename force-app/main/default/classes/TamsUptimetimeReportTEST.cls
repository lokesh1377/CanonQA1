@isTest
public class TamsUptimetimeReportTEST {
	public static testMethod void testUptimeReport() {
		PageReference uptimeReportPage = Page.TamsUptimeReportChartPage;
		Test.setCurrentPage(uptimeReportPage);
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
        										 SID_TAMS__c = 'TEST_SID',
        										 Nickname__c = 'Test',
        										 Name = 'Test',
        										 Install_Year_Comp__c = '2012');
        insert ib;
		
		TAMS_Uptime_Report__c uptimeRecord = new TAMS_Uptime_Report__c
													(SID__c = ib.SID_TAMS__c,
													 Covered_HardDown__c  = 1,
													 Hours_Covered__c  = 100,
													 TwentyFourSeven_Hours__c = 100,
													 Period_value__c = 'XXTestXX',
													 Period_Sequence__c = 1
													);
		insert uptimeRecord;		
		ApexPages.StandardController stdCont = new ApexPages.StandardController(ib); 
		TamsUptimeReportChartExtClass uptimeReportCtrl = new TamsUptimeReportChartExtClass(stdCont);

		System.assert(uptimeReportCtrl.uptimeData.size() == 1);
		System.assert(uptimeReportCtrl.uptimeData[0].Uptime_Percentage__c == 99);
		delete 	uptimeRecord;
		stdCont = new ApexPages.StandardController(ib); 
		uptimeReportCtrl = new TamsUptimeReportChartExtClass(stdCont);

		System.assert(uptimeReportCtrl.uptimeData.size() == 0);

		
	}
}