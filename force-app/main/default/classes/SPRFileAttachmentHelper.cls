/*********************************************************
        Author: Lokesh Tigulla         
        Purpose: This Class is for ContentDocumentLink Trigger Handler.        
        1.0 - Lokesh Tigulla - 08/19/2019 - Created
**********************************************************/
public class SPRFileAttachmentHelper{
  public static void checkPublicFlag(List<ContentDocumentLink> newConDocLink){
      System.debug('Entered into SPR File Attachment Helper');
      //Add attachment to the TAMS Order Process Approval notes if Parent object is TAMS_SPR_Supporting_Documents__c and flaged as Public
      List<TAMS_SPR_Supporting_Documents__c> updateSprSupportingDocuments = new List<TAMS_SPR_Supporting_Documents__c>();
      Map<ID,ContentDocumentLink> sprSupportingDocAttachments = new Map<ID,ContentDocumentLink>();
      //Get All sprSupportingDocAttachments
      for(ContentDocumentLink conDoc  : newConDocLink ){
          System.debug('Processing Parent ID:'+conDoc.LinkedEntityId);
          String objType = conDoc.LinkedEntityId.getSObjectType().getDescribe().getName();
          System.debug('objType:'+objType);
          if(objType.equalsIgnoreCase('TAMS_SPR_Supporting_Documents__c')){
            System.debug('Adding Attachment to sprSupportingDocAttachments');            
            sprSupportingDocAttachments.put(conDoc.LinkedEntityId,conDoc);
            TAMS_SPR_Supporting_Documents__c updateSprSupportingDocument = new TAMS_SPR_Supporting_Documents__c();
            updateSprSupportingDocument.id = conDoc.LinkedEntityId;
            updateSprSupportingDocument.SPR_Attachment_ID__c = conDoc.ContentDocumentId;
            updateSprSupportingDocuments.add(updateSprSupportingDocument);
          }
      }

      System.debug('sprSupportingDocAttachments size:'+sprSupportingDocAttachments.size());
      if(sprSupportingDocAttachments.size() == 0){
          return;
      }
        System.debug('updateSprSupportingDocuments'+updateSprSupportingDocuments);
      if(updateSprSupportingDocuments.size() > 0){
          update updateSprSupportingDocuments;
      }

      //Add attachment to the TAMS Order Process Approval notes if Parent object is Order_Attachment and flaged as Public
              
        Map<ID,List<ContentDocumentLink>> SPRattachament = new Map<ID,List<ContentDocumentLink>>();
        //Get All OrderAttachments
        for(ContentDocumentLink conDocatt : newConDocLink ){
          System.debug('Processing Parent ID:'+conDocatt.LinkedEntityId);
          String objType = conDocatt.LinkedEntityId.getSObjectType().getDescribe().getName();
          System.debug('objType:'+objType);
          if(objType.equalsIgnoreCase('TAMS_SPR_Supporting_Documents__c')){
            System.debug('Adding Attachment to OrderAttachments');
            if(SPRattachament.containsKey(conDocatt.LinkedEntityId)){
              List<ContentDocumentLink> condoclink = SPRattachament.get(conDocatt.LinkedEntityId);
              condoclink.add(conDocatt);
              SPRattachament.put(conDocatt.LinkedEntityId,condoclink);
            }else{
              List<ContentDocumentLink> condoclink = new List<ContentDocumentLink>();
              condoclink.add(conDocatt);
              SPRattachament.put(conDocatt.LinkedEntityId,condoclink);
            }
          }
        }

        System.debug('SPRattachament size:'+SPRattachament.size());
        if(SPRattachament.size() == 0){
          return;
        }

      //Get ALL Public sprSupportingDocAttachments and OPA ID's
      List<TAMS_SPR_Supporting_Documents__c> publicSprSupportingDocAttachments  = 
        [ SELECT
            TAMS_Special_Pricing_Request__c
           ,ID
          FROM
            TAMS_SPR_Supporting_Documents__c
          WHERE ID in :sprSupportingDocAttachments.KeySet()
          AND public__c = True];

       Set<Id> sID = new Set<Id>();
       for(TAMS_SPR_Supporting_Documents__c sprDoc : publicSprSupportingDocAttachments ){
         sID.add(sprDoc.Id);
       }

      System.debug('publicSprSupportingDocAttachments size:'+publicSprSupportingDocAttachments.size());    
      if(publicSprSupportingDocAttachments.size() == 0){
          return;
      }    
       List<ContentDocumentLink> ConDocLink = [Select ContentDocumentId From ContentDocumentLink Where LinkedEntityId IN: sId ];
       System.debug('ConDocLink'+ConDocLink); 
        Set<Id> sCondoc = new Set<Id>();
        for(ContentDocumentLink con: ConDocLink ){
          sCondoc.add(con.ContentDocumentId);
        }
        List<ContentVersion> lconver = [Select Title,PathOnClient,VersionData From ContentVersion Where ContentDocumentId IN: sCondoc AND IsLatest = true ];
          System.debug('lconver'+lconver);
           List<ContentVersion> lConDoc = new List<ContentVersion>();
           for(TAMS_SPR_Supporting_Documents__c sprSupDoc : publicSprSupportingDocAttachments){
             ContentVersion conVer = new ContentVersion();
             System.debug('Entered in For loop');
             System.debug('sprSupportingDocAttachments:'+sprSupportingDocAttachments);
              List<ContentDocumentLink> existingcondoc = SPRattachament.get(sprSupDoc.ID);
               for(ContentVersion con:lconver ){
                  for(ContentDocumentLink existingAttachment: existingcondoc){
                  conVer.FirstPublishLocationId = sprSupDoc.TAMS_Special_Pricing_Request__c;
                  conVer.Title = con.Title;
                  conVer.PathOnClient = con.PathOnClient;
                  conVer.VersionData = con.VersionData;
                   lConDoc.add(conVer);
                 system.debug('lConDoc'+lConDoc);
                  }
               }
           }
           
          if(lConDoc.size() > 0){
            insert lConDoc;
          } 
          
    //   List<Attachment> newAttachmentsForSpr = new List<Attachment>();
    //   for(TAMS_SPR_Supporting_Documents__c sprSuppDocAttachment : publicSprSupportingDocAttachments){
    //     Attachment newAttachmentForSpr = new Attachment();
    //     Attachment existingAttachment = sprSupportingDocAttachments.get(sprSuppDocAttachment.ID);
    //     newAttachmentForSpr.body  = existingAttachment.Body;
    //     newAttachmentForSpr.parentID =  sprSuppDocAttachment.TAMS_Special_Pricing_Request__c;
    //     newAttachmentForSpr.Name = existingAttachment.Name;
    //     System.debug('Adding attachment:'+existingAttachment.Name+ ' and TAMS_Special_Pricing_Request__c:'+sprSuppDocAttachment.TAMS_Special_Pricing_Request__c);    
    //     newAttachmentsForSpr.add(newAttachmentForSpr);
    //   }

    //   if(newAttachmentsForSpr.size() > 0){
    //       insert newAttachmentsForSpr;
    //   }    
          
  }
}