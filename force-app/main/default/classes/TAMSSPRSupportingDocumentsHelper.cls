public class TAMSSPRSupportingDocumentsHelper {
	public static void checkPublicFlag(List<Attachment> newAttachments){
	    //Add attachment to the TAMS Order Process Approval notes if Parent object is TAMS_SPR_Supporting_Documents__c and flaged as Public
	    //By PSINGH
	    List<TAMS_SPR_Supporting_Documents__c> updateSprSupportingDocuments = new List<TAMS_SPR_Supporting_Documents__c>();
	    Map<ID,Attachment> sprSupportingDocAttachments = new Map<ID,Attachment>();
	    //Get All sprSupportingDocAttachments
	    for(Attachment attm : newAttachments ){
	      	System.debug('Processing Parent ID:'+attm.ParentId);
	      	String objType = attm.ParentId.getSObjectType().getDescribe().getName();
	      	System.debug('objType:'+objType);
	      	if(objType.equalsIgnoreCase('TAMS_SPR_Supporting_Documents__c')){
	        	System.debug('Adding Attachment to sprSupportingDocAttachments');
	        	sprSupportingDocAttachments.put(attm.ParentID,attm);
	        	TAMS_SPR_Supporting_Documents__c updateSprSupportingDocument = new TAMS_SPR_Supporting_Documents__c();
	        	updateSprSupportingDocument.id = attm.ParentID;
	        	updateSprSupportingDocument.SPR_Attachment_ID__c = attm.id;
	        	updateSprSupportingDocuments.add(updateSprSupportingDocument);
	        }
	    }

	    System.debug('sprSupportingDocAttachments size:'+sprSupportingDocAttachments.size());
	    if(sprSupportingDocAttachments.size() == 0){
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

	    System.debug('publicSprSupportingDocAttachments size:'+publicSprSupportingDocAttachments.size());    
	    if(publicSprSupportingDocAttachments.size() == 0){
	      	return;
	    }    

	    List<Attachment> newAttachmentsForSpr = new List<Attachment>();
	    for(TAMS_SPR_Supporting_Documents__c sprSuppDocAttachment : publicSprSupportingDocAttachments){
		    Attachment newAttachmentForSpr = new Attachment();
		    Attachment existingAttachment = sprSupportingDocAttachments.get(sprSuppDocAttachment.ID);
		    newAttachmentForSpr.body  = existingAttachment.Body;
		    newAttachmentForSpr.parentID =  sprSuppDocAttachment.TAMS_Special_Pricing_Request__c;
		    newAttachmentForSpr.Name = existingAttachment.Name;
		    System.debug('Adding attachment:'+existingAttachment.Name+ ' and TAMS_Special_Pricing_Request__c:'+sprSuppDocAttachment.TAMS_Special_Pricing_Request__c);    
		    newAttachmentsForSpr.add(newAttachmentForSpr);
	    }

	    if(newAttachmentsForSpr.size() > 0){
	      	insert newAttachmentsForSpr;
	    }		

	    if(updateSprSupportingDocuments.size() > 0){
	      	update updateSprSupportingDocuments;
	    }		
	}
}