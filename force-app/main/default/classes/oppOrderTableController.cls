/*********************************************************
Author : Hemant Kumar       
Purpose: Email Component Class for Opportunity Booked Order Details  
1.0 - Hemant Kumar - 06/05/2018 - Created
**********************************************************/
public class oppOrderTableController{

  public Id thisOppId {get;set;}
  public Boolean thisEmailType {get;set;}

  public List<TAMS_Orders__c> OppOrder = new List<TAMS_Orders__c>();
  
  public List<TAMS_Orders__c> getOppOrder() {
    
    System.debug('The OPP ID :'+thisOppId );
    OppOrder = [SELECT ID, 
                       Oracle_Order_Number__c, 
                       SID_Order__c,
                       Order_Subtotal__c,
                       TAMS_Booked_Date__c,
                       Order_Type__c, 
                       Reference_SID_Order__c                       
                  FROM TAMS_Orders__c
                 WHERE TAMS_Opportunity__c = :thisOppId
                   AND Order_Status__c = 'Booked'
                ];
    System.debug('The OPP Order Details :'+OppOrder );     
    return OppOrder;
  }
}