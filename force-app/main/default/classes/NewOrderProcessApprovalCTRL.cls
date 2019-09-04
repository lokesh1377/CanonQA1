public class NewOrderProcessApprovalCTRL {
@AuraEnabled
    public static String getOpportunityRecord(ID opportunityId){
        try{
            Opportunity oppty = [SELECT Id,Name,AccountId,OwnerId,ZBM__c,TAMS_Zone__c,Original_Booking_SID_lookup__c,PBOM__c,Booking_Amount__c FROM Opportunity WHERE ID =:opportunityId];
            String str = JSON.serialize(oppty);
            return str;
        }catch(Exception e){
             return 'Error:'+e.getMessage();
        }
    }
}