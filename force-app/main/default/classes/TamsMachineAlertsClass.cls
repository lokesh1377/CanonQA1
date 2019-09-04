/*********************************************************
Author : Hemant Kumar       
Purpose: Class for MR MachineAlerts
1.0 - Hemant Kumar - 07/17/2017 - Created
**********************************************************/

global class TamsMachineAlertsClass implements Messaging.InboundEmailHandler{
  global Messaging.InboundEmailResult handleInboundEmail(Messaging.InboundEmail email,
                                                           Messaging.Inboundenvelope envelope) 
    {
        
        Machine_Alerts__c alr = new Machine_Alerts__c();
        Messaging.InboundEmailResult result = new Messaging.InboundEmailResult();
        try 
        {

            String msg     = email.plainTextBody;
            String subject = email.subject;
            System.debug('HK subject:'+subject);           
            
            if(subject.contains('MR AlertWatcher') && (subject.contains('humidity')||subject.contains('temperature'))) 
            {  
                String msgHtml = msg;
                System.debug('HK Inside If.. MR Humidity .. Processing body:'+msgHtml);
                
                LIST<RecordType> recType=[select Id from RecordType where Name = 'MR Record Type' and SobjectType = 'Machine_Alerts__c' Limit 1];  
                if(recType.size() <> 0)                  
                alr.recordTypeId     = recType[0].Id;                
                
                alr.Alert_Type__c    = 'Alert Watcher';
                alr.Modality__c      = 'MR';
                if(subject.contains('humidity')){
                  alr.Alert_Subject__c = 'Humidity';
                }else{
                  alr.Alert_Subject__c = 'Temperature';
                }

                alr.SID__c           = getData(subject,'SID#',' ',' ');
                
                alr.Zone__c          = getData(msgHtml,'Zone ','= ','\n');
                alr.Cost_Center__c   = getData(msgHtml,'Cost Center ','= ','\n');
                alr.Model__c         = getData(msgHtml,'mrModel ','= ','Primary CE'); 
                alr.Primary_CE__c    = getData(msgHtml,'Primary CE ','= ','Secondary CE');
                alr.Secondary_CE__c  = getData(msgHtml,'Secondary CE ','= ','\n');

                alr.Site_Number__c   = getData(msgHtml,'SiteNumber','=','\n');                
                alr.Customer_Name__c = getData(msgHtml,'SiteName','=','\n');
                
                alr.Alert_Message__c = getData(msgHtml,'AlertComment','=','\n');
                alr.Alert_Data__c    = getData(msgHtml,'AlertData1','=','\n');
                alr.Alert_Source__c  = getData(msgHtml,'AlertSource','=','\n');
                alr.AlertOccured__c  = getAlertTime(msgHtml,alr.Alert_Type__c);
                
                String alertLevel    = getData(msgHtml,'AlertLevel','=','\n');                
                if(alertLevel=='3')
                {
                   alr.alert_level__c      = '3-Urgent';
                }   
                else
                {
                   alr.alert_level__c      = '2-Warning';
                }
                
                alr.Alert_ID__c      = getData(msgHtml,'AlertID','=','\n');    
                            
                alr.System_Name__c   = getData(msgHtml,'SystemName','=','\n');  
                              
                alr.Machine_Type__c  = getData(msgHtml,'MachineType','=','\n');                
                alr.Machine_Id__c    = getData(msgHtml,'MachineId','=','\n');
                alr.Sm_Version__c    = getData(msgHtml,'SmVersion','=','\n');
                
                LIST<Install_Base_TAMS__c> ib=[SELECT ID,Account_Name__c, SMS_Email__c FROM Install_Base_TAMS__c WHERE SID_TAMS__c=:alr.SID__C LIMIT 1];
                if(ib.size() > 0)
                {
                   alr.Equipment__c  = ib[0].ID;
                   alr.Account__c    = ib[0].Account_Name__c;
                   alr.SMS_Address__c= ib[0].SMS_Email__c;
                   System.debug('HK IB Details: '+ib[0]);
                }                
                                
                //System.debug('HK SID__c:'+alr.SID__c);                
                System.debug('HK Alert Record Details:'+alr);                                
                                 
                System.debug('HK Inserting Alert Details...');
                insert alr;
                                    
           }//if(subject.contains('MR AlertWatcher') && (subject.contains('humidity')||subject.contains('temperature')))  
            //Perform attachments.. if any..            
            System.debug('HK Checking for Attachement Existance...'); 
            LIST<Attachment> attms = new LIST<Attachment>();
            Messaging.Inboundemail.BinaryAttachment[] bAttachments = email.binaryAttachments;
            
            if (bAttachments != null)
            {
              System.debug('HK Fetching Attachement Details...');            
              for(Messaging.Inboundemail.BinaryAttachment binFile: bAttachments)
                {
                   System.debug('HK Attaching file:'+binFile.fileName);
                   if(binFile.fileName.contains('.txt'))
                   {
                      Attachment attm = new Attachment();
                      attm.Name       = binFile.fileName;
                      attm.body       = binFile.body;
                      attm.parentId   = alr.Id;
                      attms.add(attm);
                   }
                } //for      
            } //if
             
            System.debug('HK Checking Attachemnts file Size...='+attms.size());
            if(attms.size() > 0)
             {
               System.debug('HK Inserting Attachemnts...'+attms.size());
               insert attms;     
             }
             
            result.success = true;
            return result; 
        } // try
        catch(Exception e)
        {
            System.debug('HK exception:'+e.getMessage());
            result.success = false;
            return result;
        } //catch        
                
  } //global Messaging                 
  
  global String getData(String src, String dataElement, String separator, String endText)
   {
        String  tmp=src.substringBetween(dataElement + separator, endText);
        System.debug('HK getData dataElement:'+dataElement +' Value:'+tmp);
        if (tmp != null) { 
            return tmp.trim();
           }
        else {
             tmp = ' ';
             return tmp;
           }    
   }
   
  global DateTime getAlertTime(String src, String alertType)
  {
   System.debug('HK getAlertTime alertType:'+alertType);
   try
   {
      if(alertType=='Alert Watcher')
      {
         String sTime = getData(src,'AlertOccuredTime','=','\n');
         sTime = sTime.replace('\r\n', '');
         sTime = sTime.replace('\n', '');
         sTime = sTime.replace('\r', '');
         System.debug('sTime:'+sTime);

         //In the format 2017.07.11 06:41:43
         LIST<String> stringDateTime = sTime.split(' ');
         System.debug('HK stringDateTime[0]:'+stringDateTime[0]);
         System.debug('HK stringDateTime[1]:'+stringDateTime[1]);
         
         LIST<String> stringDate = stringDateTime[0].split('\\.');
         System.debug('HK after date split');   
         System.debug('HK stringDate[0]:'+stringDate[0]);
         System.debug('HK stringDate[1]:'+stringDate[1]);
         System.debug('HK stringDate[2]:'+stringDate[2]);
         
         LIST<String> stringTime = stringDateTime[1].split(':');
         System.debug('HK stringTime[0]:'+stringTime[0]);
         System.debug('HK stringTime[1]:'+stringTime[1]); 
         System.debug('HK stringTime[2]:'+stringTime[2]);
         DateTime t = DateTime.newInstance(  Integer.valueOf(stringDate[0]), 
                                    Integer.valueOf(stringDate[1]),
                                    Integer.valueOf(stringDate[2]), 
                                    Integer.valueOf(stringTime[0]), 
                                    Integer.valueOf(stringTime[1]), 
                                    Integer.valueOf(stringTime[2]));
         System.debug('HK Alert Time worked!! '+ t);
         return t;
      }
      return System.now();
   }//try   
   catch(Exception e)
   {
      System.debug('HK getAlertTime Exception: ' +e.getMessage());
      return System.NOW(); 
   }  
  }  
     
} // global class