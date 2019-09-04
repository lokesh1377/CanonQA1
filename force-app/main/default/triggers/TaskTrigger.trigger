Trigger TaskTrigger on Task (before insert, before update) {
if((trigger.IsInsert || trigger.IsUpdate) && trigger.IsBefore){
TaskTriggerHandler.createTask(Trigger.new);
}
}