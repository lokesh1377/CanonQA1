/**
  * Class object for trigger.
  * Used By: ServiceContract_Trigger
  * 
  * @author NTT Data: Louis Wooldridge
  * @date August 12, 2015  
  * @date Jun 07, 2017 Updated by Hemant Kumar to Included All status of Contracts
  * @date August 06, 2018 checked the condition for exisitng Contract with IB   
  *
  */
public class ServiceContractTriggerHandler {
    //Update 
    public static void UpdateEquipmentWithActiveContract(List<ServiceContract> newServiceContracts, Map<Id, ServiceContract> oldServiceContracts){
        List<ServiceContract> lUpdatedContracts = new List<ServiceContract>();
        
        system.debug ('HK - Inside Update Method:');
        for(ServiceContract oContract : newServiceContracts){
            if(oContract.Contract_Status__c != oldServiceContracts.get(oContract.Id).Contract_Status__c){
                system.debug ('HK - Inside Update Method: If : Contract to be Updated based on Status as Status Changed - Old Status:' + oldServiceContracts.get(oContract.Id).Contract_Status__c );            
                system.debug ('HK - Inside Update Method: If : Contract to be Updated based on Status as Status Changed - New Status:' + oContract.Contract_Status__c  );
                lUpdatedContracts.add(oContract);
            }
            else if(oContract.Contract_Status__c == oldServiceContracts.get(oContract.Id).Contract_Status__c && oContract.Contract_Status__c == 'Active') {
                system.debug ('HK - Inside Update Method: Else If : Active Contract to be Updated sice something is changed :' + oContract);
                lUpdatedContracts.add(oContract);

            
            }   
        }
        
        if(lUpdatedContracts.isEmpty() == false){
            UpdateEquipmentWithActiveContract(lUpdatedContracts);
        }
    }
    
    //Insert 
    public static void UpdateEquipmentWithActiveContract(List<ServiceContract> newServiceContracts){
        List<Install_Base_TAMS__c> lUpdateEquipment = new List<Install_Base_TAMS__c>();
        
        for(ServiceContract oContract : newServiceContracts){
            system.debug ('HK - Inside Insert Method:');
            for(Install_Base_TAMS__c oEquipment : [Select Id, Service_Contract__c From Install_Base_TAMS__c 
                                                    Where Id = :oContract.Equipment__c]){
                                                            
                system.debug ('HK - Inside Insert Method: Equipment Details :' +oEquipment);                                                                     
                if(oContract.Contract_Status__c == 'Active') {                                             
                   oEquipment.Service_Contract__c = oContract.Id;
                   lUpdateEquipment.add(oEquipment);
                   system.debug ('HK - Inside Insert Method: Active Contract Update' +oContract.Id );
                  }                  
                else if (oContract.Contract_Status__c == 'Expired' || oContract.Contract_Status__c == 'Inactive')
                  {
                   system.debug ('HK - Inside Insert Method: Expired / Inactive Contract Found' +oContract.Contract_Status__c);
                   
                    if (oEquipment.Service_Contract__c == oContract.Id) {
                        oEquipment.Service_Contract__c = null; 
                        lUpdateEquipment.add(oEquipment);                       
                        system.debug ('HK - Inside Insert Method: Expired / Inactive Contract Update as its exists with IB Id:' +oEquipment.Id);
                    }    
                  }                     
            }          
          }
        
        if(lUpdateEquipment.isEmpty() == false){
            update lUpdateEquipment;
        }
    }
}