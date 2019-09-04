/*********************************************************
        Author: Lokesh Tigulla         
        Purpose: This Class is for ContentDocumentLink Trigger Handler.        
        1.0 - Lokesh Tigulla - 08/15/2019 - Created
**********************************************************/
public class OPAFileAttachmentHelper {
    public static void checkPublicFlag(List<ContentDocumentLink> condoc){

        Set<id> OPAIds = new Set<id>();
        List<Order_Attachment__c> OPAList = new List<Order_Attachment__c>();
        List<Order_Attachment__c> updateOPAList = new List<Order_Attachment__c>();
        Map<Id,ContentDocumentLink> mcondoc = new Map<Id,ContentDocumentLink>();
        for(ContentDocumentLink condoclink : condoc){        
               String objectAPIName = (String) condoclink.LinkedEntityId.getSObjectType().getDescribe().getName();
               System.debug('Parent Object Type Name - objectAPIName = '+objectAPIName);
               if(objectAPIName.equalsIgnoreCase('Order_Attachment__c')) {     
               OPAIds.add(condoclink.LinkedEntityId); 
                mcondoc.put(condoclink.LinkedEntityId,condoclink);         
               }
               if(OPAIds.size()>0){
               OPAList = [select id, Order_Attachment_ID__c from Order_Attachment__c where id in :OPAIds];
               }
               if(OPAList !=null && OPAList.size()>0){
                 for(Order_Attachment__c oa : OPAList){
                     oa.Order_Attachment_ID__c = mcondoc.get(oa.id).ContentDocumentId;
                     updateOPAList.add(oa);
                 }
               }
        }
        if(updateOPAList.size()>0){
        update updateOPAList;
        }

        //Add attachment to the TAMS Order Process Approval notes if Parent object is Order_Attachment and flaged as Public
        
        Map<ID,List<ContentDocumentLink>> OrderAttachments = new Map<ID,List<ContentDocumentLink>>();
        //Get All OrderAttachments
        for(ContentDocumentLink conDocatt : condoc ){
          System.debug('Processing Parent ID:'+conDocatt.LinkedEntityId);
          String objType = conDocatt.LinkedEntityId.getSObjectType().getDescribe().getName();
          System.debug('objType:'+objType);
          if(objType.equalsIgnoreCase('Order_Attachment__c')){
            System.debug('Adding Attachment to OrderAttachments');
            if(OrderAttachments.containsKey(conDocatt.LinkedEntityId)){
              List<ContentDocumentLink> condoclink = OrderAttachments.get(conDocatt.LinkedEntityId);
              condoclink.add(conDocatt);
              OrderAttachments.put(conDocatt.LinkedEntityId,condoclink);
            }else{
              List<ContentDocumentLink> condoclink = new List<ContentDocumentLink>();
              condoclink.add(conDocatt);
              OrderAttachments.put(conDocatt.LinkedEntityId,condoclink);
            }
          }
        }

        System.debug('OrderAttachments size:'+OrderAttachments.size());
        if(OrderAttachments.size() == 0){
          return;
        }

        //Get ALL Public OrderAttachments and OPA ID's
        List<Order_Attachment__c> publicOrderAttachments  = 
          [ select
              TAMS_OPA__c
             ,ID
            from
              Order_Attachment__c
            WHERE ID in :OrderAttachments.KeySet()
            AND public__c = True];
         
         Set<Id> sId = new Set<Id>();
         for(Order_Attachment__c oA : publicOrderAttachments){
             sId.add(oA.Id);
         }
        System.debug('publicOrderAttachments size:'+publicOrderAttachments.size());    
        if(publicOrderAttachments.size() == 0){
          return;
        }  

         List<ContentDocumentLink> ConDocLink = [Select ContentDocumentId From ContentDocumentLink Where LinkedEntityId IN: sId ];
          System.debug('ConDocLink:'+ConDocLink);
          Set<Id> sCondoc = new Set<Id>();
          for(ContentDocumentLink con: ConDocLink ){
              sCondoc.add(con.ContentDocumentId);
          }
           List<ContentVersion> lconver = [Select Title,PathOnClient,VersionData From ContentVersion Where ContentDocumentId IN: sCondoc AND IsLatest = true ];
          List<ContentVersion> lConDoc = new List<ContentVersion>();
        for(Order_Attachment__c ordAttachment : publicOrderAttachments){
          ContentVersion conVer = new ContentVersion();
          List<ContentDocumentLink> existingcondoc = OrderAttachments.get(ordAttachment.ID);
          for(ContentVersion con:lconver){
          for(ContentDocumentLink existingAttachment: existingcondoc){
            conVer.FirstPublishLocationId  = ordAttachment.TAMS_OPA__c;
            conVer.Title =  con.Title;
            conVer.PathOnClient = con.PathOnClient;
            conVer.VersionData = con.VersionData;   
            lConDoc.add(conVer);
            System.debug(lConDoc);
          }
          }
        }

        if(lConDoc.size() > 0){
          insert lConDoc;
        }
    }
}