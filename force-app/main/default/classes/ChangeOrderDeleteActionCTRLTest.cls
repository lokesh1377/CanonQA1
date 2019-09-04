@isTest
private class ChangeOrderDeleteActionCTRLTest {
	
  @testsetup static void testData() {

    Account acc = new Account();
          Id recordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('TAMS Account').getRecordTypeId();
          acc.RecordTypeId = recordTypeId;
          acc.TAMS_Account_Number_TAMS__c = '54321';
          acc.Name = 'Test123';
          insert acc;

          Order_Master__c ord = new Order_Master__c();
          ord.Customer_Name__c = acc.ID;
          ord.Oracle_Order_Number__c = '10012345';
          ord.SID_Order__c = 34563170;
          ord.Modality_Order__c = 'UL';
          ord.Price_List__c = 'TestPriceList';
          ord.CMSU_Booked_Date__c  = System.today();
          ord.Order_Type__c = 'TEST 123';
          ord.Order_Status__c = 'Booked';
          ord.Order_Subtotal__c = 0.00;
          insert ord;

          Order_Master__c ord2 = new Order_Master__c();
          ord2.Customer_Name__c = acc.ID;
          ord2.Oracle_Order_Number__c = '10123450';
          ord2.SID_Order__c = 34563170;
          ord2.Modality_Order__c = 'UL';
          insert ord2;

         TAMS_ROA__c roa = new TAMS_ROA__c();
         roa.Account__c = acc.Id;
         roa.ROA_Type__c = 'Item Change';
         roa.Change_Order_SID__c = '34563170';
         roa.Status__c = 'New';
         insert roa;

         ItemMaster__c itemmaster = new ItemMaster__c();
        itemmaster.Item_Number__c = 'Test123';
        itemmaster.Description__c = 'testDescription';
        itemmaster.Item_Type__c = 'TESTITEMTYPE';
        itemmaster.Discountable__c = 'Y';
        itemmaster.Status_Code__c = 'Active';
        itemmaster.Inventory_Item_Id__c = '1234';
        insert itemmaster;

         TAMS_ROA_Lines__c changeorderlines = new TAMS_ROA_Lines__c();
        changeorderlines.Action_Type__c = 'Delete';
        changeorderlines.TAMS_ROA__c = roa.Id;
        changeorderlines.List_Price__c = 2000;
        changeorderlines.Order_Number__c= '10012345';
        changeorderlines.New_Selling_Price__c = 0;
        changeorderlines.Quantity__c = 1;
        changeorderlines.Item_Description__c = 'testDescription';
        changeorderlines.COL_Comments__c= 'test';
        changeorderlines.COL_New_Item__c = itemmaster.Id ;
        changeorderlines.COL_Quantity__c = 1;
        insert changeorderlines;

        Order_Line_Master__c orderlinemaster = new Order_Line_Master__c();
        orderlinemaster.Line_ID__c = 101921037;
         orderlinemaster.CMSU_Order__c = ord.id;
        orderlinemaster.Line_Number__c = '1.1';
        orderlinemaster.Item_Selling_Price__c = 2000;
        orderlinemaster.Quantity__c = 1;
        orderlinemaster.Status__c = 'Active';
        orderlinemaster.Item_List_Price__c = 900;
        orderlinemaster.Ordered_Item__c = itemmaster.id;
        insert orderlinemaster;
  }
	
  @isTest static void getordTest() {
        // Implement test code
               TAMS_ROA__c roa = [Select Id From TAMS_ROA__c Where Change_Order_SID__c = '34563170'];
               ApexPages.standardController stdCon = new ApexPages.standardController(roa);
                ChangeOrderDeleteActionCTRL deleteitem = new ChangeOrderDeleteActionCTRL(stdCon);
               List<SelectOption> lActualSelectedOptions = deleteitem.getord();
               List<SelectOption> lExpectedSelectOptions = new List<SelectOption>();
               lExpectedSelectOptions.add(new SelectOption('None','None'));
               lExpectedSelectOptions.add(new SelectOption('10012345','10012345'));
               lExpectedSelectOptions.add(new SelectOption('10123450','10123450'));

               System.assertEquals(lExpectedSelectOptions,lActualSelectedOptions);
    }

    @isTest static void saveTest() {
        // Implement test code
       TAMS_ROA__c roa = [Select Id,Change_Order_SID__c From TAMS_ROA__c Where Change_Order_SID__c = '34563170'];
       ApexPages.standardController stdCon = new ApexPages.standardController(roa);
       ChangeOrderDeleteActionCTRL deleteitem = new ChangeOrderDeleteActionCTRL(stdCon);
       Order_Line_Master__c orderlinemaster = [select Line_Number__c,Item_Selling_Price__c,Quantity__c,Status__c,Item_List_Price__c,Ordered_Item__c,Item_Description__c From Order_Line_Master__c Where Line_ID__c = 101921037];
       TAMS_ROA_Lines__c changeOrderLines = [Select List_Price__c,New_Selling_Price__c,Quantity__c,COL_Comments__c,COL_New_Item__r.Name,COL_Quantity__c  From TAMS_ROA_Lines__c Where Action_Type__c = 'Delete'];
       ChangeOrderLinesWRP deletechangeorder = new ChangeOrderLinesWRP(orderlinemaster,true,changeOrderLines);
       deleteitem.orderLines.add(deletechangeorder);
       deleteitem.selectorders1 = '10012345';
       deleteitem.save();
       System.assertEquals('34563170',roa.Change_Order_SID__c);
    }

