@isTest
public class TamsRemoteConnectivityTEST {
	public static testMethod void testRemoveConnectivity() {
		PageReference remoteConnPage = Page.TamsRemoteConnectivityTrafficLightsPage;
		Test.setCurrentPage(remoteConnPage);
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
		System.debug('IB:'+ib); 
		System.debug('Nickname__c:'+ib.Nickname__c);
		ID recordTypeID = Schema.SObjectType.TAMS_Trending_Database__c.getRecordTypeInfosByName().get('PING').getRecordTypeId();
		System.assert(recordTypeID <> NULL);
		System.debug('Nickname__c:'+IB.Nickname__c);
		System.debug('SID_TAMS__c:'+IB.SID_TAMS__c);	
		TAMS_Trending_Database__c trendingDB = new TAMS_Trending_Database__c(
														RecordTypeID = recordTypeID,
													 	Modality__c = IB.Modality_ALL__c,
													 	SID__c = IB.SID_TAMS__c,
													 	VPN_c1__c = '1',
													 	VPN_c2__c = '1',
													 	VPN_SP__c = '1');

		insert trendingDB;
		System.debug('VPN_c1__c:'+trendingDB.VPN_c1__c);
		System.debug('VPN_c2__c:'+trendingDB.VPN_c2__c);
		System.debug('VPN_SP__c:'+trendingDB.VPN_SP__c);
		System.debug('CreatedDate:'+trendingDB.CreatedDate);
		ApexPages.currentPage().getParameters().put('ID', IB.ID);
		ApexPages.StandardController stdCont = new ApexPages.StandardController(IB); 
		TamsRemoteConnectivityTrafficLights remoteConnCtrl = new TamsRemoteConnectivityTrafficLights(stdCont);
		System.debug('lightColor:'+remoteConnCtrl.lightColor);
		System.assert('Green' == remoteConnCtrl.lightColor);
		trendingDB.VPN_c2__c = null;
		upsert trendingDB;
		stdCont = new ApexPages.StandardController(IB); 
		remoteConnCtrl = new TamsRemoteConnectivityTrafficLights(stdCont);		
		System.debug('lightColor:'+remoteConnCtrl.lightColor);
		System.assert('Yellow' == remoteConnCtrl.lightColor);		
		trendingDB.VPN_c1__c = null;
		trendingDB.VPN_c2__c = null;
		trendingDB.VPN_SP__c = null;
		upsert trendingDB;
		stdCont = new ApexPages.StandardController(IB); 
		remoteConnCtrl = new TamsRemoteConnectivityTrafficLights(stdCont);		
		System.debug('lightColor:'+remoteConnCtrl.lightColor);
		System.assert('NoLight' == remoteConnCtrl.lightColor);		

		trendingDB.VPN_c1__c = '0';
		trendingDB.VPN_c2__c = '0';
		trendingDB.VPN_SP__c = '0';
		upsert trendingDB;
		stdCont = new ApexPages.StandardController(IB); 
		remoteConnCtrl = new TamsRemoteConnectivityTrafficLights(stdCont);		
		System.debug('lightColor:'+remoteConnCtrl.lightColor);
		System.assert('Red' == remoteConnCtrl.lightColor);
		List<TAMS_Trending_Database__c> trendingDBList =
			[SELECT
				ID
			FROM
				TAMS_Trending_Database__c
			WHERE SID__c = :IB.SID_TAMS__c
				AND recordType.name = 'PING' 
			];
		delete trendingDBList; //This will cause the exception
		stdCont = new ApexPages.StandardController(IB); 
		remoteConnCtrl = new TamsRemoteConnectivityTrafficLights(stdCont);		
		System.debug('lightColor:'+remoteConnCtrl.lightColor);
		System.assert(remoteConnCtrl.lightColor == null);			
	}
}