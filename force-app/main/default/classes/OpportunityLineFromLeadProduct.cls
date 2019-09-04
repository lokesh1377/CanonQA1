public class OpportunityLineFromLeadProduct {
	static final String LEAD_SOURCE_360_SALES_ASSIST = '360 Sales Assist'; 
	public static void createOpportunityLine(List<Opportunity> newOpportunities){
		//Find all Opportunities that are converted from 360 Lead
		List<String> modalities = new List<String>();
		List<ID> productIds = new List<ID>();
		List<Opportunity> salesAssistOpportunities = new List<Opportunity>();
		for(Opportunity opp: newOpportunities){
			if(opp.LeadSource == LEAD_SOURCE_360_SALES_ASSIST){
				salesAssistOpportunities.add(opp);
				modalities.add(opp.Modality_TAMS__c);
				productIds.add(opp.Lead_Recommended_Product__c);
			}
		}


		System.debug('Modalities size:'+ modalities.size());
		System.debug('products size:'+ productIds.size());
		if(modalities.size() > 0 ){
			System.debug('Modality[0]:'+ modalities[0]); 
		}
		if(productIds.size()>0 ){
			System.debug('products[0]:'+ productIds[0]);
		}

		//Get All Price Entries based on Price Book and Products
		List<PricebookEntry> priceBookEntries = [SELECT ID,
														Product2Id,
														Pricebook2Id,
														PriceBook2.Modality__c 
												From PricebookEntry
												  WHERE PriceBook2.Modality__c IN :modalities
												  AND Product2Id IN :productIds
												  AND IsActive = True
										];
		

		System.debug('priceBookEntries size:'+ priceBookEntries.size());								
		if(priceBookEntries.size()==0){
			return;
		}

		List<OpportunityLineItem> oppLines = new List<OpportunityLineItem>();
		for(Opportunity opp: salesAssistOpportunities){
			System.debug('Adding Opp Line for Product ID:'+opp.Lead_Recommended_Product__c);
			OpportunityLineItem oppLine = new OpportunityLineItem();
			for(PricebookEntry priceBookEntry: priceBookEntries){
				if(priceBookEntry.Product2Id == opp.Lead_Recommended_Product__c && priceBookEntry.PriceBook2.Modality__c == opp.Modality_TAMS__c ){
					oppLine.PricebookEntryId = priceBookEntry.ID;
				}
			}
			oppLine.OpportunityID = opp.Id;
			oppLine.Quantity = 1;
			oppLine.Description = 'Added based on Recommended Product in '+LEAD_SOURCE_360_SALES_ASSIST+ ' Lead';
			oppLines.add(oppLine);
		}
		System.debug('Opportunities Lines size:'+ oppLines.size());
		if(oppLines.size()>=1){
			insert oppLines;
		}

	}
}