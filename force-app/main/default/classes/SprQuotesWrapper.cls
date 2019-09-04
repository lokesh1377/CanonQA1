public class SprQuotesWrapper {
    public SPR_Quote__c sprQuote {get;set;}
    public Boolean selected {get;set;}
    public Boolean primarySelected {get;set;}
    public SprQuotesWrapper(SPR_Quote__c sprQ)
    {
        sprQuote = sprQ;
        selected = false;
        primarySelected = false;
    }
}