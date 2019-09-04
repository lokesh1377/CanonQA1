/*********************************************************
        Author:         
        Purpose: This Class is used for displaying OFA on Change Order Page.        
        1.0 - Lokesh Tigulla              - Created
        1.1 - Lokesh Tigulla - 02/19/2019 - updated
**********************************************************/
public with sharing class ChangeOrderOFAController {
  public TAMS_ROA__c roa {get;set;}
  public String sidNumber;
  public Boolean isEditable {get;set;}
  public List<Change_Order_OFA__c> lofa {get;set;}
  public String baseUrl {get;set;}
  public ChangeOrderOFAController (ApexPages.StandardController stdcon) {
      roa = new TAMS_ROA__c();
      lofa = new List<Change_Order_OFA__c>();
        roa = (TAMS_ROA__c)stdcon.getRecord(); 
        System.debug('**ROA'+ roa);
           //ofadetails = getPageOFAList();
      TAMS_ROA__c roas = [SELECT
                               change_order_sid__c
                              ,Status__c
                               FROM
                               TAMS_ROA__c
                               WHERE
                               Id =: roa.Id LIMIT 1];

         sidNumber = roas.change_order_sid__c;
       if(roas.Status__c == 'Pending CFO Approval' || roas.Status__c == 'Pending Finance Mgr Approval' ||  roas.Status__c == 'Pending Gov Mgr Approval' || roas.Status__c == 'Pending Legal Approval' || roas.Status__c == 'Pending Order Management Approval'|| roas.Status__c == 'Pending Credit Approval' || roas.Status__c == 'Pending Logistics Management Approval'  || roas.Status__c == 'Complete'){

            isEditable = true;
       }else{

            isEditable = false;
       }  
       System.debug('Roa Status'+roas.Status__c);
       baseUrl = Url.getSalesforceBaseUrl().toExternalForm(); 
    }
    public List<Schema.FieldSetMember> getFields() {
    System.debug('**Fields'+ SObjectType.Change_Order_OFA__c.FieldSets.COFA_Columns_for_Change_Order_Layout.getFields());
        return SObjectType.Change_Order_OFA__c.FieldSets.COFA_Columns_for_Change_Order_Layout.getFields();

    }
    public List<Change_Order_OFA__c> getofavalues(){
        List<Change_Order_OFA__c> ofa = [SELECT 
                                                Name
                                               ,Included_OFA__c
                                               ,PBOM__c
                                               ,COOFA_Order_Status__c
                                               ,Discountable_List_Price__c
                                               ,Equipment_Gross_Margin__c
                                               ,Equipment_Gross_Margin_Pct__c
                                               ,Equipment_Net_Gross_Margin__c
                                               ,Equipment_Net_Gross_Margin_Pct__c
                                               ,Non_Discountable_List_Price__c
                                               ,Total_COGS__c
                                               ,Total_Equipment_Revenue__c
                                               ,OFA__c
                                               ,OFA__r.Name
                                               ,Order__c
                                               ,Total_Order_Price__c
                                               ,Discount__c 
                                               ,Discount_pct__c
                                               ,Id 
                                               FROM 
                                               Change_Order_OFA__c
                                               WHERE 
                                               SID__c =:sidNumber
                                               AND
                                               Change_Order_Header__c =:roa.id
                                              ]; 
            System.debug('**ofa'+ofa);
            lofa = ofa;
            return ofa;
          }
     public pagereference save(){
         System.debug('Enterted');
        try{
          update lofa;
        }
        catch(DmlException e){
            System.debug(e.getMessage());
        }
        return null;
     }

     public static pagereference ofaTriggerHandler( Set<Id> sCOId ){
       System.debug('set of Ids'+sCOId);
       Map<Id,List<Change_Order_OFA__c>> mChangeOrderHeaderOFA = new Map<Id,List<Change_Order_OFA__c>>();
      List<Change_Order_OFA__c> lChangeOrderOFA  = [Select 
                                      Id
                                     ,Change_Order_Header__c
                                     ,Discountable_List_Price__c
                                     ,Non_Discountable_List_Price__c
                                     ,Discount__c
                                     ,Total_Order_Price__c
                                     ,Total_Equipment_Revenue__c
                                     ,Total_COGS__c
                                     ,Equipment_Gross_Margin__c
                                     ,COOFA_Installation_Amount__c 
                                     ,COOFA_Warranty_Amount__c 
                                     ,Equipment_Net_Gross_Margin__c
                                     ,Order_Type__c
                                     ,COOFA_Promotion_Discount__c
                                     ,COOFA_Trade_In__c
                                     ,Included_OFA__c
                                     ,COOFA_Total_Misc_Charges__c
                                 From 
                                      Change_Order_OFA__c 
                                 Where 
                                      Change_Order_Header__c in :sCOId 
                                    ];

         for(Change_Order_OFA__c cOOfa : lChangeOrderOFA ){
            if(mChangeOrderHeaderOFA.containsKey(cOOfa.Change_Order_Header__c)){
                mChangeOrderHeaderOFA.get(cOOfa.Change_Order_Header__c).add(cOOfa);
              }else{
                List<Change_Order_OFA__c> lcoOFA = new List<Change_Order_OFA__c>();
                lcoOFA.add(cOOfa);
                mChangeOrderHeaderOFA.put(cOOfa.Change_Order_Header__c, lcoOFA);

              }
         }                            

         List<TAMS_ROA__c> lchangeOrderHeaders = new List<TAMS_ROA__c>(); 
    
          for(Id roaId:mChangeOrderHeaderOFA.keySet()){
                List<Change_Order_OFA__c> lcoOFA = mChangeOrderHeaderOFA.get(roaId);
                Decimal Discountable_List_Price = 0;
                Decimal Equipment_Gross_Margin = 0;
                Decimal Equipment_Net_Gross_Margin = 0;
                Decimal Non_Discountable_List_Price= 0;
                Decimal Discount = 0;
                Decimal Total_COGS = 0;
                Decimal Total_Equipment_Revenue = 0;
                Decimal Total_Order_Price = 0;
                Decimal Installation_Amount = 0;
                Decimal Warranty_Amount = 0;
                Decimal Promotion_Discount = 0;
                Decimal Trade_In = 0;
                Decimal Total_Misc_Charges = 0;
                System.debug('ENTERED');
                
                for(Change_Order_OFA__c ccOFA:lcoOFA){
                   if(ccOFA.Order_Type__c  != 'TAMS Systems Return Credit' && ccOFA.Included_OFA__c == true){
                    Discountable_List_Price += ccOFA.Discountable_List_Price__c;
                    Equipment_Gross_Margin += ccOFA.Equipment_Gross_Margin__c;
                    Equipment_Net_Gross_Margin += ccOFA.Equipment_Net_Gross_Margin__c;
                    Non_Discountable_List_Price += ccOFA.Non_Discountable_List_Price__c; 
                    Discount += ccOFA.Discount__c;
                    Total_COGS += ccOFA.Total_COGS__c;
                    Total_Equipment_Revenue += ccOFA.Total_Equipment_Revenue__c;
                    Total_Order_Price += ccOFA.Total_Order_Price__c; 
                    Installation_Amount += ccOFA.COOFA_Installation_Amount__c;
                    Warranty_Amount += ccOFA.COOFA_Warranty_Amount__c;
                    Promotion_Discount += ccOFA.COOFA_Promotion_Discount__c;
                    Trade_In += ccOFA.COOFA_Trade_In__c;
                    Total_Misc_Charges += ccOFA.COOFA_Total_Misc_Charges__c;
                    }
                }
                TAMS_ROA__c changeOrderHeader = new TAMS_ROA__c();
                  changeOrderHeader.Id = roaId;
                  changeOrderHeader.Discountable_List_Price__c = Discountable_List_Price;
                  changeOrderHeader.Equipment_Gross_Margin__c = Equipment_Gross_Margin;
                  changeOrderHeader.Equipment_Net_Gross_Margin__c = Equipment_Net_Gross_Margin;
                  changeOrderHeader.Non_Discountable_List_Price__c = Non_Discountable_List_Price;
                  changeOrderHeader.Discount__c = Discount;
                  changeOrderHeader.Total_COGS__c = Total_COGS;
                  changeOrderHeader.Total_Equipment_Revenue__c = Total_Equipment_Revenue;
                  changeOrderHeader.Total_Order_Price__c = Total_Order_Price;
                  changeOrderHeader.COH_Installation_Amount__c  = Installation_Amount;
                  changeOrderHeader.COH_Warranty_Amount__c = Warranty_Amount;
                  changeOrderHeader.COH_Promotion_Discount__c = Promotion_Discount;
                  changeOrderHeader.COH_Trade_In__c = Trade_In;
                  changeOrderHeader.COH_Total_Misc_Charges__c = Total_Misc_Charges;
                  changeOrderHeader.Order_Financials_As_Of__c = System.now();
                  lchangeOrderHeaders.add(changeOrderHeader);
            }
          System.debug('lroa'+lchangeOrderHeaders);
          try{
          update lchangeOrderHeaders;
          } catch(DmlException e){
            System.debug(e.getMessage());
        }
        return null;
     }

  
}