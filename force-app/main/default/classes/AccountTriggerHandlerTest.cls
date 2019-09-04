/*********************************************************
        Author:Lokesh Tigulla         
        Purpose: This testClass is for Account Trigger Handler.        
        1.0 - Lokesh Tigulla - 07/10/2019 - Created
**********************************************************/
@isTest private class AccountTriggerHandlerTest{

  @testsetup static void testData(){

      Profile profileId = [SELECT Id FROM Profile WHERE Name = 'Standard User' LIMIT 1];

        User usr = new User();
           usr.LastName = 'Canon';
           usr.FirstName='Canon';
           usr.Alias = 'jliv';
           usr.Email = 'CastIron.Canon@us.medical.canon.com';
           usr.Username = 'CastIron.Canon@us.medical.canon.com';
           usr.ProfileId = profileId.id;
           usr.TimeZoneSidKey = 'GMT';
           usr.LanguageLocaleKey = 'en_US';
           usr.EmailEncodingKey = 'UTF-8';
           usr.LocaleSidKey = 'en_US';
           insert usr;

     Account acc = new Account();
          Id recordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('TAMS Account').getRecordTypeId();
          acc.RecordTypeId = recordTypeId;
          acc.TAMS_Account_Number_TAMS__c = '123';
          acc.Name = 'Test123';
          acc.CT_ZBM_Acc__c = usr.id;
          insert acc;
 }

   @isTest static void aftertriggertest(){
          Account accCT = [Select Id,Name,CT_ZBM_Acc__c,TAMS_Account_Number_TAMS__c From Account Where TAMS_Account_Number_TAMS__c = '123' Limit 1];
          update accCT;
          system.assertequals('123',accCT.TAMS_Account_Number_TAMS__c);

   }
    @isTest static void aftertriggerMRtest(){
      Profile profileId = [SELECT Id FROM Profile WHERE Name = 'Standard User' LIMIT 1];
           User usr = new User();
           usr.LastName = 'CanonMR';
           usr.FirstName='CanonMR';
           usr.Alias = 'jliv';
           usr.Email = 'MR.Canon@us.medical.canon.com';
           usr.Username = 'MR.Canon@us.medical.canon.com';
           usr.ProfileId = profileId.id;
           usr.TimeZoneSidKey = 'GMT';
           usr.LanguageLocaleKey = 'en_US';
           usr.EmailEncodingKey = 'UTF-8';
           usr.LocaleSidKey = 'en_US';
           insert usr;

           Account acc1 = new Account();
          acc1.TAMS_Account_Number_TAMS__c = '456';
          acc1.Name = 'Test456'; 
          insert acc1;

          acc1.MR_ZBM_Acc__c = usr.id;
          update acc1;

          system.assertequals('456',acc1.TAMS_Account_Number_TAMS__c);

   }
    @isTest static void aftertriggerULtest(){
      Profile profileId = [SELECT Id FROM Profile WHERE Name = 'Standard User' LIMIT 1];
           User usr = new User();
           usr.LastName = 'CanonUL';
           usr.FirstName='CanonUL';
           usr.Alias = 'jliv';
           usr.Email = 'UL.Canon@us.medical.canon.com';
           usr.Username = 'UL.Canon@us.medical.canon.com';
           usr.ProfileId = profileId.id;
           usr.TimeZoneSidKey = 'GMT';
           usr.LanguageLocaleKey = 'en_US';
           usr.EmailEncodingKey = 'UTF-8';
           usr.LocaleSidKey = 'en_US';
           insert usr;

           Account acc1 = new Account();
          acc1.TAMS_Account_Number_TAMS__c = '789';
          acc1.Name = 'TestUL789'; 
          insert acc1;

          acc1.UL_ZBM_Acc__c = usr.id;
          update acc1;

          system.assertequals('789',acc1.TAMS_Account_Number_TAMS__c);

   }

    @isTest static void aftertriggerULcartest(){
      Profile profileId = [SELECT Id FROM Profile WHERE Name = 'Standard User' LIMIT 1];
           User usr = new User();
           usr.LastName = 'CanonULcar';
           usr.FirstName='CanonULcar';
           usr.Alias = 'jliv';
           usr.Email = 'ULcar.Canon@us.medical.canon.com';
           usr.Username = 'ULcar.Canon@us.medical.canon.com';
           usr.ProfileId = profileId.id;
           usr.TimeZoneSidKey = 'GMT';
           usr.LanguageLocaleKey = 'en_US';
           usr.EmailEncodingKey = 'UTF-8';
           usr.LocaleSidKey = 'en_US';
           insert usr;

           Account acc1 = new Account();
          acc1.TAMS_Account_Number_TAMS__c = '12';
          acc1.Name = 'TestULcar12'; 
          insert acc1;

          acc1.UL_ZBM_Acc_Cardiology__c = usr.id;
          update acc1;

          system.assertequals('12',acc1.TAMS_Account_Number_TAMS__c);

   }
   @isTest static void aftertriggerXRtest(){
      Profile profileId = [SELECT Id FROM Profile WHERE Name = 'Standard User' LIMIT 1];
           User usr = new User();
           usr.LastName = 'CanonXR';
           usr.FirstName='CanonXR';
           usr.Alias = 'jliv';
           usr.Email = 'XR.Canon@us.medical.canon.com';
           usr.Username = 'XR.Canon@us.medical.canon.com';
           usr.ProfileId = profileId.id;
           usr.TimeZoneSidKey = 'GMT';
           usr.LanguageLocaleKey = 'en_US';
           usr.EmailEncodingKey = 'UTF-8';
           usr.LocaleSidKey = 'en_US';
           insert usr;

           Account acc1 = new Account();
          acc1.TAMS_Account_Number_TAMS__c = '45';
          acc1.Name = 'TestXR12'; 
          insert acc1;

          acc1.XR_VL_ZBM_Acc__c = usr.id;
          update acc1;

          system.assertequals('45',acc1.TAMS_Account_Number_TAMS__c);

   }
    @isTest static void aftertriggernulltest(){
      Profile profileId = [SELECT Id FROM Profile WHERE Name = 'Standard User' LIMIT 1];
           User usr = new User();
           usr.LastName = 'CanonXR';
           usr.FirstName='CanonXR';
           usr.Alias = 'jliv';
           usr.Email = 'XR.Canon@us.medical.canon.com';
           usr.Username = 'XR.Canon@us.medical.canon.com';
           usr.ProfileId = profileId.id;
           usr.TimeZoneSidKey = 'GMT';
           usr.LanguageLocaleKey = 'en_US';
           usr.EmailEncodingKey = 'UTF-8';
           usr.LocaleSidKey = 'en_US';
           insert usr;

           Account acc1 = new Account();
          acc1.TAMS_Account_Number_TAMS__c = '01';
          acc1.Name = 'Test01'; 
          insert acc1;

          acc1.CT_ZBM_Acc__c = null;
          update acc1;

          system.assertequals('01',acc1.TAMS_Account_Number_TAMS__c);

   }
}