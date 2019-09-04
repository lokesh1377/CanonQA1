/*********************************************************
        Author: NTT Centerstance
        Purpose: This Class Updates Opp Name, Amount, 
        Pricebook, Owner. 
        Also Creates Comp Install Base if Opp is Lost
        1.0 - Nanda Tumurugoti - 07/24/2013 - Created
        1.1 - Brandon Cassis - 03/11/2015 - Updated
        1.2 - Hemant Kumar - 09/15/2015 - Updated
        1.3 - Prabhjeet Singh - 01/24/2018 - Updated to Set Opp ZBM etc based on the Owner's User Record
        1.4 - Hemant Kumar - 05/08/2018 - Updated for Override Opp ZBM based on the Account 
        1.5 - Lokesh Tigulla - 05/02/2019 -Updated Old Territory object to New Territory Object
**********************************************************/

public class OpportunityTriggerHandler {
    public static boolean setZBMExecuted = false;

    list<Opportunity> OppToUpdate = new list<Opportunity>();
    map<string,Id> PBMap = new map<string,Id>();
    list<Id> oppId = new list<Id>();
    map<string,double> qtyMap = new map<string,double>();
    map<string,string> prodMap = new map<string,string>();
    //list<Install_Base_TAMS__c> ibToInsert = new list<Install_Base_TAMS__c>(); //HK 09/15/2015
    //Id RecTypeCIB = [Select Id From RecordType Where SobjectType = 'Install_Base_TAMS__c' And IsActive = true And Name = 'Competitor Install Base' LIMIT 1].Id; //HK 09/15/2015
    list<TAMS_Competitor_IB__c> ibToInsert = new list<TAMS_Competitor_IB__c>();
       
    public void After_InsertUpdate(List<Opportunity> newValues, Map<Id,Opportunity> oldMap,boolean isInsert,boolean IsUpdate){
        
        //Id RecTypeCIB = getRecordTypeId('Install_Base_TAMS__c','Competitor Install Base'); //HK 09/15/2015
        // Get all Opp IDs to Get Products
        for(Opportunity o : newValues)
            oppId.add(o.Id);
        
        //Get all Pricebooks
        try {
            for(Pricebook2 pb : [select Id, Modality__c from Pricebook2]) {
                PBMap.put(pb.Modality__c,pb.Id);
            }
        } catch(Exception e) {
            ErrorLog.storeException(e.getMessage());
        }      
          
        //Get Quantity and Product Information to create Install Base
        try {
            for(OpportunityLineItem LI : [Select o.Quantity, o.PricebookEntry.Product2.Name, o.OpportunityId, o.Id From OpportunityLineItem o where o.OpportunityId in : oppId]){
                qtyMap.put(LI.OpportunityId, LI.Quantity);
                prodMap.put(LI.OpportunityId, LI.PricebookEntry.Product2.Name);
            }
        } catch(Exception e) {
            ErrorLog.storeException(e.getMessage());
        }
        
        // Process the trigger Values
        try {
            for(Opportunity opp: [select AccountId,Id,StageName,Modality_TAMS__c,Owner.FirstName,Owner.LastName, Account.Name,Account.ShippingStreet,Account.ShippingCity, Account.ShippingState, Account.ShippingPostalCode, Account.ShippingCountry, Segment_TAMS__c,Shipping_Address_TAMS__c,Additional_Comments_TAMS__c,LastModifiedDate,Competitor_Lost_to_TAMS__c from Opportunity where Id IN : newValues]){
                if(IsInsert){
                    opp.Name =  returnOppName(Opp);
                    //Assign Pricebook Based on Modality
                    if(PBMap.get(opp.Modality_TAMS__c)!=null)
                        opp.Pricebook2Id = PBMap.get(opp.Modality_TAMS__c);
                    OppToUpdate.add(opp);
                    // Create a Competitor Install Base if Opp is Lost
                    if(opp.StageName == 'Closed/Lost'){
                        ibToInsert.add(returnIB_Comp(Opp));
                    }
                        
                }
                
                if(IsUpdate){
                    if(opp.Modality_TAMS__c != oldMap.get(opp.id).Modality_TAMS__c || opp.OwnerId != oldMap.get(opp.id).OwnerId){
                        opp.Name =  returnOppName(Opp);
                        //Assign Pricebook Based on Modality
                        if(PBMap.get(opp.Modality_TAMS__c)!=null)
                            opp.Pricebook2Id = PBMap.get(opp.Modality_TAMS__c);
                        OppToUpdate.add(opp);
                    }
                    // Create a Competitor Install Base if Opp is Lost
                    if(opp.StageName == 'Closed/Lost' && opp.StageName != oldMap.get(opp.id).StageName) {
                        ibToInsert.add(returnIB_Comp(Opp));
                    }   
                }
            }
        } catch(Exception e) {
            ErrorLog.storeException(e.getMessage());
        }
        
        if(OppToUpdate.size()>0){ 
            try {
                update OppToUpdate;
            } catch(Exception e) {
                ErrorLog.storeException(e.getMessage());
            }
        }
            
        if(ibToInsert.size()>0){
            try {
                insert ibToInsert;
            } catch(Exception e) {
                ErrorLog.storeException(e.getMessage());
            }
        }   
    }

