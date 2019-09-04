/*********************************************************
        Author: Lokesh Tigulla         
        Purpose: This Class is  Trigger Handler.        
        1.0 - Lokesh Tigulla - 08/13/2019 - Created
**********************************************************/
public with sharing class OpptyNewOPACTRL {
      public TAMS_Order_Process_Approval__c opa {get;set;}
      @TestVisible private ID opptyId;
      public Opportunity oppty {get;set;}
      public Account acc {get;set;}
    public OpptyNewOPACTRL(ApexPages.StandardController stdController){
       opptyId = stdController.getId();
       opa  = new TAMS_Order_Process_Approval__c();
       System.debug('opptyId'+opptyId);
       List<Opportunity> opp = [Select Name,PBOM__c,AccountId,Booking_Amount__c,OwnerId,ZBM__c From Opportunity Where Id =: opptyId];
        oppty = opp[0];
        Id accid = opp[0].AccountId;
        
       List<Account> lacc = [Select TAMS_Service_Territory_Name__c,Sales_CC__c,Zone_TAMS__c  From Account Where id =: accid ];
       acc = lacc[0];
    }
    
    public pagereference cancel(){
     PageReference retPage = new PageReference('/'+opptyId); 
        retPage.setRedirect(true);
        return retPage;
    }
    
    public pagereference save(){
        system.debug('inside Save');
        opa.Account__c = oppty.AccountId;
        opa.Opportunity__c = opptyId;
        opa.PBOM__c = oppty.PBOM__c;
        opa.Sale_Price__c = oppty.Booking_Amount__c;
        opa.Account_Executive_1__c = oppty.OwnerId;
        opa.Zone_Business_Mgr_1__c= oppty.ZBM__c;
        opa.Zone__c = acc.Zone_TAMS__c;
        opa.ZBM1_Zone__c = acc.Zone_TAMS__c;
        opa.AE1_Sales_CC__c= acc.Sales_CC__c;
        opa.ZBM1_Sales_CC__c = acc.Sales_CC__c;
        opa.AE1_Service_CC__c = acc.TAMS_Service_Territory_Name__c;
        opa.ZBM1_Service_CC__c = acc.TAMS_Service_Territory_Name__c;
        System.debug('opadata'+opa);
    
        insert opa;
         PageReference retPage = new PageReference('/'+opa.Id); 
            retPage.setRedirect(true);
            return retPage;
   }
    
    public PageReference saveNew(){
    
        System.debug('Entered Save&New');
        opa.Account__c = oppty.AccountId;
        opa.Opportunity__c = opptyId;
        opa.PBOM__c = oppty.PBOM__c;
        opa.Sale_Price__c = oppty.Booking_Amount__c;
        opa.Account_Executive_1__c = oppty.OwnerId;
        opa.Zone_Business_Mgr_1__c= oppty.ZBM__c;
        opa.Zone__c = acc.Zone_TAMS__c;
        opa.ZBM1_Zone__c = acc.Zone_TAMS__c;
        opa.AE1_Sales_CC__c= acc.Sales_CC__c;
        opa.ZBM1_Sales_CC__c = acc.Sales_CC__c;
        opa.AE1_Service_CC__c = acc.TAMS_Service_Territory_Name__c;
        opa.ZBM1_Service_CC__c = acc.TAMS_Service_Territory_Name__c;
        System.debug('opadata'+opa);
        insert opa;
        system.debug('opptyId'+opptyId);
        PageReference saveAndnewPage = Page.OpptyNewOPA;
        saveAndnewPage.setRedirect(true);
        saveAndnewPage.getParameters().put('id', opptyId );
        return saveAndnewPage;
      

} 
}