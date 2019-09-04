/*********************************************************
Author : Hemant Kumar       
Purpose: Test class for ASMContractsDashBoardController
1.0 - Hemant Kumar - 08/09/2016 - Created
**********************************************************/

@isTest

public class ASMContractsDashBoardControllerTest 
{
    public static testMethod void testASMController() 
    {
    
        PageReference ASMDBPage = Page.ASMContractsDashBoardVPage;
        Test.setCurrentPage(ASMDBPage);    
      
        Account a = new Account();
        a.Name = 'TestAccount';
        insert a;
        
        //Id UserId = [Select Id From User where Name = 'Rich Blessington'];
        
        Profile p = [Select Id From Profile where Name = 'TAMS - ASM'];
        
        User u              = new User();
        u.LastName          = 'TestUser';
        u.Alias             = 'TUser';
        u.Email             = 'testuser@toshiba.com';
        u.Username          = 'testuser@toshiba.com';
        u.CommunityNickname = 'TestU';
        u.EmailEncodingKey  = 'UTF-8';
        u.LanguageLocaleKey = 'en_US';
        u.ProfileId         =  p.Id;
        u.TimeZoneSidKey    = 'America/Los_Angeles';
        u.LocaleSidKey      = 'en_US';
        insert u;
        
        RecordType RecTypeIB = [Select Id From RecordType Where SobjectType = 'Install_Base_TAMS__c' And IsActive = true And Name = 'TAMS Install Base'];
           
        Install_Base_TAMS__c ib = new Install_Base_TAMS__c
                            (Account_Name__c      =  a.Id,
                             Name                 = '30050001',
                             SID_TAMS__c          = '30050001',
                             Modality_ALL__c      = 'CT', 
                             Manufacturer_ALL__c  = 'GE', 
                             Active_IB__c         =  true,
                             RecordTypeId         =  RecTypeIB.Id,
                             Nickname__c          = 'TestIB',
                             External_ID__c       = '30050001',
                             ASM_lookup__c        = u.Id
                            );
        insert ib;         
           
        ServiceContract sc = new ServiceContract();
        sc.Name               = '50000-001';
        sc.AccountId          = a.id;
        sc.Modality__c        = 'CT';
        sc.OwnerId            = u.Id;
        sc.Equipment__c       = ib.Id;
        sc.Contract_Status__c = 'Active';
        sc.StartDate          = SYSTEM.today() - 10;  
        sc.EndDate            = SYSTEM.today() + 355;
        sc.Type__c            = 'Warranty Support';
        sc.sid__c             = '30050001';       
        insert sc;           

        ServiceContract sc1 = new ServiceContract();
        sc1.Name               = '50000-002';
        sc1.AccountId          = a.id;
        sc1.Modality__c        = 'CT';
        sc1.OwnerId            = u.Id;
        sc1.Equipment__c       = ib.Id;
        sc1.Contract_Status__c = 'Signed';
        sc1.StartDate          = SYSTEM.today() + 356;  
        sc1.EndDate            = SYSTEM.today() + 625;
        sc1.Type__c            = 'Full Service';
        sc1.sid__c             = '30050001';
        insert sc1;  
        
        User oCurrentUser = [Select Id From User Where Id = :u.Id];
        system.runAs(oCurrentUser)
        {
            ASMContractsDashBoardController  ASMDBCtrl = new ASMContractsDashBoardController();                                      
        }
    }
}