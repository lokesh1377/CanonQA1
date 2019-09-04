@isTest
private class OpportunityLineItemTriggerHandlerTest
{
	@isTest
	static void testAttachMarketingMaterial()
	{
		Account acc = createAccount('Test Account');
        Lead lead = createLead(acc.ID,'Test Lead','CT','2-Warm','Open');
        Product2 product = createProduct('Test Product','CT','AQUILION PRIME');
        PriceBook2 pb = createPriceBook('CT Price Book','CT');
        PriceBookEntry pbe = createPriceBookEntry(product.Id,pb.Id);
        lead.Recommended_Product__c = product.Id;
        update lead;
        TAMS_Marketing_Materials__c marketingMaterial = createMarketingMaterial('CT','AQUILION PRIME');
        Test.startTest();
        Tams360OppFromLeadExt.createOpportunity(lead.ID);
        Test.stopTest();
        Lead leadPostTest = [SELECT status,
        							convertedOpportunityId 
        					 From Lead 
        					 WHERE id=:lead.ID];
        System.assert(leadPostTest.status == 'Closed - Converted' ,'Lead not coverted into Opportunity');
        System.assert(leadPostTest.convertedOpportunityId != null ,'Converted Opportunity id is NULL');
        if(leadPostTest.convertedOpportunityId != null){
        	Opportunity opp = [SELECT AccountId,
        							  Marketing_Materials_Name__c 
        						From Opportunity 
        						WHERE Id = :leadPostTest.convertedOpportunityId];
        	System.assert(opp.AccountId == acc.ID,'Account ID is different on the Opportunity');
        	System.assert(opp.Marketing_Materials_Name__c == marketingMaterial.ID,'Marketing Material not attached to Opportunity');
        	List<OpportunityLineItem> oppLines = [SELECT PriceBookEntryId 
        										  From OpportunityLineItem
        										   WHERE OpportunityId = :leadPostTest.convertedOpportunityId];
        	System.debug('oppLines.size:'+oppLines.size());									
        	System.assert( oppLines.size() == 1 , 'No Opportunity line added');		
        	if( oppLines.size() == 1){
        		System.assert( oppLines[0].PriceBookEntryId == pbe.Id, 'Incorrect Product Added');								
        	}
        }
	}

	@isTest
	static void testRemoveMarketingMaterial()
	{
		Account acc = createAccount('Test Account');
        Lead lead = createLead(acc.ID,'Test Lead','CT','2-Warm','Open');
        Product2 product = createProduct('Test Product','CT','AQUILION PRIME');
        PriceBook2 pb = createPriceBook('CT Price Book','CT');
        PriceBookEntry pbe = createPriceBookEntry(product.Id,pb.Id);
        lead.Recommended_Product__c = product.Id;
        update lead;
        TAMS_Marketing_Materials__c marketingMaterial = createMarketingMaterial('CT','AQUILION PRIME');
        Tams360OppFromLeadExt.createOpportunity(lead.ID);
        
        Lead leadConverted = [SELECT status,convertedOpportunityId From Lead WHERE id=:lead.ID];										

        if(leadConverted.convertedOpportunityId != null){
        	List<OpportunityLineItem> oppLines = [SELECT Id,
        												PriceBookEntryId 
        										   FROM OpportunityLineItem
        										   WHERE OpportunityId = :leadConverted.convertedOpportunityId];

        	System.debug('oppLines.size:'+oppLines.size());									

        	if( oppLines.size() == 1){
        		Test.startTest();
        		delete oppLines;
        		Test.stopTest();
        		Opportunity opp1 = [SELECT AccountId,
        								   Marketing_Materials_Name__c 
        							FROM Opportunity 
        							WHERE Id = :leadConverted.convertedOpportunityId];
        		System.assert( opp1.Marketing_Materials_Name__c == Null, 'Marketing Material not removed.');								
        	}
        }        

        

	}
	private static Account createAccount(String acctName){
		Account acc = new Account(name=acctName);
		acc.Territory_Name_TAMS__c = 'US.GL.2660100.TR-101';
		insert acc;
		return acc;		
	}

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

	private static TAMS_Marketing_Materials__c createMarketingMaterial(String modality,String productSubFamily ){
		TAMS_Marketing_Materials__c mm = new TAMS_Marketing_Materials__c();
		mm.Modality__c = modality;
		mm.Product_Sub_Family__c = productSubFamily;
		mm.Role_Target__c = 'General-Oppty';
		insert mm;
		return mm;
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

	private static Lead createLead(ID accountId, String leadName, String modality, String rank,String status ){
		Lead lead = new Lead();
        lead.FirstName = leadName;
        lead.LastName = leadName;
		lead.Primary_Modality_TAMS__c = modality;
        lead.LeadSource = '360 Sales Assist';
        lead.Existing_Account__c = accountId;
        lead.email = 'test@test.com';
        lead.Phone  = '111-111-1234';
        lead.PostalCode = '11111';
        lead.company = 'TAMS';
        lead.status = status;
        lead.recordTypeId = getRecordTypeId();
        lead.Rank_PIcklist__c = rank;
        insert lead;
        return lead;
	}

	private static ID getRecordTypeId(){
		List<RecordType> recordTypes = [
                                            SELECT
                                                ID,Name
                                            FROM
                                                RecordType
                                            WHERE sObjectType= 'Lead'
                                            AND name = '360 Sales Assist'
                                            LIMIT 1
                                            ];		
        if(recordTypes.size() == 1){
        	return recordTypes[0].ID;
        }                                    

        return null;
	}
}