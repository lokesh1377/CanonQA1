@isTest
private class Contact_TriggerHandlerTest {

    static testMethod void testUpdateAccountProcessShareFlag() {
    	Account oTestAccount1;
    	Map<String, Contact> mTestContacts1;
    	
		//Creating test PortalAccountOwner
		User oPortalAccountOwner = HelperClassTest.PortalAccountOwner();
		System.runAs(oPortalAccountOwner){
	        //Creating test Accounts with Contacts/Portal Users
	        oTestAccount1 = HelperClassTest.CreatePortalAccount('TestAccount1', null, oPortalAccountOwner.Id);
	        mTestContacts1 = HelperClassTest.CreatePortalAcctContacts(oTestAccount1);
	        //resetting Process Account Share Flag
	        oTestAccount1.Process_Account_Shares__c = false;
		}
		
		Map<String, User> mTestUsers1 = HelperClassTest.CreatePortalUsers(mTestContacts1);
        
        User oCurrentUser = [Select Id From User Where Id = :UserInfo.getUserId()];
        Contact oContact = mTestContacts1.get('Admin');
        oContact.Portal_User_Type__c = 'Standard';
        test.startTest();
    	System.runAs(oCurrentUser){
	        update oContact;
    	}
        test.stopTest();
        system.assertEquals(true, [Select Process_Account_Shares__c From Account Where Id = :oTestAccount1.Id].Process_Account_Shares__c);
    }
    
    static testMethod void testFrozenUser() {
    	Account oTestAccount1;
    	Map<String, Contact> mTestContacts1;
    	
		//Creating test PortalAccountOwner
		User oPortalAccountOwner = HelperClassTest.PortalAccountOwner();
		System.runAs(oPortalAccountOwner){
	        //Creating test Accounts with Contacts/Portal Users
	        oTestAccount1 = HelperClassTest.CreatePortalAccount('TestAccount1', null, oPortalAccountOwner.Id);
	        mTestContacts1 = HelperClassTest.CreatePortalAcctContacts(oTestAccount1);
		}
        
        Map<String, User> mTestUsers1 = HelperClassTest.CreatePortalUsers(mTestContacts1);
        
        test.startTest();
        User oCurrentUser = [Select Id From User Where Id = :UserInfo.getUserId()];
    	System.runAs(oCurrentUser){
	        //Asserts need to happen outside of start/stopTest so that @Future code executes and completes
	        Contact oContact = mTestContacts1.get('Standard');
	        oContact.Is_Frozen__c = true;
	        update oContact;
    	}
        test.stopTest();
        system.assertEquals(true, [Select IsFrozen From UserLogin Where UserId = :mTestUsers1.get('Standard').Id].IsFrozen);
    }
    
    static testMethod void testModalityGroups(){
    	Map<String, Id> mModalityGroupLookup = new Map<String, Id>();
    	for(Group oGroup : [Select Id, Name, DeveloperName From Group Where Type = 'Regular' And Name Like 'Modality%']){
    		mModalityGroupLookup.put(oGroup.Name.right(2), oGroup.Id);
    	}
    	system.assert(mModalityGroupLookup.size() > 1, 'There should be 6 Group records for each Modality: CT;MR;NM;UL;VL;XR');
    	
    	Account oTestAccount1;
    	Map<String, Contact> mTestContacts1;
    	
		//Creating test PortalAccountOwner
		User oPortalAccountOwner = HelperClassTest.PortalAccountOwner();
		System.runAs(oPortalAccountOwner){
	        //Creating test Accounts with Contacts/Portal Users
	        oTestAccount1 = HelperClassTest.CreatePortalAccount('TestAccount1', null, oPortalAccountOwner.Id);
	        mTestContacts1 = HelperClassTest.CreatePortalAcctContacts(oTestAccount1);
		}
        
        Map<String, User> mTestUsers1 = HelperClassTest.CreatePortalUsers(mTestContacts1);
        
        test.startTest();
        User oCurrentUser = [Select Id From User Where Id = :UserInfo.getUserId()];
    	System.runAs(oCurrentUser){
	        Contact oContact = mTestContacts1.get('Standard');
	        oContact.Modality__c = 'CT;MR;NM;UL;VL;XR';
	        update oContact;
	        //Testing removal of a Modality
	        oContact.Modality__c = 'CT;MR;NM;UL;VL';
	        update oContact;
    	}
    	test.stopTest();
    	//Asserts need to happen outside of start/stopTest so that @Future code executes and completes
        //GroupMember object to see if a record was created for each Group
        List<GroupMember> lMembers = [Select Id, GroupId, UserOrGroupId From GroupMember 
        	Where GroupId In:mModalityGroupLookup.values() And UserOrGroupId = :mTestUsers1.get('Standard').Id];
        system.assertEquals(5, lMembers.size());
    }
}