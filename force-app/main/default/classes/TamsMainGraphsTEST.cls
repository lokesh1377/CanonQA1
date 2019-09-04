@isTest
public class TamsMainGraphsTEST {
	public static testMethod void testMainGraph() {
		PageReference mainPage = Page.TamsMainGraphsVF;
		Test.setCurrentPage(mainPage);
		Account a = new Account();
        a.Name = 'Test';        
        insert a;

        Id RecTypeCIB = 
        	[Select 
        		Id  
        	 From 
        	 	RecordType 
        	 Where 
        	 	SobjectType = 'Install_Base_TAMS__c' 
        	 And IsActive = true 
        	 And Name = 'Competitor Install Base'].Id;
        
        Account acc = new Account(Name = 'Test Account');
        insert acc;

        Install_Base_TAMS__c ib = new Install_Base_TAMS__c
        										(Account_Name__c = acc.Id, 
        										 Modality_ALL__c = 'MR', 
        										 Manufacturer_ALL__c = 'GE', 
        										 Active_IB__c = true,
        										 RecordTypeId = RecTypeCIB,
        										 Nickname__c = 'Test',
        										 Name = 'Test',
        										 Install_Year_Comp__c = '2012');
		insert ib;        										
		System.debug('IB:'+ib); 
		System.debug('Nickname__c:'+ib.Nickname__c);
		ApexPages.currentPage().getParameters().put('ID', ib.ID);
		ApexPages.StandardController stdCont = new ApexPages.StandardController(ib); 
		TamsMainGraphsCTRL mainCTRL = new TamsMainGraphsCTRL(stdCont);
		System.assert(ib.id == mainCTRL.ibRecord.id);
		PageReference retPage = mainCTRL.returnBack();
		String retURL = retPage.getUrl();
		System.debug('retURL:'+retURL); 
		System.assert(retURL == '/'+ib.id);
	}
}