/*********************************************************
        Author:Lokesh Tigulla         
        Purpose: This Class is used in Adding Items in Change Order Lines on Change Order.        
        1.0 - Lokesh Tigulla              - Created
        1.1 - Lokesh Tigulla - 02/19/2019 - updated
**********************************************************/
public with sharing class ChangeOrderAddActionCTRL {
    public List<TAMS_ROA_Lines__c> roaLines {get;set;}
    private ID roaID;
    public TAMS_ROA__c roa {get;set;}
    public Boolean showBTLItems {get;set;}
    public String ItemNumber {get;set;}
    public String Description {get;set;}
    public List<ItemMasterWrapper> itemMasters{get;set;}
    public List<ChangeOrderLinesWrapper> ChangeOrderLines{get;set;}
    public List<OrderLinesMasterWrapper> OrderLinesMaster{get;set;}
    public List<Order_Master__c> lOrds{get;set;}
    public List<Order_Master__c> omd {get;set;}
    public String bookId {get;set;}
    public Decimal qfaDiscountPercentage{get;set;}
    public Boolean isEditable {get;set;}
    public string modality {get;set;}
    public Date orderBookedDate {get;set;}
    public String orderType {get;set;}
    public String orderStatus {get;set;}
    public Decimal orderBookedAmount {get;set;}
    public String listpriceName {get;set;}
    public Id listpriceId {get;set;}
    public String selectorders1{get;set;} 
    public Boolean changeRequestedBy{get;set;}
    public Boolean internal {get;set;}
    public String baseUrl {get;set;}
    public ChangeOrderAddActionCTRL (ApexPages.StandardController stdController) 
    {
        roaID = stdController.getId();      
        System.debug('roaID:'+roaID);
        showBTLItems = false;
        baseUrl = Url.getSalesforceBaseUrl().toExternalForm();  
        roaLines    = new List<TAMS_ROA_Lines__c>();
        ChangeOrderLines = new List<ChangeOrderLinesWrapper>();
        OrderLinesMaster = new LIST<OrderLinesMasterWrapper>();
        lOrds = new List<Order_Master__c>();
        omd = new List<Order_Master__c>();
        List<TAMS_ROA_Lines__c> roalines = [SELECT Id
                                                   ,COL_Old_Item__c
                                                   ,Item_Description__c
                                                   ,Order_Number__c
                                                   ,TAMS_ROA__c
                                                   ,New_Selling_Price__c
                                                   ,COL_BTL__c 
                                                   ,COL_Suggested_Selling_Price__c
                                                   ,COL_Reason_Code__c
                                                   ,List_Price__c   
                                                   ,COL_Comments__c  
                                                   ,COL_Old_Item_Cost__c                                                                                        
                                                   FROM
                                                   TAMS_ROA_Lines__c
                                                   WHERE
                                                   Action_Type__c = 'Add' 
                                                   AND
                                                   TAMS_ROA__c = :roaID];

        for(TAMS_ROA_Lines__c roalinetemp:roalines){
            ChangeOrderLines.add(new ChangeOrderLinesWrapper(false,roalinetemp));
        }
        System.debug('change order lines'+ChangeOrderLines);
        
        List<TAMS_ROA__c> roas = [SELECT 
                                   Name
                                  ,Customer_Name__c
                                  ,Change_Order_SID__c
                                  ,Account__c
                                  ,Account_Number__c
                                  ,Status__c
                                  ,Change_Requested_By__c
                                  FROM 
                                  TAMS_ROA__c 
                                  WHERE 
                                  ID = :roaID LIMIT 1];
        System.debug('roas.size:'+roas.size());
        if(roas.size() != 1){
            return;
        }
        roa = roas[0];

        if(roa.Status__c == 'Pending CFO Approval' || roa.Status__c == 'Pending Finance Mgr Approval' ||  roa.Status__c == 'Pending Gov Mgr Approval' || roa.Status__c == 'Pending Legal Approval' || roa.Status__c == 'Pending Order Management Approval'|| roa.Status__c == 'Pending Credit Approval' || roa.Status__c == 'Pending Logistics Management Approval'  || roa.Status__c == 'Complete'){

            isEditable = true;
       }else{

            isEditable = false;
       }
        
        if(roa.Change_Requested_By__c == 'Internal'){

          changeRequestedBy = false;
          internal = true;
        }else{
          changeRequestedBy = true;
          internal = false;
        }

        System.debug('TAMS_ROA__c: '+roa);
          
    }
    public PageReference back()
    {
        PageReference retPage = new PageReference('/'+roaID); 
        retPage.setRedirect(true);
        return retPage;        
    }     

    public class ItemMasterWrapper{
        public Boolean isSelected{get;set;}
        public ItemMaster__c itMaster{get;set;} 
        public String itemNumber{get;set;}
        public String description{get;set;}
        //public Id changeOrderLineId {get;set;}
        public Decimal listPrice{get;set;}
        public Decimal sellingPrice{get;set;}
        public Decimal ofaSellingPrice{get;set;}
        public String selectorders1{get;set;}
        public Decimal suggestedSellingPrice {get;set;}
        public TAMS_ROA_Lines__c changeOrderLines {get;set;}
        public ItemMasterWrapper(Boolean isSelected, ItemMaster__c itMaster, Decimal listPrice, Decimal ofaSellingPrice ){
            this.isSelected = isSelected;
            this.itMaster = itMaster;
            this.listPrice = listPrice;
            changeOrderLines = new TAMS_ROA_Lines__c();
            this.ofaSellingPrice = ofaSellingPrice;
            System.debug('ofa Selling price'+ofaSellingPrice);
            system.debug('listPrice'+listPrice);
            if(itMaster.Discountable__c == 'Y' || itMaster.Discountable__c == ''){
                System.debug('y or blank'+itMaster.Discountable__c);
                this.suggestedSellingPrice = listPrice - (listPrice * (ofaSellingPrice/100));
            }else{
               System.debug('No'+itMaster.Discountable__c);
              this.suggestedSellingPrice = listPrice;
            }           
          }
    }

    public class ChangeOrderLinesWrapper{
        public Boolean isSelected{get;set;}
        public Id changeOrderLineId {get;set;}
        public TAMS_ROA_Lines__c troaline {get;set;}

        public ChangeOrderLinesWrapper( Boolean isSelected, TAMS_ROA_Lines__c troaline){
            this.isSelected = isSelected;
            this.troaline = troaline;
            this.changeOrderLineId = troaline.Id;
    
        }
    }

    public class OrderLinesMasterWrapper{
        public Boolean isSelected{get;set;}
        public Order_Line_Master__c odmline{get;set;}

        public OrderLinesMasterWrapper(Boolean isSelected, Order_Line_Master__c odmline){
            this.isSelected = isSelected;
            this.odmline = odmline;
        }
    }

    public PageReference search(){
        System.debug('***'+ItemNumber);
        String itemNum = String.escapeSingleQuotes(ItemNumber);
        String descrption = String.escapeSingleQuotes(Description);
        List<ItemMaster__c> itemMastrs = new List<ItemMaster__c>();
        List<Price_List__c> pricelis = new List<Price_List__c>();
        itemMasters = new List<ItemMasterWrapper>();
       

        if(itemNum != ''|| descrption != ''){
            String query = 'Select Id,Item_Number__c,Description__c,Discountable__c,Inventory_Item_Id__c,Item_Cost__c from ItemMaster__c WHERE Item_Type__c != \'TAMS PTO Model\'';   
            if(itemNum != ''){
                query = query + ' AND Item_Number__c = \''+ itemNum + '\''; 
            }  
            if(descrption != ''){
                 query = query + ' AND Description__c = \'' + descrption + '\'';
            } 
            query = query + 'LIMIT 100'; 
            itemMastrs = Database.query(query);                 
            Set<Id> sItemMasterIds = new Set<Id>();
            for(ItemMaster__c itemMaster : itemMastrs){
                sItemMasterIds.add(itemMaster.Id);
            }

            if(selectorders1 == 'None'){
             System.debug('*selectorders1**'+selectorders1);
             Apexpages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'Please Select the Order Number'));
                  return null;
            }
            
            string priceListName = [Select 
                                          Price_List__c 
                                     From 
                                          Order_Master__c 
                                     Where 
                                          Oracle_Order_Number__c =: selectorders1 LIMIT 1].Price_List__c;
                                          
            System.debug('priceListName'+priceListName);
              System.debug('sItemMasterIds'+sItemMasterIds);
            List<Price_List__c> lItemPriceList = [Select 
                                                         Id
                                                        ,Item__c
                                                        ,List_Price__c
                                                        ,Price_List_Name__c 
                                                   from 
                                                         Price_List__c 
                                                  where 
                                                         Item__c in : sItemMasterIds 
                                                    AND 
                                                         List_Price__c > 0 
                                                    AND 
                                                         Price_List_Name__c  =: priceListName 
                                                    AND 
                                                        (Line_End_Date__c = null OR Line_End_Date__c > TODAY)
                                                    Order By 
                                                    Line_Precedence__c ]; 
     
             System.debug('lItemPriceList'+lItemPriceList);
             
            Map<Id,Price_List__c> mFinalItemMaster = new Map<Id,Price_List__c>();

            for(Price_List__c itemPriceList:lItemPriceList){
                mFinalItemMaster.put(itemPriceList.Item__c,itemPriceList);
            }

            Set<Id> sItemPriceNotFound = new Set<Id>();
            for(Id itemMaster:sItemMasterIds){
                if(!mFinalItemMaster.containsKey(itemMaster)){
                    sItemPriceNotFound.add(itemMaster);
                }
            }

            if(sItemPriceNotFound.size()>0){
                List<Price_List_Hierarchy__c> lPriceListHierarchy = [Select 
                                                                            Child_Price_List_Name__c
                                                                           ,Precedence__c 
                                                                       From 
                                                                             Price_List_Hierarchy__c 
                                                                       Where 
                                                                             Parent_Price_List_Name__c =: priceListName 
                                                                         AND 
                                                                         ( End_Date_Active__c = Null OR End_Date_Active__c > TODAY ) 
                                                                    Order by 
                                                                         Precedence__c ];
                System.debug('lPriceListHierarchy'+lPriceListHierarchy);

                Map<Decimal,String> mChildPriceList  = new Map<Decimal,String>();

                for(Price_List_Hierarchy__c plh:lPriceListHierarchy){
                    mChildPriceList.put(plh.Precedence__c,plh.Child_Price_List_Name__c);
                }
                List<Price_List__c> lMissingItemPriceList = [Select 
                                                                   Id
                                                                  ,Item__c
                                                                  ,List_Price__c
                                                                  ,Price_List_Name__c 
                                                              from 
                                                                   Price_List__c 
                                                             where 
                                                                   Item__c in : sItemPriceNotFound 
                                                               AND 
                                                                   List_Price__c > 0 
                                                               AND 
                                                                   Price_List_Name__c  in: mChildPriceList.values()];
                System.debug('check***'+lMissingItemPriceList);
                Boolean breakouterloop = false;
                for(Id itemPrice:sItemPriceNotFound){
                    breakouterloop = false;
                    for(Decimal precedence : mChildPriceList.keySet()){
                        String childPriceListName = mChildPriceList.get(precedence);
                        for(Price_List__c pl :lMissingItemPriceList){
                                if(pl.Item__c == itemPrice && pl.Price_List_Name__c == childPriceListName){
                                    mFinalItemMaster.put(pl.Item__c,pl);
                                    breakouterloop = true;
                                    break;
                                }
                        }
                        if(breakouterloop){
                            break;
                        } 
                    }
                }
            }

            Set<Id> sItemsNotFoundPH = new Set<Id>();
            for(Id itemNumberNotFound : sItemPriceNotFound){
                if(!mFinalItemMaster.containsKey(itemNumberNotFound)){
                    sItemsNotFoundPH.add(itemNumberNotFound);
                }
            }

               List<Price_List__c> lSalesItems = [Select 
                                                        Id
                                                       ,Item__c
                                                       ,List_Price__c
                                                       ,Price_List_Name__c 
                                                    from 
                                                        Price_List__c 
                                                    where 
                                                        Price_List_Name__c  = 'SALES ITEMS PRICE LIST' 
                                                     AND 
                                                        Item__c in : sItemsNotFoundPH 
                                                     AND ( Line_End_Date__c= null OR Line_End_Date__c> TODAY)];
          
          for(Price_List__c itemPriceList:lSalesItems){
                mFinalItemMaster.put(itemPriceList.Item__c,itemPriceList);
            }
            //Remaining logic for List Price  
             Set<Id> sItemsNotFoundPP = new Set<Id>();
             for(Id itemNumberNotFound2 : sItemsNotFoundPH){
                if(!mFinalItemMaster.containsKey(itemNumberNotFound2)){
                      sItemsNotFoundPP.add(itemNumberNotFound2);
                }
             }
              List<Price_List__c> lTamsPartPrice = [Select 
                                                            Item__c
                                                           ,List_Price__c
                                                           ,Price_List_Name__c 
                                                        from 
                                                            Price_List__c 
                                                        where 
                                                            Price_List_Name__c  = 'TAMS PARTS PRICE LIST' 
                                                         AND 
                                                            Item__c in : sItemsNotFoundPP 
                                                         AND ( Line_End_Date__c= null OR Line_End_Date__c> TODAY)];
                for(Price_List__c itemPriceList1:lTamsPartPrice){
                mFinalItemMaster.put(itemPriceList1.Item__c,itemPriceList1);
            }
               
          System.debug('mFinalItemMaster'+mFinalItemMaster);
            for(ItemMaster__c itm : itemMastrs){
                if(mFinalItemMaster.containsKey(itm.id)){
                   listpriceId = mFinalItemMaster.get(itm.Id).Id;
                   listpriceName = mFinalItemMaster.get(itm.Id).Price_List_Name__c;

                        itemMasters.add(new ItemMasterWrapper(false, itm, mFinalItemMaster.get(itm.Id).List_Price__c,qfaDiscountPercentage));
                }else{
                        itemMasters.add(new ItemMasterWrapper(false, itm, 0,qfaDiscountPercentage));
                }
            }
        }
        return null;
    }
    public void saveOrderLines(){
        System.debug(itemMasters);

        List<TAMS_ROA_Lines__c> changeOrderLinestoInsert = new List<TAMS_ROA_Lines__c>();
        
         
        if(null != itemMasters ){
        for(ItemMasterWrapper imw : itemMasters){
          System.debug('imw.isSelected'+imw.isSelected);
            if(imw.isSelected == true){
              System.debug('entered in for loop');
                TAMS_ROA_Lines__c col = new TAMS_ROA_Lines__c();
                System.debug('***record'+imw);
                col.COL_Old_Item__c = imw.itMaster.Id;
                col.Item_Description__c = imw.itMaster.Description__c; 
                col.TAMS_ROA__c = roaID;
                col.Action_Type__c = 'Add';
                col.List_Price__c = imw.listPrice;
                col.Order_Number__c = selectorders1;
                col.Quantity__c = 1;
                col.COL_Comments__c = imw.changeOrderLines.COL_Comments__c;
                if(roa.Change_Requested_By__c == 'Internal'){
                  col.New_Selling_Price__c = 0;
                  col.COL_Suggested_Selling_Price__c = null;
                  col.COL_Reason_Code__c = imw.changeOrderLines.COL_Reason_Code__c;
                }else{
                col.New_Selling_Price__c = imw.sellingPrice;
                col.COL_Suggested_Selling_Price__c = imw.suggestedSellingPrice;
              }
               
                //for(ChangeOrderLinesWrapper changeOrderLine :ChangeOrderLines ){
                //   System.debug('roaID'+roaID);
                  //if(changeOrderLine.troaline.COL_Old_Item__c == imw.itMaster.Id && changeOrderLine.troaline.Order_Number__c == selectorders1){
                  //  col.Id = changeOrderLine.changeOrderLineId;
                  //  System.debug('inside roaID'+roaID);
                  //}
                //}
                 System.debug('listpriceId'+listpriceId);
                System.debug('listpriceName'+listpriceName);
                col.Found_in_Price_List_Id__c = listpriceId;
                col.Found_in_Price_List_Name__c = listpriceName;
                changeOrderLinestoInsert.add(col);
            }
        }
          if(changeOrderLinestoInsert.size()>0){
            try{
              System.debug('change Order Lines'+changeOrderLinestoInsert);
              insert changeOrderLinestoInsert;
            ChangeOrderLines = new List<ChangeOrderLinesWrapper>();
            List<TAMS_ROA_Lines__c> roalines = [SELECT Id
                                                   ,COL_Old_Item__c
                                                   ,Item_Description__c
                                                   ,Order_Number__c
                                                   ,TAMS_ROA__c
                                                   ,New_Selling_Price__c
                                                   ,COL_BTL__c 
                                                   ,COL_Reason_Code__c
                                                   ,COL_Suggested_Selling_Price__c
                                                   ,List_Price__c 
                                                   ,COL_Comments__c 
                                                   ,COL_Old_Item_Cost__c                                                
                                                   FROM
                                                   TAMS_ROA_Lines__c
                                                   WHERE
                                                   Action_Type__c = 'Add' 
                                                   AND
                                                   TAMS_ROA__c = :roaID];

        for(TAMS_ROA_Lines__c roalinetemp:roalines){
            ChangeOrderLines.add(new ChangeOrderLinesWrapper(false,roalinetemp));
        }
          }
          catch(DmlException e)
            {
               for (Integer i = 0; i < e.getNumDml(); i++) 
               {
                // Process exception here
                    System.debug(e.getDmlMessage(i));
                    Apexpages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,e.getDmlMessage(i)));
               }
            }
          }
          
      }
    }
    public void removeitem(){
        Integer i =0;
        List<ChangeOrderLinesWrapper> ChangeOrderLinesTemp = new List<ChangeOrderLinesWrapper>();
        List<TAMS_ROA_Lines__c> lTAMSROALines = new List<TAMS_ROA_Lines__c>();
        System.debug('**List of Change order lines'+lTAMSROALines);
        for(ChangeOrderLinesWrapper changeOrderline:ChangeOrderLines){
            if(changeOrderline.isSelected == false){
                ChangeOrderLinesTemp.add(changeOrderline);      
            }else if(changeOrderline.isSelected == true){
                lTAMSROALines.add(new TAMS_ROA_Lines__c(Id = changeOrderline.troaline.Id));
            }
        }
        ChangeOrderLines = ChangeOrderLinesTemp;
        System.debug('**changeorderline is'+lTAMSROALines);
        delete lTAMSROALines;

        }
        public List<SelectOption> getord(){
            List<SelectOption> option = new List<SelectOption>();
             Decimal sid_order = Decimal.valueOf(roa.Change_Order_SID__c);
            if(null != roa && null != roa.Change_Order_SID__c){
            list<Order_Master__c> lOrds = [SELECT 
                                             ID
                                            ,Oracle_Order_Number__c
                                            ,SID_Order__c
                                            FROM
                                            Order_Master__c
                                            WHERE 
                                            SID_Order__c = :sid_order 
                                           /* And
                                            Customer_Name__c =:roa.Account__c */
                                            ];
                      if(lOrds.size() >= 1){
                        option.add(new SelectOption('None','None'));
                            for(Order_Master__c lOrd :lOrds){
                            option.add(new SelectOption(lOrd.Oracle_Order_Number__c,lOrd.Oracle_Order_Number__c));
                        }
                    }
                      
                    //  else {
                    //    for(Order_Master__c lOrd :lOrds){
                    //        option.add(new SelectOption(lOrd.Oracle_Order_Number__c,lOrd.Oracle_Order_Number__c));
                    //    }
                    //}
                }
                  
                  return option;
            }

    public PageReference orderchange(){
            System.debug('selectedoption'+selectorders1);
            OrderLinesMaster =  new LIST<OrderLinesMasterWrapper>();
             qfaDiscountPercentage = 0;
            if(selectorders1 == 'None'){
              qfaDiscountPercentage = null;
              modality = null;
              orderBookedDate = null;
              orderType = null;
              orderStatus = null;
              orderBookedAmount = null;
                return null;
            }else{
                Decimal sid_order = Decimal.valueOf(roa.Change_Order_SID__c);
                 list<Order_Master__c> lOrds = [SELECT 
                                             ID
                                            ,Oracle_Order_Number__c
                                            ,SID_Order__c
                                            ,CMSU_Booked_Date__c
                                            ,Order_Type__c
                                            ,Order_Status__c
                                            ,Order_Subtotal__c
                                            ,Modality_Order__c
                                            FROM
                                            Order_Master__c
                                            WHERE 
                                            SID_Order__c =: sid_order
                                            AND
                                         /*   Customer_Name__c =:roa.Account__c
                                            AND */
                                            Oracle_Order_Number__c =: selectorders1];
                 if(lOrds.size() > 0){
                modality = lOrds.get(0).Modality_Order__c;
                orderBookedDate = lOrds.get(0).CMSU_Booked_Date__c;
                orderType = lOrds.get(0).Order_Type__c;
                orderStatus = lOrds.get(0).Order_Status__c;
                orderBookedAmount = lOrds.get(0).Order_Subtotal__c;
              }
            }
            
           List<Order_Financial_Analysis__c> lofaData  = [Select
                                                          QFA_Discount_Pct__c
                                                     From
                                                           Order_Financial_Analysis__c
                                                    Where 
                                                           Sales_Order__c =: selectorders1 limit 1];

                    if(lofaData.size()>0){
                        qfaDiscountPercentage = lofaData.get(0).QFA_Discount_Pct__c;
                    }else{
                        qfaDiscountPercentage = 0;
                    }
                    System.debug('qfavalue'+qfaDiscountPercentage);

             System.debug('**ord'+omd);                                  
           List<Order_Line_Master__c> toline = [SELECT 
                                             Line_Number__c
                                            ,Order_Num__c
                                            ,Ordered_Item__c
                                            ,Item_Description__c
                                            ,Quantity__c
                                            ,UOM__c
                                            ,Item_List_Price__c
                                            ,Ordered_Item__r.Name
                                            ,Item_Selling_Price__c
                                             FROM
                                             Order_Line_Master__c 
                                             WHERE 
                                             Order_Num__c = :selectorders1 
                                             ORDER BY
                                             Line_Number__c ];
                      System.debug('***toline'+toline);
             for(Order_Line_Master__c torline:toline){
                      OrderLinesMaster.add(new OrderLinesMasterWrapper(false,torline));
            }
                     return null;
        }
    }