/**
    This helper class is shared & utilized by test classes:
  		AdminTabControllerTest, HomePageComponentListViewsControllerTest,
  		NewCaseInstallBaseExtTest, NewCaseOverrideExtTest, TAMS_AffiliationTriggerHandlerTest, 
  		UserTriggerHandlerTest, UserTriggerHandlerTest, Contact_TriggerHandlerTest,
  		Batch_ProcessAccountSharesTest
  		
    @author NTT Data - Louis Wooldridge
    @date August 17, 2014
    
    @update
**/
@isTest
public class HelperClassTest {
	static Id idSystemAdminId= [Select Id, Name From Profile p
		Where Name = 'TAMS - Service Agent User'].Id;
	static Id idPortalAdminProfileId= [Select Id, Name From Profile p 
		Where UserType = 'PowerCustomerSuccess' And Name = 'TAMS - Customer Portal Admin User'].Id;
	static Id idPortalStandardProfileId= [Select Id, Name From Profile p 
		Where UserType = 'PowerCustomerSuccess' And Name = 'TAMS - Customer Portal Standard User'].Id;
	
	static Id idPortalRoleId = [Select Id From UserRole Where PortalType = 'None' Limit 1].Id;
	static Id idSysAdminProfile = [Select Id from Profile where name = 'System Administrator'].Id;
	
	static public void CreateGeneralInquiryRecTypeSettings(){
		List<GeneralInquiryRT__c> lInsertSettings = new List<GeneralInquiryRT__c>();
		
    	lInsertSettings.add(new GeneralInquiryRT__c(Name = 'Org Default', SetupOwnerId=UserInfo.getOrganizationId(),
    		Record_Type_Developer_Name_List__c = 'Billing_Invoice,Education_Training,Service_Contract,Service_Parts,Update_Account,Web_Support,New_User_Request'));
    	lInsertSettings.add(new GeneralInquiryRT__c(Name = 'TAMS - Customer Portal Admin User', SetupOwnerId=idPortalAdminProfileId,
    		Record_Type_Developer_Name_List__c = 'Billing_Invoice,Education_Training,Service_Contract,Service_Parts,Update_Account,Web_Support,New_User_Request'));
    	lInsertSettings.add(new GeneralInquiryRT__c(Name = 'TAMS - Customer Portal Standard User', SetupOwnerId=idPortalStandardProfileId,
    		Record_Type_Developer_Name_List__c = 'Billing_Invoice,Education_Training,Service_Contract,Service_Parts,Update_Account,Web_Support'));
    	
    	insert lInsertSettings;
	}
	
	static public User PortalAccountOwner(){
		User oPortalAccountOwner = new User();
		oPortalAccountOwner.UserRoleId = idPortalRoleId;
		oPortalAccountOwner.ProfileId = idSysAdminProfile;
		oPortalAccountOwner.UserName = 'PortalOwner@test.com';
		oPortalAccountOwner.Alias = 'powner';
		oPortalAccountOwner.Email = 'PortalOwner@test.com';
		oPortalAccountOwner.FirstName = 'portal';
		oPortalAccountOwner.LastName = 'owner';
		oPortalAccountOwner.emailencodingkey='UTF-8';
		oPortalAccountOwner.languagelocalekey='en_US';
		oPortalAccountOwner.localesidkey='en_US';
		oPortalAccountOwner.timezonesidkey='America/Los_Angeles';
		oPortalAccountOwner.PortalRole = 'Manager';
		insert oPortalAccountOwner;
		
		return oPortalAccountOwner;
	}
	
	static public Account CreatePortalAccount(String sName, String sParentId, String sOwnerId){
		Account oAccount = new Account();
		oAccount.OwnerId = sOwnerId;
		String sAccountName = 'TestPortalAccount';
		if(String.isNotEmpty(sName)){
			sAccountName = sName;
		}
		String sLastName = 'Test-' + sAccountName;
		
		String sAccountRT = Schema.SObjectType.Account.getRecordTypeInfosByName().get('TAMS Account').getRecordTypeId();
		oAccount.Name=sAccountName;
		oAccount.RecordTypeId=sAccountRT;
		if(String.isNotEmpty(sParentId)){
			oAccount.ParentId = sParentId;
		}
		insert oAccount;
		
		return oAccount;
	}
	
