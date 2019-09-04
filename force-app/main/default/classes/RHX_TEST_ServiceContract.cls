@isTest(SeeAllData=true)
public class RHX_TEST_ServiceContract {
	static testMethod void RHX_Testmethod() {
        List<sObject> sourceList = [SELECT Id 
			FROM ServiceContract LIMIT 1];
        if(sourceList.size() == 0) {
            sourceList.add(
                    new ServiceContract()
            );
        }
    	rh2.ParentUtil.UpsertRollupTestRecords( sourceList );
    }
}