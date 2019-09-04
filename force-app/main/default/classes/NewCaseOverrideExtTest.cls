@isTest
private class NewCaseOverrideExtTest {

    static testMethod void testNewCasePortalUser() {
    	Map<String, Contact> mTestContacts;
    	Case oTestCase;
    	
		//Creating test PortalAccountOwner
		User oPortalAccountOwner = HelperClassTest.PortalAccountOwner();
		System.runAs(oPortalAccountOwner){
	        //Creating test Accounts with Contacts/Portal Users
	        Account oTestAccount = HelperClassTest.CreatePortalAccount('TestAccount', null, oPortalAccountOwner.Id);
	        mTestContacts = HelperClassTest.CreatePortalAcctContacts(oTestAccount);
	        HelperClassTest.CreateGeneralInquiryRecTypeSettings();
	        //Creating a test case
	        oTestCase = new Case();
		}
        Map<String, User> mTestUsers = HelperClassTest.CreatePortalUsers(mTestContacts);
    	
    	system.runAs(mTestUsers.get('Standard')){
	    	test.startTest();
	    	ApexPages.StandardController oController = new ApexPages.StandardController(oTestCase);
	    	NewCaseOverrideExt oNewCase = new NewCaseOverrideExt(oController);
	    	PageReference oNewCasePage = new PageReference('/apex/NewCaseOverride');
	    	test.setCurrentPage(oNewCasePage);
	    	oNewCase.getRecordTypes();
	    	oNewCase.SaveCase();
	    	oNewCase.CancelCase();
	    	test.stopTest();
    	}
    }

    static testMethod void testNewCaseInternalUser() {
        //Creating test User
        Profile p = [select id from profile where name='Standard User'];
        User oTestUser = new User(alias='stnd', email='testNewCase@test.com', profileid=p.Id,
            emailencodingkey='UTF-8', firstname='Standard', lastname='lastname', languagelocalekey='en_US', 
            localesidkey='en_US', 
            timezonesidkey='America/Los_Angeles', username='testNewCase@test.com');
		insert oTestUser;
		
        HelperClassTest.CreateGeneralInquiryRecTypeSettings();
    	
    	system.runAs(oTestUser){
	        //Creating a test case
	        Case oTestCase = new Case();
	        
	    	test.startTest();
	    	ApexPages.StandardController oController = new ApexPages.StandardController(oTestCase);
	    	NewCaseOverrideExt oNewCase = new NewCaseOverrideExt(oController);
	    	PageReference oNewCasePage = new PageReference('/apex/NewCaseOverride');
	    	test.setCurrentPage(oNewCasePage);
	    	oNewCase.getRecordTypes();
	    	oNewCase.SaveCase();
	    	test.stopTest();
    	}
    }
}