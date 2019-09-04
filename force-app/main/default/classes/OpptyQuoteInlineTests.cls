/*********************************************************
        Author: XELLERATION         
        Purpose: This Test Class is used to test the 
        OpptyQuoteInlineController.        
        1.0 - Brandon Cassis - 03/11/2015 - Created
**********************************************************/

@isTest
                    
public class OpptyQuoteInlineTests {
    
    //Inserts the Object for the standard constructor and then builds the constructor 
    public static testMethod void TestOpptyQuoteInline() {
        Opportunity testOPP = new Opportunity();
        testOpp.Name = 'Test';
        testOpp.closeDate = date.today();
        testOpp.StageName= 'Test';
        insert testOpp;

        ApexPages.currentPage().getParameters().put('lc',testOpp.id);
        ApexPages.StandardController stdOpp = new ApexPages.StandardController(testOpp);
        OpptyQuoteInlineController testOppController  = new OpptyQuoteInlineController(stdOpp);
        OpptyQuoteInlineController.savePrimaryQuote();
    }
}