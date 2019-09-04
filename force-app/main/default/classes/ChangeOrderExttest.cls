@isTest
private class ChangeOrderExttest {
      
    @testsetup static void testdata(){
        try{
          Account acc = new Account();
          Id recordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('TAMS Account').getRecordTypeId();
          acc.RecordTypeId = recordTypeId;
          acc.TAMS_Account_Number_TAMS__c = '54321';
          acc.Name = 'Test123';
          insert acc;
            
          Opportunity op = new Opportunity();
           op.Name='testOpName';
           op.CloseDate = Date.today();
           op.StageName='testStage';
           op.Booking_Amount__c = 5000;
           op.SID_TAMS__c = '34563170';
           op.PBOM__c = 'TestPBOM';
          insert op;

          Order_Master__c ord = new Order_Master__c();
          ord.Customer_Name__c = acc.ID;
          ord.Oracle_Order_Number__c = '10012345';
          ord.Account_Number_Order__c = '54321';
          ord.SID_Order__c = 34563170;
          ord.Modality_Order__c = 'UL';
          insert ord;

          Order_Financial_Analysis__c ofa = new Order_Financial_Analysis__c();
          ofa.SID__c = '34563170';
          ofa.Modality__c = 'UL';
          insert ofa;

         Change_Order_OFA__c cOO = new Change_Order_OFA__c();
         cOO.OFA__c = ofa.id;
         insert cOO;
      }
      catch(DmlException e){
        System.debug('Inserting Fail'+e.getMessage());
      }
      }
    // Save Method with administrative changes
    @isTest static void saveTest() {
        // Implement test code
       Account acc = [Select 
                            Id
                           ,TAMS_Account_Number_TAMS__c
                       From 
                          Account
                       Where 
                           Name = 'Test123'];
        ApexPages.standardController stdCon = new ApexPages.standardController(acc);
        ChangeOrderExt changeOrder = new ChangeOrderExt(stdCon);
         changeOrder.sidNumber = 34563170;
         changeOrder.newChangeOrderHeader.ROA_Type__c = 'Item Change';
         changeOrder.isvalidSid(34563170);
         changeorder.saveOrder();
          decimal sid = 34563170;
          String sid_number = String.valueOf(sid);
          TAMS_ROA__c roaData = [Select 
                                       Id
                                      ,Change_Order_SID__c
                                      ,ROA_Type__c
                                From 
                                       TAMS_ROA__c
                                Where 
                                       Change_Order_SID__c =: sid_number ];

        Change_Order_OFA__c changeOrderOFA = [Select 
                                                    Id
                                                   ,OFA__c
                                              From 
                                                    Change_Order_OFA__c
                                              Where 
                                                     SID__c = '34563170'];

       Order_Financial_Analysis__c ofaData = [Select
                                                   Id
                                               From 
                                                  Order_Financial_Analysis__c
                                               Where 
                                                  SID__c = '34563170'];  

        System.assertEquals(ofaData.Id,changeOrderOFA.OFA__c);
    }
    // Saving change order with Other 
    @isTest static void saveTestOther() {
        // Implement test code
       Account acc = [Select 
                            Id
                           ,TAMS_Account_Number_TAMS__c
                       From 
                          Account
                       Where 
                           Name = 'Test123'];
        ApexPages.standardController stdCon = new ApexPages.standardController(acc);
       ChangeOrderExt changeOrder = new ChangeOrderExt(stdCon);
         changeOrder.newChangeOrderHeader.ROA_Type__c = 'Other';
          changeOrder.saveOrder(); 
        System.assertEquals('Other',changeOrder.newChangeOrderHeader.ROA_Type__c);
    }
    // Saving Change order Error Message 
    @isTest static void saveError() {
        // Implement test code
       Account acc = [Select 
                            Id
                           ,TAMS_Account_Number_TAMS__c
                       From 
                          Account
                       Where 
                           Name = 'Test123'];
    ApexPages.standardController stdCon = new ApexPages.standardController(acc);
       ChangeOrderExt changeOrder = new ChangeOrderExt(stdCon);
         changeOrder.newChangeOrderHeader.change_order_sid__c = '';
         changeOrder.newChangeOrderHeader.ROA_Type__c = 'Administrative Change';
          //changeOrder.createChangeOrderOFA(acc);
          changeOrder.saveOrder();
        List<TAMS_ROA__c> roaData = [Select 
                                       Id
                                      
                                      ,ROA_Type__c
                                From 
                                       TAMS_ROA__c
                                Where 
                                       Change_Order_SID__c = '34563170'];
         System.assertEquals(0,roaData.size());

        List<Change_Order_OFA__c> changeOrderOFA = [Select 
                                                    Id
                                                   ,OFA__c
                                              From 
                                                    Change_Order_OFA__c
                                              Where 
                                                     SID__c = '34563170'];
         System.assertEquals(0,changeOrderOFA.size());
  } 
  @isTest static void changeRequestedByTest() {
    // Implement test code
    Account acc = [Select 
                            Id
                           ,TAMS_Account_Number_TAMS__c
                       From 
                          Account
                       Where 
                           Name = 'Test123'];
     ApexPages.standardController stdCon = new ApexPages.standardController(acc);
       ChangeOrderExt changeOrder = new ChangeOrderExt(stdCon);
       changeorder.newChangeOrderHeader.ROA_Type__c = 'Item Change';
       changeOrder.changeRequestedBy();
       System.assertEquals(true,changeorder.showChangeRequestedBy);
  }
  @isTest static void changeRequestedByOtherTest() {
    // Implement test code
    Account acc = [Select 
                            Id
                           ,TAMS_Account_Number_TAMS__c
                       From 
                          Account
                       Where 
                           Name = 'Test123'];
     ApexPages.standardController stdCon = new ApexPages.standardController(acc);
       ChangeOrderExt changeOrder = new ChangeOrderExt(stdCon);
       changeorder.newChangeOrderHeader.ROA_Type__c = 'Other';
       changeOrder.changeRequestedBy();
       System.assertEquals(true,changeorder.showotherSID);
  }
  @isTest static void cancelTest(){
     Account acc = [Select 
                            Id
                           ,TAMS_Account_Number_TAMS__c
                       From 
                          Account
                       Where 
                           Name = 'Test123'];
    ApexPages.standardController stdCon = new ApexPages.standardController(acc);
    ChangeOrderExt changeorder = new ChangeOrderExt(stdCon);
    PageReference newPage =  changeorder.cancel();
    System.assertEquals(newPage.getUrl(),'/'+acc.ID);
  }
}