	static public Map<String, Contact> CreatePortalAcctContacts(Account oAccount){
		Map<String, Contact> mContacts = new Map<String, Contact>();
		
		String sContactRT = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('TAMS Contact').getRecordTypeId();
		String sLastName = 'Test-' + oAccount.Name;
		
		Contact oAdminContact = new Contact(FirstName='Admin', LastName=sLastName, RecordTypeId=sContactRT, AccountId=oAccount.Id,
			Email=sLastName + '_Admin@unittest.com', Portal_User_Type__c = 'Admin', Modality__c = 'CT');
		insert oAdminContact;
		mContacts.put('Admin', oAdminContact);
		
		Contact oStandardContact = new Contact(FirstName='Standard', LastName=sLastName, RecordTypeId=sContactRT, AccountId=oAccount.Id,
			Email=sLastName + '_Standard@unittest.com', Portal_User_Type__c = 'Standard', Modality__c = 'CT');
		insert oStandardContact;
		mContacts.put('Standard', oStandardContact);
		
		return mContacts;
	}
	
	static public Map<String, User> CreatePortalUsers(Map<String, Contact> mContacts){
    	Map<String, User> mUsers = new Map<String, User>();
		String sAliasSuffix = System.now().format('Hmm');
		Contact oAdminContact = mContacts.get('Admin');
		
		User oAdminUser = new User(alias='admn' + sAliasSuffix, email=oAdminContact.email, 
            emailencodingkey='UTF-8', firstname='Admin', lastname=oAdminContact.lastname, languagelocalekey='en_US', 
            localesidkey='en_US', profileid=idPortalAdminProfileId,
            timezonesidkey='America/Los_Angeles', username=oAdminContact.email,
            IsPortalSelfRegistered=true, CommunityNickname=oAdminContact.email.left(40), isactive=true,
            ContactId=oAdminContact.Id);
		insert oAdminUser;
		
		oAdminUser = [Select Id, IsPortalEnabled, AccountId From User Where Id = :oAdminUser.Id];
		System.assert(oAdminUser.IsPortalEnabled == true, 'User needs to be Portal Enabled');
		System.assert(oAdminUser.AccountId != null, 'We need AccountId Assigned');
		
		mUsers.put('Admin', oAdminUser);
		
		Contact oStandardContact = mContacts.get('Standard');
		
		User oStandardUser = new User(alias='stnd' + sAliasSuffix, email=oStandardContact.email, 
            emailencodingkey='UTF-8', firstname='Standard', lastname=oStandardContact.lastname, languagelocalekey='en_US', 
            localesidkey='en_US', profileid=idPortalStandardProfileId, 
            timezonesidkey='America/Los_Angeles', username=oStandardContact.email,
            IsPortalSelfRegistered=true, CommunityNickname=oStandardContact.email.left(40), isactive=true,
            ContactId=oStandardContact.Id);
		insert oStandardUser;
		
		oStandardUser = [Select Id, IsPortalEnabled, AccountId From User Where Id = :oStandardUser.Id];
		System.assert(oStandardUser.IsPortalEnabled == true, 'User needs to be Portal Enabled');
		System.assert(oStandardUser.AccountId != null, 'We need AccountId Assigned');
		
		mUsers.put('Standard', oStandardUser);
		
		return mUsers;
	}
	