      @isTest static void saveErrorTest() {
        // Implement test code
       TAMS_ROA__c roa = [Select Id,Change_Order_SID__c From TAMS_ROA__c Where Change_Order_SID__c = '34563170'];
       ApexPages.standardController stdCon = new ApexPages.standardController(roa);
       ChangeOrderDeleteActionCTRL deleteitem = new ChangeOrderDeleteActionCTRL(stdCon);
       Order_Line_Master__c orderlinemaster = [select Line_Number__c,Item_Selling_Price__c,Quantity__c,Status__c,Item_List_Price__c,Ordered_Item__c,Item_Description__c From Order_Line_Master__c Where Line_ID__c = 101921037];
       TAMS_ROA_Lines__c changeOrderLines = [Select List_Price__c,New_Selling_Price__c,Quantity__c,COL_Comments__c,COL_New_Item__r.Name,COL_Quantity__c  From TAMS_ROA_Lines__c Where Action_Type__c = 'Delete'];
       ChangeOrderLinesWRP deletechangeorder = new ChangeOrderLinesWRP(orderlinemaster,true,changeOrderLines);
       deleteitem.orderLines.add(deletechangeorder);
       deletechangeorder.deleteQuantity = 0;
       deleteitem.selectorders1 = '10012345';
       deleteitem.save();
       System.assertEquals('34563170',roa.Change_Order_SID__c);
    }

    @isTest static void orderchangeTest(){

        TAMS_ROA__c roa = [Select 
                            Id
                           ,ROA_Type__c
                       From 
                          TAMS_ROA__c
                       Where 
                           Change_Order_SID__c = '34563170'];
    ApexPages.standardController stdCon = new ApexPages.standardController(roa);
   ChangeOrderDeleteActionCTRL deleteitem = new ChangeOrderDeleteActionCTRL(stdCon);
       Order_Line_Master__c orderlinemaster = [select Line_Number__c  From Order_Line_Master__c Where Line_ID__c = 101921037];
       TAMS_ROA_Lines__c changeOrderLines = [Select List_Price__c,New_Selling_Price__c From TAMS_ROA_Lines__c Where Action_Type__c = 'Delete'];
     //ChangeOrderDeleteActionCTRL.ChangeOrderLinesWRP changeOrderLine = new ChangeOrderDeleteActionCTRL.ChangeOrderLinesWRP(orderlinemaster,true,changeOrderLines);
       deleteitem.selectorders1 = 'None';
       deleteitem.orderchange();        
       System.assertEquals(null,deleteitem.modality);
       System.assertEquals(null,deleteitem.orderBookedDate);
       System.assertEquals(null,deleteitem.orderType);
       System.assertEquals(null,deleteitem.orderStatus);
       System.assertEquals(null,deleteitem.orderBookedAmount);
    }

