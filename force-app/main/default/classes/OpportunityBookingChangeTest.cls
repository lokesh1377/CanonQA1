/*********************************************************
        Author: XELLERATION         
        Purpose: This Test Class is used to test when a 
        booking amount is changed on the Oppty.        
        1.0 - Brandon Cassis - 03/11/2015 - Created
**********************************************************/

@isTest(SeeAllData=true)

private class OpportunityBookingChangeTest{

    //Tests the Exception Storing Method.
    static testMethod void updateBookingTest(){
        Opportunity testOppty = new Opportunity();
        testOppty.Id = testingUtil.makeTestableOp();
        testingUtil.makeProductLineItem(testOppty.Id);
        testOppty.Booking_Amount__c = 10000;
        update testOppty;
    }
   public static String makeTestableOp(){
    Opportunity op = new Opportunity();
    op.Name='testOpName';
    op.CloseDate = Date.today();
    op.StageName='testStage';
    op.Booking_Amount__c = 5000;
    insert op;
    return op.Id;
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
}