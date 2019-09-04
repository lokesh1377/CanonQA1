@isTest
private class NewCaseInstallBaseExtTest {

    static testMethod void testNewCase() {
    	Map<String, Contact> mTestContacts;
    	Install_Base_TAMS__c oTestEquipment;
    	
		//Creating test PortalAccountOwner
		User oPortalAccountOwner = HelperClassTest.PortalAccountOwner();
		System.runAs(oPortalAccountOwner){
	        //Creating test Accounts with Contacts/Portal Users
	        Account oTestAccount = HelperClassTest.CreatePortalAccount('TestAccount', null, oPortalAccountOwner.Id);
	        mTestContacts = HelperClassTest.CreatePortalAcctContacts(oTestAccount);
	        //Creating a test equipment
	        oTestEquipment = new Install_Base_TAMS__c(Name='Test', Account_Name__c=oTestAccount.Id);
	        insert oTestEquipment;
		}
        Map<String, User> mTestUsers = HelperClassTest.CreatePortalUsers(mTestContacts);
    	
    	system.runAs(mTestUsers.get('Standard')){
	    	test.startTest();
	    	ApexPages.StandardController oController = new ApexPages.StandardController(oTestEquipment);
	    	NewCaseInstallBaseExt oNewCaseExt = new NewCaseInstallBaseExt(oController);
	    	PageReference oNewCase = new PageReference('/apex/NewCaseInstallBase');
	    	test.setCurrentPage(oNewCase);
	    	oNewCaseExt.getRecordTypes();
	    	oNewCaseExt.SaveCase();
	    	oNewCaseExt.CancelCase();
	    	test.stopTest();
    	}
    }
}