/*********************************************************
Author : Hemant Kumar       
Purpose: Test class for oppOrderTableController
1.0 - Hemant Kumar - 06/07/2018 - Created
**********************************************************/

@isTest
public class oppOrderTableControllerTest 
{    
    public static testMethod void testoppOrderTableController() 
    {
                
        Account a             = createAcc();
        Opportunity op        = createOpp(a.id);                
        TAMS_Orders__c ord    = createOrder(a.id,op.id);               
        
        Test.startTest();
        oppOrderTableController ootc  = new oppOrderTableController();
        ootc.thisOppId                = op.id;
        ootc.thisEmailType            = true;
        ootc.getOppOrder();
        Test.stopTest();
    }    
    
 
    private static Account createAcc(){
        Account a       = new Account();
        a.Name          = 'TestAccount';
        //a.OwnerId       = '005i0000001MdWR';
        //a.UL_ZBM_Acc__c = '0051Y0000098JfW';
        a.Territory_Name_TAMS__c = 'US.SW.2700100.TR-109';
        insert a;
        return a;
    }
    
    private static Opportunity createOpp(Id AccId){        
        Opportunity op                   = new Opportunity();
        op.AccountId                     = AccId;
        op.Name                          ='HK-testOppOrder';
        op.Booking_Amount__c             = 5000.00;
        op.Probability                   = 100;
        op.Modality_TAMS__c              = 'UL';
        op.Expected_Bill_Date_TAMS__c    = Date.today() + 30;
        op.CloseDate                     = Date.today() + 1;
        op.StageName                     = 'Closed/Won';
        op.Win_Reason_TAMS__c            = 'Functionality';
        op.Competitor_Lost_to_TAMS__c    = 'GE';
        op.LeadSource                    = 'Cold Call';
        op.Incumbent_TAMS__c             = 'GE';
        op.Is_this_Product_Funded_TAMS__c= 'Yes';
        op.Additional_Comments_TAMS__c   = 'Test Comments';
        op.Actual_Book_Date_TAMS__c      = Date.today();
        insert op;                 
        return op;
    }

    private static TAMS_Orders__c createOrder(Id AccId, Id OppId){  
        TAMS_Orders__c order     = new TAMS_Orders__c();
        
        order.Oracle_Order_Number__c    = '10014000';
        order.Oracle_Header_ID__c       =  10014000;
        order.Order_Status__c           = 'Booked'; 
        order.Modality_Order__c         = 'UL';
        order.Order_Subtotal__c         = 55555.00;
        order.TAMS_Opportunity__c       = OppId;
        order.Customer_Name__c          = AccId;
        
        insert order;  
        return order;        
    }    

    
}