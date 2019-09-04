@IsTest 
public with sharing class MyPreferencesControllerTest {
	
	static testMethod void testMyPreferencesController() {
		MyPreferencesEmailList__c pref = new MyPreferencesEmailList__c();
		pref.Name = 'Test';
		insert pref;

		Test.startTest();
       	PageReference pageRef = Page.MyPreferences;
		Test.setCurrentPage(pageRef);    
    

    	MyPreferencesController controller = new MyPreferencesController();
    	controller.myEmailPref[0].Is_Opt_Out__c = true;

    	controller.save();
    	
    	
    	List<TAMS_Email_Opt_In_Out__c> myOptOut = [select Id, Email__c, Is_Opt_Out__c from TAMS_Email_Opt_In_Out__c where User__c =: UserInfo.getUserId()];
    	
    	System.AssertEquals(myOptOut[0].Is_Opt_Out__c, true);
    	
    	controller = new MyPreferencesController();
    	controller.myEmailPref[0].Is_Opt_Out__c = false;

    	controller.save();
    	
    	
    	myOptOut = [select Id, Email__c, Is_Opt_Out__c from TAMS_Email_Opt_In_Out__c where User__c =: UserInfo.getUserId()];
    	
    	System.AssertEquals(myOptOut.size(), 0);
    	
    	
    	Test.stopTest();

    }
	

}