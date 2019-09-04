trigger Administrative_Change on Change_Order_Administrative_Change__c
    (after delete, after insert, after undelete, after update, before delete,before update) {
     Type rollClass = System.Type.forName('rh2', 'ParentUtil');
     if(rollClass != null) {
        rh2.ParentUtil pu = (rh2.ParentUtil) rollClass.newInstance();
        if (trigger.isAfter) {
            pu.performTriggerRollups(trigger.oldMap, trigger.newMap, new String[]{'Change_Order_Administrative_Change__c'}, null);
        }
    }
    //Added by Lokesh Tigulla on 02/05/2019 
    //When Status is updated on change order they should not be accessing any actions in administrative changes 
    if (Trigger.isBefore) {
        Id profileId=userinfo.getProfileId();
         String profileName=[Select Id,Name from Profile where Id=:profileId].Name;
         system.debug('ProfileName'+profileName);
        if(profileName != 'System Administrator' && profileName != 'Integration Admin' ){
     if (Trigger.isDelete || Trigger.isUpdate) {
            Set<Id> sRoaIds = new Set<Id>();
           for(Change_Order_Administrative_Change__c coa:trigger.old){
               sRoaIds.add(coa.TAMS_ROA__c);
           }
          if(sRoaIds.size()>0){
            Map<Id,TAMS_ROA__c> mRoaIds = new Map<Id,TAMS_ROA__c>([Select 
                                               Id
                                              ,Status__c
                                         From 
                                               TAMS_ROA__c 
                                         Where
                                              Id IN: sRoaIds]);
                 if(!mRoaIds.isEmpty()){
                    if(trigger.isUpdate){
                    for(Change_Order_Administrative_Change__c coa:trigger.new){
                        String roaStatus = mRoaIds.get(coa.TAMS_ROA__c).Status__c;
                        if(roaStatus == 'Pending Commissions Mgr Approval' || roaStatus == 'Pending Credit Approval' ||  roaStatus == 'Pending Gov Mgr Approval' || roaStatus == 'Pending Order Management Approval' || roaStatus == 'Pending Finance Mgr Approval' || roaStatus == 'Complete'){
                            coa.addError('Change Order Cannot be edited after it is submitted for Approval');
                        }
                    }
                 }

                 if(trigger.isDelete){
                    for(Change_Order_Administrative_Change__c coa:trigger.old){
                        String roaStatus = mRoaIds.get(coa.TAMS_ROA__c).Status__c;
                        if(roaStatus == 'Pending Commissions Mgr Approval' || roaStatus == 'Pending Credit Approval' ||  roaStatus == 'Pending Gov Mgr Approval' || roaStatus == 'Pending Order Management Approval' || roaStatus == 'Pending Finance Mgr Approval' || roaStatus == 'Complete'){
                            coa.addError('Change Order Cannot be edited after it is submitted for Approval');
                        }
                    }
                 }
                 }
          }

    }  
}
}

}