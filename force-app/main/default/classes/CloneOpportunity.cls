global class CloneOpportunity {
	@AuraEnabled
	webservice static String CloneOpp(Id origOpportunityId){
		System.debug('START:CloneOpp');
		System.debug('origOpportunityId:'+origOpportunityId);
		Opportunity clonedOpportunity;
		try{
			String qry = 'SELECT '; 
			String fields = '';
			// Include here the Object that you want to get all the fields from
			Schema.Describesobjectresult d = Opportunity.sObjectType.getDescribe();
			Map<String, Schema.SObjectField> fieldMap = d.fields.getMap();
			// Iterate over the fields
			for (String field : fieldMap.keySet()) {
				Boolean fieldExcluded = false;
				List<Schema.FieldSetMember> fieldsToReset = SObjectType.Opportunity.FieldSets.ResetFieldsForCloneAction.getFields();
				for(Schema.FieldSetMember resetField : fieldsToReset){
					if(field == resetField.getFieldPath() ){
						fieldExcluded = true;
						break;
					}
				}
				if (fieldExcluded){
					System.debug('Field excluded is:'+field);
					continue; //Skip this field
				}

			  	if (fields.length() > 0) {
			    	// If fields already has letters on it, it means we are adding a new value so we need to add a comma
			    	fields += ', '; 
			  	}
			  	fields += field; // Add the field to the list
			}

			qry += fields;
			System.debug('qry with Fields:+'+qry);
			qry += ' FROM Opportunity WHERE ID='+'\''+origOpportunityId+'\'';		
			System.debug('qry FINAL:+'+qry);
			Opportunity existingOpportunity = (Opportunity)Database.Query(qry);
			clonedOpportunity = existingOpportunity.clone(false,true);
			clonedOpportunity.isCloned__c = true;
			if(ClonedOpportunity.CloseDate <= Date.today()){
				ClonedOpportunity.CloseDate = Date.today().addDays(1);
				ClonedOpportunity.Expected_Bill_Date_TAMS__c = Date.today().addDays(10);
			}

			insert clonedOpportunity;

			//START: Added on 08/09/2017 by Prabhjeet Singh to copy Opp Lines with Opportunity
			List<OpportunityLineItem> clonedOppLines = new List<OpportunityLineItem>();
			for(OpportunityLineItem existingOppLine: [SELECT pricebookentryid, product2id 
													  FROM OpportunityLineItem 
													  WHERE OpportunityID= :origOpportunityId
													   ] ) {
				OpportunityLineItem clonedOppLine = existingOppLine.clone(false,true);
				clonedOppLine.OpportunityId = clonedOpportunity.Id;
				clonedOppLines.add(clonedOppLine);
			}

			insert clonedOppLines;
			//END: Added on 08/09/2017 by Prabhjeet Singh to copy Opp Lines with Opportunity
			return clonedOpportunity.Id;
		}Catch(Exception e){
			delete clonedOpportunity;
			String errMsg = e.getMessage();
			if(errMsg.contains('pricebook entry is inactive')){
				return 'Error: You cannot clone an opportunity with an inactive product.';
			}
			else{	
            	return 'Error: '+e.getMessage();
            }
        }

	} 
}