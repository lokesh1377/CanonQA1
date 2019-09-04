/*********************************************************
        Author:         
        Purpose: This Class is used in Replace Items on change Order.        
        1.0 - Lokesh Tigulla              - Created
        1.1 - Lokesh Tigulla - 03/07/2019 - updated
        1.2 - Lokesh Tigulla - 05/02/2019 - updated(List price Logic)
**********************************************************/
public with sharing class ChangeOrderReplaceActionCTRL {
    private ID roaID;
    public TAMS_ROA__c roa {get;set;}   
    public List<ChangeOrderLinesWRP> orderLines {get;set;}
    public List<ItemMaster__c> itemMasters {get;set;}
    public List<Price_List__c> pricelist {get;set;}
    public List<Order_Master__c> lOrds{get;set;}
    //public TAMS_ROA_Lines__c roaLine {get;set;}
    public String modality {get;set;}
    public Decimal newlistprice {get;set;}
    public String selectorders1{get;set;}
    public Date orderBookedDate {get;set;}
    public String orderType {get;set;}
    public string orderStatus {get;set;}
    public Decimal orderBookedAmount {get;set;}
    public String baseUrl {get;set;}
     public Id itemMasterId {get;set;}
     public Boolean isEditable {get;set;}
     public String oldItemNumberId {get;set;}
     public String oldItemNumber {get;set;}
    //public String itemNumber {get;set;}
    //public String bookId {get;set;}
    public String selectedItemNumber {get;set;}
    public ChangeOrderReplaceActionCTRL(ApexPages.StandardController stdController) 
    {
        System.debug('inside TamsROAReplaceActionCTRL controller');
        itemMasters = new List<ItemMaster__c>();
        pricelist = new List<Price_List__c>();
        orderLines = new  List<ChangeOrderLinesWRP >();
        lOrds = new List<Order_Master__c>(); 
        roaID = stdController.getId();
        if(roaID !=null){       
        System.debug('roaID:'+roaID);
        roa = [SELECT
                     Name
                    ,Change_Order_SID__c
                    ,Status__c
                    ,Account__c
                    ,Customer_Name__c
                FROM 
                    TAMS_ROA__c 
                WHERE 
                    ID = :roaID LIMIT 1];
        System.debug('roa:'+roa);  
        baseUrl = Url.getSalesforceBaseUrl().toExternalForm();  
        }  
        if(roa.Status__c == 'Pending Logistics Management Approval' || roa.Status__c == 'Pending Legal Approval' || roa.Status__c == 'Pending CFO Approval' || roa.Status__c == 'Pending Order Management Approval' || roa.Status__c == 'Complete' || roa.Status__c == 'Canceled' || roa.Status__c == 'Pending Finance Mgr Approval'){
          isEditable = true;
        }else{
            isEditable = false;
        } 
    }
    public PageReference save()
    {
        System.debug('inside save');
        List<TAMS_ROA_Lines__c> tamsRoaLines = new List<TAMS_ROA_Lines__c>(); 
         system.debug('oldItemNumber'+oldItemNumber);
         system.debug('selectedItemNumber'+selectedItemNumber);
        for(ChangeOrderLinesWRP line:orderLines)
        {
            if(line.selected)
            {
                System.debug('New Item Number'+line.lookupItemNumber);
                //ItemMaster__c itm = itmMap.get(line.itemNumber);
                //if(itm!=null && itm.Item_Number__c!=null && itm.Item_Number__c == line.itemNumber){
                    System.debug('***'+line);
                    TAMS_ROA_Lines__c roaLine = new TAMS_ROA_Lines__c();
                    roaLine.Action_Type__c = 'Replace';
                    roaLine.Order_Line_Master__c = line.orderLineMaster.Id;
                    roaLine.Original_Selling_Price__c = line.newSellingPrice;
                    roaLine.List_Price__c = line.orderLineMaster.Item_List_Price__c;
                    roaLine.COL_New_Item__c = line.selectedItemNumber;
                    roaLine.COL_Old_Item__c  = line.orderLineMaster.Ordered_Item__c;
                    roaLine.COL_Comments__c = line.changeOrderLine.COL_Comments__c;
                    roaLine.Item_Description__c = line.orderLineMaster.Item_Description__c;
                    roaline.COL_New_List_Price__c = line.listprice;
                    roaline.Quantity__c  =  line.orderLineMaster.Quantity__c;
                    roaline.COL_Quantity__c = line.replaceQuantity;
                    roaline.COL_RMA__c = line.changeOrderLine.COL_RMA__c;
                    roaline.COL_Reason_Code__c = line.changeOrderLine.COL_Reason_Code__c;
                    roaLine.TAMS_ROA__c = roaID;
                    roaLine.Order_Number__c = selectorders1;
                    if(line.changeOrderLineId != null || line.changeOrderLineId != ''){
                        roaline.Id = line.changeOrderLineId;
                    }
                     System.debug('New Line Qty'+roaline.COL_Quantity__c);
                      System.debug('Line Qty'+roaline.Quantity__c);
                    if(roaline.COL_Quantity__c > roaline.Quantity__c ){
                        System.debug('entered');
                        Apexpages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'New Line Quantity could not be less than Regional Line Quantity'));
                        return null;
                    }
                   System.debug('roalines**'+roaLine);   
                    tamsRoaLines.add(roaLine); 
                }
             }
             System.debug('tamsRoaLines'+tamsRoaLines);
        if(tamsRoaLines.size()>0)
        {
            try
            {    
               upsert tamsRoaLines;
            }catch(DmlException e)
            {
               for (Integer i = 0; i < e.getNumDml(); i++) 
               {
                // Process exception here
                    System.debug(e.getDmlMessage(i));
                    Apexpages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,e.getDmlMessage(i)));
                    return null;
               }
            }
        }   
        PageReference retPage = new PageReference('/'+roaID); 
        retPage.setRedirect(true);
        return retPage; 
    }
    public PageReference cancel()
    {
        PageReference retPage = new PageReference('/'+roaID); 
        retPage.setRedirect(true);
        return retPage;        
    }   
    public PageReference checkboxChanged()
    {
        for(ChangeOrderLinesWRP  line:orderLines)
        {
            if( line.selected == true && line.deleteQuantity == 0 ) 
            {
                System.debug('line.deleteQuantity'+line.deleteQuantity);
                System.debug('line.selected'+line.selected);
                line.deleteQuantity = line.orderLine.Quantity__c;
            }
            if( line.selected == false && line.deleteQuantity <> null )
            {
                line.deleteQuantity = null;     
            }
        }
        return null;

    }
     public List<SelectOption> getord(){
            List<SelectOption> option = new List<SelectOption>();
            if(roa !=null){
          Decimal sid_order = Decimal.valueOf(roa.Change_Order_SID__c);
            list<Order_Master__c> lOrds = [SELECT 
                                             ID
                                            ,Oracle_Order_Number__c
                                            ,SID_Order__c
                                            FROM
                                            Order_Master__c
                                            WHERE 
                                            SID_Order__c = :sid_order 
                                            ];
                      if(lOrds.size() >= 1){
                          option.add(new SelectOption('None','None'));
                            for(Order_Master__c lOrd :lOrds){
                            option.add(new SelectOption(lOrd.Oracle_Order_Number__c,lOrd.Oracle_Order_Number__c));
                        }
                    } 
                      //else {
                      //  for(Order_Master__c lOrd :lOrds){
                      //      option.add(new SelectOption(lOrd.Oracle_Order_Number__c,lOrd.Oracle_Order_Number__c));
                      //  }
                      //}
                  }
                  return option;
              }

           
    public PageReference orderchange(){

         System.debug('selectedoption'+selectorders1);
         Set<String> sItemNumbers = new Set<String>();
         orderLines = new List<ChangeOrderLinesWRP >();
        if(selectorders1 == 'None'){
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
                                          /*  AND
                                            Customer_Name__c =:roa.Account__c */
                                            AND 
                                            Oracle_Order_Number__c =: selectorders1];
                   if(lOrds.size() > 0){                      
                  System.debug(lOrds.get(0).Modality_Order__c);
                      modality = lOrds.get(0).Modality_Order__c;
                      orderBookedDate  =  lOrds.get(0).CMSU_Booked_Date__c;
                      orderType = lOrds.get(0).Order_Type__c;
                      orderStatus = lOrds.get(0).Order_Status__c;
                      orderBookedAmount = lOrds.get(0).Order_Subtotal__c;
                       
               System.debug('modality'+modality);
               }

            }
      List<Order_Line_Master__c> orderLinesObj = [SELECT
                                                     ID
                                                    ,Line_ID__c
                                                    ,Line_Item_Cost__c
                                                    ,Item_Description__c
                                                    ,CMSU_Order__r.Modality_Order__c
                                                    ,Line_Number__c
                                                    ,Ordered_Item__c
                                                    ,Quantity__c
                                                    ,Status__c
                                                    ,UOM__c
                                                    ,Item_List_Price__c
                                                    ,Item_Selling_Price__c
                                                    ,Ordered_Item__r.Name
                                                    ,OLM_Ordered_Item_Cost__c 
                                                    FROM
                                                    Order_Line_Master__c
                                                    WHERE
                                                    Order_Num__c = :selectorders1
                                                    ORDER BY Line_Number__c ];

           List<TAMS_ROA_Lines__c> changeOrderLines  = [SELECT 
                                                        Id
                                                        ,Order_Line_Master__c
                                                        ,Quantity__c
                                                        ,COL_Old_Item__c
                                                        ,COL_New_Item__c
                                                        ,COL_New_Item__r.Name
                                                        ,New_Selling_Price__c 
                                                        ,List_Price__c  
                                                        ,COL_RMA__c   
                                                        ,COL_Reason_Code__c                                               
                                                        ,New_Item_Number__c
                                                        ,COL_Comments__c
                                                        ,COL_Quantity__c
                                                        FROM
                                                        TAMS_ROA_Lines__c
                                                        WHERE
                                                        Order_Number__c = :selectorders1
                                                        AND 
                                                        Action_Type__c = 'Replace'
                                                        AND
                                                        TAMS_ROA__c =: roaID
                                                        ];

                            System.debug('***'+orderLinesObj);
                            System.debug('***'+changeOrderLines);
          List<Id> orderlineMasterIds = new List<Id>();
         Map<Id,TAMS_ROA_Lines__c> mchangeOrderLines = new Map<Id,TAMS_ROA_Lines__c>();
         for(TAMS_ROA_Lines__c changeOrderLine:changeOrderLines){
            orderlineMasterIds.add(changeOrderLine.Order_Line_Master__c);
            mchangeOrderLines.put(changeOrderLine.Order_Line_Master__c,changeOrderLine);
         }                                               
         System.debug('list of orderlinemasters'+orderlineMasterIds);
          System.debug('change order lines'+mchangeOrderLines);

            System.debug('orderLinesObj'+orderLinesObj);
        for(Order_Line_Master__c lineObj:orderLinesObj)
        {
            sItemNumbers.add(lineObj.Ordered_Item__c);
        } 
        System.debug('Set of Item numbers'+sItemNumbers);
        System.debug('mchangeOrderLines'+mchangeOrderLines); 

        for(Order_Line_Master__c lineObj:orderLinesObj)
        {
              if(mchangeOrderLines.containsKey(lineObj.Id)){
                //replace button: with new selling price nad New list price
                //orderLines.add(new ChangeOrderLinesWRP (lineObj,true,mFinalItemMaster.get(lineObj.Ordered_Item__c).List_Price__c,mchangeOrderLines.get(lineObj.Id)));
                orderLines.add(new ChangeOrderLinesWRP (lineObj,true,mchangeOrderLines.get(lineObj.Id)));
              }else{
                //orderLines.add(new ChangeOrderLinesWRP (lineObj,true,mFinalItemMaster.get(lineObj.Ordered_Item__c).List_Price__c,mchangeOrderLines.get(lineObj.Id)));
                orderLines.add(new ChangeOrderLinesWRP (lineObj,false,mchangeOrderLines.get(lineObj.Id)));
              }
          
          //else{
          //  if(mchangeOrderLines.containsKey(lineObj.Id)){
          //      orderLines.add(new ChangeOrderLinesWRP (lineObj,true,mchangeOrderLines.get(lineObj.Id)));
          //    }else{
          //      orderLines.add(new ChangeOrderLinesWRP (lineObj,false,mchangeOrderLines.get(lineObj.Id)));
          //    }
          //}

          }
          System.debug('order Lines'+orderLines);                                                     
          return null;
    }

    public PageReference lookupId(){
             Id itemMasterId;
             String itemNumber;
             System.debug('selectedItemNumber:'+Apexpages.currentPage().getParameters().get('selectedItemNumber'));
        selectedItemNumber = Apexpages.currentPage().getParameters().get('selectedItemNumber');
        System.debug('Entered in LookupId method'+selectedItemNumber);
        // Id itemMasterId = [SELECT Id FROM ItemMaster__c WHERE Name =: selectedItemNumber].Id;
        List<ItemMaster__c> ItemNumbers = [SELECT Id,Name,Description__c FROM ItemMaster__c WHERE Name =: selectedItemNumber];
        System.debug('ItemNumbers'+ItemNumbers);
        if(ItemNumbers.size()>0){
                itemMasterId  = ItemNumbers.get(0).Id;
                System.debug('itemMasterId'+itemMasterId);
        }else{
             Apexpages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'Please Enter Correct Item Number')); 
            return null;
        }
         System.debug(itemMasterId);
        if(itemMasterId != null ){
       System.debug('itemMasterId'+itemMasterId);
            string priceListName = [Select 
                                      Price_List__c 
                                     From
                                      Order_Master__c 
                                      Where 
                                      Oracle_Order_Number__c =: selectorders1 LIMIT 1].Price_List__c;

                 System.debug('Price List'+priceListName);
             List<Price_List__c> lItemPriceList = [Select 
                                                       Id
                                                       ,Item__c
                                                       ,List_Price__c
                                                       ,Price_List_Name__c 
                                                   from 
                                                       Price_List__c 
                                                   where 
                                                      Item__c =: itemMasterId 
                                                   AND 
                                                      List_Price__c > 0
                                                   AND
                                                      Price_List_Name__c  =: priceListName ];

                                        System.debug('Item Price List'+lItemPriceList);

               if(lItemPriceList.size() > 0)
               {
                 newlistprice = lItemPriceList.get(0).List_Price__c;
                 System.debug('newlistprice'+newlistprice);
                 //selectedWrapper.newSellingPrice = lItemPriceList.get(0).List_Price__c;
               }else{

                List<Price_List_Hierarchy__c> lPriceListHierarchy = [Select 
                                                                        Child_Price_List_Name__c
                                                                       ,Precedence__c 
                                                                    From 
                                                                         Price_List_Hierarchy__c 
                                                                    Where 
                                                                         Parent_Price_List_Name__c =: priceListName 
                                                                    AND 
                                                                        ( End_Date_Active__c = null OR End_Date_Active__c > TODAY ) 
                                                                    Order by 
                                                                         Precedence__c ];
                System.debug('Item Price List Hierarchy'+lPriceListHierarchy);
                Map<Decimal,String> mChildPriceList  = new Map<Decimal,String>();

                for(Price_List_Hierarchy__c plh:lPriceListHierarchy){
                    mChildPriceList.put(plh.Precedence__c,plh.Child_Price_List_Name__c);
                }
                System.debug('Values'+mChildPriceList);
                List<Price_List__c> lMissingItemPriceList = [Select Id
                                                                   ,Item__c
                                                                   ,List_Price__c
                                                                   ,Price_List_Name__c
                                                             from  
                                                                Price_List__c 
                                                             where 
                                                                Item__c =: itemMasterId
                                                            AND 
                                                                List_Price__c > 0 
                                                            AND 
                                                                 Price_List_Name__c  in: mChildPriceList.values()];

                 System.debug('Missing Item Price List'+lMissingItemPriceList);

                 Boolean breakouterloop = false;
                    for(Decimal precedence : mChildPriceList.keySet()){
                        String childPriceListName = mChildPriceList.get(precedence);
                        for(Price_List__c pl :lMissingItemPriceList){
                                if(pl.Item__c ==  itemMasterId  && pl.Price_List_Name__c == childPriceListName){
                                   newlistprice =  lMissingItemPriceList.get(0).List_Price__c;
                                   //selectedWrapper.newSellingPrice =  lItemPriceList.get(0).List_Price__c;
                                    breakouterloop = true;
                                    break;
                                }
                        }
                        if(breakouterloop){
                            break;
                        } 
                    }
      
                   System.debug(itemMasterId);
               

                List<Price_List__c> lFinalItemMaster = new List<Price_List__c>();
               Set<Id> sItemsNotFoundPH = new Set<Id>();
                    sItemsNotFoundPH.add(itemMasterId);
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
            System.debug('lSalesItems'+lSalesItems);
          
          for(Price_List__c itemPriceList:lSalesItems){
                lFinalItemMaster.add(itemPriceList);
            }
            //Remaining logic for List Price  
             Set<Id> sItemsNotFoundPP = new Set<Id>();
             for(Id itemNumberNotFound2 : sItemsNotFoundPH){
                      sItemsNotFoundPP.add(itemNumberNotFound2);
             }
             System.debug('sItemsNotFoundPP'+sItemsNotFoundPP);
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
                      System.debug('lTamsPartPrice'+lTamsPartPrice);
                for(Price_List__c itemPriceList1:lTamsPartPrice){
                lFinalItemMaster.add(itemPriceList1);
            }
              System.debug(lFinalItemMaster);    
             if(lFinalItemMaster.size() > 0){
             newlistprice = lFinalItemMaster.get(0).List_Price__c;
             System.debug('newlistprice'+newlistprice);
             }else{
              newlistprice = 0;
              System.debug('newlistprice'+newlistprice);
                }
               }
    }
        System.debug(newlistprice);
        for(ChangeOrderLinesWRP orderLine: orderLines){
            if(orderLine.lookupItemNumber == selectedItemNumber){
                System.debug('entered'+orderLine.lookupItemNumber+'::'+selectedItemNumber+'::'+itemMasterId);
                orderLine.selectedItemNumber = itemMasterId;
                orderLine.listprice = newlistprice;
                 oldItemNumberId = orderLine.orderLineMaster.Ordered_Item__c;
                system.debug('old Item Number'+orderLine.orderLineMaster.Ordered_Item__c);
                System.debug('orderLine.selectedItemNumber:'+orderLine.selectedItemNumber);
            }            
        }
        List<ItemMaster__c> lItemNumber = [Select Name From ItemMaster__c Where Id =: oldItemNumberId];
        if(lItemNumber.size() > 0){
            oldItemNumber = lItemNumber.get(0).Name;
        }
         System.debug('oldItemNumber'+oldItemNumber);
        return null;
    }     
}