/*********************************************
 * Class object for Testing trigger.         *  
 *                                           *
 * Tests: ServiceContractOwnerTriggerHandler *
 *                                           *
 * @author: Wendy B. Copeland                *
 * @date:   August 25, 2016                  *
 *                                           *
 *                                           *
 *********************************************/
@isTest
private class ServiceContractOwnerTriggerHandlerTest {

    static testMethod void testServiceContractOwnerUpdateInsert() {
      Account oTestAccount1;
      User oUser;
      Install_Base_TAMS__c oEquipment;
      ServiceContract oContract;
      
    //Creating test PortalAccountOwner
    User oPortalAccountOwner = HelperClassTest.PortalAccountOwner();
    System.runAs(oPortalAccountOwner){
          //Creating test Accounts with Contacts/Portal Users
          oTestAccount1 = HelperClassTest.CreatePortalAccount('TestAccount1', null, oPortalAccountOwner.Id);
          
      //Creating ASM User Record 
      Profile p = [SELECT Id FROM Profile WHERE Name = 'TAMS - ASM'];

      oUser = new User();
          oUser.Alias = 'testu';
          oUser.Email = 'test@ASMTestUser.com';
          oUser.EmailEncodingKey = 'UTF-8';
          oUser.LastName = 'ASMTestUser';
          oUser.LanguageLocaleKey = 'en_US';
          oUser.LocaleSidKey = 'en_US';
          oUser.TimeZoneSidKey='America/Los_Angeles';
          oUser.ProfileId = p.Id;
          oUser.UserName='test@ASMTestUser.com';
          insert oUser;

          //Creating test Equipment Record
          oEquipment = new Install_Base_TAMS__c ();
          oEquipment.Name = 'Test-123456';
          oEquipment.Account_Name__c = oTestAccount1.Id;
          oEquipment.ASM_lookup__c = oUser.Id;
          insert oEquipment;
          
          test.startTest();
          oContract = new ServiceContract();
          oContract.Name = 'Test Contract';
          oContract.Contract_Status__c = 'Active';
          oContract.Equipment__c = oEquipment.Id;
          insert oContract;
          test.stopTest();
    }
        //Confirming that the Related Equipment record was updated the Contract Id
        //system.assertEquals(oContract.OwnerId, [Select Service_Contract__c From Install_Base_TAMS__c Where Id = :oEquipment.Id].Service_Contract__c);
        system.assertEquals([Select OwnerId From ServiceContract Where Id = : oContract.Id].OwnerId, [Select ASM_lookup__c From Install_Base_TAMS__c Where Id = :oEquipment.Id].ASM_lookup__c);
    }
 
