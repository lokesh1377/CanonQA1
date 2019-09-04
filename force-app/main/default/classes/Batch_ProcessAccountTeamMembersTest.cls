@isTest
private class Batch_ProcessAccountTeamMembersTest {
    static testMethod void testFailureEmail() {
        test.startTest();
        
        //Make it fail
        Batch_ProcessAccountTeamMembers oBatch = new Batch_ProcessAccountTeamMembers();
        oBatch.bIsSuccess = false;
        oBatch.sErrorMessage = 'test';
        Database.executeBatch(oBatch);

        test.stopTest();
    }
    
    static testMethod void testUpdateAccountTeamMembersUS() {
        List<Id> lProfileIds = new List<Id>();
        for(Profile oProfile : [Select Id, Name From Profile Where Name Like 'TAMS - %' 
        And (Name Like '%AE' Or Name Like '%ZBM' Or Name Like '%ZVP' Or Name Like '%ZSM')]){
            lProfileIds.add(oProfile.Id);
        }
        
        List<User> lUsers = CreateUsers();
        
        Account oTestAccount;
        //Creating test PortalAccountOwner
        User oPortalAccountOwner = HelperClassTest.PortalAccountOwner();
        System.runAs(oPortalAccountOwner){
            oTestAccount = HelperClassTest.CreatePortalAccount('TestAccount', null, oPortalAccountOwner.Id);
            
            Territory2 oTerritory = [Select Id, Name From Territory2 Where Name Like 'US.%' Limit 1];
            oTestAccount.Territory_Name_TAMS__c = oTerritory.Name;
            update oTestAccount;
            
            //Creating a test equipment
            Install_Base_TAMS__c oTestEquipment = HelperClassTest.CreateEquipment(oTestAccount);
            for(User oUser : lUsers){
                if(oUser.Alias == 'CE'){
                    oTestEquipment.Primary_CE_lookup__c = oUser.Id;
                }
                if(oUser.Alias == 'ASM'){
                    oTestEquipment.ASM_lookup__c = oUser.Id;
                }
            }
            oTestEquipment.SID_TAMS__c = '11111';
            update oTestEquipment;
            
            //Creating a second test equipment
            oTestEquipment = HelperClassTest.CreateEquipment(oTestAccount);
            for(User oUser : lUsers){
                if(oUser.Alias == 'CE'){
                    oTestEquipment.Primary_CE_lookup__c = oUser.Id;
                }
                if(oUser.Alias == 'ASM'){
                    oTestEquipment.ASM_lookup__c = oUser.Id;
                }
            }
            oTestEquipment.SID_TAMS__c = '22222';
            oTestEquipment.Modality_ALL__c = 'VR';
            update oTestEquipment;
        }
        
        test.startTest();
        try{
            System.runAs(oPortalAccountOwner){
            Batch_ProcessAccountTeamMembers oBatch = new Batch_ProcessAccountTeamMembers();
            oBatch.sAccountId = oTestAccount.Id;
            Database.executeBatch(oBatch, 1);
            }
        }catch(exception e){
            System.assert(false, '*****> Error in testUpdateAccountTeamMembersUS: ' + e.getMessage() + '\n stacktrace: \n' + e.getStackTraceString());
        }
        test.stopTest();
    }
    
