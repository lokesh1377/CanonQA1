@isTest	
public with sharing class CaseTriggerTest {
	
	static testMethod void testBusinessHoursCheck() {
		Test.startTest();
		
		
		RecordType rtSolutionCenter = [select Id from RecordType where SObjectType = 'Case' and Name = 'Solution Center Support'];
		
		Account acc = new Account(Name= 'Test');
		insert acc;
		
		RecordType ibRT = [select Id from RecordType where SObjectType = 'Install_Base_TAMS__c' and Name = 'TAMS Install Base'];
		
		Install_Base_TAMS__c equip = new Install_Base_TAMS__c(Name = 'Test', Account_Name__c= acc.Id, RecordTypeId = ibRT.Id );
		insert equip;
		
		Case c = new Case(
			RecordTypeId = rtSolutionCenter.Id,
			Install_Base__c = equip.Id
		); 
		
		insert c; 
		
		CaseTrigger ct = new CaseTrigger(); 
		
		BusinessHours bh = [SELECT Id FROM BusinessHours WHERE Name=: ct.SCSBusinessHours];
		
		Case selectedCase = [select IsCreatedInSCSBusinessHours__c from Case where id =: c.Id limit 1];
		
		System.Debug('IsCreatedInSCSBusinessHours:' + selectedCase.IsCreatedInSCSBusinessHours__c);
		System.Debug('Business hours?:' +BusinessHours.isWithin(bh.id, DateTime.Now()));
		
		
		System.assertEquals(selectedCase.IsCreatedInSCSBusinessHours__c, BusinessHours.isWithin(bh.id, DateTime.Now()));
		Test.stopTest();

	}
	
	static testMethod void testCheckPO() {
		
		Account acc = new Account();
		acc.Name = 'Test';
		insert acc;
		
		Install_Base_TAMS__c equip = new Install_Base_TAMS__c();
		equip.Account_Name__c = acc.Id;
		insert equip;
		
		ServiceContract sc = new ServiceContract();
		sc.Name ='test';
		sc.Equipment__c = equip.Id;
		sc.Contract_Status__c = 'Active';
		sc.Oracle_Status__c = 'Active';
		insert sc;
		
		CaseTrigger ct = new CaseTrigger(); 
		BusinessHours bh = [SELECT Id FROM BusinessHours WHERE Name=: ct.SCSBusinessHours];
		
		Entitlement ent = new Entitlement();
		ent.Name = 'test';
		ent.BusinessHoursId = bh.Id;
		ent.Type = 'Extended 24HD';
		ent.AccountId = acc.Id;
		insert ent;
		
		TAMS_Service_Contract_line_Items__c line = new TAMS_Service_Contract_line_Items__c();
		line.ServiceContract__c = sc.Id;
		line.Entitlement__c = ent.Id;
		insert line;
		
		Test.startTest();
		
		DateTime testDate = DateTime.newInstance(2015, 1, 1, 17, 1, 0);
		CaseTrigger.setNow(testDate);
		
		RecordType rtSolutionCenter = [select Id from RecordType where SObjectType = 'Case' and Name = 'Engineer Dispatch'];
		
		try {
			Case c = new Case(
				RecordTypeId = rtSolutionCenter.Id,
				Install_Base__c = equip.Id,
				When_would_you_like_to_schedule_service__c = 'Immediately',
				PO_Number__c = ''
			);
			insert c;
			//System.AssertEquals(true, false); 
		} catch (DmlException ex) {
		}
	
		Test.stopTest();
	}

}