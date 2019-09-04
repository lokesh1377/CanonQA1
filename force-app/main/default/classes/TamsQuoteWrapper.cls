public class TamsQuoteWrapper {
	public TAMS_Quotes__c tamsQuote {get;set;}
	public Boolean selected {get;set;}
    public TamsQuoteWrapper(TAMS_Quotes__c tamsQ)
    {
        tamsQuote = tamsQ;
        selected = false;
    }	

}