public class ServiceContractRelatedList{
    private List<TAMS_Service_Contract_line_Items__c> listCLI;
    private ServiceContract sc; 
    public ServiceContractRelatedList(ApexPages.StandardController controller) {
        this.sc= (ServiceContract)controller.getRecord();
    }
    public List<TAMS_Service_Contract_line_Items__c> getLineItems()
    {
        integer i = 0;
        String query = 'SELECT ';
        for(Schema.FieldSetMember f : this.getFields()) {
            query = i>0 ? query +', ' : query;
            query += f.getFieldPath();
            i++;
        }
        set<string> excludedProducts = new set<string>{'CONTVARIANCE.009','BILLONLYSVC.009'};
        query += ' FROM TAMS_Service_Contract_line_Items__c WHERE ServiceContract__c = \'' + sc.Id + '\' AND Line_Item__c NOT IN :excludedProducts';
        system.debug(query);
        return Database.query(query);
        
        //listCLI = [SELECT Id,LineItemNumber,Product_Name__c,Description,Entitlement_Type__c,Entitlement_Description__c,Preventative_Maintenance_Description__c FROM ContractLineItem WHERE ServiceContractId = :sc.Id];
        //return listCLI;
    }
    
    public List<Schema.FieldSetMember> getFields() {
        return SObjectType.TAMS_Service_Contract_line_Items__c.FieldSets.RelatedList.getFields();
    }
}