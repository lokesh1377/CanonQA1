/*********************************************************
        Author: TAMS
        Purpose: This Class is used to handle the Quote
                Trigger operations.        
        1.0 - Brandon Cassis - 03/31/2015 - Created
        1.1 - Hemant Kumar - 01/12/2016 - Updated for Product
        2.0 - Hemant Kumar - 10/27/2016 - Updated call of removeLineItemList
        3.0 - Hemant Kumar - 05/02/2017 - Updated for isActive in PriceBookEntry
        3.1 - Hemant Kumar - 05/10/2017 - Updated for Quote and LineItem PBOM matching HK on 5/10/2015
**********************************************************/
public class QuoteTriggerHandlerClass {
    
    //This method is used to update the Product on an Opportunity when a 
    //Quote with a different prodcuct is flagged primary
    public static void updateOpportunityLineItem(List<TAMS_Quotes__c> inputQuotesQuotesList ) {
        
        Set<Id> opptyIdSet = new Set<Id>();
        Map<Id, TAMS_Quotes__c> quoteMap = new Map<Id, TAMS_Quotes__c>();
        Map<Id, Id> quoteIdOpptyIdMap = new Map<Id, Id>();
        Map<Id, Opportunity> opptyMap;
        Map<Id, Opportunity> updateOppMap = new Map<Id, Opportunity>();
        List<PriceBook2> pbList = new List<PriceBook2>(); 
        List<OpportunityLineItem> upsertList = new List<OpportunityLineItem>();
        List<Product2> prodList = new List<Product2>();
        Set<String> prodNameSet = new Set<String>();
        Map<String, Product2> prodMap = new Map<String, Product2>();
        Map<String, PriceBook2> modPriceBookMap = new Map<String, PriceBook2>();
        Map<Id, PriceBookEntry> opptyPBEMap = new Map<Id, PriceBookEntry>();
        List<OpportunityLineItem> updateLineItemList = new List<OpportunityLineItem>();
        List<OpportunityLineItem> removeLineItemList = new List<OpportunityLineItem>();
        List<PriceBookEntry> PBEList = new List<PriceBookentry>();
        Set<Id> prodIdSet = new Set<Id>();
        Set<Id> pricebookIdSet = new Set<Id>();
        List<PriceBookEntry> PBEListInActive = new List<PriceBookentry>();        
        
        try {
            pbList = [select Id, Name from PriceBook2 where isActive = true AND IsStandard = false]; 
        } catch(Exception e) {
            ErrorLog.storeException(e.getMessage());
        }
        
       
        for(PriceBook2 loopPB: pbList) {
            modPriceBookMap.put(loopPB.Name.substring(0, loopPB.Name.indexof(' ')),loopPB); 
            pricebookIdSet.add(loopPB.Id);   
        }
        
        for(TAMS_Quotes__c loopTQ: inputQuotesQuotesList) {
            opptyIdSet.add(loopTQ.Opportunity_Name__c);
            quoteIdOpptyIdMap.put(loopTQ.Id,loopTQ.Opportunity_Name__c); 
            quoteMap.put(loopTQ.Id, loopTQ); 
        }
        
        try{
            opptyMap = new Map<Id, Opportunity>([SELECT Id, (SELECT Id, PricebookEntry.Product2.Name, PricebookEntry.Pricebook2Id FROM OpportunityLineItems) FROM Opportunity where Id IN :opptyIdSet]);
        } catch(Exception e) {
            ErrorLog.storeException(e.getMessage());
        }
        System.debug('HK Before For Loop opptyMap          :' +opptyMap);
        System.debug('HK Before For Loop quoteIdOpptyIdMap :' +quoteIdOpptyIdMap);
        
        for(Id loopTQId: quoteIdOpptyIdMap.keyset()) {
           System.debug('HK Inside For Loop quoteIdOpptyIdMap :'+loopTQId);
        
            if(opptyMap.containsKey(quoteIdOpptyIdMap.get(loopTQId))) {
              System.debug('HK Inside For Loop -- 1st if :');
            
                if(!opptyMap.get(quoteIdOpptyIdMap.get(loopTQId)).OpportunityLineItems.isEmpty()) {
                   System.debug('HK Inside For Loop -- 2nd if Opp Line Item is not empty:');
                    
                    for(OpportunityLineItem loopOLI: opptyMap.get(quoteIdOpptyIdMap.get(loopTQId)).OpportunityLineItems) {   
                      System.debug('HK Inside 2nd For Loop --:' +loopOLI);
                
                        if(quoteMap.get(loopTQId).PBOM__c != loopOLI.PricebookEntry.Product2.Name) {
                          System.debug('HK Inside 2nd For Loop -- 2nd if Quote PBOM <> PBE Product Name (Quote):'+quoteMap.get(loopTQId).PBOM__c);                        
                          System.debug('HK Inside 2nd For Loop -- 2nd if Quote PBOM <> PBE Product Name (PBE)  :'+loopOLI.PricebookEntry.Product2.Name);                              
                            updateOppMap.put(quoteIdOpptyIdMap.get(loopTQId), opptyMap.get(quoteIdOpptyIdMap.get(loopTQId)));
                            prodNameSet.add(quoteMap.get(loopTQId).PBOM__c);
                            System.debug('HK Inside 2nd For Loop -- Out of if .. calling removeLineItem :'+loopOLI); 
                            removeLineItemList.add(loopOLI);
                          }        
                          //Commented by HK on 10/27/2016 and moved inside above if                  
                          //removeLineItemList.add(loopOLI);
                          //Added below code to take care the old opportunity to clean up the mismatch pbom by HK on 5/10/2015
                         else {
                           System.debug('HK Inside 2nd For Loop -- 2nd if -- Else -- Quote PBOM = PBE Product Name:');    
                           updateOppMap.put(quoteIdOpptyIdMap.get(loopTQId), opptyMap.get(quoteIdOpptyIdMap.get(loopTQId)));
                           prodNameSet.add(quoteMap.get(loopTQId).PBOM__c);  
                           removeLineItemList.add(loopOLI);                                             
                         }                    
                     }
                }                     
                else {
                    System.debug('HK Inside Else of 2nd if .. calling updateOppMap:'); 
                    updateOppMap.put(quoteIdOpptyIdMap.get(loopTQId), opptyMap.get(quoteIdOpptyIdMap.get(loopTQId)));
                    prodNameSet.add(quoteMap.get(loopTQId).PBOM__c);
                } 
            }
        }
        
        System.debug('HK Before Product Name Set 1st Query:');
        if(!prodNameSet.isEmpty()) {
            try {
                prodList = [select Id, Name, isActive from Product2 where Name IN :prodNameSet AND isActive = true];
                System.debug('HK Inside 1st Query Product Name Set prodList :'+prodList );
            } catch(Exception e) {
                ErrorLog.storeException(e.getMessage());
                System.debug('HK Inside 1st Query Exception :'+e.getMessage());
            }
                System.debug('HK After Product Name Set 1st Query:');             
                System.debug('HK Before Product Name Set 2nd Query:');            
            if(prodList.isEmpty())
             try{
                 prodList = [select Id, Name, isActive from Product2 where Name IN :prodNameSet AND isActive = false];
                System.debug('HK Inside 2nd Query Product Name Set prodList :'+prodList );                         
                }catch(Exception e) {
                 ErrorLog.storeException(e.getMessage());
                 System.debug('HK Inside 2nd Query Exception :'+e.getMessage());
                }            
            System.debug('HK After Product Name Set 2nd Query:'); 
            for(Product2 loopP2: prodList) {
                prodMap.put(loopP2.Name, loopP2);
                prodIdSet.add(loopP2.Id); 
            }
            
            try {
                PBEList = [select Id, Product2Id, PriceBook2Id from PriceBookEntry where Product2Id IN : prodIdSet AND PriceBook2Id IN :pricebookIdSet];
                System.debug('HK After Product Name Set 2nd Query PBEList:'+PBEList);
            } catch(Exception e) {
            
            }
            
            //Utilize or create needed PriceBookEntry
            for(Id loopTQId: quoteIdOpptyIdMap.keyset()) {
                if(updateOppMap.containsKey(quoteIdOpptyIdMap.get(loopTQId))) {
                   System.debug('HK Inside 1st IF of For Utilize or create needed PriceBookEntry:'); 
                    Boolean isPBEntry = false;
                    for(PriceBookEntry loopPBE: PBEList) {
                        if(loopPBE.PriceBook2Id == modPriceBookMap.get(quoteMap.get(loopTQId).Modality__c).Id && loopPBE.Product2Id == prodMap.get(quoteMap.get(loopTQId).PBOM__c).Id)  {
                            loopPBE.isActive = true;
                            opptyPBEMap.put(quoteIdOpptyIdMap.get(loopTQId), loopPBE);
                            isPBEntry = true;                   
                            System.debug('HK Inside 1st IF -For Loop of Existing PriceBookEntry:'); 
                          }
                        }
                        System.debug('HK After 1st IF of For create needed PriceBookEntry: isPBEntry ' +isPBEntry); 
                        if(!isPBEntry) {
                        System.debug('HK Inside 2nd IF of For create needed PriceBookEntry:'); 
                        PriceBookEntry insertPBE = new PriceBookEntry();
                        insertPBE.PriceBook2Id = modPriceBookMap.get(quoteMap.get(loopTQId).Modality__c).Id;  
                        insertPBE.Product2Id = prodMap.get(quoteMap.get(loopTQId).PBOM__c).Id; 
                        insertPBE.unitPrice = quoteMap.get(loopTQId).Amount__c; 
                        insertPBE.isActive = true;
                        opptyPBEMap.put(quoteIdOpptyIdMap.get(loopTQId), insertPBE);
                    }
                }
            }
        }
        if(!opptyPBEMap.values().isEmpty()) {
            try {
                System.debug('HK Inside upsert opptyPBEMap : '+opptyPBEMap);
                upsert opptyPBEMap.values();
            } catch(Exception e) {
                ErrorLog.storeException(e.getMessage());
            }
        }
        
        if(!removeLineItemList.isEmpty()) {
            try {
                 System.debug('HK Inside removeLineItemList: '+removeLineItemList);  
                delete removeLineItemList;
            } catch(Exception e) {
                ErrorLog.storeException(e.getMessage());
            }
        }
        //update or create Line Items
        for(Id loopTQId: quoteIdOpptyIdMap.keyset()) {
           
            if(updateOppMap.containsKey(quoteIdOpptyIdMap.get(loopTQId))) {
                System.debug('HK Inside update or create Line Items tempOLI : '+loopTQId);
                OpportunityLineItem tempOLI = new OpportunityLineItem();
                tempOLI.OpportunityId = quoteIdOpptyIdMap.get(loopTQId);
                system.debug(logginglevel.WARN, 'PriceBookEntry ' + opptyPBEMap.get(quoteIdOpptyIdMap.get(loopTQId)).Id);
                tempOLI.PriceBookEntryId = opptyPBEMap.get(quoteIdOpptyIdMap.get(loopTQId)).Id;
                tempOLI.Quantity = 1;
                tempOLI.UnitPrice = quoteMap.get(loopTQId).Amount__c;
                updateLineItemList.add(tempOLI);                 
            }
        }
        
        if(!updateLineItemList.isEmpty()) {
            try {
                System.debug('HK Inside updateLineItemList: '+updateLineItemList);
                insert updateLineItemList;  
                } catch(Exception e) {
                ErrorLog.storeException(e.getMessage());
            }
        }


        //update PriceBookEntry to InActive
         if(!opptyPBEMap.values().isEmpty()) {
             System.debug('HK Inside IF PriceBookEntry InActive - Check of opptyPBEMap Is Empty or Not' + opptyPBEMap.values().isEmpty()); 
             
                for(Id loopTQId: quoteIdOpptyIdMap.keyset()) {           
                    System.debug('HK Inside For Update PriceBookEntry InActive'); 
                           
                    if(prodMap.get(quoteMap.get(loopTQId).PBOM__c).isActive == false) {
                      System.debug('HK Inside IF Update PriceBookEntry InActive');
                      PriceBookEntry inactivePBE = new PriceBookEntry();                  
                      inactivePBE.Id       = opptyPBEMap.get(quoteIdOpptyIdMap.get(loopTQId)).Id;
                      inactivePBE.IsActive = false; //prodMap.get(quoteMap.get(loopTQId).PBOM__c).isActive;
                      PBEListInActive.add(inactivePBE);                 
                    }
                }
         }   
        
        if(!PBEListInActive.isEmpty()) {
            try {
                System.debug('HK Inside PBEListInActive Method: '+PBEListInActive);
                update PBEListInActive;
                } catch(Exception e) {
                ErrorLog.storeException(e.getMessage());
            }
        }
        
        
    }
}