@isTest(SeeAllData=true)
public class RHX_TEST_SPR_Quote {
	static testMethod void RHX_Testmethod() {
        List<sObject> sourceList = [SELECT Id 
			FROM SPR_Quote__c LIMIT 1];
        if(sourceList.size() == 0) {
            sourceList.add(
                    new SPR_Quote__c()
            );
        }
    	rh2.ParentUtil.UpsertRollupTestRecords( sourceList );
    }
}