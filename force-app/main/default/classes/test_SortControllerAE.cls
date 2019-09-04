@isTest
private class test_SortControllerAE 
{
    static testMethod void test_SortControllerAE() 
    {
        Account a = new Account();
        a.Name = 'Test';
        
        insert a;
        
        Opportunity o = new Opportunity();
        o.Name = 'Test';
        o.AccountId = a.id;
        o.Modality_TAMS__c = 'CT';
        o.Expected_Bill_Date_TAMS__c = Date.today() + 2;
        o.CloseDate =  Date.today()+1;
        o.StageName = 'Closed/Lost';
        o.Lost_Cancelled_Reason_TAMS__c = 'Functionality/Insufficient Technology';
        o.Competitor_Lost_to_TAMS__c = 'GE';
        o.LeadSource = 'Cold Call';
        o.Incumbent_TAMS__c = 'GE';
        o.Competitor_Lost_to_TAMS__c = 'GE';
        o.Is_this_Product_Funded_TAMS__c = 'Yes';
        o.Additional_Comments_TAMS__c = 'Test Comments';
        o.Actual_Book_Date_TAMS__c = Date.today();
        insert o;
        
        List<Opportunity> listOfOpps = new List<Opportunity>();
        listOfOpps.add(o);
        
        Test.setCurrentPageReference(Page.MassEditOppAE);
      
        ApexPages.StandardSetController con = new ApexPages.StandardSetController(listOfOpps); 
        con.setSelected(listOfOpps); 
      
        SortControllerAE sc = new SortControllerAE(con);    
        sc.setSortDirection('ASC');
        sc.ViewData();
        
        sc.setSortDirection('DESC');
        sc.ViewData();
    
        sc.SaveAll();
        
        System.Debug(sc.sortExpression);
    }
    
}