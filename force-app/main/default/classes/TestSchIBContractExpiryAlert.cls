@isTest(SeeAllData = True)

private class TestSchIBContractExpiryAlert {                       
/*
// CRON expression: midnight on January 1.                              
// Because this is a test, job executes                                
// immediately after Test.stopTest().                                    
                          

static testmethod void testIBExpiryAlert() {                             
                                      
     id ibid_1;

     id uid = [Select id from User where name = 'Jackie Reding'].id;
                             
     Account a = new Account();
     a.Name = 'Test Account';
     a.Account_Status_TAMS__c = 'Active';
     a.Territory_Name_TAMS__c =  'Reding Jackie US.WE.268010.TR-102';            
  
     insert (a);                
       
     Id AccID = [Select id from Account where id = : a.Id].id; 
     system.debug('accid = ' + string.valueOf(accid));                  
      
     ExpirationPeriod__c p = new ExpirationPeriod__c();                      
     p.Name = 'Test';                            
     p.Number_of_days__c = 10;                         
     insert(p);        
                                
     list<ExpirationPeriod__c> periodList = [Select p.Name, p.Number_Of_Days__c From ExpirationPeriod__c p]; // where p.Name = 'Test'];                                     
        
     for (ExpirationPeriod__c prd : periodlist){                                                                                      
        integer period = Integer.valueOf(prd.Number_Of_Days__c);                           
        date d = system.today().addDays(+period);                                               
        System.debug('period: ' + string.valueOf(period));            
        System.debug('target date: ' + string.valueOf(d));                                                                           
    
        Id RecTypeCIB = [Select Id From RecordType Where SobjectType = 'Install_Base_TAMS__c' And IsActive = true And Name = 'TAMS Install Base'].Id;                               
 //       system.debug('RecTypeCIB: ' + RecTypeCIB) ;                       
                                                                                                               
       Install_Base_TAMS__c ib_1 = new Install_Base_TAMS__c();                                    
       ib_1.Account_Name__c = AccID;                     
       ib_1.Modality_ALL__c = 'CT';                     
       ib_1.Active_IB__c = true;                 
       ib_1.RecordTypeId = RecTypeCIB;                     
       ib_1.Contract_End_Date_ALL__c = d;                                     
       insert ib_1;                                                         
      
        ibid_1 = ib_1.id;        
       //    system.debug('ibid_1: ' + ibid_1);               
     }          
     
     Test.startTest();   
                      
     String CRON_EXP = '0 0 0 1 1 ? 2025';                  
     String jobId = System.schedule('testScheduledApex', CRON_EXP, new  Sch_IBContractExpiryAlert() );                    
 //String jobId = System.schedule('testScheduledApex', CRON_EXP, new  NT() );                    


     CronTrigger ct = [select id, CronExpression, TimesTriggered, NextFireTime from CronTrigger where id = :jobId];                    

     System.assertEquals(CRON_EXP, ct.CronExpression);                     
     System.assertEquals(0, ct.TimesTriggered);                    

     System.assertEquals('2025-01-01 00:00:00', String.valueOf(ct.NextFireTime));           

     // Verify the scheduled job hasn't run yet.                               
     Install_Base_TAMS__c[] ib = [SELECT Id FROM Install_Base_TAMS__c  WHERE id =: ibid_1 and IB_Contract_Expiration_30_To__c != ''];                         
     System.assertEquals(ib.size(),0);                               
                                             
     Test.stopTest();                  
      
     list<ExpirationPeriod__c> periodLstAfter = [Select p.Name, p.Number_Of_Days__c From ExpirationPeriod__c p where p.Name = 'Test'];                                           
     System.assertEquals(periodLstAfter.size(),1); 
                                                           
     // Now that the scheduled job has executed after Test.stopTest(),                                  
     ib = [SELECT Id FROM Install_Base_TAMS__c  WHERE id =: ibid_1];         
     System.assertNotEquals(ib.size(), 0);                              
              
     }           */
 }