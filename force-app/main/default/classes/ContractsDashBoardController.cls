/**
  * Controller Class object for TAMS Contract Dashboard Visualforce page.
  * Used By: TAMS Contract Dashboard
  * 
  * @author TAMS: Hemant Kumar
  * @date November 18, 2015
  *
  * @update
  * @date Sep 8 2016, Updated for Affiliated Accounts
  * @date Sep 22 2016, Updated for Modality Filter 
  */
public class ContractsDashBoardController {

    public List<ServiceContract> SContract{get; set;}
    
    public ContractsDashBoardController() {
      System.debug('HK-Inside constructor ContractsDashBoardController');   
      User loggedInUser = [Select id, contactId, AccountId, Contact.AccountId, contact.Modality__c from User where id = :UserInfo.getUserId()]; 
      System.debug('HK-Looged In User Details          :: '+ loggedInUser );
              
      String loggedInUserAcctId = loggedInUser.AccountId;      
      System.debug('HK-Looged In loggedInUserAcctId  : '+loggedInUser.AccountId);   

      String loggedInUserModality = loggedInUser.contact.Modality__c;      
      System.debug('HK-Looged In contact.Modality__c: '+loggedInUser.contact.Modality__c);   
           
      List<Account> loggedInAcc = new List<Account>();                
      loggedInAcc = [Select Id, TAMS_Account_Number_TAMS__c from Account where Id = :loggedInUserAcctId ];
      System.debug('HK-Looged In User Account# : '+loggedInAcc);   
      
      Set<String> AllAccountNumber = new Set<String>();  
      for(Account AAccN :loggedInAcc){
            AllAccountNumber.add(AAccN.TAMS_Account_Number_TAMS__c);
         }         
      System.debug('AllAccountNumber Set : '+AllAccountNumber);
            
      List<TAMS_Affiliation__c> AffiliatedAcc = new List<TAMS_Affiliation__c>();
      AffiliatedAcc = [ Select Account__c
                          from TAMS_Affiliation__c
                         where Primary_Account_Number__c = :AllAccountNumber
                           and user__c  = :loggedInUser.id     
                      ];                      
      System.debug('Looged In User AffiliatedAcc IDs : '+AffiliatedAcc);   
              
      Set<String> AllAccountId = new Set<String>();  
      for(TAMS_Affiliation__c AAcc :AffiliatedAcc){
            AllAccountId.add(AAcc.Account__c);
         }         
      System.debug('AllAccountId Set-1 : '+AllAccountId );             
      
      AllAccountId.add(loggedInUser.AccountId);
      System.debug('AllAccountId Set-2 : '+AllAccountId ); 
      
      List<ServiceContract> AllSContract = new List<ServiceContract>();
      AllSContract = [ Select Id, Modality__c
                        From ServiceContract s
                       Where s.Contract_Status__c = 'Active'
                         and s.Days_to_Expire__c > 0
                         and s.AccountId IN :AllAccountId                       
                       Order by s.Days_to_Expire__c ASC                       
                     ];          
      System.debug('AllSContract With Modality : '+AllSContract); 
      
      Set<String> AllSContractId = new Set<String>();      
      for(ServiceContract AllSC :AllSContract){
         if(loggedInUserModality.contains(AllSC.Modality__c)==true){
            AllSContractId.add(AllSC.Id);
           }       
         }
      System.debug('AllSContract ID : '+AllSContractId);           
          
      SContract = [ Select s.Days_to_Expire__c , s.Name ,s.SID__c,  s.Nickname__c, s.EndDate, s.DashBoard_Field_Color__c 
                      From ServiceContract s
                     Where s.Contract_Status__c = 'Active'
                       and s.Days_to_Expire__c > 0
                       and s.Id IN :AllSContractId                       
                     Order by s.Days_to_Expire__c ASC
                     LIMIT 20 
                  ];    
      System.debug('SContract Record:'+SContract);       
    }

}