/**
	* This test class will test the following batch classes:
	* Batch_ProcessAccountCaseShares, Batch_ProcessAccountContractShares and Batch_ProcessAccountShares.
 
	@author NTT Data: Louis Wooldridge
	@date Dec 2, 2015
 **/
@isTest
private class Batch_ProcessAccountSharesTest {
    static testMethod void testBatch_ProcessAccountCaseSharesSchedule() {
    	Test.startTest();
    	
   		Batch_ProcessAccountCaseSharesSchedule sch = new Batch_ProcessAccountCaseSharesSchedule();
   		sch.execute(null);
   		
   		Test.stopTest();
    }
    
    static testMethod void testFailureEmailAccountShares() {
		test.startTest();
		
		//Make it fail
  		Batch_ProcessAccountShares oBatch = new Batch_ProcessAccountShares();
  		oBatch.bIsSuccess = false;
  		oBatch.sErrorMessage = 'test';
  		Database.executeBatch(oBatch);

		test.stopTest();
	}
    
    static testMethod void testFailureEmailAccountCaseShares() {
		test.startTest();
		
		//Make it fail
  		Batch_ProcessAccountCaseShares oBatch = new Batch_ProcessAccountCaseShares();
  		oBatch.bIsSuccess = false;
  		oBatch.sErrorMessage = 'test';
  		Database.executeBatch(oBatch);

		test.stopTest();
	}
    
    static testMethod void testFailureEmailAccountContractShares() {
		test.startTest();
		
		//Make it fail
  		Batch_ProcessAccountContractShares oBatch = new Batch_ProcessAccountContractShares();
  		oBatch.bIsSuccess = false;
  		oBatch.sErrorMessage = 'test';
  		Database.executeBatch(oBatch);

		test.stopTest();
	}
    
	static testMethod void testUpdateAccountCaseShares(){
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
	        
	        Account oGrandChildAccount = HelperClassTest.CreatePortalAccount('TestGrandChildAccount', oChildAccount.Id, oPortalAccountOwner.Id);
	        Map<String, Contact> mGrandChildContacts = HelperClassTest.CreatePortalAcctContacts(oGrandChildAccount);
	        Map<String, User> mGrandChildUsers = HelperClassTest.CreatePortalUsers(mGrandChildContacts);
	        
	        //Creating a test equipment
	        Install_Base_TAMS__c oTestEquipment2 = HelperClassTest.CreateEquipment(oGrandChildAccount);
	        //Creating a test contract
	        ServiceContract oTestContract2 = HelperClassTest.CreateContract(oGrandChildAccount, mGrandChildContacts.get('Admin'), oTestEquipment2);
	        //Creating a test case
	        Case oTestCase2 = HelperClassTest.CreateCase(oGrandChildAccount, oTestEquipment2);
					
	        test.startTest();
	        Batch_ProcessAccountCaseShares oBatchCase = new Batch_ProcessAccountCaseShares();
	        oBatchCase.sAccountId = oChildAccount.Id;
			Database.executeBatch(oBatchCase);
			test.stopTest();
			
			//Confirming that 4 share records were created, 2 for parent account contacts to see child account
			//and 2 for the child account contacts to see the grandchild account
			List<CaseShare> lCaseSharesCreated = [Select Id From CaseShare Where CaseId = :oTestCase.Id And RowCause = 'Manual'];
			system.assertEquals(4, lCaseSharesCreated.size());
			
			//Confirming that 4 share records were created, 2 for parent account contacts to see child account
			//and 2 for the child account contacts to see the grandchild account
			List<CaseShare> lCaseSharesCreated2 = [Select Id From CaseShare Where CaseId = :oTestCase2.Id And RowCause = 'Manual'];
			system.assertEquals(2, lCaseSharesCreated2.size());
		}
	}
    
	static testMethod void testUpdateAccountContractShares(){
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
	        
	        Account oGrandChildAccount = HelperClassTest.CreatePortalAccount('TestGrandChildAccount', oChildAccount.Id, oPortalAccountOwner.Id);
	        Map<String, Contact> mGrandChildContacts = HelperClassTest.CreatePortalAcctContacts(oGrandChildAccount);
	        Map<String, User> mGrandChildUsers = HelperClassTest.CreatePortalUsers(mGrandChildContacts);
	        
	        //Creating a test equipment
	        Install_Base_TAMS__c oTestEquipment2 = HelperClassTest.CreateEquipment(oGrandChildAccount);
	        //Creating a test contract
	        ServiceContract oTestContract2 = HelperClassTest.CreateContract(oGrandChildAccount, mGrandChildContacts.get('Admin'), oTestEquipment2);
	        //Creating a test case
	        Case oTestCase2 = HelperClassTest.CreateCase(oGrandChildAccount, oTestEquipment2);
					
	        test.startTest();
	        Batch_ProcessAccountContractShares oBatchContract = new Batch_ProcessAccountContractShares();
	        oBatchContract.sAccountId = oChildAccount.Id;
			Database.executeBatch(oBatchContract);
			test.stopTest();
			
			//Confirming that 4 share records were created, 2 for parent account contacts to see child account
			//and 2 for the child account contacts to see the grandchild account
			List<ServiceContractShare> lContractSharesCreated = [Select Id From ServiceContractShare Where ParentId = :oTestContract.Id And RowCause = 'Manual'];
			system.assertEquals(4, lContractSharesCreated.size());
						
			//Confirming that 4 share records were created, 2 for parent account contacts to see child account
			//and 2 for the child account contacts to see the grandchild account
			List<ServiceContractShare> lContractSharesCreated2 = [Select Id From ServiceContractShare Where ParentId = :oTestContract2.Id And RowCause = 'Manual'];
			system.assertEquals(2, lContractSharesCreated2.size());
		}
	}
    
	static testMethod void testUpdateAccountShares(){
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
	        
	        Account oGrandChildAccount = HelperClassTest.CreatePortalAccount('TestGrandChildAccount', oChildAccount.Id, oPortalAccountOwner.Id);
	        Map<String, Contact> mGrandChildContacts = HelperClassTest.CreatePortalAcctContacts(oGrandChildAccount);
	        Map<String, User> mGrandChildUsers = HelperClassTest.CreatePortalUsers(mGrandChildContacts);
	        
	        //Creating a test equipment
	        Install_Base_TAMS__c oTestEquipment2 = HelperClassTest.CreateEquipment(oGrandChildAccount);
	        //Creating a test contract
	        ServiceContract oTestContract2 = HelperClassTest.CreateContract(oGrandChildAccount, mGrandChildContacts.get('Admin'), oTestEquipment2);
	        //Creating a test case
	        Case oTestCase2 = HelperClassTest.CreateCase(oGrandChildAccount, oTestEquipment2);
					
	        test.startTest();
	        Batch_ProcessAccountShares oBatch = new Batch_ProcessAccountShares();
	        oBatch.sAccountId = oChildAccount.Id;
			Database.executeBatch(oBatch);
			test.stopTest();
			
			//Confirming that 4 share records were created, 2 for parent account contacts to see child account
			//and 2 for the child account contacts to see the grandchild account
			List<AccountShare> lAccountSharesCreated = [Select Id From AccountShare Where AccountId = :oChildAccount.Id And RowCause = 'Manual'];
			system.assertEquals(4, lAccountSharesCreated.size());
		}
	}
}