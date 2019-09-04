/*****************************************
 * Class object for trigger.             *
 *                                       *
 * Used By: ServiceContractOwner_Trigger *
 *                                       *
 * @author: Wendy B. Copeland            *
 * @date:   August 25, 2016              *
 *                                       *
 * @update                               *
 *****************************************/
public class ServiceContractOwnerTriggerHandler {
    // Method for Contract Record Change
    public static void UpdateContractOwnerWithASM(List<ServiceContract> newServiceContracts, Map<Id, ServiceContract> oldServiceContracts){
        User u;
		// Create a List for Updated Contracts
        List<ServiceContract> lUpdatedContracts = new List<ServiceContract>();
		// Loop through the Contract Records being passed in	
        for(ServiceContract oContract : newServiceContracts){
            System.debug('Owner ID Before: '+oContract.Ownerid);
            // Run a Query to Retrieve the ASM from the SEG 
            try {   
            	u = [SELECT id 
                   	   FROM User 
                  	  WHERE Id IN (SELECT eq.ASM_lookup__c 
                                 	 FROM Install_Base_TAMS__c eq
                                	WHERE eq.id = : oContract.Equipment__c)
                  	  LIMIT 1];
		    // Catch any Exceptions
            } catch(Exception e) {
           	system.debug ('Bypassing due to sql error: ' + e.getMessage() );  
           	continue;      
        	}
        	System.debug('Equipment ID: '+oContract.Equipment__c);
        	System.debug('Owner ID After: '+u.id);
			// Check to see if the Id for the ASM retrieved from the Query is not blank 
			// and not equal to the one that was in the Record previously 
	   		if((String.isnotBlank(u.id))&&(oContract.Ownerid != u.id)){
               ServiceContract sctoUpdate = new ServiceContract(Id = oContract.Id, Ownerid = u.id);
               // Add the Contract Id and the Owner Id to the list of Fields to Update 
               lUpdatedContracts.add(sctoUpdate); 
           } else {
                // Bypass Record if the Id for the ASM retrieved from the Query was blank
                // or equal to the one that was in the Record previously 
                continue;        
             }
  
            }
 	try { 
           // If the List of Contracts to Update is not Empty, 
           // Update the Contracts in the List with the ASM Owner Id
           if(lUpdatedContracts.isEmpty() ==false) {
              update lUpdatedContracts;
           }
    // Catch any Exceptions
    } catch(Exception e) {
         system.debug ('error: ' + e.getMessage() );  
      }
   }
	// Method for Contract Record Add
    public static void UpdateContractOwnerWithASM(List<ServiceContract> newServiceContracts){
    	User u;
		// Create a List for Updated Contracts
        List<ServiceContract> lUpdatedContracts = new List<ServiceContract>();
		// Loop through the Contract Records being passed in
        for(ServiceContract oContract : newServiceContracts){
            System.debug('Owner ID Before: '+oContract.Ownerid);
            // Run a Query to Retrieve the ASM from the SEG 
            try {   
            	u = [SELECT id 
                   	   FROM User 
                  	  WHERE Id IN (SELECT eq.ASM_lookup__c 
                                 	 FROM Install_Base_TAMS__c eq
                                	WHERE eq.id = : oContract.Equipment__c)
                  	  LIMIT 1];
		    // Catch any Exceptions
            } catch(Exception e) {
           	system.debug ('Bypassing due to sql error: ' + e.getMessage() );  
           	continue;      
        	}
        	System.debug('Equipment ID: '+oContract.Equipment__c);
        	System.debug('Owner ID After: '+u.id);
			// Check to see if the Id for the ASM retrieved from the Query is not blank 
	   		if(String.isnotBlank(u.id)){
               ServiceContract sctoUpdate = new ServiceContract(Id = oContract.Id, Ownerid = u.id);
               // Add the Contract Id and the Owner Id to the list of Fields to Update
               lUpdatedContracts.add(sctoUpdate); 
           } else {
                // Bypass Record if the Id for the ASM retrieved from the Query was blank
                continue;        
             }
  
            }
 	try { 
        // If the List of Contracts to Update is not Empty, 
        // Update the Contracts in the List with the ASM Owner Id
        if(lUpdatedContracts.isEmpty() ==false) {
               update lUpdatedContracts;
           }
    // Catch any Exceptions
    } catch(Exception e) {
         system.debug ('error: ' + e.getMessage() );  
      }
   }
}