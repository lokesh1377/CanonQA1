/*********************************************************
        Author:         
        Purpose: This Class is a Wrapper for Delete,Update,Replace on Change Order.        
        1.0 - Lokesh Tigulla              - Created
        1.1 - Lokesh Tigulla - 02/19/2019 - updated
**********************************************************/
public with sharing class ChangeOrderLinesWRP 
{
    public TAMS_Order_Lines__c orderLine {get;set;}
    public Order_Line_Master__c orderLineMaster {get;set;}
    public TAMS_ROA_Lines__c changeOrderLine {get;set;}
    public Id changeOrderLineId {get;set;}
    public ItemMaster__c itMaster{get;set;} 
    public Boolean selected {get;set;}
    public Boolean selectAll {get;set;}
    public Decimal deleteQuantity {get;set;}
    public String replaceItemNumber {get;set;}
    public Decimal newSellingPrice {get;set;}
    public Decimal replaceQuantity {get;set;}
    public Boolean marginImpact{get;set;}
    public Decimal newListPrice {get;set;}
    public String itemNumber{get;set;}
    public String selectedItemNumber {get;set;}
    public String lookupItemNumber {get;set;}
    public Boolean rmaValue {get;set;}
    public Decimal listprice {get;set;}
    public ChangeOrderLinesWRP ( Decimal newListPrice, Decimal newSellingPrice ,Decimal deleteQuantity ) 
    {
        //orderLine = pLine;
        selected = false; 
        selectAll = false; 
        replaceItemNumber = null;
        newSellingPrice = null;
        deleteQuantity = null;
        replaceQuantity = null;
        //rmaValue = false;
        //selectedItemNumber = orderLineMaster.Ordered_Item__c;
        marginImpact = false;
        changeOrderLine = new TAMS_ROA_Lines__c();
        this.deleteQuantity = deleteQuantity;
        this.newListPrice = newListPrice;
        this.newSellingPrice = newSellingPrice;
        system.debug('lookupItemNumber'+lookupItemNumber);
    }
    //public ChangeOrderLinesWRP (TAMS_Order_Lines__c pLine){

    //    orderLine = pLine;
    //    this.selected = false;
    //}
    //public ChangeOrderLinesWRP ( Order_Line_Master__c mline , Decimal newListPrice, Decimal newSellingPrice){
        
    //    orderLineMaster = mline;
    //}
    //Constructor used for Delete,Replace and update Item
    public ChangeOrderLinesWRP ( Order_Line_Master__c mline, Boolean isExist, TAMS_ROA_Lines__c changeOrderLine){
        
        if(isExist){
            selected = true;
            this.newSellingPrice = changeOrderLine.New_Selling_Price__c;
            this.changeOrderLineId = changeOrderLine.Id;
            this.deleteQuantity = changeOrderLine.Quantity__c;
            this.changeOrderLine = changeOrderLine;
            this.selectedItemNumber = changeOrderLine.COL_New_Item__c;
            this.lookupItemNumber = changeOrderLine.COL_New_Item__r.Name;
            this.replaceQuantity = changeOrderLine.COL_Quantity__c;
        }
        else {
            this.changeOrderLine = new TAMS_ROA_Lines__c();
            this.newSellingPrice = mline.Item_Selling_Price__c;
             this.deleteQuantity = mline.Quantity__c;
             this.replaceQuantity = mline.Quantity__c;
             //this.selectedItemNumber = mline.Ordered_Item__c;
        }
        orderLineMaster = mline;

    }
    //Constructor used for Replace Item(optional)
    //public ChangeOrderLinesWRP (Order_Line_Master__c mline, Boolean isExist,TAMS_ROA_Lines__c changeOrderLine){
    //    if(isExist){
    //    //this.newListPrice = newListPrice;
    //    this.newSellingPrice = changeOrderLine.New_Selling_Price__c;
    //    this.changeOrderLineId = changeOrderLine.Id;
    //    this.changeOrderLine = changeOrderLine;
    //    this.selected = true; 
    //    }else{
    //        this.newSellingPrice = mline.Item_Selling_Price__c;
    //        //this.newListPrice = newListPrice;
    //        this.changeOrderLine = new TAMS_ROA_Lines__c();
    //    }
    //    this.orderLineMaster = mline;
 
    //}

}