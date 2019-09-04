@isTest
private class ChangeOrderlookupcontrollerTest {
	
	@testSetup static void testData() {
		// Implement test code
		 Account acc = new Account();
          Id recordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('TAMS Account').getRecordTypeId();
          acc.RecordTypeId = recordTypeId;
          acc.TAMS_Account_Number_TAMS__c = '54321';
          acc.Name = 'Test123';
          insert acc;

         Order_Master__c ord1 = new Order_Master__c();
          ord1.Customer_Name__c = acc.ID;
          //ord1.Customer_Account_Name__c = acc.ID;
          ord1.Oracle_Order_Number__c = '10012345';
          ord1.SID_Order__c = 34563170;
          ord1.Modality_Order__c = 'UL';
          ord1.CMSU_Booked_Date__c  = System.today();
          ord1.Order_Type__c = 'TEST 123';
          ord1.Order_Status__c = 'Booked';
          ord1.Order_Subtotal__c = 0.00;
          insert ord1; 
	}
	 
@isTest static void onLoadTest() {
    Test.setCurrentPageReference(new PageReference('Page.ChangeOrderlookupVF')); 
    System.currentPageReference().getParameters().put('parentname', '');
    System.currentPageReference().getParameters().put('parentid', '');
    System.currentPageReference().getParameters().put('namefield', 'j_id0:ChangeorderForm:ChangeorderBlock:changeorder:inputname');
    System.currentPageReference().getParameters().put('idfield', 'j_id0:ChangeorderForm:ChangeorderBlock:changeorder:inputid');
    System.currentPageReference().getParameters().put('sObject', 'Order_Master__c');
    System.currentPageReference().getParameters().put('fieldName', 'OM_SID__c');
    System.currentPageReference().getParameters().put('query', 'SELECT Id,Name,SID_Order__c,OM_SID__c,Order_Type__c,CMSU_Booked_Date__c,Modality_Order__c,Order_Status__c,Order_Subtotal__c FROM Order_Master__c where Customer_Name__r.TAMS_Account_Number_TAMS__c = \'54321\' AND OM_SID__c');
    System.currentPageReference().getParameters().put('listofcolumns', 'OM_SID__c:SID;Name:Order Number;Order_Type__c:Order Type;Modality_Order__c:Modality;Order_Status__c:Order Status;Order_Subtotal__c:Order Booking Amount;CMSU_Booked_Date__c:Order Booked Date;');
		System.currentPageReference().getParameters().put('orderBy', 'SID_Order__c');
    ChangeOrderlookupcontroller colc = new ChangeOrderlookupcontroller(); 
    System.assertEquals(7,colc.mColumnsDisplay.size());

  }


  @isTest static void onLoadTestWithSearchValue() {
    Test.setCurrentPageReference(new PageReference('Page.ChangeOrderlookupVF')); 
    System.currentPageReference().getParameters().put('parentname', '34563170');
    System.currentPageReference().getParameters().put('parentid', '');
    System.currentPageReference().getParameters().put('namefield', 'j_id0:ChangeorderForm:ChangeorderBlock:changeorder:inputname');
    System.currentPageReference().getParameters().put('idfield', 'j_id0:ChangeorderForm:ChangeorderBlock:changeorder:inputid');
    System.currentPageReference().getParameters().put('sObject', 'Order_Master__c');
    System.currentPageReference().getParameters().put('fieldName', 'OM_SID__c');
    System.currentPageReference().getParameters().put('query', 'SELECT Id,Name,SID_Order__c,OM_SID__c,Order_Type__c,CMSU_Booked_Date__c,Modality_Order__c,Order_Status__c,Order_Subtotal__c FROM Order_Master__c where Customer_Name__r.TAMS_Account_Number_TAMS__c = \'54321\' AND OM_SID__c');
    System.currentPageReference().getParameters().put('listofcolumns', 'OM_SID__c:SID;Name:Order Number;Order_Type__c:Order Type;Modality_Order__c:Modality;Order_Status__c:Order Status;Order_Subtotal__c:Order Booking Amount;CMSU_Booked_Date__c:Order Booked Date;');
    System.currentPageReference().getParameters().put('orderBy', 'SID_Order__c');
    ChangeOrderlookupcontroller colc = new ChangeOrderlookupcontroller(); 
    System.assertEquals(7,colc.mColumnsDisplay.size());

  }

	 @isTest static void onkeyupActionTest() {
	 ChangeOrderlookupcontroller colc = new ChangeOrderlookupcontroller();	
   colc.partialQuery = 'SELECT Id,Name,SID_Order__c,OM_SID__c,Order_Type__c,CMSU_Booked_Date__c,Modality_Order__c,Order_Status__c,Order_Subtotal__c FROM Order_Master__c where Customer_Name__r.TAMS_Account_Number_TAMS__c = \'54321\' AND OM_SID__c';
   colc.searchvalue = '34563170';
   colc.fieldName = 'OM_SID__c';
   colc.SObjectName = 'Order_Master__c';
   colc.mColumnsDisplay.put('Order_Subtotal__c','Order Sub total');
   colc.mColumnsDisplay.put('OM_SID__c','SID Number');
   colc.mColumnsDisplay.put('Order_Type__c','order Type');
   colc.mColumnsDisplay.put('CMSU_Booked_Date__c','Booked Date');
   colc.mColumnsDisplay.put('Modality_Order__c','Modality');
   colc.mColumnsDisplay.put('Order_Status__c','Order Status');
   PageReference pg = colc.onkeyupAction();
	 System.assertEquals(null,pg);
	}
}