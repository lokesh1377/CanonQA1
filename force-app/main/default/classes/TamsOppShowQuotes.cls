global class TamsOppShowQuotes {
	@AuraEnabled
	webservice static List<TAMS_Quotes__c> getQuotes(String opportunityId){
		System.debug('START:getQuotes');
		System.debug('opportunityId:'+opportunityId);
		List<TAMS_Quotes__c> quotes = [SELECT
											Name,
											Id,
											Primary__c,
											PBOM__c,
											Amount__c,
											Status__c,
											Site_Plan_Status__c
									   FROM
									   	 	TAMS_Quotes__c
									   WHERE Opportunity_Name__c = :opportunityId
									   ORDER BY Primary__c DESC];
		System.debug('Quotes size:'+quotes.size());
		return quotes;									   
	}	

	@AuraEnabled
	webservice static void setPrimary(String quoteId){
		System.debug('START:setPrimary');
		System.debug('quoteId:'+quoteId);				
    	TAMS_Quotes__c updateQuote = new TAMS_Quotes__c();
        updateQuote.Id = quoteId;
        updateQuote.Primary__c = true;
        try{
            update updateQuote;
        } catch(Exception e) {
            ErrorLog.storeException(e.getMessage());
        }
        System.debug('END:setPrimary');
	} 	
	
}