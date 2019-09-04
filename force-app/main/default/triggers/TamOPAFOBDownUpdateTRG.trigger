trigger TamOPAFOBDownUpdateTRG on TAMS_Order_Process_Approval__c (before insert, before update, after insert) {
    if((Trigger.isBefore)&&(Trigger.isInsert || Trigger.isUpdate)){
    // System.debug('START:TamOPAFOBDownUpdateTRG'+trigger.new.get(0).OPA_ZVP_Role__c);
    TamsQuoteFOBDownUpdateHelper.OPAUpdated(Trigger.new,Trigger.old);
    // Add by Lokesh Tigulla 
     if(Trigger.isInsert){
        TamsQuoteFOBDownUpdateHelper.UpdatingZVP(Trigger.new);
     }
    }

    //  if((Trigger.isBefore) && (Trigger.isUpdate)){
    //      TamsQuoteFOBDownUpdateHelper.ZVPAcknowledgement(Trigger.new);
    //  }
}