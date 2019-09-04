trigger OpportunityLineItemTrigger on OpportunityLineItem (
	before insert, 
	before update, 
	before delete, 
	after insert, 
	after update, 
	after delete, 
	after undelete) {

	if (Trigger.isAfter) {
		if(Trigger.isInsert||Trigger.isUpdate){
			OpportunityLineItemTriggerHandler.updateMarketingMaterial(Trigger.new);
		}
	}
	if (Trigger.isBefore) {
		if(Trigger.isDelete){
			OpportunityLineItemTriggerHandler.removeMarketingMaterial(Trigger.old);
		}
	}	
}