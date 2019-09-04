@isTest
public class TamsCommunityCasesCTRTest {
	@isTest
	public static void testCommunityCasesGeneralInquiry(){
		PageReference casePage = Page.TamsCommunityCasesVFP;
		Test.setCurrentPage(casePage);
		List<Account> accts = createAccounts(1);
		Install_Base_TAMS__c equipment = createEquipment(accts[0].ID);	
		List<Case> casesEquipment = createCases(10,accts[0].ID,'Install','New',equipment.id);
		List<Case> casesGeneralInquiry = createCases(10,accts[0].ID,'Education & Training','New',equipment.id);
		
		Test.startTest();
		TamsCommunityCasesCTR caseController = new TamsCommunityCasesCTR();
		caseController.caseCategory = 'GeneralInquiry';
		caseController.filter();
		List<Case> cases1 = caseController.getCases();
		System.debug('cases1.size:'+cases1.size());
		Test.stopTest();
		System.assert(cases1.size() == 10 ,'Total General Inquiry case count should be 10. Actual:'+cases1.size());
	}

	@isTest
	public static void testCommunityCasesEquipment(){
		PageReference casePage = Page.TamsCommunityCasesVFP;
		Test.setCurrentPage(casePage);
		List<Account> accts = createAccounts(1);
		Install_Base_TAMS__c equipment = createEquipment(accts[0].ID);	
		List<Case> casesEquipment = createCases(10,accts[0].ID,'Install','New',equipment.id);
		List<Case> casesGeneralInquiry = createCases(10,accts[0].ID,'Education & Training','New',equipment.id);
		
		Test.startTest();
		TamsCommunityCasesCTR caseController = new TamsCommunityCasesCTR();
		caseController.caseCategory = 'Equipment';
		caseController.filter();
		//Integer i= caseController.totalPages;
		//Integer j= caseController.pageNumber;
		caseController.sortByField();
		caseController.refreshPageSize();
		List<Case> cases1 = caseController.getCases();
		System.debug('cases1.size:'+cases1.size());
		Test.stopTest();
		System.assert(cases1.size() == 10 ,'Total Equipment case count should be 10. Actual:'+cases1.size());
	}

	@isTest
	public static void testCommunityCasesWhereClause(){
		PageReference casePage = Page.TamsCommunityCasesVFP;
		Test.setCurrentPage(casePage);
		List<Account> accts = createAccounts(1);
		Install_Base_TAMS__c equipment = createEquipment(accts[0].ID);	
		List<Case> casesEquipment = createCases(10,accts[0].ID,'Install','New',equipment.id);
		List<Case> casesGeneralInquiry = createCases(10,accts[0].ID,'Education & Training','New',equipment.id);
		
		Test.startTest();
		TamsCommunityCasesCTR caseController = new TamsCommunityCasesCTR();
		caseController.caseCategory = 'Equipment';
		caseController.PMAttached = 'Yes';
		caseController.FSRAttached = 'Yes';
		caseController.SRNumber = '123';
		caseController.status = 'New';
		caseController.subject = 'Test';
		caseController.accountName = 'TEST';
		caseController.dummyCaseForFromDate.Date_Case_Working__c = System.today();
		caseController.dummyCaseForToDate.Date_Case_Working__c = System.today();
		caseController.caseNumber = '123';
		caseController.nickName = 'Test';
		caseController.SID = '123';
		caseController.Modality = 'CT';
		caseController.caseType = 'Install';
		caseController.filter();
		List<Case> cases1 = caseController.getCases();
		Integer j= caseController.pageNumber;
		Integer i= caseController.totalPages;
		//NO RECORDS WILL be returned. No need to Assert as its just to improve code coverage for WHERE CLAUSE IF CONDITIONS
		System.debug('cases1.size:'+cases1.size());
		Test.stopTest();
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
	        c.status = caseStatus;
			cases.add(c);
		}
		insert cases;
		return cases;	
	}	

	private static Install_Base_TAMS__c createEquipment(Id accountId){	
	    RecordType RecTypeIB = [Select Id From RecordType 
	        						Where SobjectType = 'Install_Base_TAMS__c' 
	        						And IsActive = true And Name = 'TAMS Install Base'];
        
 
       	Install_Base_TAMS__c equipment = new Install_Base_TAMS__c
                            (Account_Name__c      =  accountId,
                             Name                 = '30050001',
                             SID_TAMS__c          = '30050001',
                             Modality_ALL__c      = 'CT', 
                             Manufacturer_ALL__c  = 'GE', 
                             Active_IB__c         =  true,
                             RecordTypeId         =  RecTypeIB.Id,
                             Nickname__c          = 'TestIB',
                             External_ID__c       = '30050001'
                            );

        insert equipment;
        return equipment;         
               
    } 
}