    private string returnOppName(Opportunity Opp){
        
        //Following Expression Returns Account Name by Removing Vowels. It will not remove Vowel if it is a start of word 
        string temp='';
        if(opp.Account.Name != null)
            temp = opp.Account.Name.replaceAll('(?i)(?<!\\b)[aeiou]', '');
        return((opp.Owner.FirstName.left(1) + opp.Owner.LastName.left(1) + '-'+ opp.Modality_TAMS__c + '-' + temp).toUpperCase());
        
    }
    
    private TAMS_Competitor_IB__c returnIB_Comp(Opportunity Opp){
        //Creates Install Base
        TAMS_Competitor_IB__c IB = new TAMS_Competitor_IB__c();
        //IB.RecordTypeId = RecTypeCIB; //HK 09/15/2015
        IB.Account_Name__c = Opp.AccountId;
        IB.Modality_ALL__c = Opp.Modality_TAMS__c;
        IB.Department_Comp__c = Opp.Segment_TAMS__c;
        //IB.Product_ALL__c = prodMap.get(Opp.id);
        IB.Quantity_Comp__c = qtyMap.get(Opp.id);
        //IB.Install_Location_ALL__c = Opp.Shipping_Address_TAMS__c;
        IB.Current_Location_Street_1_TAMS__c = Opp.Account.ShippingStreet;
        IB.Current_Location_City_TAMS__c = Opp.Account.ShippingCity;
        IB.Current_Location_State_TAMS__c = Opp.Account.ShippingState;
        IB.Current_Location_Zip_TAMS__c = Opp.Account.ShippingPostalCode;      
        IB.Current_Location_Country_TAMS__c = Opp.Account.ShippingCountry; 
        IB.Install_Comments_Comp__c = Opp.Additional_Comments_TAMS__c;
        IB.Manufacturer_ALL__c = Opp.Competitor_Lost_to_TAMS__c + ' - ' + Opp.Modality_TAMS__c;
        IB.Install_Year_Comp__c = string.Valueof(Opp.LastModifiedDate.year());
        //IB.Type__c = 'Competitor Install Base'; //HK 09/15/2015
             
        return IB;
    } 
    
    
    
    /****************************Opportunity Booking*********************************************/
    
