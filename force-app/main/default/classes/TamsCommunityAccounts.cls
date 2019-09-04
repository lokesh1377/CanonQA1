public with sharing class TamsCommunityAccounts {
    Public Integer size{get;set;} 
    Public Integer noOfRecords{get; set;} 
    public List<SelectOption> paginationSizeOptions{get;set;}
    public String filterByCity {get;set;}
    public String filterByState {get;set;}  
    public String filterByName {get;set;}
    private String nameSortingOrder ;
    private String citySortingOrder ;
    private String stateSortingOrder ;
    private String zipSortingOrder ;

    public List<SelectOption> orderByOptions{get;set;}
    public String orderBy {get;set;}
    private String queryString;   
    public TamsCommunityAccounts(){
        System.debug('START:TamsCommunityAccounts');
        size=20;
        paginationSizeOptions = new List<SelectOption>();
        paginationSizeOptions.add(new SelectOption('5','5'));
        paginationSizeOptions.add(new SelectOption('10','10'));
        paginationSizeOptions.add(new SelectOption('20','20'));
        paginationSizeOptions.add(new SelectOption('50','50'));
        paginationSizeOptions.add(new SelectOption('100','100'));
        orderByOptions = new List<SelectOption>();
        orderByOptions.add(new SelectOption('Name','Account Name'));
        orderByOptions.add(new SelectOption('ShippingCity','City'));
        orderByOptions.add(new SelectOption('ShippingState','State'));
        
        filterByCity ='';
        filterByState ='';
        filterByName ='';
        sortByName();
        System.debug('END:TamsCommunityAccounts');

    }
     
    public ApexPages.StandardSetController setCon {
        get {
            System.debug('START:setCon GET');
            System.debug('setCon:'+setCon);
            if(setCon == null) {                
                setCon = new ApexPages.StandardSetController(Database.getQueryLocator(queryString));
                setCon.setPageSize(size);  
                noOfRecords = setCon.getResultSize();
            }            
            System.debug('END:setCon GET');
            return setCon;
        }
        set;
    }
    
    public PageReference clearFilter(){
        System.debug('START:clearFilter');
        filterByCity ='';
        filterByState ='';
        filterByName ='';
        nameSortingOrder = null;
        sortByName();
        return null;        
     } 

    public PageReference sortByName(){
        if(nameSortingOrder==null){
            nameSortingOrder = 'ASC';
        }else{
            if(nameSortingOrder=='ASC'){
                nameSortingOrder = 'DESC';
            }
            else{
                nameSortingOrder = 'ASC';   
            }
        }
        orderBy = 'Name '+nameSortingOrder;         
        citySortingOrder = null;
        stateSortingOrder = null;
        zipSortingOrder = null;
        filter();
        return null;        
     }        

    public PageReference sortByCity(){
        if(citySortingOrder==null){
            citySortingOrder = 'ASC';
        }else{
            if(citySortingOrder=='ASC'){
                citySortingOrder = 'DESC';
            }
            else{
                citySortingOrder = 'ASC';   
            }
        }
        orderBy = 'ShippingCity '+citySortingOrder;
        nameSortingOrder = null;
        stateSortingOrder = null;
        zipSortingOrder = null;
        filter();
        return null;        
     }        

    public PageReference sortByState(){
        if(stateSortingOrder==null){
            stateSortingOrder = 'ASC';
        }else{
            if(stateSortingOrder == 'ASC'){
                stateSortingOrder = 'DESC';
            }
            else{
                stateSortingOrder = 'ASC';   
            }
        }
        orderBy = 'ShippingState '+stateSortingOrder;
        nameSortingOrder = null;
        citySortingOrder = null;
        zipSortingOrder = null;
        filter();
        return null;        
     }        

    public PageReference sortByZip(){
        if(zipSortingOrder==null){
            zipSortingOrder = 'ASC';
        }else{
            if(zipSortingOrder=='ASC'){
                zipSortingOrder = 'DESC';
            }
            else{
                zipSortingOrder = 'ASC';   
            }
        }
        orderBy = 'ShippingPostalCode '+zipSortingOrder;         
        citySortingOrder = null;
        stateSortingOrder = null;
        nameSortingOrder = null;
        filter();
        return null;        
     }                       
    public PageReference filter(){
        System.debug('START:filter');
        queryString = 'Select id,Name,ShippingStreet,ShippingCity,ShippingState,ShippingPostalCode from Account ';
        if(filterByCity != '' || filterByName != '' || filterByState != ''){
            queryString = queryString + ' WHERE ';
        }

        System.debug('AFTER ADDING WHERE queryString:'+queryString);
        if(filterByCity != ''){
            queryString = queryString + ' ShippingCity like \'%'+filterByCity+'%\' AND';
        }

        if(filterByState != ''){
            queryString = queryString + ' ShippingState like \'%'+filterByState+'%\' AND';
        }

        if(filterByName != ''){
            queryString = queryString + ' Name like \'%'+filterByName+'%\' AND';
        }
        System.debug('BEFORE REMOVING AND queryString:'+queryString);
        queryString = queryString.removeEnd(' AND');
        System.debug('AFTER REMOVING AND queryString:'+queryString);
        queryString = queryString + ' ORDER BY '+ orderBy;
        System.debug('AFTER ORDER BY queryString:'+queryString);
        queryString = queryString + ' LIMIT 999';
        setCon = null; 
        System.debug('END:filter');
        return null;
    } 

    //Changes the size of pagination
    public PageReference refreshPageSize() {
         setCon.setPageSize(size);
         return null;
    }
 
    // Initialize setCon and return a list of record    
     
    public List<Account> getAccounts() {
         return (List<Account>) setCon.getRecords();
    }

}