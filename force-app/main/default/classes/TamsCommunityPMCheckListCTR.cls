public with sharing class TamsCommunityPMCheckListCTR {

    Public String Modality {get;set;}
    Public String SID {get;set;}
    public String nickName {get;set;}
    public String accountName {get;set;}
    public String SRNumber {get;set;}
    public List<SelectOption> paginationSizeOptions{get;set;}

    public Map<String,String> sortByFields {get;set;}  
    public String orderBy {get;set;}
    public PM_Checklist__c dummyPMCheckListForFromDate {get;set;}
    public PM_Checklist__c dummyPMCheckListForToDate {get;set;}
    private String queryString;

    Public Integer pageSize{get;set;} 
    Public Integer totalRecords{get; set;}     
    public integer totalPages   {   get{
                                    return (Integer)Math.ceil((Decimal)totalRecords / pageSize);
                                    }
                                    set;
                                }

    public Integer pageNumber {
        get {
            return setCon.getPageNumber();
            }
        set;
    }    

    private final String OBJECT_NAME = 'PM_Checklist__c';

    private List<Schema.FieldSetMember> fieldSetMembers;    
    public TamsCommunityPMCheckListCTR(){
        System.debug('START:TamsCommunityPMCheckListCTR');
        pageSize = 20;
        paginationSizeOptions = new List<SelectOption>();
        paginationSizeOptions.add(new SelectOption('5','5'));
        paginationSizeOptions.add(new SelectOption('10','10'));
        paginationSizeOptions.add(new SelectOption('20','20'));
        paginationSizeOptions.add(new SelectOption('50','50'));
        paginationSizeOptions.add(new SelectOption('100','100'));


        dummyPMCheckListForFromDate = new PM_Checklist__c();
        dummyPMCheckListForToDate = new PM_Checklist__c();
        sortByFields = new Map<String,String>();
        fieldSetMembers = new List<Schema.FieldSetMember>();
        resetFilter();
        System.debug('END:TamsCommunityPMCheckListCTR');

    }
     
    public ApexPages.StandardSetController setCon {
        get {
            System.debug('START:setCon GET');
            System.debug('setCon:'+setCon);
            if(setCon == null) {                
                setCon = new ApexPages.StandardSetController(Database.getQueryLocator(queryString));
                setCon.setPageSize(pageSize);  
                totalRecords = setCon.getResultSize();
            }            
            System.debug('END:setCon GET');
            return setCon;
        }
        set;
    }
    
    public PageReference resetFilter(){
        System.debug('START:resetFilter');
        sortByFields.clear();
        fieldSetMembers.clear();
        Modality= '';
        SRNumber='';
        dummyPMCheckListForFromDate.Dummy_Date__c = null;
        dummyPMCheckListForToDate.Dummy_Date__c = null;
        SID='';
        nickName='';
        accountName='';

        fieldSetMembers = TamsFieldSetHelper.getFieldSetMembers('PM_CHECKLIST_FS',OBJECT_NAME);        
        for(Schema.FieldSetMember fieldSetMember : fieldSetMembers){
            sortByFields.put(fieldSetMember.getFieldPath(),null);
        }
                
        
       sortByField();
        
        return null;        
     } 

    public PageReference sortByField(){
        System.debug('START:sortByField');
        String fieldName = Apexpages.currentPage().getParameters().get('fieldName');
        System.debug('fieldName:'+fieldName);
        if(fieldName==null){
            fieldName = 'Name';
        }

        String currentSortingOrder = sortByFields.get(fieldName);
        System.debug('currentSortingOrder:'+currentSortingOrder);
        if(currentSortingOrder==null){
            sortByFields.put(fieldName,'DESC');
        }else{
            if(currentSortingOrder=='ASC'){
                sortByFields.put(fieldName,'DESC');
            }
            else{
                sortByFields.put(fieldName,'ASC');
            }
        }
        orderBy = fieldName + ' ' + sortByFields.get(fieldName);       
        System.debug('orderBy:'+orderBy);  
        filter();
        return null;        
     }        


    public PageReference filter(){
        System.debug('START:filter');
        queryString = ' SELECT ';
        for(Schema.FieldSetMember fieldSetMember : fieldSetMembers){
            if(sortByFields.size() == 0){
            //First time add all fields    
                sortByFields.put(fieldSetMember.getFieldPath(),null);
            }
            queryString = queryString + fieldSetMember.getFieldPath() + ',';
        }        
        queryString = queryString.removeEnd(',');
        queryString = queryString + ' FROM PM_Checklist__c WHERE IB_lookup__r.Active_IB__c = true AND IB_lookup__r.Modality_ALL__c IN (\''+getContactModalities()+ '\') ';
        System.debug('queryString AFTER SELECT:'+queryString);

        
        if(Modality != '' ||
            dummyPMCheckListForFromDate.Dummy_Date__c != null||
           dummyPMCheckListForToDate.Dummy_Date__c != null || 
           SID != '' || 
           nickName != ''|| 
           accountName != ''|| 
           SRNumber != '' 
            ){
            queryString = queryString + ' AND ';
        }
        
        System.debug('AFTER ADDING WHERE queryString:'+queryString);
        System.debug('Modality:'+Modality);
        System.debug('dummyPMCheckListForFromDate.Dummy_Date__c:'+dummyPMCheckListForFromDate.Dummy_Date__c);
        System.debug('dummyPMCheckListForToDate.Dummy_Date__c:'+dummyPMCheckListForToDate.Dummy_Date__c);
        System.debug('SID:'+SID);
        System.debug('nickName:'+nickName);
        System.debug('accountName:'+accountName);
        System.debug('SRNumber:'+SRNumber);
        if(Modality != ''){
            queryString = queryString + ' Modality__c like \'%'+Modality+'%\' AND';
        }

        if(dummyPMCheckListForFromDate.Dummy_Date__c != null ){
            queryString = queryString + ' Case_Date_Time_Closed__c >= '+String.valueOf(dummyPMCheckListForFromDate.Dummy_Date__c)+'T00:00:00Z AND';
        }

        if( dummyPMCheckListForToDate.Dummy_Date__c != null ){
            
            queryString = queryString + ' Case_Date_Time_Closed__c <= '+String.valueOf(dummyPMCheckListForToDate.Dummy_Date__c.addDays(1))+'T00:00:00Z AND';
        }        


        if(SID != '' ){
            queryString = queryString + ' SID_TAMS__c like \'%'+SID+'%\' AND';
        }        

        if(nickName != ''){
            queryString = queryString + ' Nickname__c like \'%'+nickName+'%\' AND';
        }

        if(accountName != '' ){
            queryString = queryString + ' Account__c like \'%'+accountName+'%\' AND';
        }

        if(SRNumber != '' ){
            queryString = queryString + ' Oracle_SR_Number__c like \'%'+SRNumber+'%\' AND';
        }

        System.debug('BEFORE REMOVING AND queryString:'+queryString);
        queryString = queryString.removeEnd(' AND');
        System.debug('AFTER REMOVING AND queryString:'+queryString);
        queryString = queryString + ' ORDER BY '+ orderBy;
        System.debug('AFTER ORDER BY queryString:'+queryString);
        queryString = queryString + ' LIMIT 9999';
        setCon = null; 
        System.debug('END:filter');
        
        return null;
    } 

    private String getContactModalities(){
        List<User> currUser = [SELECT ContactId,Contact.Modality__c From User where Id = :UserInfo.getUserId() LIMIT 1];
        System.debug('currUser.size():'+currUser.size());
        if(currUser.size()==0){
            return 'XXXX';
        }
        else{
            if(currUser[0].contact == null || currUser[0].contact.Modality__c == null){ 
	            System.debug('Modality__c:'+currUser[0].contact.Modality__c);
	            System.debug('ContactId:'+currUser[0].ContactId);
	            return 'XXXX';
	          }
	          else{
	            	return currUser[0].contact.Modality__c.replaceAll(';','\',\'');
	          }
            
        }
    }

    //Changes the size of pagination
    public PageReference refreshPageSize() {
         setCon.setPageSize(pageSize);
         return null;
    }
 
    // Initialize setCon and return a list of record    
     
    public List<PM_Checklist__c> getPMCheckLists() {
         return (List<PM_Checklist__c>) setCon.getRecords();
    }



}