    //This Method is used to change the total of the Oppty Amount based on the Booking Amount my modifying
    // the the unit price on the Opportunity Line Item.
    public void updateOpptyBooking(List<Opportunity> inputList) {
    
        List<OpportunityLineItem> updateList = new List<OpportunityLineItem>(); 
        Map<Id, Opportunity> OpptyMap = new Map<Id, Opportunity>();
        
        
        for(Opportunity loopOppty: inputList) {           
            OpptyMap.put(loopOppty.Id, loopOppty);
        }
    
        try{
            updateList = [select Id, unitprice, OpportunityId From OpportunityLineItem Where OpportunityId In :OpptyMap.KeySet()];
        } catch(Exception e) {
            ErrorLog.storeException(e.getMessage());
        }
        
        for(OpportunityLineItem loopOLI: updateList) {
            if(OpptyMap.get(loopOLI.opportunityId).Booking_Amount__c != null) {
                loopOLI.unitPrice = OpptyMap.get(loopOLI.opportunityId).Booking_Amount__c;
            } else{
                loopOLI.unitPrice = 0;
            }
        }
        
        if(!updateList.isEmpty()) {
            try {
                update updateList;
            } catch(Exception e) {
                ErrorLog.storeException(e.getMessage());
            }
        }
    }
    
    /****************************Opportunity Ownership*********************************************/
    //Updated Code by NTT Data - Louis Wooldridge
    //Updated Code by Lokesh Tigulla - changed Old Territory object to New Territory Object
    public static void changeOpptyOwner(List<Opportunity> inputList) {
        System.debug('START:changeOpptyOwner');
        System.debug('inputList:'+inputList);
        //Retrieving Ids for the Accounts related to the Opportunities 
        Set<Id> accountIdSet = OpptyUtilClass.getAccountSet(inputList);
        System.debug('accountIdSet:'+accountIdSet);
        //Retrieving Territory Names for the related Accounts
        Map<Id,String> mAccountTerritories = new Map<Id,String>();
        for(Account oAccount : [Select Id, TAMS_Territory_Id__c From Account Where Id In:accountIdSet]){
            mAccountTerritories.put(oAccount.Id, oAccount.TAMS_Territory_Id__c);
        }
        //Retrieving Territory Ids
        System.debug('mAccountTerritories:'+mAccountTerritories);
        Map<String,Id> mLookupTerritoryIds = new Map<String,Id>();
        for(Territory2 oTerritory : [Select Id, Name From Territory2 Where Name In:mAccountTerritories.values()]){
            mLookupTerritoryIds.put(oTerritory.Name, oTerritory.Id);
        }
        //Retrieving list of Users in the Territories
        System.debug('mLookupTerritoryIds:'+mLookupTerritoryIds);
        List<UserTerritory2Association> lUserTerritory = [Select UserId, Territory2Id, Id From UserTerritory2Association Where IsActive = true And Territory2Id In:mLookupTerritoryIds.values()];
        System.debug('lUserTerritory:'+lUserTerritory);        
        Set<Id> sUserIds = OpptyUtilClass.getUserSet(lUserTerritory);
        System.debug('sUserIds:'+sUserIds);
        //Filtering down Territory Users to Active AE users
        Map<Id,User> mLookupAEUsers = new Map<Id,User>();
        For(User oUser : [Select Id, Title, ProfileId From User Where IsActive = True And Id In:sUserIds And ProfileId = :OpptyStaticVarsUtilClass.AEProfileId]){
            mLookupAEUsers.put(oUser.Id, oUser);
        }
        System.debug('mLookupAEUsers:'+mLookupAEUsers);
        Map<Id,Id> mAEOppOwnerIds = new Map<Id,Id>();
        Map<Id,Id> mKeyAEOppOwnerIds = new Map<Id,Id>();
        Map<Id,Id> mSrAEOppOwnerIds = new Map<Id,Id>();
        
        //Capturing AE Users grouping by Title
        for(Opportunity oOpportunity :inputList){
            String sTerritory = mAccountTerritories.get(oOpportunity.AccountId);
            if(sTerritory != null){
                Id idTerritory = mLookupTerritoryIds.get(sTerritory);
                
                for(UserTerritory2Association oUT : lUserTerritory){
                    if(oUT.Territory2Id == idTerritory){
                        User oAEUser = mLookupAEUsers.get(oUT.UserId);
                        if(oAEUser != null){
                            if(oAEUser.Title == System.label.AETitle){
                                mAEOppOwnerIds.put(oOpportunity.Id, oAEUser.Id);
                            }else if(oAEUser.Title == System.label.SRAETitle){
                                mSrAEOppOwnerIds.put(oOpportunity.Id, oAEUser.Id);
                            }else if(oAEUser.Title == System.label.KeyAETitle){
                                mKeyAEOppOwnerIds.put(oOpportunity.Id, oAEUser.Id);
                            }
                        }
                    }
                }
            }
        }
        
        //Updating Opportunity Owner, applying AE, then Key, Sr if they exist
        for(Opportunity oOpportunity :inputList){
            if(mAEOppOwnerIds.containsKey(oOpportunity.Id) == true){
                oOpportunity.OwnerId = mAEOppOwnerIds.get(oOpportunity.Id);
            }
            if(mKeyAEOppOwnerIds.containsKey(oOpportunity.Id) == true){
                oOpportunity.OwnerId = mKeyAEOppOwnerIds.get(oOpportunity.Id);
            }
            if(mSrAEOppOwnerIds.containsKey(oOpportunity.Id) == true){
                oOpportunity.OwnerId = mSrAEOppOwnerIds.get(oOpportunity.Id);
            }
        }
        System.debug('END:inputList:'+inputList);
        
    }
    
