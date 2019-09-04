@isTest 
Private class TaskTriggerHandlerTest{

@testsetup static void testData() {
		// Implement test code
          Account acc = new Account();
          Id recordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('TAMS Account').getRecordTypeId();
          acc.RecordTypeId = recordTypeId;
          acc.TAMS_Account_Number_TAMS__c = '54321';
          acc.Name = 'Test123';
          insert acc;

          Install_Base_TAMS__c eqip = new Install_Base_TAMS__c();
          eqip.Account_Name__c = acc.id;
          eqip.SID_TAMS__c = '123456';
          insert eqip;

          Campaign cam = new Campaign();
          cam.Installed_Base_TAMS__c = eqip.Id;
          cam.Name = 'testcam';
          insert cam;

          Equip_Upgrade__c equipupgrade = new Equip_Upgrade__c();
          equipupgrade.Equp_Equipment__c = eqip.Id;
          equipupgrade.Equp_Campaign__c = cam.Id;
          insert equipupgrade;

          Profile p = [Select Id From Profile where Name = : 'System Administrator'];   
            User u            = new User();
            u.LastName          = 'test321';
            u.Alias             = 'test321';
            u.Email             = 'test321@toshiba.com';
            u.Username          = 'test321@toshiba.com';
            u.CommunityNickname = 'test321';
            u.EmailEncodingKey  = 'UTF-8';
            u.LanguageLocaleKey = 'en_US';
            u.ProfileId         =  p.Id;
            u.TimeZoneSidKey    = 'America/Los_Angeles';
            u.LocaleSidKey      = 'en_US';
            u.dealer__c         = false;
            u.isActive          = true;
            insert u;

          contact con = new contact();
           con.AccountId = acc.id;
            con.FirstName='fname';
            con.LastName = 'lname';
            con.Email = 'email@Canon.com';
           insert con;

           TAMS_Affiliation__c tamsaff = new TAMS_Affiliation__c();
           tamsaff.Account__c = acc.Id;
           tamsaff.Contact__c = con.id;
           tamsaff.User__c = u.Id;
           insert tamsaff;

           Task task = new Task();
           task.WhatId = equipupgrade.id;
           task.WhoId = con.Id;
           task.Description = 'test';
           insert task;
}

    @isTest static void createtaskTest(){
        List<Task> ltask = [Select Id,WhatId,WhoId From Task];
        TaskTriggerHandler.createTask(ltask);
        List<Install_Base_TAMS__c> leqip = [Select Id,SID_TAMS__c from Install_Base_TAMS__c Where SID_TAMS__c = '123456'];
         System.assertEquals('123456',leqip.get(0).SID_TAMS__c);
   }
}