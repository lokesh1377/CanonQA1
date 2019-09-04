@isTest
private class ChangeOrderReplaceActionCTRLTest {
    
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
        itemmaster.Name = 'Test123';
        itemmaster.Description__c = 'testDescription';
        itemmaster.Item_Type__c = 'TESTITEMTYPE';
        itemmaster.Discountable__c = 'Y';
        itemmaster.Status_Code__c = 'Active';
        itemmaster.Inventory_Item_Id__c = '1234';
        insert itemmaster;

         Price_List__c priceList = new Price_List__c();
        priceList.Line_Precedence__c = '200';
        priceList.Price_List_Name__c = 'TAMS PARTS PRICE LIST';
        priceList.Item__c = itemmaster.ID;
        priceList.Line_Start_Date__c = System.now();
        priceList.Line_End_Date__c = null;
        priceList.List_Price__c = 20000;
        insert priceList;

        Price_List__c priceListPH = new Price_List__c();
         priceListPH.Line_Precedence__c = '200';
        priceListPH.Price_List_Name__c = 'ABC123';
        priceListPH.Item__c = itemmaster.ID;
       priceListPH.Line_Start_Date__c = System.now();
        priceListPH.Line_End_Date__c = null;
        priceListPH.List_Price__c = 1000;
        insert priceListPH;
   
        Price_List_Hierarchy__c priceListHierarchy = new Price_List_Hierarchy__c();
        priceListHierarchy.Parent_Price_List_Name__c = 'TestPriceList';
        priceListHierarchy.Child_Price_List_Name__c = 'TestPriceListchild'; 
        priceListHierarchy.Precedence__c = 200;
        priceListHierarchy.Start_Date_Active__c = system.today();
        priceListHierarchy.End_Date_Active__c = null;
        insert priceListHierarchy;

         TAMS_ROA_Lines__c changeorderlines = new TAMS_ROA_Lines__c();
        changeorderlines.Action_Type__c = 'Replace';
        changeorderlines.TAMS_ROA__c = roa.Id;
        changeorderlines.List_Price__c = 2000;
        changeorderlines.Order_Number__c= '10012345';
        changeorderlines.New_Selling_Price__c = 1;
        changeorderlines.Quantity__c = 1;
        changeorderlines.COL_Reason_Code__c = 'Configuration';
        changeorderlines.COL_RMA__c = true;
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
                ChangeOrderReplaceActionCTRL replaceitem = new ChangeOrderReplaceActionCTRL(stdCon);
               List<SelectOption> lActualSelectedOptions = replaceitem.getord();
               List<SelectOption> lExpectedSelectOptions = new List<SelectOption>();
               lExpectedSelectOptions.add(new SelectOption('None','None'));
               lExpectedSelectOptions.add(new SelectOption('10012345','10012345'));
               lExpectedSelectOptions.add(new SelectOption('10123450','10123450'));