    //1.3 Prabhjeet Singh - 01/24/2018 - Updated to Set Opp ZBM etc based on the Owner's User Record

    public static void setOppZBMUser(List<Opportunity> newOpps){
        System.debug('START:setOppZBMUser');
        
        //Get the Account and Override ZBM .. if any
        Set<Id> accIds = new Set<Id>();
        for(Opportunity opp : newOpps){
            accIds.add(opp.AccountId);
        }        
        System.debug('AccountIds:'+accIds);        
        Map<Id,Account> accOwners = new Map<Id,Account>([
                                                Select 
                                                    Id,
                                                    CT_ZBM_Acc__c,
                                                    MR_ZBM_Acc__c,
                                                    UL_ZBM_Acc__c,
                                                    XR_VL_ZBM_Acc__c
                                                From account 
                                                WHERE id IN :accIds
                                                 ]); 
        System.debug('accOwners:'+accOwners);
        
        
        //Get all Owner User details
        Set<Id> userIds = new Set<Id>();
        for(Opportunity opp : newOpps){
            userIds.add(opp.OwnerId);
        }
        System.debug('userIds:'+userIds);
        Map<Id,User> owners = new Map<Id,User>([
                                                Select 
                                                    Id,
                                                    CT_ZBM_User__c,
                                                    MR_ZBM_User__c,
                                                    UL_ZBM_User__c,
                                                    XR_VL_ZBM_User__c
                                                From user 
                                                WHERE id IN :userIds
                                                 ]); 
        System.debug('owners:'+owners);
        for(Opportunity opp: newOpps){
            //if(opp.ZBM__c == null){
                if(opp.Modality_TAMS__c == 'CT'){                
                  if(accOwners.get(opp.AccountId).CT_ZBM_acc__c != null)
                       {
                        opp.ZBM__c = accOwners.get(opp.AccountId).CT_ZBM_acc__c; 
                       }
                       else
                       {  
                        opp.ZBM__c = owners.get(opp.OwnerId).CT_ZBM_User__c;
                       } 
                }
                if(opp.Modality_TAMS__c == 'MR'){
                  if(accOwners.get(opp.AccountId).MR_ZBM_acc__c != null)
                       {
                        opp.ZBM__c = accOwners.get(opp.AccountId).MR_ZBM_acc__c; 
                       }
                       else
                       {  
                        opp.ZBM__c = owners.get(opp.OwnerId).MR_ZBM_User__c;
                       } 
                }                
                if(opp.Modality_TAMS__c == 'UL'){
                  if(accOwners.get(opp.AccountId).UL_ZBM_acc__c != null)
                       {
                        opp.ZBM__c = accOwners.get(opp.AccountId).UL_ZBM_acc__c; 
                       }
                       else
                       {  
                        opp.ZBM__c = owners.get(opp.OwnerId).UL_ZBM_User__c;
                       } 
                }                                
                if(opp.Modality_TAMS__c == 'XR' ||opp.Modality_TAMS__c == 'VL' ){
                  if(accOwners.get(opp.AccountId).XR_VL_ZBM_acc__c != null)
                       {
                        opp.ZBM__c = accOwners.get(opp.AccountId).XR_VL_ZBM_acc__c; 
                       }
                       else
                       {  
                        opp.ZBM__c = owners.get(opp.OwnerId).XR_VL_ZBM_User__c;
                       } 
                }                      
                System.debug('New opp.ZBM__c:'+opp.ZBM__c);                          
            //}
        }                     
    }
    //This method is used to change the owner when an Opportunity is created by someone
    //    other than an Account Executive.
    /********** ORIGINAL CODE *********
    public static void changeOpptyOwner(List<Opportunity> inputList) {
        
        Map<Id, List<User>> opptyUserMap = new Map<Id, List<User>>();
        Set<Id> accountIdSet = new Set<Id>();
        Map<Id, Id> accountshareMap = new Map<Id, Id>();
        Map<Id, Id> groupMap = new Map<Id, Id>();
        List<AccountShare> accountShareList = new List<AccountShare>();
        List<Group> groupList = new List<Group>();
        Map<Id, Territory> territoryMap;
        List<UserTerritory> userTerritoryList = new List<UserTerritory>();
        List<User> userList = new List<User>();
        Map<Id, Id> accountUserMap = new Map<Id, Id>();
        
        
        if(!inputList.isEmpty()) {
            accountIdSet = OpptyUtilClass.getAccountSet(inputList);
            
            try {
                accountShareList = [Select Id, UserOrGroupId, AccountId from AccountShare where (RowCause = 'Territory' OR RowCause = 'TerritoryManual') and AccountId IN :accountIdSet ];
            }catch(Exception e) {
                ErrorLog.storeException(e.getMessage());
            }
            
            if(!accountShareList.isEmpty()) {
                accountshareMap = OpptyUtilClass.getAccountShareMap(accountShareList);
             
                try {
                    groupList =  [Select Id, RelatedId from Group where Type='Territory' and Id IN :accountshareMap.Values()];
                }catch(Exception e) {
                    ErrorLog.storeException(e.getMessage());
                }
                
                if(!groupList.isEmpty()) {
                    groupMap = OpptyUtilClass.getGroupMap(groupList);
                    
                    try {
                        territoryMap = new Map<Id, Territory>([select id, name, ParentTerritoryId from Territory where Id IN :groupMap.Values() ]);
                    } catch(Exception e) {
                        ErrorLog.storeException(e.getMessage());
                    }
                    
                    if(!territoryMap.isEmpty()) {
                        
                        try {
                            userTerritoryList = [Select UserId, TerritoryId, IsActive, Id From UserTerritory WHERE IsActive = true AND TerritoryId IN :territoryMap.KeySet()];
                        } catch(Exception e) {
                            ErrorLog.storeException(e.getMessage());
                        }
                        
                        if(!userTerritoryList.isEmpty()) {
                            Set<Id> userIdSet = new Set<Id>();
                            
                            userIdSet = OpptyUtilClass.getUserSet(userTerritoryList);
                            
                            try {
                                userList = [Select Id, Title, ProfileId From User where isActive = true AND Id IN :userIdSet];
                            } catch(Exception e) {
                                ErrorLog.storeException(e.getMessage());
                            }
                            if(!userList.isEmpty()) {
                                accountUserMap = OpptyUtilClass.getAccountExecutiveMap(userList, userTerritoryList, territoryMap.KeySet(), accountshareMap, groupMap);
                            }
                        }
                    }
                }   
            }
            
            //Modifies the Owner of the Opportunity
            if(!accountUserMap.isEmpty()) {
                for(Opportunity loopOpp:inputList) {
                    if(accountUserMap.containsKey(loopOpp.AccountId)) {
                        loopOpp.OwnerId = accountUserMap.get(loopOpp.AccountId);
                    }
                }
            }
        }
    }         
    */
}