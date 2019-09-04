public class OpportunityLineItemTriggerHandler {
	private static Set<ID> opportunityIDs = new Set<ID>();
	private static List<Opportunity> opportunities;
	private static Set<ID> productIDs = new Set<ID>();
	private static List<Product2> Products = new List<Product2>();
	private static List<TAMS_Marketing_Materials__c> marketingMaterials = new List<TAMS_Marketing_Materials__c>();
	private static Set<String> modalities = new Set<String>();
	private static Set<String> productSubFamilies = new Set<String>();
	private static final String MARKETING_MATERIAL_ROLE = 'General-Oppty';
	public static void updateMarketingMaterial(List<OpportunityLineItem> oppLines){
		System.debug('START:updateMarketingMaterial');
		getOpportunities(oppLines);
		//Get Product IDs from Opportunity Lines
		for(OpportunityLineItem oppLine : oppLines){
			productIDs.add(oppLine.Product2Id);
		}
		System.debug('productIDs size:'+productIDs.size());
		if(productIDs.size() == 0){
			return;
		}

		//Get Products and their Product Sub Family
		Products = [SELECT Name,
							id, 
							Family, 
							Product_Sub_Family__c
					FROM Product2
					WHERE ID IN :productIDs];

		System.debug('Products size:'+Products.size());
		if(Products.size() == 0){
			return;
		}
		System.debug('Products[0].name:'+Products[0].name);
		System.debug('Products[0].Family:'+Products[0].Family);
		System.debug('Products[0].Product_Sub_Family__c:'+Products[0].Product_Sub_Family__c);
		for(Product2 product : Products){
			modalities.add(product.Family);
			productSubFamilies.add(product.Product_Sub_Family__c);
		}			

		System.debug('modalities size:'+modalities.size());
		if(modalities.size() == 0){
			return;
		}
		List<String> modalitiesList = new List<String>();
		modalitiesList.addAll(modalities);
		System.debug('modalities[0]:'+modalitiesList[0]);

		System.debug('productSubFamilies size:'+productSubFamilies.size());
		if(productSubFamilies.size() == 0){
			return;
		}
		List<String> productSubFamiliesList = new List<String>();
		productSubFamiliesList.addAll(productSubFamilies);
		System.debug('productSubFamilies[0]:'+productSubFamiliesList[0]);
		//Get Marketing Materials based on Modality/Product Sub Family
		
		marketingMaterials = [SELECT Name,
									 ID,
									 Modality__c, 
									 Product_Sub_Family__c
							  FROM TAMS_Marketing_Materials__c
							  WHERE Modality__c IN :modalities 
							  AND Product_Sub_Family__c IN :productSubFamilies
							  AND Role_Target__c = :MARKETING_MATERIAL_ROLE];			

		System.debug('marketingMaterials size:'+marketingMaterials.size());
		if(marketingMaterials.size() == 0){
			return;
		}

		System.debug('marketingMaterials[0].name:'+marketingMaterials[0].name);

		for(TAMS_Marketing_Materials__c marketingMaterial: marketingMaterials){
			Boolean marketingMaterialAssignedFlag = false;
			System.debug('marketingMaterial.ID:'+marketingMaterial.ID);
			for(Product2 product: Products){
				System.debug('product.ID:'+product.ID);
				System.debug('product.Family:'+product.Family);
				System.debug('product.Product_Sub_Family__c:'+product.Product_Sub_Family__c);
				if(product.Family == marketingMaterial.Modality__c &&
				   product.Product_Sub_Family__c == marketingMaterial.Product_Sub_Family__c){
					for(OpportunityLineItem oppLine : oppLines){
						System.debug('oppLine.Product2Id:'+oppLine.Product2Id);
						System.debug('oppLine.OpportunityId:'+oppLine.OpportunityId);
						if(oppLine.Product2Id == product.Id){
							for(Opportunity opp: opportunities){
								System.debug('opp.Id:'+opp.Id);
								if( opp.Id == oppLine.OpportunityId){
									System.debug('Updating Opp ID:'+opp.ID+' with marketingMaterial ID:'+marketingMaterial.Id);
									opp.Marketing_Materials_Name__c = marketingMaterial.Id;
									marketingMaterialAssignedFlag = true;
									break;
								}
							}
							if(marketingMaterialAssignedFlag){
								break;
							}
						}
					}
					if(marketingMaterialAssignedFlag){
						break;
					}	
				}
			}
		}	

		System.debug('opportunities size:'+opportunities.size());
		if(opportunities.size() == 0){
			return;
		}else{
			update opportunities;
		}


		System.debug('END:updateMarketingMaterial');
	}

	public static void removeMarketingMaterial(List<OpportunityLineItem> oppLines){
		System.debug('START:removeMarketingMaterial');
		System.debug('oppLines size:'+oppLines.size());
		getOpportunities(oppLines);
		for(Opportunity opp: opportunities){
			opp.Marketing_Materials_Name__c = null;
		}
		//Reset Opportunities in Case of Deletion only
		if( opportunities.size() > 0){
			update opportunities;
		}
		System.debug('END:removeMarketingMaterial');
	}	

	private static void getOpportunities(List<OpportunityLineItem> oppLines){
		System.debug('START:getOpportunities');
		System.debug('oppLines size:'+oppLines.size());		
		if(opportunities == null){
			opportunities = new List<Opportunity>();
		}

		//Get all Opportunity IDs First
		for( OpportunityLineItem oppLine : oppLines){
			opportunityIDs.add(oppLine.OpportunityId);
		}

		System.debug('opportunityIDs size:'+opportunityIDs.size());
		//Get All opportunity Records

		if( opportunityIDs.size() == 0){
			return;
		}

		opportunities = [SELECT ID, NAME 
						FROM Opportunity
						WHERE ID IN :opportunityIDs ];

		System.debug('opportunities size:'+opportunities.size());	
		
		if( opportunities.size() == 0){
			return;
		}					
	}


}