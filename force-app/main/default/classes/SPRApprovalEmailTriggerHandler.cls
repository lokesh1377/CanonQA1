/*********************************************************
Author : Hemant Kumar       
Purpose: Class for SPR Approval / Rejection Email 
1.0 - Hemant Kumar - 08/30/2017 - Created
1.1 - Hemant Kumar - 06/26/2018 - Updated NSD and Added ZBM
1.2 - Hemant Kumar - 02/22/2019 - Added MT Zone
**********************************************************/

public class SPRApprovalEmailTriggerHandler {
  
   public static void SendApprovalEmail(List<TAMS_Special_Pricing_Request__c> newSPR){
         
      String uRoleName; 
      String uGroupName; 
      List<GroupMember> groupMembers;
      List<User>  rUser;         
      Id uZBMId; 
             
      System.debug('HK- SendApprovalEmail .. SPR Details :'+ newSPR);
           
      for(TAMS_Special_Pricing_Request__c spr : newSPR) { 
     
         if(spr.Executive_Approved__c == true && spr.Status__c== 'Approved'){
            uRoleName = 'ZBM';
            uZBMId = spr.ZBM_Id__c;
            System.debug('HK- SendApprovalEmail .. ZBM Id :'+ uZBMId);         
            sendEmail('A', uZBMId, uRoleName, spr.Id);
         }   
     
         if(spr.Executive_Approved__c == true && spr.ZVP_CE_Approved__c == true){         
            uRoleName= 'ZVP CENTRAL-EAST';
            rUser = [Select Id, FirstName, LastName, UserRoleId, UserRole.Name 
                       from User 
                      Where UserRole.name=:uRoleName
                        and IsActive = true];
            for(User rm : rUser)
            {
              sendEmail('A', rm.Id, uRoleName, spr.Id);
            } 
         }
         
         if(spr.Executive_Approved__c == true && spr.ZVP_CW_Approved__c == true){
            uRoleName= 'ZVP CENTRAL-WEST';
            rUser = [Select Id, FirstName, LastName, UserRoleId, UserRole.Name 
                       from User 
                      Where UserRole.name=:uRoleName
                        and IsActive = true];
            for(User rm : rUser)
            {
              sendEmail('A', rm.Id, uRoleName, spr.Id);
            } 
         }
                   
         if(spr.Executive_Approved__c == true && spr.ZVP_GS_Approved__c == true){
            uRoleName= 'ZVP GULF SOUTH';
            rUser = [Select Id, FirstName, LastName, UserRoleId, UserRole.Name 
                       from User 
                      Where UserRole.name=:uRoleName
                        and IsActive = true];                      
            for(User rm : rUser)
            {
              sendEmail('A', rm.Id, uRoleName, spr.Id);
            } 
         }
                  
          if(spr.Executive_Approved__c == true && spr.ZVP_MA_Approved__c == true){
            uRoleName= 'ZVP MID-ATLANTIC';
            rUser = [Select Id, FirstName, LastName, UserRoleId, UserRole.Name 
                       from User 
                      Where UserRole.name=:uRoleName
                        and IsActive = true];                      
            for(User rm : rUser)
            {
              sendEmail('A', rm.Id, uRoleName, spr.Id);
            } 
         }
                   
         if(spr.Executive_Approved__c == true && spr.ZVP_MS_Approved__c == true){
            uRoleName= 'ZVP MID-SOUTH';
            rUser = [Select Id, FirstName, LastName, UserRoleId, UserRole.Name 
                       from User 
                      Where UserRole.name=:uRoleName
                        and IsActive = true];                      
            for(User rm : rUser)
            {
              sendEmail('A', rm.Id, uRoleName, spr.Id);
            } 
         }
         
         if(spr.Executive_Approved__c == true && spr.SPR_ZVP_MT_Approved__c == true){
            uRoleName= 'ZVP MOUNTAIN';
            rUser = [Select Id, FirstName, LastName, UserRoleId, UserRole.Name 
                       from User 
                      Where UserRole.name=:uRoleName
                        and IsActive = true];                      
            for(User rm : rUser)
            {
              sendEmail('A', rm.Id, uRoleName, spr.Id);
            } 
         }
                  
         if(spr.Executive_Approved__c == true && spr.ZVP_NW_Approved__c == true){
            uRoleName= 'ZVP NORTHWEST';
            rUser = [Select Id, FirstName, LastName, UserRoleId, UserRole.Name 
                       from User 
                      Where UserRole.name=:uRoleName
                        and IsActive = true];                      
            for(User rm : rUser)
            {
              sendEmail('A', rm.Id, uRoleName, spr.Id);
            } 
         }
                   
         if(spr.Executive_Approved__c == true && spr.ZVP_SW_Approved__c == true){
            uRoleName= 'ZVP SOUTHWEST';
            rUser = [Select Id, FirstName, LastName, UserRoleId, UserRole.Name 
                       from User 
                      Where UserRole.name=:uRoleName
                        and IsActive = true];                      
            for(User rm : rUser)
            {
              sendEmail('A', rm.Id, uRoleName, spr.Id);
            } 
         }
                   
         if(spr.Executive_Approved__c == true && spr.ZVP_WE_Approved__c == true){
            uRoleName= 'ZVP WEST';
            rUser = [Select Id, FirstName, LastName, UserRoleId, UserRole.Name 
                       from User 
                      Where UserRole.name=:uRoleName
                        and IsActive = true];                      
            for(User rm : rUser)
            {
              sendEmail('A', rm.Id, uRoleName, spr.Id);
            } 
         }                                   

        if(spr.Executive_Approved__c == true && spr.NSD_CT_Approved__c == true){
            uGroupName= 'NSD CT'; 
            groupMembers=[Select Id, UserOrGroupId From GroupMember where group.name=:uGroupName];
            for(GroupMember gm : groupMembers)
            {
              sendEmail('A', gm.UserOrGroupId, uGroupName, spr.Id);
            }    
         }
          
         if(spr.Executive_Approved__c == true && spr.NSD_MR_Approved__c == true){
            uGroupName= 'NSD MR';
            groupMembers=[Select Id, UserOrGroupId From GroupMember where group.name=:uGroupName];
            for(GroupMember gm : groupMembers)
            {
              sendEmail('A', gm.UserOrGroupId, uGroupName, spr.Id);
            }             
         }
         
         if(spr.Executive_Approved__c == true && spr.NSD_UL_Approved__c == true){
            uGroupName= 'NSD UL';
            groupMembers=[Select Id, UserOrGroupId From GroupMember where group.name=:uGroupName];
            for(GroupMember gm : groupMembers)
            {
              sendEmail('A', gm.UserOrGroupId, uGroupName, spr.Id);
            }             
         }
         
         if(spr.Executive_Approved__c == true && spr.NSD_XRVL_Approved__c == true){
            uGroupName= 'NSD XRVL';   
            groupMembers=[Select Id, UserOrGroupId From GroupMember where group.name=:uGroupName];
            for(GroupMember gm : groupMembers)
            {
              sendEmail('A', gm.UserOrGroupId, uGroupName, spr.Id);
            } 
         }
         
         
      } //for   
   }//public Approval method


