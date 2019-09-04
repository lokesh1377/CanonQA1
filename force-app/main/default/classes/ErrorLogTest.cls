/*********************************************************
        Author: XELLERATION         
        Purpose: This Test Class is used to test processing
        system exceptions for the rest of the code.        
        1.0 - Brandon Cassis - 03/11/2015 - Created
**********************************************************/

@isTest

private class ErrorLogTest{

    //Tests the Exception Storing Method.
    static testMethod void storeExceptionTest(){
        Integer beforeCount = [select count() From Error_Log__c Where CreatedDate = Today];
        ErrorLog.storeException('Test');
        Integer afterCount = [select count() From Error_Log__c Where CreatedDate = Today];
        system.assert(beforeCount < aftercount);
    }
    
    //Tests the Email Admin Method, but only for code coverage.
 /**static testMethod void emailAdminTest(){
        ErrorLog.emailAdmin('Test');
    }**/
}