	static public void CreateAccountShares(Account oChildAccount, Map<String, User> mParentUser){
		List<AccountShare> lInsertShares = new List<AccountShare>();
		
		for(String sUser : mParentUser.keySet()){
			//Creating Account Share Records because cannot run batch in test
			AccountShare oAdminShare = new AccountShare();
			oAdminShare.UserOrGroupId = mParentUser.get(sUser).Id;
			oAdminShare.AccountId = oChildAccount.Id;
			if(sUser == 'Admin'){
				oAdminShare.AccountAccessLevel = 'Edit';
			}else{
				oAdminShare.AccountAccessLevel = 'Read';
			}
			oAdminShare.OpportunityAccessLevel = 'None';
			lInsertShares.add(oAdminShare);
		}
		
		insert lInsertShares;
	}
	
	static public Install_Base_TAMS__c CreateEquipment(Account oAccount){
		String sEquipmentRT = Schema.SObjectType.Install_Base_TAMS__c.getRecordTypeInfosByName().get('TAMS Install Base').getRecordTypeId();
        Install_Base_TAMS__c oTestEquipment = new Install_Base_TAMS__c();
        oTestEquipment.Name = 'Test-123456';
        oTestEquipment.RecordTypeId = sEquipmentRT;
        oTestEquipment.Account_Name__c = oAccount.Id;
        oTestEquipment.Modality_ALL__c = 'CT';
        oTestEquipment.Nickname__c = 'Test Equipment';
        insert oTestEquipment;
        
        return oTestEquipment;
	}
	
	static public ServiceContract CreateContract(Account oAccount, Contact oContact, Install_Base_TAMS__c oEquipment){
		ServiceContract oTestContract = new ServiceContract();
        oTestContract.SID__c = '99999';
        oTestContract.Name = 'Test Contract';
        oTestContract.Modality__c = 'CT';
        oTestContract.Equipment__c = oEquipment.Id;
        oTestContract.EndDate = system.today().addDays(90);
        oTestContract.StartDate = system.today();
        oTestContract.Contract_Status__c = 'Active';
        oTestContract.Oracle_Status__c = 'Active';
        oTestContract.ContactId = oContact.Id;
        oTestContract.AccountId = oAccount.Id;
        insert oTestContract;
        
        ServiceContract oContractVerifyException = [Select Is_Exception__c From ServiceContract Where Id = :oTestContract.Id];
		System.assert(oContractVerifyException.Is_Exception__c == false, 'Is_Exception__c needs to be false for Service Contract to be shared.');
        
        return oTestContract;
	}
	
	static public Case CreateCase(Account oAccount, Install_Base_TAMS__c oEquipment){
        String sCaseRT = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Install').getRecordTypeId();
		Case oTestCase = new Case();
        oTestCase.AccountId = oAccount.Id;
        oTestCase.Type = 'Install';
        oTestCase.Status = 'Closed';
        oTestCase.Subject = 'Test Case';
        oTestCase.Description = 'Test Case Description';
        oTestCase.RecordTypeId = sCaseRT;
        oTestCase.Primary_Contact_Last_Name__c = 'Last Name';
        oTestCase.Primary_Contact_First_Name__c = 'First Name';
        oTestCase.Primary_Contact_Email__c = 'first.last@test.com';
        oTestCase.Origin = 'Portal';
        oTestCase.Install_Base__c = oEquipment.Id;
        insert oTestCase;
        
        Case oCaseVerifyFlags = [Select Admin_Portal_Share__c, Standard_Portal_Share__c From Case Where Id = :oTestCase.Id];
		System.assert(oCaseVerifyFlags.Admin_Portal_Share__c == true, 'Admin_Portal_Share__c needs to be true to share with other Admin Users.');
		System.assert(oCaseVerifyFlags.Standard_Portal_Share__c == true, 'Standard_Portal_Share__c needs to be true to share with other Standard Users.');
        
        return oTestCase;
	}
	
	static public TAMS_Affiliation__c CreateAffiliation(Account oAccount, User oUser){
		TAMS_Affiliation__c oNewAffiliation = new TAMS_Affiliation__c();
		oNewAffiliation.User__c = oUser.Id;
		oNewAffiliation.Account__c = oAccount.Id;
		insert oNewAffiliation;
		
		return oNewAffiliation;
	}
}