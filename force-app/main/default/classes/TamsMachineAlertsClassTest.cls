/*********************************************************
Author : Hemant Kumar       
Purpose: Test class for TamsMachineAlertsClass 
1.0 - Hemant Kumar - 07/28/2017 - Created
**********************************************************/

@isTest

public class TamsMachineAlertsClassTest 
{
    public static testMethod void testMachineAlerts() 
    {
       // Create a new email and envelope object
       Messaging.InboundEmail email   = new Messaging.InboundEmail();
       Messaging.InboundEmail email1  = new Messaging.InboundEmail();       
       Messaging.InboundEmail email2  = new Messaging.InboundEmail();        
       Messaging.InboundEmail email3  = new Messaging.InboundEmail();        
       Messaging.InboundEnvelope env  = new Messaging.InboundEnvelope();
    
       // Set up data 
       Account a = new Account();
       a.Name = 'TestAccount';
       insert a;
           
       RecordType RecTypeIB = [Select Id From RecordType Where SobjectType = 'Install_Base_TAMS__c' And IsActive = true And Name = 'TAMS Install Base'];
           
       Install_Base_TAMS__c ib = new Install_Base_TAMS__c
                           (Account_Name__c      =  a.Id,
                            Name                 = '30021567',
                            SID_TAMS__c          = '30021567',
                            Modality_ALL__c      = 'CT', 
                            Manufacturer_ALL__c  = 'GE', 
                            Active_IB__c         =  true,
                            RecordTypeId         =  RecTypeIB.Id,
                            Nickname__c          = 'MRTestIB',
                            External_ID__c       = '30021567'                             
                           );
       insert ib;    

       // Create the email body
       email.fromAddress = 'ServiceNetworkingSupport@tams.com';       
       email.subject = 'MR AlertWatcher SID# 30021567   The humidity in Computer Room is Too Moist/Wet!';    
       email.plainTextBody = 'SiteNumber=30021567-000\nZone=SouthWest\nCost Center = 5073200\nModality = MR\nSiteName = COON MEMORIAL HOSPITAL\nmrModel = TITAN-ASSURANCE.000\nPrimary CE = Robert E Schneider\nSecondary CE = Jake Baker Conger\nSystemType=MRT200MT5\nAlertComment=The humidity in Computer Room is Too Moist/Wet!\nAlertOccuredTime=2017.07.26 18:21:48\nAlertData1=(Computer Room - CH2 - Value:77 < Limit:75)\nAlertSource=ThermoLogAlert\nAlertLevel=2\nAlertID=04030110009\nSystemName=M-Power\nMachineType=MRT200MT5\nMachineId=0x0002030E';
       
       email1.fromAddress = 'ServiceNetworkingSupport@tams.com';       
       email1.subject = 'MR AlertWatcher SID# 30021567   The humidity in Computer Room is Too Moist/Wet!';    
       email1.plainTextBody = 'SiteNumber=30021567-001\nZone=SouthWest\nCost Center = 5073200\nModality = MR\nSiteName = COON MEMORIAL HOSPITAL\nmrModel = TITAN-ASSURANCE.000\nPrimary CE = Robert E Schneider\nSecondary CE = Jake Baker Conger\nSystemType=MRT200MT5\nAlertComment=The humidity in Computer Room is Too Moist/Wet!\nAlertOccuredTime=2017/07/26 18:21:48\nAlertData1=(Computer Room - CH2 - Value:77 < Limit:75)\nAlertSource=ThermoLogAlert\nAlertLevel=3\nAlertID=04030110009\nSystemName=M-Power\nMachineType=MRT200MT5\nMachineId=0x0002030E';
       
       email2.fromAddress = 'ServiceNetworkingSupport@tams.com';       
       email2.subject = 'MR AlertWatchers SID# 30021568   The humidity in Computer Room is Too Moist/Wet!';    
       email2.plainTextBody = 'SiteNumber=30021567-001\nZone=SouthWest\nCost Center = 5073200\nModality = MR\nSiteName = COON MEMORIAL HOSPITAL\nmrModel = TITAN-ASSURANCE.000\nPrimary CE = Robert E Schneider\nSecondary CE = Jake Baker Conger\nSystemType=MRT200MT5\nAlertComment=The humidity in Computer Room is Too Moist/Wet!\nAlertOccuredTime=\nAlertData1=(Computer Room - CH2 - Value:77 < Limit:75)\nAlertSource=ThermoLogAlert\nAlertLevel=3\nAlertID=04030110009\nSystemName=M-Power\nMachineType=MRT200MT5\nMachineId=0x0002030E';

       email3.fromAddress = 'ServiceNetworkingSupport@tams.com';       
       email3.subject = 'MR AlertWatchers SID# 30021568   The temperature is too cold!';    
       email3.plainTextBody = 'SiteNumber=30021567-001\nZone=SouthWest\nCost Center = 5073200\nModality = MR\nSiteName = COON MEMORIAL HOSPITAL\nmrModel = TITAN-ASSURANCE.000\nPrimary CE = Robert E Schneider\nSecondary CE = Jake Baker Conger\nSystemType=MRT200MT5\nAlertComment=The humidity in Computer Room is Too Moist/Wet!\nAlertOccuredTime=\nAlertData1=(Computer Room - CH2 - Value:77 < Limit:75)\nAlertSource=ThermoLogAlert\nAlertLevel=3\nAlertID=04030110009\nSystemName=M-Power\nMachineType=MRT200MT5\nMachineId=0x0002030E';       
       
       // add an Binary attachment
       Messaging.InboundEmail.BinaryAttachment attachment = new Messaging.InboundEmail.BinaryAttachment();
       attachment.body            =  blob.valueOf('MR Machine Alerts Binary attachment body');
       attachment.fileName        = 'MRAlertsBinaryfile.txt';
       attachment.mimeTypeSubType = 'text/plain';
       email.binaryAttachments    =  new Messaging.inboundEmail.BinaryAttachment[] { attachment };
        
       // add an Text atatchment  
       Messaging.InboundEmail.TextAttachment attachmenttext = new Messaging.InboundEmail.TextAttachment();
       attachmenttext.body            = 'MR Machine Alerts Text attachment body';
       attachmenttext.fileName        = 'MRAlertsTextfile.txt';
       attachmenttext.mimeTypeSubType = 'texttwo/plain';
       email1.textAttachments         =  new Messaging.inboundEmail.TextAttachment[] { attachmenttext };
      
       TamsMachineAlertsClass tmac = new TamsMachineAlertsClass();           
       Test.startTest();
       Messaging.InboundEmailResult result  = tmac.handleInboundEmail(email, env);
       Messaging.InboundEmailResult result1 = tmac.handleInboundEmail(email1, env);       
       Messaging.InboundEmailResult result2 = tmac.handleInboundEmail(email2, env);              
       Messaging.InboundEmailResult result3 = tmac.handleInboundEmail(email3, env);              
       Test.stopTest();    

       System.assert (result.success, 'InboundEmailResult returned a failure message');
       System.assert (result1.success, true);       
       System.assert (result1.success, false);              
       
    } // public static testMethod void testMachineAlerts   
}//public class TamsMachineAlertsClassTest