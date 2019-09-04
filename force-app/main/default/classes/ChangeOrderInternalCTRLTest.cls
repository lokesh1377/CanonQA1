@isTest
private class ChangeOrderInternalCTRLTest {
	
	@testsetup static void testdata() {
		try{
		 Account acc = new Account();
          Id recordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('TAMS Account').getRecordTypeId();
          acc.RecordTypeId = recordTypeId;
          acc.TAMS_Account_Number_TAMS__c = '54321';
          acc.Name = 'Test123';
          insert acc;

          Order_Master__c ord = new Order_Master__c();
          ord.Customer_Name__c = acc.ID;
          ord.Oracle_Order_Number__c = '10012345';
          ord.Account_Number_Order__c = '54321';
          ord.SID_Order__c = 34563170;
          ord.Modality_Order__c = 'UL';
          insert ord;

         TAMS_ROA__c roa = new TAMS_ROA__c();
         roa.Account__c = acc.Id;
         roa.ROA_Type__c = 'Item Change';
         roa.Change_Requested_By__c = 'Internal';
         roa.Change_Order_SID__c = '34563178';
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

    @isTest static void saveerrorTest() {
     List<TAMS_ROA__c> lroa = [Select Id,Change_Order_SID__c From TAMS_ROA__c Where Change_Order_SID__c = '34563178' AND Change_Requested_By__c = 'Internal'];
     ApexPages.StandardSetController stdCon = new ApexPages.StandardSetController(lroa);
     ChangeOrderInternalCTRL changeorderinternal = new ChangeOrderInternalCTRL(stdCon);
      changeorderinternal.sidNumber = '12345';
      changeorderinternal.saveChangeOrder(); 
        TAMS_ROA__c roa = [Select Id,Change_Order_SID__c From TAMS_ROA__c Where Change_Order_SID__c = '34563178' AND Change_Requested_By__c = 'Internal'];
        System.assertEquals('34563178',roa.Change_Order_SID__c);
 }

	 @isTest static void saveTest() {
       List<Account> acc = [Select 
                            Id
                           ,TAMS_Account_Number_TAMS__c
                       From 
                          Account
                       Where 
                           Name = 'Test123'];
          Order_Master__c ord = [Select Id From Order_Master__c Where Account_Number_Order__c = '54321'];             
        ApexPages.StandardSetController stdCon = new ApexPages.StandardSetController(acc);
        ChangeOrderInternalCTRL changeorderinternal = new ChangeOrderInternalCTRL(stdCon);
         changeorderinternal.sidNumber = '34563170';
         changeorderinternal.sidNumberId = ord.Id;
         changeorderinternal.newChangeOrderHeader.ROA_Type__c = 'Item Change';
         changeorderinternal.isvalidSid('34563170');
         changeorderinternal.saveChangeOrder();
          TAMS_ROA__c roaData = [Select 
                                       Id
                                      ,Change_Order_SID__c
                                      ,ROA_Type__c
                                From 
                                       TAMS_ROA__c
                                Where 
                                       Change_Order_SID__c =: '34563170' And Change_Requested_By__c = 'External' ];

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

     @isTest static void saveOtherTest() {
       List<Account> lacc = [Select 
                            Id
                           ,TAMS_Account_Number_TAMS__c
                       From 
                          Account
                       Where 
                           Name = 'Test123'];
         Account acc = [Select 
                            Id
                           ,TAMS_Account_Number_TAMS__c
                       From 
                          Account
                       Where 
                           Name = 'Test123'];
          Order_Master__c ord = [Select Id From Order_Master__c Where Account_Number_Order__c = '54321'];             
        ApexPages.StandardSetController stdCon = new ApexPages.StandardSetController(lacc);
        ChangeOrderInternalCTRL changeorderinternal = new ChangeOrderInternalCTRL(stdCon);
         changeorderinternal.newChangeOrderHeader.ROA_Type__c = 'Other';
         changeorderinternal.newChangeOrderHeader.Account__c = acc.Id;
         changeorderinternal.saveChangeOrder();
        System.assertEquals('Other',changeorderinternal.newChangeOrderHeader.ROA_Type__c);
    }

    @isTest static void saveError() {
       List<Account> acc = [Select 
                            Id
                           ,TAMS_Account_Number_TAMS__c
                       From 
                          Account
                       Where 
                           Name = 'Test123'];
    ApexPages.StandardSetController stdCon = new ApexPages.StandardSetController(acc);
       ChangeOrderInternalCTRL changeorderinternal = new ChangeOrderInternalCTRL(stdCon);
         changeorderinternal.newChangeOrderHeader.change_order_sid__c = '';
         changeorderinternal.newChangeOrderHeader.ROA_Type__c = 'Administrative Change';
          changeorderinternal.saveChangeOrder();
        System.assertEquals('Administrative Change',changeorderinternal.newChangeOrderHeader.ROA_Type__c);
  } 
	
	

	 @isTest static void changeOrdersInternalTest() {
    List<Account> acc = [Select Id,Name From Account Where Name = 'Test123'];
    ApexPages.StandardSetController stdCon = new ApexPages.StandardSetController(acc);
    ChangeOrderInternalCTRL changeorderinternal = new ChangeOrderInternalCTRL(stdCon);
    changeorderinternal.changeorders();
    System.assertEquals(true,changeorderinternal.showChangeOrderInternal);
 }		
 

  @isTest static void getChangeorderInternalTest() {
     List<TAMS_ROA__c> lroa = [Select Id,Change_Order_SID__c From TAMS_ROA__c Where Change_Order_SID__c = '34563178' AND Change_Requested_By__c = 'Internal'];
     ApexPages.StandardSetController stdCon = new ApexPages.StandardSetController(lroa);
     ChangeOrderInternalCTRL changeorderinternal = new ChangeOrderInternalCTRL(stdCon);
      changeorderinternal.getchangeorderInternal(); 
        TAMS_ROA__c roa = [Select Id,Change_Order_SID__c From TAMS_ROA__c Where Change_Order_SID__c = '34563178' AND Change_Requested_By__c = 'Internal'];
        System.assertEquals('34563178',roa.Change_Order_SID__c);
 }
  @isTest static void cancelTest() {
     List<TAMS_ROA__c> lroa = [Select Id,Change_Order_SID__c From TAMS_ROA__c Where Change_Order_SID__c = '34563178' AND Change_Requested_By__c = 'Internal'];
     ApexPages.StandardSetController stdCon = new ApexPages.StandardSetController(lroa);
     ChangeOrderInternalCTRL changeorderinternal = new ChangeOrderInternalCTRL(stdCon);
      changeorderinternal.cancel(); 
        TAMS_ROA__c roa = [Select Id,Change_Order_SID__c From TAMS_ROA__c Where Change_Order_SID__c = '34563178' AND Change_Requested_By__c = 'Internal'];
        System.assertEquals('34563178',roa.Change_Order_SID__c);
 }

}