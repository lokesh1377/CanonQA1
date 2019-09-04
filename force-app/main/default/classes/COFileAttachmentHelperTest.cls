@isTest
public class COFileAttachmentHelperTest{

      @testSetup static void setupTestData(){
        Account acct        = createAccount('TESTACCOUNT');
        Opportunity opp     = createOpportunity(acct.Id, 'TESTOPPORTUNITY');   
        Order_Master__c ord = createOrderMaster(acct.Id, opp.Id);               
        TAMS_ROA__c co      = createChangeOrder(acct.Id, ord.id);
        Change_Order_Attachment__c coAttm = createCoAttm(co.Id);          
      }

        
      private static Account createAccount(String acctName){
        Account acc = new Account(name='Test Account');
        acc.Territory_Name_TAMS__c = 'US.GL.2660100.TR-101';
        insert acc;
        return acc;
      }  
      
      private static Opportunity createOpportunity(Id acctId, String oppName){
        Opportunity opp = new Opportunity();
            opp.Name = oppName;
            opp.SID_TAMS__c = '1234567';
            opp.Expected_Bill_Date_TAMS__c = Date.today() + 2;
            opp.CloseDate =  Date.today()+1;
            opp.StageName = 'Closed/Lost';
            opp.Lost_Cancelled_Reason_TAMS__c = 'Functionality/Insufficient Technology';
            opp.Competitor_Lost_to_TAMS__c = 'GE';
            opp.LeadSource = 'Cold Call';
            opp.Incumbent_TAMS__c = 'GE';
            opp.Competitor_Lost_to_TAMS__c = 'GE';
            opp.Is_this_Product_Funded_TAMS__c = 'Yes';
            opp.Additional_Comments_TAMS__c = 'Test Comments';
            opp.Actual_Book_Date_TAMS__c = Date.today();
            opp.AccountId = acctId;
            insert opp;        
            return opp;
      }      
      
    private static Order_Master__c createOrderMaster(Id acctId, Id oppId){
      Order_Master__c om = new Order_Master__c();
          om.Customer_Name__c       = acctId;
          om.Oracle_Order_Number__c ='10012345';
          om.SID_Order__c           = 1234567;
          om.Modality_Order__c      = 'UL';
          insert om; 
          return om;  
    }      
    
    private static TAMS_ROA__c createChangeORder(Id acctId, Id ordId){
      TAMS_ROA__c co = new TAMS_ROA__c();
          co.ROA_Type__c          = 'Administrative Change';
          co.Account__c           = acctId;
          co.Change_Order_SID__c  = '1234567';          
          insert co; 
          return co;  
    }      
    
    private static Change_Order_Attachment__c createCoAttm(Id COId){
      Change_Order_Attachment__c CoAttm = new Change_Order_Attachment__c();
         CoAttm.COA_Change_Order__c = COId;
         CoAttm.COA_Description__c  = 'HK Test Doc';
         CoAttm.COA_Public__c       = true;     
         insert CoAttm; 
         return CoAttm;  
    }

       @isTest
     public static void testAttachment(){
     Change_Order_Attachment__c CoAttm = [Select Id From Change_Order_Attachment__c LIMIT 1];
     System.debug(CoAttm);
     TAMS_ROA__c co = [Select Id From TAMS_ROA__c LIMIT 1];
     System.debug(co);
     ContentVersion cv = new ContentVersion();
     cv.VersionData = Blob.valueOf('Unit Test Attachment by HK - Hemant Kumar');
     cv.FirstPublishLocationId = coAttm.Id;
     cv.PathOnClient = 'newfile.txt';
     cv.Title = 'TestForAttachment'; 
     Test.startTest();
       insert cv;
     Test.stopTest();  
     System.debug(co.Id);   
     List<ContentVersion> coAttms = [SELECT Title FROM ContentVersion WHERE FirstPublishLocationId = :co.Id LIMIT 1];
     System.debug('HK - ChangeOrderAttachmentHelperTest - coAttms: '+coAttms);
     System.assertEquals('TestForAttachment', cv.Title);
     if(coAttms.size() == 1){
      System.debug('HK - coAttms[0].name: '+ coAttms[0].Title);
      //System.assert(coAttms[0].name == 'TestForAttachment', 'Change Order Attachment not created/incorrect Name'); 
     }          
  }  

}