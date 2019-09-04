/*********************************************************
        Author: Lokesh Tigulla         
        Purpose: This Class is for ContentDocumentLink Trigger Handler.        
        1.0 - Lokesh Tigulla - 08/13/2019 - Created
**********************************************************/
public class COFileAttachmentHelper{
  public static void checkPublicFlag(List<ContentDocumentLink> newContentDocumentLink){
      System.debug('Entered into Apex class of change order attachment');
     //Add attachment to the Change Order Attachement if Parent object is Change_Order_Attachment__c and flaged as Public  
      Set<id> COIds = new Set<id>();
      List<Change_Order_Attachment__c> COList       = new List<Change_Order_Attachment__c>();
      List<Change_Order_Attachment__c> updateCOList = new List<Change_Order_Attachment__c>();
      Map<Id,ContentDocumentLink> mConDoc           = new Map<Id,ContentDocumentLink>();
    
      System.debug('Inside ChangeOrderAttachmentHelper Class:');
      
      //Get All ChangeOrderAttachments
      for(ContentDocumentLink conDocatt : newContentDocumentLink ){
          System.debug('Processing Parent ID:'+conDocatt.LinkedEntityId);
          String objectAPIName = (String) conDocatt.LinkedEntityId.getSObjectType().getDescribe().getName();
          System.debug('Parent Object Type Name - objectAPIName = '+objectAPIName);
          
          if(objectAPIName.equalsIgnoreCase('Change_Order_Attachment__c')){
             System.debug('Adding Attachment to ChangeOrderAttachments');
             COIds.add(conDocatt.LinkedEntityId);
             mConDoc.put(conDocatt.LinkedEntityId,conDocatt);
              }
            }
      if(COIds.Size()>0){
             COList = [Select id, COA_Change_Order_Attachment_ID__c
                         FROM Change_Order_Attachment__c
                        WHERE ID in :COIds
                      ];   
          }
             if(COList !=null && COList.size()>0){
               for(Change_Order_Attachment__c coa : COList){
                   coa.COA_Change_Order_Attachment_ID__c = mConDoc.get(coa.id).ContentDocumentId;
                   updateCOList.add(coa);
               }
             }
           
          System.debug('updateCOList'+updateCOList);
          if(updateCOList.size()>0){
          update updateCOList;
          }
          
          //Add attachment to the Change Order notes if Parent object is Change Order Attachment and flaged as Public          
          Map<ID,List<ContentDocumentLink>> ChangeOrderAttachments = new Map<ID,List<ContentDocumentLink>>();
          //Get All ChangeOrderAttachments
          for(ContentDocumentLink conDocatt : newContentDocumentLink ){
            System.debug('ChangeOrderAttachments - Processing Parent ID:'+conDocatt.LinkedEntityId);
            String objType = conDocatt.LinkedEntityId.getSObjectType().getDescribe().getName();
            System.debug('ChangeOrderAttachments - objType:'+objType);
            if(objType.equalsIgnoreCase('Change_Order_Attachment__c')){
              System.debug('ChangeOrderAttachments -Adding Attachment to ChangeOrderAttachments');
              if(ChangeOrderAttachments.containsKey(conDocatt.LinkedEntityId)){
                List<ContentDocumentLink> condoclink = ChangeOrderAttachments.get(conDocatt.LinkedEntityId);
                condoclink.add(conDocatt);
                ChangeOrderAttachments.put(conDocatt.LinkedEntityId,condoclink);
              }else{
                List<ContentDocumentLink> condoclink = new List<ContentDocumentLink>();
                condoclink.add(conDocatt);
                ChangeOrderAttachments.put(conDocatt.LinkedEntityId,condoclink);
              }
            }
          }
                    
          System.debug('ChangeOrderAttachments - ChangeOrderAttachments size:'+ChangeOrderAttachments.size());
          if(ChangeOrderAttachments.size() == 0){
            return;
          }        
            
          // Get ALL Public ChangeOrderAttachments and ChangeOrder ID's
          List<Change_Order_Attachment__c> publicChangeOrderAttachments  = 
            [ select COA_Change_Order__c ,ID
                from Change_Order_Attachment__c
               where ID in :ChangeOrderAttachments.KeySet()
                 and COA_Public__c = True];

          Set<Id> sId = new Set<Id>();

          for(Change_Order_Attachment__c coa: publicChangeOrderAttachments){
            sId.add(coa.Id);
          }

          System.debug('ChangeOrderAttachments - publicChangeOrderAttachments size:'+publicChangeOrderAttachments.size());    
          if(publicChangeOrderAttachments.size() == 0){
             return;
          }    
          List<ContentDocumentLink> ConDocLink = [Select ContentDocumentId From ContentDocumentLink Where LinkedEntityId IN: sId ];
          System.debug('ConDocLink'+ConDocLink); 
          Set<Id> sCondoc = new Set<Id>();
          for(ContentDocumentLink con : ConDocLink){
              sCondoc.add(con.ContentDocumentId);
          }
          List<ContentVersion> lconver = [Select Title,PathOnClient,VersionData From ContentVersion Where ContentDocumentId IN: sCondoc AND IsLatest = true ];
          System.debug('lconver'+lconver);
          List<ContentVersion> lConDoc = new List<ContentVersion>();
          for(Change_Order_Attachment__c ChangeOrdAttachment : publicChangeOrderAttachments){
             ContentVersion conVer = new ContentVersion();
             System.debug('Entered in For loop');
             System.debug('ChangeOrderAttachments:'+ChangeOrderAttachments);
             List<ContentDocumentLink> existingcondoc = ChangeOrderAttachments.get(ChangeOrdAttachment.ID);
               for(ContentVersion con:lconver ){
               for(ContentDocumentLink existingAttachment: existingcondoc){                  
                  conVer.FirstPublishLocationId = ChangeOrdAttachment.COA_Change_Order__c;
                  conVer.Title = con.Title;
                  conVer.PathOnClient = con.PathOnClient;
                  conVer.VersionData = con.VersionData;
                 lConDoc.add(conVer);
                 System.debug('lConDoc'+lConDoc);
               }
             }
          }

          if(lConDoc.size() > 0){
            insert lConDoc;
          }  

  }
}