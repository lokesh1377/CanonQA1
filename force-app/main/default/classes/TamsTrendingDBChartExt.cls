public class TamsTrendingDBChartExt {
	public List<TAMS_Trending_Database__c> trendingRecords {get;set;}
	public String productCode {get;set;}
	public String heliumLevel {get;set;}
	public String shieldTemp {get;set;}
	public TamsTrendingDBChartExt(ApexPages.StandardController stdController) {
		ID ibID = stdController.getId();
		System.debug('inside constructor TamsTrendingDBChartExt');
		System.debug('ibID:'+ibID);
		try{
			Install_Base_TAMS__c ibRecord = 
					[SELECT 
						id, 
						SID_TAMS__c,
						TAMS_Product_Lookup_TAMS__r.Name 
					FROM 
						Install_Base_TAMS__c 
					WHERE ID = :ibID];
			productCode = ibRecord.TAMS_Product_Lookup_TAMS__r.Name;		
			System.debug('SID_TAMS__c:'+ibRecord.SID_TAMS__c);
			trendingRecords = [SELECT 
								MR_HeliumLevel__c,
								MR_ShieldTemp__c 
							  FROM 
								TAMS_Trending_Database__c 
							  WHERE SID__c = :ibRecord.SID_TAMS__c
								ORDER BY CreatedDate DESC
							  LIMIT 1];	
			System.debug('size:'+trendingRecords.size());						  	
			System.debug('MR_HeliumLevel__c:'+trendingRecords[0].MR_HeliumLevel__c);				  
			System.debug('MR_ShieldTemp__c:'+trendingRecords[0].MR_ShieldTemp__c);	
			heliumLevel = trendingRecords[0].MR_HeliumLevel__c;
			shieldTemp = trendingRecords[0].MR_ShieldTemp__c;							  
		}					  
		catch(Exception e)
		{
			System.debug(e.getMessage());
			Apexpages.addMessage(new ApexPages.Message(ApexPages.Severity.WARNING,
				'No Data Or Invalid Data Available for MR Trending Database – Please create a Web Support Case via General Inquiry.'));
		}
	}	

}