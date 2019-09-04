/*********************************************************
        Author: XELLERATION         
        Purpose: This Utility Class is used support the  
        OpportunitytriggerHandler Class with helper methods.    
        1.0 - Brandon Cassis - 03/17/2015 - Created
        1.1 - Lokesh Tigulla - 05/02/2019 - Updated old userterritory object to new userterritory object
**********************************************************/
public class OpptyUtilClass{
    
    //This method is used to get the Account Set.
    public static Set<Id> getAccountSet(List<Opportunity> inputList) {
        Set<Id> returnSet = new Set<Id>();
        
        for(Opportunity loopOppty: inputList) {
            returnSet.add(loopOppty.AccountId);
        }
        return returnSet;
    } 

    //This method is used to create a Map of Account Shares.
    public static Map<Id, Id> getAccountShareMap(List<AccountShare> inputList) {
        Map<Id, Id> returnMap = new Map<Id, Id>();
        system.debug(loggingLevel.Warn, 'inputlist ' + inputList.size());
        for(AccountShare loopAS: inputList) {
            returnMap.put(loopAS.AccountId, loopAS.UserOrGroupId);
        }
        system.debug(loggingLevel.Warn, 'returnMap ' + returnMap.size());
        return returnMap;
    }
    
    //This method is used to create a Map of Groups.
    public static Map<Id, Id> getGroupMap(List<Group> inputList) {
        Map<Id, Id> returnMap = new Map<Id, Id>();
        
        for(Group loopG: inputList) {
            returnMap.put(loopG.Id, loopG.RelatedId);
        }
        return returnMap;
    }
    
    //This method is used to get the User Set.
    public static Set<Id> getUserSet(List<UserTerritory2Association > inputList) {
        Set<Id> returnSet = new Set<Id>();
        
        for(UserTerritory2Association loopUT: inputList) {
            returnSet.add(loopUT.UserId);
        }
        return returnSet;
    }
    
    //This method is used to get a collection Map of Account Executives for an account. 
    public static Map<Id, Id> getAccountExecutiveMap(List<User> inputUserList, List<UserTerritory2Association > inputUserTerritoryList, Set<Id> inputTerritorySet, Map<Id,Id> inputAccountShareMap, Map<Id, Id> inputGroupMap) {
        Map<Id, Id> returnMap = new Map<Id, Id>();
        Map<Id, List<User>> terrUserListMap = new Map<Id, List<User>>();
        
        terrUserListMap = getTerritoryList(inputUserList, inputTerritorySet, inputUserTerritoryList);
        
        try {
        
            for(Id loopShareId: inputAccountShareMap.keySet()) {
                
                for(User loopUser: terrUserListMap.get(inputGroupMap.get(inputAccountShareMap.get(loopShareId)))) {
                    Id tempKeyId;
                    Id tempSrId;
                   
                    if(loopUser.ProfileId == OpptyStaticVarsUtilClass.AEProfileId) {
                        
                        if(loopUser.Title == System.label.AETitle) {
                            returnMap.put(loopShareId, loopUser.Id); 
                        } else if(loopUser.Title == System.label.SRAETitle) {
                            tempSrId = loopUser.Id;
                        } else if(loopUser.Title == System.label.KeyAETitle) {
                            tempKeyId = loopUser.Id;
                        }  
                    }
                    
                    if(!returnMap.containsKey(loopShareId)) {
                        if(tempSrId != null) {
                            returnMap.put(loopShareId, tempSrId);
                        } else if(tempKeyId != null) {
                            returnMap.put(loopShareId, tempKeyId);
                        }
                    }
                }
            }
        } catch(Exception e) {
            ErrorLog.storeException(e.getMessage());
        }
        
        return returnMap;
    }
   
   //This method is used to put all of the Users in a territory into a Map. 
   public static Map<Id, List<User>> getTerritoryList(List<User> inputUserList, Set<Id> inputTerritorySet, List<UserTerritory2Association> inputUserTerritoryList) {
       Map<Id, List<User>> returnMap = new Map<Id, List<User>>();
       
       Map<Id, User> userMap = new Map<Id, User>();
       
       for(User loopUser: inputUserList) {
           userMap.put(loopUser.Id, loopUser);
       }
       
       for(Id loopId: inputTerritorySet) {
           List<User>tempUserList = new List<User>();
           
           for(UserTerritory2Association loopUT : inputUserTerritoryList) {
               if(loopUT.Territory2Id == loopId) {
                   if(userMap.containsKey(loopUT.UserId)) {
                       tempUserList.add(userMap.get(loopUT.UserId));
                   }
               }
           
           }
           returnMap.put(loopId, tempUserList);
       }
       
       return returnMap;
    }
        
  
}