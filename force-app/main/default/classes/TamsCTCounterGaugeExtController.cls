public class TamsCTCounterGaugeExtController {

    public class applicationException extends Exception {}
    public String rotationCountStr {get;set;}
    public String usageString {get;set;}
    public List<String> returnStrings = new List<String>();
    public Install_Base_Counter_TAMS__c counterRecord {get;set;}
    public Install_Base_TAMS__c ibRecord {get;set;}
    public ServiceContract scRecord {get;set;}
    public Decimal  diffCount {get;set;}
    public Decimal sliceCounter {get;set;}
    public Decimal     baseReading {get;set;}
    public Decimal     latestReading {get;set;}
    public Date    readingDate {get;set;}  
    public ID ibID {get;set;}
    public TAMS_Service_Contract_line_Items__c scLineRecord {get;set;}
    
    public TamsCTCounterGaugeExtController(ApexPages.StandardController stdController) 
    {
        System.debug('Inside constructor TamsCTCounterGaugeExtController');         
        ibID = stdController.getId();
     try{
        ibRecord = [SELECT id,NAME,ASM_lookup__c,ASM_lookup__r.NAME
                    FROM Install_Base_TAMS__c
                    WHERE ID=:ibID 
                    LIMIT 1];
        System.debug('ibRecord:'+ibRecord);         
        scRecord = [SELECT 
                        ID,
                        NAME
                    FROM ServiceContract 
                    WHERE Equipment__c = :ibID
                        AND Contract_Status__c = 'Active'
                        LIMIT 1];
        System.debug('scRecord:'+scRecord);         
        System.debug('scRecord.NAME:'+scRecord.NAME);           
        scLineRecord = [SELECT 
                            Slice_Counter__c
                            ,Overage_Amount__c 
                            ,Start_Date__c
                            ,End_Date__c
                        FROM 
                            TAMS_Service_Contract_line_Items__c
                        WHERE ServiceContract__c = :scRecord.ID
                            AND status__c = 'Active'
                            AND Slice_Counter__c <> null
                            LIMIT 1];       
        System.debug('scLineRecord:'+scLineRecord);
        sliceCounter = scLineRecord.Slice_Counter__c;            
        System.debug('Slice_Counter__c:'+scLineRecord.Slice_Counter__c);    
        System.debug('Overage_Amount__c:'+scLineRecord.Overage_Amount__c);  
        System.debug('Start_Date__c:'+scLineRecord.Start_Date__c);
        System.debug('End_Date__c:'+scLineRecord.End_Date__c);

        Date today = Date.today();
        Date startDate = scLineRecord.Start_Date__c;
        Integer totalMonths = startDate.monthsBetween(today);
        System.debug('totalMonths:'+totalMonths);
        Decimal totalYrs = totalMonths/12;
        System.debug('totalYrs:'+totalYrs);
        Integer yrs = Integer.valueOf(Math.FLOOR(totalYrs));
        System.debug('yrs:'+yrs);
        Date baseDate = startDate.addYears(yrs);
        System.debug('baseDate:'+baseDate); 
        List<Install_Base_Counter_TAMS__c> baseCounterRecord = 
            [SELECT 
                Reading_Date__c
                ,Counter_Reading__c 
            FROM 
                Install_Base_Counter_TAMS__c
            WHERE Install_Base_Name__c = :ibID
                AND Reading_Date__c <= :baseDate
                ORDER BY Reading_Date__c DESC
                LIMIT 1];
        //if there is no record exists look for record less than the baseDate
        System.debug('baseCounterRecord.size():'+baseCounterRecord.size()); 
        if( baseCounterRecord.size() == 0)
        {
            baseCounterRecord = 
            [SELECT 
                Reading_Date__c
                ,Counter_Reading__c 
            FROM 
                Install_Base_Counter_TAMS__c
            WHERE Install_Base_Name__c = :ibID
                AND Reading_Date__c < :baseDate
                ORDER BY Reading_Date__c desc
                LIMIT 1];           
        }       

        if( baseCounterRecord.size() <> 0 )
        {
            System.debug('base Reading_Date__c:'+baseCounterRecord[0].Reading_Date__c);         
            System.debug('base Counter_Reading__c:'+baseCounterRecord[0].Counter_Reading__c);
        }

        List<Install_Base_Counter_TAMS__c> latestCounterRecord = 
            [SELECT 
                Reading_Date__c
                ,Counter_Reading__c 
            FROM 
                Install_Base_Counter_TAMS__c
            WHERE Install_Base_Name__c = :ibID
                AND Reading_Date__c >= :baseDate
                ORDER BY Reading_Date__c DESC
                LIMIT 1];       
        //If no record exists for latest counter reading, use base counter reading      

        System.debug('latestCounterRecord.size():'+latestCounterRecord.size());         
        if( latestCounterRecord.size() >= 1)
        {
            System.debug('Inside if( latestCounterRecord.size() >= 1)');         
            System.debug('latest Reading_Date__c:'+latestCounterRecord[0].Reading_Date__c);         
            System.debug('latest Counter_Reading__c:'+latestCounterRecord[0].Counter_Reading__c);
        }

        if(latestCounterRecord.size() == 0 && baseCounterRecord.size() <> 0)        
        {
            System.debug('if(latestCounterRecord.size() == 0 && baseCounterRecord.size() <> 0)');         
            diffCount = 0;
            readingDate = Date.today(); 
        }

        if(baseCounterRecord.size() == 0 && latestCounterRecord.size() <> 0)        
        {
            System.debug('if(baseCounterRecord.size() == 0 && latestCounterRecord.size() <> 0)');         
            diffCount = latestCounterRecord[0].Counter_Reading__c;
            readingDate = Date.newInstance(latestCounterRecord[0].Reading_Date__c.year()
                                         , latestCounterRecord[0].Reading_Date__c.month()
                                         , latestCounterRecord[0].Reading_Date__c.day());
        }

        if( baseCounterRecord.size() <> 0 && latestCounterRecord.size() <> 0 && baseCounterRecord[0] == latestCounterRecord[0])     
        {
            System.debug('if( baseCounterRecord.size() <> 0 && latestCounterRecord.size() <> 0 && baseCounterRecord[0] == latestCounterRecord[0])');         
            diffCount = latestCounterRecord[0].Counter_Reading__c;
            readingDate = Date.newInstance(latestCounterRecord[0].Reading_Date__c.year()
                                         , latestCounterRecord[0].Reading_Date__c.month()
                                         , latestCounterRecord[0].Reading_Date__c.day());
        }

        if( baseCounterRecord.size() <> 0 && latestCounterRecord.size() <> 0 && baseCounterRecord[0] <> latestCounterRecord[0])     
        {
            System.debug('if( baseCounterRecord.size() <> 0 && latestCounterRecord.size() <> 0 && baseCounterRecord[0] <> latestCounterRecord[0])');         
            diffCount = latestCounterRecord[0].Counter_Reading__c -  baseCounterRecord[0].Counter_Reading__c;
            readingDate = Date.newInstance(latestCounterRecord[0].Reading_Date__c.year()
                                         , latestCounterRecord[0].Reading_Date__c.month()
                                         , latestCounterRecord[0].Reading_Date__c.day());
        }       
 
        if(diffCount < 0)
        {
          System.debug('diffCount is Negative: '+diffCount);
          diffCount = 0;
          rotationCountStr = 'Unable to Calculate Rotation count at this point. Please navigate to General Inquiry area to create a support case.';
        } 
        else
        {   
           System.debug('diffCount:'+diffCount);
           System.debug('readingDate:'+readingDate);
           rotationCountStr = 'Rotation Count: '
                        + String.valueOf(diffCount)
                        + ' (as of ' + String.valueOf(readingDate) 
                        + ' and contract anniversary date of:' + String.valueOf(baseDate) + ')';
        }                
        System.debug('rotationCountStr:'+rotationCountStr);
        
        if(diffCount > scLineRecord.Slice_Counter__c)
        {
            usageString = /*'Usage Fee: $'+scLineRecord.Overage_Amount__c+'*'
                            + String.valueOf( diffCount - scLineRecord.Slice_Counter__c)
                            + ' = $'
                            + String.valueOf((diffCount - scLineRecord.Slice_Counter__c)
                                            * scLineRecord.Overage_Amount__c)
                            +' (Based on '+ String.valueOf(scLineRecord.Slice_Counter__c)+' Tube Coverage)';    
                            */
                        'Usage Fee: Your Rotation Count may be over the allowed Tube Coverage, please contact your ASM for more details.';  
        }   
     }                                         
     catch(Exception e)
     {
        System.debug(e.getMessage());
        Apexpages.addMessage(new ApexPages.Message(ApexPages.Severity.WARNING,
            'No Data/Invalid Data Available for CT Counter Chart– Please create a Web Support Case via General Inquiry.'));         
     }

    }   

    public PageReference sendEmail()
    {
        System.debug('inside sendEmail');
        ibRecord.send_email_to_ASM__c = true;
        update ibRecord;
        ibRecord.send_email_to_ASM__c = false;
        update ibRecord;

        System.debug('setting message');                
        Apexpages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO,
            'Email sent to ASM:'+ibRecord.ASM_lookup__r.Name));         

        System.debug('returning back');
        return NULL;   
    }
}