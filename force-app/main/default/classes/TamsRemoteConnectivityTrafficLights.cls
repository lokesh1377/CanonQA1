public class TamsRemoteConnectivityTrafficLights {
	public String lightColor {get;set;}
	public TamsRemoteConnectivityTrafficLights(ApexPages.StandardController stdController) {
		ID ibID= stdController.getId();
		try 
		{
			System.debug('Inside constructor TamsRemoteConnectivityTrafficLights');
			System.debug('ibID:'+ibID);
			Install_Base_TAMS__c ibRecord = 
				[SELECT 
					id, 
					SID_TAMS__c 
				 FROM 
				 	Install_Base_TAMS__c 
				 WHERE ID = :ibID
				];
			System.debug('SID_TAMS__c:'+ibRecord.SID_TAMS__c);

			TAMS_Trending_Database__c trendingDB = 
					[SELECT 
						VPN_c1__c,
						VPN_c2__c,
						VPN_SP__c 
					FROM 
						TAMS_Trending_Database__c 
					WHERE SID__c = :ibRecord.SID_TAMS__c
						AND recordType.name = 'PING'
						ORDER BY CreatedDate DESC
						LIMIT 1];		
			System.debug('VPN_c1__c:'+trendingDB.VPN_c1__c);
			System.debug('VPN_c2__c:'+trendingDB.VPN_c2__c);
			System.debug('VPN_SP__c:'+trendingDB.VPN_SP__c);
			if(trendingDB.VPN_c1__c == '1' && trendingDB.VPN_c2__c == '1' && trendingDB.VPN_SP__c == '1')
			{
				lightColor = 'Green';
			}
			else if(trendingDB.VPN_c1__c == '0' && trendingDB.VPN_c2__c == '0' && trendingDB.VPN_SP__c == '0') 			
			{
				lightColor = 'Red';
			}
			else if(trendingDB.VPN_c1__c == null || trendingDB.VPN_c2__c == null && trendingDB.VPN_SP__c == null) 			
			{
				lightColor = 'NoLight';
			}
			else
			{
				lightColor = 'Yellow';				
			}
		}
		catch(Exception e)
		{
			System.debug('Inside Exception. '+e.getMessage());
			Apexpages.addMessage(new ApexPages.Message(ApexPages.Severity.WARNING,
				'No Data/Invalid Data Available for Remote Connectivity– Please create a Web Support Case via General Inquiry.'));			
		}		
	}	

}