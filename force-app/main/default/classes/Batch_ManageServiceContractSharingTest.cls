@isTest
private class Batch_ManageServiceContractSharingTest {
    static testMethod void testFailureServiceContractShares() {
		test.startTest();
		
		//Make it fail
  		Batch_ManageServiceContractSharing oBatch = new Batch_ManageServiceContractSharing();
  		oBatch.bIsSuccess = false;
  		oBatch.sErrorMessage = 'test';
  		Database.executeBatch(oBatch);

		test.stopTest();
	}
    
    static testMethod void testFailureEmailServiceContractShares() {
		test.startTest();
		
		//Make it fail
  		Batch_ManageServiceContractSharing oBatch = new Batch_ManageServiceContractSharing();
  		oBatch.bIsSuccess = false;
  		oBatch.sErrorMessage = 'test';
  		Database.executeBatch(oBatch);

		test.stopTest();
	}
    
	static testMethod void testManageServiceContractSharing(){
		//Creating test PortalAccountOwner
		User oPortalAccountOwner = HelperClassTest.PortalAccountOwner();
		System.runAs(oPortalAccountOwner){
	        //Creating test Accounts with Contacts/Portal Users
	        Account oParentAccount = HelperClassTest.CreatePortalAccount('TestParentAccount', null, oPortalAccountOwner.Id);
	        Map<String, Contact> mParentContacts = HelperClassTest.CreatePortalAcctContacts(oParentAccount);
	        Map<String, User> mParentUsers = HelperClassTest.CreatePortalUsers(mParentContacts);
	        
	        Account oChildAccount = HelperClassTest.CreatePortalAccount('TestChildAccount', oParentAccount.Id, oPortalAccountOwner.Id);
	        Map<String, Contact> mChildContacts = HelperClassTest.CreatePortalAcctContacts(oChildAccount);
	        Map<String, User> mChildUsers = HelperClassTest.CreatePortalUsers(mChildContacts);
	        
	        //Creating a test equipment
	        Install_Base_TAMS__c oTestEquipment = HelperClassTest.CreateEquipment(oChildAccount);
	        //Creating a test contract
	        ServiceContract oTestContract = HelperClassTest.CreateContract(oChildAccount, mChildContacts.get('Admin'), oTestEquipment);
	        //Creating a test case
	        Case oTestCase = HelperClassTest.CreateCase(oChildAccount, oTestEquipment);
	        
	        //Creating an Affiliated User to the Account
	        Account oOtherAccount = HelperClassTest.CreatePortalAccount('TestOtherAccount', null, oPortalAccountOwner.Id);
	        Map<String, Contact> mOtherContacts = HelperClassTest.CreatePortalAcctContacts(oOtherAccount);
	        Map<String, User> mOtherUsers = HelperClassTest.CreatePortalUsers(mOtherContacts);
	        
	        TAMS_Affiliation__c newAffiliation = new TAMS_Affiliation__c();
	        newAffiliation.User__c = mOtherUsers.get('Admin').Id;
	        newAffiliation.Name = 'Affiliation';
	        newAffiliation.Account__c = oChildAccount.Id;
	        insert newAffiliation;
					
	        test.startTest();
	        Batch_ManageServiceContractSharing oBatchContract = new Batch_ManageServiceContractSharing();
	        oBatchContract.sServiceContractId = oTestContract.Id;
			Database.executeBatch(oBatchContract);
			test.stopTest();
		}
	}
}