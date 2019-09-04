/*********************************************************
        Author: NTT Centerstance
        Purpose: Opportunity Trigger
        1.0 - Nanda Tumurugoti - 07/24/2013 - Created
        1.1 - Brandon Cassis 03/17/2015 - Updated
        1.2 - Prabhjeet Singh 04/10/2017 - Updated and added OpportunityLineFromLeadProduct.cls 
        1.3 - Prabhjeet Singh 12/5/2017 - Updated to Set SPR Owner Based on the Opportunity
**********************************************************/

trigger Opportunity_Triggers on Opportunity (before insert, before update, after insert, after update) {
    System.debug('START:Opportunity_Triggers');
    if(Trigger.isAfter && Trigger.isUpdate){
        System.debug('Calling setSPROwnerBasedOnOpportunity For AFTER UPDATE');
        SPRSharingUtil.setSPROwnerBasedOnOpportunity(Trigger.newMap,Trigger.oldMap);
    }
    OpportunityTriggerHandler OppHandler = new OpportunityTriggerHandler();
    
    //Lists used to store specific records that need further automation.
    List<Opportunity> updateBookingOppyList = new List<Opportunity>();
    List<Opportunity> updateOwnerOppyList = new List<Opportunity>();
    
    //Divides the trigger execution by location in order of execution 
    if(trigger.isBefore) {
        
        if(trigger.isInsert) {
            
            for(Opportunity loopOppty :trigger.new) {
               
                if(Userinfo.getProfileId() != OpptyStaticVarsUtilClass.getAEProfile()) {           
                    updateOwnerOppyList.add(loopOppty);
                }
            }
            
            if(!updateOwnerOppyList.isEmpty()) {
                System.debug('Calling OpportunityTriggerHandler.changeOpptyOwner');
                OpportunityTriggerHandler.changeOpptyOwner(updateOwnerOppyList);
            }
        }
        //Added by Prabhjeet on 01/26/18
        if(Trigger.isBefore){
            if(OpportunityTriggerHandler.setZBMExecuted == false){
                System.debug('Calling setOppZBMUser For BEFORE');
                OpportunityTriggerHandler.setOppZBMUser(Trigger.new);
                OpportunityTriggerHandler.setZBMExecuted = true;
            }
        }            
    } else if(trigger.isAfter) {
        
        if(OpportunityTriggerFirstRunCheck.firstRun && (trigger.IsUpdate ||trigger.isInsert)) {
             OppHandler.After_InsertUpdate(Trigger.new, Trigger.oldMap,trigger.isInsert,trigger.isUpdate);
            OpportunityTriggerFirstRunCheck.firstRun = false;
        }
        
        //These seperate out the records that are new or have new Oppty Booking Amounts.
        if(trigger.IsInsert) {
            for(Opportunity loopOppty:trigger.new) {
                if(loopOppty.Booking_Amount__c != null) {
                    updateBookingOppyList.add(loopOppty);
                }
            }
            //By Prabhjeet Singh for 360 Lead Conversion
            OpportunityLineFromLeadProduct.createOpportunityLine(Trigger.New);
        } else if(trigger.isUpdate) {
            for(Opportunity loopOppty:trigger.new) {
                if(loopOppty.Booking_Amount__c != trigger.oldMap.get(loopOppty.Id).Booking_Amount__c) {
                    updateBookingOppyList.add(loopOppty);
                }
            }
        }
        
        //Sends the Oppty needing Booking Amount to the Helper Class.
        if(!updateBookingOppyList.isEmpty() && OpportunityTriggerFirstRunCheck.runOpptyOnce()) {
             OppHandler.updateOpptyBooking(updateBookingOppyList);
        }
    }
}