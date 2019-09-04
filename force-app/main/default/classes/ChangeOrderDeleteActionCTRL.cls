/*********************************************************
        Author:         
        Purpose: This Class is used in Deleting Items on Change Order.        
        1.0 - Lokesh Tigulla              - Created
        1.1 - Lokesh Tigulla - 02/19/2019 - updated
**********************************************************/
public with sharing class ChangeOrderDeleteActionCTRL {
    public List<TAMS_ROA_Lines__c> roaDelLines {get;set;}
    private ID roaID;
    public TAMS_ROA__c roa {get;set;}   
    public List<ChangeOrderLinesWRP> orderLines {get;set;}
    public List<Order_Master__c> lOrds{get;set;}
    public String modality {get;set;}
    public Date orderBookedDate {get;set;}
    public Boolean showSellingPrice {get;set;}
    public Boolean showRMA {get;set;}
    public Boolean isEditable {get;set;}
    public String orderType {get;set;}
    public String orderStatus {get;set;}
    public Decimal orderBookedAmount {get;set;}
    public Boolean selectAll {get;set;}
    public String selectorders1{get;set;}
    public String baseUrl {get;set;}
    public String orderLineStatus {get;set;}
    public List<String> lOrderStatus {get;set;}
    public ChangeOrderDeleteActionCTRL(ApexPages.StandardController stdController) 
    {
        roaDelLines = new List<TAMS_ROA_Lines__c>();
        orderLines = new  List<ChangeOrderLinesWRP >();
        System.debug('***orderLines***'+orderLines);
        roaID = stdController.getId();  
        lOrds = new List<Order_Master__c>(); 
        lOrderStatus = new list<String>();
        System.debug('roaID:'+roaID);
        roa = [SELECT
                     Name
                    ,Change_Order_SID__c
                    ,Change_Requested_By__c
                    ,Customer_Name__c
                    ,Account__c 
                    ,Status__c
                FROM 
                    TAMS_ROA__c 
                WHERE 
                    ID = :roaID LIMIT 1];
        System.debug('roa:'+roa);       
      
       if(roa.Status__c == 'Pending CFO Approval' || roa.Status__c == 'Pending Finance Mgr Approval' ||  roa.Status__c == 'Pending Gov Mgr Approval' || roa.Status__c == 'Pending Legal Approval' || roa.Status__c == 'Pending Order Management Approval'|| roa.Status__c == 'Pending Credit Approval' || roa.Status__c == 'Pending Logistics Management Approval'  || roa.Status__c == 'Complete'){

            isEditable = true;
       }else{

            isEditable = false;
       }

       if(roa.Change_Requested_By__c == 'Internal'){

        showSellingPrice  = false;
         showRMA = true;
       }else{
        showSellingPrice = true;
        showRMA = false;
       }

        baseUrl = Url.getSalesforceBaseUrl().toExternalForm();  
                                  
    }
    public PageReference save()
    {
        System.debug('inside save');   
        List<TAMS_ROA_Lines__c> newRoaLines = new List<TAMS_ROA_Lines__c>(); 
        System.debug('***orderLines***'+orderLines);
        for(ChangeOrderLinesWRP  line:orderLines)
        {
            
            if(line != null){
               
                if(line.selected)
                {
                    System.debug('line**'+line);
                    TAMS_ROA_Lines__c roaLine = new TAMS_ROA_Lines__c();
                    roaLine.TAMS_ROA__c = roaID;
                    roaLine.Order_Line_Master__c = line.orderLineMaster.Id;
                    System.debug('****'+ line.deleteQuantity);
                    roaLine.Quantity__c = line.deleteQuantity;  
                    roaLine.COL_Status__c = line.orderLineMaster.Status__c;
                    roaLine.List_Price__c = line.orderLineMaster.Item_List_Price__c;
                    roaLine.COL_Old_Item__c = line.orderLineMaster.Ordered_Item__c;
                    roaLine.Item_Description__c = line.orderLineMaster.Item_Description__c;
                    roaLine.COL_Comments__c = line.changeOrderLine.COL_Comments__c;
                    if(roa.Change_Requested_By__c == 'Internal'){
                    roaLine.New_Selling_Price__c = line.orderLineMaster.Item_Selling_Price__c;
                    roaLine.Original_Selling_Price__c = line.orderLineMaster.Item_Selling_Price__c; 
                    roaLine.COL_RMA__c = line.changeOrderLine.COL_RMA__c;
                    roaLine.COL_Reason_Code__c = line.changeOrderLine.COL_Reason_Code__c;
                    }else{
                    roaLine.New_Selling_Price__c = line.newSellingPrice;
                    roaLine.Original_Selling_Price__c = line.orderLineMaster.Item_Selling_Price__c;
                    }
                    roaLine.Action_Type__c = 'Delete';
                    roaLine.Order_Number__c = selectorders1;
                    if(line.changeOrderLineId != null || line.changeOrderLineId != ''){
                        roaLine.Id = line.changeOrderLineId;
                    }
                    if(roaLine.Quantity__c == 0 || roaLine.Quantity__c == null ){
                         Apexpages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'Delete Quantity Cannot be Zero or balnk'));
                        return null;
                    }
                    System.debug(line.orderLineMaster.Quantity__c);
                    if(roaLine.Quantity__c > line.orderLineMaster.Quantity__c){
                          Apexpages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'Delete Quantity Cannot be greater than Existing Quantity'));
                          return null;
                    }
                    newRoaLines.add(roaLine);
                    System.debug('roaLine diplay'+ roaLine);                    
                }
            }
        }
        if(newRoaLines.size()>0)
        {
            try
            {
               upsert newRoaLines;
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

        System.debug('lOrderStatus'+lOrderStatus);
        for(ChangeOrderLinesWRP  line:orderLines)
        {
            System.debug('line.selected'+line.selected);
            System.debug('line:'+line);
            if( line.selected == true && (line.deleteQuantity == 0 || line.deleteQuantity == null))
            {
                System.debug('Entered First If');
                line.deleteQuantity = line.orderLineMaster.Quantity__c;
            }

            if( line.selected == false )
            {
                System.debug('Entered Second If');
                line.deleteQuantity = null;     
            }
        //for(String status : lOrderStatus){
        //    System.debug('status'+status);
        //    if(status == 'CLOSED'){
        //        System.debug('true');
        //        line.rmaValue = true;
        //    }else{
        //        System.debug('false');
        //        line.rmaValue = false;
        //    }
        // }
        }

        return null;
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
                                            SID_Order__c =: sid_order
                                            /*AND
                                            Customer_Name__c =:roa.Account__c */];
                         System.debug('***lOrds'+lOrds);
                      if(lOrds.size() >= 1){
                        option.add(new SelectOption('None','None'));
                        System.debug('lOrds'+lOrds);
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
    public PageReference selectAll(){

        System.debug('Entered');
        List<Id> lChangeorderLineId = new List<Id>();
        
        for(TAMS_ROA_Lines__c changeOrderLines : [SELECT Id FROM TAMS_ROA_Lines__c WHERE Order_Number__c = :selectorders1 AND Action_Type__c = 'Delete' AND TAMS_ROA__c =: roaID]){
           lChangeorderLineId.add(changeOrderLines.Id); 
        }
        System.debug('Ids'+lChangeorderLineId);
        for(ChangeOrderLinesWRP line: orderLines){
            System.debug('line'+line.changeOrderLineId);
        if(selectAll == true){
            System.debug('if loop'+selectAll);
              line.selected = true;
        }else{
            if(lChangeorderLineId.contains(line.changeOrderLineId)){   
            line.selected = true;
            System.debug('Selected');
            }else{
                 line.selected = false;
            }
        }
    }
        return null;
    }

    public PageReference orderchange(){
         System.debug('selectedoption'+selectorders1);
         orderLines =  new LIST<ChangeOrderLinesWRP >();
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
                                            /*AND
                                            Customer_Name__c =:roa.Account__c*/
                                            AND 
                                            Oracle_Order_Number__c =: selectorders1];
                 if(lOrds.size() > 0){
                modality = lOrds.get(0).Modality_Order__c;
                orderBookedDate = lOrds.get(0).CMSU_Booked_Date__c;
                orderType = lOrds.get(0).Order_Type__c;
                orderStatus = lOrds.get(0).Order_Status__c;
                orderBookedAmount = lOrds.get(0).Order_Subtotal__c;
            }
            }
                 
         List<Order_Line_Master__c> orderLinesObj = [SELECT
                                                        ID
                                                        ,Line_ID__c
                                                        ,Line_Item_Cost__c
                                                        ,Line_Number__c
                                                        ,Ordered_Item__c
                                                        ,CMSU_Order__r.Modality_Order__c
                                                        ,Quantity__c
                                                        ,Item_Description__c
                                                        ,Status__c
                                                        ,Ordered_Item__r.Name
                                                        ,UOM__c
                                                        ,Item_List_Price__c
                                                        ,Item_Selling_Price__c  
                                                        ,OLM_BTL__c 
                                                        ,OLM_Ordered_Item_Cost__c           
                                                        FROM
                                                         Order_Line_Master__c 
                                                        WHERE
                                                        Order_Num__c = :selectorders1
                                                        ORDER BY Line_Number__c         
                                                             ];

      //   for(Order_Line_Master__c orderstatus : orderLinesObj){
      //      lOrderStatus.add(orderstatus.Status__c);
      //      System.debug('lOrderStatus'+lOrderStatus);
      //}

        List<TAMS_ROA_Lines__c> changeOrderLines  = [SELECT 
                                                        Id
                                                        ,Order_Line_Master__c
                                                        ,Quantity__c
                                                        ,New_Selling_Price__c
                                                        ,COL_Comments__c
                                                        ,COL_RMA__c 
                                                        ,COL_Reason_Code__c 
                                                        ,COL_New_Item__r.Name
                                                        ,COL_Quantity__c
                                                        FROM
                                                        TAMS_ROA_Lines__c
                                                        WHERE
                                                        Order_Number__c = :selectorders1
                                                        AND 
                                                        Action_Type__c = 'Delete'
                                                        AND
                                                        TAMS_ROA__c =: roaID
                                                        ];

                            System.debug('***'+orderLinesObj);
                            System.debug('ROA Lines'+changeOrderLines);
         List<Id> orderlineMasterIds = new List<Id>();
         Map<Id,TAMS_ROA_Lines__c> mchangeOrderLines = new Map<Id,TAMS_ROA_Lines__c>();
         System.debug('changeOrderLines'+changeOrderLines);
         for(TAMS_ROA_Lines__c changeOrderLine:changeOrderLines){
            System.debug('changeOrderLine'+changeOrderLine);
            orderlineMasterIds.add(changeOrderLine.Order_Line_Master__c);
            mchangeOrderLines.put(changeOrderLine.Order_Line_Master__c,changeOrderLine);
         }                                               
         System.debug('list of orderlinemasters'+orderlineMasterIds);
         
        for(Order_Line_Master__c lineObj:orderLinesObj)
        {
            System.debug('lineObjID'+lineObj.Id);
            if(orderlineMasterIds.contains(lineObj.Id)){
                System.debug('entered');
                orderLines.add(new ChangeOrderLinesWRP (lineObj,true,mchangeOrderLines.get(lineObj.Id)));
            }else{
                System.debug('not entered'+mchangeOrderLines.get(lineObj.Id));
                orderLines.add(new ChangeOrderLinesWRP (lineObj,false,mchangeOrderLines.get(lineObj.Id)));
            }
            
        }
         return null;
    }
}