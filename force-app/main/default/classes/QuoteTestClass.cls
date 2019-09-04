/*********************************************************
        Author: XELLERATION         
        Purpose: This Test Class is used to test when a 
        quote is primary.        
        1.0 - Brandon Cassis - 04/03/2015 - Created
        2.0 - Hemant Kumar - 05/02/2017 - Updated to increase the coverage from 65% to 84%
**********************************************************/

@isTest(SeeAllData=true)

private class QuoteTestClass{

    //Tests the Updating of Booking Amount.
    static testMethod void updateProductTest(){
        TAMS_Quotes__c testQuote = new TAMS_Quotes__c();
        TAMS_Quotes__c testQuote1 = new TAMS_Quotes__c();        
        Opportunity testOppty = new Opportunity();
        testOppty.Id = testingUtil.makeTestableOp();
        makeProductLineItem(testOppty.Id);
        testQuote = testingUtil.makeQuote(testOppty.Id, 'UL', 'XARIO-200.000');
        testQuote.Primary__c = false;        
        update testQuote;
        
        testQuote1 = testingUtil.makeQuote(testOppty.Id, 'UL', 'APLIO-500/PS2.000');
        testQuote1.Primary__c = true;
        update testQuote1;                    
            
        testQuote.Primary__c = true;
        testQuote.PBOM__c = 'NEMIO-20-DC.000';        
        update testQuote; 
        }
        
      public static String makeProductLineItem(Id inputId) {
        OpportunityLineItem tempOLI = new OpportunityLineitem();
        tempOLI.Quantity = 1;
        tempOLI.unitPrice = 100;
        tempOLI.OpportunityId = inputId;
        tempOLI.PricebookEntryId=makePriceBookEntry();     
        insert tempOLI;
        return tempOLI.Id;
 }
     private static string makePriceBookEntry() {
      PricebookEntry pbe = new PricebookEntry();
      pbe.UseStandardPrice = false;
      pbe.Pricebook2Id=makePriceBook();
      pbe.Product2Id=makeProduct();
      pbe.IsActive=true;
      pbe.UnitPrice=100.0;

     insert pbe;
     return pbe.Id;
 }  
 
 private static string makeProduct(){
     Product2 product = new Product2();
      product.Name='Test Product';
      product.IsActive=true;
      insert product;
      return product.Id;
 
 }
 
 private static String makePriceBook() {
      Pricebook2 pb= [select Id,IsActive from PriceBook2 where IsStandard=True];
      if(pb!=null) {
          pb.IsActive = true;
          update pb;
      }
      return pb.Id;
 }      
    
    
}