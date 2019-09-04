@isTest
private class ChangeOrderOFAControllerTest {
    
    @TestSetup static void TestData() {
        // Implement test data
          Account acc = new Account();
          Id recordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('TAMS Account').getRecordTypeId();
          acc.RecordTypeId = recordTypeId;
          acc.TAMS_Account_Number_TAMS__c = '54321';
          acc.Name = 'Test123';
          insert acc;

        TAMS_ROA__c roa = new TAMS_ROA__c();
         roa.Account__c = acc.Id;
         roa.ROA_Type__c = 'Item Change';
         roa.Change_Order_SID__c = '34563170';
         roa.Status__c = 'New';
         insert roa;
         
         Change_Order_OFA__c cOO = new Change_Order_OFA__c();
         cOO.Account_CH_OFA__c = acc.Id;
         cOO.Change_Order_Header__c = roa.Id;
         cOO.Included_OFA__c = true;
         insert cOO;
    }
    
    @isTest static void saveTest() {
        // Implement test code
    TAMS_ROA__c roa = [Select Id From TAMS_ROA__c Where Change_Order_SID__c = '34563170'];
    ApexPages.standardController stdCon = new ApexPages.standardController(roa);
    ChangeOrderOFAController changeorderOFA = new ChangeOrderOFAController(stdCon);
    changeorderOFA.getofavalues();
    changeorderOFA.save();
        Change_Order_OFA__c cOO = [Select Id,Included_OFA__c from Change_Order_OFA__c Where Change_Order_Header__c =: roa.id ];
    System.assertEquals(true,cOO.Included_OFA__c);
    }
    @isTest static void getFieldsTest() {
    // Implement test code
    TAMS_ROA__c roa = [Select Id,Change_Order_SID__c From TAMS_ROA__c Where Change_Order_SID__c = '34563170'];
    ApexPages.standardController stdCon = new ApexPages.standardController(roa);
    ChangeOrderOFAController changeorderOFA = new ChangeOrderOFAController(stdCon);
     list<Schema.FieldSetMember> lFieldSet = changeorderOFA.getFields();
       list<Schema.FieldSetMember> lactualFieldSet = SObjectType.Change_Order_OFA__c.FieldSets.COFA_Columns_for_Change_Order_Layout.getFields();
        System.assertEquals('34563170',roa.Change_Order_SID__c);
  }
   //@isTest static void EditableTest() {
   //     // Implement test code
   //     Account acc = new Account();
   //     Id recordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('TAMS Account').getRecordTypeId();
   //       acc.RecordTypeId = recordTypeId;
   //       acc.TAMS_Account_Number_TAMS__c = '54321';
   //       acc.Name = 'Test123';
   //       insert acc;

   //    TAMS_ROA__c roas = new TAMS_ROA__c();
   //      roas.Account__c = acc.Id;
   //      roas.ROA_Type__c = 'Item Change';
   //      roas.Change_Order_SID__c = '34563178';
   //      roas.Status__c = 'New';
   //      insert roas;

   // TAMS_ROA__c roa = [Select Id,Status__c From TAMS_ROA__c Where Change_Order_SID__c = '34563170'];
   // ApexPages.standardController stdCon = new ApexPages.standardController(roa);
   // ChangeOrderOFAController changeorderOFA = new ChangeOrderOFAController(stdCon);
   // roas.Status__c = 'Complete';
   //  update roas;
   // System.assertEquals('Complete',roas.Status__c);
   // }
}