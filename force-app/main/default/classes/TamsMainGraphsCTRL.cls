public class TamsMainGraphsCTRL {
	public Install_Base_TAMS__c ibRecord {get;set;}
	private ID ibID;
	public TamsMainGraphsCTRL(ApexPages.StandardController stdController) {
		System.debug('Inside constructor TamsMainGraphsCTRL'); 
		ibID = stdController.getId();
		ibRecord = [SELECT id,NAME,Modality_ALL__c,nickname__c 
					FROM Install_Base_TAMS__c
				    WHERE ID=:ibID 
				    LIMIT 1];
		System.debug('ibRecord:'+ibRecord); 		    
	}

   public PageReference returnBack(){
   		System.debug('inside returnBack'); 
        PageReference retPage = new PageReference('/'+ibID); 
        retPage.setRedirect(true);
        return retPage;        
    }		
}