@isTest
private class InstallBaseTriggerHandlerTest {

    static testMethod void testProductFamilyUpdate() {
    	Account oTestAccount1;
    	
		//Creating test PortalAccountOwner
		User oPortalAccountOwner = HelperClassTest.PortalAccountOwner();
		System.runAs(oPortalAccountOwner){
	        //Creating test Accounts with Contacts/Portal Users
	        oTestAccount1 = HelperClassTest.CreatePortalAccount('TestAccount1', null, oPortalAccountOwner.Id);
		}
        
        
        test.startTest();
        User oCurrentUser = [Select Id From User Where Id = :UserInfo.getUserId()];
    	
    	system.runAs(oCurrentUser){
	        //Creating test Sub Family Record
	        TAMS_Product_Sub_Family__c oFamily = new TAMS_Product_Sub_Family__c();
	        oFamily.Name = 'Test-123456';
	        insert oFamily;
	        
	        //Creating test Equipment Record
	        Install_Base_TAMS__c oEquipment = new Install_Base_TAMS__c ();
	        oEquipment.Name = 'Test-123456';
	        oEquipment.Account_Name__c = oTestAccount1.Id;
	        oEquipment.TAMS_Product_Sub_Family__c = 'Test-123456';
	        insert oEquipment;
	        test.stopTest();
	        system.assertEquals(oFamily.Id, [Select TAMS_Product_Sub_Family_lookup__c From Install_Base_TAMS__c Where Id = :oEquipment.Id].TAMS_Product_Sub_Family_lookup__c);
    	}
    }
    
    static testMethod void testUpdateAccountTeamFlag(){
    	User oTestUser;
    	User oTestUser2;
    	User oCurrentUser = [Select Id From User Where Id = :UserInfo.getUserId()];
    	
    	system.runAs(oCurrentUser){
	        //Creating test Users
	        Profile p = [select id from profile where name='TAMS - Service Agent User'];
	        oTestUser = new User(alias='stnd', email='testNewCase@test.com', profileid=p.Id,
	            emailencodingkey='UTF-8', firstname='Standard', lastname='lastname', languagelocalekey='en_US', 
	            localesidkey='en_US', EmployeeNumber='88888888', isactive=true,
	            timezonesidkey='America/Los_Angeles', username='testNewCase@test.com');
			insert oTestUser;
	        oTestUser2 = new User(alias='stnd2', email='testNewCase2@test.com', profileid=p.Id,
	            emailencodingkey='UTF-8', firstname='Standard2', lastname='lastname2', languagelocalekey='en_US', 
	            localesidkey='en_US', EmployeeNumber='99999999', isactive=true,
	            timezonesidkey='America/Los_Angeles', username='testNewCase2@test.com');
			insert oTestUser2;
    	}
		
    	Account oTestAccount1;
    	
		//Creating test PortalAccountOwner
		User oPortalAccountOwner = HelperClassTest.PortalAccountOwner();
		System.runAs(oPortalAccountOwner){
	        //Creating test Accounts with Contacts/Portal Users
	        oTestAccount1 = HelperClassTest.CreatePortalAccount('TestAccount1', null, oPortalAccountOwner.Id);
		
        
		        
        test.startTest();
        //Creating test Equipment Record
        Install_Base_TAMS__c oEquipment = new Install_Base_TAMS__c ();
        oEquipment.Name = 'Test-123456';
        oEquipment.Account_Name__c = oTestAccount1.Id;
        oEquipment.Primary_CE_lookup__c = oTestUser.Id;
        oEquipment.ASM_lookup__c = oTestUser2.Id;
        insert oEquipment;
        //Confirming flag was updated on insert
        system.assertEquals(true, [Select Process_Account_Team_Members__c From Account Where Id = :oTestAccount1.Id].Process_Account_Team_Members__c);
        //Resetting flag
        oTestAccount1.Process_Account_Team_Members__c = false;
        update oTestAccount1;
        
        oEquipment.Primary_CE_lookup__c = oTestUser2.Id;
        oEquipment.ASM_lookup__c = oTestUser.Id;
        update oEquipment;
        //Confirming flag was updated on update
        system.assertEquals(true, [Select Process_Account_Team_Members__c From Account Where Id = :oTestAccount1.Id].Process_Account_Team_Members__c);
        //Resetting flag
        oTestAccount1.Process_Account_Team_Members__c = false;
        update oTestAccount1;
        
        delete oEquipment;
        //Confirming flag was updated on delete
        system.assertEquals(true, [Select Process_Account_Team_Members__c From Account Where Id = :oTestAccount1.Id].Process_Account_Team_Members__c);
        test.stopTest();
		}
    }
}