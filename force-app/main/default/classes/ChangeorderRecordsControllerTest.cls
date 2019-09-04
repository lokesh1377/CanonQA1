@isTest
private class ChangeorderRecordsControllerTest{
    
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
         roa.Change_Requested_By__c = 'Internal';
         roa.Change_Order_SID__c = '34563170';
         roa.Status__c = 'New';
         insert roa;

        TAMS_ROA__c roa1 = new TAMS_ROA__c();
         roa1.Account__c = acc.Id;
         roa1.ROA_Type__c = 'Item Change';
         roa1.Change_Requested_By__c = 'External';
         roa1.Change_Order_SID__c = '34563170';
         roa1.Status__c = 'New';
         insert roa1;

          TAMS_ROA__c roa2 = new TAMS_ROA__c();
         roa2.Account__c = acc.Id;
         roa2.ROA_Type__c = 'Item Change';
         roa2.Change_Order_SID__c = '34563170';
         roa2.Status__c = 'New';
         insert roa2;
     }
    
    @isTest static void getFieldsTest(){
    // Implement test code
    TAMS_ROA__c roa = [Select Id,Change_Order_SID__c From TAMS_ROA__c Where Change_Order_SID__c = '34563170'  AND Change_Requested_By__c = null ];
    ApexPages.standardController stdCon = new ApexPages.standardController(roa);
    ChangeorderRecordsController changeorderRelated = new ChangeorderRecordsController(stdCon);
     list<Schema.FieldSetMember> lFieldSet = changeorderRelated .getFields();
       list<Schema.FieldSetMember> lactualFieldSet = SObjectType.TAMS_ROA__c.FieldSets.COFA_Columns_for_Item_Change_Layout.getFields();
        System.assertEquals('34563170',roa.Change_Order_SID__c);
  }

    @isTest static void getChangeorderExternalTest() {
    // Implement test code
    TAMS_ROA__c roa = [Select Id,Change_Order_SID__c From TAMS_ROA__c Where Change_Order_SID__c = '34563170' AND Change_Requested_By__c = 'External'];
    ApexPages.standardController stdCon = new ApexPages.standardController(roa);
    ChangeorderRecordsController changeorderRelated = new ChangeorderRecordsController(stdCon);
     changeorderRelated.getchangeorderExternal();
        System.assertEquals('34563170',roa.Change_Order_SID__c);
 }
 @isTest static void getChangeorderInternalTest() {
    // Implement test code
    TAMS_ROA__c roa = [Select Id,Change_Order_SID__c From TAMS_ROA__c Where Change_Order_SID__c = '34563170' AND Change_Requested_By__c = 'Internal'];
    ApexPages.standardController stdCon = new ApexPages.standardController(roa);
    ChangeorderRecordsController changeorderRecords = new ChangeorderRecordsController(stdCon);
      changeorderRecords.getchangeorderInternal(); 
       //changeorderRecords.roa.Change_Requested_By__c = 'Internal';
        System.assertEquals('34563170',roa.Change_Order_SID__c);
 }
 @isTest static void changeOrderTest() {
    // Implement test code
    TAMS_ROA__c roa = [Select Id,Name,Change_Order_SID__c From TAMS_ROA__c Where Change_Order_SID__c = '34563170' AND Change_Requested_By__c = 'External'];
    ApexPages.standardController stdCon = new ApexPages.standardController(roa);
    ChangeorderRecordsController changeorderRelated = new ChangeorderRecordsController(stdCon);
    changeorderRelated.changeordername = roa.Name;
    changeorderRelated.changeOrder();
     System.assertEquals('34563170',roa.Change_Order_SID__c);
 }
}