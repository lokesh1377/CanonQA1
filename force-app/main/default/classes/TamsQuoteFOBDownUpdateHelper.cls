public class TamsQuoteFOBDownUpdateHelper {
	public static void QuoteFOBDownUpdated(Map<ID,TAMS_Quotes__c> newQuotes,Map<ID,TAMS_Quotes__c> oldQuotes){
		System.debug('START:QuoteFOBDownUpdated');
		System.debug('newQuotes count:'+newQuotes.size());
		if(oldQuotes != null){
			System.debug('oldQuotes count:'+oldQuotes.size());
		}
		//Tams Quote = Key, FOB Down = Value
		Map<Id,Id> quotesFOBUpdated = new Map<Id,Id>();
		if(oldQuotes != null){
			for(TAMS_Quotes__c newQuote: newQuotes.values()){
				TAMS_Quotes__c oldQuote = oldQuotes.get(newQuote.Id);
				if( (oldQuote != null && oldQuote.FOB_Down__c != newQuote.FOB_Down__c) || oldQuote == null ){
					quotesFOBUpdated.put(newQuote.Id,newQuote.FOB_Down__c);
				}
			}
		}

		if(oldQuotes == null){
			for(TAMS_Quotes__c newQuote: newQuotes.values()){
				quotesFOBUpdated.put(newQuote.Id,newQuote.FOB_Down__c);
			}
		}
		
		System.debug('quotesFOBUpdated.size():'+quotesFOBUpdated.size());
		//Get All SPR Quotes attached with specific Quotes
		List<SPR_Quote__c> sprQuotes = [SELECT
										  id,
										  TAMS_Quote_SPR__c
										FROM
										  SPR_Quote__c
										WHERE TAMS_Quote_SPR__c IN :quotesFOBUpdated.keySet()
										];
		System.debug('sprQuotes size:'+sprQuotes.size());
		for(SPR_Quote__c sprQuote: sprQuotes){
			sprQuote.FOB_Down__c = quotesFOBUpdated.get(sprQuote.TAMS_Quote_SPR__c);
		}										

		if( sprQuotes.size() > 0 ){
			System.debug('Updating SPR Quotes');
			update sprQuotes;
		}

		//Get All OPA attached with specific Quotes
		List<TAMS_Order_Process_Approval__c> OPAs = [SELECT
										  				id,
										  				TAMS_Quote__c
													FROM
										  				TAMS_Order_Process_Approval__c
													WHERE TAMS_Quote__c IN :quotesFOBUpdated.keySet()
										];
		System.debug('OPAs size:'+OPAs.size());
		for(TAMS_Order_Process_Approval__c OPA: OPAs){
			OPA.FOB_Down__c = quotesFOBUpdated.get(OPA.TAMS_Quote__c);
		}										

		if( OPAs.size() > 0 ){
			System.debug('Updating OPAs');
			update OPAs;
		}		
	}

	public static void OPAUpdated(List<TAMS_Order_Process_Approval__c> newOPAs,List<TAMS_Order_Process_Approval__c> oldOPAs){
		System.debug('START:OPAUpdated');
		if(newOPAs != null){
			System.debug('newOPAs count:'+newOPAs.size());
		}
		if(oldOPAs != null){
			System.debug('oldOPAs count:'+oldOPAs.size());
		}
		//Quote ID = Key , Row Count = Value
		Map<Id,Integer> quoteChangedOPAs = new Map<Id,Integer>();
		Integer quoteChangedOPAsCount = 0;
		Integer rowCount = 0;
		if(oldOPAs != null){
			for(TAMS_Order_Process_Approval__c newOPA: newOPAs){
				TAMS_Order_Process_Approval__c oldOPA = oldOPAs[rowCount++];
				if( (oldOPA != null && oldOPA.TAMS_Quote__c != newOPA.TAMS_Quote__c) || oldOPA == null ){
					quoteChangedOPAs.put(newOPA.TAMS_Quote__c,quoteChangedOPAsCount++);
				}
			}
		}
		
		if(oldOPAs == null){
			for(TAMS_Order_Process_Approval__c newOPA: newOPAs){
				quoteChangedOPAs.put(newOPA.TAMS_Quote__c,quoteChangedOPAsCount++);
			}
		}
		
		System.debug('quoteChangedOPAs.size():'+quoteChangedOPAs.size());
		//Get All SPR Quotes attached with specific Quotes
		List<TAMS_Quotes__c> quotes = [SELECT
										  id,
										  FOB_Down__c
										FROM
										  TAMS_Quotes__c
										WHERE ID IN :quoteChangedOPAs.keySet()
										];
		System.debug('quotes size:'+quotes.size());
		for(TAMS_Quotes__c quote: quotes){
			newOPAs.get(quoteChangedOPAs.get(quote.id)).FOB_Down__c = quote.FOB_Down__c;
		}										

	}	

	public static void SPRQuoteUpdated(List<SPR_Quote__c> newSPRQuotes,List<SPR_Quote__c> oldSPRQuotes){
		System.debug('START:SPRQuoteUpdated');
		if(newSPRQuotes != null){
			System.debug('newSPRQuotes count:'+newSPRQuotes.size());
		}
		if(oldSPRQuotes != null){
			System.debug('oldSPRQuotes count:'+oldSPRQuotes.size());
		}
		//Quote ID = Key , Row Count = Value
		Integer quoteChangedOPAsCount = 0;
		Integer rowCount = 0;		
		Map<Id,Integer> quoteChangedSPRQuotes = new Map<Id,Integer>();
		if(oldSPRQuotes != null){
			for(SPR_Quote__c newSPRQuote: newSPRQuotes){
				SPR_Quote__c oldSPRQuote = oldSPRQuotes[rowCount++];
				if( (oldSPRQuote != null && oldSPRQuote.TAMS_Quote_SPR__c != newSPRQuote.TAMS_Quote_SPR__c) || oldSPRQuote == null ){
					quoteChangedSPRQuotes.put(newSPRQuote.TAMS_Quote_SPR__c,quoteChangedOPAsCount++);
				}
			}
		}

		if(oldSPRQuotes == null){
			for(SPR_Quote__c newSPRQuote: newSPRQuotes){
				quoteChangedSPRQuotes.put(newSPRQuote.TAMS_Quote_SPR__c,quoteChangedOPAsCount++);
			}
		}
		
		System.debug('quoteChangedSPRQuotes.size():'+quoteChangedSPRQuotes.size());
		//Get All SPR Quotes attached with specific Quotes
		List<TAMS_Quotes__c> quotes = [SELECT
										  id,
										  FOB_Down__c
										FROM
										  TAMS_Quotes__c
										WHERE ID IN :quoteChangedSPRQuotes.keySet()
										];
		System.debug('quotes size:'+quotes.size());
		for(TAMS_Quotes__c quote: quotes){
			newSPRQuotes.get(quoteChangedSPRQuotes.get(quote.id)).FOB_Down__c = quote.FOB_Down__c;
		}										

	}
	// Added - Lokesh Tigulla - updating ZVP When the new OPA is Created 
	public static void UpdatingZVP(List<TAMS_Order_Process_Approval__c> lOPA){
    system.debug('Entered in updatedZVP');
	system.debug('lOPA'+lOPA);
	Set<String> sZVP = new Set<String>();
	Map<String,Id> mUserIdtoRole = new Map<String,Id>();
	for(TAMS_Order_Process_Approval__c opa: lOPA){
		sZVP.add(opa.OPA_ZVP_Role__c);
		// mOpptyIdtoOPA.put(opa.Opportunity__c, opa.OPA_ZVP_Role__c);		
	}
	system.debug('sZVP'+sZVP);
	if(sZVP.size() > 0){
     for(User usr: [Select Id,UserRole.name From User Where UserRole.name IN:sZVP And IsActive = true AND profile.name = 'TAMS - ZVP']){
		 mUserIdtoRole.put(usr.UserRole.name,usr.Id);
	 }
	 System.debug('mUserIdtoRole'+mUserIdtoRole);
	 if(mUserIdtoRole.size() > 0){
		 for(TAMS_Order_Process_Approval__c opa : lOPA){
			 if(mUserIdtoRole.containsKey(opa.OPA_ZVP_Role__c)){
				 opa.OPA_ZVP__c = mUserIdtoRole.get(opa.OPA_ZVP_Role__c);
			 }
		 }
	    }
	  }
	}
    // Added - Lokesh Tigulla- c before approval 
	// public static void ZVPAcknowledgement(List<TAMS_Order_Process_Approval__c> lOPA){
    //   System.debug('Entered approvalagreement');
	//   System.debug('lOPA'+lOPA);
	//   Set<Id> sOPAId = new Set<Id>();
	//   for(TAMS_Order_Process_Approval__c opaId : lOPA){
	// 	  sOPAId.add(opaId.Id);
	//   }
	// //   List<ProcessInstance> lprocessInstance = [SELECT Id, FROM ProcessInstance WHERE  ];
	// if(sOPAId.size()>0){
	//      Map<Id,TAMS_Order_Process_Approval__c> mopastatus = new Map<Id,TAMS_Order_Process_Approval__c> ([Select id,Status__c,OPA_Sep_Verbal_Written_Agreements__c From TAMS_Order_Process_Approval__c Where Id IN: sOPAId ]);
		
	// 	for(TAMS_Order_Process_Approval__c opa : lOPA ){
	// 		if(opa.Status__c == 'Pending ZVP Acknowledgement'){
    //             System.debug('Entered into for loop');
    //             if(mopastatus.get(opa.Id).OPA_Sep_Verbal_Written_Agreements__c == null){
	// 				opa.addError('Please Enter Separate Verbal/ Written Agreements Value');
	// 			}
	// 		}
	// 	  }
	//      }
	//   	}	
}