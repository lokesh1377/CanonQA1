public without sharing class TamsFieldSetHelper {

public static List<Schema.FieldSetMember> getFieldSetMembers(String fieldSetName, String ObjectName){
		System.debug('START:getFieldSetMembers');
		System.debug('fieldSetName:'+fieldSetName);
		System.debug('ObjectName:'+ObjectName);
	    Map<String, Schema.SObjectType> GlobalDescribeMap = Schema.getGlobalDescribe(); 
	    Schema.SObjectType SObjectTypeObj = GlobalDescribeMap.get(ObjectName);
	    Schema.DescribeSObjectResult DescribeSObjectResultObj = SObjectTypeObj.getDescribe();
	    Schema.FieldSet fieldSetObj = DescribeSObjectResultObj.FieldSets.getMap().get(fieldSetName);
	    List<Schema.FieldSetMember> fieldSetMemberList = fieldSetObj.getFields();
	    /***
		for(Schema.FieldSetMember fieldSetMemberObj : fieldSetMemberList){
		    system.debug('API Name ====>' + fieldSetMemberObj.getFieldPath()); //api name
		    system.debug('Label ====>' + fieldSetMemberObj.getLabel());
		    system.debug('Required ====>' + fieldSetMemberObj.getRequired());
		    system.debug('DbRequired ====>' + fieldSetMemberObj.getDbRequired());
		    system.debug('Type ====>' + fieldSetMemberObj.getType());   //type - STRING,PICKLIST

		}	    
		**/
	    return fieldSetMemberList; 
	}  

}