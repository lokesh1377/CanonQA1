trigger TAMS_Case_Task_Trigger on TAMS_Case_Task__c (before insert, before update) {
	TAMS_CaseTaskTriggerHandler oHandler = new TAMS_CaseTaskTriggerHandler();
	
	if(trigger.isInsert){
		oHandler.UpdateOwner(trigger.new);
	}else if(trigger.isUpdate){
		oHandler.UpdateOwner(trigger.new, trigger.oldMap);
	}
}