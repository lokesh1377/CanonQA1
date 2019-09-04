trigger AccountTrigger on Account (after insert, after update) {
    if((Trigger.isAfter)&&(Trigger.isInsert || Trigger.isUpdate)){
        System.debug('Entered into Trigger');
        AccountTriggerHandler.After_InsertUpdate(Trigger.New,Trigger.oldMap,Trigger.newMap);
     }
}