    @isTest static void orderchangeErrorTest(){

    TAMS_ROA__c roa = [Select 
                            Id
                           ,ROA_Type__c
                       From 
                          TAMS_ROA__c
                       Where 
                           Change_Order_SID__c = '34563170'];
    ApexPages.standardController stdCon = new ApexPages.standardController(roa);
   ChangeOrderDeleteActionCTRL deleteitem = new ChangeOrderDeleteActionCTRL(stdCon);
    Order_Line_Master__c orderlinemaster = [select Line_Number__c,Item_Selling_Price__c,Quantity__c,Status__c,Item_List_Price__c,Ordered_Item__c,Item_Description__c  From Order_Line_Master__c Where Line_ID__c = 101921037];
       TAMS_ROA_Lines__c changeOrderLines = [Select List_Price__c,New_Selling_Price__c,Quantity__c,COL_New_Item__r.Name,COL_Quantity__c  From TAMS_ROA_Lines__c Where Action_Type__c = 'Delete'];
       Decimal listprice = changeOrderLines.List_Price__c;
       Decimal sellingprice = changeOrderLines.New_Selling_Price__c;
       Decimal quantity = changeOrderLines.Quantity__c;
       ChangeOrderLinesWRP deletechangeorderCon = new ChangeOrderLinesWRP(listprice,sellingprice,quantity);
        ChangeOrderLinesWRP deletechangeorder = new ChangeOrderLinesWRP(orderlinemaster,false,changeOrderLines);
        deleteitem.orderLines.add(deletechangeorder);
        deleteitem.getord();
       deleteitem.selectorders1 = '10012345';
       deleteitem.orderchange();  
       Order_Master__c ordmaster = [Select 
                                          Modality_Order__c
                                         ,CMSU_Booked_Date__c
                                         ,Order_Type__c
                                         ,Order_Status__c
                                         ,Order_Subtotal__c 
                                    From 
                                          Order_Master__c 
                                    Where 
                                          Oracle_Order_Number__c = '10012345' ];       
       System.assertEquals('UL',ordmaster.Modality_Order__c);
       System.assertEquals(System.today(),ordmaster.CMSU_Booked_Date__c);
       System.assertEquals('TEST 123',ordmaster.Order_Type__c);
       System.assertEquals('Booked',ordmaster.Order_Status__c);
       System.assertEquals(0.00,ordmaster.Order_Subtotal__c);
  }
  @isTest static void checkboxchangedTest(){

        TAMS_ROA__c roa = [Select 
                            Id
                           ,ROA_Type__c
                       From 
                          TAMS_ROA__c
                       Where 
                           Change_Order_SID__c = '34563170'];

        TAMS_ROA_Lines__c changeorderlines = new TAMS_ROA_Lines__c();
        changeorderlines.Action_Type__c = 'Delete';
        changeorderlines.TAMS_ROA__c = roa.Id;
        changeorderlines.List_Price__c = 2000;
        changeorderlines.New_Selling_Price__c = 0;
        changeorderlines.Quantity__c = 0;
        changeorderlines.Item_Description__c = 'testDescription';
        insert changeorderlines;

    ApexPages.standardController stdCon = new ApexPages.standardController(roa);
   ChangeOrderDeleteActionCTRL deleteitem = new ChangeOrderDeleteActionCTRL(stdCon);
       Order_Line_Master__c orderlinemaster = [select Line_Number__c,Item_Selling_Price__c,Quantity__c,Status__c,Item_List_Price__c,Ordered_Item__c,Item_Description__c  From Order_Line_Master__c Where Line_ID__c = 101921037];
       TAMS_ROA_Lines__c testchangeOrderLines = [Select List_Price__c,New_Selling_Price__c,Quantity__c,COL_New_Item__r.Name,COL_Quantity__c From TAMS_ROA_Lines__c Where Action_Type__c = 'Delete' AND Quantity__c = 0 ];
       ChangeOrderLinesWRP deletechangeorder = new ChangeOrderLinesWRP(orderlinemaster,true,testchangeOrderLines);
       deleteitem.orderLines.add(deletechangeorder);
        deleteitem.selectorders1 = '10012345';
       deleteitem.checkboxChanged();        
       System.assertEquals('10012345',deleteitem.selectorders1);
    }

     @isTest static void selectAllTest() {
        // Implement test code
         TAMS_ROA__c roa = [Select Id From TAMS_ROA__c Where Change_Order_SID__c = '34563170'];
         ApexPages.standardController stdCon = new ApexPages.standardController(roa);
         ChangeOrderDeleteActionCTRL deleteitem = new ChangeOrderDeleteActionCTRL(stdCon);
         Order_Line_Master__c orderlinemaster = [select Line_Number__c,Item_Selling_Price__c,Quantity__c,Status__c,Item_List_Price__c,Ordered_Item__c,Item_Description__c   From Order_Line_Master__c Where Line_ID__c = 101921037];
         TAMS_ROA_Lines__c changeOrderLines = [Select Id,List_Price__c,New_Selling_Price__c,Quantity__c,COL_New_Item__r.Name,COL_Quantity__c  From TAMS_ROA_Lines__c Where Action_Type__c = 'Delete' ];
         ChangeOrderLinesWRP deletechangeorder = new ChangeOrderLinesWRP(orderlinemaster,true,changeOrderLines);
         deleteitem.orderLines.add(deletechangeorder);   
         System.debug('deleteitem.orderLines'+deleteitem.orderLines);
         deleteitem.selectAll = false;
         deleteitem.selectorders1 = '10012345';
         deleteitem.selectAll();
        System.assertEquals('10012345',deleteitem.selectorders1);

    }
    @isTest static void cancelTest() {
    // Implement test code
      TAMS_ROA__c roa = [Select 
                            Id
                           ,ROA_Type__c
                       From 
                          TAMS_ROA__c
                       Where 
                           Change_Order_SID__c = '34563170'];
    ApexPages.standardController stdCon = new ApexPages.standardController(roa);
    ChangeOrderDeleteActionCTRL deleteitem = new ChangeOrderDeleteActionCTRL(stdCon);
    PageReference newPage =  deleteitem.cancel();
    System.assertEquals(newPage.getUrl(),'/'+roa.ID);
    
  }
   @isTest static void StatusTest() {
      TAMS_ROA__c roa = [Select 
                            Id
                           ,ROA_Type__c
                           ,Status__c
                       From 
                          TAMS_ROA__c
                       Where 
                           Change_Order_SID__c = '34563170'];
        roa.Status__c = 'Pending CFO Approval';  
        update roa;                 
    ApexPages.standardController stdCon = new ApexPages.standardController(roa);
    ChangeOrderDeleteActionCTRL deleteitem = new ChangeOrderDeleteActionCTRL(stdCon);
    System.assertEquals('Pending CFO Approval',roa.Status__c);
    }
}