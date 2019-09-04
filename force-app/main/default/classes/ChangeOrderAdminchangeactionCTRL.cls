/*********************************************************
        Author:         
        Purpose: This Class is used in Adding Items.        
        1.0 - Lokesh Tigulla              - Created
        1.1 - Lokesh Tigulla - 01/19/2019 - updated
**********************************************************/

public with sharing class ChangeOrderAdminchangeactionCTRL {
    public TAMS_ROA__c roa {get;set;} 
   @TestVisible private ID roaID;
    public String selectorders1{get;set;}
  public Change_Order_Administrative_Change__c cOrdAdminChange {get;set;}
  public String modality {get;set;}
  public Boolean isEditable {get;set;}
  public Date orderBookedDate {get;set;}
  public String orderType {get;set;}
  public String orderStatus {get;set;}
  public Decimal orderBookedAmount {get;set;}
  public Boolean showBillTo {get;set;}
  public Boolean showShipTo {get;set;}
  public Boolean showPoNum {get;set;}
  public Boolean showGPOFees {get;set;}  
  public Boolean showProBillTerm {get;set;}
  public Boolean showSalesChannel {get;set;}
  public Boolean showShippingMethod {get;set;}
  public Boolean showSid {get;set;}
  public Boolean showWaiveDownPayment {get;set;}
  public Boolean showOther {get;set;}
  public Boolean showSalesCredit {get;set;}
  public String  billtocustomer {get;set;}
  public String  billtocustomername {get;set;}
  public String billtoaddressId{get;set;}
  public String billtoaddressname {get;set;}
  public String shiptocustomer {get;set;}
  public String shiptocustomername {get;set;}
  public String shiptoaddressId{get;set;}
  public String shiptoaddressname {get;set;}
  public Boolean showBilltoaddress {get;set;}
  public Boolean showshiptoaddress {get;set;}
  public String accountNumber {get;set;}
  public Map<String,Order_Master__c> mOrdersData;
  public List<ChangeOrderSalesCreditWrapperClass> salesCreditsWrapper {get;set;} 
  public Map<String,List<Change_Order_Administrative_Change__c>> mCOAdminstrativeChanges;
  public Order_Master__c resultantOrderMaster {get;set;}
    public ChangeOrderAdminchangeactionCTRL (ApexPages.StandardController stdController) {
        roaID = stdController.getId();
        if(roaID !=null){       
        System.debug('roaID:'+roaID);
        roa = [SELECT
                     Name
                    ,Change_Order_SID__c
                    ,Account__c
                    ,Status__c
                FROM 
                    TAMS_ROA__c 
                WHERE 
                    ID = :roaID LIMIT 1];  
    if(roa.Status__c == 'Pending Commissions Mgr Approval' || roa.Status__c == 'Pending Credit Approval' ||  roa.Status__c == 'Pending Gov Mgr Approval' || roa.Status__c == 'Pending Order Management Approval' || roa.Status__c == 'Pending Finance Mgr Approval'|| roa.Status__c == 'Complete'){

            isEditable = true;
       }else{

            isEditable = false;
       }

      List<Change_Order_Administrative_Change__c> lCOrdAdmin = [SELECT 
                                                                      Id
                                                                      ,COAC_New_Bill_To__c
                                                                      ,COAC_Change_Type__c
                                                                      ,COAC_New_Bill_To_Account_Number__c
                                                                      ,COAC_New_Bill_To_Customer__c
                                                                      ,COAC_New_Ship_To__c
                                                                      ,New_Ship_To_Account_Number__c
                                                                      ,COAC_New_Ship_to_Customer__c
                                                                      ,COAC_New_Ship_To_Address__c
                                                                      ,COAC_New_PO__c
                                                                      ,COAC_New_GPO_Fees__c
                                                                      ,COAC_New_Progressive_Bill_Term__c
                                                                      ,COAC_New_Sales_Channel__c
                                                                      ,COAC_New_Shipping_Method__c
                                                                      ,CMSU_Order__r.Oracle_Order_Number__c
                                                                      ,COAC_New_Bill_To_Address__c
                                                                      ,COAC_New_SID__c
                                                                      ,Salesrep_Name__c
                                                                      ,COAC_New_Revenue_Cost_Center_One__c
                                                                      ,COAC_New_Revenue_Cost_Center_Two__c
                                                                      ,Credit_Type__c
                                                                      ,Old_Percentage__c
                                                                      ,To_Salesrep1__c
                                                                      ,To_Credit_Type1__c
                                                                      ,To_Percentage1__c
                                                                      ,To_Salesrep2__c
                                                                      ,To_Credit_Type2__c
                                                                      ,To_Percentage2__c
                                                                      ,COAC_Comments__c
                                                                      ,TAMS_ROA_Id__c
                                                                      ,COAC_Waive_Down_Payment__c
                                                                      FROM
                                                                      Change_Order_Administrative_Change__c
                                                                      WHERE
                                                                      TAMS_ROA__c =: roaID];
        System.debug('list'+lCOrdAdmin);                                                               

        mCOAdminstrativeChanges = new Map<String,List<Change_Order_Administrative_Change__c>>();

        for(Change_Order_Administrative_Change__c cOrdAdmin:lCOrdAdmin){
            if(mCOAdminstrativeChanges.containsKey(cOrdAdmin.CMSU_Order__r.Oracle_Order_Number__c)){
                 List<Change_Order_Administrative_Change__c> tempCOAdminChangeTemp = mCOAdminstrativeChanges.get(cOrdAdmin.CMSU_Order__r.Oracle_Order_Number__c);
                 tempCOAdminChangeTemp.add(cOrdAdmin);
                 mCOAdminstrativeChanges.put(cOrdAdmin.CMSU_Order__r.Oracle_Order_Number__c,tempCOAdminChangeTemp);
            }else{
              List<Change_Order_Administrative_Change__c> tempCOAdminChangeTemp = new List<Change_Order_Administrative_Change__c>();
              tempCOAdminChangeTemp.add(cOrdAdmin);
              mCOAdminstrativeChanges.put(cOrdAdmin.CMSU_Order__r.Oracle_Order_Number__c,tempCOAdminChangeTemp);
            }
        }
        
        System.debug('list'+mCOAdminstrativeChanges); 
        
        cOrdAdminChange = new Change_Order_Administrative_Change__c();

        System.debug('roa:'+roa); 
        showBillTo = false; 
        mOrdersData = new Map<String,Order_Master__c>();
    }
  }
public List<SelectOption> getord(){
            List<SelectOption> option = new List<SelectOption>();
            if(roa !=null){
          Decimal sid_order = Decimal.valueOf(roa.Change_Order_SID__c);
            list<Order_Master__c> lOrds = [SELECT 
                                             ID
                                            ,Bill_To_Account_Number__c
                                            ,Bill_To_Customer__c
                                            ,Bill_To_Address__c
                                            ,Ship_To_Account_Number__c
                                            ,Ship_To_Customer__c
                                            ,Ship_To_Address__c
                                            ,PO_Number__c
                                            ,OM_GPO_Admin_Fee__c
                                            ,Progressive_Bill_Term__c
                                            ,Sales_Channel__c
                                            ,Shipping_Method__c 
                                            ,Oracle_Order_Number__c
                                            ,Modality_Order__c
                                            ,CMSU_Booked_Date__c
                                            ,Order_Type__c
                                            ,Order_Status__c
                                            ,Order_Subtotal__c
                                            ,SID_Order__c
                                            FROM
                                            Order_Master__c 
                                            WHERE 
                                            SID_Order__c = :sid_order
                                            AND
                                            Customer_Name__c =:roa.Account__c];
                      if(lOrds.size() >= 1){
                          option.add(new SelectOption('--None--','--None--'));
                            for(Order_Master__c lOrd :lOrds){
                              option.add(new SelectOption(lOrd.Oracle_Order_Number__c,lOrd.Oracle_Order_Number__c));
                              mOrdersData.put(lOrd.Oracle_Order_Number__c,lOrd);
                        }
                    } 
                      else {
                        for(Order_Master__c lOrd :lOrds){
                            option.add(new SelectOption(lOrd.Oracle_Order_Number__c,lOrd.Oracle_Order_Number__c));
                        }
                      }
                  }
                  return option;
              }

  public PageReference orderchange(){
         System.debug('selectedoption'+selectorders1);
         if(selectorders1 == '--None--'){
              System.debug('selectedoption'+ selectorders1 );
              modality = null;
              orderBookedDate = null;
              orderType = null;
              orderStatus =null;
              orderBookedAmount = null;
         }else{
          System.debug('selectorders1'+selectorders1);
           modality = mOrdersData.get(selectorders1).Modality_Order__c;
           orderBookedDate = mOrdersData.get(selectorders1).CMSU_Booked_Date__c;
           orderType = mOrdersData.get(selectorders1).Order_Type__c;
           orderStatus = mOrdersData.get(selectorders1).Order_Status__c;
           orderBookedAmount = mOrdersData.get(selectorders1).Order_Subtotal__c;
         }
         cOrdAdminChange.COAC_Change_Type__c = null;
         showBillTo = false;
         showShipTo = false;
         showPoNum = false;
         showGPOFees = false;
         showProBillTerm = false;
         showSalesChannel = false;
         showShippingMethod = false;
         showSid = false;
         showWaiveDownPayment = false;
         showSalesCredit = false;
         showOther = false;
         accountNumber = null;
         billtoaddressId = null;
         billtocustomername = null;
         billtocustomer = null;
         billtoaddressname  = null;
         shiptoaddressId = null;
         shiptocustomername = null;
         shiptocustomer = null;
         shiptoaddressname  = null;
         return null; 
       }
  public PageReference changetype(){
        cOrdAdminChange.COAC_Comments__c = '';
        System.debug('***entered');
        if(cOrdAdminChange.COAC_Change_Type__c == 'Bill To'){
          
          cOrdAdminChange = new Change_Order_Administrative_Change__c();
          cOrdAdminChange.COAC_Change_Type__c = 'Bill To';

          if(selectorders1 == '--None--'){
            Apexpages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'Please Select the Order Number'));
             return null;
          }
           resultantOrderMaster = mOrdersData.get(selectorders1);
            System.debug('map is populated'+mCOAdminstrativeChanges);
           if(!mCOAdminstrativeChanges.isEmpty()){
                System.debug('map is populated');
                 System.debug('Check**'+mCOAdminstrativeChanges.get(selectorders1));
              if(mCOAdminstrativeChanges.containsKey(selectorders1)){
                 for(Change_Order_Administrative_Change__c coAdmin : mCOAdminstrativeChanges.get(selectorders1)){
                      if(coAdmin.COAC_Change_Type__c == 'Bill To'){
                         cOrdAdminChange = coAdmin;
                         if(cOrdAdminChange.COAC_New_Bill_To_Customer__c != null && cOrdAdminChange.COAC_New_Bill_To__c != null ){
                         accountNumber = coAdmin.COAC_New_Bill_To_Account_Number__c;
                         billtoaddressId = coAdmin.COAC_New_Bill_To__c;
                         billtocustomername = [SELECT Name FROM Customer_Account_Master__c where id =: coAdmin.COAC_New_Bill_To_Customer__c].Name;
                         billtocustomer = coAdmin.COAC_New_Bill_To_Customer__c;
                         billtoaddressname = [SELECT CSM_Site_Address_Lookup__c FROM Customer_Site_Master__c where id =: coAdmin.COAC_New_Bill_To__c].CSM_Site_Address_Lookup__c;
                       }
                       else{
                         accountNumber = null;
                       }
                        break;
                      }
                 }
              }
            }

           if(billtocustomer == null){
                showBilltoaddress = false;
           }else{
                showBilltoaddress = true;
           }

           showBillTo = true;
           showShipTo = false;
           showPoNum = false;
           showGPOFees = false;
           showProBillTerm = false;
           showSalesChannel = false;
           showShippingMethod = false;
           showSid = false;
           showWaiveDownPayment = false;
           showSalesCredit = false;               
        }else{
          showBillTo = false;
        }
         if(cOrdAdminChange.COAC_Change_Type__c == 'Ship To'){

          cOrdAdminChange = new Change_Order_Administrative_Change__c();
          cOrdAdminChange.COAC_Change_Type__c = 'Ship To';
             
          if(selectorders1 == '--None--'){
            Apexpages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'Please Select the Order Number'));
             return null;
          }
            resultantOrderMaster = mOrdersData.get(selectorders1);
             System.debug('map is populated'+mCOAdminstrativeChanges);
           if(!mCOAdminstrativeChanges.isEmpty()){
             System.debug('map is populated');
             System.debug('Check**'+mCOAdminstrativeChanges.get(selectorders1));
             if(mCOAdminstrativeChanges.containsKey(selectorders1)){
              for(Change_Order_Administrative_Change__c coAdmin : mCOAdminstrativeChanges.get(selectorders1)){
                  if(coAdmin.COAC_Change_Type__c == 'Ship To'){
                     cOrdAdminChange = coAdmin;
                     if(cOrdAdminChange.COAC_New_Ship_to_Customer__c != null && cOrdAdminChange.COAC_New_Ship_To__c != null){
                         accountNumber = coAdmin.New_Ship_To_Account_Number__c;
                         shiptoaddressId = coAdmin.COAC_New_Ship_To__c;
                         shiptocustomername = [SELECT Name FROM Customer_Account_Master__c where id =: coAdmin.COAC_New_Ship_to_Customer__c].Name;
                         shiptocustomer = coAdmin.COAC_New_Ship_to_Customer__c;
                         shiptoaddressname = [SELECT CSM_Site_Address_Lookup__c FROM Customer_Site_Master__c where id =: coAdmin.COAC_New_Ship_To__c].CSM_Site_Address_Lookup__c;
                       }
                       else{
                        accountNumber = null;
                        break;
                       }
                     
                  }
                }
             }
          }

              if(shiptocustomer == null){
                showshiptoaddress = false;
           }else{
                showshiptoaddress = true;
           }

           showBillTo = false;
           showShipTo = true;
           showPoNum  = false;
           showGPOFees = false;           
           showProBillTerm = false;
           showSalesChannel = false;
           showShippingMethod = false;
           showSid = false;
           showWaiveDownPayment = false;
           showSalesCredit = false;
        }else{
          showShipTo = false;
        }
         if(cOrdAdminChange.COAC_Change_Type__c == 'PO #'){

          cOrdAdminChange = new Change_Order_Administrative_Change__c();
          cOrdAdminChange.COAC_Change_Type__c = 'PO #';
          if(selectorders1 == '--None--'){
            Apexpages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'Please Select the Order Number'));
             return null;
          }
            resultantOrderMaster = mOrdersData.get(selectorders1);
             System.debug('map is populated'+mCOAdminstrativeChanges);
           if(!mCOAdminstrativeChanges.isEmpty()){
              System.debug('map is populated');
              System.debug('Check**'+mCOAdminstrativeChanges.get(selectorders1));
             if(mCOAdminstrativeChanges.containsKey(selectorders1)){
              for(Change_Order_Administrative_Change__c coAdmin : mCOAdminstrativeChanges.get(selectorders1)){
                  if(coAdmin.COAC_Change_Type__c == 'PO #'){
                     cOrdAdminChange = coAdmin;
                     break;
                  }
                }
             }
          }
           showBillTo = false;
           showShipTo = false;
           showPoNum = true;
           showGPOFees = false;           
           showProBillTerm = false;
          showSalesChannel = false;
          showShippingMethod = false;
          showSid = false;
           showWaiveDownPayment = false;
           showSalesCredit = false;
        }else{
          showPoNum = false;
        }
         if(cOrdAdminChange.COAC_Change_Type__c == 'GPO Admin Fee'){

          cOrdAdminChange = new Change_Order_Administrative_Change__c();
          cOrdAdminChange.COAC_Change_Type__c = 'GPO Admin Fee';
          if(selectorders1 == '--None--'){
            Apexpages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'Please Select the Order Number'));
             return null;
          }
            resultantOrderMaster = mOrdersData.get(selectorders1);
             System.debug('map is populated'+mCOAdminstrativeChanges);
           if(!mCOAdminstrativeChanges.isEmpty()){
              System.debug('map is populated');
              System.debug('Check**'+mCOAdminstrativeChanges.get(selectorders1));
             if(mCOAdminstrativeChanges.containsKey(selectorders1)){
              for(Change_Order_Administrative_Change__c coAdmin : mCOAdminstrativeChanges.get(selectorders1)){
                  if(coAdmin.COAC_Change_Type__c == 'GPO Admin Fee'){
                     cOrdAdminChange = coAdmin;
                     break;
                  }
                }
             }
          }
           showBillTo = false;
           showShipTo = false;
           showPoNum = false;
           showGPOFees = true;           
           showProBillTerm = false;
          showSalesChannel = false;
          showShippingMethod = false;
          showSid = false;
           showWaiveDownPayment = false;
           showSalesCredit = false;
        }else{
          showGPOFees = false;
        }        
        if(cOrdAdminChange.COAC_Change_Type__c == 'Progressive Bill Term'){

          cOrdAdminChange = new Change_Order_Administrative_Change__c();
          cOrdAdminChange.COAC_Change_Type__c = 'Progressive Bill Term';
          if(selectorders1 == '--None--'){
            Apexpages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'Please Select the Order Number'));
             return null;
          }
          resultantOrderMaster = mOrdersData.get(selectorders1);
            System.debug('map is populated'+mCOAdminstrativeChanges);
           if(!mCOAdminstrativeChanges.isEmpty()){
            System.debug('map is populated');
            System.debug('Check**'+mCOAdminstrativeChanges.get(selectorders1));
             if(mCOAdminstrativeChanges.containsKey(selectorders1)){
              for(Change_Order_Administrative_Change__c coAdmin : mCOAdminstrativeChanges.get(selectorders1)){
                  if(coAdmin.COAC_Change_Type__c == 'Progressive Bill Term'){
                     cOrdAdminChange = coAdmin;
                     break;
                  }
                }
             }
          }
           showBillTo = false;
           showShipTo = false;
           showPoNum = false;
           showGPOFees = false;           
           showProBillTerm = true;
           showSalesChannel = false;
          showShippingMethod = false;
          showSid = false;
           showWaiveDownPayment = false;
           showSalesCredit = false;
        }else
        {
          showProBillTerm = false;
        }
        if(cOrdAdminChange.COAC_Change_Type__c == 'Sales Channel'){

           cOrdAdminChange = new Change_Order_Administrative_Change__c();
          cOrdAdminChange.COAC_Change_Type__c = 'Sales Channel';
          if(selectorders1 == '--None--'){
            Apexpages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'Please Select the Order Number'));
             return null;
          }
          resultantOrderMaster = mOrdersData.get(selectorders1);
            System.debug('map is populated'+mCOAdminstrativeChanges);
           if(!mCOAdminstrativeChanges.isEmpty()){
              System.debug('map is populated');
              System.debug('Check**'+mCOAdminstrativeChanges.get(selectorders1));
             if(mCOAdminstrativeChanges.containsKey(selectorders1)){
              for(Change_Order_Administrative_Change__c coAdmin : mCOAdminstrativeChanges.get(selectorders1)){
                  if(coAdmin.COAC_Change_Type__c == 'Sales Channel'){
                     cOrdAdminChange = coAdmin;
                     break;
                  }
                }
             }
          }
           showBillTo = false;
           showShipTo = false;
           showPoNum = false;
           showGPOFees = false;           
           showProBillTerm = false;
           showSalesChannel = true;
          showShippingMethod = false;
          showSid = false;
           showWaiveDownPayment = false;
           showSalesCredit = false;
        }else
        {
          showSalesChannel = false;
        }
         if(cOrdAdminChange.COAC_Change_Type__c == 'Shipping Method'){

           cOrdAdminChange = new Change_Order_Administrative_Change__c();
          cOrdAdminChange.COAC_Change_Type__c = 'Shipping Method';
          if(selectorders1 == '--None--'){
            Apexpages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'Please Select the Order Number'));
             return null;
          }
          resultantOrderMaster = mOrdersData.get(selectorders1);
            System.debug('map is populated'+mCOAdminstrativeChanges);
           if(!mCOAdminstrativeChanges.isEmpty()){
              System.debug('map is populated');
              System.debug('Check**'+mCOAdminstrativeChanges.get(selectorders1));
             if(mCOAdminstrativeChanges.containsKey(selectorders1)){
              for(Change_Order_Administrative_Change__c coAdmin : mCOAdminstrativeChanges.get(selectorders1)){
                  if(coAdmin.COAC_Change_Type__c == 'Shipping Method'){
                     cOrdAdminChange = coAdmin;
                     break;
                  }
                }
             }
          }
           showBillTo = false;
           showShipTo = false;
           showPoNum = false;
           showGPOFees = false;           
           showProBillTerm = false;
           showSalesChannel = false;
           showShippingMethod = true;
           showSid = false;
            showWaiveDownPayment = false;
            showSalesCredit = false;
        }else
        {
          showShippingMethod = false;
        }
       
        if(cOrdAdminChange.COAC_Change_Type__c == 'Waive Down Payment'){

          cOrdAdminChange = new Change_Order_Administrative_Change__c();
          cOrdAdminChange.COAC_Change_Type__c = 'Waive Down Payment';
          cOrdAdminChange.COAC_Waive_Down_Payment__c = true; 
          if(selectorders1 == '--None--'){
            Apexpages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'Please Select the Order Number'));
             return null;
          }
            System.debug('map is populated'+mCOAdminstrativeChanges);
           if(!mCOAdminstrativeChanges.isEmpty()){
              System.debug('map is populated');
              System.debug('Check**'+mCOAdminstrativeChanges.get(selectorders1));
             if(mCOAdminstrativeChanges.containsKey(selectorders1)){
              for(Change_Order_Administrative_Change__c coAdmin : mCOAdminstrativeChanges.get(selectorders1)){
                  if(coAdmin.COAC_Change_Type__c == 'Waive Down Payment'){
                     cOrdAdminChange = coAdmin;
                      cOrdAdminChange.COAC_Waive_Down_Payment__c = true; 
                  }
                }
             }
          }
           showBillTo = false;
           showShipTo = false;
           showPoNum = false;
           showGPOFees = false;           
           showProBillTerm = false;
           showSalesChannel = false;
           showShippingMethod = false;
           showSid = false;
          showWaiveDownPayment = true;
           showSalesCredit = false;
        }else
        {
          showWaiveDownPayment = false;
        }
        if(cOrdAdminChange.COAC_Change_Type__c == 'Other'){

          cOrdAdminChange = new Change_Order_Administrative_Change__c();
          cOrdAdminChange.COAC_Change_Type__c = 'Other';
          if(selectorders1 == '--None--'){
            Apexpages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'Please Select the Order Number'));
             return null;
          }
            System.debug('map is populated'+mCOAdminstrativeChanges);
           if(!mCOAdminstrativeChanges.isEmpty()){
              System.debug('map is populated');
              System.debug('Check**'+mCOAdminstrativeChanges.get(selectorders1));
             if(mCOAdminstrativeChanges.containsKey(selectorders1)){
              for(Change_Order_Administrative_Change__c coAdmin : mCOAdminstrativeChanges.get(selectorders1)){
                  if(coAdmin.COAC_Change_Type__c == 'Other'){
                     cOrdAdminChange = coAdmin;
                     break;
                  }
                }
             }
          }
           showBillTo = false;
           showShipTo = false;
           showPoNum = false;
           showGPOFees = false;           
           showProBillTerm = false;
           showSalesChannel = false;
           showShippingMethod = false;
           showSid = false;
          showWaiveDownPayment = false;
           showSalesCredit = false;
           showOther = true;
        }else
        {
          showOther = false;
        }
         if(cOrdAdminChange.COAC_Change_Type__c == 'Sales Credit'){

           cOrdAdminChange = new Change_Order_Administrative_Change__c();
          cOrdAdminChange.COAC_Change_Type__c = 'Sales Credit';
          if(selectorders1 == '--None--'){
            Apexpages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'Please Select the Order Number'));
             return null;
          }
          salesCreditsWrapper = new List<ChangeOrderSalesCreditWrapperClass>();                                 
          List<TAMS_Order_Sales_Credit__c> salesCredits = [SELECT
                          Id 
                        ,Name
                        ,Credit_Type__c
                        ,Percentage__c
                        ,Salesrep_Name__c
                        FROM
                          TAMS_Order_Sales_Credit__c
                        WHERE
                          Oracle_Order_Number__c = :selectorders1    
                        ORDER BY Salesrep_Name__c
                        ];
        System.debug('salesCredits size:'+salesCredits.size());

        for(TAMS_Order_Sales_Credit__c sc:salesCredits)
        {
            ChangeOrderSalesCreditWrapperClass scWrapper = new ChangeOrderSalesCreditWrapperClass(sc);
            salesCreditsWrapper.add(scWrapper);
        }
        System.debug('List of sales Credit'+salesCreditsWrapper);
         if(!mCOAdminstrativeChanges.isEmpty()){
              System.debug('map is populated');
              System.debug('Check**'+mCOAdminstrativeChanges.get(selectorders1));
             if(mCOAdminstrativeChanges.containsKey(selectorders1)){
              for(Change_Order_Administrative_Change__c coAdmin : mCOAdminstrativeChanges.get(selectorders1)){
                  if(coAdmin.COAC_Change_Type__c == 'Sales Credit'){
                    for(ChangeOrderSalesCreditWrapperClass scWrapper : salesCreditsWrapper){
                        if(scWrapper.rsc.Salesrep_Name__c == coAdmin.Salesrep_Name__c && scWrapper.rsc.Credit_Type__c == coAdmin.Credit_Type__c){
                           scWrapper.rsc = coAdmin;
                        }
                    }
                  }
                }
             }
          }
           showBillTo = false;
           showShipTo = false;
           showPoNum = false;
           showGPOFees = false;           
           showProBillTerm = false;
           showSalesChannel = false;
           showShippingMethod = false;
           showSid = false;
          showWaiveDownPayment = false;
          showSalesCredit = true;
        }else
        {
          showSalesCredit = false;
        }
        return null;
  }

  public PageReference saveChangeOrder(){
    TAMS_Order_Sales_Credit__c wrapper = new TAMS_Order_Sales_Credit__c();
    try{
      System.debug('Inside Save');
      if(selectorders1 == '--None--'){
            Apexpages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'Please Select the Order Number'));
             return null;
          }
      if(cOrdAdminChange.COAC_Change_Type__c == '--None--'){
        System.debug('entered'+cOrdAdminChange.COAC_Change_Type__c);
            Apexpages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'Please Select the Change Type'));
             return null;
          }
      if(cOrdAdminChange.COAC_Change_Type__c != 'Sales Credit'){
        
            cOrdAdminChange.CMSU_Order__c = mOrdersData.get(selectorders1).Id;
            cOrdAdminChange.Order_Number__c = selectorders1;
            cOrdAdminChange.Salesrep_Name__c = wrapper.Salesrep_Name__c;
            cOrdAdminChange.Credit_Type__c = wrapper.Credit_Type__c;
            cOrdAdminChange.Old_Percentage__c = wrapper.Percentage__c;
            String changeType;

            if(cOrdAdminChange.COAC_Change_Type__c == 'Bill To'){
              changeType = 'billto';

            }else if (cOrdAdminChange.COAC_Change_Type__c == 'Ship To'){
              changeType = 'shipto';
            }
            else if (cOrdAdminChange.COAC_Change_Type__c == 'PO #'){
              changeType = 'PoNum';
            }
            else if (cOrdAdminChange.COAC_Change_Type__c == 'GPO Admin Fee'){
              changeType = 'GPOFees';
            }
            else if (cOrdAdminChange.COAC_Change_Type__c == 'Progressive Bill Term'){
              changeType = 'progressivebillterm';
            }
            else if (cOrdAdminChange.COAC_Change_Type__c == 'Sales Channel'){
              changeType = 'saleschannel';
            }
            else if (cOrdAdminChange.COAC_Change_Type__c == 'Shipping Method'){
              changeType = 'shippingmethod';
            }
            else if (cOrdAdminChange.COAC_Change_Type__c == 'SID'){
              changeType = 'sid';
            }
            else if (cOrdAdminChange.COAC_Change_Type__c == 'Waive Down Payment'){
              changeType = 'waivedownpayment';
            }
            else if (cOrdAdminChange.COAC_Change_Type__c == 'Other'){
              changeType = 'other';
            }
            cOrdAdminChange.TAMS_ROA_Id__c = roa.Change_Order_SID__c + '-'+selectorders1+'-'+changeType+'-'+roaID;
            System.debug('billtocustomer'+billtocustomer);
            System.debug('billtoaddressId'+billtoaddressId);
            
            if(billtocustomer != null && billtocustomer != '' && billtoaddressId != null && billtoaddressId != ''){
            cOrdAdminChange.COAC_New_Bill_To_Customer__c = billtocustomer;
            cOrdAdminChange.COAC_New_Bill_To__c = billtoaddressId;
            }
            else if(shiptocustomer != null && shiptocustomer != '' && shiptoaddressId != null && shiptoaddressId != ''){
               cOrdAdminChange.COAC_New_Ship_to_Customer__c = shiptocustomer;
               cOrdAdminChange.COAC_New_Ship_To__c = shiptoaddressId;
            }
            //else{
            //   Apexpages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'Please Select the Customer and address'));
            //   return null;
            //}
            System.debug('uniquie path'+ roa.Change_Order_SID__c + '-'+selectorders1+'-'+changeType+'-'+roaID);

            if(cOrdAdminChange.Id == null){
              cOrdAdminChange.TAMS_ROA__c = roaID;
            }
            try{
              upsert cOrdAdminChange TAMS_ROA_Id__c; 
              System.debug('**save');
              PageReference retpage = new PageReference('/'+roaID);
              retpage.setRedirect(true);
              return retpage;
            }
          catch(DmlException e)
            {
               for (Integer i = 0; i < e.getNumDml(); i++) 
               {
                // Process exception here
                    System.debug(e.getDmlMessage(i));
                    Apexpages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,e.getDmlMessage(i)));
                    return null;
               }
              }
        }else if(cOrdAdminChange.COAC_Change_Type__c == 'Sales Credit'){
          System.debug('entered');
              List<Change_Order_Administrative_Change__c> lfinalchangeOrderAdminChangeSC = new List<Change_Order_Administrative_Change__c>();
              System.debug('Old values'+salesCreditsWrapper);
              for(ChangeOrderSalesCreditWrapperClass scWrapper : salesCreditsWrapper){
                  System.debug('For loop'+scWrapper);
                if(((scWrapper.rsc.To_Salesrep1__c != null || scWrapper.rsc.COAC_New_Revenue_Cost_Center_One__c != null ) && scWrapper.rsc.To_Percentage1__c != null  ) || ((scWrapper.rsc.To_Salesrep2__c != null || scWrapper.rsc.COAC_New_Revenue_Cost_Center_Two__c != null) && scWrapper.rsc.To_Percentage2__c != null)){
                  scWrapper.rsc.COAC_Change_Type__c = 'Sales Credit';
                  System.debug('****'+cOrdAdminChange.Id);
                   if(scWrapper.rsc.Id == null){
                     System.debug('****'+roaID);
                      scWrapper.rsc.TAMS_ROA__c = roaID; 
                       System.debug(''+ scWrapper.rsc.TAMS_ROA__c);
                    }
                  scWrapper.rsc.TAMS_ROA_Id__c = roa.Change_Order_SID__c+ '-'+selectorders1+'-'+scWrapper.rsc.Salesrep_Name__c+'-'+scWrapper.rsc.Credit_Type__c+'-'+roaID;
                  scWrapper.rsc.CMSU_Order__c = mOrdersData.get(selectorders1).Id;
                  scWrapper.rsc.Order_Number__c = selectorders1;
                  lfinalchangeOrderAdminChangeSC.add(scWrapper.rsc);
                }
              }
              System.debug('Final List'+lfinalchangeOrderAdminChangeSC);
              if(lfinalchangeOrderAdminChangeSC.size() > 0){
                try{
                 upsert lfinalchangeOrderAdminChangeSC TAMS_ROA_Id__c;
                 PageReference retpage = new PageReference('/'+roaID);
                 retpage.setRedirect(true);
                 return retpage; 
                }catch(DmlException e){
                Apexpages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Specify Complete Details'));
                  return null;
               }
              }
        } 
              Apexpages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Specify Complete Details')); 
        return null;
    }catch(DmlException e){
                System.debug(e.getMessage());
                return null;
    }        
  }
  public PageReference back()
    {
      System.debug('entered');
        PageReference retPage = new PageReference('/'+roaID); 
        retPage.setRedirect(true);
        return retPage;        
    }
    public PageReference cancel()
    {
      System.debug('entered');
        PageReference retPage = new PageReference('/'+roaID); 
        retPage.setRedirect(true);
        return retPage;        
    }
    public PageReference CustomerLookup(){
      System.debug('Entered');
           if(billtocustomer == null){
                showBilltoaddress = false;
           }else{
                showBilltoaddress = true;
           }
     System.debug('billtocustomer'+billtocustomer);
        System.debug('shiptocustomer'+shiptocustomer);
           if(shiptocustomer == null){
                showshiptoaddress = false;
           }else{
                showshiptoaddress = true;
           }
      return null;
    }
    public PageReference AddressLookup(){
 
      System.debug('billtocustomer'+billtocustomer);
      System.debug('billtoaddressId'+billtoaddressId);
       if(billtocustomer != null && billtocustomer != ''){
              accountNumber = [Select Id,CAM_Account_Number__c From Customer_Account_Master__c Where id =: billtocustomer].CAM_Account_Number__c;
            }
           else if(shiptocustomer != null && shiptocustomer != ''){
              accountNumber = [Select Id,CAM_Account_Number__c From Customer_Account_Master__c Where id =: shiptocustomer].CAM_Account_Number__c;
            }
            else{
              Apexpages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'Please Select the Customer and address'));
               return null;
            }

      return null;
    }
     //used in administrative changes(Sales Credit) 
     //public PageReference creditTypeChange()   {
     //   System.debug('START:creditTypeChange');
     //   //Reset Credit tyoe to original value
     //   for(ChangeOrderSalesCreditWrapperClass wrapperRec:salesCreditsWrapper)
     //   {
     //       wrapperRec.sc.Credit_Type__c = wrapperRec.origCreditType;
     //   }
     //   Apexpages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'Current Credit Type Change is not allowed.'));
     //   return null;
     //    }  

      //if(cOrdAdminChange.COAC_Change_Type__c == 'SID'){

        //   cOrdAdminChange = new Change_Order_Administrative_Change__c();
        //  cOrdAdminChange.COAC_Change_Type__c = 'SID';
        //  if(selectorders1 == '--None--'){
        //    Apexpages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'Please Select the Order Number'));
        //     return null;
        //  }
        //  resultantOrderMaster = mOrdersData.get(selectorders1);
        //    System.debug('map is populated'+mCOAdminstrativeChanges);
        //   if(!mCOAdminstrativeChanges.isEmpty()){
        //      System.debug('map is populated');
        //      System.debug('Check**'+mCOAdminstrativeChanges.get(selectorders1));
        //     if(mCOAdminstrativeChanges.containsKey(selectorders1)){
        //      for(Change_Order_Administrative_Change__c coAdmin : mCOAdminstrativeChanges.get(selectorders1)){
        //          if(coAdmin.COAC_Change_Type__c == 'SID'){
        //             cOrdAdminChange = coAdmin;
        //             break;
        //          }
        //        }
        //     }
        //  }
        //   showBillTo = false;
        //   showShipTo = false;
        //   showPoNum = false;
        //   showGPOFees = false;           
        //   showProBillTerm = false;
        //   showSalesChannel = false;
        //   showShippingMethod = false;
        //   showSid = true;
        //    showWaiveDownPayment = false;
        //    showSalesCredit = false;
        //}else
        //{
        //  showSid = false;
        //}

}