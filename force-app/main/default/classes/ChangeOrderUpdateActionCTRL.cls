/*********************************************************
        Author:         
        Purpose: This Class is used in update Items.        
        1.0 - Lokesh Tigulla              - Created
        1.1 - Lokesh Tigulla - 02/19/2019 - updated
**********************************************************/
public with sharing class ChangeOrderUpdateActionCTRL {
    public List<TAMS_ROA_Lines__c> roaUpdLines {get;set;}
    private ID roaID;
    public TAMS_ROA__c roa {get;set;}   
    public List<ChangeOrderLinesWRP > orderLines {get;set;}
    public String selectorders1{get;set;}
    public string modality {get;set;}
    public Boolean isEditable {get;set;}
    public Date orderBookedDate {get;set;}
    public String orderType {get;set;}
    public String orderStatus {get;set;}
    public Decimal orderBookedAmount {get;set;}
    public ChangeOrderUpdateActionCTRL (ApexPages.StandardController stdController) 
    {
        System.debug('inside TamsROADeleteActionCTRL controller');
        roaUpdLines = new List<TAMS_ROA_Lines__c>();
        orderLines = new  List<ChangeOrderLinesWRP >();
        roaID = stdController.getId();      
        System.debug('roaID:'+roaID);
        roa = [SELECT 
                     Name
                    ,Change_Order_SID__c
                    ,Customer_Name__c
                    ,Account__c
                    ,Status__c
                FROM 
                    TAMS_ROA__c 
                WHERE 
                    ID = :roaID LIMIT 1];
        System.debug('roa:'+roa);  
         if(roa.Status__c == 'Pending CFO Approval' || roa.Status__c == 'Pending Finance Mgr Approval' ||  roa.Status__c == 'Pending Gov Mgr Approval' || roa.Status__c == 'Pending Legal Approval' || roa.Status__c == 'Pending Order Management Approval' || roa.Status__c == 'Complete'){

            isEditable = true;
       }else{

            isEditable = false;
       }                             
    }
    public PageReference save()
    {
        System.debug('inside save');  
        List<TAMS_ROA_Lines__c> newRoaLines = new List<TAMS_ROA_Lines__c>(); 
        for(ChangeOrderLinesWRP  line:orderLines)
        {
            if(line.selected)
            {
                TAMS_ROA_Lines__c roaLine = new TAMS_ROA_Lines__c();
                roaLine.TAMS_ROA__c = roaID;
                roaLine.Action_Type__c = 'Update';
                roaLine.Order_Line_Master__c = line.orderLineMaster.Id;
                roaLine.Quantity__c = line.orderLineMaster.Quantity__c;
                roaLine.New_Selling_Price__c = line.newSellingPrice;
                roaLine.Original_Selling_Price__c = line.orderLineMaster.Item_Selling_Price__c;
                roaLine.List_Price__c = line.orderLineMaster.Item_List_Price__c;
                roaLine.COL_Old_Item__c = line.orderLineMaster.Ordered_Item__c;
                roaline.COL_Comments__c = line.changeOrderLine.COL_Comments__c;
                roaLine.Item_Description__c = line.orderLineMaster.Item_Description__c;
                roaLine.Order_Number__c = selectorders1;
                  if(line.changeOrderLineId != null || line.changeOrderLineId != ''){
                        roaline.Id = line.changeOrderLineId;
                    }
                newRoaLines.add(roaLine);
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
       for(ChangeOrderLinesWRP  line:orderLines)
        {
            if( line.selected == true && line.deleteQuantity == 0 && line.selectAll == true )
            {
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
            if(null != roa && null != roa.Change_Order_SID__c){
                 Decimal sid_order = Decimal.valueOf(roa.Change_Order_SID__c);
            list<Order_Master__c> lOrds = [SELECT 
                                             ID
                                            ,Oracle_Order_Number__c
                                            ,SID_Order__c
                                            FROM
                                            Order_Master__c
                                            WHERE 
                                            SID_Order__c = :sid_order];
                         System.debug('***lOrds'+lOrds);
                      if(lOrds.size() >= 1){
                        option.add(new SelectOption('None','None'));
                        System.debug('lOrds'+lOrds);
                            for(Order_Master__c lOrd :lOrds){
                            option.add(new SelectOption(lOrd.Oracle_Order_Number__c,lOrd.Oracle_Order_Number__c));
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
                                            AND
                                            Customer_Name__c =:roa.Account__c
                                            AND 
                                            Oracle_Order_Number__c =: selectorders1];

                modality = lOrds.get(0).Modality_Order__c;
                orderBookedDate = lOrds.get(0).CMSU_Booked_Date__c;
                orderType = lOrds.get(0).Order_Type__c;
                orderStatus = lOrds.get(0).Order_Status__c;
                orderBookedAmount = lOrds.get(0).Order_Subtotal__c;
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
                                                        ,UOM__c
                                                        ,Item_List_Price__c
                                                        ,Item_Selling_Price__c              
                                                        FROM
                                                         Order_Line_Master__c 
                                                        WHERE
                                                        Order_Num__c = :selectorders1
                                                        ORDER BY Line_Number__c         
                                                             ];

        List<TAMS_ROA_Lines__c> changeOrderLines  = [SELECT 
                                                        Id
                                                        ,Order_Line_Master__c
                                                        ,Quantity__c
                                                        ,New_Selling_Price__c
                                                        ,COL_Comments__c
                                                        FROM
                                                        TAMS_ROA_Lines__c
                                                        WHERE
                                                        Order_Number__c = :selectorders1
                                                        AND 
                                                        Action_Type__c = 'Update'
                                                        AND
                                                         TAMS_ROA__c =: roaID
                                                        ];

                            System.debug('***'+orderLinesObj);
            if(orderLinesObj.size() > 0){
                modality = orderLinesObj.get(0).CMSU_Order__r.Modality_Order__c;
            }
            List<Id> orderlineMasterIds = new List<Id>();
         Map<Id,TAMS_ROA_Lines__c> mchangeOrderLines = new Map<Id,TAMS_ROA_Lines__c>();

         for(TAMS_ROA_Lines__c changeOrderLine:changeOrderLines){
            orderlineMasterIds.add(changeOrderLine.Order_Line_Master__c);
            mchangeOrderLines.put(changeOrderLine.Order_Line_Master__c,changeOrderLine);
         }                                               
         System.debug('list of orderlinemasters'+orderlineMasterIds);

        if(orderLinesObj.size() > 0){
            modality = orderLinesObj.get(0).CMSU_Order__r.Modality_Order__c;
        } 
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