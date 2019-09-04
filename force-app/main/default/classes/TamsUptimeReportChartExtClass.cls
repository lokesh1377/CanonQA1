public with sharing class TamsUptimeReportChartExtClass {
	public List<TAMS_Uptime_Report__c> uptimeData {get;set;}
	private ID ibID;
	private Install_Base_TAMS__c ib;
	private String SID;
	public TamsUptimeReportChartExtClass(ApexPages.StandardController stdController) 
	{
		System.debug('Inside: constructor TamsUptimeReportChartExtClass');
		ibID = stdController.getId();
		System.debug('ibID:'+ibID);
		ib  = 	[SELECT 
					SID_TAMS__c 
				FROM 
					Install_Base_TAMS__c 
				WHERE ID = :ibID];
		SID = ib.SID_TAMS__c;
		System.debug('SID:'+SID);
		uptimeData = new List<TAMS_Uptime_Report__c>();
		uptimeData = [SELECT 
						Uptime_Percentage__c,
						Contract_Uptime_Percentage__c,
						Period_value__c,
						Period_Sequence__c
					  FROM 
					  	TAMS_Uptime_Report__c
					  WHERE 
					  	SID__c = :SID
					  ORDER BY Period_Sequence__c
					  ];	
		System.debug('uptimeData.size():'+uptimeData.size());			  
		if(uptimeData.size()==0)	
		{
			Apexpages.addMessage(new ApexPages.Message(ApexPages.Severity.WARNING,
				'No Data Available for Uptime Report – Please create a Web Support Case via General Inquiry.'));				
		}		  	

	}
}