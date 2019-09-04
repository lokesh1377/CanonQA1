trigger ChangeOrderOFATrigger on Change_Order_OFA__c (after insert,after update) {
       if((trigger.IsInsert || trigger.IsUpdate) && trigger.IsAfter){
          Map<Id,List<Change_Order_OFA__c>> mChangeOrderHeaderOFA = new Map<Id,List<Change_Order_OFA__c>>();

          Set<Id> sCOId = new Set<Id>();
          for(Change_Order_OFA__c cOOfa: trigger.new)
          {  
              sCOId.add(cOOfa.Change_Order_Header__c);
          }

          System.debug('set of Ids'+sCOId);

        if(sCOId.size() > 0){
        
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
          update lchangeOrderHeaders;
       }
     }
}