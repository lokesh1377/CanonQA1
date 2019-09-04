trigger ChangeorderLines_Trigger on TAMS_ROA_Lines__c
    (after delete, after insert, after undelete, after update, before delete,before update) {
     Type rollClass = System.Type.forName('rh2', 'ParentUtil');
     if(rollClass != null) {
        rh2.ParentUtil pu = (rh2.ParentUtil) rollClass.newInstance();
        if (trigger.isAfter) {
            pu.performTriggerRollups(trigger.oldMap, trigger.newMap, new String[]{'TAMS_ROA_Lines__c'}, null);
        }
    }

     //Added by Lokesh Tigulla on 02/21/2019 
    //When Status is updated on change order they should not be accessing any actions in Item changes 
    //updated by Lokesh Tigulla on 04/10/2109
    if (Trigger.isBefore) {
            if (Trigger.isDelete || Trigger.isUpdate) {
            Id profileId=userinfo.getProfileId();
            String profileName=[Select Id,Name from Profile where Id=:profileId].Name;
            system.debug('ProfileName'+profileName);
            if(profileName != 'System Administrator' && profileName != 'Integration Admin' ){
                    Set<Id> sRoaIds = new Set<Id>();
                for(TAMS_ROA_Lines__c col:trigger.old){
                    sRoaIds.add(col.TAMS_ROA__c);
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
                            for(TAMS_ROA_Lines__c col:trigger.new){
                                String roaStatus = mRoaIds.get(col.TAMS_ROA__c).Status__c;
                                if(roaStatus == 'Pending Finance Mgr Approval' || roaStatus == 'Pending CFO Approval' ||  roaStatus == 'Pending Gov Mgr Approval' || roaStatus == 'Pending Order Management Approval' || roaStatus == 'Pending Legal Approval' || roaStatus == 'Pending Credit Approval' ||roaStatus == 'Pending Logistics Management Approval' || roaStatus == 'Complete' || roaStatus == 'Canceled' ){
                                    col.addError('Change Order Cannot be edited after it is submitted for Approval');
                                }
                            }
                        }

                        if(trigger.isDelete){
                            for(TAMS_ROA_Lines__c col:trigger.old){
                                String roaStatus = mRoaIds.get(col.TAMS_ROA__c).Status__c;
                                if(roaStatus == 'Pending Finance Mgr Approval' || roaStatus == 'Pending CFO Approval' ||  roaStatus == 'Pending Gov Mgr Approval' || roaStatus == 'Pending Order Management Approval' || roaStatus == 'Pending Legal Approval' || roaStatus == 'Pending Credit Approval' ||roaStatus == 'Pending Logistics Management Approval' || roaStatus == 'Complete' || roaStatus == 'Canceled'){
                                    col.addError('Change Order Cannot be edited after it is submitted for Approval');
                                }
                            }
                        }
                     }
                }

            }
    }
  }
}