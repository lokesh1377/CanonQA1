@isTest
private class UserTriggerHandlerTest {

    static testMethod void testAdminPortalGroup() {
    	Map<String, Contact> mTestContacts1;
    	Group oAdminGroup;
    	
		//Creating test PortalAccountOwner
		User oPortalAccountOwner = HelperClassTest.PortalAccountOwner();
		System.runAs(oPortalAccountOwner){
	        //Creating test Accounts with Contacts/Portal Users
	        Account oTestAccount1 = HelperClassTest.CreatePortalAccount('TestAccount1', null, oPortalAccountOwner.Id);
	        mTestContacts1 = HelperClassTest.CreatePortalAcctContacts(oTestAccount1);
	        
	        oAdminGroup = [Select Id, Name, DeveloperName From Group 
			Where Type = 'Regular' And DeveloperName = 'Admin_Portal_Users' Limit 1];
		}
		Map<String, User> mTestUsers1 = HelperClassTest.CreatePortalUsers(mTestContacts1);
		
        test.startTest();
        //Confirming Admin user got added to the group
        List<GroupMember> lAdminMembers = [Select Id From GroupMember Where GroupId = :oAdminGroup.Id And UserOrGroupId = :mTestUsers1.get('Admin').Id];
        system.assertEquals(1, lAdminMembers.size());
        //Updating Admin user to Standard User profile, confirming that User was removed from group
        User oAdminUser = mTestUsers1.get('Admin');
        oAdminUser.ProfileId = [Select ProfileId From User Where Id = :mTestUsers1.get('Standard').Id].ProfileId;
        update oAdminUser;
        test.stopTest();
        lAdminMembers.clear();
        lAdminMembers = [Select Id From GroupMember Where GroupId = :oAdminGroup.Id And UserOrGroupId = :mTestUsers1.get('Admin').Id];
        system.assertEquals(0, lAdminMembers.size());
    }
    
    static testMethod void testAccountContactUpdates() {
    	Account oTestAccount1;
    	Map<String, Contact> mTestContacts1;
    	
        test.startTest();
		//Creating test PortalAccountOwner
		User oPortalAccountOwner = HelperClassTest.PortalAccountOwner();
		System.runAs(oPortalAccountOwner){
	        //Creating test Accounts with Contacts/Portal Users
	        oTestAccount1 = HelperClassTest.CreatePortalAccount('TestAccount1', null, oPortalAccountOwner.Id);
	        mTestContacts1 = HelperClassTest.CreatePortalAcctContacts(oTestAccount1);
		}
        Map<String, User> mTestUsers1 = HelperClassTest.CreatePortalUsers(mTestContacts1);
        test.stopTest();
        
        /*
        //Confirming Account Process Share flag was updated
        Account oAccount = [Select Process_Account_Shares__c From Account Where Id = :oTestAccount1.Id];
        system.assertEquals(true, oAccount.Process_Account_Shares__c);
        //Confirming Portal User Type field was updated on related Contact records
        Contact oAdminContact = [Select Portal_User_Type__c From Contact Where Id = :mTestContacts1.get('Admin').Id];
        system.assertEquals('Admin', oAdminContact.Portal_User_Type__c);
        Contact oStandardContact = [Select Portal_User_Type__c From Contact Where Id = :mTestContacts1.get('Standard').Id];
        system.assertEquals('Standard', oStandardContact.Portal_User_Type__c);
        */
    }
}