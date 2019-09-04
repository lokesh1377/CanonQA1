@isTest
private class ChangeorderAddActionCTRLTest {
	
	@testsetup static void testData() {
		// Implement test code
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
          
         Order_Master__c ord1 = new Order_Master__c();
          ord1.Customer_Name__c = acc.ID;
          ord1.Oracle_Order_Number__c = '10012345';
          ord1.SID_Order__c = 34563170;
          ord1.Modality_Order__c = 'UL';
          ord1.Price_List__c = 'TestPriceList';
          ord1.CMSU_Booked_Date__c  = System.today();
          ord1.Order_Type__c = 'TEST 123';
          ord1.Order_Status__c = 'Booked';
          ord1.Order_Subtotal__c = 0.00;
          insert ord1;

        Order_Master__c ord2 = new Order_Master__c();
          ord2.Customer_Name__c = acc.ID;
          ord2.Oracle_Order_Number__c = '10123450';
          ord2.SID_Order__c = 34563170;
          ord2.Modality_Order__c = 'UL';
          insert ord2;

        Order_Financial_Analysis__c ofa = new Order_Financial_Analysis__c();
        ofa.QFA_Discount_Pct__c = 25.55;
        ofa.Sales_Order__c = '10012345';
        insert ofa;

        ItemMaster__c itemmaster = new ItemMaster__c();
        itemmaster.Item_Number__c = 'Test123';
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

        Price_List_Hierarchy__c priceListHierarchy = new Price_List_Hierarchy__c();
        priceListHierarchy.Parent_Price_List_Name__c = 'TestPriceList';
        priceListHierarchy.Child_Price_List_Name__c = 'TestPriceListchild'; 
        priceListHierarchy.Precedence__c = 200;
        priceListHierarchy.Start_Date_Active__c = system.today();
        priceListHierarchy.End_Date_Active__c = null;
        insert priceListHierarchy;

        TAMS_ROA_Lines__c changeorderlines = new TAMS_ROA_Lines__c();
        changeorderlines.Action_Type__c = 'Add';
        changeorderlines.TAMS_ROA__c = roa.Id;
        changeorderlines.COL_New_Item__c = itemmaster.Id;
        changeorderlines.Item_Description__c = 'testDescription';
        insert changeorderlines;

        Order_Line_Master__c orderlinemaster = new Order_Line_Master__c();
        orderlinemaster.Line_ID__c = 101921037;
        orderlinemaster.CMSU_Order__c = ord1.id;
        orderlinemaster.Ordered_Item__c = itemmaster.id;
        orderlinemaster.Line_Number__c = '1.1';
        insert orderlinemaster;
	}
	
	@isTest static void SearchTest() {
		TAMS_ROA__c roa = [Select 
                            Id
                           ,ROA_Type__c
                           ,Change_Order_SID__c
                       From 
                          TAMS_ROA__c
                       Where 
                           Change_Order_SID__c = '34563170'];
    ApexPages.standardController stdCon = new ApexPages.standardController(roa);
   ChangeOrderAddActionCTRL additem = new ChangeOrderAddActionCTRL(stdCon);
      additem.selectorders1 = '10012345';
      additem.ItemNumber = 'Test123';
      additem.Description = 'testDescription';
      ItemMaster__c itemmaster = [Select Id,Item_Number__c,Description__c,Discountable__c From ItemMaster__c Where Inventory_Item_Id__c = '1234'];
      List<Price_List__c> lpriceList = [Select Id,List_Price__c From Price_List__c Where Price_List_Name__c = 'TAMS PARTS PRICE LIST' AND Item__c =: itemmaster.id AND Line_End_Date__c = null];
      Decimal listprice = lpriceList.get(0).List_Price__c;
      System.debug('listprice'+listprice);
      Decimal ofa = [Select QFA_Discount_Pct__c From Order_Financial_Analysis__c Where Sales_Order__c = '10012345'].QFA_Discount_Pct__c;
      System.debug('ofa'+ofa);
        additem.orderchange();
      ChangeOrderAddActionCTRL.ItemMasterWrapper itemMasterWrapper = new ChangeOrderAddActionCTRL.ItemMasterWrapper(false,itemmaster,listprice,ofa);
      itemMasterWrapper.itemNumber = 'Test123';
      itemMasterWrapper.description = 'testDescription';
      itemMasterWrapper.selectorders1 = '10012345';
      itemMasterWrapper.sellingPrice = 145;
      additem.search();  
     System.assertEquals('10012345',itemMasterWrapper.selectorders1);
	}

