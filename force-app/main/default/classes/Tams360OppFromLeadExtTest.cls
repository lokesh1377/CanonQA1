@isTest
private class Tams360OppFromLeadExtTest
{
	@isTest
	static void testCreateOpportunity()
	{
		Account acc = new Account(name='Test Account');
		acc.Territory_Name_TAMS__c = 'US.GL.2660100.TR-101';
		insert acc;
        Lead lead = createLead(acc.ID,'Test Lead','CT','2-Warm','Open');
		Contact contact = New Contact();
		contact.AccountId = acc.ID;
		contact.FirstName = lead.FirstName;
		contact.LastName = lead.LastName;
		insert contact;        
        Test.startTest();
        Tams360OppFromLeadExt.createOpportunity(lead.ID);
        Test.stopTest();
        Lead leadPostTest = [SELECT status,convertedOpportunityId From Lead WHERE id=:lead.ID];
        System.assert(leadPostTest.status == 'Closed - Converted' ,'Lead not coverted into Opportunity');
        System.assert(leadPostTest.convertedOpportunityId != null ,'Converted Opportunity id is NULL');
        if(leadPostTest.convertedOpportunityId != null){
        	Opportunity opp = [SELECT AccountId From Opportunity where Id = : leadPostTest.convertedOpportunityId];
        	System.assert(opp.AccountId == acc.ID,'Account ID is different on the Opportunity');
        	Contact contactPostTest = [SELECT email From Contact where ID = :contact.ID];
        	System.assert(contactPostTest.Email == lead.Email , 'Contact email not updated');
        }
	}

	@isTest
	static void testGetAllLeads()
	{
		Account acc1 = new Account(name='Test Account1');
        acc1.Territory_Name_TAMS__c = 'US.GL.2660100.TR-101';
        insert acc1;
        Lead lead1 = createLead(acc1.ID,'Test Lead1','CT','1-Hot','Open');
        Lead lead2 = createLead(acc1.ID,'Test Lead2','CT','1-Hot','Open');
        Lead lead3 = createLead(acc1.ID,'Test Lead3','MR','1-Hot','Open');
		Account acc2 = new Account(name='Test Account2');
        acc2.Territory_Name_TAMS__c = 'US.GL.2660100.TR-101';
        insert acc2;
        Lead lead4 = createLead(acc2.ID,'Test Lead4','CT','2-Warm','Open');
        Lead lead5 = createLead(acc2.ID,'Test Lead5','CT','2-Warm','Working');
        Lead lead6 = createLead(acc2.ID,'Test Lead6','MR','2-Warm','Working');        
        Test.startTest();
        List<Lead> leads = Tams360OppFromLeadExt.getLeads('Open;Working','All',null,null,'All','Rank');
        Test.stopTest();
        System.debug('leads.size:'+leads.size());
        //getLeads(String status, String modality, String leadName, String accountName,String rank, String sortBy){
        System.assert(leads.size() == 6, 'Not getting all eligible Leads');
	}

	@isTest
	static void testAccountSpecificLeads()
	{
		Account acc1 = new Account(name='Test Account1');
        acc1.Territory_Name_TAMS__c = 'US.GL.2660100.TR-101';
        insert acc1;
        Lead lead1 = createLead(acc1.ID,'Test Lead1','CT','1-Hot','Open');
        Lead lead2 = createLead(acc1.ID,'Test Lead2','CT','1-Hot','Open');
        Lead lead3 = createLead(acc1.ID,'Test Lead3','MR','1-Hot','Open');
		Account acc2 = new Account(name='Test Account2');
        acc2.Territory_Name_TAMS__c = 'US.GL.2660100.TR-101';
        insert acc2;
        Lead lead4 = createLead(acc2.ID,'Test Lead4','CT','2-Warm','Open');
        Lead lead5 = createLead(acc2.ID,'Test Lead5','CT','2-Warm','Working');
        Lead lead6 = createLead(acc2.ID,'Test Lead6','MR','2-Warm','Working');        
        Test.startTest();
        List<Lead> leads = Tams360OppFromLeadExt.getLeads('Open;Working','All',null,'Test Account1','All','Account Name');
        Test.stopTest();
        System.debug('leads.size:'+leads.size());
        //getLeads(String status, String modality, String leadName, String accountName,String rank, String sortBy){
        System.assert(leads.size() == 3, 'Not getting all eligible Leads (3 For specific Account)');
	}	

	@isTest
	static void testModalitySpecificLeads()
	{
		Account acc1 = new Account(name='Test Account1');
        acc1.Territory_Name_TAMS__c = 'US.GL.2660100.TR-101';
        insert acc1;
        Lead lead1 = createLead(acc1.ID,'Test Lead1','CT','1-Hot','Open');
        Lead lead2 = createLead(acc1.ID,'Test Lead2','CT','1-Hot','Open');
        Lead lead3 = createLead(acc1.ID,'Test Lead3','MR','1-Hot','Open');
		Account acc2 = new Account(name='Test Account2');
        acc2.Territory_Name_TAMS__c = 'US.GL.2660100.TR-101';
        insert acc2;
        Lead lead4 = createLead(acc2.ID,'Test Lead4','CT','2-Warm','Open');
        Lead lead5 = createLead(acc2.ID,'Test Lead5','CT','2-Warm','Working');
        Lead lead6 = createLead(acc2.ID,'Test Lead6','MR','2-Warm','Working');        
        Test.startTest();
        List<Lead> leads = Tams360OppFromLeadExt.getLeads('Open;Working','CT', null ,null,'All','Modality');
        Test.stopTest();
        System.debug('leads.size:'+leads.size());
        //getLeads(String status, String modality, String leadName, String accountName,String rank, String sortBy){
        System.assert(leads.size() == 4, 'Not getting all eligible Leads (4 Based on modality)');
	}		

