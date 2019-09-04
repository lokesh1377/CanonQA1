@isTest
private class HomePageComponentListViewsControllerTest {

    static testMethod void testListViews() {
    	Map<String, Contact> mTestContacts;
    	
		//Creating test PortalAccountOwner
		User oPortalAccountOwner = HelperClassTest.PortalAccountOwner();
		System.runAs(oPortalAccountOwner){
	        //Creating test Accounts with Contacts/Portal Users
	        Account oTestAccount = HelperClassTest.CreatePortalAccount('TestAccount', null, oPortalAccountOwner.Id);
	        mTestContacts = HelperClassTest.CreatePortalAcctContacts(oTestAccount);
		}
        Map<String, User> mTestUsers = HelperClassTest.CreatePortalUsers(mTestContacts);
        
        system.runAs(mTestUsers.get('Standard')){
	        test.startTest();
	    	PageReference oListViews = new PageReference('/apex/HomePageComponentListViews');
	    	test.setCurrentPage(oListViews);
	    	HomePageComponentListViewsController oListViewController = new HomePageComponentListViewsController();
	    	test.stopTest();
        }
    }
}