/*********************************************************
        Author: Lokesh Tigulla        
        Purpose: This Class is used in Creating Change Order From Change Order Tab.        
        1.0 - Lokesh Tigulla-04/03/2019 - Created
**********************************************************/
public with sharing class ChangeOrderInternalCTRL {
	public String sidNumberId {get;set;}
  private System.PageReference cancel {get;set;}
	public String sidNumber {get;set;}
	public TAMS_ROA__c newChangeOrderHeader {get;set;}
	public List<Order_Master__c> lOrd ;
	public Boolean showChangeOrderInternal {get;set;}
	public BOolean showChangeorderExternal {get;set;}
	public Boolean showChangeRequestedBy {get;set;}
	public Boolean showotherSID {get;set;}
	public Boolean showSID {get;set;}
	public Boolean showOrderNUmber {get;set;}
	public Boolean showAccount {get;set;}
	public Boolean showOA {get;set;}
  public String changeOrderType {get;set;}
  public String changeRequestedBy {get;set;}
	public String modality {get;set;}
	public String customerName {get;set;}
	public ChangeOrderInternalCTRL(ApexPages.StandardSetController controller) {
           this.cancel  =  controller.cancel(); 
       newChangeOrderHeader = new TAMS_ROA__c();
        //this.showChangeorderExternal = false;
        // this.showChangeOrderInternal = false;
       this.changeOrderType = 'Item Change';
       this.changeRequestedBy = 'Internal';
   }
	public PageReference saveChangeOrder(){
		System.debug('Entered');
		System.debug('sidNumber'+sidNumber);
		System.debug('sidNumberId'+sidNumberId);
		if(newChangeOrderHeader.ROA_Type__c !='Other'){
            if(isvalidSid(sidNumber)){
							// if(sidNumber != null){
	            //   Order_Master__c ord = [Select Customer_Name__c,Account_Number_Order__c,Modality_Order__c From Order_Master__c Where Id =: sidNumberId ];
							// 	modality = ord.Modality_Order__c;
							// 	customerName = ord.Customer_Name__c;
							// // }else{
							// // 	List<Order_Master__c> lOrd = [Select Customer_Name__c,Account_Number_Order__c,Modality_Order__c From Order_Master__c Where OM_SID__c =: sidNumber ];
							// // 	modality = lOrd.get(0).Modality_Order__c;
							// // 	customerName = lOrd.get(0).Customer_Name__c;
							// // }
								List<Order_Master__c> lOrd = [Select Customer_Name__c,Account_Number_Order__c,Modality_Order__c From Order_Master__c Where OM_SID__c =: sidNumber ];
	              System.debug(customerName);
								System.debug(modality);
								if(lOrd.size() > 0){
	              newChangeOrderHeader.Account__c = lOrd.get(0).Customer_Name__c;
	              newChangeOrderHeader.change_order_sid__c = sidNumber;
                newChangeOrderHeader.ROA_Type__c = 'Item Change';
                newChangeOrderHeader.Change_Requested_By__c = 'Internal';
	              newChangeOrderHeader.COH_Modality__c = lOrd.get(0).Modality_Order__c;
	              System.debug(newChangeOrderHeader);
	               insert newChangeOrderHeader;
	              System.debug('***newChangeOrderHeader**'+ newChangeOrderHeader);
	              ChangeOrderExt.createChangeOrderOFA(newChangeOrderHeader);
	              PageReference newPage = new PageReference('/'+newChangeOrderHeader.Id);
	              return newPage.setRedirect(true);
								}else{
									Apexpages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'Please check the SID Number')); 
								}
              }else{
              	 Apexpages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'Please check the SID Number')); 
              }
		}else{
			      insert newChangeOrderHeader;
	              System.debug('***newChangeOrderHeader**'+ newChangeOrderHeader);
	              ChangeOrderExt.createChangeOrderOFA(newChangeOrderHeader);
	              PageReference newPage = new PageReference('/'+newChangeOrderHeader.Id);
	              return newPage.setRedirect(true);
		}
		return null;
	}

	 @TestVisible private boolean isvalidSid(String sidNumber){
	 	System.debug('Valid Sid');
	    List<Order_Master__c> lOrd = [Select Id,OM_SID__c From Order_Master__c];
	    for(Order_Master__c ord : lOrd){
	    	if(ord.OM_SID__c == sidNumber && sidNumber != null ){
	    		return true;
	    	}
	    }
	    return false;
	 }

  
	 public void changeorders(){
                     
     showChangeOrderInternal = true;
   }

   public List<TAMS_ROA__c> getchangeorderInternal(){
    System.debug('sidNumber'+sidNumber);
     showChangeOrderInternal = true;
       list<TAMS_ROA__c> lroa = [Select Id,Name,Change_Requested_By__c,Status__c,COH_Modality__c From TAMS_ROA__c Where Change_Order_SID__c =: sidNumber ];
       System.debug(lroa);
       return lroa;
  }

  public PageReference cancel()
    {         
          return cancel;  
    } 
}