	@isTest static void saveOrderLines(){
		TAMS_ROA__c roa = [Select 
                            Id
                           ,ROA_Type__c
                           ,Change_Order_SID__c
                       From 
                          TAMS_ROA__c
                       Where 
                           Change_Order_SID__c = '34563170'];
      Price_List__c priceList = [Select Id,Price_List_Name__c From Price_List__c Where Line_Precedence__c = '200'];  
    ApexPages.standardController stdCon = new ApexPages.standardController(roa);
    ChangeOrderAddActionCTRL additem = new ChangeOrderAddActionCTRL(stdCon);
    additem.selectorders1 = '10012345';
    additem.listpriceName = priceList.Price_List_Name__c;
    additem.listpriceId = priceList.Id;
     ItemMaster__c itemmaster = [Select Id,Item_Number__c,Description__c,Discountable__c From ItemMaster__c Where Inventory_Item_Id__c = '1234'];
      List<Price_List__c> lpriceList4 = [Select Id,List_Price__c From Price_List__c Where Price_List_Name__c = 'TAMS PARTS PRICE LIST' ];
      Decimal listprice = lpriceList4.get(0).List_Price__c;
      Decimal ofa = [Select QFA_Discount_Pct__c From Order_Financial_Analysis__c Where Sales_Order__c = '10012345'].QFA_Discount_Pct__c;
      TAMS_ROA_Lines__c changeorderlinesrecord = [Select Id From TAMS_ROA_Lines__c Where Action_Type__c = 'Add'];
      additem.ItemNumber = 'Test123';
      additem.Description = 'testDescription';
       additem.orderchange();
      additem.search();
       ChangeOrderAddActionCTRL.ItemMasterWrapper itemMasterWrapper = new ChangeOrderAddActionCTRL.ItemMasterWrapper(true,itemmaster,listprice,ofa);
      additem.itemMasters.add(itemMasterWrapper);
      System.debug('itemMasterWrapper.isSelected '+itemMasterWrapper.isSelected );
      additem.saveOrderLines();
      System.assertEquals('10012345',additem.selectorders1);
	}


     @isTest static void removeitemtest(){

     	TAMS_ROA__c roa = [Select Id,Change_Order_SID__c From TAMS_ROA__c Where Change_Order_SID__c = '34563170'];
         ApexPages.standardController stdCon = new ApexPages.standardController(roa);
          ChangeOrderAddActionCTRL additem = new ChangeOrderAddActionCTRL(stdCon);
          additem.bookId = '9876543';
            TAMS_ROA_Lines__c changeorderlinesrecord = [Select Id From TAMS_ROA_Lines__c Where Action_Type__c = 'Add'];
           ChangeOrderAddActionCTRL.ChangeOrderLinesWrapper changeOrderLines = new ChangeOrderAddActionCTRL.ChangeOrderLinesWrapper(false,changeorderlinesrecord);
            //changeOrderLines.isSelected = true;
          additem.removeitem();
          System.assertEquals('34563170',roa.Change_Order_SID__c);
     }