	@isTest
	static void testStatusSpecificLeads()
	{
		Account acc1 = new Account(name='Test Account1');
        acc1.Territory_Name_TAMS__c = 'US.GL.2660100.TR-101';
        insert acc1;
        Lead lead1 = createLead(acc1.ID,'Test Lead1','CT','1-Hot','Open');
        Lead lead2 = createLead(acc1.ID,'Test Lead2','CT','1-Hot','Open');
        Lead lead3 = createLead(acc1.ID,'Test Lead3','MR','1-Hot','Open');
		Account acc2 = new Account(name='Test Account2');
        acc2.Territory_Name_TAMS__c = 'US.GL.2660100.TR-101';
        insert acc2;
        Lead lead4 = createLead(acc2.ID,'Test Lead4','CT','2-Warm','Open');
        Lead lead5 = createLead(acc2.ID,'Test Lead5','CT','2-Warm','Working');
        Lead lead6 = createLead(acc2.ID,'Test Lead6','MR','2-Warm','Working');        
        Test.startTest();
        List<Lead> leads = Tams360OppFromLeadExt.getLeads('Open','All', null ,null,'All','Status');
        Test.stopTest();
        System.debug('leads.size:'+leads.size());
        //getLeads(String status, String modality, String leadName, String accountName,String rank, String sortBy){
        System.assert(leads.size() == 4, 'Not getting all eligible Leads (4 Based on Status)');
	}

	@isTest
	static void testRankSpecificLeads()
	{
		Account acc1 = new Account(name='Test Account1');
        acc1.Territory_Name_TAMS__c = 'US.GL.2660100.TR-101';
        insert acc1;
        Lead lead1 = createLead(acc1.ID,'Test Lead1','CT','1-Hot','Open');
        Lead lead2 = createLead(acc1.ID,'Test Lead2','CT','1-Hot','Open');
        Lead lead3 = createLead(acc1.ID,'Test Lead3','MR','1-Hot','Open');
		Account acc2 = new Account(name='Test Account2');
        acc2.Territory_Name_TAMS__c = 'US.GL.2660100.TR-101';
        insert acc2;
        Lead lead4 = createLead(acc2.ID,'Test Lead4','CT','2-Warm','Open');
        Lead lead5 = createLead(acc2.ID,'Test Lead5','CT','2-Warm','Working');
        Lead lead6 = createLead(acc2.ID,'Test Lead6','MR','2-Warm','Working');        
        Test.startTest();
        List<Lead> leads = Tams360OppFromLeadExt.getLeads('Open;Working','All', null ,null,'1-Hot','Rank');
        Test.stopTest();
        System.debug('leads.size:'+leads.size());
        //getLeads(String status, String modality, String leadName, String accountName,String rank, String sortBy){
        System.assert(leads.size() == 3, 'Not getting all eligible Leads (3 Based on Rank)');
	}

	@isTest
	static void testLeadNameSpecificLeads()
	{
		Account acc1 = new Account(name='Test Account1');
        acc1.Territory_Name_TAMS__c = 'US.GL.2660100.TR-101';
        insert acc1;
        Lead lead1 = createLead(acc1.ID,'Test Lead1','CT','1-Hot','Open');
        Lead lead2 = createLead(acc1.ID,'Test Lead2','CT','1-Hot','Open');
        Lead lead3 = createLead(acc1.ID,'Test Lead3','MR','1-Hot','Open');
		Account acc2 = new Account(name='Test Account2');
        acc2.Territory_Name_TAMS__c = 'US.GL.2660100.TR-101';
        insert acc2;
        Lead lead4 = createLead(acc2.ID,'Test Lead4','CT','2-Warm','Open');
        Lead lead5 = createLead(acc2.ID,'Test Lead5','CT','2-Warm','Working');
        Lead lead6 = createLead(acc2.ID,'Test Lead6','MR','2-Warm','Working');        
        Test.startTest();
        List<Lead> leads = Tams360OppFromLeadExt.getLeads('Open;Working','All', 'Test Lead1' ,null,'All','@@@@Rank@@@@@');
        Test.stopTest();
        System.debug('leads.size:'+leads.size());
        //getLeads(String status, String modality, String leadName, String accountName,String rank, String sortBy){
        System.assert(leads.size() == 1, 'Not getting all eligible Leads (1 Based on Lead Name)');
	}

	private static Lead createLead(ID accountId, String leadName, String modality, String rank,String status ){
		Lead lead = new Lead();
        lead.FirstName = leadName;
        lead.LastName = leadName;
		lead.Primary_Modality_TAMS__c = modality;
        lead.LeadSource = '360 Sales Assist';
        lead.Existing_Account__c = accountId;
        lead.email = 'test@test.com';
        lead.Phone  = '111-111-1234';
        lead.PostalCode = '11111';
        lead.company = 'TAMS';
        lead.status = status;
        lead.recordTypeId = getRecordTypeId();
        lead.Rank_PIcklist__c = rank;
        insert lead;
        return lead;
	}

	private static ID getRecordTypeId(){
		List<RecordType> recordTypes = [
                                            SELECT
                                                ID,Name
                                            FROM
                                                RecordType
                                            WHERE sObjectType= 'Lead'
                                            AND name = '360 Sales Assist'
                                            LIMIT 1
                                            ];		
        if(recordTypes.size() == 1){
        	return recordTypes[0].ID;
        }                                    

        return null;
	}
}