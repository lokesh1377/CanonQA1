@isTest
private class AdminTabControllerTest {

    static testMethod void testAdminPage() {
    	Map<String, Contact> mParentContacts;
    	Map<String, Contact> mChildContacts;
    	Map<String, Contact> mAffiliateContacts;
    	Account oChildAccount;
    	Account oAffiliateAccount;
    	
		//Creating test PortalAccountOwner
		User oPortalAccountOwner = HelperClassTest.PortalAccountOwner();
		System.runAs(oPortalAccountOwner){
	    	List<Account> lUpdateAccounts = new List<Account>();
	        //Creating test Accounts with Contacts/Portal Users
	        Account oParentAccount = HelperClassTest.CreatePortalAccount('ParentAccountTest', null, oPortalAccountOwner.Id);
	        //Upating Process Share flag, because this is @future call in the User Trigger
	        oParentAccount.Process_Account_Shares__c =  true;
	        lUpdateAccounts.add(oParentAccount);
	        mParentContacts = HelperClassTest.CreatePortalAcctContacts(oParentAccount);
			
	        oChildAccount = HelperClassTest.CreatePortalAccount('ChildAccountTest', oParentAccount.Id, oPortalAccountOwner.Id);
	        //Upating Process Share flag, because this is @future call in the User Trigger
	        oChildAccount.Process_Account_Shares__c =  true;
	        lUpdateAccounts.add(oChildAccount);
	        mChildContacts = HelperClassTest.CreatePortalAcctContacts(oChildAccount);
	        //Updating Accounts
	        update lUpdateAccounts;
	        
	        //Creating test Affiliate Account with Contacts/Portal Users
	        oAffiliateAccount = HelperClassTest.CreatePortalAccount('AffiliateAccountTest', null, oPortalAccountOwner.Id);
	        mAffiliateContacts = HelperClassTest.CreatePortalAcctContacts(oAffiliateAccount);
		}
		
		Map<String, User> mParentUsers = HelperClassTest.CreatePortalUsers(mParentContacts);
		Map<String, User> mChildUsers = HelperClassTest.CreatePortalUsers(mChildContacts);
		Map<String, User> mAffiliateUsers = HelperClassTest.CreatePortalUsers(mAffiliateContacts);
		
		System.runAs(oPortalAccountOwner){
        	HelperClassTest.CreateAffiliation(oAffiliateAccount, mParentUsers.get('Admin'));
        	HelperClassTest.CreateAccountShares(oChildAccount, mParentUsers);
		}
        
        system.runAs(mParentUsers.get('Admin')){
        	test.startTest();
        	PageReference oAdminPage = new PageReference('/apex/AdminTab');
        	test.setCurrentPage(oAdminPage);
        	AdminTabController oAdminPageController = new AdminTabController();
        	List<SelectOption> lAccountOptions = oAdminPageController.getUserAccountOptions();
        	//Checking to see if the Parent, Child & Affiliate Accounts were added to the pick-list
        	system.assertEquals(3, lAccountOptions.size());
        	oAdminPageController.RetrieveAccountContacts();
        	oAdminPageController.Save();
        	oAdminPageController.NewUserRequest();
        	oAdminPageController.Cancel();
        	test.stopTest();
        }
    }
}