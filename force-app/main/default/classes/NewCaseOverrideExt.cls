/**
  * Extension Class object for Visualforce page.
  *
  * Used By: NewCaseOverride
  * 
  * @author NTT Data: Louis Wooldridge
  * @date July 7, 2015
  *
  * @update
  */
public class NewCaseOverrideExt {
    //The store record accessed through the standard controller
    public Case oCase {get; set;}
    private List<RecordType> lRecordTypes = new List<RecordType>();
    
    private void LoadRecordTypes(){
	try{
    	GeneralInquiryRT__c oRecordTypeSettings = GeneralInquiryRT__c.getInstance(UserInfo.getProfileId());
		String sRecordTypeNames = oRecordTypeSettings.Record_Type_Developer_Name_List__c;
    	
    	if(String.isEmpty(sRecordTypeNames) == false){
    		List<String> lRecordTypeNames = sRecordTypeNames.split(',');
    		
	        BusinessProcess oProcess = [Select Id From BusinessProcess Where Name = 'General Inquiries'];
	        for(RecordType oRecType : [Select Id, Name, DeveloperName From RecordType Where SobjectType = 'Case' 
	        And BusinessProcessId = :oProcess.Id And DeveloperName In:lRecordTypeNames]){
	            lRecordTypes.add(oRecType);
	        }
    	}
    	
    }catch(Exception e){ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'Error: ' + e.getMessage()));}
	}
    
    private Map<String, String> RetrieveUserInfo(){
	try{
        Map<String, String> mReturnValue = new Map<String, String>();
        mReturnValue.put('Account', '');
        mReturnValue.put('Contact', '');
        
        List<User> lUsers = [Select ContactId From User Where Id = :UserInfo.getUserId()];
        if(lUsers.isEmpty() == false){
        	if(lUsers[0].ContactId != null){
	        	Contact oContact = [Select Account.Name, Name From Contact Where Id = :lUsers[0].ContactId];
	            mReturnValue.put('Account', oContact.Account.Name);
	            mReturnValue.put('Contact', oContact.Name);
        	}
        }
        
        return mReturnValue;
        
    }catch(Exception e){ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'Error: ' + e.getMessage())); return null;}
	}
    
    public NewCaseOverrideExt(ApexPages.StandardController stdController){
        oCase = (Case)stdController.getRecord();
        LoadRecordTypes();
    }
    
    public PageReference SaveCase(){
	try{
        Map<String, String> mUserInfo = RetrieveUserInfo();
        
        PageReference oNewCasePage;
        oNewCasePage = new PageReference('/500/e?nooverride=1&retURL=500&RecordType=' 
            + oCase.RecordTypeId + '&cas4=' + mUserInfo.get('Account') + '&cas3=' + mUserInfo.get('Contact'));
        
        oNewCasePage.setRedirect(true);
        return oNewCasePage;
        
    }catch(Exception e){ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'Error: ' + e.getMessage())); return null;}
	}
    
    public PageReference CancelCase(){
        PageReference oNewCasePage = new PageReference('/500/o');
        oNewCasePage.setRedirect(true);
        return oNewCasePage;
    }
    
    public List<SelectOption> getRecordTypes(){
        List<SelectOption> options = new List<SelectOption>();
        for(RecordType oRecType : lRecordTypes){
            options.add(new SelectOption(oRecType.Id,oRecType.Name));
        }
        return options;
    }
}