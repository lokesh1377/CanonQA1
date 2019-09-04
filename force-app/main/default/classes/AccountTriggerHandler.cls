public class AccountTriggerHandler{

    public static void After_InsertUpdate( List<Account> lAccount,Map<Id,Account> mAccountold,Map<Id,Account> mAccountNew){

        Set<Id> sAccountIdsCT = new Set<Id>();
        Set<Id> sAccountIdsUL = new Set<Id>();
        Set<Id> sAccountIdsMR = new Set<Id>();
        Set<Id> sAccountIdsXR = new Set<Id>();
        Set<Id> removeAccessUserIdsCT = new Set<Id>();
        Set<Id> removeAccessUserIdsUL = new Set<Id>();
        Set<Id> removeAccessUserIdsMR = new Set<Id>();
        Set<Id> removeAccessUserIdsXR = new Set<Id>(); 
        if(mAccountold != null){
            for(Account acc: lAccount){
                 System.debug('acc.CT_ZBM_Acc__c'+acc.CT_ZBM_Acc__c);
                if(acc.CT_ZBM_Acc__c != null){                 
                    sAccountIdsCT.add(acc.id);
                    System.debug('sAccountIdsCT'+sAccountIdsCT);
                 }else if(mAccountold.containsKey(acc.Id)){
                     system.debug('**'+mAccountold.get(acc.Id).CT_ZBM_Acc__c);
                     if(mAccountold.get(acc.Id).CT_ZBM_Acc__c != null){
                        removeAccessUserIdsCT.add(mAccountold.get(acc.Id).CT_ZBM_Acc__c);
                     }
                 }else if(acc.UL_ZBM_Acc__c != null){
                     sAccountIdsUL.add(acc.id);
                 }else if(mAccountold.containsKey(acc.Id)){ 
                     if(mAccountold.get(acc.Id).UL_ZBM_Acc__c != null){
                        removeAccessUserIdsUL.add(mAccountold.get(acc.Id).UL_ZBM_Acc__c);
                     }
                 }else if(acc.MR_ZBM_Acc__c!= null){
                     sAccountIdsMR.add(acc.id);
                 }else if(mAccountold.containsKey(acc.Id)){
                     if(mAccountold.get(acc.Id).MR_ZBM_Acc__c!= null){
                        removeAccessUserIdsMR.add(mAccountold.get(acc.Id).MR_ZBM_Acc__c);
                     }
                 }else if(acc.XR_VL_ZBM_Acc__c != null){
                     sAccountIdsXR.add(acc.id);
                 }else if(mAccountold.containsKey(acc.Id)){
                     if(mAccountold.get(acc.Id).XR_VL_ZBM_Acc__c != null){
                        removeAccessUserIdsXR.add(mAccountold.get(acc.Id).XR_VL_ZBM_Acc__c);
                     }
                 }                       
            }
    	}
        
        if(sAccountIdsCT.size() > 0){
            List<AccountShare> lAccountShare = new List<AccountShare>();
            for(Id accountId : sAccountIdsCT){
                AccountShare thisAccountShare = new AccountShare();
                thisAccountShare.userorgroupid = mAccountNew.get(accountId).CT_ZBM_Acc__c;                
                thisAccountShare.accountid = accountid;
                thisAccountShare.accountaccesslevel = 'Edit';
                thisAccountShare.OpportunityAccessLevel = 'Edit';
                thisAccountShare.CaseAccessLevel = 'Edit';
                lAccountShare.add(thisAccountShare);
            }  
            insert lAccountShare;
        }
        if(sAccountIdsUL.size() > 0){
            List<AccountShare> lAccountShare = new List<AccountShare>();
            for(Id accountId : sAccountIdsUL){
                AccountShare thisAccountShare = new AccountShare();
                thisAccountShare.userorgroupid = mAccountNew.get(accountId).UL_ZBM_Acc__c;                
                thisAccountShare.accountid = accountid;
                thisAccountShare.accountaccesslevel = 'Edit';
                thisAccountShare.OpportunityAccessLevel = 'Edit';
                thisAccountShare.CaseAccessLevel = 'Edit';
                lAccountShare.add(thisAccountShare);
            }  
            insert lAccountShare;
        }

    if(sAccountIdsMR.size() > 0){
            List<AccountShare> lAccountShare = new List<AccountShare>();
            for(Id accountId : sAccountIdsMR){
                AccountShare thisAccountShare = new AccountShare();
                thisAccountShare.userorgroupid = mAccountNew.get(accountId).MR_ZBM_Acc__c;                
                thisAccountShare.accountid = accountid;
                thisAccountShare.accountaccesslevel = 'Edit';
                thisAccountShare.OpportunityAccessLevel = 'Edit';
                thisAccountShare.CaseAccessLevel = 'Edit';
                lAccountShare.add(thisAccountShare);
            }  
            insert lAccountShare;
        }
        
        if(sAccountIdsXR.size() > 0){
            List<AccountShare> lAccountShare = new List<AccountShare>();
            for(Id accountId : sAccountIdsXR){
                AccountShare thisAccountShare = new AccountShare();
                thisAccountShare.userorgroupid = mAccountNew.get(accountId).XR_VL_ZBM_Acc__c;                
                thisAccountShare.accountid = accountid;
                thisAccountShare.accountaccesslevel = 'Edit';
                thisAccountShare.OpportunityAccessLevel = 'Edit';
                thisAccountShare.CaseAccessLevel = 'Edit';
                lAccountShare.add(thisAccountShare);
            }  
            insert lAccountShare;
        }
        
        
        if(removeAccessUserIdsCT.size() > 0){         
              List<AccountShare> lAccountShareCT = [Select id from AccountShare where userorgroupid in: removeAccessUserIdsCT];
              if(lAccountShareCT.size() > 0){
                  delete lAccountShareCT;
              }
        }
       if(removeAccessUserIdsUL.size() > 0){         
              List<AccountShare> lAccountShareUL = [Select id from AccountShare where userorgroupid in: removeAccessUserIdsUL];
              if(lAccountShareUL.size() > 0){
                  delete lAccountShareUL;
              }
              }
       if(removeAccessUserIdsMR.size() > 0){
               List<AccountShare> lAccountShareMR = [Select id from AccountShare where userorgroupid in: removeAccessUserIdsMR];
               if(lAccountShareMR.size() > 0){
                  delete lAccountShareMR;
               }
              }
      if(removeAccessUserIdsXR.size() > 0){
                List<AccountShare> lAccountShareXR = [Select id from AccountShare where userorgroupid in: removeAccessUserIdsXR];
                if(lAccountShareXR.size() > 0){
                    delete lAccountShareXR;
                }
              }
 
        

    }
}