@isTest(SeeAllData=true)
public class RHX_TEST_TAMS_ROA_Lines {
	static testMethod void RHX_Testmethod() {
        List<sObject> sourceList = [SELECT Id 
			FROM TAMS_ROA_Lines__c LIMIT 1];
        if(sourceList.size() == 0) {
            sourceList.add(
                    new TAMS_ROA_Lines__c()
            );
        }
    	rh2.ParentUtil.UpsertRollupTestRecords( sourceList );
    }
}