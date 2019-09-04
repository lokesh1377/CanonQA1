@isTest
/*********************************************************
        Author: NTT Centerstance
        Purpose: Test Strategy Dashboard Controller
        1.0 - Nanda Tumurugoti - 09/04/2013 - Created
**********************************************************/
public with sharing class Test_StrategyDashBoard {
    private static testMethod void UnitTest(){
        Id RecTypeCIB = [Select Id From RecordType Where SobjectType = 'Install_Base_TAMS__c' And IsActive = true And Name = 'Competitor Install Base'].Id;
        
        Account acc = new Account(Name = 'Test Account');
        insert acc;
        Install_Base_TAMS__c ib = new Install_Base_TAMS__c(Account_Name__c = acc.Id, Modality_ALL__c = 'XR', Manufacturer_ALL__c = 'GE', Active_IB__c = true,RecordTypeId = RecTypeCIB,Install_Year_Comp__c = '2012');
        insert ib;
        PageReference pr = new PageReference('/apex/StrategyDashBoard?Id=' + acc.Id);
        Test.setCurrentPage(pr);
        ApexPages.Standardcontroller sc = new ApexPages.Standardcontroller(acc);
        StrategyDashBoard ibs = new StrategyDashBoard(sc);
        ibs.IBModalityGroups[0].getTotalRecordCount();
    }


}