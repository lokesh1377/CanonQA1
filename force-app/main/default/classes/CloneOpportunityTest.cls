@isTest
public class CloneOpportunityTest {
	@isTest
	public static void testCloneOpp(){
		Opportunity opp = createOpportunity();
		Product2 prd = createProduct('TEST','MR');
		PriceBook2 pb = createPriceBook('TEST','MR');
		PriceBookEntry pbe = createPriceBookEntry(prd.Id,pb.Id);
		OpportunityLineitem oppLine = createOpportunityLine(opp.Id,pbe.Id);	
		Test.startTest();
		String resp = CloneOpportunity.CloneOpp(opp.Id);
		Test.stopTest();
		System.debug('resp:'+resp);
		System.assert( !resp.startsWith('Error') ,'Error creating Cloned Opportunity');
		if(!resp.startsWith('Error')){
			Opportunity newOpp = [SELECT ID, isCloned__c FROM Opportunity where id = :resp];
			OpportunityLineitem newOppLine = [SELECT pricebookentryid, product2id FROM 
												OpportunityLineitem WHERE OpportunityId = :resp LIMIT 1];
			System.assert(newOpp.IsCloned__c,'IsCloned checkbox not set to True');
			System.assert(newOppLine.product2id == prd.Id,'Product is not cloned. Prd.Id'+prd.Id +' and Cloned Opportunity Line Product Id:'+newOppLine.product2id);
		}
	}

	private static Opportunity createOpportunity(){
        Opportunity op = new Opportunity();
        op.Name='testOpName';
        op.Expected_Bill_Date_TAMS__c     = Date.today() + 2;
        op.CloseDate                      =  Date.today()+1;
        op.StageName                      = 'Closed/Lost';
        op.Lost_Cancelled_Reason_TAMS__c  = 'Functionality/Insufficient Technology';
        op.Competitor_Lost_to_TAMS__c     = 'GE';
        op.LeadSource                     = 'Cold Call';
        op.Incumbent_TAMS__c              = 'GE';
        op.Competitor_Lost_to_TAMS__c     = 'GE';
        op.Is_this_Product_Funded_TAMS__c = 'Yes';
        op.Additional_Comments_TAMS__c    = 'Test Comments';
        op.Actual_Book_Date_TAMS__c       = Date.today();
        insert op;
        return op;		
	}

	private static Product2 createProduct(String productName, String modality){
		Product2 prd = new Product2();
		prd.name = productName;
		prd.isActive = true;
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