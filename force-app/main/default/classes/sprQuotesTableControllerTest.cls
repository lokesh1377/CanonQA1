/*********************************************************
Author : Hemant Kumar       
Purpose: Test class for sprQuotesTableController
1.0 - Hemant Kumar - 08/02/2017 - Created
2.0 - Hemant Kumar - 09/07/2017 - Updated to include the SPRApprovalEmailTrigger too...
2.1 - Hemant Kumar - 02/22/2019 - Added for MT Zone   
**********************************************************/

@isTest
public class sprQuotesTableControllerTest 
{    
    public static testMethod void testSprQuotesTableController() 
    {
        PageReference sprPageRef=Page.SprPage;
        Test.setCurrentPage(sprPageRef);
          
        Account a             = createAcc();
        Opportunity op1       = createOpp();                
        TAMS_Quotes__c qt1    = createQuote(a.id,op1.id,1);
        TAMS_Quotes__c qt2    = createQuote(a.id,op1.id,2);        
        TAMS_Special_Pricing_Request__c spr1 = createSPR(a.id, qt1.id);
        TAMS_Special_Pricing_Request__c spr2 = createSPR(a.id, qt2.id);
        SPR_Quote__c sq1      = createSQ(a.id, qt1.id, spr1.id);
        SPR_Quote__c sq2      = createSQ(a.id, qt2.id, spr2.id);
               
        Test.startTest();
        spr1.Status__c                = 'Approved'; 
        sprQuotesTableController aqtc = new sprQuotesTableController();
        aqtc.thisSprId                = spr1.id;
        aqtc.thisEmailType            = true;
        aqtc.getSprQuotes();
        Test.stopTest();
    }    
    
    public static testMethod void testSprApprovalZVP1Trigger() 
    {    

        Account a                            = createAcc();
        Opportunity op1                      = createOpp();                
        TAMS_Quotes__c qt1                   = createQuote(a.id,op1.id,1);
        TAMS_Special_Pricing_Request__c spr1 = createSPR(a.id, qt1.id);
        SPR_Quote__c sq1                     = createSQ(a.id, qt1.id, spr1.id);
        Test.startTest();
        spr1.Status__c                       = 'Approved'; 
        spr1.Executive_Approved__c           = true;
        spr1.Executive_Approved_Date__c      = Date.today();
        spr1.ZVP_CE_Approved__c              = true;
        spr1.ZVP_CW_Approved__c              = true;
        spr1.ZVP_GS_Approved__c              = true;
        spr1.ZVP_MA_Approved__c              = true;
        spr1.SPR_ZVP_MT_Approved__c          = true;
        update spr1; 
        Test.stopTest();    
    }

    public static testMethod void testSprApprovalZVP2Trigger() 
    {    

        Account a                            = createAcc();
        Opportunity op1                      = createOpp();                
        TAMS_Quotes__c qt1                   = createQuote(a.id,op1.id,1);
        TAMS_Special_Pricing_Request__c spr1 = createSPR(a.id, qt1.id);
        SPR_Quote__c sq1                     = createSQ(a.id, qt1.id, spr1.id);
        Test.startTest();
        spr1.Status__c                       = 'Approved'; 
        spr1.Executive_Approved__c           = true;
        spr1.Executive_Approved_Date__c      = Date.today();
        spr1.ZVP_MS_Approved__c              = true;
        spr1.ZVP_NW_Approved__c              = true; 
        spr1.ZVP_SW_Approved__c              = true; 
        spr1.ZVP_WE_Approved__c              = true; 
        spr1.SPR_ZVP_MT_Approved__c          = true;        
        update spr1; 
        Test.stopTest();    
    }

    public static testMethod void testSprApprovalNSDTrigger() 
    {    

        Account a                            = createAcc();
        Opportunity op1                      = createOpp();                
        TAMS_Quotes__c qt1                   = createQuote(a.id,op1.id,1);
        TAMS_Special_Pricing_Request__c spr1 = createSPR(a.id, qt1.id);
        SPR_Quote__c sq1                     = createSQ(a.id, qt1.id, spr1.id);
        Test.startTest();
        spr1.Status__c                       = 'Approved'; 
        spr1.Executive_Approved__c           = true;
        spr1.Executive_Approved_Date__c      = Date.today();
        spr1.NSD_CT_Approved__c              = true; 
        spr1.NSD_MR_Approved__c              = true; 
        spr1.NSD_UL_Approved__c              = true; 
        spr1.NSD_XRVL_Approved__c            = true;
        spr1.SPR_ZVP_MT_Approved__c          = true;        
        update spr1; 
        Test.stopTest();    
    }
    
    public static testMethod void testSprRejectionZVP1Trigger() 
    {    

        Account a                            = createAcc();
        Opportunity op1                      = createOpp();                
        TAMS_Quotes__c qt1                   = createQuote(a.id,op1.id,1);
        TAMS_Special_Pricing_Request__c spr1 = createSPR(a.id, qt1.id);
        SPR_Quote__c sq1                     = createSQ(a.id, qt1.id, spr1.id);
        Test.startTest();
        spr1.Status__c                       = 'Rejected'; 
        spr1.Executive_Rejected__c           = true;
        spr1.Executive_Rejected_Date__c      = Date.today();
        spr1.ZVP_CE_Approved__c              = true;
        spr1.ZVP_CW_Approved__c              = true;
        spr1.ZVP_GS_Approved__c              = true;
        spr1.ZVP_MA_Approved__c              = true;
        spr1.SPR_ZVP_MT_Approved__c          = true;
        update spr1; 
        Test.stopTest();    
    }

