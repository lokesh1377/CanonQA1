global class TamsSprCMPCTRL {
    @AuraEnabled
    webservice static String createSPR(Id quoteId){
        System.debug('START:createSPR');
        System.debug('quoteId:'+quoteId);
        try{
            TAMS_Special_Pricing_Request__c spr = new TAMS_Special_Pricing_Request__c();
            List<TAMS_Quotes__c> quotes = [SELECT Customer_Name__c,Modality__c 
                                            FROM TAMS_Quotes__c 
                                            WHERE id =:quoteId LIMIT 1];
            System.debug('quotes size:'+quotes.size());                                         
            if(quotes.size() != 1){
                return 'Error: Unable to quote details for Quote Id:'+quoteId;
            }                   

            spr.TAMS_Quote_SPR__c = quoteId;
            spr.Requested_Response_Date_SPR__c = System.TODAY();
            spr.Delivery_Date_SPR__c = System.TODAY()  + 30;          
            spr.Multi_Modality__c = quotes[0].Modality__c;  
            spr.Bundled_SPR__c = 'No';
            insert spr; 
            System.debug('After inserting SPR Record');
            SPR_Quote__c sprQuote =new SPR_Quote__c(TAMS_SPR__c = spr.Id);
            sprQuote.TAMS_SPR__c = spr.id; 
            sprQuote.Account_SPR__c = quotes[0].Customer_Name__c ;
            sprQuote.TAMS_Quote_SPR__c=quoteId;
            sprQuote.Primary__c = true;
            insert sprQuote;
            System.debug('After inserting SPR Quote Record');
            return spr.id;
        }catch(Exception e){ 
            return 'Error:'+e.getMessage();
        }
    }
}