 /*   
    static testMethod void testServiceContractOwnerUpdateMultipleInsert() {
      Account oTestAccount1;
      User oUser;
//      ServiceContract oContract;
      Install_Base_TAMS__c oEquipment;
      List<ServiceContract> lContracts = new List<ServiceContract>();     
    //Creating test PortalAccountOwner
    User oPortalAccountOwner = HelperClassTest.PortalAccountOwner();
    System.runAs(oPortalAccountOwner){
          //Creating test Accounts with Contacts/Portal Users
          oTestAccount1 = HelperClassTest.CreatePortalAccount('TestAccount1', null, oPortalAccountOwner.Id);
          
      //Creating ASM User Record 
      Profile p = [SELECT Id FROM Profile WHERE Name = 'TAMS - ASM'];

          oUser = new User();
          oUser.Alias = 'testu';
          oUser.Email = 'test@ASMTestUser.com';
          oUser.EmailEncodingKey = 'UTF-8';
          oUser.LastName = 'ASMTestUser';
          oUser.LanguageLocaleKey = 'en_US';
          oUser.LocaleSidKey = 'en_US';
          oUser.TimeZoneSidKey='America/Los_Angeles';
          oUser.ProfileId = p.Id;
          oUser.UserName='test@ASMTestUser.com';
          insert oUser;
       
          //Creating test Equipment Record
          oEquipment = new Install_Base_TAMS__c ();
          oEquipment.Name = 'Test2-123456';
          oEquipment.Account_Name__c = oTestAccount1.Id;
          oEquipment.ASM_lookup__c = oUser.Id;
          insert oEquipment;
          
          test.startTest();
          for(Integer i=0;i<3;i++) { 
             ServiceContract oContract = new ServiceContract(Name = 'Test Contract' + i,  
                                                             Contract_Status__c = 'Active',
                                                             Equipment__c = oEquipment.id); 
             lContracts.add(oContract); 
          } 
          //insert lContracts;
          test.stopTest();
    }
        //Confirming that the Related Equipment record was updated the Contract Id
         system.assertEquals([Select OwnerId From ServiceContract Where Name = 'Test Contract1'].OwnerId, [Select ASM_lookup__c From Install_Base_TAMS__c Where Id = :oEquipment.Id].ASM_lookup__c);
         system.assertEquals([Select OwnerId From ServiceContract Where Name = 'Test Contract2'].OwnerId, [Select ASM_lookup__c From Install_Base_TAMS__c Where Id = :oEquipment.Id].ASM_lookup__c);
    }  
 */
   static testMethod void testServiceContractOwnerNoASMUpdateUpdate() {
      Account oTestAccount1;
      User oUser;
      Install_Base_TAMS__c oEquipment;
      ServiceContract oContract;
      
    //Creating test PortalAccountOwner
    User oPortalAccountOwner = HelperClassTest.PortalAccountOwner();
    System.runAs(oPortalAccountOwner){
          //Creating test Accounts with Contacts/Portal Users
          oTestAccount1 = HelperClassTest.CreatePortalAccount('TestAccount1', null, oPortalAccountOwner.Id);
          
      //Creating ASM User Record 
      Profile p = [SELECT Id FROM Profile WHERE Name = 'TAMS - ASM'];

      oUser = new User();
          oUser.Alias = 'testu';
          oUser.Email = 'test@ASMTestUser.com';
          oUser.EmailEncodingKey = 'UTF-8';
          oUser.LastName = 'ASMTestUser';
          oUser.LanguageLocaleKey = 'en_US';
          oUser.LocaleSidKey = 'en_US';
          oUser.TimeZoneSidKey='America/Los_Angeles';
          oUser.ProfileId = p.Id;
          oUser.UserName='test@ASMTestUser.com';
          insert oUser;

          //Creating test Equipment Record
          oEquipment = new Install_Base_TAMS__c ();
          oEquipment.Name = 'Test-123456';
          oEquipment.Account_Name__c = oTestAccount1.Id;
          insert oEquipment;
          
          test.startTest();
          oContract = new ServiceContract();
          oContract.Name = 'Test Contract';
          oContract.Equipment__c = oEquipment.Id;
          insert oContract;
                  
          oContract.Contract_Status__c = 'Active';
          update oContract;
          test.stopTest();
    }
        //Confirming that the Related Equipment record was update the Contract Id
        system.assertNotEquals([Select OwnerId From ServiceContract Where Id = : oContract.Id].OwnerId, [Select ASM_lookup__c From Install_Base_TAMS__c Where Id = :oEquipment.Id].ASM_lookup__c);
                      
    }

   static testMethod void testServiceContractOwnerUpdateUpdate() {
      Account oTestAccount1;
      User oUser;
      Install_Base_TAMS__c oEquipment;
      ServiceContract oContract;
      
    //Creating test PortalAccountOwner
    User oPortalAccountOwner = HelperClassTest.PortalAccountOwner();
    System.runAs(oPortalAccountOwner){
          //Creating test Accounts with Contacts/Portal Users
          oTestAccount1 = HelperClassTest.CreatePortalAccount('TestAccount1', null, oPortalAccountOwner.Id);
          
      //Creating ASM User Record 
      Profile p = [SELECT Id FROM Profile WHERE Name = 'TAMS - ASM'];

      oUser = new User();
          oUser.Alias = 'testu';
          oUser.Email = 'test@ASMTestUser.com';
          oUser.EmailEncodingKey = 'UTF-8';
          oUser.LastName = 'ASMTestUser';
          oUser.LanguageLocaleKey = 'en_US';
          oUser.LocaleSidKey = 'en_US';
          oUser.TimeZoneSidKey='America/Los_Angeles';
          oUser.ProfileId = p.Id;
          oUser.UserName='test@ASMTestUser.com';
          insert oUser;

          //Creating test Equipment Record
          oEquipment = new Install_Base_TAMS__c ();
          oEquipment.Name = 'Test-123456';
          oEquipment.Account_Name__c = oTestAccount1.Id;
          oEquipment.ASM_lookup__c = oUser.Id; 
         insert oEquipment;
          
          test.startTest();
          oContract = new ServiceContract();
          oContract.Name = 'Test Contract';
          oContract.Equipment__c = oEquipment.Id;
          insert oContract;
                  
          oContract.Contract_Status__c = 'Inactive';
          update oContract;
          test.stopTest();
    }
        //Confirming that the Related Equipment record was update the Contract Id
        system.assertEquals([Select OwnerId From ServiceContract Where Id = : oContract.Id].OwnerId, [Select ASM_lookup__c From Install_Base_TAMS__c Where Id = :oEquipment.Id].ASM_lookup__c);
                      
    }
}