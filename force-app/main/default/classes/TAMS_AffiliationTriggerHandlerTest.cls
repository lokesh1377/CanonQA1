@isTest
private class TAMS_AffiliationTriggerHandlerTest {
	
	static testMethod void testDeleteAffiliations(){
		Account oTestAccount;
		Account oTestAccount2;
		Map<String, Contact> mTestContacts;
		ServiceContract oTestContract;
		Case oTestCase;
		
		//Creating test PortalAccountOwner
		User oPortalAccountOwner = HelperClassTest.PortalAccountOwner();
		System.runAs(oPortalAccountOwner){
			//Creating test Accounts with Contacts/Portal Users
	        oTestAccount = HelperClassTest.CreatePortalAccount('TestAccount1', null, oPortalAccountOwner.Id);
	        mTestContacts = HelperClassTest.CreatePortalAcctContacts(oTestAccount);
	        oTestAccount2 = HelperClassTest.CreatePortalAccount('TestAccount2', null, oPortalAccountOwner.Id);
	        
	        //Creating a test equipment
	        Install_Base_TAMS__c oTestEquipment = HelperClassTest.CreateEquipment(oTestAccount2);
	        //Creating a test contract
	        oTestContract = HelperClassTest.CreateContract(oTestAccount2, mTestContacts.get('Admin'), oTestEquipment);
	        //Creating a test case
	        oTestCase = HelperClassTest.CreateCase(oTestAccount2, oTestEquipment);
		}
        Map<String, User> mTestUsers = HelperClassTest.CreatePortalUsers(mTestContacts);
        
        test.startTest();
		System.runAs(oPortalAccountOwner){
	        TAMS_Affiliation__c oNewAffiliation = HelperClassTest.CreateAffiliation(oTestAccount2, mTestUsers.get('Admin'));
	        //Confirming AccountShare was created
	        List<AccountShare> lShares = [Select Id From AccountShare Where UserOrGroupId = :mTestUsers.get('Admin').Id And AccountId = :oTestAccount2.Id And RowCause = 'Manual'];
	        system.assertEquals(1, lShares.size());
	        //Confirming CaseShare was created
	        List<CaseShare> lCaseShares = [Select Id From CaseShare Where CaseId = :oTestCase.Id And UserOrGroupId = :mTestUsers.get('Admin').Id And RowCause = 'Manual']; 
	        system.assertEquals(1, lCaseShares.size());
	        //Confirming updated ContractShare was added
	        List<ServiceContractShare> lContractShares = [Select Id From ServiceContractShare Where ParentId = :oTestContract.Id And UserOrGroupId = :mTestUsers.get('Admin').Id And RowCause = 'Manual']; 
	        system.assertEquals(1, lContractShares.size());
	        
	        delete oNewAffiliation;
	        
	        //Confirming AccountShare was deleted
	        List<AccountShare> lShares_Del = [Select Id From AccountShare Where UserOrGroupId = :mTestUsers.get('Admin').Id And AccountId = :oTestAccount2.Id And RowCause = 'Manual'];
	        system.assertEquals(0, lShares_Del.size());
	        //Confirming CaseShare was deleted
	        List<CaseShare> lCaseShares_Del = [Select Id From CaseShare Where CaseId = :oTestCase.Id And UserOrGroupId = :mTestUsers.get('Admin').Id And RowCause = 'Manual']; 
	        system.assertEquals(0, lCaseShares_Del.size());
	        //Confirming updated ContractShare was deleted
	        List<ServiceContractShare> lContractShares_Del = [Select Id From ServiceContractShare Where ParentId = :oTestContract.Id And UserOrGroupId = :mTestUsers.get('Admin').Id And RowCause = 'Manual']; 
	        system.assertEquals(0, lContractShares_Del.size());
		}
        test.stopTest();
	}

