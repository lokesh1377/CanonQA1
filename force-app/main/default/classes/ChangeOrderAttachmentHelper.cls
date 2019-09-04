public class ChangeOrderAttachmentHelper{
  public static void checkPublicFlag(List<Attachment> newAttachments){
  
     //Add attachment to the Change Order Attachement if Parent object is Change_Order_Attachment__c and flaged as Public  
      Set<id> COIds = new Set<id>();
      List<Change_Order_Attachment__c> COList       = new List<Change_Order_Attachment__c>();
      List<Change_Order_Attachment__c> updateCOList = new List<Change_Order_Attachment__c>();
    
      System.debug('HK - Inside ChangeOrderAttachmentHelper Class:');
      
      //Get All ChangeOrderAttachments
      for(Attachment att : newAttachments ){
          System.debug('HK - Processing Parent ID:'+att.ParentId);
          String objectAPIName = (String) att.ParentId.getSObjectType().getDescribe().getName();
          System.debug('Parent Object Type Name - objectAPIName = '+objectAPIName);
          
          if(objectAPIName.equalsIgnoreCase('Change_Order_Attachment__c'))
             System.debug('HK - Adding Attachment to ChangeOrderAttachments');
             COIds.add(att.ParentId);
            
             COList = [Select id, COA_Change_Order_Attachment_ID__c
                         FROM Change_Order_Attachment__c
                        WHERE ID in :COIds
                      ];   

             if(COList !=null && COList.size()>0){
               for(Change_Order_Attachment__c coa : COList){
                   coa.COA_Change_Order_Attachment_ID__c= att.id;
                   updateCOList.add(coa);
               }
             }
          } 
          update updateCOList;
          
          //Add attachment to the Change Order notes if Parent object is Change Order Attachment and flaged as Public          
          Map<ID,List<Attachment>> ChangeOrderAttachments = new Map<ID,List<Attachment>>();
          //Get All ChangeOrderAttachments
          for(Attachment attm : newAttachments ){
            System.debug('HK - ChangeOrderAttachments - Processing Parent ID:'+attm.ParentId);
            String objType = attm.ParentId.getSObjectType().getDescribe().getName();
            System.debug('HK - ChangeOrderAttachments - objType:'+objType);
            if(objType.equalsIgnoreCase('Change_Order_Attachment__c')){
              System.debug('HK - ChangeOrderAttachments -Adding Attachment to ChangeOrderAttachments');
              if(ChangeOrderAttachments.containsKey(attm.ParentID)){
                List<Attachment> attms = ChangeOrderAttachments.get(attm.ParentID);
                attms.add(attm);
                ChangeOrderAttachments.put(attm.ParentID,attms);
              }else{
                List<Attachment> attms = new List<Attachment>();
                attms.add(attm);
                ChangeOrderAttachments.put(attm.ParentID,attms);
              }
            }
          }
                    
          System.debug('HK - ChangeOrderAttachments - ChangeOrderAttachments size:'+ChangeOrderAttachments.size());
          if(ChangeOrderAttachments.size() == 0){
            return;
          }        
            
          //Get ALL Public ChangeOrderAttachments and ChangeOrder ID's
          List<Change_Order_Attachment__c> publicChangeOrderAttachments  = 
            [ select COA_Change_Order__c ,ID
                from Change_Order_Attachment__c
               where ID in :ChangeOrderAttachments.KeySet()
                 and COA_Public__c = True];

          System.debug('HK - ChangeOrderAttachments - publicChangeOrderAttachments size:'+publicChangeOrderAttachments.size());    
          if(publicChangeOrderAttachments.size() == 0){
             return;
          }    
         
          List<Attachment> newAttachmentsForCO = new List<Attachment>();
          for(Change_Order_Attachment__c ChangeOrdAttachment : publicChangeOrderAttachments){
             Attachment newAttachmentForCO = new Attachment();
             
             List<Attachment> existingAttachments = ChangeOrderAttachments.get(ChangeOrdAttachment.ID);
             
             for(Attachment existingAttachment: existingAttachments){
                newAttachmentForCO.body     = existingAttachment.Body;
                newAttachmentForCO.parentID = ChangeOrdAttachment.COA_Change_Order__c;
                newAttachmentForCO.Name     = existingAttachment.Name;
                System.debug('HK - ChangeOrderAttachments - Adding attachment: '+existingAttachment.Name+ ' and COA_Change_Order__c :'+ChangeOrdAttachment.COA_Change_Order__c);    
                newAttachmentsForCO.add(newAttachmentForCO);
             }
          }

          if(newAttachmentsForCO.size() > 0){
            insert newAttachmentsForCO;
          }   
       
  }
}