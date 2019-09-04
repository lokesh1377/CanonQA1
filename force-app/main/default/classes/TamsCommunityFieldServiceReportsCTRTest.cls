@isTest
public class TamsCommunityFieldServiceReportsCTRTest {
	@isTest
	public static void testCommunityFSRs(){
		System.debug('START TEST:testCommunityFSRs');
		PageReference fsrPage = Page.TamsCommunityFieldServiceReportsVFP;
		Test.setCurrentPage(fsrPage);
		List<Account> accts = createAccounts(1);
		Contact contact = createContact(accts[0].ID);
		List<Install_Base_TAMS__c> equipments = createEquipments(accts[0].ID, 10);
		List<Case> cases = createCases(1,accts[0].ID,'Install','New',equipments[0].id); //(Integer cnt, ID acctId, String caseType, String caseStatus, id equipmentId){
		List<TAMS_FSR_Attachment__c> FSRs = createFSRs(equipments[0].id,cases[0].id,1);	//(Id equipmentId, Id caseId Integer cnt)
		Test.startTest();
		TamsCommunityFieldServiceReportsCTR fsrController = new TamsCommunityFieldServiceReportsCTR();
		fsrController.filter();
		List<TAMS_FSR_Attachment__c> FSRs1 = fsrController.getFieldServiceRequests();
		Test.stopTest();
		System.assert(FSRs1.size() == 1 ,'Total FSRs1 count should be 1. Actual:'+FSRs1.size());
		System.debug('END TEST:testCommunityFSRs');
	}


	@isTest
	public static void testCommunityFSRWhereClause(){
		System.debug('START TEST:testCommunityFSRWhereClause');
		PageReference fsrPage = Page.TamsCommunityFieldServiceReportsVFP;
		Test.setCurrentPage(fsrPage);
		List<Account> accts = createAccounts(1);
		Contact contact = createContact(accts[0].ID);
		List<Install_Base_TAMS__c> equipments = createEquipments(accts[0].ID,10);
		List<Case> cases = createCases(1,accts[0].ID,'Install','New',equipments[0].id); //(Integer cnt, ID acctId, String caseType, String caseStatus, id equipmentId){
		List<TAMS_FSR_Attachment__c> FSRs = createFSRs(equipments[0].id,cases[0].id,1);	//(Id equipmentId, Id caseId Integer cnt)
		Test.startTest();
		TamsCommunityFieldServiceReportsCTR fsrController = new TamsCommunityFieldServiceReportsCTR();
		fsrController.Modality = 'CT';
		fsrController.SID = '30050001';
		fsrController.nickName = 'TestIB';
		fsrController.accountName = 'TEST ACCOUNT';
		fsrController.SRNumber = '123';
		fsrController.dummyFSRForFromDate.Dummy_Date__c = System.today();
		fsrController.dummyFSRForToDate.Dummy_Date__c = System.today();
		fsrController.dummyFSRForCaseIncidentFromDate.Dummy_Date__c = System.today();
		fsrController.dummyFSRForCaseIncidentToDate.Dummy_Date__c = System.today();
		fsrController.filter();
		List<TAMS_FSR_Attachment__c> FSRs1 = fsrController.getFieldServiceRequests();
		Integer j= fsrController.pageNumber;
		Integer i= fsrController.totalPages;
		fsrController.refreshPageSize();
		Test.stopTest();
		//System.assert(FSRs1.size() == 1 ,'Total FSRs1 count should be 1. Actual:'+FSRs1.size());
		System.debug('STOP TEST:testCommunityFSRWhereClause');
	}
	private static List<Account> createAccounts(Integer cnt){
		List<Account> accts = new List<Account>();
		for(Integer i=0 ; i < cnt; i++){
			Account acct = new Account();
			acct.Name = 'TEST ACCOUNT'+i;
			acct.ShippingCity = 'Tustin';
			acct.ShippingStreet = 'TAMS'+i;
			acct.ShippingState = 'CA';
			acct.ShippingPostalCode = '92570';
			accts.add(acct);
		}
		insert accts;
		return accts;	
	}

	private static Contact createContact(Id accountId){
		Contact c = new Contact();
		c.accountid = accountId;
		c.firstName = 'test';
		c.Modality__c = 'CT'; 
		c.lastName = 'test';
		insert c;
		return c;
	}


	private static List<Install_Base_TAMS__c> createEquipments(Id accountId,  Integer cnt){	
	    RecordType RecTypeIB = [Select Id From RecordType 
	        						Where SobjectType = 'Install_Base_TAMS__c' 
	        						And IsActive = true And Name = 'TAMS Install Base'];
        
        List<Install_Base_TAMS__c> equipments = new List<Install_Base_TAMS__c>();   

        for(Integer i=0 ; i < cnt; i++){  
        	Install_Base_TAMS__c equipment = new Install_Base_TAMS__c
                            (Account_Name__c      =  accountId,
                             Name                 = '30050001'+i,
                             SID_TAMS__c          = '30050001',
                             Modality_ALL__c      = 'CT', 
                             Manufacturer_ALL__c  = 'GE', 
                             Active_IB__c         =  true,
                             RecordTypeId         =  RecTypeIB.Id,
                             Nickname__c          = 'TestIB'+i,
                             External_ID__c       = '30050001'+i
                            );
            equipments.add(equipment);                
        }           
        insert equipments;
        return equipments;         
               
    }    

	private static List<Case> createCases(Integer cnt, ID acctId, String caseType, String caseStatus, id equipmentId){
		List<Case> cases = new List<Case>();
		ID caseRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get(caseType).getRecordTypeId();
			
		for(Integer i=0 ; i < cnt; i++){
	        
	        Case c = new Case();
	        c.Subject = 'Test Case';
	        c.Description = 'Test Case Description';
	        c.Type = caseType;
	        c.AccountId = acctId;
	        c.RecordTypeId = caseRecordTypeId;
	        c.Primary_Contact_Last_Name__c = 'Last Name';
	        c.Primary_Contact_First_Name__c = 'First Name';
	        c.Primary_Contact_Email__c = 'first.last@test.com';
	        c.Origin = 'Portal';
	        c.Oracle_SR_Number_TAMS__c = '123';
	        c.PM_Attached__c = true;
	        c.FSR_Attached__c = true;
	        c.Install_Base__c = equipmentId;
	        c.Creation_Date_and_Time__c = System.today();
	        c.status = caseStatus;
			cases.add(c);
		}
		insert cases;
		return cases;	
	}	

	private static List<TAMS_FSR_Attachment__c> createFSRs(Id equipmentId, Id caseId, Integer cnt){	
        List<TAMS_FSR_Attachment__c> FSRs = new List<TAMS_FSR_Attachment__c>();   

        for(Integer i=0 ; i < cnt; i++){  
        	TAMS_FSR_Attachment__c fsr = new TAMS_FSR_Attachment__c
                            (IB_Lookup__c      	= equipmentId,
                             Case_Number__c    	= caseId,
                             SID__c          	= '30050001',
                             SR_Number__c       = '123'
                            );
            FSRs.add(fsr);                
        }           
        insert FSRs;
        return FSRs;         
               
    }


}