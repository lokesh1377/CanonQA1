/*********************************************************
        Author:         
        Purpose: This HandlerClass is for task trigger.        
        1.0 - Lokesh Tigulla-05/31/2019- Created
**********************************************************/
public class TaskTriggerHandler{
  
   public static void createTask(List<Task> ltaskId){
   System.debug('ltaskId'+ltaskId);
   Set<Id> sWhatId = new Set<Id>();
   Set<Id> sWhoId = new Set<Id>();
    List<Task> lEUTasks  = new List<Task>();
    Map<Id,Id> mWhoIdToWhatId = new Map<Id,Id>();
    system.debug('ltaskId:'+ltaskId);
   for(Task tId : ltaskId){
            sWhatId.add(tId.WhatId);
            sWhoId.add(tId.WhoId);
            mWhoIdToWhatId.put(tId.WhoId,tId.WhatId);
    }
    if(sWhoId.size() > 0){
        List<Equip_Upgrade__c> lEU = [Select Id,Name,eu_Account_Id__c From Equip_Upgrade__c Where id in: sWhatId];
        Map<Id,Id> mEUAccountId = new Map<Id,Id>();
        for(Equip_Upgrade__c eu :lEU){
            if(eu.name.startsWith('EU')){
                mEUAccountId.put(eu.Id,eu.eu_Account_Id__c);
            }
        }
        System.debug('**Map'+mEUAccountId);
        Map<Id,contact> mIdtoContact = new Map<Id,Contact>([Select Id,AccountId From contact Where id in: sWhoId]);
        List<TAMS_Affiliation__c> ltamsaff =  [SELECT id, Account__c ,Contact__c from TAMS_Affiliation__c where Contact__c in: sWhoId ];
        Map<Id,Id> mContactIdtoAccountId = new Map<Id,Id>();
        for(TAMS_Affiliation__c tamsaff: ltamsaff){
            mContactIdtoAccountId.put(tamsaff.contact__c, tamsaff.account__c);
        }
        for(Task tk: ltaskId){
            if(mEUAccountId.containsKey(tk.WhatId)){
                String taskAccount = mEUAccountId.get(tk.WhatId);
                String contactAccount = mIdtoContact.get(tk.WhoId).AccountId;
                String affAccount  = mContactIdtoAccountId.get(tk.whoId);
                if((taskAccount != null  && taskAccount != contactAccount) || (contactAccount != affAccount && affAccount != null)){
                    tk.addError('Please Select Contact Associated to this Acccount');
                }
            }

        }
    }    
   }   
}