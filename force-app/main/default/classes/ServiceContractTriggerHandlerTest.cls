@isTest
private class ServiceContractTriggerHandlerTest {

    static testMethod void testEquipmentUpdateInsert() {
        Account oTestAccount1;
        Install_Base_TAMS__c oEquipment;
        ServiceContract oContract;
        
        //Creating test PortalAccountOwner
        User oPortalAccountOwner = HelperClassTest.PortalAccountOwner();
        System.runAs(oPortalAccountOwner){
            //Creating test Accounts with Contacts/Portal Users
            oTestAccount1 = HelperClassTest.CreatePortalAccount('TestAccount1', null, oPortalAccountOwner.Id);
            
            //Creating test Equipment Record
            oEquipment = new Install_Base_TAMS__c ();
            oEquipment.Name = 'Test-123456';
            oEquipment.Account_Name__c = oTestAccount1.Id;
            insert oEquipment;
            
            test.startTest();
            oContract = new ServiceContract();
            oContract.Name = 'Test Contract';
            oContract.Contract_Status__c = 'Active';
            oContract.Equipment__c = oEquipment.Id;
            insert oContract;
            test.stopTest();
        }
        //Confirming that the Related Equipment record was update the Contract Id
        system.assertEquals(oContract.Id, [Select Service_Contract__c From Install_Base_TAMS__c Where Id = :oEquipment.Id].Service_Contract__c);
    }
    
    static testMethod void testEquipmentUpdateUpdate() {
        Account oTestAccount1;
        Install_Base_TAMS__c oEquipment;
        ServiceContract oContract;
        
        //Creating test PortalAccountOwner
        User oPortalAccountOwner = HelperClassTest.PortalAccountOwner();
        System.runAs(oPortalAccountOwner){
            //Creating test Accounts with Contacts/Portal Users
            oTestAccount1 = HelperClassTest.CreatePortalAccount('TestAccount1', null, oPortalAccountOwner.Id);
            
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
            
            oContract.Contract_Status__c = 'Active';
            update oContract;
                        
            //Added by HK on June 8 2017 as logic got changed of class
            oContract.Contract_Status__c = 'Inactive';
            update oContract;
                        
            test.stopTest();
        }
        //Confirming that the Related Equipment record was update the Contract Id
        //system.assertEquals(oContract.Id, [Select Service_Contract__c From Install_Base_TAMS__c Where Id = :oEquipment.Id].Service_Contract__c);
    }
}