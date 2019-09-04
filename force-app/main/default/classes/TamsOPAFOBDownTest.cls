@isTest
public class TamsOPAFOBDownTest {

public static testMethod void testOPAInsert() {

        Account acct = createAccount();
        Opportunity opp = createOpportunity();                
        FOB_Down__c fobDown = createFOBDown('TEST');        
        TAMS_Quotes__c qte = createQuote('TEST',acct.id,opp.id, fobDown.Id);
        TAMS_Special_Pricing_Request__c spr = createSPR(acct.id, qte.id);
        SPR_Quote__c sprQte = createSPRQuote(acct.id, qte.id, spr.id);

        Test.startTest();
        TAMS_Order_Process_Approval__c opa = createOPA(acct.id,opp.id,qte.id);
		Test.stopTest();
		TAMS_Order_Process_Approval__c opa1 = [SELECT FOB_Down__c FROM TAMS_Order_Process_Approval__c WHERE id = :opa.Id LIMIT 1];
		System.debug('opa1.FOB_Down__c:'+opa1.FOB_Down__c);
		System.debug('qte.FOB_Down__c:'+qte.FOB_Down__c);
		System.assert(opa1.FOB_Down__c == qte.FOB_Down__c,'OPA FOB Down should be same of Quote FOB Down');
 	}

public static testMethod void testOPAUpdate() {

        Account acct = createAccount();
        Opportunity opp = createOpportunity();                
        FOB_Down__c fobDown1 = createFOBDown('TEST1');        
        FOB_Down__c fobDown2 = createFOBDown('TEST2');        
        TAMS_Quotes__c qte1 = createQuote('TEST1',acct.id,opp.id, fobDown1.Id);
        TAMS_Quotes__c qte2 = createQuote('TEST2',acct.id,opp.id, fobDown2.Id);
        TAMS_Special_Pricing_Request__c spr = createSPR(acct.id, qte1.id);
        SPR_Quote__c sprQte = createSPRQuote(acct.id, qte1.id, spr.id);
        TAMS_Order_Process_Approval__c opa = createOPA(acct.id,opp.id,qte1.id);
        Test.startTest();
        opa.TAMS_Quote__c = qte2.id;
        update opa;
		Test.stopTest();
		TAMS_Order_Process_Approval__c opa1 = [SELECT FOB_Down__c FROM TAMS_Order_Process_Approval__c WHERE id = :opa.Id LIMIT 1];
		System.debug('opa1.FOB_Down__c:'+opa1.FOB_Down__c);
		System.debug('qte2.FOB_Down__c:'+qte2.FOB_Down__c);
		System.assert(opa1.FOB_Down__c == qte2.FOB_Down__c,'OPA FOB Down should be updated based on Updated Quote');
 	}

public static testMethod void testSPQQuoteUpdate() {

        Account acct = createAccount();
        Opportunity opp = createOpportunity();                
        FOB_Down__c fobDown1 = createFOBDown('TEST1');        
        FOB_Down__c fobDown2 = createFOBDown('TEST2');        
        TAMS_Quotes__c qte1 = createQuote('TEST1',acct.id,opp.id, fobDown1.Id);
        TAMS_Quotes__c qte2 = createQuote('TEST2',acct.id,opp.id, fobDown2.Id);
        TAMS_Special_Pricing_Request__c spr = createSPR(acct.id, qte1.id);
        SPR_Quote__c sprQte = createSPRQuote(acct.id, qte1.id, spr.id);
        TAMS_Order_Process_Approval__c opa = createOPA(acct.id,opp.id,qte1.id);
        Test.startTest();
        sprQte.TAMS_Quote_SPR__c = qte2.id;
        update sprQte;
		Test.stopTest();
		SPR_Quote__c sprQte1 = [SELECT FOB_Down__c FROM SPR_Quote__c WHERE id = :sprQte.Id LIMIT 1];
		System.debug('sprQte1.FOB_Down__c:'+sprQte1.FOB_Down__c);
		System.debug('qte2.FOB_Down__c:'+qte2.FOB_Down__c);
		System.assert(sprQte1.FOB_Down__c == qte2.FOB_Down__c,'SPR Quote FOB Down should be updated based on Updated Quote');
 	}

public static testMethod void testQuoteFOBDownUpdate() {

        Account acct = createAccount();
        Opportunity opp = createOpportunity();                
        FOB_Down__c fobDown1 = createFOBDown('TEST1');        
        FOB_Down__c fobDown2 = createFOBDown('TEST2');        
        TAMS_Quotes__c qte = createQuote('TEST1',acct.id,opp.id, fobDown1.Id);
        TAMS_Special_Pricing_Request__c spr = createSPR(acct.id, qte.id);
        SPR_Quote__c sprQte = createSPRQuote(acct.id, qte.id, spr.id);
        TAMS_Order_Process_Approval__c opa = createOPA(acct.id,opp.id,qte.id);
        Test.startTest();
        qte.FOB_Down__c = fobDown2.id;
        update qte;
		Test.stopTest();
		SPR_Quote__c sprQte2 = [SELECT FOB_Down__c FROM SPR_Quote__c WHERE id = :sprQte.Id LIMIT 1];
		System.debug('sprQte.FOB_Down__c:'+sprQte.FOB_Down__c);
		System.debug('sprQte2.FOB_Down__c:'+sprQte2.FOB_Down__c);
		System.debug('qte.FOB_Down__c:'+qte.FOB_Down__c);
		System.assert(sprQte2.FOB_Down__c == qte.FOB_Down__c,'SPR FOB Down should be updated to updated Quote FOB Down');
 	}

