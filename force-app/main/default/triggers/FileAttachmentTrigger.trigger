/*********************************************************
        Author: Lokesh Tigulla         
        Purpose: This Trigger is for ContentDocumentLink Trigger.        
        1.0 - Lokesh Tigulla - 08/12/2019 - Created
**********************************************************/
trigger FileAttachmentTrigger on ContentDocumentLink (after insert,after Update) {
 if((Trigger.isAfter)&&(Trigger.isInsert || Trigger.isUpdate)){
        System.debug('Entered into COFileAttachmentHelper Trigger');
        COFileAttachmentHelper.checkPublicFlag(Trigger.New);
         System.debug('Entered into OPAFileAttachmentHelper Trigger');
           OPAFileAttachmentHelper.checkPublicFlag(Trigger.New);
           System.debug('Entered Into SPRFileAttachmentHelper Trigger');
           SPRFileAttachmentHelper.checkPublicFlag(Trigger.New);
     }
}