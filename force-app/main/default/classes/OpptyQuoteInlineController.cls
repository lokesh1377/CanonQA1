/*********************************************************
        Author: XELLERATION         
        Purpose: This Controller Class is used support the  
        business logic and data needs of the 
        OpptyQuoteInlineVFPage.        
        1.0 - Brandon Cassis - 03/11/2015 - Created
**********************************************************/
public with sharing class OpptyQuoteInlineController{
    
    public Opportunity pageOppty {get; set;}
    public Id primaryQuoteId {get; set;}
    public List<TAMS_Quotes__c> pageQuoteList = new List<TAMS_Quotes__c>();
    public OpptyQuoteInlineController(ApexPages.StandardController cont) {
        pageOppty = new Opportunity();
        this.pageOppty = (Opportunity)cont.getRecord();
        
        pageQuoteList = getPageQuoteList();
    }
    
    //Returns fields listed in the Fieldset 
    public List<Schema.FieldSetMember> getFields() {
        return SObjectType.TAMS_Quotes__c.FieldSets.Quote_Columns_for_Opportunity_Layout.getFields();
    }
    
    //Qeueries associated Quote records based on fields in the Fieldset
    public List<TAMS_Quotes__c> getPageQuoteList() {
        List<TAMS_Quotes__c> returnList = new List<TAMS_Quotes__c>();
        String query = 'SELECT ';
        Id tempId = pageOppty.Id;
        for(Schema.FieldSetMember f : this.getFields()) {
            query += f.getFieldPath() + ', ';
        }
        query += 'Id, Opportunity_Name__c, Primary__c, Name FROM TAMS_Quotes__c Where Opportunity_Name__c = :tempId ORDER BY CreatedDate DESC' ;
        
        try{
           returnList = Database.query(query);  
        } catch(Exception e) {
            ErrorLog.storeException(e.getMessage());
        }   
        return returnList;    
    }
    
    //Action Method used to update the selected Quote as Primary
    public static PageReference savePrimaryQuote() {
        TAMS_Quotes__c updateQuote = new TAMS_Quotes__c();
        updateQuote.Id = Apexpages.currentPage().getParameters().get('quoteId');
        updateQuote.Primary__c = true;
        try{
            update updateQuote;
        } catch(Exception e) {
            ErrorLog.storeException(e.getMessage());
        }

        return null;
    }
}