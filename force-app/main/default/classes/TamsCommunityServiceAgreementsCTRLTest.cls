@isTest
public class TamsCommunityServiceAgreementsCTRLTest {
	@isTest
	public static void testCommunityServiceAgreements(){
		System.debug('START TEST:testCommunityServiceAgreements');
		PageReference saPage = Page.TamsCommunityServiceAgreementsVFP;
		Test.setCurrentPage(saPage);
		List<Account> accts = createAccounts(1);
		Contact contact = createContact(accts[0].ID);
		List<Install_Base_TAMS__c> equipments = createEquipments(accts[0].ID, 10);
		List<Case> cases = createCases(1,accts[0].ID,'Install','New',equipments[0].id); //(Integer cnt, ID acctId, String caseType, String caseStatus, id equipmentId){
		List<ServiceContract> SAs = createServiceAgreements(accts[0].ID,equipments[0].id,1);	//(Id accountId,Id equipmentId,  Integer cnt){	
		Test.startTest();
		TamsCommunityServiceAgreementsCTRL saController = new TamsCommunityServiceAgreementsCTRL();
		saController.filter();
		List<ServiceContract> SAs1 = saController.getServiceAgreements();
		Test.stopTest();
		//System.assert(SAs1.size() == 1 ,'Total SAs1 count should be 1. Actual:'+SAs1.size());
		System.debug('END TEST:testCommunityServiceAgreements');
	}


	@isTest
	public static void testCommunityServiceAgreementsWhereClause(){
		System.debug('START TEST:testCommunityServiceAgreementsWhereClause');
		PageReference saPage = Page.TamsCommunityServiceAgreementsVFP;
		Test.setCurrentPage(saPage);
		List<Account> accts = createAccounts(1);
		Contact contact = createContact(accts[0].ID);
		List<Install_Base_TAMS__c> equipments = createEquipments(accts[0].ID,10);
		List<Case> cases = createCases(1,accts[0].ID,'Install','New',equipments[0].id); //(Integer cnt, ID acctId, String caseType, String caseStatus, id equipmentId){
		List<ServiceContract> SAs = createServiceAgreements(accts[0].ID,equipments[0].id,1);	//(Id accountId,Id equipmentId,  Integer cnt){	
		Test.startTest();
		TamsCommunityServiceAgreementsCTRL saController = new TamsCommunityServiceAgreementsCTRL();
		saController.Modality = 'CT';
		saController.SID = '30050001';
		saController.nickName = 'TestIB';
		saController.accountName = 'TEST ACCOUNT';
		saController.SRNumber = '123';
		saController.Status = 'Active';
		saController.dummySAForContractEndFromDate.Quote_Signed_Date__c = System.today();
		saController.dummySAForContractEndToDate.Quote_Signed_Date__c = System.today();
		saController.dummySAForContractStartFromDate.Quote_Signed_Date__c = System.today();
		saController.dummySAForContractStartToDate.Quote_Signed_Date__c = System.today();
		saController.filter();
		List<ServiceContract> SAs1 = saController.getServiceAgreements();
		Integer j= saController.pageNumber;
		Integer i= saController.totalPages;
		saController.refreshPageSize();
		Test.stopTest();
		//System.assert(SAs1.size() == 1 ,'Total SAs1 count should be 1. Actual:'+SAs1.size());
		System.debug('STOP TEST:testCommunityServiceAgreementsWhereClause');
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


	private static List<Install_Base_TAMS__c> createEquipments(Id accountId, Integer cnt){	
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

	private static List<ServiceContract> createServiceAgreements(Id accountId, Id equipmentId, Integer cnt){	
        List<ServiceContract> SAs = new List<ServiceContract>();   

        for(Integer i=0 ; i < cnt; i++){  
	        ServiceContract sc = new ServiceContract();
	        sc.Name               = '50000-001'+i;
	        sc.AccountId          = accountid;
	        sc.Modality__c        = 'CT';
	        sc.Equipment__c       = equipmentId;
	        sc.Contract_Status__c = 'Active';
	        sc.StartDate          = SYSTEM.today() - 10;  
	        sc.EndDate            = SYSTEM.today() + 355;
	        sc.Type__c            = 'Warranty Support';
	        sc.sid__c             = '30050001';
            SAs.add(sc);                
        }           
        insert SAs;
        return SAs;         
               
    }

}