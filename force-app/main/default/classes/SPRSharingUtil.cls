public without sharing class SPRSharingUtil {
    public static boolean setSPRQuoteOwnerExecuted = false;
    public static boolean setSPROwnerBasedOnOpportunityExecuted = false;
    public static boolean setSPRSharingExecuted = false;

    public static void setSPROwnerBasedOnOpportunity(Map<ID,Opportunity> newOpportunities, Map<ID,Opportunity> oldOpportunities){
        System.debug('START:setSPROwnerBasedOnOpportunity');
        Map<Id,Id> oppIdOwnerIdMap = new Map<Id,Id>();
        for(Opportunity newOpp: newOpportunities.values()){
            if(newOpp.OwnerId != oldOpportunities.get(newOpp.Id).OwnerId ){
                oppIdOwnerIdMap.put(newOpp.Id, newOpp.OwnerId);
            }
        }
        System.debug('oppIdOwnerIdMap size:'+oppIdOwnerIdMap.size());
        if(oppIdOwnerIdMap.size() == 0){
            return;
        }

        List<SPR_Quote__c> sprQuotes = [SELECT  Id,
                                                TAMS_Quote_SPR__r.Opportunity_Name__c,
                                                TAMS_Quote_SPR__r.Opportunity_Name__r.OwnerId,
                                                Primary__c,
                                                TAMS_SPR__c
                                        FROM SPR_Quote__c
                                        WHERE TAMS_Quote_SPR__r.Opportunity_Name__c IN :oppIdOwnerIdMap.keySet()];
        List<TAMS_Special_Pricing_Request__c> SPRs = new List<TAMS_Special_Pricing_Request__c>();
        for(SPR_Quote__c sprQuote : sprQuotes){
            sprQuote.OwnerId = sprQuote.TAMS_Quote_SPR__r.Opportunity_Name__r.OwnerId;
            if(sprQuote.Primary__c == true){
                TAMS_Special_Pricing_Request__c spr = new TAMS_Special_Pricing_Request__c();
                spr.Id = sprQuote.TAMS_SPR__c;
                spr.OwnerId = sprQuote.TAMS_Quote_SPR__r.Opportunity_Name__r.OwnerId;
            }
        }                               
        System.debug('sprQuotes size:'+sprQuotes.size());
        System.debug('SPRs size:'+SPRs.size());
        if(sprQuotes.size() > 0){
            update sprQuotes;
        }

        if(SPRs.size() > 0){
            update SPRs;
        }
        System.debug('END:setSPROwnerBasedOnOpportunity');
    }

    public static void setSPRQuoteOwner(Map<ID,SPR_Quote__c> newSPRQuotes){
        System.debug('START:setSPRQuoteOwner');

        Map<Id,Id> sprQuoteIdTamsQuoteIdMap = new Map<Id,Id>();
        for(SPR_Quote__c sprQuote : newSPRQuotes.values()){
            sprQuoteIdTamsQuoteIdMap.put(sprQuote.Id,sprQuote.TAMS_Quote_SPR__c);
        }

        List<TAMS_Quotes__c> tamsQuotes = [SELECT Id,
                                                Opportunity_Name__r.OwnerId
                                            FROM TAMS_Quotes__c 
                                            WHERE Id IN :sprQuoteIdTamsQuoteIdMap.values()];
        Map<Id,Id> sprIdOwnerIdMap = new Map<Id,Id>();
        List<SPR_Quote__c> sprQuotesToUpdate = new List<SPR_Quote__c>();
        for(id sprQuoteId : sprQuoteIdTamsQuoteIdMap.keySet()){
            SPR_Quote__c sprQuote = newSPRQuotes.get(sprQuoteId);
            for(TAMS_Quotes__c tamsQuote : tamsQuotes){
                if(sprQuote.TAMS_Quote_SPR__c == tamsQuote.Id){
                    if(Trigger.isAfter && Trigger.isInsert){
                        SPR_Quote__c sprQuoteToUpdate = new SPR_Quote__c();
                        sprQuoteToUpdate.id = sprQuote.id;
                        sprQuoteToUpdate.OwnerId = tamsQuote.Opportunity_Name__r.OwnerId;
                        sprQuotesToUpdate.add(sprQuoteToUpdate);
                    }else{
                        sprQuote.OwnerId = tamsQuote.Opportunity_Name__r.OwnerId;
                    }

                    if(sprQuote.Primary__c == true){
                        sprIdOwnerIdMap.put(sprQuote.TAMS_SPR__c,tamsQuote.Opportunity_Name__r.OwnerId);
                    }                   
                }

            }

        }

        System.debug('sprIdOwnerIdMap size:'+sprIdOwnerIdMap.size());
        List<TAMS_Special_Pricing_Request__c> SPRs = [SELECT Id 
                                                      FROM TAMS_Special_Pricing_Request__c
                                                      WHERE Id IN :sprIdOwnerIdMap.keySet()];
        System.debug('SPRs size:'+SPRs.size());                                                   
        for(TAMS_Special_Pricing_Request__c spr : SPRs){
            spr.OwnerId = sprIdOwnerIdMap.get(spr.Id);
        }
        if(sprQuotesToUpdate.size() > 0 ){
            update sprQuotesToUpdate;
        }   
            
        if(SPRs.size() > 0){
            update SPRs;
        }           

        System.debug('END:setSPRQuoteOwner');
    }

// Lokesh Tigulla - updated - Updated Old Territory object to New Territory Object
    public static void setSPRSharing(Map<ID,SPR_Quote__c> newSPRQuotes){
        System.debug('START:setSPRSharing');
        //delete old all sharings??
        List<SPR_Quote__c> sprQuotes = [SELECT Id,
                                            OwnerId,
                                            TAMS_Quote_SPR__r.Opportunity_Name__r.Account.Territory_Name_TAMS__c,
                                            TAMS_SPR__c,
                                            TAMS_Quote_SPR__r.Modality__c,
                                            TAMS_SPR__r.OwnerId
                                        FROM
                                            SPR_Quote__c
                                        WHERE Id IN :newSPRQuotes.keySet()];
        
        Set<String> territoryNames = new Set<String>();
        for(SPR_Quote__c sprQuote : sprQuotes){
            String str = sprQuote.TAMS_Quote_SPR__r.Opportunity_Name__r.Account.Territory_Name_TAMS__c;

            if(str != null){
                str = str.substring(str.indexOf('US.'),str.length());
            }

            System.debug('str:'+str);           
            territoryNames.add(str);
        }

        System.debug('territoryNames:'+territoryNames);
        List<Territory2> territories = [SELECT 
                                            Id,
                                            Name
                                       FROM
                                            Territory2
                                       WHERE Name LIKE :territoryNames];    
        System.debug('territories:'+territories);                              
        Map<SPR_Quote__c,Id> sprQuoteTerritoryIdMap = new Map<SPR_Quote__c,Id>();
        for(SPR_Quote__c sprQuote : sprQuotes){
            String str = sprQuote.TAMS_Quote_SPR__r.Opportunity_Name__r.Account.Territory_Name_TAMS__c;
            if(str != null){
                str = str.substring(str.indexOf('US.'),str.length());
            }

            System.debug('str:'+str);           
            for(Territory2 terr: territories){
                if(terr.Name.contains(str)){
                    sprQuoteTerritoryIdMap.put(sprQuote, terr.Id);
                    break;
                }
            }
        }
        System.debug('sprQuoteTerritoryIdMap:'+sprQuoteTerritoryIdMap);
        System.debug('sprQuoteTerritoryIdMap size:'+sprQuoteTerritoryIdMap.size());
        //Give current user access as well
        String currentUserId = UserInfo.getUserId();    
        System.debug('currentUserId:'+currentUserId);



        List<UserTerritory2Association> userTerritories = [SELECT
                                                 userId,
                                                 Territory2Id
                                               FROM
                                                 UserTerritory2Association
                                               WHERE Territory2Id IN :sprQuoteTerritoryIdMap.values()
                                                 AND isActive = true];
        System.debug('userTerritories:'+userTerritories);
        Set<id> userIds = new Set<id>();
        for(UserTerritory2Association ut: userTerritories){
            userIds.add(ut.userId);
        }
        System.debug('userIds:'+userIds);
        Map<Id,User> users = new Map<Id,User>([SELECT 
                                                    Id,
                                                    Profile.Name 
                                                FROM User 
                                                WHERE Id IN :userIds
                                                AND Dealer__c = False
                                                AND isActive = true]);
        System.debug('users:'+users);
        List<SPR_Quote__Share>  sprQuoteShares = new List<SPR_Quote__Share>();                                         
        List<TAMS_Special_Pricing_Request__Share>   sprShares = new List<TAMS_Special_Pricing_Request__Share>();
        Boolean currentUserSPRShareDone = false;
        for(SPR_Quote__c sprQuote : sprQuoteTerritoryIdMap.keySet() ){
            System.debug('userTerritories'+userTerritories);
            for(UserTerritory2Association userTerr: userTerritories){
                if(userTerr.Territory2Id == sprQuoteTerritoryIdMap.get(sprQuote) 
                        && userTerr.userId != sprQuote.OwnerId
                        && users.containsKey(userTerr.userId)
                        && ( (users.get(userTerr.userId).Profile.Name == 'TAMS - UL ZBM' && sprQuote.TAMS_Quote_SPR__r.Modality__c == 'UL')
                            ||users.get(userTerr.userId).Profile.Name == 'TAMS - AE'
                            ||users.get(userTerr.userId).Profile.Name == 'TAMS - Hybrid'
                            )
                        ){
                    SPR_Quote__Share sprQuoteShare = new SPR_Quote__Share();
                    sprQuoteShare.parentId = sprQuote.Id;
                    sprQuoteShare.UserOrGroupId = userTerr.userId;
                    sprQuoteShare.AccessLevel = 'Edit';
                    sprQuoteShare.rowCause = 'Manual';
                    sprQuoteShares.add(sprQuoteShare);
                    if(sprQuote.TAMS_SPR__r.OwnerId != userTerr.userId ){
                        TAMS_Special_Pricing_Request__Share sprShare = new TAMS_Special_Pricing_Request__Share();
                        sprShare.parentId = sprQuote.TAMS_SPR__c;
                        sprShare.UserOrGroupId = userTerr.userId;
                        sprShare.AccessLevel = 'Edit';
                        sprShare.rowCause = 'Manual';
                        sprShares.add(sprShare);
                    }
                }
            }
            if(currentUserId != sprQuote.OwnerId){
                SPR_Quote__Share sprQuoteShare = new SPR_Quote__Share();
                sprQuoteShare.parentId = sprQuote.Id;
                sprQuoteShare.UserOrGroupId = currentUserId;
                sprQuoteShare.AccessLevel = 'Edit';
                sprQuoteShare.rowCause = 'Manual';
                sprQuoteShares.add(sprQuoteShare);
                if(currentUserSPRShareDone == false && sprQuote.TAMS_SPR__r.OwnerId != currentUserId){
                    TAMS_Special_Pricing_Request__Share sprShare = new TAMS_Special_Pricing_Request__Share();
                    sprShare.parentId = sprQuote.TAMS_SPR__c;
                    sprShare.UserOrGroupId = currentUserId;
                    sprShare.AccessLevel = 'Edit';
                    sprShare.rowCause = 'Manual';
                    sprShares.add(sprShare);            
                    currentUserSPRShareDone = true;
                }
            }
        }

        System.debug('sprQuoteShares:'+sprQuoteShares);
        System.debug('sprQuoteShares size:'+sprQuoteShares.size());
        List<Error_Log__c> errorLogs = new List<Error_Log__c>();
        if(sprQuoteShares.size() > 0){
            //insert sprQuoteShares;
            Database.SaveResult[] srList = Database.Insert(sprQuoteShares, false);
            // Iterate through each returned result
            for(Integer i = 0; i < sprQuoteShares.size() ; i++){
                Error_Log__c errorLog = new Error_Log__c();
                Database.SaveResult sr = srList[i];
                if (!sr.isSuccess()) {
                    // Operation failed, so get all errors         
                    String str ='The following error has occurred with corresponding SPR Quote Id:'+sprQuoteShares[i].parentId;
                    for(Database.Error err : sr.getErrors()) {
                        System.debug(err.getStatusCode() + ': ' + err.getMessage());
                        str = str + ' Error:'+err.getMessage();
                    }
                    if(str.length() >= 25000){
                        str = str.substring(0,25000);
                    }
                    errorLog.Description__c = str;
                    errorlog.class_name__c = 'SPRSharingUtil';
                    errorlog.argument1_Name__c = 'TAMS_Quote_SPR__c';
                    errorlog.argument1_value__c = sprQuoteShares[i].parentId;
                    errorlog.argument1_Name__c = 'User';
                    errorlog.argument1_value__c = sprQuoteShares[i].UserOrGroupId;  
                }else{
                    errorLog.Description__c = 'SUCCESS FOR SPR QUOTE';
                    errorlog.class_name__c = 'SPRSharingUtil';
                    errorlog.argument1_Name__c = 'TAMS_Quote_SPR__c';
                    errorlog.argument1_value__c = sprQuoteShares[i].parentId;
                    errorlog.argument1_Name__c = 'User';
                    errorlog.argument1_value__c = sprQuoteShares[i].UserOrGroupId;                      
                }
                errorLogs.add(errorlog);
            }           
        }

        System.debug('sprShares:'+sprShares);
        System.debug('sprShares size:'+sprShares.size());
        if(sprShares.size()>0){
            //insert sprShares;
            Database.SaveResult[] srList = Database.Insert(sprShares, false);
            // Iterate through each returned result
            for(Integer i = 0; i < sprShares.size() ; i++){
                Error_Log__c errorLog = new Error_Log__c();
                Database.SaveResult sr = srList[i];
                if (!sr.isSuccess()) {
                    // Operation failed, so get all errors         
                    String str ='The following error has occurred with corresponding SPR Id:'+sprShares[i].parentId;
                    for(Database.Error err : sr.getErrors()) {
                        System.debug(err.getStatusCode() + ': ' + err.getMessage());
                        str = str + ' Error:'+err.getMessage();
                    }
                    if(str.length() >= 25000){
                        str = str.substring(0,25000);
                    }
                    errorLog.Description__c = str;
                    errorlog.class_name__c = 'SPRSharingUtil';
                    errorlog.argument1_Name__c = 'TAMS_Special_Pricing_Request__c';
                    errorlog.argument1_value__c = sprShares[i].parentId;
                    errorlog.argument1_Name__c = 'User';
                    errorlog.argument1_value__c = sprShares[i].UserOrGroupId;   
                }else{
                    errorLog.Description__c = 'SUCCESS FOR SPR SHARE';
                    errorlog.class_name__c = 'SPRSharingUtil';
                    errorlog.argument1_Name__c = 'TAMS_Special_Pricing_Request__c';
                    errorlog.argument1_value__c = sprShares[i].parentId;
                    errorlog.argument1_Name__c = 'User';
                    errorlog.argument1_value__c = sprShares[i].UserOrGroupId;                       
                }
                errorLogs.add(errorlog);
            }           
        }

        ErrorLog.storeExceptions(errorLogs);
        System.debug('END:setSPRSharing');
    }



}