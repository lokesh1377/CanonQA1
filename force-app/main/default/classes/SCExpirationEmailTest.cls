@isTest
private class SCExpirationEmailTest {

 	static testMethod void TestEmailExpiration() {

 		System.runAs ( new User(Id = UserInfo.getUserId()) ) {
	 		EmailTemplate et = new EmailTemplate();
			et.isActive = true;
			et.Name = 'test';
			et.DeveloperName = 'test';
			et.TemplateType = 'text';
			et.FolderId = UserInfo.getUserId();
			insert et;
	 		
	 		MyPreferencesEmailList__c pref = new MyPreferencesEmailList__c();
			pref.Name = '90 Days Before Expiration';
			pref.Template_Id__c = et.Id;
			pref.Expiration_Email_to_Send__c = '90 Days';
			pref.Expiration_Email__c = true;
			insert pref;
			
			pref = new MyPreferencesEmailList__c();
			pref.Name = '60 Days Before Expiration';
			pref.Template_Id__c = et.Id;
			pref.Expiration_Email_to_Send__c = '60 Days';
			pref.Expiration_Email__c = true;
			insert pref;
			
			pref = new MyPreferencesEmailList__c();
			pref.Name = '30 Days Before Expiration';
			pref.Template_Id__c = et.Id;
			pref.Expiration_Email_to_Send__c = '30 Days';
			pref.Expiration_Email__c = true;
			insert pref;
			
			User oAccountOwner = HelperClassTest.PortalAccountOwner();
			Account oPortalAccount = HelperClassTest.CreatePortalAccount('PortalAccunt', null, oAccountOwner.Id);
			Map<String,Contact> mContacts = HelperClassTest.CreatePortalAcctContacts(oPortalAccount);
			Map<String,User> mPortalUsers = HelperClassTest.CreatePortalUsers(mContacts);
			
			//List<User> usrs = [select Id from User where IsPortalEnabled = true and IsActive = true];
			
			TAMS_Email_Opt_In_Out__c opt = new TAMS_Email_Opt_In_Out__c();
			opt.Email__c = '90 Days Before Expiration';
			//opt.User__c  = usrs[0].Id;
			opt.User__c = mPortalUsers.get('Admin').Id;
			opt.Is_Opt_Out__c = true;
			insert opt;
			
			
			ServiceContract sc90 = new ServiceContract();
			sc90.Name = 'Test 90';
			sc90.StartDate = Date.Today();
			sc90.EndDate = Date.Today().addDays(90);
			sc90.Contract_Status__c = 'Active';
			sc90.Oracle_Status__c = 'Active';
			insert sc90;
			
			
			ServiceContract sc60 = new ServiceContract();
			sc60.Name = 'Test 60';
			sc60.StartDate = Date.Today();
			sc60.EndDate = Date.Today().addDays(60);
			sc60.Contract_Status__c = 'Active';
			sc60.Oracle_Status__c = 'Active';
			insert sc60;
			
			
			ServiceContract sc30 = new ServiceContract();
			sc30.Name = 'Test 30';
			sc30.StartDate = Date.Today();
			sc30.EndDate = Date.Today().addDays(30);
			sc30.Contract_Status__c = 'Active';
			sc30.Oracle_Status__c = 'Active';
			insert sc30;
			
			List<ServiceContract> servcont = [select Id, Contract_Status__c from ServiceContract where Id =: sc90.Id or Id =: sc60.Id or Id =: sc30.Id];
			
			System.Debug('contract status: ' + servcont);
			
		
			ServiceContractShare scs = new ServiceContractShare();
			scs.ParentId = sc90.Id;
			//scs.UserOrGroupId = usrs[1].Id;
			scs.UserOrGroupId = mPortalUsers.get('Standard').Id;
			scs.AccessLevel = 'Read';
			insert scs;
			
			scs = new ServiceContractShare();
			scs.ParentId = sc60.Id;
			//scs.UserOrGroupId = usrs[1].Id;
			scs.UserOrGroupId = mPortalUsers.get('Standard').Id;
			scs.AccessLevel = 'Read';
			insert scs;
			
			scs = new ServiceContractShare();
			scs.ParentId = sc30.Id;
			//scs.UserOrGroupId = usrs[1].Id;
			scs.UserOrGroupId = mPortalUsers.get('Standard').Id;
			scs.AccessLevel = 'Read';
			insert scs;
 		
 		
	    	Test.startTest();
		 	SCExpirationEmailBatch expBatch = new SCExpirationEmailBatch();
			Database.ExecuteBatch(expBatch, 10);
		  	Test.stopTest();
 		}
    }
    
    static testMethod void testSCExpirationEmailSchedule() {
    	Test.startTest();
    	
   		SCExpirationEmailSchedule sch = new SCExpirationEmailSchedule();
   		sch.execute(null);
   		
   		Test.stopTest();
    }
}