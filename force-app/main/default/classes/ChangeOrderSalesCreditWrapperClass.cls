/*********************************************************
        Author:         
        Purpose: This wrapper Class is used in Adminitrative Changes Items.        
        1.0 - Lokesh Tigulla              - Created
        1.1 - Lokesh Tigulla - 01/19/2019 - updated
**********************************************************/
public with sharing class ChangeOrderSalesCreditWrapperClass {
    public  TAMS_Order_Sales_Credit__c  sc {get;set;}
    //public String origCreditType {get;set;}
    public Boolean isRevenueCostCenter {get;set;}  
    public Change_Order_Administrative_Change__c rsc {get;set;}
    public ChangeOrderSalesCreditWrapperClass(TAMS_Order_Sales_Credit__c pSC) 
    {
        this.sc = pSC;
        this.rsc= new Change_Order_Administrative_Change__c();
        this.rsc.Salesrep_Name__c = pSc.Salesrep_Name__c;
        this.rsc.Credit_Type__c = pSc.Credit_Type__c;
        if(pSc.Credit_Type__c == 'Revenue Cost Center'){
            this.isRevenueCostCenter = true;
        }else{
            this.isRevenueCostCenter = false;
        }
        this.rsc.Old_Percentage__c = pSc.Percentage__c;
    }
}