trigger SetSprFieldsTrigger on SPR_Quote__c (after insert, after update,after delete, before update) {
    if((Trigger.isBefore && Trigger.isUpdate) || ( Trigger.isAfter && Trigger.isInsert)  ){
        if(SPRSharingUtil.setSPRQuoteOwnerExecuted == false){
            System.debug('Calling SPRSharingUtil.setSPRQuoteOwner');
            SPRSharingUtil.setSPRQuoteOwner(Trigger.newMap);
            SPRSharingUtil.setSPRQuoteOwnerExecuted = true;
        }
                
        if(SPRSharingUtil.setSPRSharingExecuted == false && Trigger.isAfter && Trigger.isInsert){
            System.debug('Calling SPRSharingUtil.setSPRSharing');
            SPRSharingUtil.setSPRSharing(Trigger.newMap);
            SPRSharingUtil.setSPRSharingExecuted = true;            
        }

    }

    if(Trigger.isBefore && Trigger.isUpdate){
        return;
    }

    List<ID> sprIds=new List<ID>();
    Decimal totalList;
    Decimal totalSelling;
    if(Trigger.isDelete)
    {
        for(SPR_Quote__c x: Trigger.Old)
        { 
            System.Debug('DEL x.id'+x.id);          
            System.Debug('DEL TAMS_SPR__c'+x.TAMS_SPR__c);           
            sprIds.add(x.TAMS_SPR__c);
        }
        
    }
    else
    {
        for(SPR_Quote__c x: Trigger.New)
        { 
            System.Debug('INS/UPD x.id'+x.id);          
            System.Debug('INS/UPD TAMS_SPR__c'+x.TAMS_SPR__c);           
            sprIds.add(x.TAMS_SPR__c); 
        }

    }

    List<TAMS_Special_Pricing_Request__c> triggerSprList = [SELECT ID,Multi_Modality__c,(select ID,Modality_SPRQ__c,List_Price_SPR__c,Selling_Price_SPR__c from SPR_Quotes__r) 
                                                            FROM TAMS_Special_Pricing_Request__c 
                                                            WHERE id IN :sprIds];
    System.Debug('triggerSprList size:'+triggerSprList.size());
    for(TAMS_Special_Pricing_Request__c spr:triggerSprList)
    {
        totalList=0;
        totalSelling=0;
        System.Debug('Multi_Modality__c:'+spr.Multi_Modality__c);
        spr.Multi_Modality__c = ''; 
        spr.Bundled_SPR__c ='No';
        Integer i = 0;
        for(SPR_Quote__c q: spr.SPR_Quotes__r)
        {
            System.Debug('Modality_SPRQ__c:'+q.Modality_SPRQ__c);
            if(spr.Multi_Modality__c != q.Modality_SPRQ__c) 
                spr.Multi_Modality__c = spr.Multi_Modality__c +';'+ q.Modality_SPRQ__c;
            System.Debug('new Multi_Modality__c:'+spr.Multi_Modality__c);            
            i++;
            totalList=q.List_Price_SPR__c+totalList;
            totalSelling=q.Selling_Price_SPR__c+totalSelling;
            if(i>1)
                spr.Bundled_SPR__c ='Yes';
        }
        System.Debug('totalList:'+totalList);
        System.Debug('totalSelling:'+totalSelling);
        if(totalList > 0 )
        {
            Decimal x= ((totalList-totalSelling)/totalList)*100;
            spr.Blended_Discount__c = x.setScale(0,RoundingMode.HALF_UP);
        }
        else
            spr.Blended_Discount__c = 0;  
        
    }
    System.Debug('After for loop');
    if (triggerSprList.size()>0)
        update triggerSprList;
}