public class Site_Drawing_Request_CTRL {
  @AuraEnabled
    public static String getQuoteRecord(ID quoteId){
        try{
            TAMS_Quotes__c quote = [SELECT Id,Name,Status__c,Site_Plan_Status__c,SID__c FROM TAMS_Quotes__c WHERE ID =:quoteId];
            String str = JSON.serialize(quote);
            return str;
        }catch(Exception e){
             return 'Error:'+e.getMessage();
        }
    }
}