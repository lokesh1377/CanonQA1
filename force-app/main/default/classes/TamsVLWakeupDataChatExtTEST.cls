@isTest
public class TamsVLWakeupDataChatExtTEST {

    public static testMethod void testVLWakeupDBChart() {
        PageReference VLWakeUpDataPage= Page.TamsVLWakeUpDataPage;
        Test.setCurrentPage(VLWakeUpDataPage);
        
        Account a = new Account();
        a.Name = 'Test';        
        insert a;

        Id RecTypeCIB = [Select Id From RecordType Where SobjectType = 'Install_Base_TAMS__c' 
                         And IsActive = true And Name = 'Competitor Install Base'].Id;
        
        Account acc = new Account(Name = 'Test Account');
        insert acc;

        Install_Base_TAMS__c ib = new Install_Base_TAMS__c
                                (Account_Name__c = acc.Id, 
                                 Modality_ALL__c = 'VL', 
                                 Manufacturer_ALL__c = 'GE', 
                                 Active_IB__c = true,
                                 RecordTypeId = RecTypeCIB,
                                 SID_TAMS__c = '123456',
                                 Nickname__c = 'Test',
                                 Name = 'Test',
                                 Install_Year_Comp__c = '2012');
        insert ib;
                                                
        VL_Wake_Up_Data__c VLWakeupDB = new VL_Wake_Up_Data__c
                                                        (SID__c = ib.SID_TAMS__c,
                                                         Equipment__c = ib.ID,
                                                         Account__c = acc.Id,
                                                         rmType__c  = 'BP',
                                                         acqDate__c = SYSTEM.today(),
                                                         base_reading_date__c = SYSTEM.today()- 30,
                                                         f_tubetype__c = 'HK-TEST-TUBE-F',
                                                         l_tubetype__c = 'HK-TEST-TUBE-L'
                                                        );
        insert VLWakeupDB;
        
        ApexPages.currentPage().getParameters().put('ID', ib.ID);
        ApexPages.StandardController stdCont = new ApexPages.StandardController(ib); 
        TamsVLWakeupDataChatExt VLWakeupDBCtrl = new TamsVLWakeupDataChatExt(stdCont);

    }
}