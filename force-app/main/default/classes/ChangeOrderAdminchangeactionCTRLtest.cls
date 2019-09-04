@isTest
private class ChangeOrderAdminchangeactionCTRLtest {
    
    @testsetup static void testData() {
        // Implement test data
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

        Order_Master__c ord2 = new Order_Master__c();
          ord2.Customer_Name__c = acc.ID;
          ord2.Oracle_Order_Number__c = '10123450';
          ord2.SID_Order__c = 34563170;
          ord2.Modality_Order__c = 'UL';
          insert ord2;
          
       TAMS_ROA__c roa = new TAMS_ROA__c();
         roa.Account__c = acc.Id;
         roa.ROA_Type__c = 'Administrative Changes';
         roa.Change_Order_SID__c = '34563170';
         roa.Status__c = 'New';
         insert roa;

         Order_Master__c ord = [select Id from Order_Master__c Where Oracle_Order_Number__c = '10012345'];
            
       TAMS_Order_Sales_Credit__c osc = new TAMS_Order_Sales_Credit__c();
           osc.Name = '2939';
           osc.Percentage__c = 100;
           osc.Credit_Type__c = 'AE1 Billing';
           osc.Sales_Credit_ID__c = 2921;
           osc.Salesrep_Name__c = 'Alex Thomas';
           osc.Order_Master__c = ord.Id;
           osc.Oracle_Order_Number__c = '10012345';
           insert osc;
        
       Profile profileId = [SELECT Id FROM Profile WHERE Name = 'Standard User' LIMIT 1];

        User usr = new User();
           usr.LastName = 'Canon';
           usr.FirstName='Canon';
           usr.Alias = 'jliv';
           usr.Email = 'CastIron.Canon@us.medical.canon.com';
           usr.Username = 'CastIron.Canon@us.medical.canon.com';
           usr.ProfileId = profileId.id;
           usr.TimeZoneSidKey = 'GMT';
           usr.LanguageLocaleKey = 'en_US';
           usr.EmailEncodingKey = 'UTF-8';
           usr.LocaleSidKey = 'en_US';
           insert usr;
          
       Customer_Account_Master__c cAM = new Customer_Account_Master__c();
         cAM.Name = 'Test123';
         cAM.CAM_Account_Status__c = 'Active';
         cAM.CAM_Account_Number__c = '54321';
           insert cAM;

          Id camId = [select Id from Customer_Account_Master__c Where CAM_Account_Number__c = '54321'].Id;

      Customer_Site_Master__c csm = new Customer_Site_Master__c();
          csm.Name = 'Test-321';  
          csm.CSM_Customer_Name__c = camId;
          //csm.CSM_Site_Address__c = '';
          insert csm;
    } 
    @isTest static void getordTest() {
        // Implement test code
               TAMS_ROA__c roa = [Select Id From TAMS_ROA__c Where Change_Order_SID__c = '34563170'];
               ApexPages.standardController stdCon = new ApexPages.standardController(roa);
               ChangeOrderAdminchangeactionCTRL adminChange = new ChangeOrderAdminchangeactionCTRL(stdCon);
               List<SelectOption> lActualSelectedOptions = adminChange.getord();

               List<SelectOption> lExpectedSelectOptions = new List<SelectOption>();
               lExpectedSelectOptions.add(new SelectOption('--None--','--None--'));
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
   ChangeOrderAdminchangeactionCTRL adminChange = new ChangeOrderAdminchangeactionCTRL(stdCon);
       adminChange.selectorders1 = '--None--';
       adminChange.orderchange();        
       System.assertEquals(null,adminChange.modality);
       System.assertEquals(null,adminChange.orderBookedDate);
       System.assertEquals(null,adminChange.orderType);
       System.assertEquals(null,adminChange.orderStatus);
       System.assertEquals(null,adminChange.orderBookedAmount);
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
    ChangeOrderAdminchangeactionCTRL adminChange = new ChangeOrderAdminchangeactionCTRL(stdCon);
        adminChange.getord();
       adminChange.selectorders1 = '10012345';
       adminChange.orderchange();  
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

    @isTest static void changetypeTest(){

      TAMS_ROA__c roa = [Select 
                            Id
                           ,ROA_Type__c
                       From 
                          TAMS_ROA__c
                       Where 
                           Change_Order_SID__c = '34563170'];
    ApexPages.standardController stdCon = new ApexPages.standardController(roa);
    ChangeOrderAdminchangeactionCTRL adminChange = new ChangeOrderAdminchangeactionCTRL(stdCon);
    
       adminChange.selectorders1 = '10012345';
       adminChange.cOrdAdminChange.COAC_Change_Type__c = 'Bill To';
       adminChange.changetype();
       System.assertEquals(true,adminChange.showBillTo);

       adminChange.cOrdAdminChange.COAC_Change_Type__c = 'Ship To';
       adminChange.changetype();        
       System.assertEquals(true,adminChange.showShipTo);

       adminChange.cOrdAdminChange.COAC_Change_Type__c = 'PO #';
       adminChange.changetype();        
       System.assertEquals(true,adminChange.showPoNum);

       adminChange.cOrdAdminChange.COAC_Change_Type__c = 'Progressive Bill Term';
       adminChange.changetype();        
       System.assertEquals(true,adminChange.showProBillTerm);

       adminChange.cOrdAdminChange.COAC_Change_Type__c = 'Sales Channel';
       adminChange.changetype();        
       System.assertEquals(true,adminChange.showSalesChannel);

       adminChange.cOrdAdminChange.COAC_Change_Type__c = 'Shipping Method';
       adminChange.changetype();        
       System.assertEquals(true,adminChange.showShippingMethod);

       adminChange.cOrdAdminChange.COAC_Change_Type__c = 'Waive Down Payment';
       adminChange.changetype();        
       System.assertEquals(true,adminChange.showWaiveDownPayment);

       adminChange.cOrdAdminChange.COAC_Change_Type__c = 'Sales Credit';
       adminChange.changetype();        
       System.assertEquals(true,adminChange.showSalesCredit);

       adminChange.cOrdAdminChange.COAC_Change_Type__c = 'Other';
       adminChange.changetype();        
       System.assertEquals(true,adminChange.showOther);

       adminChange.cOrdAdminChange.COAC_Change_Type__c = 'GPO Admin Fee';
       adminChange.changetype();        
       System.assertEquals(true,adminChange.showGPOFees);
    }


    @isTest static void changetypeErrorTest(){

      TAMS_ROA__c roa = [Select 
                            Id
                           ,ROA_Type__c
                       From 
                          TAMS_ROA__c
                       Where 
                           Change_Order_SID__c = '34563170'];
    ApexPages.standardController stdCon = new ApexPages.standardController(roa);
    ChangeOrderAdminchangeactionCTRL adminChange = new ChangeOrderAdminchangeactionCTRL(stdCon);
    
       adminChange.selectorders1 = '--None--';
       adminChange.cOrdAdminChange.COAC_Change_Type__c = 'Bill To';
       adminChange.changetype();
       System.assertEquals('--None--',adminChange.selectorders1);

       adminChange.cOrdAdminChange.COAC_Change_Type__c = 'Ship To';
       adminChange.changetype();        
       System.assertEquals('--None--',adminChange.selectorders1);

       adminChange.cOrdAdminChange.COAC_Change_Type__c = 'PO #';
       adminChange.changetype();        
       System.assertEquals('--None--',adminChange.selectorders1);

       adminChange.cOrdAdminChange.COAC_Change_Type__c = 'Progressive Bill Term';
       adminChange.changetype();        
       System.assertEquals('--None--',adminChange.selectorders1);

       adminChange.cOrdAdminChange.COAC_Change_Type__c = 'Sales Channel';
       adminChange.changetype();        
       System.assertEquals('--None--',adminChange.selectorders1);

       adminChange.cOrdAdminChange.COAC_Change_Type__c = 'Shipping Method';
       adminChange.changetype();        
       System.assertEquals('--None--',adminChange.selectorders1);

       adminChange.cOrdAdminChange.COAC_Change_Type__c = 'Waive Down Payment';
       adminChange.changetype();        
       System.assertEquals('--None--',adminChange.selectorders1);

       adminChange.cOrdAdminChange.COAC_Change_Type__c = 'Sales Credit';
       adminChange.changetype();        
       System.assertEquals('--None--',adminChange.selectorders1);

       adminChange.cOrdAdminChange.COAC_Change_Type__c = 'Other';
       adminChange.changetype();        
       System.assertEquals('--None--',adminChange.selectorders1);

       adminChange.cOrdAdminChange.COAC_Change_Type__c = 'GPO Admin Fee';
       adminChange.changetype();        
       System.assertEquals('--None--',adminChange.selectorders1);
    }


    @isTest static void changeTypeBillToTest(){
      TAMS_ROA__c roa = [Select 
                            Id
                           ,ROA_Type__c
                       From 
                          TAMS_ROA__c
                       Where 
                           Change_Order_SID__c = '34563170'];

      Customer_Account_Master__c cam = [Select Id,Name,CAM_Account_Number__c From Customer_Account_Master__c Where CAM_Account_Status__c = 'Active'];
      Customer_Site_Master__c csm = [Select Id,Name From Customer_Site_Master__c Where CSM_Customer_Name__c =: cam.Id];
       Order_Master__c ord = [Select Id From Order_Master__c Where Oracle_Order_Number__c = '10012345'];

      Change_Order_Administrative_Change__c cOACBillTo = new Change_Order_Administrative_Change__c();
      cOACBillTo.TAMS_ROA__c = roa.Id;
      cOACBillTo.COAC_New_Bill_To_Customer__c = cam.Id; 
      cOACBillTo.COAC_New_Bill_To__c = csm.Id;
      cOACBillTo.CMSU_Order__c = ord.Id;
      cOACBillTo.COAC_Change_Type__c = 'Bill To';
      cOACBillTo.COAC_Comments__c = 'TestBillTo';
        insert cOACBillTo;

        ApexPages.standardController stdCon = new ApexPages.standardController(roa);
         ChangeOrderAdminchangeactionCTRL adminChange = new ChangeOrderAdminchangeactionCTRL(stdCon);
         adminChange.selectorders1 = '10012345';
       adminChange.cOrdAdminChange.COAC_Change_Type__c = 'Bill To';
       adminChange.changetype();
       System.assertEquals(1,adminChange.mCOAdminstrativeChanges.size());
    }

      @isTest static void changeTypeShipToTest(){
      TAMS_ROA__c roa = [Select 
                            Id
                           ,ROA_Type__c
                       From 
                          TAMS_ROA__c
                       Where 
                           Change_Order_SID__c = '34563170'];

      Customer_Account_Master__c cam = [Select Id,Name,CAM_Account_Number__c From Customer_Account_Master__c Where CAM_Account_Status__c = 'Active'];
      Customer_Site_Master__c csm = [Select Id,Name From Customer_Site_Master__c Where CSM_Customer_Name__c =: cam.Id];
       Order_Master__c ord = [Select Id From Order_Master__c Where Oracle_Order_Number__c = '10012345'];

      Change_Order_Administrative_Change__c cOACShipTo = new Change_Order_Administrative_Change__c();
      cOACShipTo.TAMS_ROA__c = roa.Id;
      cOACShipTo.COAC_New_Ship_to_Customer__c = cam.Id;   
      cOACShipTo.COAC_New_Ship_To__c = csm.Id;   
      cOACShipTo.CMSU_Order__c = ord.Id;
      cOACShipTo.COAC_Change_Type__c = 'Ship To';
      cOACShipTo.COAC_Comments__c = 'TestShipTo';
        insert cOACShipTo;

        ApexPages.standardController stdCon = new ApexPages.standardController(roa);
         ChangeOrderAdminchangeactionCTRL adminChange = new ChangeOrderAdminchangeactionCTRL(stdCon);
         adminChange.selectorders1 = '10012345';
       adminChange.cOrdAdminChange.COAC_Change_Type__c = 'Ship To';
       adminChange.changetype();
       System.assertEquals(1,adminChange.mCOAdminstrativeChanges.size());
    }

     @isTest static void changeTypePoNumTest(){
      TAMS_ROA__c roa = [Select 
                            Id
                           ,ROA_Type__c
                       From 
                          TAMS_ROA__c
                       Where 
                           Change_Order_SID__c = '34563170'];

      Customer_Account_Master__c cam = [Select Id,Name,CAM_Account_Number__c From Customer_Account_Master__c Where CAM_Account_Status__c = 'Active'];
      Customer_Site_Master__c csm = [Select Id,Name From Customer_Site_Master__c Where CSM_Customer_Name__c =: cam.Id];
       Order_Master__c ord = [Select Id From Order_Master__c Where Oracle_Order_Number__c = '10012345'];

      Change_Order_Administrative_Change__c cOACPoNum = new Change_Order_Administrative_Change__c();
      cOACPoNum.TAMS_ROA__c = roa.Id;
      cOACPoNum.COAC_New_PO__c = '4567';
      cOACPoNum.CMSU_Order__c = ord.Id;
      cOACPoNum.COAC_Change_Type__c = 'PO #';
      cOACPoNum.COAC_Comments__c = 'TestPoNum';
        insert cOACPoNum;

        ApexPages.standardController stdCon = new ApexPages.standardController(roa);
         ChangeOrderAdminchangeactionCTRL adminChange = new ChangeOrderAdminchangeactionCTRL(stdCon);
         adminChange.selectorders1 = '10012345';
       adminChange.cOrdAdminChange.COAC_Change_Type__c = 'PO #';
       adminChange.changetype();
       System.assertEquals(1,adminChange.mCOAdminstrativeChanges.size());
    }

    @isTest static void changeTypeGPOAdminFeeTest(){
      TAMS_ROA__c roa = [Select 
                            Id
                           ,ROA_Type__c
                       From 
                          TAMS_ROA__c
                       Where 
                           Change_Order_SID__c = '34563170'];

      Customer_Account_Master__c cam = [Select Id,Name,CAM_Account_Number__c From Customer_Account_Master__c Where CAM_Account_Status__c = 'Active'];
      Customer_Site_Master__c csm = [Select Id,Name From Customer_Site_Master__c Where CSM_Customer_Name__c =: cam.Id];
       Order_Master__c ord = [Select Id From Order_Master__c Where Oracle_Order_Number__c = '10012345'];

      Change_Order_Administrative_Change__c cOACGPO = new Change_Order_Administrative_Change__c();
      cOACGPO.TAMS_ROA__c = roa.Id;
      cOACGPO.COAC_New_GPO_Fees__c  = 29.90;
      cOACGPO.CMSU_Order__c = ord.Id;
      cOACGPO.COAC_Change_Type__c = 'GPO Admin Fee';
      cOACGPO.COAC_Comments__c = 'TestGPO';
        insert cOACGPO;

        ApexPages.standardController stdCon = new ApexPages.standardController(roa);
         ChangeOrderAdminchangeactionCTRL adminChange = new ChangeOrderAdminchangeactionCTRL(stdCon);
         adminChange.selectorders1 = '10012345';
       adminChange.cOrdAdminChange.COAC_Change_Type__c = 'GPO Admin Fee';
       adminChange.changetype();
       System.assertEquals(1,adminChange.mCOAdminstrativeChanges.size());
    }
      @isTest static void changeTypeProgressiveBillTermTest(){
      TAMS_ROA__c roa = [Select 
                            Id
                           ,ROA_Type__c
                       From 
                          TAMS_ROA__c
                       Where 
                           Change_Order_SID__c = '34563170'];

      Customer_Account_Master__c cam = [Select Id,Name,CAM_Account_Number__c From Customer_Account_Master__c Where CAM_Account_Status__c = 'Active'];
      Customer_Site_Master__c csm = [Select Id,Name From Customer_Site_Master__c Where CSM_Customer_Name__c =: cam.Id];
       Order_Master__c ord = [Select Id From Order_Master__c Where Oracle_Order_Number__c = '10012345'];

      Change_Order_Administrative_Change__c cOACProBill = new Change_Order_Administrative_Change__c();
      cOACProBill.TAMS_ROA__c = roa.Id;
      cOACProBill.COAC_New_Progressive_Bill_Term__c = '123zyx';
      cOACProBill.CMSU_Order__c = ord.Id;
      cOACProBill.COAC_Change_Type__c = 'Progressive Bill Term';
      cOACProBill.COAC_Comments__c = 'TestProBill';
        insert cOACProBill;

        ApexPages.standardController stdCon = new ApexPages.standardController(roa);
         ChangeOrderAdminchangeactionCTRL adminChange = new ChangeOrderAdminchangeactionCTRL(stdCon);
         adminChange.selectorders1 = '10012345';
       adminChange.cOrdAdminChange.COAC_Change_Type__c = 'Progressive Bill Term';
       adminChange.changetype();
       System.assertEquals(1,adminChange.mCOAdminstrativeChanges.size());
    }

    @isTest static void changeTypeSalesChannelTest(){
      TAMS_ROA__c roa = [Select 
                            Id
                           ,ROA_Type__c
                       From 
                          TAMS_ROA__c
                       Where 
                           Change_Order_SID__c = '34563170'];

      Customer_Account_Master__c cam = [Select Id,Name,CAM_Account_Number__c From Customer_Account_Master__c Where CAM_Account_Status__c = 'Active'];
      Customer_Site_Master__c csm = [Select Id,Name From Customer_Site_Master__c Where CSM_Customer_Name__c =: cam.Id];
       Order_Master__c ord = [Select Id From Order_Master__c Where Oracle_Order_Number__c = '10012345'];

      Change_Order_Administrative_Change__c cOACSalesChannel = new Change_Order_Administrative_Change__c();
      cOACSalesChannel.TAMS_ROA__c = roa.Id;
      cOACSalesChannel.COAC_New_Sales_Channel__c = 'Direct';
      cOACSalesChannel.CMSU_Order__c = ord.Id;
      cOACSalesChannel.COAC_Change_Type__c = 'Sales Channel';
      cOACSalesChannel.COAC_Comments__c = 'TestProBill';
        insert cOACSalesChannel;

        ApexPages.standardController stdCon = new ApexPages.standardController(roa);
         ChangeOrderAdminchangeactionCTRL adminChange = new ChangeOrderAdminchangeactionCTRL(stdCon);
         adminChange.selectorders1 = '10012345';
       adminChange.cOrdAdminChange.COAC_Change_Type__c = 'Sales Channel';
       adminChange.changetype();
       System.assertEquals(1,adminChange.mCOAdminstrativeChanges.size());
    }

    @isTest static void changeTypeShippingMethodTest(){
      TAMS_ROA__c roa = [Select 
                            Id
                           ,ROA_Type__c
                       From 
                          TAMS_ROA__c
                       Where 
                           Change_Order_SID__c = '34563170'];

      Customer_Account_Master__c cam = [Select Id,Name,CAM_Account_Number__c From Customer_Account_Master__c Where CAM_Account_Status__c = 'Active'];
      Customer_Site_Master__c csm = [Select Id,Name From Customer_Site_Master__c Where CSM_Customer_Name__c =: cam.Id];
       Order_Master__c ord = [Select Id From Order_Master__c Where Oracle_Order_Number__c = '10012345'];

      Change_Order_Administrative_Change__c cOACShippingMethod = new Change_Order_Administrative_Change__c();
      cOACShippingMethod.TAMS_ROA__c = roa.Id;
      cOACShippingMethod.COAC_New_Shipping_Method__c = 'Day Light Ground';
      cOACShippingMethod.CMSU_Order__c = ord.Id;
      cOACShippingMethod.COAC_Change_Type__c = 'Shipping Method';
      cOACShippingMethod.COAC_Comments__c = 'TestProBill';
        insert cOACShippingMethod;

        ApexPages.standardController stdCon = new ApexPages.standardController(roa);
         ChangeOrderAdminchangeactionCTRL adminChange = new ChangeOrderAdminchangeactionCTRL(stdCon);
         adminChange.selectorders1 = '10012345';
       adminChange.cOrdAdminChange.COAC_Change_Type__c = 'Shipping Method';
       adminChange.changetype();
       System.assertEquals(1,adminChange.mCOAdminstrativeChanges.size());
    }
    @isTest static void changeTypeWaiveDownPaymentTest(){
      TAMS_ROA__c roa = [Select 
                            Id
                           ,ROA_Type__c
                       From 
                          TAMS_ROA__c
                       Where 
                           Change_Order_SID__c = '34563170'];

      Customer_Account_Master__c cam = [Select Id,Name,CAM_Account_Number__c From Customer_Account_Master__c Where CAM_Account_Status__c = 'Active'];
      Customer_Site_Master__c csm = [Select Id,Name From Customer_Site_Master__c Where CSM_Customer_Name__c =: cam.Id];
       Order_Master__c ord = [Select Id From Order_Master__c Where Oracle_Order_Number__c = '10012345'];

      Change_Order_Administrative_Change__c cOACWavedownpayment = new Change_Order_Administrative_Change__c();
      cOACWavedownpayment.TAMS_ROA__c = roa.Id;
      cOACWavedownpayment.COAC_New_Shipping_Method__c = 'Day Light Ground';
      cOACWavedownpayment.CMSU_Order__c = ord.Id;
      cOACWavedownpayment.COAC_Change_Type__c = 'Waive Down Payment';
      cOACWavedownpayment.COAC_Comments__c = 'TestProBill';
        insert cOACWavedownpayment;

        ApexPages.standardController stdCon = new ApexPages.standardController(roa);
         ChangeOrderAdminchangeactionCTRL adminChange = new ChangeOrderAdminchangeactionCTRL(stdCon);
         adminChange.selectorders1 = '10012345';
       adminChange.cOrdAdminChange.COAC_Change_Type__c = 'Waive Down Payment';
       adminChange.changetype();
       System.assertEquals(1,adminChange.mCOAdminstrativeChanges.size());
    }

    @isTest static void changeTypeOtherTest(){
      TAMS_ROA__c roa = [Select 
                            Id
                           ,ROA_Type__c
                       From 
                          TAMS_ROA__c
                       Where 
                           Change_Order_SID__c = '34563170'];

      Customer_Account_Master__c cam = [Select Id,Name,CAM_Account_Number__c From Customer_Account_Master__c Where CAM_Account_Status__c = 'Active'];
      Customer_Site_Master__c csm = [Select Id,Name From Customer_Site_Master__c Where CSM_Customer_Name__c =: cam.Id];
       Order_Master__c ord = [Select Id From Order_Master__c Where Oracle_Order_Number__c = '10012345'];

      Change_Order_Administrative_Change__c cOACOther = new Change_Order_Administrative_Change__c();
      cOACOther.TAMS_ROA__c = roa.Id;
      cOACOther.COAC_New_Shipping_Method__c = 'Day Light Ground';
      cOACOther.CMSU_Order__c = ord.Id;
      cOACOther.COAC_Change_Type__c = 'Other';
      cOACOther.COAC_Comments__c = 'TestProBill';
        insert cOACOther;

        ApexPages.standardController stdCon = new ApexPages.standardController(roa);
         ChangeOrderAdminchangeactionCTRL adminChange = new ChangeOrderAdminchangeactionCTRL(stdCon);
         adminChange.selectorders1 = '10012345';
       adminChange.cOrdAdminChange.COAC_Change_Type__c = 'Other';
       adminChange.changetype();
       System.assertEquals(1,adminChange.mCOAdminstrativeChanges.size());
    }

     @isTest static void changeTypeSalesCreditTest(){
      TAMS_ROA__c roa = [Select 
                            Id
                           ,ROA_Type__c
                       From 
                          TAMS_ROA__c
                       Where 
                           Change_Order_SID__c = '34563170'];

      Customer_Account_Master__c cam = [Select Id,Name,CAM_Account_Number__c From Customer_Account_Master__c Where CAM_Account_Status__c = 'Active'];
      Customer_Site_Master__c csm = [Select Id,Name From Customer_Site_Master__c Where CSM_Customer_Name__c =: cam.Id];
       Order_Master__c ord = [Select Id From Order_Master__c Where Oracle_Order_Number__c = '10012345'];
         User user = [select Id From User Where LastName = 'Canon'];
      Change_Order_Administrative_Change__c cOACSalesCredit = new Change_Order_Administrative_Change__c();
      cOACSalesCredit.TAMS_ROA__c = roa.Id;
      cOACSalesCredit.Salesrep_Name__c = '2876 West Zone';
      cOACSalesCredit.Credit_Type__c = 'ZBM Billing';
      cOACSalesCredit.Old_Percentage__c = 100;
      cOACSalesCredit.To_Salesrep1__c = user.Id;
      cOACSalesCredit.To_Percentage1__c = 100;
      cOACSalesCredit.CMSU_Order__c = ord.Id;
      cOACSalesCredit.COAC_Change_Type__c = 'Sales Credit';
      cOACSalesCredit.COAC_Comments__c = 'TestProBill';
        insert cOACSalesCredit;

        ApexPages.standardController stdCon = new ApexPages.standardController(roa);
         ChangeOrderAdminchangeactionCTRL adminChange = new ChangeOrderAdminchangeactionCTRL(stdCon);
         adminChange.selectorders1 = '10012345';
       adminChange.cOrdAdminChange.COAC_Change_Type__c = 'Sales Credit';
       adminChange.changetype();
       System.assertEquals(1,adminChange.mCOAdminstrativeChanges.size());
    }
    @isTest static void saveChangeOrdertest(){
        TAMS_ROA__c roa = [Select Id,ROA_Type__c From TAMS_ROA__c Where Change_Order_SID__c = '34563170'];
     Customer_Account_Master__c cam = [Select Id,Name,CAM_Account_Number__c From Customer_Account_Master__c Where CAM_Account_Status__c = 'Active'];
     Customer_Site_Master__c csm = [Select Id,Name From Customer_Site_Master__c Where CSM_Customer_Name__c =: cam.Id];
     ApexPages.standardController stdCon = new ApexPages.standardController(roa);
    ChangeOrderAdminchangeactionCTRL adminChange = new ChangeOrderAdminchangeactionCTRL(stdCon);
             adminChange.getord();
             adminChange.selectorders1 = '10012345';
               adminChange.cOrdAdminChange.COAC_Change_Type__c = 'Bill To';
               adminChange.billtocustomer = cam.Id;
               adminChange.billtoaddressId = csm.Id;
               adminChange.saveChangeOrder();
              Order_Master__c ordData = [Select 
                                               Id
                                              ,Oracle_Order_Number__c
                                          From 
                                               Order_Master__c
                                           Where 
                                              Oracle_Order_Number__c = '10012345'];
        
             Change_Order_Administrative_Change__c cOAC = [Select
                                                                 Id
                                                                ,Order_Number__c
                                                            From
                                                                 Change_Order_Administrative_Change__c
                                                             Where 
                                                                  Order_Number__c = '10012345']; 

              System.assertEquals(ordData.Oracle_Order_Number__c,cOAC.Order_Number__c);  

              adminChange.cOrdAdminChange.COAC_Change_Type__c = 'Ship To';
              adminChange.shiptocustomer = cam.Id;
              adminChange.shiptoaddressId = csm.Id;
               adminChange.saveChangeOrder();
              System.assertEquals(ordData.Oracle_Order_Number__c,cOAC.Order_Number__c);

              adminChange.cOrdAdminChange.COAC_Change_Type__c = 'PO #';
               adminChange.saveChangeOrder();
              System.assertEquals(ordData.Oracle_Order_Number__c,cOAC.Order_Number__c); 

              adminChange.cOrdAdminChange.COAC_Change_Type__c = 'Progressive Bill Term';
               adminChange.saveChangeOrder();
              System.assertEquals(ordData.Oracle_Order_Number__c,cOAC.Order_Number__c); 

              adminChange.cOrdAdminChange.COAC_Change_Type__c = 'Sales Channel';
               adminChange.saveChangeOrder();
              System.assertEquals(ordData.Oracle_Order_Number__c,cOAC.Order_Number__c); 

              adminChange.cOrdAdminChange.COAC_Change_Type__c = 'Shipping Method';
               adminChange.saveChangeOrder();
              System.assertEquals(ordData.Oracle_Order_Number__c,cOAC.Order_Number__c); 

              adminChange.cOrdAdminChange.COAC_Change_Type__c = 'SID';
               adminChange.saveChangeOrder();
              System.assertEquals(ordData.Oracle_Order_Number__c,cOAC.Order_Number__c); 

              adminChange.cOrdAdminChange.COAC_Change_Type__c = 'Waive Down Payment';
               adminChange.saveChangeOrder();
              System.assertEquals(ordData.Oracle_Order_Number__c,cOAC.Order_Number__c); 

               adminChange.cOrdAdminChange.COAC_Change_Type__c = 'Other';
               adminChange.saveChangeOrder();
              System.assertEquals(ordData.Oracle_Order_Number__c,cOAC.Order_Number__c); 

               adminChange.cOrdAdminChange.COAC_Change_Type__c = 'GPO Admin Fee';
               adminChange.saveChangeOrder();
              System.assertEquals(ordData.Oracle_Order_Number__c,cOAC.Order_Number__c); 
    }

     @isTest static void saveChangeOrderErrortest(){
        TAMS_ROA__c roa = [Select 
                            Id
                           ,ROA_Type__c
                       From 
                          TAMS_ROA__c
                       Where 
                           Change_Order_SID__c = '34563170'];
     ApexPages.standardController stdCon = new ApexPages.standardController(roa);
    ChangeOrderAdminchangeactionCTRL adminChange = new ChangeOrderAdminchangeactionCTRL(stdCon);
             adminChange.getord();
             adminChange.selectorders1 = '--None--';
             adminChange.cOrdAdminChange.COAC_Change_Type__c = '--None--';
             adminChange.saveChangeOrder();
             System.assertEquals('--None--', adminChange.selectorders1);
}

    @istest static void saveChangeOrderSalesCredittest(){
      TAMS_ROA__c roa = [Select 
                            Id
                           ,ROA_Type__c
                       From 
                          TAMS_ROA__c
                       Where 
                           Change_Order_SID__c = '34563170'];

     ApexPages.standardController stdCon = new ApexPages.standardController(roa);
    ChangeOrderAdminchangeactionCTRL adminChange = new ChangeOrderAdminchangeactionCTRL(stdCon);
             adminChange.getord();
             adminChange.selectorders1 = '10012345';
               adminChange.cOrdAdminChange.COAC_Change_Type__c = 'Sales Credit';
               List<ChangeOrderSalesCreditWrapperClass > salesCreditsWrapper = new List<ChangeOrderSalesCreditWrapperClass >(); 
                List<TAMS_Order_Sales_Credit__c> salesCredits = [SELECT
                          Id 
                        ,Name
                        ,Credit_Type__c
                        ,Percentage__c
                        ,Salesrep_Name__c
                        FROM
                          TAMS_Order_Sales_Credit__c
                        WHERE
                          Oracle_Order_Number__c = '10012345'   
                        ORDER BY Salesrep_Name__c
                        ];
                        System.debug('Query Result'+salesCredits);

              User user = [select 
                                Id
                            From
                                User
                            Where 
                                LastName = 'Canon'];

      for(TAMS_Order_Sales_Credit__c sc:salesCredits)
        {
            ChangeOrderSalesCreditWrapperClass  scWrapper = new ChangeOrderSalesCreditWrapperClass (sc);
            scWrapper.rsc.To_Salesrep1__c = user.Id;
            scWrapper.rsc.To_Percentage1__c  = 100;
            scWrapper.rsc.COAC_Comments__c = 'Test';
            salesCreditsWrapper.add(scWrapper);
        }
        System.debug('Sales Credit'+salesCreditsWrapper);
          adminChange.salesCreditsWrapper = salesCreditsWrapper;
          System.debug('Sales Credit2'+adminChange.salesCreditsWrapper);
          adminChange.saveChangeOrder();
                Order_Master__c ordData = [Select 
                                               Id
                                              ,Oracle_Order_Number__c
                                          From 
                                               Order_Master__c
                                           Where 
                                              Oracle_Order_Number__c = '10012345'];
        
             Change_Order_Administrative_Change__c cOAC = [Select
                                                                 Id
                                                                ,Order_Number__c
                                                            From
                                                                 Change_Order_Administrative_Change__c
                                                             Where 
                                                                  Order_Number__c = '10012345']; 

              System.assertEquals(ordData.Oracle_Order_Number__c,cOAC.Order_Number__c);
    }

    @isTest static void cancelTest() {
      TAMS_ROA__c roa = [Select 
                            Id
                           ,ROA_Type__c
                       From 
                          TAMS_ROA__c
                       Where 
                           Change_Order_SID__c = '34563170'];
    ApexPages.standardController stdCon = new ApexPages.standardController(roa);
    ChangeOrderAdminchangeactionCTRL adminChange = new ChangeOrderAdminchangeactionCTRL(stdCon);
    PageReference newPage =  adminChange.cancel();
    System.assertEquals(newPage.getUrl(),'/'+roa.ID);
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
    ChangeOrderAdminchangeactionCTRL adminChange = new ChangeOrderAdminchangeactionCTRL(stdCon);
    PageReference newPage =  adminChange.back();
    System.assertEquals(newPage.getUrl(),'/'+roa.ID);
    }

    @isTest static void CustomerLookupTest(){
      TAMS_ROA__c roa = [Select 
                            Id
                           ,ROA_Type__c
                       From 
                          TAMS_ROA__c
                       Where 
                           Change_Order_SID__c = '34563170'];
    ApexPages.standardController stdCon = new ApexPages.standardController(roa);
    ChangeOrderAdminchangeactionCTRL adminChange = new ChangeOrderAdminchangeactionCTRL(stdCon);
     adminChange.selectorders1 = '10012345';
       adminChange.cOrdAdminChange.COAC_Change_Type__c = 'Bill To';
       adminChange.billtocustomer = null;
       adminChange.CustomerLookup();
       adminChange.cOrdAdminChange.COAC_Change_Type__c = 'Ship To';
       adminChange.shiptocustomer = null;
       adminChange.CustomerLookup();
    System.assertEquals(false,adminChange.showBilltoaddress);
    }

    @isTest static void AddressLookupTestBillTo(){
      TAMS_ROA__c roa = [Select 
                            Id
                           ,ROA_Type__c
                       From 
                          TAMS_ROA__c
                       Where 
                           Change_Order_SID__c = '34563170'];
       Customer_Account_Master__c cam = [Select
                                            Id
                                         From 
                                         Customer_Account_Master__c
                                         Where
                                         Name = 'Test123'];                  
    ApexPages.standardController stdCon = new ApexPages.standardController(roa);
    ChangeOrderAdminchangeactionCTRL adminChange = new ChangeOrderAdminchangeactionCTRL(stdCon);
     adminChange.selectorders1 = '10012345';
       adminChange.cOrdAdminChange.COAC_Change_Type__c = 'Bill To';
        adminChange.billtocustomer = cam.Id;
        adminChange.AddressLookup();
    //adminChange.;
    System.assertEquals(cam.Id,adminChange.billtocustomer);
    }

    @isTest static void AddressLookupTestShipTo(){
      TAMS_ROA__c roa = [Select 
                            Id
                           ,ROA_Type__c
                       From 
                          TAMS_ROA__c
                       Where 
                           Change_Order_SID__c = '34563170'];
       Customer_Account_Master__c cam = [Select
                                            Id
                                         From 
                                         Customer_Account_Master__c
                                         Where
                                         Name = 'Test123'];                  
    ApexPages.standardController stdCon = new ApexPages.standardController(roa);
    ChangeOrderAdminchangeactionCTRL adminChange = new ChangeOrderAdminchangeactionCTRL(stdCon);
     adminChange.selectorders1 = '10012345';
       adminChange.cOrdAdminChange.COAC_Change_Type__c = 'Ship To';
       adminChange.shiptocustomer = cam.Id;
       adminChange.AddressLookup();
    //adminChange.;
    System.assertEquals(cam.Id,adminChange.shiptocustomer);
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
          
      Change_Order_Administrative_Change__c cOAC = new Change_Order_Administrative_Change__c();
        cOAC.TAMS_ROA__c = roa.Id;
        cOAC.COAC_New_PO__c = '4567';
        cOAC.CMSU_Order__c = ord.Id;
       cOAC.COAC_Change_Type__c = 'PO #';
       cOAC.COAC_Comments__c = 'TestPoNum';
        insert cOAC; 
      
    ApexPages.standardController stdCon = new ApexPages.standardController(roa);
    ChangeOrderAdminchangeactionCTRL adminChange = new ChangeOrderAdminchangeactionCTRL(stdCon);
     adminChange.roa.Status__c = 'Complete';
     //Change_Order_Administrative_Change__c cOAC = new Change_Order_Administrative_Change__c();
     cOAC.COAC_New_PO__c = '6543';
     update cOAC;
     //Change_Order_Administrative_Change__c cOAC = new Change_Order_Administrative_Change__c();
     delete cOAC;
     System.assertEquals('6543',cOAC.COAC_New_PO__c);
     }
}