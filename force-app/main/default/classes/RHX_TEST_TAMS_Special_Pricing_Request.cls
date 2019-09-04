@isTest(SeeAllData=true)
public class RHX_TEST_TAMS_Special_Pricing_Request {
	static testMethod void RHX_Testmethod() {
        List<sObject> sourceList = [SELECT Id 
			FROM TAMS_Special_Pricing_Request__c LIMIT 1];
        if(sourceList.size() == 0) {
            sourceList.add(
                    new TAMS_Special_Pricing_Request__c()
            );
        }
    	rh2.ParentUtil.UpsertRollupTestRecords( sourceList );
    }
}