    static public List<User> CreateUsers(){
        //Creating test Users
        Map<String, Profile> mLookupProfiles = new Map<String, Profile>();
        for(Profile oProfile : [Select Id, Name From Profile Where Name Like 'TAMS - %' 
        And (Name Like '%AE' Or Name Like '%ZBM' Or Name Like '%ZVP' Or Name Like '%ZSM' Or Name Like '%Service Agent User')]){
            
            if(oProfile.Name.endsWith(' AE')){
                mLookupProfiles.put('AE', oProfile);
            }else if(oProfile.Name.endsWith(' ZBM')){
                mLookupProfiles.put('ZBM', oProfile);
            }else if(oProfile.Name.endsWith(' ZVP')){
                mLookupProfiles.put('ZVP', oProfile);
            }else if(oProfile.Name.endsWith(' ZSM')){
                mLookupProfiles.put('ZSM', oProfile);
            }else if(oProfile.Name.endsWith(' User')){
                mLookupProfiles.put('Agent', oProfile);
            }
        }
        
        List<User> lInsertUsers = new List<User>();
        
        User oTestUser = new User(alias='stnd', email='testUserAE@test.com', profileid=mLookupProfiles.get('AE').Id,
            emailencodingkey='UTF-8', firstname='Standard', lastname='lastname', languagelocalekey='en_US', 
            localesidkey='en_US', EmployeeNumber='88888888', isactive=true,
            timezonesidkey='America/Los_Angeles', username='testUserAE@test.com', Modality__c='CT');
        lInsertUsers.add(oTestUser);        
        User oTestUser2 = new User(alias='ZBM1', email='testUser1ZBM@test.com', profileid=mLookupProfiles.get('ZBM').Id,
            emailencodingkey='UTF-8', firstname='Standard', lastname='lastname2', languagelocalekey='en_US', 
            localesidkey='en_US', EmployeeNumber='99999999', isactive=true,
            timezonesidkey='America/Los_Angeles', username='testUser1ZBM@test.com', Modality__c='CT');
        lInsertUsers.add(oTestUser2);
        User oTestUser3 = new User(alias='stnd3', email='testUser3ZVP@test.com', profileid=mLookupProfiles.get('ZVP').Id,
            emailencodingkey='UTF-8', firstname='Standard', lastname='lastname3', languagelocalekey='en_US', 
            localesidkey='en_US', EmployeeNumber='66666666', isactive=true,
            timezonesidkey='America/Los_Angeles', username='testUser3ZVP@test.com', Modality__c='CT');
        lInsertUsers.add(oTestUser3);
        User oTestUser4 = new User(alias='stnd4', email='testUser4ZSM@test.com', profileid=mLookupProfiles.get('ZSM').Id,
            emailencodingkey='UTF-8', firstname='Standard', lastname='lastname4', languagelocalekey='en_US', 
            localesidkey='en_US', EmployeeNumber='55555555', isactive=true,
            timezonesidkey='America/Los_Angeles', username='testUser4ZSM@test.com', Modality__c='CT');
        lInsertUsers.add(oTestUser4);
        User oTestUser5 = new User(alias='ASM', email='testUser5ASM@test.com', profileid=mLookupProfiles.get('Agent').Id,
            emailencodingkey='UTF-8', firstname='Standard', lastname='lastname5', languagelocalekey='en_US', 
            localesidkey='en_US', EmployeeNumber='44444444', isactive=true,
            timezonesidkey='America/Los_Angeles', username='testUser5ASM@test.com', Modality__c='CT');
        lInsertUsers.add(oTestUser5);
        User oTestUser6 = new User(alias='CE', email='testUser6CE@test.com', profileid=mLookupProfiles.get('Agent').Id,
            emailencodingkey='UTF-8', firstname='Standard', lastname='lastname6', languagelocalekey='en_US', 
            localesidkey='en_US', EmployeeNumber='33333333', isactive=true,
            timezonesidkey='America/Los_Angeles', username='testUser6CE@test.com', Modality__c='CT');
        lInsertUsers.add(oTestUser6);        
        User oTestUser7 = new User(alias='ZBM2', email='testUser7ZBM@test.com', profileid=mLookupProfiles.get('ZBM').Id,
            emailencodingkey='UTF-8', firstname='Standard', lastname='lastname7', languagelocalekey='en_US', 
            localesidkey='en_US', EmployeeNumber='99999999', isactive=true,
            timezonesidkey='America/Los_Angeles', username='testUser7ZBM@test.com', Modality__c='MR');
        lInsertUsers.add(oTestUser7);
        User oTestUser8 = new User(alias='ZBM3', email='testUser8ZBM@test.com', profileid=mLookupProfiles.get('ZBM').Id,
            emailencodingkey='UTF-8', firstname='Standard', lastname='lastname8', languagelocalekey='en_US', 
            localesidkey='en_US', EmployeeNumber='99999999', isactive=true,
            timezonesidkey='America/Los_Angeles', username='testUser8ZBM@test.com', Modality__c='UL');
        lInsertUsers.add(oTestUser8);
        User oTestUser9 = new User(alias='ZBM4', email='testUser9ZBM@test.com', profileid=mLookupProfiles.get('ZBM').Id,
            emailencodingkey='UTF-8', firstname='Standard', lastname='lastname9', languagelocalekey='en_US', 
            localesidkey='en_US', EmployeeNumber='99999999', isactive=true,
            timezonesidkey='America/Los_Angeles', username='testUser9ZBM@test.com', Modality__c='XR;VL');
        lInsertUsers.add(oTestUser9);
             
        insert lInsertUsers;
        
        oTestUser.id                = oTestUser.id;
        oTestUser.CT_ZBM_User__c    = oTestUser2.id;
        oTestUser.MR_ZBM_User__c    = oTestUser7.id; 
        oTestUser.UL_ZBM_User__c    = oTestUser8.id;
        oTestUser.XR_VL_ZBM_User__c = oTestUser9.id;   
        
        update oTestUser;
                
        return lInsertUsers;
    }
}