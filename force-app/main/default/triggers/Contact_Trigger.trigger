trigger Contact_Trigger on Contact (after update) {
	//Making sure these updates to Contact are not the result of another @Future call
	//originating from an update to the User object.
	if(system.isFuture() == false){
		//Only executing these code when Contact is Community Enabled on Update
		Contact_TriggerHandler.UpdateContactUserInfo(trigger.new, trigger.oldMap);
	}
	Contact_TriggerHandler.UpdateAccountProcessShareFlag(trigger.new, trigger.oldMap);
}