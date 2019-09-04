@isTest

public with sharing class TestingUtil {
  public String opId;
  public String scsId;
  public String scsecId;
  public String scsecItemId;
  public String actId;

  public TestingUtil(){
    opId = makeTestableOp();
    scsId = makeSalesCoachStage();
    scsecId = makeSalesCoachSections();
    scsecItemId = makeSecItem();
    actId = makeActivities();
    ApexPages.currentPage().getParameters().put('id', this.opId);
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
  
  private String makeSalesCoachStage(){
    Sales_Coach_Stage__c scs = new Sales_Coach_Stage__c();
    scs.Name='testStage';
    scs.Buyer_Stage__c='testBuyStage';
    scs.Active__c=true;
    insert scs;
    return scs.Id;
  }
  
  private String makeSalesCoachSections(){
    Sales_Coach_Section__c scsec =  new Sales_Coach_Section__c();
    scsec.Section_Ordering__c =1.0;
    scsec.Section_Name__c='testSection';
    scsec.Sales_Coach_Stage__c=scsId;
    scsec.Section_Width__c=33.0;
    insert scsec;
    return scsec.Id;
  }
  
 private String makeSecItem(){
    Sales_Coach_Section_Item__c secItem = new Sales_Coach_Section_Item__c();
    secItem.Section_Ordering__c=1.0;
    secItem.Sales_Coach_Section__c=scsecId;
    secItem.Link_to_Content__c='http://www.google.com';
    secItem.Item_Name__c='testItem';
    secItem.Display__c=true;
    secItem.Products__c='';
    insert secItem;
    return secItem.Id;
 }
 
 private String makeActivities(){
  Sales_Coach_Activity__c sca = new Sales_Coach_Activity__c();
  sca.Sales_Coach_Stage__c=scsId;
  sca.Ordering_Number__c=1.0;
  sca.Activity_Details__c='testActivity';
  insert sca;
  return sca.Id;
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
 public static String makeProductLineItem(Id inputId) {
     OpportunityLineItem tempOLI = new OpportunityLineitem();
     tempOLI.Quantity = 1;
     tempOLI.unitPrice = 100;
     tempOLI.OpportunityId = inputId;
     tempOLI.PricebookEntryId=makePriceBookEntry();     
     insert tempOLI;
     return tempOLI.Id;
 }
 
 public static String makeAccount() {
     Account tempAcc = new Account(name='Test Account');
     tempAcc.Territory_Name_TAMS__c = 'US.GL.2660100.TR-101';
     insert tempAcc;
     return tempAcc.Id;
     
 }
 
 public static TAMS_Quotes__c makeQuote(String inputOpptyId, String inputModality, String inputProductName) {
     TAMS_Quotes__c tempQuote = new TAMS_Quotes__c();
     tempQuote.Primary__c = true;
     tempQuote.Modality__c = inputModality;
     tempQuote.PBOM__c = inputProductName;
     tempQuote.Opportunity_Name__c = inputOpptyId;
     insert tempQuote;
     return tempQuote;
 }
  
 public static User getUser(String inputName) {
     User tempUser = new User();
     tempUser = [select Id, Profile.Name from User where IsActive=true AND Profile.Name = :inputName limit 1];
     return tempUser;
 }
 
 public static String setNewOppty(Id inputAccountId) {
    Opportunity op = new Opportunity();
    op.Name='testOpName';
    op.CloseDate = Date.today();
    op.AccountId = inputAccountId;
    op.StageName='testStage';
    op.Booking_Amount__c = 5000;
    insert op;
    return op.Id;
     
 }
 

}