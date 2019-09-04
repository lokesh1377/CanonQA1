public with sharing class TamsCommunityEquipmentsCTR {

    Public String Modality {get;set;}

    Public String SID {get;set;}
    public String nickName {get;set;}
    public String accountName {get;set;}
    public List<SelectOption> paginationSizeOptions{get;set;}

    public Map<String,String> sortByFields {get;set;}  
    public String orderBy {get;set;}
    public Install_Base_TAMS__c dummyEquipmentForFromDate {get;set;}
    public Install_Base_TAMS__c dummyEquipmentForToDate {get;set;}
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

    private final String OBJECT_NAME = 'Install_Base_TAMS__c';

    private List<Schema.FieldSetMember> fieldSetMembers;    
    public TamsCommunityEquipmentsCTR(){
        System.debug('START:TamsCommunityEquipmentsCTR');
        pageSize = 20;
        paginationSizeOptions = new List<SelectOption>();
        paginationSizeOptions.add(new SelectOption('5','5'));
        paginationSizeOptions.add(new SelectOption('10','10'));
        paginationSizeOptions.add(new SelectOption('20','20'));
        paginationSizeOptions.add(new SelectOption('50','50'));
        paginationSizeOptions.add(new SelectOption('100','100'));


        dummyEquipmentForFromDate = new Install_Base_TAMS__c();
        dummyEquipmentForToDate = new Install_Base_TAMS__c();
        sortByFields = new Map<String,String>();
        fieldSetMembers = new List<Schema.FieldSetMember>();
        resetFilter();
        System.debug('END:TamsCommunityEquipmentsCTR');

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
        dummyEquipmentForFromDate.Install_Date_TAMS__c = null;
        dummyEquipmentForToDate.Install_Date_TAMS__c = null;
        SID='';
        nickName='';
        accountName='';

        fieldSetMembers = TamsFieldSetHelper.getFieldSetMembers('EQUIPMENT_FS',OBJECT_NAME);        
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
        queryString = queryString + ' FROM Install_Base_TAMS__c WHERE Active_IB__c = true AND Modality_ALL__c IN (\''+getContactModalities()+ '\') ';
        System.debug('queryString AFTER SELECT:'+queryString);

        
        if(Modality != '' ||
            dummyEquipmentForFromDate.Install_Date_TAMS__c != null||
           dummyEquipmentForToDate.Install_Date_TAMS__c != null || 
           SID != '' || 
           nickName != ''|| 
           accountName != '' 
            ){
            queryString = queryString + ' AND ';
        }
        
        System.debug('AFTER ADDING WHERE queryString:'+queryString);
        System.debug('Modality:'+Modality);
        System.debug('dummyEquipmentForFromDate.Install_Date_TAMS__c:'+dummyEquipmentForFromDate.Install_Date_TAMS__c);
        System.debug('dummyEquipmentForToDate.Install_Date_TAMS__c:'+dummyEquipmentForToDate.Install_Date_TAMS__c);
        System.debug('SID:'+SID);
        System.debug('nickName:'+nickName);
        System.debug('accountName:'+accountName);
        if(Modality != ''){
            queryString = queryString + ' Modality_ALL__c like \'%'+Modality+'%\' AND';
        }

        if(dummyEquipmentForFromDate.Install_Date_TAMS__c != null ){
            queryString = queryString + ' Install_Date_TAMS__c >= '+String.valueOf(dummyEquipmentForFromDate.Install_Date_TAMS__c)+' AND';
        }

        if( dummyEquipmentForToDate.Install_Date_TAMS__c != null ){
            
            queryString = queryString + ' Install_Date_TAMS__c <= '+String.valueOf(dummyEquipmentForToDate.Install_Date_TAMS__c.addDays(1))+' AND';
        }        


        if(SID != '' ){
            queryString = queryString + ' SID_TAMS__c like \'%'+SID+'%\' AND';
        }        

        if(nickName != ''){
            queryString = queryString + ' Nickname__c like \'%'+nickName+'%\' AND';
        }

        if(accountName != '' ){
            queryString = queryString + ' Account_Name__r.Name like \'%'+accountName+'%\' AND';
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
     
    public List<Install_Base_TAMS__c> getEquipments() {
         return (List<Install_Base_TAMS__c>) setCon.getRecords();
    }



}