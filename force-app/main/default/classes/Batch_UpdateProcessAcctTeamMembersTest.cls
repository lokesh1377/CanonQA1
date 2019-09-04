@isTest
private class Batch_UpdateProcessAcctTeamMembersTest {
    static testMethod void testBatch_UpdateProcessAcctTeamMembersSched() {
    	Test.startTest();
    	
   		Batch_UpdateProcessAcctTeamMembersSched sch = new Batch_UpdateProcessAcctTeamMembersSched();
   		sch.execute(null);
   		
   		Test.stopTest();
    }
    
    static testMethod void testFailureEmail() {
		test.startTest();
		
		//Make it fail
  		Batch_UpdateProcessAccountTeamMembers oBatch = new Batch_UpdateProcessAccountTeamMembers();
  		oBatch.bIsSuccess = false;
  		oBatch.sErrorMessage = 'test';
  		Database.executeBatch(oBatch);

		test.stopTest();
	}
    
    static testMethod void testUpdateAccountTeamMembersUS() {
    	Territory2 oMainTerritory;
    	
		//Creating test PortalAccountOwner
		User oPortalAccountOwner = HelperClassTest.PortalAccountOwner();
		System.runAs(oPortalAccountOwner){
	    	//Creating test Accounts with Contacts/Portal Users
	        Account oParentAccount = HelperClassTest.CreatePortalAccount('TestParentAccount', null, oPortalAccountOwner.Id);
	    	//Creating test US Territories
			 List<Territory2Model> territorymodel = [Select Id from Territory2Model Limit 1];
             List<Territory2Type> territorytype = [Select Id from Territory2Type Limit 1];

	    	Territory2 oParentMainTerritory = new Territory2();
	    	oParentMainTerritory.Name = 'US.Test Main Parent';
	    	oParentMainTerritory.DeveloperName = 'US_Test_Main_Parent';
	    	oParentMainTerritory.CaseAccessLevel = 'Edit';
	    	oParentMainTerritory.AccountAccessLevel = 'Edit';
			oParentMainTerritory.Territory2ModelId = territorymodel.get(0).id;
			oParentMainTerritory.Territory2TypeId = territorytype.get(0).id;
	    	insert oParentMainTerritory;
	    	
	    	oMainTerritory = new Territory2();
	    	oMainTerritory.Name = 'US.Test Main';
	    	oMainTerritory.DeveloperName = 'US_Test_Main';
	    	oMainTerritory.CaseAccessLevel = 'Edit';
	    	oMainTerritory.AccountAccessLevel = 'Edit';
	    	oMainTerritory.ParentTerritory2Id = oParentMainTerritory.Id;
			oMainTerritory.Territory2ModelId = territorymodel.get(0).id;
			oMainTerritory.Territory2TypeId = territorytype.get(0).id;
	    	insert oMainTerritory;
	    	
	    	oParentAccount.Territory_Name_TAMS__c = 'US.Test Main';
	    	update oParentAccount;
		}
    	
    	test.startTest();
    	Batch_UpdateProcessAccountTeamMembers oBatch = new Batch_UpdateProcessAccountTeamMembers();
    	oBatch.sTerritoryId = oMainTerritory.Id;
		Database.executeBatch(oBatch, 1);
    	test.stopTest();
    }
    
