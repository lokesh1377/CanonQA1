trigger CaseTrigger on Case (before insert, before update) {
    
    CaseTrigger ct = new CaseTrigger();
    if (Trigger.isInsert){
        ct.BusinessHoursCheck(Trigger.New);
        //ct.checkPO(Trigger.New);
    }
    if(Trigger.isInsert|| Trigger.IsUpdate){
       ct.EquipmentTrigger(Trigger.New);
    }

}