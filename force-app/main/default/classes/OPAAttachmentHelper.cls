public class OPAAttachmentHelper {
	public static void checkPublicFlag(List<Attachment> newAttachments){

	    Set<id> OPAIds = new Set<id>();
	    List<Order_Attachment__c> OPAList = new List<Order_Attachment__c>();
	    List<Order_Attachment__c> updateOPAList = new List<Order_Attachment__c>();
	    
	    for(Attachment att : newAttachments){        
	           String objectAPIName = (String) att.ParentId.getSObjectType().getDescribe().getName();
	           System.debug('Parent Object Type Name - objectAPIName = '+objectAPIName);
	           if(objectAPIName.equalsIgnoreCase('Order_Attachment__c'))        
	           OPAIds.add(att.ParentId);           
	    
	           OPAList = [select id, Order_Attachment_ID__c from Order_Attachment__c where id in :OPAIds];
	           if(OPAList !=null && OPAList.size()>0){
	             for(Order_Attachment__c oa : OPAList){
	                 oa.Order_Attachment_ID__c = att.id;
	                 updateOPAList.add(oa);
	             }
	           }
	    }    
	    update updateOPAList;

	    //Add attachment to the TAMS Order Process Approval notes if Parent object is Order_Attachment and flaged as Public
	    
	    Map<ID,List<Attachment>> OrderAttachments = new Map<ID,List<Attachment>>();
	    //Get All OrderAttachments
	    for(Attachment attm : newAttachments ){
	      System.debug('Processing Parent ID:'+attm.ParentId);
	      String objType = attm.ParentId.getSObjectType().getDescribe().getName();
	      System.debug('objType:'+objType);
	      if(objType.equalsIgnoreCase('Order_Attachment__c')){
	        System.debug('Adding Attachment to OrderAttachments');
	        if(OrderAttachments.containsKey(attm.ParentID)){
	          List<Attachment> attms = OrderAttachments.get(attm.ParentID);
	          attms.add(attm);
	          OrderAttachments.put(attm.ParentID,attms);
	        }else{
	          List<Attachment> attms = new List<Attachment>();
	          attms.add(attm);
	          OrderAttachments.put(attm.ParentID,attms);
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

	    System.debug('publicOrderAttachments size:'+publicOrderAttachments.size());    
	    if(publicOrderAttachments.size() == 0){
	      return;
	    }    

	    List<Attachment> newAttachmentsForOPA = new List<Attachment>();
	    for(Order_Attachment__c ordAttachment : publicOrderAttachments){
	      Attachment newAttachmentForOPA = new Attachment();
	      List<Attachment> existingAttachments = OrderAttachments.get(ordAttachment.ID);
	      for(Attachment existingAttachment: existingAttachments){
	        newAttachmentForOPA.body  = existingAttachment.Body;
	        newAttachmentForOPA.parentID =  ordAttachment.TAMS_OPA__c;
	        newAttachmentForOPA.Name = existingAttachment.Name;
	        System.debug('Adding attachment:'+existingAttachment.Name+ ' and TAMS_OPA__c:'+ordAttachment.TAMS_OPA__c);    
	        newAttachmentsForOPA.add(newAttachmentForOPA);
	      }
	    }

	    if(newAttachmentsForOPA.size() > 0){
	      insert newAttachmentsForOPA;
	    }
	}
}