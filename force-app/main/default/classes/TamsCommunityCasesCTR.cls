public with sharing class TamsCommunityCasesCTR {

    Public String caseCategory {get;set;}
    Public String caseType {get;set;}
    Public String Modality {get;set;}

    Public String SID {get;set;}
    public String nickName {get;set;}
    public String accountName {get;set;}
    public String subject {get;set;}
    public String status {get;set;}
    public String SRNumber {get;set;}
    public String caseNumber {get;set;}
    public String PMAttached {get;set;}
    public String FSRAttached {get;set;}
    public List<SelectOption> paginationSizeOptions{get;set;}
    public List<SelectOption> caseCategoryOptions{get;set;}
    public List<SelectOption> caseTypeOptions{get;set;}
    public List<SelectOption> statusOptions{get;set;}
    public List<SelectOption> fsrAttachedOptions{get;set;}
    public List<SelectOption> pmAttachedOptions{get;set;}
    public Map<String,String> sortByFields {get;set;}  
    public String orderBy {get;set;}
    public Case dummyCaseForFromDate {get;set;}
    public Case dummyCaseForToDate {get;set;}
    private String queryString;
    private String equipmentTypes = '\'Engineer Dispatch\',\'FMI\',\'Install\',\'Preventive Maintenance\',\'Solution Center Support\'';
    private String generalInquiryTypes = '\'Billing/Invoice\',\'Education & Training\',\'New User Request\',\'Service Contract\',\'Service Parts\',\'Update Account\',\'Web Support\'';
    private Set<String> equipmentStatuses = new Set<String> {'New', 'Scheduled', 'Billing Review', 'Closed','Working'};
    private Set<String> generalInquiryStatuses = new Set<String> {'New', 'Working', 'Canceled', 'Closed'};
    Public Integer size{get;set;} 
    Public Integer noOfRecords{get; set;}     
    public integer totalPages   {   get{
                                    return (Integer)Math.ceil((Decimal)noOfRecords / size);
                                    }
                                    set;
                                }

    public Integer pageNumber {
        get {
            return setCon.getPageNumber();
            }
        set;
    }    

    private final String OBJECT_NAME = 'Case';

    private List<Schema.FieldSetMember> fieldSetMembers;    
    public TamsCommunityCasesCTR(){
        System.debug('START:TamsCommunityCasesCTR');
        size = 20;
        paginationSizeOptions = new List<SelectOption>();
        paginationSizeOptions.add(new SelectOption('5','5'));
        paginationSizeOptions.add(new SelectOption('10','10'));
        paginationSizeOptions.add(new SelectOption('20','20'));
        paginationSizeOptions.add(new SelectOption('50','50'));
        paginationSizeOptions.add(new SelectOption('100','100'));

        caseCategoryOptions = new List<SelectOption>();
        caseCategoryOptions.add(new SelectOption('Equipment','Equipment'));
        caseCategoryOptions.add(new SelectOption('GeneralInquiry','General Inquiry'));
        caseTypeOptions = new List<SelectOption>();
        statusOptions = new List<SelectOption>();
        fsrAttachedOptions = new List<SelectOption>();
        pmAttachedOptions = new List<SelectOption>();
        fsrAttachedOptions.add(new SelectOption('All', 'All'));
        fsrAttachedOptions.add(new SelectOption('Yes', 'Yes'));
        fsrAttachedOptions.add(new SelectOption('No', 'No'));
        pmAttachedOptions.add(new SelectOption('All', 'All'));
        pmAttachedOptions.add(new SelectOption('Yes', 'Yes'));
        pmAttachedOptions.add(new SelectOption('No', 'No'));

        dummyCaseForFromDate = new Case();
        dummyCaseForToDate = new Case();
        sortByFields = new Map<String,String>();
        fieldSetMembers = new List<Schema.FieldSetMember>();
        caseCategory='Equipment';
        resetFilter();
        System.debug('END:TamsCommunityCasesCTR');

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
    
    public PageReference resetFilter(){
        System.debug('START:resetFilter');
        System.debug('caseCategory:'+caseCategory);
        sortByFields.clear();
        caseTypeOptions.clear();
        fieldSetMembers.clear();
        statusOptions.clear();
        statusOptions.add(new SelectOption('All', 'All'));
        Schema.DescribeFieldResult statusFieldResult = Case.Status.getDescribe();
        List<Schema.PicklistEntry> ple2 = statusFieldResult.getPicklistValues();
        for( Schema.PicklistEntry f : ple2){
            if(caseCategory =='Equipment' && equipmentStatuses.contains(f.getLabel())){
                statusOptions.add(new SelectOption(f.getLabel(), f.getValue()));
            }
            if(caseCategory == 'GeneralInquiry' && generalInquiryStatuses.contains(f.getLabel())){
                statusOptions.add(new SelectOption(f.getLabel(), f.getValue()));
            }
        }         

        Modality= '';
        dummyCaseForFromDate.Date_Case_Working__c=null;
        dummyCaseForToDate.Date_Case_Working__c=null;
        SID='';
        nickName='';
        accountName='';
        subject='';
        status='All';
        SRNumber='';
        caseNumber='';
        PMAttached='All';
        FSRAttached='All';
        caseType='All';

        fieldSetMembers = TamsFieldSetHelper.getFieldSetMembers(caseCategory+'_FS',OBJECT_NAME);        
        for(Schema.FieldSetMember fieldSetMember : fieldSetMembers){
            sortByFields.put(fieldSetMember.getFieldPath(),null);
        }
                
        
        caseTypeOptions.add(new SelectOption('All', 'All'));
        Schema.DescribeFieldResult typeFieldResult = Case.Type.getDescribe();
        List<Schema.PicklistEntry> ple = typeFieldResult.getPicklistValues();
        for( Schema.PicklistEntry f : ple){
            if(caseCategory=='Equipment' && equipmentTypes.contains(f.getLabel()) ||
               caseCategory=='GeneralInquiry' && generalInquiryTypes.contains(f.getLabel()) 
                ){
                caseTypeOptions.add(new SelectOption(f.getLabel(), f.getValue()));
            }
        }                 
        sortByField();
        
        return null;        
     } 

    public PageReference sortByField(){
        System.debug('START:sortByField');
        String fieldName = Apexpages.currentPage().getParameters().get('fieldName');
        System.debug('fieldName:'+fieldName);
        if(fieldName==null){
            fieldName = 'CaseNumber';
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
        queryString = queryString + ' FROM CASE WHERE Modality__c IN (\''+getContactModalities()+ '\') ';
        System.debug('queryString AFTER SELECT:'+queryString);

        
        if(caseType != '' || Modality != '' || dummyCaseForFromDate.Date_Case_Working__c != null||
           dummyCaseForToDate.Date_Case_Working__c != null || SID != '' || nickName != ''|| 
           accountName != null || subject != '' || status != ''|| 
           SRNumber != null || caseNumber != '' || PMAttached != '' || FSRAttached != ''
            ){
            queryString = queryString + ' AND ';
        }
        
        System.debug('AFTER ADDING WHERE queryString:'+queryString);
        if(caseType != 'All'){
            queryString = queryString + ' Type =\''+caseType+'\' AND';
        }

        if(caseType == 'All' && caseCategory =='Equipment'){
            queryString = queryString + ' Type IN ('+equipmentTypes+') AND';
        }

        if(caseType == 'All' && caseCategory =='GeneralInquiry'){
            queryString = queryString + ' Type IN ('+generalInquiryTypes+') AND';
        }

        if(Modality != ''){
            queryString = queryString + ' Modality__c like \'%'+Modality+'%\' AND';
        }

        if(dummyCaseForFromDate.Date_Case_Working__c != null && caseCategory == 'Equipment'){
            queryString = queryString + ' Incident_Date__c >= '+String.valueOf(dummyCaseForFromDate.Date_Case_Working__c)+' AND';
        }
        if(dummyCaseForFromDate.Date_Case_Working__c != null && caseCategory == 'GeneralInquiry'){
            queryString = queryString + ' CreatedDate >= '+String.valueOf(dummyCaseForFromDate.Date_Case_Working__c)+'T00:00:00Z AND';
        }

        if( dummyCaseForToDate.Date_Case_Working__c != null && caseCategory == 'Equipment'){
            
            queryString = queryString + ' Incident_Date__c <= '+String.valueOf(dummyCaseForToDate.Date_Case_Working__c.addDays(1))+' AND';
        }        

        if( dummyCaseForToDate.Date_Case_Working__c != null && caseCategory == 'GeneralInquiry'){
            
            queryString = queryString + ' CreatedDate <= '+String.valueOf(dummyCaseForToDate.Date_Case_Working__c.addDays(1))+'T00:00:00Z AND';
        }        

        if(SID != ''){
            queryString = queryString + ' Install_Base__r.SID_TAMS__c like \'%'+SID+'%\' AND';
        }        

        if(nickName != ''){
            queryString = queryString + ' Nickname__c like \'%'+nickName+'%\' AND';
        }

        if(accountName != ''){
            queryString = queryString + ' Account.Name like \'%'+accountName+'%\' AND';
        }

        if(subject != ''){
            queryString = queryString + ' subject like \'%'+subject+'%\' AND';
        }

        if(status != ''  && status != 'All'){
            queryString = queryString + ' status = \''+status+'\' AND';
        }

        if(SRNumber != ''){
            queryString = queryString + ' Oracle_SR_Number_TAMS__c like \'%'+SRNumber+'%\' AND';
        }

        if(caseNumber != ''){
            queryString = queryString + ' CaseNumber like \'%'+caseNumber+'%\' AND';
        }

        if(PMAttached != '' && PMAttached != 'All'){
            if(PMAttached == 'Yes' ){
                queryString = queryString + ' PM_Attached__c = TRUE AND';
            }
            else{
                queryString = queryString + ' PM_Attached__c = FALSE AND';
            }
        }

        if(FSRAttached != '' && FSRAttached != 'All'){

            if(FSRAttached == 'Yes' ){
                queryString = queryString + ' FSR_Attached__c = TRUE AND';
            }
            else{
                queryString = queryString + ' FSR_Attached__c = FALSE AND';
            }
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


    //Changes the size of pagination
    public PageReference refreshPageSize() {
         setCon.setPageSize(size);
         return null;
    }
 
    // Initialize setCon and return a list of record    
     
    public List<Case> getCases() {
         return (List<Case>) setCon.getRecords();
    }

    private String getContactModalities(){
        if(Test.isRunningTest()){
            return 'CT;MR;UL;VL;XR'.replaceAll(';','\',\'');
        }

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

}