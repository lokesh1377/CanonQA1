global class Sch_IBContractExpiryAlert implements Schedulable {
global void execute(SchedulableContext ctx) {
}
/*
   global void execute(SchedulableContext ctx) {
   integer run = 0;
   String tmpstr; 
   List<Profile> ProfileList = [Select p.Id, p.Name from Profile p where p.Name in ('TAMS - AE','TAMS - ZBM','TAMS - UL ZBM','TAMS - ZVP','TAMS - Hybrid')];
      id aeProfile;
      id ulZbmProfile;
      id zbmProfile;
      id zvpProfile;
      id hybridProfile;
      set<id> profiles = new set<id>();
      for (Profile prf :ProfileList){
         profiles.add(prf.id);
         tmpstr = prf.Name;
         if (tmpstr == 'TAMS - AE'){// || tmpstr.contains('TAMS - Hybrid'))
            aeProfile = prf.id;}
         if (tmpstr == 'TAMS - ZBM'){
            zbmProfile = prf.id;}
         if (tmpstr == 'TAMS - UL ZBM'){
            ulZbmProfile = prf.id;}
         if (tmpstr == 'TAMS - ZVP'){
            zvpProfile = prf.id;}
         if(tmpstr == 'TAMS - Hybrid'){
            hybridProfile = prf.id;}
      }
   list<ExpirationPeriod__c> periodList = [Select p.Name, p.Number_Of_Days__c From ExpirationPeriod__c p];
   periodList.sort();
  //Service Contract for {!Install_Base_TAMS__c.Account_Name__c} will Expire in 30 Days 
   for (ExpirationPeriod__c prd : periodlist){
        run = run + 1;
        integer period = Integer.valueOf(prd.Number_Of_Days__c);
        date d = system.today().addDays(+period);  
        Set<String> terrs = new Set<String>(); 
        String terDesc;              
        List<UserRole> RolesList = [Select u.Id, u.Name from UserRole u];
        List<TerritoriesList__c> TerritoriesListAll = [Select t.name, t.Parent_Territory__c from TerritoriesList__c t];
        map<string, string> territoryMap = new map<string, string>();    
        for (TerritoriesList__c tt : TerritoriesListAll){
            territoryMap.put(tt.name, tt.Parent_Territory__c); 
        }                  
//getting list of IB with expiration date on specified day
        List<Install_Base_TAMS__c> InstallBase = [Select i.id, i.Account_Name__c, i.Name, i.Account_Name__r.Territory_Name_TAMS__c,i.Account_Name__r.Name,i.Product_ALL__c,i.SID_TAMS__c, i.Modality_ALL__c,i.Contract_Number_ALL__c,i.Contract_End_Date_ALL__c                                               
                                           From Install_Base_TAMS__c i where i.Contract_End_Date_ALL__c  != null  and i.Manufacturer_ALL__c like 'Toshiba%' and i.Contract_End_Date_ALL__c = : d];  
      if(!InstallBase.isEmpty()){  
         map<Install_Base_TAMS__c, String> IbTerrNameMap = new map<Install_Base_TAMS__c, String>();
         for (Install_Base_TAMS__c ibList : InstallBase){ 
//account ids array for selected Install Base                  
            terDesc = ibList.Account_Name__r.Territory_Name_TAMS__c;
//terDesc = terDesc.right(19); for GAIA in CNFG1       
            terDesc = terDesc.right(19);
            terDesc = terDesc.left(12) + terDesc.right(7);            
            IbTerrNameMap.put(ibList, terDesc);
            terrs.add(terDesc); 
        }        
            set<Id> TerritoryIdSet = new set<Id>(); 
            map<id,string> TerrIdMap = new map<id,string>();            
            map<id,string> TerrParentIdMap = new map<id,string>();
            map<Territory,String> terrMap = new map<Territory,String>();
//getting territories names linked to account            
            List<Territory> TerritoryList = new  List<Territory>([Select t.Id, t.ParentTerritoryId, t.Name From Territory t Where Name in : terrs]);
            for (Territory t: TerritoryList){
               TerritoryIdSet.add(t.Id);
               TerritoryIdSet.add(t.parentTerritoryId); 
               TerrParentIdMap.put(t.ParentTerritoryId, t.Name); 
               TerrIdMap.put(t.Id, t.Name);                            
               terrMap.put(t, t.Name);  
            }   
                                    
            List<Territory> ParentTerritoryList = new  List<Territory>([Select t.Id, t.ParentTerritoryId, t.Name From Territory t Where id in : TerrParentIdMap.keyset()]);
            for (Territory pt : ParentTerritoryList){
                 for (id prt : TerrParentIdMap.keyset()){
                     if (pt.id == prt){                      
                     terrMap.put(pt, TerrParentIdMap.get(prt));}
                }
            }
//======================= assign territory name of the main territory to parent territory and map to the IB =====  
            map<Install_Base_TAMS__c, set<Id>> ibTerritoryMap = new map<Install_Base_TAMS__c, set<Id>>();           
            for (Install_Base_TAMS__c ibt: IbTerrNameMap.keyset()){
                set<Id> TerritoryToIbSet = new set<Id>();          
                tmpstr = IbTerrNameMap.get(ibt);   //territory name
                for (Territory tt: terrMap.keyset()){                    
                    if (tmpstr == terrMap.get(tt)){
                        TerritoryToIbSet.add(tt.Id);
                     }
                }
                ibTerritoryMap.put(ibt, TerritoryToIbSet);   //map IB to territory                         
            }
            map<Install_Base_TAMS__c, set<UserTerritory>> ibUserTerritoryMap = new map<Install_Base_TAMS__c, set<UserTerritory>>();   //map UserTerritory to IB
            set<Id> userIds = new set<Id>();
            List<UserTerritory> UserTerritoryList = new  List<UserTerritory>([Select u.UserId, u.TerritoryId From UserTerritory u Where u.isActive=true and u.TerritoryId in : TerritoryIdSet]);
            for (UserTerritory ut : UserTerritoryList){ 
                 userIds.add(ut.UserId); 
            }     
            for (Install_Base_TAMS__c ibid: ibTerritoryMap.keyset()){
                set<UserTerritory> terrSet = new set<UserTerritory>();
                for(Id tid : ibTerritoryMap.get(ibid)){
                    for (UserTerritory ut1 : UserTerritoryList){ 
                       if (tid == ut1.TerritoryId){
                           terrSet.add(ut1);} 
                    }                                          
                 }
                 ibUserTerritoryMap.put(ibid, terrSet);           
              }                      
            map<Install_Base_TAMS__c, set<User>> ibUserMap = new map<Install_Base_TAMS__c, set<User>>();   //map UserTerritory to IB                       
            List<User> UsersList = new List<User>([Select u.UserRoleId, u.Email, u.Title, u.ProfileId, u.Id From User u where u.id in : userIds and u.ProfileId in : profiles]); 
 //           and (u.Title like '%Account Executive%' or u.Title like '%Mgr Zone Bus%' or u.Title like '%ZBM%' or u.Title like '%Mgr Zone Sls%')]);              
            for (Install_Base_TAMS__c it :ibUserTerritoryMap.keyset()){
                 set<User> allUsersSet = new set<User>();
                 for(UserTerritory tt1 : ibUserTerritoryMap.get(it)){
                     for(User u: UsersList){                   
                         if (tt1.UserId == u.Id){
                             allUsersSet.add(u);}                             
                     }                   
                 } 
                 ibUserMap.put(it, allUsersSet);    
            }                                   
       map<Install_Base_TAMS__c, Set<String>> ibEmailsMap = new map<Install_Base_TAMS__c, Set<String>>();                         
        for (Install_Base_TAMS__c ib : ibUserMap.keyset()){
            set<string> roleIds = new set<string>();
            getRoleIds(ib.Account_Name__r.Territory_Name_TAMS__c, roleIds, territoryMap, RolesList);  
            string modality = ib.Modality_ALL__c;
            set<string> emails = new set<string>();
            string tmpEmailStr = '';              
            for (User uu : ibUserMap.get(ib)){ 
                string title = uu.Title; 
                id profileId = uu.ProfileId; 
                string role = uu.UserRoleId;
// geting ae email
             if (roleIds.contains(role)){
                if (profileId == aeProfile){           
                   emails.add(uu.Email);
                   tmpEmailStr = tmpEmailStr + uu.Email + ',';
                }
//getting zvp email        
                 if (profileId == zvpProfile){
                    emails.add(uu.Email); 
                    tmpEmailStr = tmpEmailStr + uu.Email + ',';
                 }
//getting zbm emails 
                 if (profileId == zbmProfile){
                      if ((modality == 'VL' && title.contains('CVXR')) || (modality != 'VL' && title.contains(modality))){
                         emails.add(uu.Email); 
                         tmpEmailStr = tmpEmailStr + uu.Email + ',';
                      } 
                  }                  
         //getting zbm emails            
                 if (profileId == ulZbmProfile && modality == 'UL'){
                     emails.add(uu.Email); 
                     tmpEmailStr = tmpEmailStr + uu.Email + ',';
                 } 
                  if (profileId == hybridProfile){
                      if( title.contains('Mgr Zone Bus')){                            
                          if ((modality == 'VL' && title.contains('CVXR')) || (modality != 'VL' && title.contains(modality))){              
                              emails.add(uu.Email); 
                               tmpEmailStr = tmpEmailStr + uu.Email + ',';
                          }    
                      }else{
                           If (title.contains('Account Executive')){
                              emails.add(uu.Email); 
                              tmpEmailStr = tmpEmailStr + uu.Email + ',';
                           }    
                      } 
                 }                      
            }
        }       
        ibEmailsMap.put(ib, emails);    
              
        if(run == 1){
            ib.IB_Contract_Expiration_30_To__c = tmpEmailStr;                 
            ib.IB_Contract_Expiration_30_On__c = system.today();        
        } 
        if (run == 2){                 
            ib.IB_Contract_Expiration_60_To__c = tmpEmailStr;                 
            ib.IB_Contract_Expiration_60_On__c = system.today();             
        }
        if (run == 3){                 
            ib.IB_Contract_Expiration_90_To__c = tmpEmailStr;                 
            ib.IB_Contract_Expiration_90_On__c = system.today();             
        } 
        if (run == 4){                 
            ib.IB_Contract_Expiration_120_To__c = tmpEmailStr;                 
            ib.IB_Contract_Expiration_120_On__c = system.today();             
        }             
        update ib;   
    }  
        sendNotificationEmail(ibEmailsMap, period); 
        }
    } 
} 
    public void sendNotificationEmail(map<Install_Base_TAMS__c, Set<String>> ibEmailsMap, integer period){
   
    Contact con = new Contact();              
    con.FirstName = 'Test';       
    con.LastName = 'Contact';       
    con.Email = 'no-reply@organization.com';       
    insert con;
    
    set<String> allEmails = new set<String>();
    map<id, string> emailBody = new map<id, string>();
    map<id, string> emailSubject = new map<id, string>();
    map<id, set<string>> emailSendTo = new map<id, set<string>>();
    List<Messaging.SingleEmailMessage> allMails = new List<Messaging.SingleEmailMessage>();
    for(Install_Base_TAMS__c ibItem : ibEmailsMap.keyset()){
       List<String> toAddress = new List<String>(); 
       String accountURL = URL.getSalesforceBaseUrl().toExternalForm() + '/' + ibItem.Account_Name__c;
       String ibURL = URL.getSalesforceBaseUrl().toExternalForm() + '/' + ibItem.id;
       Date endDate = ibItem.Contract_End_Date_ALL__c;
       string tmpbody = '<html lang="ja"><body>'+                          
        '<br>'+'The Service Contract for the following Account will expire in ' + string.valueOf(period) + ' days.'+
        '<br><br>'+'Account: '+ '<a href=' + accountURL + '>' + ibItem.Account_Name__r.Name + '</a>' +
        '<br>'+'Modality: '+ ibItem.Modality_ALL__c + 
        '<br>'+'Product: '+ ibItem.Product_ALL__c + 
        '<br>'+'SID: '+ '<a href=' + ibURL + '>' + ibItem.SID_TAMS__c + '</a>' +   
        '<br>'+'Contract Number: '+ ibItem.Contract_Number_ALL__c +
        '<br>'+'Contract End Date: '+ String.valueOf(endDate)+'</body></html>';         
       string tmpSubject = 'Service Contract for '+ ibItem.Account_Name__r.Name +' will Expire in '+String.valueOf(period)+' Days';
       for (string em :ibEmailsMap.get(ibItem)){
           toAddress.add(em);
//           toAddress.add('jpark@tams.com');//em);
//           toAddress.add('HKumar@tams.com');//em);
       } 
            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
            mail.setToAddresses(toAddress);
            mail.setTargetObjectID(con.id);
       // mail.setCcAddresses(ccAddresses);
            mail.setHtmlBody(tmpbody); 
            mail.setSubject(tmpSubject);
            mail.setReplyTo('compass@noreply.com');
            mail.setSenderDisplayName('Compass Automatic Notification');        
            mail.saveAsActivity = false; 
            allMails.add(mail); 
        }
            Messaging.sendEmail(allMails);    
            delete con;             
    } 
           public void getRoleIds(string territory, set<string> roleIds, map<string, string> territoryMap, list<UserRole> RolesList){  
        //List<UserRole> RolesList = [Select u.Id, u.Name from UserRole u];
          string zone;
          string tmpstr;
          string roleName;
          if (territory.contains('US.')){
              tmpstr = territory.right(19);
              tmpstr = tmpstr.left(5);
              tmpstr = tmpstr.right(2);
          }else{
              tmpstr = territory.toUpperCase();
          }
          for(string zn :territoryMap.keyset()){
              if (zn == tmpstr){
                  zone = territoryMap.get(zn);       
                  for (UserRole r :RolesList){
                      roleName = r.Name;
                      if (roleName.contains(zone)){
                          roleIds.add(r.Id);      
                       }
                  }
              }    
           }   
       } */
}