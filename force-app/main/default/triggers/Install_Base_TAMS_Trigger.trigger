trigger Install_Base_TAMS_Trigger on Install_Base_TAMS__c (before delete, before insert, before update) {
	if(Trigger.isInsert){
		InstallBaseTriggerHandler.UpdateProductSubFamilyLookup(Trigger.new);
		InstallBaseTriggerHandler.UpdateAccountTeam(Trigger.new);
	}else if(Trigger.isUpdate){
		InstallBaseTriggerHandler.UpdateProductSubFamilyLookup(Trigger.new);
		InstallBaseTriggerHandler.UpdateAccountTeam(Trigger.new, Trigger.oldMap);
	}else if(Trigger.isDelete){
		InstallBaseTriggerHandler.UpdateAccountTeam(Trigger.old);
	}
}