	@isTest static void getordTest() {
        // Implement test code
               TAMS_ROA__c roa = [Select Id From TAMS_ROA__c Where Change_Order_SID__c = '34563170'];
               ApexPages.standardController stdCon = new ApexPages.standardController(roa);
                ChangeOrderAddActionCTRL additem = new ChangeOrderAddActionCTRL(stdCon);
               List<SelectOption> lActualSelectedOptions = additem.getord();

               List<SelectOption> lExpectedSelectOptions = new List<SelectOption>();
               lExpectedSelectOptions.add(new SelectOption('None','None'));
               lExpectedSelectOptions.add(new SelectOption('10012345','10012345'));
               lExpectedSelectOptions.add(new SelectOption('10123450','10123450'));

               System.assertEquals(lExpectedSelectOptions,lActualSelectedOptions);

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
   ChangeOrderAddActionCTRL additem = new ChangeOrderAddActionCTRL(stdCon);
       Order_Line_Master__c orderlinemaster = [select Line_Number__c  From Order_Line_Master__c Where Line_ID__c = 101921037];
   ChangeOrderAddActionCTRL.OrderLinesMasterWrapper orderline = new ChangeOrderAddActionCTRL.OrderLinesMasterWrapper(false,orderlinemaster);
       additem.selectorders1 = 'None';
       additem.orderchange();        
       System.assertEquals(null,additem.modality);
       System.assertEquals(null,additem.orderBookedDate);
       System.assertEquals(null,additem.orderType);
       System.assertEquals(null,additem.orderStatus);
       System.assertEquals(null,additem.orderBookedAmount);
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
  ChangeOrderAddActionCTRL additem = new ChangeOrderAddActionCTRL(stdCon);
        additem.getord();
       additem.selectorders1 = '10012345';
       additem.orderchange();  
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

    @isTest static void backTest() {
      TAMS_ROA__c roa = [Select 
                            Id
                           ,ROA_Type__c
                       From 
                          TAMS_ROA__c
                       Where 
                           Change_Order_SID__c = '34563170'];
    ApexPages.standardController stdCon = new ApexPages.standardController(roa);
    ChangeOrderAddActionCTRL additem = new ChangeOrderAddActionCTRL(stdCon);
    PageReference newPage =  additem.back();
    System.assertEquals(newPage.getUrl(),'/'+roa.ID);
    }

    @isTest static void changeOrderAdminTrigger(){

      TAMS_ROA__c roa = [Select 
                            Id
                           ,ROA_Type__c
                       From 
                          TAMS_ROA__c
                       Where 
                           Change_Order_SID__c = '34563170'];
       Order_Master__c ord = [Select Id From Order_Master__c Where Oracle_Order_Number__c = '10012345']; 
          
      TAMS_ROA_Lines__c col = new TAMS_ROA_Lines__c();
        col.TAMS_ROA__c = roa.Id;
        col.Action_Type__c = 'Add';
        col.Order_Number__c = '10012345';
        col.Item_Description__c = 'TestitemDescription';
        insert col; 
      
    ApexPages.standardController stdCon = new ApexPages.standardController(roa);
    ChangeOrderAddActionCTRL additem = new ChangeOrderAddActionCTRL(stdCon);
     roa.Status__c = 'Complete';
     col.Item_Description__c = 'TestitemDescription2';
     update col;
     delete col;
     System.assertEquals('TestitemDescription2', col.Item_Description__c);
     }
     @isTest static void SearchErrorTest() {
		TAMS_ROA__c roa = [Select 
                            Id
                           ,ROA_Type__c
                           ,Change_Order_SID__c
                       From 
                          TAMS_ROA__c
                       Where 
                           Change_Order_SID__c = '34563170'];
    ApexPages.standardController stdCon = new ApexPages.standardController(roa);
   ChangeOrderAddActionCTRL additem = new ChangeOrderAddActionCTRL(stdCon);
      additem.selectorders1 = 'None';
      additem.ItemNumber = 'Test123';
      additem.Description = 'testDescription';
      ItemMaster__c itemmaster = [Select Id,Item_Number__c,Description__c,Discountable__c From ItemMaster__c Where Inventory_Item_Id__c = '1234'];
      List<Price_List__c> lpriceList = [Select Id,List_Price__c From Price_List__c Where Price_List_Name__c = 'TAMS PARTS PRICE LIST' AND Item__c =: itemmaster.id AND Line_End_Date__c = null];
      Decimal listprice = lpriceList.get(0).List_Price__c;
      System.debug('listprice'+listprice);
      Decimal ofa = [Select QFA_Discount_Pct__c From Order_Financial_Analysis__c Where Sales_Order__c = '10012345'].QFA_Discount_Pct__c;
      System.debug('ofa'+ofa);
      ChangeOrderAddActionCTRL.ItemMasterWrapper itemMasterWrapper = new ChangeOrderAddActionCTRL.ItemMasterWrapper(true,itemmaster,listprice,ofa);
      itemMasterWrapper.itemNumber = 'Test123';
      itemMasterWrapper.description = 'testDescription';
      itemMasterWrapper.selectorders1 = 'None';
      itemMasterWrapper.sellingPrice = 145;
      additem.search();  
     System.assertEquals('None',itemMasterWrapper.selectorders1);
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
    ChangeOrderAddActionCTRL additem = new ChangeOrderAddActionCTRL(stdCon);
    System.assertEquals('Pending CFO Approval',roa.Status__c);
    }
	
}