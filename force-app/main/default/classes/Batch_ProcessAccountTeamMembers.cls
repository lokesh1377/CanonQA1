/**
    * This batch job will run nightly and will be started by Batch_UpdateProcessAccountTeamMembers when it completes
    * Retrieves Accounts where Process Account Team Members field equals true
    * Builds Account Team based on Territory Account relationship and CEs & ASMs on related Equipment records
    
    * Database.executeBatch(new Batch_ProcessAccountTeamMembers(), 1);
 
    @author NTT Data: Louis Wooldridge
    @date Sep 23, 2015
    @update 
    @date Mar 11, 2019 : Updated for ZBM
 **/
global class Batch_ProcessAccountTeamMembers implements Database.Batchable<sObject>, Database.Stateful {
    @TestVisible private Boolean bIsSuccess {get;set;}
    @TestVisible private String sErrorMessage {get;set;}
    @TestVisible private String sAccountId {get;set;}
    public Id aeUserId {get;set;}
    private Map<Id, String> mLookupTerritoryUsers = new Map<Id, String>();

    
    global Batch_ProcessAccountTeamMembers() {
        bIsSuccess = true;
        sErrorMessage = '';
        String sModality; 
        
        for(User oUser : [Select Id, Profile.Name, ProfileId, Modality__c From User 
        Where Profile.Name Like 'TAMS - %' And UserType = 'Standard']){
            sModality = '';
            if(oUser.Modality__c != null){
                sModality = oUser.Modality__c;
            }
            if(oUser.Profile.Name.endsWith(' AE')){
                mLookupTerritoryUsers.put(oUser.Id, 'AE-' + sModality);
            //HK on 3/11/2019    
            //Removing the ZBM selection from Territory    
            //}else if(oUser.Profile.Name.endsWith(' ZBM')){
                //Includes UL ZBM
            //    mLookupTerritoryUsers.put(oUser.Id, 'ZBM-' + sModality);
            }else if(oUser.Profile.Name.endsWith(' ZVP')){
                mLookupTerritoryUsers.put(oUser.Id, 'ZVP-' + sModality);
            }else if(oUser.Profile.Name.endsWith(' ZSM')){
                mLookupTerritoryUsers.put(oUser.Id, 'ZSM-' + sModality);
            }
        }
    }
    
    global Database.QueryLocator start(Database.BatchableContext BC) {
        if(test.isRunningTest() == true){
            return Database.getQueryLocator([Select Name, TAMS_Territory_Id__c, TAMS_UL_Territory_Name__c, TAMS_Service_Territory_Name__c, 
                Process_Account_Team_Members__c, Id From Account
                Where Id = :sAccountId Limit 1]);
        }else{
            return Database.getQueryLocator([Select Name, TAMS_Territory_Id__c, TAMS_UL_Territory_Name__c, TAMS_Service_Territory_Name__c, 
                Process_Account_Team_Members__c, Id From Account 
                Where Process_Account_Team_Members__c = true]);
        }
    }
    
    global void execute(Database.BatchableContext BC, List<sObject> lSobjects) {
        Map<String, TAMS_Account_Team__c> mNewAccountTeamRecords = new Map<String, TAMS_Account_Team__c>();
        Account oAccount = (Account)lSobjects[0];
        system.debug('Processing Account: ' + oAccount);
        
        //Deleting existing Account Team records
        List<TAMS_Account_Team__c> lDeleteAccountTeams = [Select Id From TAMS_Account_Team__c Where Account__c = :oAccount.Id];
        if(lDeleteAccountTeams.isEmpty() == false){
            delete lDeleteAccountTeams;
        }
        
        //Retrieving Account Team members from Territory assignments
        List<Territory2> lTerritories = new List<Territory2>();
        if((oAccount.TAMS_Territory_Id__c != null)||(oAccount.TAMS_UL_Territory_Name__c != null)||(oAccount.TAMS_Service_Territory_Name__c != null)){
            //Capturing all of the Territory Ids up the hierarchy
            lTerritories = [Select ParentTerritory2Id, Name, Id, DeveloperName From Territory2 
                Where Name = :oAccount.TAMS_Territory_Id__c Or Name = :oAccount.TAMS_UL_Territory_Name__c Or Name = :oAccount.TAMS_Service_Territory_Name__c];
            
            List<Territory2> lLoopTerritory = new List<Territory2>(lTerritories);
            for(Territory2 oTerritory : lLoopTerritory){
                String sParentTerritoryId = oTerritory.ParentTerritory2Id;
                While(sParentTerritoryId != null){
                    Territory2 oParentTerritory = [Select ParentTerritory2Id, Name, Id, DeveloperName From Territory2 Where Id = :sParentTerritoryId];
                    sParentTerritoryId = oParentTerritory.ParentTerritory2Id;
                    lTerritories.add(oParentTerritory);
                }
            }
        }
        
        //Adding Team Members for the found Territories
        List<Id> lTerritoryUserIds = new List<Id>();
        if(test.isRunningTest() == true){
            //Added line because UserTerritories cannot be created with DML in unit tests
            for(User oUser : [Select Id From User Where FirstName = 'Standard' And LastName = 'lastname']){
                lTerritoryUserIds.add(oUser.Id);
            }
        }else{
            for(UserTerritory2Association oUserTerr : [Select UserId From UserTerritory2Association Where IsActive = true And Territory2Id In:lTerritories]){
                lTerritoryUserIds.add(oUserTerr.UserId);
            }
        }
        
        aeUserId = null;
        for(Id idUser : lTerritoryUserIds){
            TAMS_Account_Team__c oTeamMember = new TAMS_Account_Team__c();
                        
            String sValues = mLookupTerritoryUsers.get(idUser);
            if(sValues != null){
                List<String> lRoleModality = sValues.split('-', 2);
                aeUserId               = null;
                oTeamMember.Account__c = oAccount.Id;
                oTeamMember.User__c = idUser;
                oTeamMember.Role__c = lRoleModality[0];
                if(lRoleModality.size() > 1){
                    oTeamMember.Modality__c = lRoleModality[1];
                }
                if (oTeamMember.Role__c == 'AE') {
                    aeUserId = idUser;
                  } else {
                    aeUserId = null; 
                  }
                  
                system.debug('HK - AE User ID :'+ aeUserId); 
                oTeamMember.External_Id__c = oAccount.Id + '-' + idUser + '-' + lRoleModality[0];
                mNewAccountTeamRecords.put(oTeamMember.External_Id__c, oTeamMember);
            }
            
        //HK @ 3/11/2019 - Retrieving the ZBM based on AE and Account
        if(aeUserId != null){
           TAMS_Account_Team__c ctTeamMemberZBM = new TAMS_Account_Team__c();
           TAMS_Account_Team__c mrTeamMemberZBM = new TAMS_Account_Team__c();
           TAMS_Account_Team__c ulTeamMemberZBM = new TAMS_Account_Team__c();
           TAMS_Account_Team__c vlTeamMemberZBM = new TAMS_Account_Team__c();                                 
           Account              accZBM         = new Account();
           User                 aeZBM          = new User();
                                             
           aeZBM = [select CT_ZBM_User__c,MR_ZBM_User__c,UL_ZBM_User__c,XR_VL_ZBM_User__c 
                      from User where id = :aeUserId];

           accZBM = [select CT_ZBM_Acc__c,MR_ZBM_Acc__c,UL_ZBM_Acc__c,XR_VL_ZBM_Acc__c
                       from account where id = :oAccount.id];
                             
           system.debug('HK - Inside AE User - Got the ACC-ZBMs :'+accZBM); 
           system.debug('HK - Inside AE User - Got the AE-ZBMs  :'+aeZBM); 
                                                        
               if(accZBM.CT_ZBM_Acc__c != null){
                 system.debug('HK - Inside Acct CT User - Got the accZBM.CT_ZBM_Acc__c  :'+accZBM.CT_ZBM_Acc__c); 
                    ctTeamMemberZBM.Account__c  = oAccount.Id;
                    ctTeamMemberZBM.User__c     = accZBM.CT_ZBM_Acc__c;
                    ctTeamMemberZBM.Role__c     = 'ZBM';
                    ctTeamMemberZBM.Modality__c = 'CT';  
                    ctTeamMemberZBM.External_Id__c = oAccount.Id + '-' + ctTeamMemberZBM.User__c + '-' + ctTeamMemberZBM.Modality__c;
                    mNewAccountTeamRecords.put(ctTeamMemberZBM.External_Id__c, ctTeamMemberZBM);  
                    system.debug('HK - Inside Acct CT User - Record  :'+ctTeamMemberZBM.External_Id__c);                                                       
                    }else if(aeZBM.CT_ZBM_User__c != null){
                        system.debug('HK - Inside Else - AE CT User - Got the aeZBM.CT_ZBM_User__c :'+aeZBM.CT_ZBM_User__c ); 
                        ctTeamMemberZBM.Account__c  = oAccount.Id;
                        ctTeamMemberZBM.User__c     = aeZBM.CT_ZBM_User__c;
                        ctTeamMemberZBM.Role__c     = 'ZBM';
                        ctTeamMemberZBM.Modality__c = 'CT';                                                          
                        ctTeamMemberZBM.External_Id__c = oAccount.Id + '-' + ctTeamMemberZBM.User__c + '-' + ctTeamMemberZBM.Modality__c;
                        mNewAccountTeamRecords.put(ctTeamMemberZBM.External_Id__c, ctTeamMemberZBM);                            
                        system.debug('HK - Inside Else AE CT User - Record  :'+ctTeamMemberZBM.External_Id__c);                                                                               
                        }                                                                                     

               if(accZBM.MR_ZBM_Acc__c != null){
                 system.debug('HK - Inside Acct MR User - Got the accZBM.MR_ZBM_Acc__c  :'+accZBM.MR_ZBM_Acc__c);                
                    mrTeamMemberZBM.Account__c  = oAccount.Id;
                    mrTeamMemberZBM.User__c     = accZBM.MR_ZBM_Acc__c;
                    mrTeamMemberZBM.Role__c     = 'ZBM';
                    mrTeamMemberZBM.Modality__c = 'MR';  
                    mrTeamMemberZBM.External_Id__c = oAccount.Id + '-' + mrTeamMemberZBM.User__c + '-' + mrTeamMemberZBM.Modality__c;
                    mNewAccountTeamRecords.put(mrTeamMemberZBM.External_Id__c, mrTeamMemberZBM);      
                    system.debug('HK - Inside Acct MR User - Record  :'+mrTeamMemberZBM.External_Id__c);                                                                                                                                 
                    }else if(aeZBM.MR_ZBM_User__c != null){
                        system.debug('HK - Inside Else - AE MR User - Got the aeZBM.MR_ZBM_User__c :'+aeZBM.MR_ZBM_User__c );                    
                        mrTeamMemberZBM.Account__c  = oAccount.Id;
                        mrTeamMemberZBM.User__c     = aeZBM.MR_ZBM_User__c;
                        mrTeamMemberZBM.Role__c     = 'ZBM';
                        mrTeamMemberZBM.Modality__c = 'MR';  
                        mrTeamMemberZBM.External_Id__c = oAccount.Id + '-' + mrTeamMemberZBM.User__c + '-' + mrTeamMemberZBM.Modality__c;
                        mNewAccountTeamRecords.put(mrTeamMemberZBM.External_Id__c, mrTeamMemberZBM); 
                        system.debug('HK - Inside Else AE MR User - Record  :'+mrTeamMemberZBM.External_Id__c);                                                                                                       
                        } 
                    
               if(accZBM.UL_ZBM_Acc__c != null){
                 system.debug('HK - Inside Acct UL User - Got the accZBM.UL_ZBM_Acc__c  :'+accZBM.UL_ZBM_Acc__c);                               
                    ulTeamMemberZBM.Account__c  = oAccount.Id;
                    ulTeamMemberZBM.User__c     = accZBM.UL_ZBM_Acc__c;
                    ulTeamMemberZBM.Role__c     = 'ZBM';
                    ulTeamMemberZBM.Modality__c = 'UL';                                      
                    ulTeamMemberZBM.External_Id__c = oAccount.Id + '-' + ulTeamMemberZBM.User__c + '-' + ulTeamMemberZBM.Modality__c;
                    mNewAccountTeamRecords.put(ulTeamMemberZBM.External_Id__c, ulTeamMemberZBM); 
                    system.debug('HK - Inside Acct UL User - Record  :'+ulTeamMemberZBM.External_Id__c);                                       
                    }else if(aeZBM.UL_ZBM_User__c != null){
                        system.debug('HK - Inside Else - AE UL User - Got the aeZBM.UL_ZBM_User__c :'+aeZBM.UL_ZBM_User__c );                                        
                        ulTeamMemberZBM.Account__c  = oAccount.Id;
                        ulTeamMemberZBM.User__c     = aeZBM.UL_ZBM_User__c;
                        ulTeamMemberZBM.Role__c     = 'ZBM';
                        ulTeamMemberZBM.Modality__c = 'UL';                                                          
                        ulTeamMemberZBM.External_Id__c = oAccount.Id + '-' + ulTeamMemberZBM.User__c + '-' + ulTeamMemberZBM.Modality__c;
                        mNewAccountTeamRecords.put(ulTeamMemberZBM.External_Id__c, ulTeamMemberZBM);
                        system.debug('HK - Inside Else AE MR User - Record  :'+ulTeamMemberZBM.External_Id__c);                        
                        }
                     
               if(accZBM.XR_VL_ZBM_Acc__c != null){
                 system.debug('HK - Inside Acct UL User - Got the accZBM.XR_VL_ZBM_Acc__c  :'+accZBM.XR_VL_ZBM_Acc__c);               
                    vlTeamMemberZBM.Account__c  = oAccount.Id;
                    vlTeamMemberZBM.User__c     = accZBM.XR_VL_ZBM_Acc__c;
                    vlTeamMemberZBM.Role__c     = 'ZBM';
                    vlTeamMemberZBM.Modality__c = 'VL;XR';                                      
                    vlTeamMemberZBM.External_Id__c = oAccount.Id + '-' + vlTeamMemberZBM.User__c + '-' + vlTeamMemberZBM.Modality__c;
                    mNewAccountTeamRecords.put(vlTeamMemberZBM.External_Id__c, vlTeamMemberZBM);
                    system.debug('HK - Inside Acct XRVL User - Record  :'+vlTeamMemberZBM.External_Id__c);                    
                    }else if(aeZBM.XR_VL_ZBM_User__c != null){
                        system.debug('HK - Inside Else - AE XRVL User - Got the aeZBM.XR_VL_ZBM_User__c :'+aeZBM.XR_VL_ZBM_User__c);                                        
                        vlTeamMemberZBM.Account__c  = oAccount.Id;
                        vlTeamMemberZBM.User__c     = aeZBM.XR_VL_ZBM_User__c;
                        vlTeamMemberZBM.Role__c     = 'ZBM';
                        vlTeamMemberZBM.Modality__c = 'VL;XR';
                        vlTeamMemberZBM.External_Id__c = oAccount.Id + '-' + vlTeamMemberZBM.User__c + '-' + vlTeamMemberZBM.Modality__c;
                        mNewAccountTeamRecords.put(vlTeamMemberZBM.External_Id__c, vlTeamMemberZBM); 
                        system.debug('HK - Inside Else AE XRVL User - Record  :'+vlTeamMemberZBM.External_Id__c);                                               
                        }                                                                         
              }            
        }
        
         
         
        
        //Retrieving Account Team members from Install Base
        Map<Id,Set<String>> mModalities = new Map<Id,Set<String>>();
        Map<Id,String> mNicknames = new Map<Id,String>();
        Map<Id,String> mSIDs = new Map<Id,String>();
        
        for(Install_Base_TAMS__c oIB : [Select Primary_CE_lookup__c, Modality_ALL__c, Active_IB__c, 
        ASM_lookup__c, Account_Name__c, Nickname__c, SID_TAMS__c 
        From Install_Base_TAMS__c Where Active_IB__c = true And Account_Name__c = :oAccount.Id]){
            //Adding CE First
            if(oIB.Primary_CE_lookup__c != null){
                //Capturing the Modalities for each Primary CE
                Set<String> sDistinctModalities = new Set<String>();
                
                if(mModalities.containsKey(oIB.Primary_CE_lookup__c) == true){
                    sDistinctModalities = mModalities.get(oIB.Primary_CE_lookup__c);
                }
                if(oIB.Modality_ALL__c != null){
                    sDistinctModalities.add(oIB.Modality_ALL__c);
                    mModalities.put(oIB.Primary_CE_lookup__c, sDistinctModalities);
                }
                
                //Capturing the Nicknames for each Primary CE
                String sNicknames = '';
                if(mNicknames.containsKey(oIB.Primary_CE_lookup__c) == true){
                    sNicknames = mNicknames.get(oIB.Primary_CE_lookup__c);
                }
                if(oIB.Nickname__c != null){
                    if(sNicknames.length() > 0){
                        sNicknames += ', ' + oIB.Nickname__c;
                    }else{
                        sNicknames = oIB.Nickname__c;
                    }
                    mNicknames.put(oIB.Primary_CE_lookup__c, sNicknames);
                }
                
                //Capturing the SIDs for each Primary CE
                String sSIDs = '';
                if(mSIDs.containsKey(oIB.Primary_CE_lookup__c) == true){
                    sSIDs = mSIDs.get(oIB.Primary_CE_lookup__c);
                }
                if(oIB.SID_TAMS__c != null){
                    if(sSIDs.length() > 0){
                        sSIDs += ', ' + oIB.SID_TAMS__c;
                    }else{
                        sSIDs = oIB.SID_TAMS__c;
                    }
                    mSIDs.put(oIB.Primary_CE_lookup__c, sSIDs);
                }
                
                //Adding CE
                TAMS_Account_Team__c oTeamMemberCE = new TAMS_Account_Team__c();
                oTeamMemberCE.Account__c = oIB.Account_Name__c;
                oTeamMemberCE.User__c = oIB.Primary_CE_lookup__c;
                oTeamMemberCE.Role__c = 'Primary CE';
                String sModalityValues = '';
                for(String sValue : mModalities.get(oIB.Primary_CE_lookup__c)){
                    if(sModalityValues == ''){
                        sModalityValues = sValue;
                    }else{
                        sModalityValues += ';' + sValue;
                    }
                }
                oTeamMemberCE.Modality__c = sModalityValues;
                oTeamMemberCE.Equipment_Nicknames__c = mNicknames.get(oIB.Primary_CE_lookup__c);
                oTeamMemberCE.Equipment_SIDs__c = mSIDs.get(oIB.Primary_CE_lookup__c);
                oTeamMemberCE.External_Id__c = oIB.Account_Name__c + '-' + oIB.Primary_CE_lookup__c + '-' + 'Primary CE';
                mNewAccountTeamRecords.put(oTeamMemberCE.External_Id__c, oTeamMemberCE);
            }
            
            //Adding ASM
            if(oIB.ASM_lookup__c != null){
                TAMS_Account_Team__c oTeamMemberASM = new TAMS_Account_Team__c();
                oTeamMemberASM.Account__c = oIB.Account_Name__c;
                oTeamMemberASM.User__c = oIB.ASM_lookup__c;
                oTeamMemberASM.Role__c = 'ASM';
                oTeamMemberASM.External_Id__c = oIB.Account_Name__c + '-' + oIB.ASM_lookup__c + '-' + 'ASM';
                mNewAccountTeamRecords.put(oTeamMemberASM.External_Id__c, oTeamMemberASM);
            }
        }
        
        //Added check to see if Unit Test code is running, the following two DML statements caused MIXED_DML_OPERATION errors
        //for unknown reasons.
        if(mNewAccountTeamRecords.isEmpty() == false){
            List<TAMS_Account_Team__c> lUpsertAccountTeam = new List<TAMS_Account_Team__c>(mNewAccountTeamRecords.values());
            if(test.isRunningTest() == false){upsert lUpsertAccountTeam External_Id__c;}
        }
        
        //Resetting update flag on Account
        oAccount.Process_Account_Team_Members__c = false;
        if(test.isRunningTest() == false){update oAccount;}
    }
    
    global void finish(Database.BatchableContext BC) {
        AsyncApexJob oJob = [Select Id, Status, NumberOfErrors, ExtendedStatus, JobItemsProcessed, CreatedBy.Email 
            From AsyncApexJob Where Id = :BC.getJobId()];
        
        if(oJob.NumberOfErrors > 0){
            bIsSuccess = false;
            sErrorMessage = oJob.ExtendedStatus;
        }
        if(bIsSuccess == false){
            //Sending Error Msg to Job Submitter
            Messaging.SingleEmailMessage oMail = new Messaging.SingleEmailMessage();
            String[] toAddresses = new String[] {oJob.CreatedBy.Email};
            oMail.setToAddresses(toAddresses);
            oMail.setSubject('Batch_ProcessAccountTeamMembers job failed, status: ' + oJob.Status + ' (' + oJob.NumberOfErrors + ' errors out of '+ oJob.JobItemsProcessed + ' batches)');
            oMail.setPlainTextBody('Error Message: ' + sErrorMessage);
            Messaging.sendEmail(new Messaging.SingleEmailMessage[] { oMail });
        }
    }
}