trigger TamSPRQuoteFOBDownUpdateTRG on SPR_Quote__c (before insert, before update) {
    System.debug('START:TamSPRQuoteFOBDownUpdateTRG');
    TamsQuoteFOBDownUpdateHelper.SPRQuoteUpdated(Trigger.new,Trigger.old);
}