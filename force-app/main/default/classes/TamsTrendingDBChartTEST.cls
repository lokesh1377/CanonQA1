@isTest
public class TamsTrendingDBChartTEST {
	public static testMethod void testTrendingDBChart() {
		PageReference trendingDBChartPage = Page.TamsTrendingDBChartPage;
		Test.setCurrentPage(trendingDBChartPage);
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
        										
		TAMS_Trending_Database__c trendingDB = new TAMS_Trending_Database__c
														(SID__c = ib.SID_TAMS__c,
														 MR_HeliumLevel__c = '80',
														 MR_ShieldTemp__c = '45.5');
		insert trendingDB;
		System.debug('MR_HeliumLevel__c:' + trendingDB.MR_HeliumLevel__c);												
		System.debug('MR_ShieldTemp__c:' + trendingDB.MR_ShieldTemp__c);
		ApexPages.currentPage().getParameters().put('ID', ib.ID);
		ApexPages.StandardController stdCont = new ApexPages.StandardController(ib); 
		TamsTrendingDBChartExt trendingDBCtrl = new TamsTrendingDBChartExt(stdCont);
		System.assert(trendingDBCtrl.heliumLevel == '80');
		System.assert(trendingDBCtrl.shieldTemp == '45.5');
		System.debug('productCode:' + trendingDBCtrl.productCode);
		
		List<TAMS_Trending_Database__c> trendingDBList =
			[SELECT
				ID
			FROM
				TAMS_Trending_Database__c
			WHERE SID__c = :ib.SID_TAMS__c
			];
		delete trendingDBList; //This will cause the exception
		stdCont = new ApexPages.StandardController(ib); 
		trendingDBCtrl = new TamsTrendingDBChartExt(stdCont);				
		System.debug('heliumLevel:' + trendingDBCtrl.heliumLevel);
		System.assert(trendingDBCtrl.heliumLevel == NULL);
	}
}