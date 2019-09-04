trigger OPAAttachmentTrigger on Attachment (after insert) {

    System.debug('BEFORE TAMSSPRSupportingDocumentsHelper.checkPublicFlag');
    TAMSSPRSupportingDocumentsHelper.checkPublicFlag(Trigger.new);
    System.debug('AFTER TAMSSPRSupportingDocumentsHelper.checkPublicFlag');

    System.debug('BEFORE OPAAttachmentHelper.checkPublicFlag');
    OPAAttachmentHelper.checkPublicFlag(Trigger.new);
    System.debug('AFTER OPAAttachmentHelper.checkPublicFlag');

}