   public static void SendRejectionEmail(List<TAMS_Special_Pricing_Request__c> newSPR){       

      String uRoleName; 
      String uGroupName; 
      List<GroupMember> groupMembers;
      List<User>  rUser;
      Id uZBMId;
                   
      System.debug('HK- SendRejectionEmail .. SPR Details :'+ newSPR);
           
      for(TAMS_Special_Pricing_Request__c spr : newSPR) { 
     
         if(spr.Executive_Rejected__c == true && spr.Status__c== 'Rejected'){
            uRoleName = 'ZBM';
            uZBMId = spr.ZBM_Id__c;
            System.debug('HK- SendApprovalEmail .. ZBM Id :'+ uZBMId);         
            sendEmail('R', uZBMId, uRoleName, spr.Id);
         }
              
         if(spr.Executive_Rejected__c == true && spr.ZVP_CE_Approved__c == true){         
            uRoleName= 'ZVP CENTRAL-EAST';
            rUser = [Select Id, FirstName, LastName, UserRoleId, UserRole.Name 
                       from User 
                      Where UserRole.name=:uRoleName
                        and IsActive = true];                      
            for(User rm : rUser)
            {
              sendEmail('R', rm.Id, uGroupName, spr.Id);
            } 
         }
         
         if(spr.Executive_Rejected__c == true && spr.ZVP_CW_Approved__c == true){
            uRoleName= 'ZVP CENTRAL-WEST';
            rUser = [Select Id, FirstName, LastName, UserRoleId, UserRole.Name 
                       from User 
                      Where UserRole.name=:uRoleName
                        and IsActive = true];                      
            for(User rm : rUser)
            {
              sendEmail('R', rm.Id, uRoleName, spr.Id);
            } 
         }
                   
         if(spr.Executive_Rejected__c == true && spr.ZVP_GS_Approved__c == true){
            uRoleName= 'ZVP GULF SOUTH';
            rUser = [Select Id, FirstName, LastName, UserRoleId, UserRole.Name 
                       from User 
                      Where UserRole.name=:uRoleName
                        and IsActive = true];                      
            for(User rm : rUser)
            {
              sendEmail('R', rm.Id, uRoleName, spr.Id);
            } 
         }
                  
          if(spr.Executive_Rejected__c == true && spr.ZVP_MA_Approved__c == true){
            uRoleName= 'ZVP MID-ATLANTIC';
            rUser = [Select Id, FirstName, LastName, UserRoleId, UserRole.Name 
                       from User 
                      Where UserRole.name=:uRoleName
                        and IsActive = true];                      
            for(User rm : rUser)
            {
              sendEmail('R', rm.Id, uRoleName, spr.Id);
            } 
         }
                   
         if(spr.Executive_Rejected__c == true && spr.ZVP_MS_Approved__c == true){
            uRoleName= 'ZVP MID-SOUTH';
            rUser = [Select Id, FirstName, LastName, UserRoleId, UserRole.Name 
                       from User 
                      Where UserRole.name=:uRoleName
                        and IsActive = true];                      
            for(User rm : rUser)
            {
              sendEmail('R', rm.Id, uRoleName, spr.Id);
            } 
         }

         if(spr.Executive_Rejected__c == true && spr.SPR_ZVP_MT_Approved__c == true){
            uRoleName= 'ZVP MOUNTAIN';
            rUser = [Select Id, FirstName, LastName, UserRoleId, UserRole.Name 
                       from User 
                      Where UserRole.name=:uRoleName
                        and IsActive = true];                      
            for(User rm : rUser)
            {
              sendEmail('R', rm.Id, uRoleName, spr.Id);
            } 
         }       
                  
         if(spr.Executive_Rejected__c == true && spr.ZVP_NW_Approved__c == true){
            uRoleName= 'ZVP NORTHWEST';
            rUser = [Select Id, FirstName, LastName, UserRoleId, UserRole.Name 
                       from User 
                      Where UserRole.name=:uRoleName
                        and IsActive = true];                      
            for(User rm : rUser)
            {
              sendEmail('R', rm.Id, uRoleName, spr.Id);
            } 
         }
                   
         if(spr.Executive_Rejected__c == true && spr.ZVP_SW_Approved__c == true){
            uRoleName= 'ZVP SOUTHWEST';
            rUser = [Select Id, FirstName, LastName, UserRoleId, UserRole.Name 
                       from User 
                      Where UserRole.name=:uRoleName
                        and IsActive = true];                      
            for(User rm : rUser)
            {
              sendEmail('R', rm.Id, uRoleName, spr.Id);
            } 
         }
                   
         if(spr.Executive_Rejected__c == true && spr.ZVP_WE_Approved__c == true){
            uRoleName= 'ZVP WEST';
            rUser = [Select Id, FirstName, LastName, UserRoleId, UserRole.Name 
                       from User 
                      Where UserRole.name=:uRoleName
                        and IsActive = true];                      
            for(User rm : rUser)
            {
              sendEmail('R', rm.Id, uRoleName, spr.Id);
            } 
         }                                   

        if(spr.Executive_Rejected__c == true && spr.NSD_CT_Approved__c == true){
            uGroupName= 'NSD CT'; 
            groupMembers=[Select Id, UserOrGroupId From GroupMember where group.name=:uGroupName];
            for(GroupMember gm : groupMembers)
            {
              sendEmail('R', gm.UserOrGroupId, uGroupName, spr.Id);
            }    
         }
          
         if(spr.Executive_Rejected__c == true && spr.NSD_MR_Approved__c == true){
            uGroupName= 'NSD MR';
            groupMembers=[Select Id, UserOrGroupId From GroupMember where group.name=:uGroupName];
            for(GroupMember gm : groupMembers)
            {
              sendEmail('R', gm.UserOrGroupId, uGroupName, spr.Id);
            }             
         }
         
         if(spr.Executive_Rejected__c == true && spr.NSD_UL_Approved__c == true){
            uGroupName= 'NSD UL';
            groupMembers=[Select Id, UserOrGroupId From GroupMember where group.name=:uGroupName];
            for(GroupMember gm : groupMembers)
            {
              sendEmail('R', gm.UserOrGroupId, uGroupName, spr.Id);
            }             
         }
         
         if(spr.Executive_Rejected__c == true && spr.NSD_XRVL_Approved__c == true){
            uGroupName= 'NSD XRVL';   
            groupMembers=[Select Id, UserOrGroupId From GroupMember where group.name=:uGroupName];
            for(GroupMember gm : groupMembers)
            {
              sendEmail('R', gm.UserOrGroupId, uGroupName, spr.Id);
            } 
         }
         
         
      } //for

   }//public Rejection Method
   