               System.assertEquals(lExpectedSelectOptions,lActualSelectedOptions);
    }

    @isTest static void saveTestpH() {
        // Implement test code
       TAMS_ROA__c roa = [Select Id,Change_Order_SID__c From TAMS_ROA__c Where Change_Order_SID__c = '34563170'];
       ApexPages.standardController stdCon = new ApexPages.standardController(roa);
       ChangeOrderReplaceActionCTRL replaceitem = new ChangeOrderReplaceActionCTRL(stdCon);
       Order_Line_Master__c orderlinemaster = [select Line_Number__c,Item_Selling_Price__c,Quantity__c,Status__c,Item_List_Price__c,Ordered_Item__c,Item_Description__c From Order_Line_Master__c Where Line_ID__c = 101921037];
       TAMS_ROA_Lines__c changeOrderLines = [Select List_Price__c,New_Selling_Price__c,Quantity__c,COL_Comments__c,COL_New_Item__r.Name,COL_Quantity__c,COL_RMA__c,COL_Reason_Code__c  From TAMS_ROA_Lines__c Where Action_Type__c = 'Replace'];
       ItemMaster__c itemmaster = [Select Id,Name,Description__c,Discountable__c From ItemMaster__c Where Inventory_Item_Id__c = '1234'];  
       ChangeOrderLinesWRP replacechangeorder = new ChangeOrderLinesWRP(orderlinemaster,true,changeOrderLines);
       replaceitem.orderLines.add(replacechangeorder);
       replaceitem.selectorders1 = '10012345';
       replaceitem.save();
       System.assertEquals('34563170',roa.Change_Order_SID__c);
    }

    @isTest static void saveTestpp() {
        // Implement test code
       TAMS_ROA__c roa = [Select Id,Change_Order_SID__c From TAMS_ROA__c Where Change_Order_SID__c = '34563170'];
       ApexPages.standardController stdCon = new ApexPages.standardController(roa);
       ChangeOrderReplaceActionCTRL replaceitem = new ChangeOrderReplaceActionCTRL(stdCon);
       Order_Line_Master__c orderlinemaster = [select Line_Number__c,Item_Selling_Price__c,Quantity__c,Status__c,Item_List_Price__c,Ordered_Item__c,Item_Description__c From Order_Line_Master__c Where Line_ID__c = 101921037];
       TAMS_ROA_Lines__c changeOrderLines = [Select List_Price__c,New_Selling_Price__c,Quantity__c,COL_Comments__c,COL_New_Item__r.Name,COL_Quantity__c,COL_RMA__c,COL_Reason_Code__c  From TAMS_ROA_Lines__c Where Action_Type__c = 'Replace'];
       ItemMaster__c itemmaster = [Select Id,Name,Description__c,Discountable__c From ItemMaster__c Where Inventory_Item_Id__c = '1234'];
        List<Price_List__c> lpriceList = [Select Id,List_Price__c From Price_List__c Where Price_List_Name__c = 'TAMS PARTS PRICE LIST' AND Item__c =: itemmaster.id AND Line_End_Date__c = null];
       Decimal listprice = lpriceList.get(0).List_Price__c;
       System.debug('listprice'+listprice);
       ChangeOrderLinesWRP replacechangeorder = new ChangeOrderLinesWRP(orderlinemaster,true,changeOrderLines);
       replaceitem.orderLines.add(replacechangeorder);
       replaceitem.selectorders1 = '10012345';
       replaceitem.save();
       System.assertEquals('34563170',roa.Change_Order_SID__c);
    }

     @isTest static void lookupIdTest(){

        TAMS_ROA__c roa = [Select 
                            Id
                           ,ROA_Type__c
                           ,Change_Order_SID__c
                       From 
                          TAMS_ROA__c
                       Where 
                           Change_Order_SID__c = '34563170'];
      ItemMaster__c itemmaster = [Select Id,Name,Description__c,Discountable__c From ItemMaster__c Where Inventory_Item_Id__c = '1234'];
      system.debug('itemmaster:'+itemmaster);
      ApexPages.standardController stdCon = new ApexPages.standardController(roa);
      ChangeOrderReplaceActionCTRL replaceitem = new ChangeOrderReplaceActionCTRL(stdCon);
       Test.setCurrentPage(Page.ChangeOrderReplaceActionVF);
        ApexPages.currentPage().getParameters().put('selectedItemNumber',itemmaster.Name);
        replaceitem.itemMasterId = itemmaster.id;
        replaceitem.selectorders1 = '10012345';
        replaceitem.lookupId();
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
   ChangeOrderReplaceActionCTRL replaceitem = new ChangeOrderReplaceActionCTRL(stdCon);
       Order_Line_Master__c orderlinemaster = [select Line_Number__c  From Order_Line_Master__c Where Line_ID__c = 101921037];
       TAMS_ROA_Lines__c changeOrderLines = [Select List_Price__c,New_Selling_Price__c From TAMS_ROA_Lines__c Where Action_Type__c = 'Replace'];
     //ChangeOrderDeleteActionCTRL.ChangeOrderLinesWRP changeOrderLine = new ChangeOrderDeleteActionCTRL.ChangeOrderLinesWRP(orderlinemaster,true,changeOrderLines);
       replaceitem.selectorders1 = 'None';
       replaceitem.orderchange();        
       System.assertEquals(null,replaceitem.modality);
       System.assertEquals(null,replaceitem.orderBookedDate);
       System.assertEquals(null,replaceitem.orderType);
       System.assertEquals(null,replaceitem.orderStatus);
       System.assertEquals(null,replaceitem.orderBookedAmount);
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
   ChangeOrderReplaceActionCTRL replaceitem = new ChangeOrderReplaceActionCTRL(stdCon);
    Order_Line_Master__c orderlinemaster = [select Line_Number__c,Item_Selling_Price__c,Quantity__c,Status__c,Item_List_Price__c,Ordered_Item__c,Item_Description__c  From Order_Line_Master__c Where Line_ID__c = 101921037];
       TAMS_ROA_Lines__c changeOrderLines = [Select List_Price__c,New_Selling_Price__c,Quantity__c,COL_New_Item__r.Name,COL_Quantity__c  From TAMS_ROA_Lines__c Where Action_Type__c = 'Replace'];
       Decimal listprice = changeOrderLines.List_Price__c;
       Decimal sellingprice = changeOrderLines.New_Selling_Price__c;
       Decimal quantity = changeOrderLines.Quantity__c;
       ChangeOrderLinesWRP replacechangeorderCon = new ChangeOrderLinesWRP(listprice,sellingprice,quantity);
        ChangeOrderLinesWRP replacechangeorder = new ChangeOrderLinesWRP(orderlinemaster,false,changeOrderLines);
        replaceitem.orderLines.add(replacechangeorder);
        replaceitem.getord();
       replaceitem.selectorders1 = '10012345';
       replaceitem.orderchange();  
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

   @isTest static void orderchangeErrorTestchangeorder(){

    TAMS_ROA__c roa = [Select 
                            Id
                           ,ROA_Type__c
                       From 
                          TAMS_ROA__c
                       Where 
                           Change_Order_SID__c = '34563170'];
    ApexPages.standardController stdCon = new ApexPages.standardController(roa);
   ChangeOrderReplaceActionCTRL replaceitem = new ChangeOrderReplaceActionCTRL(stdCon);
    Order_Line_Master__c orderlinemaster = [select Line_Number__c,Item_Selling_Price__c,Quantity__c,Status__c,Item_List_Price__c,Ordered_Item__c,Item_Description__c  From Order_Line_Master__c Where Line_ID__c = 101921037];
       TAMS_ROA_Lines__c changeOrderLines = [Select List_Price__c,New_Selling_Price__c,Quantity__c,COL_New_Item__r.Name,COL_Quantity__c  From TAMS_ROA_Lines__c Where Action_Type__c = 'Replace'];
       Decimal listprice = changeOrderLines.List_Price__c;
       Decimal sellingprice = changeOrderLines.New_Selling_Price__c;
       Decimal quantity = changeOrderLines.Quantity__c;
       ChangeOrderLinesWRP replacechangeorderCon = new ChangeOrderLinesWRP(listprice,sellingprice,quantity);
        ChangeOrderLinesWRP replacechangeorder = new ChangeOrderLinesWRP(orderlinemaster,true,changeOrderLines);
        replaceitem.orderLines.add(replacechangeorder);
        replaceitem.getord();
       replaceitem.selectorders1 = '10012345';
       replaceitem.orderchange();  
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

        

    ApexPages.standardController stdCon = new ApexPages.standardController(roa);
   ChangeOrderReplaceActionCTRL replaceitem = new ChangeOrderReplaceActionCTRL(stdCon);
       Order_Line_Master__c orderlinemaster = [select Line_Number__c,Item_Selling_Price__c,Quantity__c,Status__c,Item_List_Price__c,Ordered_Item__c,Item_Description__c  From Order_Line_Master__c Where Line_ID__c = 101921037];
       TAMS_ROA_Lines__c testchangeOrderLines = [Select List_Price__c,New_Selling_Price__c,Quantity__c,COL_New_Item__r.Name,COL_Quantity__c From TAMS_ROA_Lines__c Where Action_Type__c = 'Replace'];
       ChangeOrderLinesWRP replacechangeorder = new ChangeOrderLinesWRP(orderlinemaster,true,testchangeOrderLines);
        replaceitem.orderLines.add(replacechangeorder);
        replaceitem.selectorders1 = '10012345';
        replacechangeorder.deleteQuantity = 0;
        replacechangeorder.selected = true;
        replaceitem.checkboxChanged();        
       System.assertEquals('10012345',replaceitem.selectorders1);
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
    ChangeOrderReplaceActionCTRL replaceitem = new ChangeOrderReplaceActionCTRL(stdCon);
    PageReference newPage =  replaceitem.cancel();
    System.assertEquals(newPage.getUrl(),'/'+roa.ID);
    
  } 
}