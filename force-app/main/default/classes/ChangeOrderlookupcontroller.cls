/*********************************************************
        Author:Lokesh Tigulla         
        Purpose: This Class is used for Custom Lookup.        
        1.0 - Lokesh Tigulla              - Created
        1.1 - Lokesh Tigulla - 01/19/2019 - updated
**********************************************************/
public with sharing class ChangeOrderlookupcontroller {
  @TestVisible
  private String query;
  public String SObjectName;
  public String fieldName;
  @TestVisible
  private String partialQuery;
  public Boolean render1 {get;set;}
  public Map<String,String> mColumnsDisplay {get;set;}
  List < resultWrapper > records = new List < resultWrapper > ();
  public list <dynamicWrapper> lDynamicWrapper {get;set;}
  public List<String> lLabel {get;set;}
  public String searchvalue {get;set;}
  public String orderby {get;set;}
    public ChangeOrderlookupcontroller() {
        try {
            lDynamicWrapper = new List<dynamicWrapper>();
            lLabel = new List<String>();
            searchvalue = ApexPages.currentPage().getParameters().get('parentname');
            String id = ApexPages.currentPage().getParameters().get('parentid');
            this.SObjectName = ApexPages.currentPage().getParameters().get('sObject');
            this.fieldName = ApexPages.currentPage().getParameters().get('fieldName');
            this.partialQuery = ApexPages.currentPage().getParameters().get('query');
            String lColumns = ApexPages.currentPage().getParameters().get('listofcolumns');
            String orderby = ApexPages.currentPage().getParameters().get('orderBy');
            System.debug('partialQuery'+partialQuery);
            System.debug('searchvalue'+searchvalue);
            System.debug('SObjectName'+SObjectName);
            System.debug('fieldName'+fieldName);
            System.debug('orderby'+orderby);           
            mColumnsDisplay =  new Map<String,String>();
            String[] resultantColumns = lColumns.split(';');
            System.debug('**columns'+resultantColumns);
            for(String resultantColumn : resultantColumns){
                String[] namelabelpair = resultantColumn.split(':');
                mColumnsDisplay.put(namelabelpair[0],namelabelpair[1]);
            }
            System.debug('mColumnsDisplay'+mColumnsDisplay);
            query = partialQuery +' like \'' +searchvalue + '%' + '\' order by '+orderby+' asc limit 200';
            System.debug('***query'+query);
            if (String.IsNotBlank(searchvalue)) {
                render1 = true;
                //Database.query('SELECT Id FROM MyCustomObject__c WHERE Name = :myTestString')
                List<sObject> resultRecord = Database.query(query);
                if(resultRecord.size() > 0){
                  for(sObject rec: resultRecord){
                    //records.add(new resultWrapper(String.valueOf(rec.getSObject(SObjectName).get('Id')),String.valueOf(rec.getSObject(SObjectName).get('Name')), String.valueOf(rec.get('Description__c'))));
                    List<String> lValues = new List<String>();
                    lLabel = mColumnsDisplay.values();
                    for(String key:mColumnsDisplay.keySet()){
                        if(key != fieldName){
                          if(key == 'CMSU_Booked_Date__c' && SObjectName == 'Order_Master__c'){
                              Date dt = Date.valueOf(rec.get(key));
                              System.debug('dt'+dt);
                              if(dt != null){
                                System.debug('dt:'+dt);
                                lValues.add(dt.format());
                              }else{
                                lValues.add(' ');
                              }

                          }else if(key == 'Order_Subtotal__c' && SObjectName == 'Order_Master__c'){
                              Decimal amt = Decimal.valueOf(String.valueOf(rec.get(key)));
                              List<String> args = new String[]{'0','number','###,###,##0.00'};
                              if(amt != null){
                                lValues.add('$'+String.format(amt.format(), args));
                              }
                          }
                          else{
                          if(rec != null){
                              if(key.contains('.')){
                                String[] splitRec = key.split('\\.');
                                SObject childObject = rec.getSObject(splitRec[0]);
                                String value = String.valueOf(childObject.get(splitRec[1]));
                                if(value != null){
                                  lValues.add(value);
                                }else {
                                  lValues.add(' ');
                                }

                              }else{
                                if(rec.get(key) != null){
                                  lValues.add(String.valueOf(rec.get(key)));
                                }else{
                                  lValues.add(' ');
                                }
                              }
                          }
                        }
                      }
                    }
                    lDynamicWrapper.add(new dynamicWrapper(String.valueOf(rec.get('Id')),String.valueOf(rec.get(fieldName)),lValues));     
                  }
                }
            } else {
                render1 = true;
                List<sObject> resultRecord = Database.query(query);
                if(resultRecord.size() > 0){
                  for(sObject rec: resultRecord){
                    //records.add(new resultWrapper(String.valueOf(rec.get('Id')),String.valueOf(rec.get('Name')),String.valueOf(rec.get('Description__c'))));
                    List<String> lValues = new List<String>();
                    lLabel = mColumnsDisplay.values();
                    for(String key:mColumnsDisplay.keySet()){
                        if(key != fieldName){
                          if(key == 'CMSU_Booked_Date__c' && SObjectName == 'Order_Master__c'){
                              Date dt = Date.valueOf(rec.get(key));
                              if(dt != null){
                                  lValues.add(dt.format());
                              }else{
                                lValues.add(' ');
                              }

                          }else if(key == 'Order_Subtotal__c' && SObjectName == 'Order_Master__c'){
                              Decimal amt = Decimal.valueOf(String.valueOf(rec.get(key)));
                              List<String> args = new String[]{'0','number','###,###,##0.00'};
                              if(amt != null){
                                lValues.add('$'+String.format(amt.format(), args));
                              }
                          }
                          else{
                            if(rec != null){
                              if(key.contains('.')){
                                String[] splitRec = key.split('\\.');
                                SObject childObject = rec.getSObject(splitRec[0]);
                                String value = String.valueOf(childObject.get(splitRec[1]));
                                if(value != null){
                                  lValues.add(value);
                                }else {
                                  lValues.add(' ');
                                }

                              }else{
                                if(rec.get(key) != null){
                                  lValues.add(String.valueOf(rec.get(key)));
                                }else{
                                  lValues.add(' ');
                                }
                              }
                          }
                        } 
                      }
                    }
                    System.debug('lValues'+lValues);
                      lDynamicWrapper.add(new dynamicWrapper(String.valueOf(rec.get('Id')),String.valueOf(rec.get(fieldName)),lValues));
                  
                  }
                }
                System.debug('****'+lDynamicWrapper);

            }
            
        } catch (Exception e) {
          System.debug('**'+e.getMessage());
          System.debug('**'+e.getStackTraceString());
        }
    }
    //public List < resultWrapper > getRecords() {
    //  System.debug('records'+records.size());
    //    if (records.size() != 0) {
    //        return records;
    //    } else {
    //        return null;
    //    }
    //}
    public PageReference onkeyupAction() {
        searchAction();
        return null;
    }
    public PageReference searchAction() {
        render1 = true;
        query = partialQuery + ' like \'' +searchvalue + '%' + '\' order by '+fieldName+' asc limit 200';
        System.debug('**qurery'+query);
       
        List<sObject> resultRecord = Database.query(query);
        records = new List<resultWrapper>();
        lDynamicWrapper = new List<dynamicWrapper>();
        if(resultRecord.size() > 0){
          for(sObject rec: resultRecord){
              List<String> lValues = new List<String>();
                    lLabel = mColumnsDisplay.values();
                    for(String key:mColumnsDisplay.keySet()){
                        if(key != fieldName){
                          if(key == 'CMSU_Booked_Date__c' && SObjectName == 'Order_Master__c'){
                              Date dt = Date.valueOf(rec.get(key));
                              if(dt != null){
                                lValues.add(dt.format());
                              }else{
                                lValues.add(' ');
                              }

                          }else if(key == 'Order_Subtotal__c' && SObjectName == 'Order_Master__c'){
                              Decimal amt = Decimal.valueOf(String.valueOf(rec.get(key)));
                              List<String> args = new String[]{'0','number','###,###,##0.00'};
                              if(amt != null){
                                lValues.add('$'+String.format(amt.format(), args));
                              }
                          }else{
                           if(rec != null){
                              if(key.contains('.')){
                                String[] splitRec = key.split('\\.');
                                SObject childObject = rec.getSObject(splitRec[0]);
                                String value = String.valueOf(childObject.get(splitRec[1]));
                                if(value != null){
                                  lValues.add(value);
                                }else {
                                  lValues.add(' ');
                                }

                              }else{
                                if(rec.get(key) != null){
                                  lValues.add(String.valueOf(rec.get(key)));
                                }else{
                                  lValues.add(' ');
                                }
                              }
                          }
                        }
                      }
                      
                    }
              lDynamicWrapper.add(new dynamicWrapper(String.valueOf(rec.get('Id')),String.valueOf(rec.get(fieldName)),lValues));      
          }
        }
        
        //records = Database.query(query);
        if (records.isEmpty()) {
            //ApexPages.addMessage(new ApexPages.message(ApexPages.Severity.Error, 'No Records Found'));
             System.debug(ApexPages.Severity.Error);
        }

        return null;
    }
    
      public PageReference previous(){
        return null;
      }

      public PageReference next(){
        return null;
      }

    public class resultWrapper {
      public String id {get;set;}
      public String name {get;set;}
      public String Description {get;set;}

      public resultWrapper(String id, String name, String Description){
        this.id = id;
        this.name = name;
        this.Description = Description;
      }
    }

    public class dynamicWrapper{
        public String Id {get;set;}
        public String Name {get;set;}
        public List<String> lValues {get;set;}


        public dynamicWrapper(String Id, String Name, List<String> lValues){
            this.Id = Id;
            this.Name = Name;
            this.lValues = lValues;
        }
    }
}