/*********************************************************
Author : Hemant Kumar       
Purpose: Class for SPR Quotes Email Component 
1.0 - Hemant Kumar - 08/02/2017 - Created
**********************************************************/
public class sprQuotesTableController{

  public Id thisSprId {get;set;}
  public Boolean thisEmailType {get;set;}

  public List<SPR_Quote__c> sprQuotes = new List<SPR_Quote__c>();
  
  public List<SPR_Quote__c> getSprQuotes() {
    
    System.debug('The SPR ID :'+thisSprId );
    sprQuotes = [SELECT Oracle_Quote__c, Approved_Discount__c,
                        APPROVED_Selling_Price__c, SPR_Comments__c,
                        Modality_SPRQ__c, Primary__c
                  FROM SPR_Quote__c
                 WHERE TAMS_SPR__c = :thisSprId        
                ];
    System.debug('The SPR Quotes Details :'+sprQuotes );     
    return sprQuotes;
  }
}