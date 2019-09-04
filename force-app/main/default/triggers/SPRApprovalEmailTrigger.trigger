/*********************************************************
Author : Hemant Kumar       
Purpose: Trigger for SPR Approval / Rejection Email 
1.0 - Hemant Kumar - 08/30/2017 - Created
**********************************************************/
trigger SPRApprovalEmailTrigger on TAMS_Special_Pricing_Request__c (after update) {
    
    if(Trigger.isUpdate){
       System.debug('HK- Inside SPRApprovalEmailTrigger .. After Update .. isUpdate Method :');
    
      for (TAMS_Special_Pricing_Request__c lSpr : Trigger.new){
          System.debug('HK- Inside for Loop .. SPR ID :'+lSpr.ID);
          System.debug('HK- Inside for Loop .. Executive Approved New = :'+lSpr.Executive_Approved__c );
          System.debug('HK- Inside for Loop .. Executive Approved Old = :'+trigger.oldMap.get(lSpr.Id).Executive_Approved__c );
          System.debug('HK- Inside for Loop .. Executive Rejected New = :'+lSpr.Executive_Rejected__c );
          System.debug('HK- Inside for Loop .. Executive Rejected Old = :'+trigger.oldMap.get(lSpr.Id).Executive_Rejected__c);
                    
          if(lSpr.Executive_Approved__c  != trigger.oldMap.get(lSpr.Id).Executive_Approved__c && lSpr.Executive_Approved_Date__c != null) {
             System.debug('HK- Inside if .. Approval Email Condition...Executive_Approved Flag:'+lSpr.Executive_Approved__c);
             System.debug('HK- Inside if .. Approval Email Condition...Executive_Approved Date:'+lSpr.Executive_Approved_Date__c);
             System.debug('HK- Inside if .. Approval Email Condition...Calling SendApprovalEmail Method...');             
             SPRApprovalEmailTriggerHandler.SendApprovalEmail(Trigger.new);
          } 
          else if (lSpr.Executive_Rejected__c != trigger.oldMap.get(lSpr.Id).Executive_Rejected__c && lSpr.Executive_Rejected_Date__c != null){
             System.debug('HK- Inside if .. Rejection Email Condition...Executive_Rejected Flag:'+lSpr.Executive_Rejected__c);
             System.debug('HK- Inside if .. Rejection Email Condition...Executive_Rejected Date:'+lSpr.Executive_Rejected_Date__c);
             System.debug('HK- Inside Else if .. Rejection Email Condition...Calling SendRejectionEmail Method...');
             SPRApprovalEmailTriggerHandler.SendRejectionEmail(Trigger.new);         
         }//if ..else if
         
         System.debug('HK- Outside of if..else if ..');   
      }//for (TAMS_Special_Pricing_Request__c lSpr : Trigger.new)           
      
    }//if(Trigger.isUpdate) 
    
}//trigger