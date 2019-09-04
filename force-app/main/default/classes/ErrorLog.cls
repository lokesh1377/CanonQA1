/*********************************************************
        Author: XELLERATION         
        Purpose: This Class is used to process system 
        exceptions for the rest of the code.        
        1.0 - Brandon Cassis - 03/09/2015 - Created
**********************************************************/


public class ErrorLog{
    
    
    //Future method used to log the exception in a custom object.
    public static void storeException(String exceptionMessage                                                                                                                                                      
                                      ) {
        try {
            Error_Log__c tempErrorLog = new Error_Log__c();
            tempErrorLog.Description__c = exceptionMessage;
            insert tempErrorLog;
        }catch(Exception e) {
            System.debug('Unable to insert in storeException:'+e.getMessage());
        }

    }
        
    public static void storeExceptions(List<Error_Log__c> errorLogs) {
        try {
            insert errorLogs;
        }catch(Exception e) {
            System.debug('Unable to insert in storeExceptions:'+e.getMessage());
        }        
    }
    
    
    //Method sends an email to Admin when the execption cannot be stored in 
    // the earlier in the Error Object. 
/**    public static void emailAdmin(string inputException) {
         Messaging.SingleEmailMessage mail=new Messaging.SingleEmailMessage();
         String[] toAddresses = new String[]{System.Label.ToAddress};
         mail.setToAddresses(toAddresses);
         mail.setReplyTo(System.Label.FromAddress);
         mail.setSenderDisplayName('Apex error message');
         mail.setSubject('Error from Org : ' + UserInfo.getOrganizationName());
         mail.setPlainTextBody(inputException);
         Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
    } **/
}