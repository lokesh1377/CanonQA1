global with sharing class OpportunityOriginalSIDWarningMsgCTRL {
	private Opportunity opp;
	private static final String WARNING_MESSAGE = 'Specify Original SID for Upgrades';
	public OpportunityOriginalSIDWarningMsgCTRL(ApexPages.StandardController stdCtrl) {
		System.debug('START:OpportunityOriginalSIDWarningMsgCTRL');
		Id oppId = stdCtrl.getId();
		List<Opportunity> opps = [SELECT Opportunity_Type__c,Original_Booking_SID_lookup__c  FROM Opportunity
									WHERE id = :oppId LIMIT 1];
		if(opps.size() == 1){
			opp = opps[0];
		}
		System.debug('END:OpportunityOriginalSIDWarningMsgCTRL');
	}

	public PageReference getMsg(){
		System.debug('START:getMsg');
		System.debug('opp:'+opp);
		if(opp != null){
			System.debug('Opportunity_Type__c:'+opp.Opportunity_Type__c);
			System.debug('Original_Booking_SID_lookup__c :'+opp.Original_Booking_SID_lookup__c );
			if(opp.Opportunity_Type__c == 'Upgrade' && opp.Original_Booking_SID_lookup__c  == null){
				ApexPages.Message errMsg = new ApexPages.Message(ApexPages.Severity.WARNING, OpportunityOriginalSIDWarningMsgCTRL.WARNING_MESSAGE);
				ApexPages.addMessage(errMsg);				
			}
		}
		System.debug('END:getMsg');
		return null;
	}
	@AuraEnabled
	webservice static String getMessageLightning(Id opportunityId){
		System.debug('START:getMessageLightning');
		List<Opportunity> opps = [SELECT Opportunity_Type__c,Original_Booking_SID_lookup__c  FROM Opportunity
									WHERE id = :opportunityId LIMIT 1];
		if(opps.size() == 1){
			System.debug('Opportunity_Type__c:'+opps[0].Opportunity_Type__c);
			System.debug('Original_Booking_SID_lookup__c :'+opps[0].Original_Booking_SID_lookup__c );
			if(opps[0].Opportunity_Type__c == 'Upgrade' && opps[0].Original_Booking_SID_lookup__c  == null){
				return WARNING_MESSAGE;
			}
		}
		return Null;		
	} 

}