    static testMethod void testUpdateAccountTeamMembersUL() {
    	Territory2 oMainTerritory;
    	
		//Creating test PortalAccountOwner
		User oPortalAccountOwner = HelperClassTest.PortalAccountOwner();
		System.runAs(oPortalAccountOwner){
	    	//Creating test Accounts with Contacts/Portal Users
	        Account oParentAccount = HelperClassTest.CreatePortalAccount('TestParentAccount', null, oPortalAccountOwner.Id);
	    	//Creating test US Territories
			List<Territory2Model> territorymodel = [Select Id from Territory2Model Limit 1];
             List<Territory2Type> territorytype = [Select Id from Territory2Type Limit 1];

	    	Territory2 oParentMainTerritory = new Territory2();
	    	oParentMainTerritory.Name = 'UL.Test Main Parent';
	    	oParentMainTerritory.DeveloperName = 'UL_Test_Main_Parent';
	    	oParentMainTerritory.CaseAccessLevel = 'Edit';
	    	oParentMainTerritory.AccountAccessLevel = 'Edit';
			oParentMainTerritory.Territory2ModelId = territorymodel.get(0).id;
			oParentMainTerritory.Territory2TypeId = territorytype.get(0).id;
	    	insert oParentMainTerritory;
	    	
	    	oMainTerritory = new Territory2();
	    	oMainTerritory.Name = 'UL.Test Main';
	    	oMainTerritory.DeveloperName = 'UL_Test_Main';
	    	oMainTerritory.CaseAccessLevel = 'Edit';
	    	oMainTerritory.AccountAccessLevel = 'Edit';
			oMainTerritory.Territory2ModelId = territorymodel.get(0).id;
			oMainTerritory.Territory2TypeId = territorytype.get(0).id;
	    	oMainTerritory.ParentTerritory2Id = oParentMainTerritory.Id;
	    	insert oMainTerritory;
	    	
	    	oParentAccount.TAMS_UL_Territory_Name__c = 'UL.Test Main';
	    	update oParentAccount;
		}
    	
    	test.startTest();
    	Batch_UpdateProcessAccountTeamMembers oBatch = new Batch_UpdateProcessAccountTeamMembers();
    	oBatch.sTerritoryId = oMainTerritory.Id;
		Database.executeBatch(oBatch, 1);
    	test.stopTest();
    }
    
    static testMethod void testUpdateAccountTeamMembersService() {
    	Territory2 oMainTerritory;
    	
		//Creating test PortalAccountOwner
		User oPortalAccountOwner = HelperClassTest.PortalAccountOwner();
		System.runAs(oPortalAccountOwner){
	    	//Creating test Accounts with Contacts/Portal Users
	        Account oParentAccount = HelperClassTest.CreatePortalAccount('TestParentAccount', null, oPortalAccountOwner.Id);
	    	//Creating test US Territories
			List<Territory2Model> territorymodel = [Select Id from Territory2Model Limit 1];
             List<Territory2Type> territorytype = [Select Id from Territory2Type Limit 1];
			 
	    	Territory2 oParentMainTerritory = new Territory2();
	    	oParentMainTerritory.Name = 'Service.Test Main Parent';
	    	oParentMainTerritory.DeveloperName = 'Service_Test_Main_Parent';
	    	oParentMainTerritory.CaseAccessLevel = 'Edit';
	    	oParentMainTerritory.AccountAccessLevel = 'Edit';
			oParentMainTerritory.Territory2ModelId = territorymodel.get(0).id;
			oParentMainTerritory.Territory2TypeId = territorytype.get(0).id;
	    	insert oParentMainTerritory;
	    	
	    	oMainTerritory = new Territory2();
	    	oMainTerritory.Name = 'Service.Test Main';
	    	oMainTerritory.DeveloperName = 'Service_Test_Main';
	    	oMainTerritory.CaseAccessLevel = 'Edit';
	    	oMainTerritory.AccountAccessLevel = 'Edit';
			oMainTerritory.Territory2ModelId = territorymodel.get(0).id;
			oMainTerritory.Territory2TypeId = territorytype.get(0).id;
	    	oMainTerritory.ParentTerritory2Id = oParentMainTerritory.Id;
	    	insert oMainTerritory;
	    	
	    	oParentAccount.TAMS_Service_Territory_Name__c = 'Service.Test Main';
	    	update oParentAccount;
		}
    	
    	test.startTest();
    	Batch_UpdateProcessAccountTeamMembers oBatch = new Batch_UpdateProcessAccountTeamMembers();
    	oBatch.sTerritoryId = oMainTerritory.Id;
		Database.executeBatch(oBatch, 1);
    	test.stopTest();
    }
}