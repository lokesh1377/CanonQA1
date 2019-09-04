/*********************************************************
        Author:         
        Purpose: This Class is to grab Quote changes.        
        1.0 -                -            - Created
        1.1 - Brandon Cassis - 03/31/2015 - updated
**********************************************************/
trigger Tams_Quotes_Trigger on TAMS_Quotes__c (before insert, before update,after insert,after update) {
    
    if(Trigger.isBefore){
        List<TAMS_Quotes__c> primaryQuoteList = new List<TAMS_Quotes__c>();
        
        if(trigger.isInsert) {
            
            for(TAMS_Quotes__c loopTQ: trigger.new) {
                
                if(loopTQ.Primary__c) { 
                    primaryQuoteList.add(loopTQ);
                }
            }
        } else if(Trigger.isUpdate) {  
            
            for(TAMS_Quotes__c loopTQ: trigger.new) {
                
                if(loopTQ.Primary__c && !trigger.oldmap.get(loopTQ.Id).Primary__c) { 
                    primaryQuoteList.add(loopTQ);
                }
            }      
            
            list<TAMS_Quotes__c> QuotesToUpdate = new list<TAMS_Quotes__c>();
            
            for (TAMS_Quotes__c q: Trigger.new) {
                          
                if (q.Primary__c != Trigger.oldMap.get(q.id).Primary__c) {  
                    
                    try {        
                        
                        for (TAMS_Quotes__c qot: [select Id, Primary__c from TAMS_Quotes__c where Opportunity_Name__c = :q.Opportunity_Name__c and Primary__c = true and Id != :q.Id]){
                            qot.Primary__c = false;
                            qot.id = qot.id;
                            QuotesToUpdate.add(qot); 
                        }
                    }catch(Exception e) {
                        ErrorLog.storeException(e.getMessage());
                    }                
                    
                    if(QuotesToUpdate.size()>0){
                        
                        try{ 
                            update QuotesToUpdate;
                        }catch(Exception e) {
                            ErrorLog.storeException(e.getMessage()); 
                        }                      
                    }  
                } 
            }
        }
        
        //passes Primary Quote Flag objects with a changed Primary Flag to the helper method.    
        if(!primaryQuoteList.isEmpty()) {
            QuoteTriggerHandlerClass.updateOpportunityLineItem(primaryQuoteList); 
        }
    }
    if(Trigger.isAfter){
        System.debug('START:TamsQuoteFOBDownUpdateTRG');
        TamsQuoteFOBDownUpdateHelper.QuoteFOBDownUpdated(Trigger.newMap,Trigger.oldMap); 
    }
}