   private static Account createAccount(){
        Account a = new Account();
        a.Name = 'TestAccount';
        a.Territory_Name_TAMS__c = 'US.GL.2660100.TR-101';
        insert a;
        return a;
    }
    
    private static Opportunity createOpportunity(){        
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

    private static TAMS_Quotes__c createQuote(String quoteName, Id accountId, Id opportunityId, id fobDownId ){  
        TAMS_Quotes__c quote      = new TAMS_Quotes__c();
        quote.Opportunity_Name__c = opportunityId;
        quote.Customer_Name__c    = accountId;
        quote.Modality__c         = 'CT';
        quote.PBOM__c             = 'AQ64/VELOCT/UPG.000';
        quote.Quote_Name__c       = quoteName;
        quote.Quote_Version__c    = '1';
        quote.Status__c           = 'Quote Generated by HQ';
        quote.Amount__c           = 4000;
        quote.FOB_Down__c         = fobDownId;
        insert quote;
        return quote;        
    }    
    
    private static TAMS_Special_Pricing_Request__c createSPR(Id accountId, Id quoteId ){  
        TAMS_Special_Pricing_Request__c spr      = new TAMS_Special_Pricing_Request__c();
        spr.Account_SPR__c                      = accountId;
        spr.Delivery_Date_SPR__c                = Date.today() + 4;
        spr.Requested_Response_Date_SPR__c      = Date.today() + 4;
        spr.Blended_Discount__c                 = 50;
        spr.Strategy_Justification__c           = 'PS Test';
        spr.Vital_Installed_Planned__c          = 'PS Knows';
        spr.Service_Discount_and_Offering__c    = 'PS Offered';
        spr.Service_Discount_SPR__c             = 50;
        spr.Finance_Method_and_Special_Terms__c = 'PS Terms';    
        spr.Other_Comments__c                   = 'PS Comments';
        spr.TAMS_Quote_SPR__c                   = quoteId;
        spr.Status__c                           = 'Open'; 
        insert spr;
        return spr;        
    }    
        
    private static SPR_Quote__c createSPRQuote(Id accountId, Id quoteId, Id sprId ){  
        SPR_Quote__c sq               = new SPR_Quote__c();
        sq.Account_SPR__c            = accountId;
        sq.TAMS_SPR__c               = sprId;
        sq.TAMS_Quote_SPR__c         = quoteId;
        sq.Approved_Discount__c      = 50;
        sq.APPROVED_Selling_Price__c = 100000;
        sq.Primary__c                = true;
        sq.SPR_Comments__c           = 'PS Test SPR';
        insert sq;
        return sq;            
    }

    private static TAMS_Order_Process_Approval__c createOPA(Id accountId, Id opportunityId, Id quoteId){
        TAMS_Order_Process_Approval__c topa = new TAMS_Order_Process_Approval__c();
        topa.Account__c                   = accountId;
        topa.Opportunity__c               = opportunityId;
        topa.TAMS_Quote__c                = quoteId;
        topa.Payment_Method__c            = 'PO Paying';
        topa.Total_Contract_Price__c      = 'Yes';
        topa.BOM__c                       = 'Yes';
        topa.Added_Purchasable_Options__c = 'Yes';
        topa.Handwritten_Notes__c         = 'Yes';
        topa.POP_Service_Contract__c      = 'Yes';
        topa.Trade_in_Included__c         = 'Yes';
        topa.Non_Standard_Terms_form__c   = 'Yes';
        topa.Down_Payment_Check__c        = 'Yes';
        topa.Multi_System_Deal__c         = 'Yes';
        topa.Handwritten_Notes1__c        = 'Test handwritten Notes';
        topa.If_Multi_System_list_opportunity_SIDs__c = 'Yes';
        insert topa;    	
        return topa;
    }

    private static FOB_Down__c createFOBDown(String tmsc_Quote_name){
    	FOB_Down__c fobDown = new FOB_Down__c();
    	fobDown.Discount_Amount_per_Unit__c = 25000;
    	fobDown.Modality__c = 'CT';
    	fobDown.Product_Part_Number__c = 'AQUILION';
    	fobDown.TMSC_Quote__c = 'TMSC CT-GI-02321'+tmsc_Quote_name;
    	fobDown.Status__c = 'Open';
    	fobDown.Agreement_Summary__c = 'Test';
    	insert fobDown;
    	return fobDown;
    }
        
}