/**
  * Controller Class object for Visualforce page.
  *
  * Used By: AdminTab
  * 
  * @author NTT Data: Louis Wooldridge
  * @date August 6, 2015
  *
  * @update
  */
public class AdminTabController {
	private static String sUserRequestRT = Schema.SObjectType.Case.getRecordTypeInfosByName().get('New User Request').getRecordTypeId();
	private Account oPrimaryAccount = new Account();
	private Contact oContact = new Contact();
	private Map<Id, String> mAllChildAccounts = new Map<Id, String>();
	private Map<Id, List<Contact>> mLookupAcctContactList = new Map<Id, List<Contact>>();
	public List<Contact> lAccountContacts {get; set;}
	public String sSelectedAccountId {get; set;}
	
	public AdminTabController(){
	try{
        List<User> lUsers = [Select Name, Contact.AccountId, ContactId From User Where Id = :UserInfo.getUserId()];
        if(lUsers.isEmpty() == false){
        	if(lUsers[0].ContactId != null){
    			oPrimaryAccount = [Select Id, Name,
        			(Select Id, Name, Modality__c, Is_Frozen__c From Contacts 
        				Where Portal_User_Type__c = 'Standard') 
        	 		From Account Where Id = :lUsers[0].Contact.AccountId];
        	 		
    			mLookupAcctContactList.put(oPrimaryAccount.Id, oPrimaryAccount.Contacts);
    			sSelectedAccountId = oPrimaryAccount.Id;
    			oContact = [Select Id, Name From Contact Where Id = :lUsers[0].ContactId];
        	}
        }
        
    	RetrieveAllChildAccounts();
    	RetrieveAffiliationAccounts();
    	RetrieveAccountContacts();
	
	}catch(Exception e){ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'Error: ' + e.getMessage()));}
    }
    
    public PageReference Cancel(){
    	PageReference oHome = new PageReference('/home/home.jsp');
        oHome.setRedirect(true);
        return oHome;
    }
    
    public PageReference NewUserRequest(){
        PageReference oNewCasePage = new PageReference('/500/e?nooverride=1&retURL=apex/AdminTab&RecordType='
            + sUserRequestRT + '&cas4=' + oPrimaryAccount.Name + '&cas3=' + oContact.Name);
        oNewCasePage.setRedirect(true);
        
        return oNewCasePage;
    }
    
    public List<SelectOption> getUserAccountOptions(){
        List<SelectOption> lOptions = new List<SelectOption>();
        if((oPrimaryAccount.Id != null)&&(oPrimaryAccount.Name != null)){
	        lOptions.add(new SelectOption(oPrimaryAccount.Id, '*' + oPrimaryAccount.Name + '*'));
	        for(Id idAccount : mAllChildAccounts.keySet()){
	        	lOptions.add(new SelectOption(idAccount, mAllChildAccounts.get(idAccount)));
	        }
        }
        
        return lOptions;
    }
    
    public PageReference Save(){
	try{
    	List<Contact> lUpdateContacts = new List<Contact>();
    	for(String sAcctId : mLookupAcctContactList.keySet()){
    		lUpdateContacts.addAll(mLookupAcctContactList.get(sAcctId));
    	}
    	
    	if(lUpdateContacts.isEmpty() == false){
    		update lUpdateContacts;
    	}
    	return Cancel();
    }catch(Exception e){ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'Error: ' + e.getMessage()));return null;}
	}
    
    public void RetrieveAccountContacts(){
		lAccountContacts = mLookupAcctContactList.get(sSelectedAccountId);
    }
    
    private void RetrieveAffiliationAccounts(){
	try{
    	List<Id> lAcctIds = new List<Id>();
    	for(TAMS_Affiliation__c oAffiliation : [Select Account__c, Account__r.Name
    	From TAMS_Affiliation__c Where User__c = :UserInfo.getUserId()]){
    		mAllChildAccounts.put(oAffiliation.Account__c, oAffiliation.Account__r.Name);
    		lAcctIds.add(oAffiliation.Account__c);
    	}
    	
    	for(Account oAccount : [Select Id,
		(Select Id, Name, Modality__c, Is_Frozen__c From Contacts 
		Where Portal_User_Type__c = 'Standard') From Account Where Id In:lAcctIds]){
			mLookupAcctContactList.put(oAccount.Id, oAccount.Contacts);
		}
    }catch(Exception e){ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'Error: ' + e.getMessage()));}
	}
    
    private void RetrieveAllChildAccounts(){
	try{
    	if(oPrimaryAccount.Id != null){
	    	Set<Id> sAcctQueryIds = new Set<Id>();
	    	Boolean bFoundAllChildren = false;
	    	
	    	sAcctQueryIds.add(oPrimaryAccount.Id);
    		
	    	while(bFoundAllChildren == false){
	    		List<Account> lAccounts = new List<Account>([Select Id, Name,
	    			(Select Id, Name From ChildAccounts),
					(Select Id, Name, Modality__c, Is_Frozen__c From Contacts 
					Where Portal_User_Type__c = 'Standard')
	    			From Account Where ParentId In:sAcctQueryIds]);
    			
	    		if(lAccounts.isEmpty() == true){
		    		bFoundAllChildren = true;
	    		}else{
	    			sAcctQueryIds.clear();
	    			
			    	for(Account oAccount : lAccounts){
			    		mLookupAcctContactList.put(oAccount.Id, oAccount.Contacts);
			    		mAllChildAccounts.put(oAccount.Id, oAccount.Name);
			    		if(oAccount.ChildAccounts.isEmpty() == false){
			    			sAcctQueryIds.clear();
				    		for(Account oChildAcct : oAccount.ChildAccounts){
				    			sAcctQueryIds.add(oChildAcct.Id);
				    		}
			    		}else{
			    			bFoundAllChildren = true;
			    		}
			    	}
	    		}
	    	}
    	}
    }catch(Exception e){ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'Error: ' + e.getMessage()));}
	}
}