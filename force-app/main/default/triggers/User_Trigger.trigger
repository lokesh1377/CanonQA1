trigger User_Trigger on User (after insert, after update) {
	UserTriggerHandler oHandler = new UserTriggerHandler();
	
	if(trigger.isInsert == true){
		oHandler.UpdateProcessAccountShares(trigger.newMap);
	}else if(trigger.isUpdate == true){
		oHandler.UpdateProcessAccountShares(trigger.newMap, trigger.old);
	}
}