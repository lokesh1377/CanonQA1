trigger ServiceContract_Trigger on ServiceContract (after insert, after update) {
	if(trigger.isInsert){
		ServiceContractTriggerHandler.UpdateEquipmentWithActiveContract(trigger.new);
	}else{
		ServiceContractTriggerHandler.UpdateEquipmentWithActiveContract(trigger.new, trigger.oldMap);
	}
}