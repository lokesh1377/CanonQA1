/**
  * Controller Class object for TAMS ASM Contract Dashboard Visualforce page.
  * Used By: TAMS ASM Contract Dashboard
  * 
  * @author TAMS: Hemant Kumar
  * @date July 13, 2016
  * @update
  */
  
public class ASMContractsDashBoardController {

    public List<ServiceContract> SContract{get; set;}
    
    public ASMContractsDashBoardController() {
      System.debug('1. Inside constructor ASMContractsDashBoardController');   
      
      User loggedInUser = [Select id, contactId, AccountId, Contact.AccountId from User where id = :UserInfo.getUserId()];       
      System.debug('2. Logged In ASM User Id: '+loggedInUser.Id);   
      
      //List all the Active Contract SIDs for the logged in ASM
      List<ServiceContract> ASidList = new List<ServiceContract>();
      ASidList = [Select s.SID__c
                    From ServiceContract s
                   Where s.Contract_Status__c = 'Active'
                     and s.Days_to_Expire__c > 0
                       and s.OwnerId = :loggedInUser.Id                      
              ];
      
      System.debug('3. ASM Active SIDs :'+ASidList);
      
      //List all the Signed Contract SIDs for the logged in ASM
      List<ServiceContract> SSidList = new List<ServiceContract>();
      SSidList = [Select s.SID__c
                    From ServiceContract s
                   Where s.Contract_Status__c = 'Signed'
                     and s.Days_to_Expire__c  > 0
                     and s.OwnerId = :loggedInUser.Id                             
              ];

      System.debug('4. ASM Signed SIDs :'+SSidList);
      
      
      Set<String> ActiveSID = new Set<String>(); 
      Set<String> SignedSID = new Set<String>(); 
            
        // Loop thru the ASidList and populate the ActiveSID set. Put values into the set.
                            For(ServiceContract ASid : ASidList){
                                         ActiveSID.add(ASid.SID__c);
                            }
    
           System.debug('5. ASM Active SID SET :'+ActiveSID);
        
                            // Loop thru the SSSid list and populate the SignedSID set - put values into the set.
                            For(ServiceContract SSid : SSidList){
                                         SignedSID.add(SSid.SID__c);
                            }
               
              System.debug('5. ASM Active SID SET :'+SignedSID); 
                        
         // Compare the Active SID with those listed on the Signed SID list.  
         // Remove all Active SIDs from the set that are the same on SIGNED, so that the result is(are) unique Active values.
         
         if(ActiveSID.removeAll(SignedSID)){
            ActiveSID.removeAll(SignedSID);
           }
        
           System.debug('6. ASM The Active SIDs needed contains' + ActiveSID);      
      
      //Fetch all the Eligible Active SIDs for the logged in ASM
      
      SContract = [ Select s.Id, s.Days_to_Expire__c , s.Name , s.SID__c, s.Contract_Status__c, s.Nickname__c, s.EndDate, s.DashBoard_Field_Color__c, s.Account.Name,
                      s.Account.id, s.Equipment__c 
                      From ServiceContract s
                     Where s.SID__c        IN :ActiveSID 
                       and s.Contract_Status__c = 'Active'
                       and s.Days_to_Expire__c  > 0
                     Order by s.Days_to_Expire__c ASC
                     LIMIT 20 
                  ];    
                  
      System.debug('7. ASM Final List of SContract Record:'+SContract);       
    }

}