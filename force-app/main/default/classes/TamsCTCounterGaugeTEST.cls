@isTest
public class TamsCTCounterGaugeTEST {
public static testMethod void testCTGauge() {
		PageReference CTCounterGaugePage = Page.TamsCTCounterGaugePage;
		Test.setCurrentPage(CTCounterGaugePage);

		Account a = new Account();
        a.Name = 'Test';        
        insert a;

        Id RecTypeCIB = 
        	[Select 
        		Id  
        	 From 
        	 	RecordType 
        	 Where 
        	 	SobjectType = 'Install_Base_TAMS__c' 
        	 And IsActive = true 
        	 And Name = 'Competitor Install Base'].Id;
        
        Account acc = new Account(Name = 'Test Account');
        insert acc;

        Install_Base_TAMS__c ib = new Install_Base_TAMS__c
        										(Account_Name__c = acc.Id, 
        										 Modality_ALL__c = 'MR', 
        										 Manufacturer_ALL__c = 'GE', 
        										 Active_IB__c = true,
        										 RecordTypeId = RecTypeCIB,
        										 Nickname__c = 'Test',
        										 Name = 'Test',
        										 Install_Year_Comp__c = '2012');
		insert ib;        										
		//Now Insert test data
		Date baseDate = System.today() - 30;
		Date startContractDate = baseDate.addYears(-1);
		Date endContractDate = baseDate.addYears(2);		
		ServiceContract sc = new ServiceContract
										(Equipment__c = ib.ID,
										 StartDate = startContractDate,
										 EndDate = 	endContractDate,
										 AccountID = ib.Account_Name__c,
										 Contract_Status__c = 'Active',
										 Name = 'TamsCTCounterGaugeTEST');
		Insert sc;

		TAMS_Service_Contract_line_Items__c scLine = new TAMS_Service_Contract_line_Items__c
															(ServiceContract__c = sc.Id,
															 Covered_Product__c = ib.ID,
															 Slice_Counter__c = 1000,
															 Overage_Amount__c = 1.5,
															 Start_Date__c = startContractDate,
															 End_Date__c = endContractDate,
															 status__c = 'Active'
															 );
		Insert scLine;
		Install_Base_Counter_TAMS__c counterReading1 = new Install_Base_Counter_TAMS__c
															(Install_Base_Name__c = ib.ID,
															 Reading_Date__c = baseDate,
															 Counter_Reading__c = 100  	
															);
		insert counterReading1;
		ApexPages.StandardController stdCont = new ApexPages.StandardController(ib); 
		TamsCTCounterGaugeExtController CTCounterCtrl = new TamsCTCounterGaugeExtController(stdCont);

		PageReference pageRef = CTCounterCtrl.sendEmail();		
		System.assert(pageRef == NULL);

		Install_Base_Counter_TAMS__c counterReading2 = new Install_Base_Counter_TAMS__c
															(Install_Base_Name__c = ib.ID,
															 Reading_Date__c = baseDate - 60,
															 Counter_Reading__c = 200  	
															);
		stdCont = new ApexPages.StandardController(ib); 
		CTCounterCtrl = new TamsCTCounterGaugeExtController(stdCont);

		insert counterReading2;
		Install_Base_Counter_TAMS__c counterReading3 = new Install_Base_Counter_TAMS__c
															(Install_Base_Name__c = ib.ID,
															 Reading_Date__c = baseDate + 10,
															 Counter_Reading__c = 300  	
															);

		insert counterReading3;														
		stdCont = new ApexPages.StandardController(ib); 
		CTCounterCtrl = new TamsCTCounterGaugeExtController(stdCont);
		scLine.status__c = null;
		update scLine;
		delete counterReading1;
		delete counterReading2;
		delete counterReading3;
		stdCont = new ApexPages.StandardController(ib); 
		CTCounterCtrl = new TamsCTCounterGaugeExtController(stdCont);


	}
}