    private static void sendEmail(string emailType, Id toAddress, string uRoleGroupName, Id sprId){        
        
        if(Test.isRunningTest()){
          return;
        }
        
        EmailTemplate templateId;
        OrgWideEmailAddress owa = [select id, DisplayName, Address from OrgWideEmailAddress where Address = 'Compass.support@us.medical.canon'];        
        System.debug('HK- SendEmail .. Email From        :'+ owa.Address);
        if(emailType == 'A'){
           templateId = [Select id from EmailTemplate where name = 'SPR Approval Email'];    
        }
        else if(emailType == 'R'){
           templateId = [Select id from EmailTemplate where name = 'SPR Rejection Email'];     
        }        
        System.debug('HK- SendEmail .. Email Template Type :'+emailType);
        System.debug('HK- SendEmail .. Email Template ID   :'+emailType);
        System.debug('HK- SendEmail .. Email To RoleGroupName :'+ uRoleGroupName);
        System.debug('HK- SendEmail .. Email To RoleGroupId   :'+ toAddress);        
        
        List<Messaging.SingleEmailMessage> allmsg = new List<Messaging.SingleEmailMessage>();
        Messaging.SingleEmailMessage mail         = new Messaging.SingleEmailMessage();
        mail.setWhatId(sprId);
        mail.setTemplateID(templateId.Id);
        mail.setSaveAsActivity(false);
        mail.setOrgWideEmailAddressId(owa.id);
        mail.setTargetObjectId(toAddress); 
        allmsg.add(mail);
        Messaging.sendEmail(allmsg,false);        
        System.debug('HK- SendEmail .. Email Sent       :'+ allmsg);
        System.debug('HK- SendEmail .. Done');
    }//private void sendEmail 
    
}