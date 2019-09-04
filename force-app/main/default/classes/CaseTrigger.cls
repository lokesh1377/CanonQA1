public with sharing class CaseTrigger {
    public String SCSBusinessHours = 'TAMS SCS Business Hours-Irvine, CA';
    public String defaultBusinessHours = 'TAMS Default Business Hours-Irvine, CA';
    
    private static DateTime todayNow;                            
    private static DateTime getNow() {
        return todayNow == null ? DateTime.now() : todayNow;
    }
    
    public static void setNow(DateTime dt) {
        todayNow =dt;
    }
    
    
    public void BusinessHoursCheck(List<Case> newCases){
        
        BusinessHours bh = [SELECT Id FROM BusinessHours WHERE Name=: SCSBusinessHours];
        DateTime dateToday = CaseTrigger.getNow();
        
        RecordType rtSolutionCenter = [select Id from RecordType where SObjectType = 'Case' and Name = 'Solution Center Support'];
        for (Case c : newCases){
            if (c.RecordTypeId == rtSolutionCenter.Id){
                System.Debug('Business hours in trigger?:' +BusinessHours.isWithin(bh.id, dateToday));
                c.IsCreatedInSCSBusinessHours__c = BusinessHours.isWithin(bh.id, dateToday);
            }
        }
        
    }
    
    public void checkPO(List<Case> newCases){
        
        String errorMsg = 'PO is required!';

        Map<Integer, Case> casesNotInBusinessHours = new Map<Integer, Case>();
        BusinessHours bh = [SELECT Id FROM BusinessHours WHERE Name=: defaultBusinessHours];
        List<Holiday>  holidays = [SELECT ActivityDate FROM Holiday];
        
        DateTime dateToday = CaseTrigger.getNow();
        
        
        RecordType rtEngineerDispatch = [select Id from RecordType where SObjectType = 'Case' and Name = 'Engineer Dispatch'];
        Integer count = 0;
        for (Case c : newCases){
        	System.Debug('test:' +c.When_would_you_like_to_schedule_service__c + c.RecordTypeId);
            if (c.When_would_you_like_to_schedule_service__c == 'Immediately' && c.RecordTypeId == rtEngineerDispatch.Id){
                if ((!BusinessHours.isWithin(bh.id, dateToday)) && String.isBlank(c.PO_Number__c)){
                    casesNotInBusinessHours.put(count, c); 
                    count++;
                }
            }
        }
        
        Map<String, Integer> equipmentToCase = new Map<String, Integer>();
        
        for (Integer c : casesNotInBusinessHours.keySet()){
            equipmentToCase.put(casesNotInBusinessHours.get(c).Install_Base__c, c);
        }
        
        List<ServiceContract> serviceContracts = [  select Id, Equipment__c 
                                                    from ServiceContract 
                                                    where Equipment__c =: equipmentToCase.keySet() and Contract_Status__c = 'Active'];
        
        Map<String, Integer> servContToCase = new Map<String, Integer>();
        
        for (ServiceContract sc : serviceContracts){
            servContToCase.put(sc.Id, equipmentToCase.get(sc.Equipment__c));
        }

        List<String> entitlementTypes = new List<String>{'EXTENDED HOURS','EXTENDED WKD HOURS','EXTENDED 24HD'};
        
        List<TAMS_Service_Contract_line_Items__c> serviceContractsLines = 
            [   select Id, Entitlement_Type__c, Entitlement__c, Entitlement__r.BusinessHoursId, ServiceContract__c
                    from TAMS_Service_Contract_line_Items__c 
                    where ServiceContract__c =: servContToCase.keySet()
                        and Entitlement_Type__c =: entitlementTypes];
        
        
        Map<String, TAMS_Service_Contract_line_Items__c> scLines = new Map<String, TAMS_Service_Contract_line_Items__c>();
        for (TAMS_Service_Contract_line_Items__c scLine : serviceContractsLines){
            Integer caseId = servContToCase.get(scLine.ServiceContract__c);
            scLines.put(caseId + scLine.Entitlement_Type__c, scLine);
        }
        
        System.Debug('scLines: ' + scLines);
        
        for (Integer c : casesNotInBusinessHours.keySet()){
            Boolean entitlementFound = false;
            Boolean errorFound = false;
            for (String et : entitlementTypes){
            	System.Debug('c + et' + (c+et));
                System.Debug('scLines.containsKey(c + et): ' + scLines.containsKey(c + et));
                if (scLines.containsKey(c + et) && !errorFound){
                	if (!BusinessHours.isWithin(scLines.get(c + et).Entitlement__r.BusinessHoursId, dateToday)){
                		casesNotInBusinessHours.get(c).addError(errorMsg);
                		errorFound = true;
                	} 
                    entitlementFound = true;
                }
            }
            
            if (!entitlementFound){
                casesNotInBusinessHours.get(c).addError(errorMsg);
            }
        }
        
    }

    public void EquipmentTrigger(List<Case> lcase){
        System.debug('Entered into Equipment Trigger');
        System.debug('Inserted Case record'+lcase);
    }

}