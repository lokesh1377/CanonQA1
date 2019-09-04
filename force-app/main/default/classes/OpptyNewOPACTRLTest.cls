@isTest
private class OpptyNewOPACTRLTest{

    @TestSetup static void TestData() {
        // Implement test data
          Account acc = new Account();
          Id recordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('TAMS Account').getRecordTypeId();
          acc.RecordTypeId = recordTypeId;
          acc.TAMS_Account_Number_TAMS__c = '54321';
          acc.Name = 'Test123';
          acc.Zone_TAMS__c = 'GS';
          insert acc;
          
          Opportunity oppty = new Opportunity();
          oppty.AccountId = acc.id;
          oppty.Name='testOpName';
          oppty.CloseDate = Date.today();
          oppty.StageName='testStage';
          oppty.Booking_Amount__c = 5000;
           insert oppty;
          }
          
         @isTest static void canceltest(){
         Opportunity opptydata = [Select Id From Opportunity Where StageName = 'testStage'];
         ApexPages.standardController stdCon = new ApexPages.standardController(opptydata);
         OpptyNewOPACTRL opa = new OpptyNewOPACTRL(stdCon);
          PageReference newPage =  opa.cancel();
          System.assertEquals(newPage.getUrl(),'/'+opptydata.ID);
         }
         
          @isTest static void savetest(){
         Opportunity opptydata = [Select Id,StageName  From Opportunity Where StageName = 'testStage'];
         ApexPages.standardController stdCon = new ApexPages.standardController(opptydata);
         OpptyNewOPACTRL opa = new OpptyNewOPACTRL(stdCon);
         opa.save();
         system.assertEquals('testStage',opptydata.StageName);
         }
         
          @isTest static void saveNewtest(){
         Opportunity opptydata = [Select Id,StageName  From Opportunity Where StageName = 'testStage'];
         ApexPages.standardController stdCon = new ApexPages.standardController(opptydata);
         OpptyNewOPACTRL opa = new OpptyNewOPACTRL(stdCon);
         opa.saveNew();
         system.assertEquals('testStage',opptydata.StageName);
         }
         
 }