    static testMethod void testAffiliations() {
		Account oTestAccount1;
		Account oTestAccount12;
		Account oTestAccount2;
		Map<String, Contact> mTestContacts1;
		Map<String, Contact> mTestContacts12;
		ServiceContract oTestContract;
		Case oTestCase;
		TAMS_Affiliation__c oNewAffiliation;
		
		//Creating test PortalAccountOwner
		User oPortalAccountOwner = HelperClassTest.PortalAccountOwner();
		System.runAs(oPortalAccountOwner){
	        //Creating test Accounts with Contacts/Portal Users
	        oTestAccount1 = HelperClassTest.CreatePortalAccount('TestAccount1', null, oPortalAccountOwner.Id);
	        mTestContacts1 = HelperClassTest.CreatePortalAcctContacts(oTestAccount1);
	        //Creating second set of Portal Users for the Account
	        oTestAccount12 = HelperClassTest.CreatePortalAccount('TestAccount12', null, oPortalAccountOwner.Id);
	        mTestContacts12 = HelperClassTest.CreatePortalAcctContacts(oTestAccount12);
	        oTestAccount2 = HelperClassTest.CreatePortalAccount('TestAccount2', null, oPortalAccountOwner.Id);
	        
	        //Creating a test equipment
	        Install_Base_TAMS__c oTestEquipment = HelperClassTest.CreateEquipment(oTestAccount2);
	        
	        //Creating a test contract
	        oTestContract = HelperClassTest.CreateContract(oTestAccount2, mTestContacts1.get('Admin'), oTestEquipment);
			
	        //Creating a test case
	        oTestCase = HelperClassTest.CreateCase(oTestAccount2, oTestEquipment);
		}
        Map<String, User> mTestUsers1 = HelperClassTest.CreatePortalUsers(mTestContacts1);
        Map<String, User> mTestUsers12 = HelperClassTest.CreatePortalUsers(mTestContacts12);
        
        test.startTest();
		System.runAs(oPortalAccountOwner){
        	oNewAffiliation = HelperClassTest.CreateAffiliation(oTestAccount2, mTestUsers1.get('Admin'));
        	
	        //Checking to see if Contact__c field was updated to the related Contact record for the User record
	        system.assertEquals(mTestContacts1.get('Admin').Id, [Select Contact__c From TAMS_Affiliation__c Where Id = :oNewAffiliation.Id].Contact__c);
	        //Confirming AccountShare was created
	        List<AccountShare> lShares = [Select Id From AccountShare Where UserOrGroupId = :mTestUsers1.get('Admin').Id And AccountId = :oTestAccount2.Id And RowCause = 'Manual'];
	        system.assertEquals(1, lShares.size());
	        //Confirming CaseShare was created
	        List<CaseShare> lCaseShares = [Select Id From CaseShare Where CaseId = :oTestCase.Id And UserOrGroupId = :mTestUsers1.get('Admin').Id And RowCause = 'Manual']; 
	        system.assertEquals(1, lCaseShares.size());
	        //Confirming updated ContractShare was added
	        List<ServiceContractShare> lContractShares = [Select Id From ServiceContractShare Where ParentId = :oTestContract.Id And UserOrGroupId = :mTestUsers1.get('Admin').Id And RowCause = 'Manual']; 
	        system.assertEquals(1, lContractShares.size());
	        
	        oNewAffiliation.User__c = mTestUsers12.get('Admin').Id;
	        update oNewAffiliation;
	        //Checking to see if Contact__c field was updated to the related Contact record for the User record
	        system.assertEquals(mTestContacts12.get('Admin').Id, [Select Contact__c From TAMS_Affiliation__c Where Id = :oNewAffiliation.Id].Contact__c);
	        //Confirming AccountShare was removed
	        List<AccountShare> lOriginalShares = [Select Id From AccountShare Where UserOrGroupId = :mTestUsers1.get('Admin').Id And AccountId = :oTestAccount2.Id And RowCause = 'Manual'];
	        system.assertEquals(0, lOriginalShares.size());
	        //Confirming updated AccountShare was added
	        List<AccountShare> lUpdatedShares = [Select Id From AccountShare Where UserOrGroupId = :mTestUsers12.get('Admin').Id And AccountId = :oTestAccount2.Id And RowCause = 'Manual'];
	        system.assertEquals(1, lUpdatedShares.size());
	        
	        delete oNewAffiliation;
	        //Confirming AccountShare was deleted
	        List<AccountShare> lDeletedShares = [Select Id From AccountShare Where AccountId = :oTestAccount2.Id And RowCause = 'Manual'
	        	And (UserOrGroupId = :mTestUsers1.get('Admin').Id Or UserOrGroupId = :mTestUsers12.get('Admin').Id)];
	        system.assertEquals(0, lDeletedShares.size());
	        
	        //Inserting Affiliation for Standard User to get code coverage
	        TAMS_Affiliation__c oNewAffiliationStandard = new TAMS_Affiliation__c();
	        oNewAffiliationStandard.User__c = mTestUsers1.get('Standard').Id;
	        oNewAffiliationStandard.Account__c = oTestAccount2.Id;
	        insert oNewAffiliationStandard;
		}
        test.stopTest();
    }
}