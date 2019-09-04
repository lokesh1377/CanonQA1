trigger TAMS_Affiliation_Trigger on TAMS_Affiliation__c (before insert, before update, after delete) {
	TAMS_AffiliationTriggerHandler oHandler = new TAMS_AffiliationTriggerHandler();
	
	if(trigger.isInsert){
		oHandler.UpdateContact(trigger.new);
	}else if(trigger.isUpdate){
		oHandler.UpdateContact(trigger.new, trigger.oldMap);
	}else{
		oHandler.DeleteShares(trigger.old);
	}
}