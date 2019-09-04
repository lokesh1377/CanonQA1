@isTest
/*********************************************************
        Author: NTT Centerstance
        Purpose: Test Opportunity Trigger
        1.0 - Nanda Tumurugoti - 07/24/2013 - Created
        2.0 - Hemant Kumar - 04/24/2019 - Updated for the UL Cardiology   
**********************************************************/
public with sharing class Test_OpportunityTriggers {

    static testMethod void testOppInsert(){
        Account a = new Account();
        a.Name = 'Test';
        a.CT_ZBM_Acc__c = '005i0000000xPhWAAU';
        a.MR_ZBM_Acc__c = '005i0000000xPhWAAU';
        a.UL_ZBM_Acc__c = '005i0000000xPhWAAU';
        a.UL_ZBM_Acc_Cardiology__c = '005i0000000xPhWAAU';
        a.XR_VL_ZBM_Acc__c = '005i0000000xPhWAAU';
        a.Territory_Name_TAMS__c = 'Bedford Bob US.CE.2650100.TR-105';      
        insert a;
       
        
        Opportunity o = new Opportunity();
        o.Name = 'Test';
        o.AccountId = a.id;
        o.Modality_TAMS__c = 'UL';
        o.Segment_TAMS__c  = 'Radiology';
        o.Expected_Bill_Date_TAMS__c = Date.today() + 2;
        o.CloseDate =  Date.today()+1;
        o.StageName = 'Closed/Lost';
        o.Lost_Cancelled_Reason_TAMS__c = 'Functionality/Insufficient Technology';
        o.Competitor_Lost_to_TAMS__c = 'GE';
        o.LeadSource = 'Cold Call';
        o.Incumbent_TAMS__c = 'GE';
        o.Competitor_Lost_to_TAMS__c = 'GE';
        o.Is_this_Product_Funded_TAMS__c = 'Yes';
        o.Additional_Comments_TAMS__c = 'Test Comments';
        o.Actual_Book_Date_TAMS__c = Date.today();
        //insert o;
        
               
        try{    
            test.startTest();
                insert o;
            test.stopTest();
         } catch (exception e) {
            System.assert(false);
        } 
                
        Product2 product   = createProduct('Test Product','UL','AQUILION PRIME');
        PriceBook2 pb      = createPriceBook('UL Price Book','UL');
        PriceBookEntry pbe = createPriceBookEntry(product.Id,pb.Id);
        OpportunityLineitem oppLine = createOpportunityLine(o.Id,pbe.Id);                  

     
        Opportunity o1 = new Opportunity();
        o1.Name = 'ULTest';
        o1.AccountId = a.id;
        o1.Modality_TAMS__c = 'UL';
        o1.Segment_TAMS__c  = 'Cardiology';
        o1.Expected_Bill_Date_TAMS__c = Date.today() + 2;
        o1.CloseDate =  Date.today()+1;
        o1.StageName = 'Closed/Lost';
        o1.Is_this_Product_Funded_TAMS__c = 'Yes';
        o1.Additional_Comments_TAMS__c = 'Test Comments';
        o1.Actual_Book_Date_TAMS__c = Date.today();
        insert o1;

        Opportunity o2 = new Opportunity();
        o2.Name = 'CTTest';
        o2.AccountId = a.id;
        o2.Modality_TAMS__c = 'CT';
        o2.Segment_TAMS__c  = 'Cardiology';
        o2.Expected_Bill_Date_TAMS__c = Date.today() + 2;
        o2.CloseDate =  Date.today()+1;
        o2.StageName = 'Closed/Lost';
        o2.Is_this_Product_Funded_TAMS__c = 'Yes';
        o2.Additional_Comments_TAMS__c = 'Test Comments';
        o2.Actual_Book_Date_TAMS__c = Date.today();
        insert o2;

        Opportunity o3 = new Opportunity();
        o3.Name = 'MRTest';
        o3.AccountId = a.id;
        o3.Modality_TAMS__c = 'MR';
        o3.Segment_TAMS__c  = 'Cardiology';
        o3.Expected_Bill_Date_TAMS__c = Date.today() + 2;
        o3.CloseDate =  Date.today()+1;
        o3.StageName = 'Closed/Lost';
        o3.Is_this_Product_Funded_TAMS__c = 'Yes';
        o3.Additional_Comments_TAMS__c = 'Test Comments';
        o3.Actual_Book_Date_TAMS__c = Date.today();
        insert o3;

        Opportunity o4 = new Opportunity();
        o4.Name = 'VLTest';
        o4.AccountId = a.id;
        o4.Modality_TAMS__c = 'VL';
        o4.Segment_TAMS__c  = 'Cardiology';
        o4.Expected_Bill_Date_TAMS__c = Date.today() + 2;
        o4.CloseDate =  Date.today()+1;
        o4.StageName = 'Closed/Lost';
        o4.Is_this_Product_Funded_TAMS__c = 'Yes';
        o4.Additional_Comments_TAMS__c = 'Test Comments';
        o4.Actual_Book_Date_TAMS__c = Date.today();
        insert o4;
        
           
    }

static testMethod void testOppUpdate(){
        Account a = new Account();
        a.Name = 'Test';
        a.CT_ZBM_Acc__c = '005i0000000xPhWAAU';
        a.MR_ZBM_Acc__c = '005i0000000xPhWAAU';
        a.UL_ZBM_Acc__c = '005i0000000xPhWAAU';
        a.UL_ZBM_Acc_Cardiology__c = '005i0000000xPhWAAU';
        a.XR_VL_ZBM_Acc__c = '005i0000000xPhWAAU';        
        a.Territory_Name_TAMS__c = 'Bedford Bob US.CE.2650100.TR-105';     
        //insert a;
        insert a;
        
        Opportunity o = new Opportunity();
        o.Name = 'Test';
        o.AccountId = a.id;
        o.ownerid   = '005i0000000xPhWAAU';
        o.Modality_TAMS__c = 'UL';
        o.Segment_TAMS__c  = 'Cardiology';
        o.Expected_Bill_Date_TAMS__c = Date.today() + 2;
        o.CloseDate =  Date.today()+1;
        o.StageName = 'Milestone 3: Negotiations';
        o.LeadSource = 'Cold Call';
        o.Incumbent_TAMS__c = 'GE';
        o.Competitor_Lost_to_TAMS__c = 'GE';
        o.Is_this_Product_Funded_TAMS__c = 'Yes';
        insert o;

        Product2 product   = createProduct('Test Product','UL','AQUILION PRIME');
        PriceBook2 pb      = createPriceBook('UL Price Book','UL');
        PriceBookEntry pbe = createPriceBookEntry(product.Id,pb.Id);
        OpportunityLineitem oppLine = createOpportunityLine(o.Id,pbe.Id);  
                
        //o.Modality_TAMS__c = 'MR';
        o.ownerid   = '005i0000000xPhW';
        o.StageName = 'Closed/Lost';
        o.Lost_Cancelled_Reason_TAMS__c = 'Functionality/Insufficient Technology';
        o.Competitor_Lost_to_TAMS__c = 'GE';
        o.Additional_Comments_TAMS__c = 'Test Comments';
        o.Actual_Book_Date_TAMS__c = Date.today();
        update o;
       //  HK on 5/1/14       
        try{    
            test.startTest();
                update o;
            test.stopTest();
         } catch (exception e) {
            System.assert(false);
        } // 
        
        
           
    }
  

  static testMethod void testInsertGovernorLimits(){
    
    Account a = new Account();
    a.Name = 'Test';
    a.CT_ZBM_Acc__c = '005i0000000xPhWAAU';
    a.MR_ZBM_Acc__c = '005i0000000xPhWAAU';
    a.UL_ZBM_Acc__c = '005i0000000xPhWAAU';
    a.UL_ZBM_Acc_Cardiology__c = '005i0000000xPhWAAU';
    a.XR_VL_ZBM_Acc__c = '005i0000000xPhWAAU';  
    a.Territory_Name_TAMS__c = 'Bedford Bob US.CE.2650100.TR-105';      
     
    insert a;
    
    list<Opportunity> Opplist = new list<Opportunity>();
    
    for(Integer i=0; i<200;i++){
        Opportunity o = new Opportunity();
        o.Name = 'Test' + i;
        o.AccountId = a.id;
        o.Modality_TAMS__c = 'XR';
        o.Expected_Bill_Date_TAMS__c = Date.today() + 2;
        o.CloseDate =  Date.today()+1;
        o.StageName = 'Milestone 3: Negotiations';
        o.LeadSource = 'Cold Call';
        o.Incumbent_TAMS__c = 'GE';
        o.Competitor_Lost_to_TAMS__c = 'GE';
        o.Is_this_Product_Funded_TAMS__c = 'Yes';
        
        Opplist.add(o);              
        
    }
    insert Opplist;
    
    Product2 product            = createProduct('Test Product','UL','AQUILION PRIME');
    PriceBook2 pb               = createPriceBook('UL Price Book','UL');
    PriceBookEntry pbe          = createPriceBookEntry(product.Id,pb.Id);
    OpportunityLineitem oppLine = createOpportunityLine(Opplist[0].Id,pbe.Id);      
    
  }
  
  //HK
  private static Product2 createProduct(String productName, String modality, String productSubFamily){
    Product2 prd = new Product2();
    prd.name = productName;
    prd.isActive = true;
    prd.Family = 'CT';
    prd.Product_Sub_Family__c = productSubFamily; //'AQUILION PRIME';
    insert prd;
    return prd;
  }

  private static PriceBook2 createPriceBook(String pbName, String modality){
    PriceBook2 pb = new PriceBook2();
    pb.id = Test.getStandardPricebookId();
    pb.isActive = true;
    pb.Modality__c = modality;
    update pb;
    return pb;
  }

  private static PriceBookEntry createPriceBookEntry(Id productId,Id PriceBookId){
    PriceBookEntry pbe = new PriceBookEntry();
    pbe.PriceBook2Id = PriceBookId;
    pbe.Product2Id = productId;
    pbe.UnitPrice = 0;
    pbe.UseStandardPrice = false;
    pbe.isActive = true;
    insert pbe;
    return pbe;
  }  
  
   private static OpportunityLineItem createOpportunityLine(Id oppId, Id priceBookId) {
       OpportunityLineItem oppLine = new OpportunityLineitem();
       oppLine.Quantity = 1;
       oppLine.unitPrice = 100;
       oppLine.OpportunityId = oppId;
       oppLine.PricebookEntryId=priceBookId;     
       insert oppLine;
       return oppLine;
   }    
 
}