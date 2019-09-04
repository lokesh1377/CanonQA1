public class SortControllerAE extends SortController
{
    public String FieldList {set;get;}  
    private ApexPages.StandardSetController con;
    private String retUrl;
    private PageReference cancel;
    
    public SortControllerAE(ApexPages.StandardSetController controller) 
    {
        ApexPages.currentPage().getHeaders().put('X-UA-Compatible', 'IE=10,IE=9,IE=8');
        con = controller;
        
        if(ApexPages.currentPage().getParameters().get('retURL') != null)
            retUrl = ApexPages.currentPage().getParameters().get('retURL');
        // updated By Lokesh Tigulla
         this.cancel  =  controller.cancel(); 
            
        InitFieldList();
        sortExpression = 'Account.Name';
        Opps = getFilteredList();
    }   

    private void InitFieldList()
    {
        // Initialize setup variables
        FieldList = '';
        
        String objectName = 'Opportunity';
        Map<String, Schema.SObjectField> objectFields = Schema.getGlobalDescribe().get(objectName).getDescribe().fields.getMap();
         
        // Grab the fields from the describe method and append them to the queryString one by one.
        for(String s : objectFields.keySet())   
        {
           FieldList += s + ',';
        }
        
        // Strip off the last comma if it exists.
        FieldList = FieldList.subString(0, FieldList.Length()-1);
         
    }
    
    private List<Opportunity> getFilteredList()
    {
        Set<Id> setOfOpps = new Set<Id>();

        // do something with the selected records
        for ( Opportunity o : (Opportunity[])con.getSelected() )
        {
            setOfOpps.add(o.Id);
        }

        Query = 'SELECT ' + FieldList + ' FROM Opportunity ';
        Query += 'WHERE Id IN :setOfOpps ';
        Query += 'ORDER BY ';       

        //build the full sort expression
        String sortFullExp = sortExpression  + ' ' + getSortDirection();
      
        //query the database based on the sort expression
        System.debug('Query = ' + (Query + sortFullExp + ' limit 1000'));
        Opps = Database.query(Query + sortFullExp + ' limit 1000');
        
        return(Opps);               
    }
    
    public PageReference SaveAll()
    {
        List<Opportunity> updates = new List<Opportunity>();
        
        for(Opportunity o : Opps)
        {
            updates.add(o); 
        }   
        
        try
        {
            update(updates);
        }
        catch(dmlexception de)
        {
           //HK added on 5/22/2014
           ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR, de.getdmlMessage(0)));
           return( null );           
           System.debug('Error =' + de.getMessage());  
        }
       /*
        updated By Lokesh Tigulla 
        pageReference p;        
         if(! Test.isRunningTest())                
            p = new PageReference(retUrl);*/
            
        return(cancel);
    }
    
    public PageReference ViewData() 
    {    
        Opps = getFilteredList();
        return( null );
    }

    
}