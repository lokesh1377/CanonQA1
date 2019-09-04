/**
  * Controller Class object for Visualforce page.
  *
  * Used By: HomePageComponentListViews
  * 
  * @author NTT Data: Louis Wooldridge
  * @date July 9, 2015
  *
  * @update
  */
public class HomePageComponentListViewsController {
	public List<Case> lCases {get; set;}
	public List<Install_Base_TAMS__c> lInstallBaseItems {get; set;}
	
	public HomePageComponentListViewsController(){
	try{
		lCases = [Select Id, Subject, CaseNumber, Status, Type, SID__c, Oracle_SR_Number_TAMS__c, Nickname__c 
			From Case Where LastViewedDate != null Order By LastViewedDate desc Limit 5];
		
		List<User> lUsers = [Select Contact.AccountId, ContactId, AccountId From User Where Id = :UserInfo.getUserId()];
		if(lUsers[0].Contact.AccountId != null){
			lInstallBaseItems = [Select Id, Name, Nickname__c, Class__c, Status__c, Type__c, Product_Image__c 
				From Install_Base_TAMS__c Where Account_Name__c = :lUsers[0].AccountId 
				And LastViewedDate != null Order By LastViewedDate desc Limit 5];
		}
	}catch(Exception e){ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'Error: ' + e.getMessage()));}
	}
}