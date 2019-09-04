/**
 * This class contains unit tests to improve code coverage
 */
@isTest(SeeAllData=true)
private class OpptyUtilClassTest {

    static testMethod void myUnitTest() {
    	List<Opportunity> lOpportunities = [Select Id, AccountId From Opportunity Limit 10000];
        Set<Id> sAccountIds = OpptyUtilClass.getAccountSet(lOpportunities);
        
        List<AccountShare> lAccountShares = [Select Id, AccountId, UserOrGroupId From AccountShare Limit 10000];
        Map<Id, Id> mAccountShareIds = OpptyUtilClass.getAccountShareMap(lAccountShares);
        
        List<Group> lGroups = [Select Id, RelatedId From Group Limit 10000];
        Map<Id, Id> mGroupIds = OpptyUtilClass.getGroupMap(lGroups);
        
        List<UserTerritory> lUserTerritories = [Select Id, UserId, TerritoryId From UserTerritory Limit 10000];
        Set<Id> sUserTerritoryIds = OpptyUtilClass.getUserSet(lUserTerritories);
        
        List<User> lUsers = [Select Id, Title, ProfileId From User Limit 10000];
        Set<Id> sTerritoryIds = new Set<Id>();
        for(Territory t : [Select Id From Territory Limit 10000]){
        	sTerritoryIds.add(t.Id);
        }
        Map<Id, Id> mAccountExecIds = OpptyUtilClass.getAccountExecutiveMap(lUsers, lUserTerritories, sTerritoryIds, mAccountShareIds, mGroupIds);
    }
}