    public static testMethod void testSprRejectionZVP2Trigger() 
    {    

        Account a                            = createAcc();
        Opportunity op1                      = createOpp();                
        TAMS_Quotes__c qt1                   = createQuote(a.id,op1.id,1);
        TAMS_Special_Pricing_Request__c spr1 = createSPR(a.id, qt1.id);
        SPR_Quote__c sq1                     = createSQ(a.id, qt1.id, spr1.id);
        Test.startTest();
        spr1.Status__c                       = 'Rejected'; 
        spr1.Executive_Rejected__c           = true;
        spr1.Executive_Rejected_Date__c      = Date.today();
        spr1.ZVP_MS_Approved__c              = true;        
        spr1.ZVP_NW_Approved__c              = true; 
        spr1.ZVP_SW_Approved__c              = true; 
        spr1.ZVP_WE_Approved__c              = true;
        spr1.SPR_ZVP_MT_Approved__c          = true;         
        update spr1; 
        Test.stopTest();    
    }

    public static testMethod void testSprRejectionNSDTrigger() 
    {    

        Account a                            = createAcc();
        Opportunity op1                      = createOpp();                
        TAMS_Quotes__c qt1                   = createQuote(a.id,op1.id,1);
        TAMS_Special_Pricing_Request__c spr1 = createSPR(a.id, qt1.id);
        SPR_Quote__c sq1                     = createSQ(a.id, qt1.id, spr1.id);
        Test.startTest();
        spr1.Status__c                       = 'Rejected'; 
        spr1.Executive_Rejected__c           = true;
        spr1.Executive_Rejected_Date__c      = Date.today();
        spr1.NSD_CT_Approved__c              = true; 
        spr1.NSD_MR_Approved__c              = true; 
        spr1.NSD_UL_Approved__c              = true; 
        spr1.NSD_XRVL_Approved__c            = true; 
        spr1.SPR_ZVP_MT_Approved__c          = true;       
        update spr1; 
        Test.stopTest();    
    }

  
    private static Account createAcc(){
        Account a = new Account();
        a.Name = 'TestAccount';
        a.Territory_Name_TAMS__c = 'US.GL.2660100.TR-101';
        insert a;
        return a;
    }
    
    private static Opportunity createOpp(){        
        Opportunity op1                   = new Opportunity();
        op1.Name                          ='testOpName1';
        op1.Expected_Bill_Date_TAMS__c    = Date.today() + 2;
        op1.CloseDate                     = Date.today()+1;
        op1.StageName                     = 'Closed/Lost';
        op1.Lost_Cancelled_Reason_TAMS__c = 'Functionality/Insufficient Technology';
        op1.Competitor_Lost_to_TAMS__c    = 'GE';
        op1.LeadSource                    = 'Cold Call';
        op1.Incumbent_TAMS__c             = 'GE';
        op1.Competitor_Lost_to_TAMS__c    = 'GE';
        op1.Is_this_Product_Funded_TAMS__c= 'Yes';
        op1.Additional_Comments_TAMS__c   = 'Test Comments';
        op1.Actual_Book_Date_TAMS__c      = Date.today();
        insert op1;                 
        return op1;
    }

    private static TAMS_Quotes__c createQuote(Id AccId, Id OppId, Integer I ){  
        TAMS_Quotes__c quote      = new TAMS_Quotes__c();
        if(I == 1) {            
            quote.Opportunity_Name__c = OppId;
            quote.Customer_Name__c    = AccId;
            quote.Modality__c         = 'CT';
            quote.PBOM__c             = 'AQ64/VELOCT/UPG.000';
            quote.Quote_Name__c       = 'TriggerTestQuote1';
            quote.Quote_Version__c    = '1';
            quote.Status__c           = 'Quote Generated by HQ';
            quote.Amount__c           = 4000;
            insert quote;
        }
        else if(I == 2) {
            quote.Opportunity_Name__c = OppId;
            quote.Customer_Name__c    = AccId;
            quote.Modality__c         = 'MR';
            quote.PBOM__c             = 'TITAN/X.000';
            quote.Quote_Name__c       = 'TriggerTestQuote2';
            quote.Quote_Version__c    = '1';
            quote.Status__c           = 'Quote Generated by HQ';
            quote.Amount__c           = 8000;
            insert quote;           
        }        
        return quote;        
    }    
    
    private static TAMS_Special_Pricing_Request__c createSPR(Id AccId, Id QuoteId ){  
        TAMS_Special_Pricing_Request__c spr      = new TAMS_Special_Pricing_Request__c();
        spr.Account_SPR__c                      = AccId;
        spr.Delivery_Date_SPR__c                = Date.today() + 4;
        spr.Requested_Response_Date_SPR__c      = Date.today() + 4;
        spr.Blended_Discount__c                 = 50;
        spr.Strategy_Justification__c           = 'HK Test';
        spr.Vital_Installed_Planned__c          = 'HK Knows';
        spr.Service_Discount_and_Offering__c    = 'HK Offered';
        spr.Service_Discount_SPR__c             = 50;
        spr.Finance_Method_and_Special_Terms__c = 'HK Terms';    
        spr.Other_Comments__c                   ='HK Comments';
        spr.TAMS_Quote_SPR__c                   = QuoteId;
        spr.Status__c                           = 'Open'; 
        insert spr;
        return spr;        
    }    
        
    private static SPR_Quote__c createSQ(Id AccId, Id QuoteId, Id SprId ){  
        SPR_Quote__c sq               = new SPR_Quote__c();
        sq.Account_SPR__c            = AccId;
        sq.TAMS_SPR__c               = SprId;
        sq.TAMS_Quote_SPR__c         = QuoteId;
        sq.Approved_Discount__c      = 50;
        sq.APPROVED_Selling_Price__c = 100000;
        sq.Primary__c                = true;
        sq.SPR_Comments__c           = 'HK Test SPR';
        insert sq;
        return sq;            
    }
    
}