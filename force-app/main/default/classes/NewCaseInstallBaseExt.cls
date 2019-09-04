/**
  * Extension Class object for Visualforce page.
  * Used By: NewCaseInstallBase
  * @author NTT Data: Louis Wooldridge
  * @date July 9, 2015
  * @update
  * @5/19/2016 Hemant Kumar For 10PM to 5AM Message
  */
public class NewCaseInstallBaseExt {
    //The store record accessed through the standard controller
    public Install_Base_TAMS__c oInstallBase {get; set;}
    public String sRecordTypeId {get; set;}
    private List<RecordType> lRecordTypes = new List<RecordType>();
    public class RecTypeRow{
        public String sName {get; set;}
        public String sDescription {get; set;}
    }
    public List<RecTypeRow> lRecTypes {get; set;}
    public String DisplayFlag {get;set;}
          
    public NewCaseInstallBaseExt(ApexPages.StandardController stdController){
        this.oInstallBase = (Install_Base_TAMS__c)stdController.getRecord();
        LoadRecordTypes();
        SdisplayFlag();
    }
    
    private void LoadRecordTypes(){
    try{
        lRecTypes = new List<RecTypeRow>();
        
        for(RecordType oRecType : [Select Id, Name, Description From RecordType Where SobjectType = 'Case' 
        And DeveloperName In('Engineer_Dispatch', 'Solution_Center_Support')]){
            lRecordTypes.add(oRecType);
            RecTypeRow oRT = new RecTypeRow();
            oRT.sName = oRecType.Name;
            oRT.sDescription = oRecType.Description;
            lRecTypes.add(oRT);
        }
    }catch(Exception e){ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'Error: ' + e.getMessage()));}
    }
    
    private void SdisplayFlag(){
       DisplayFlag = 'false';
       Datetime cDT = System.now();
       system.debug('The current Time is :'+cDT);       
       Integer cH = cDT.hourGMT();
       system.debug('The current G Hours is :'+cH);
       system.debug('The current Before if sDisplay is :'+DisplayFlag);  
       if (cH >= 5 && cH<= 12){
         DisplayFlag = 'true';
         system.debug('The current Inside if sDisplay is :'+DisplayFlag);  
       } 
       system.debug('The current After if sDisplay is :'+DisplayFlag);                  
    } 
    
    private Map<String, String> RetrieveUserInfo(){
    try{
        Map<String, String> mReturnValue = new Map<String, String>();
        mReturnValue.put('Account', '');
        mReturnValue.put('Contact', '');
        
        List<User> lUsers = [Select ContactId From User Where Id = :UserInfo.getUserId()];
        if(lUsers.isEmpty() == false){
            Contact oContact = [Select Account.Name, Name From Contact Where Id = :lUsers[0].ContactId];
            mReturnValue.put('Account', oContact.Account.Name);
            mReturnValue.put('Contact', oContact.Name);
        }
        
        return mReturnValue;
    }catch(Exception e){ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'Error: ' + e.getMessage())); return null;}
    }
    
    public PageReference SaveCase(){
    try{
        Map<String, String> mUserInfo = RetrieveUserInfo();
        String sInstallBaseName = [Select Name From Install_Base_TAMS__c Where Id = :oInstallBase.Id].Name;
        
        //Make sure check/update InstallBase field name for each org
        PageReference oNewCasePage = new PageReference('/500/e?nooverride=1&retURL=500&RecordType=' + sRecordTypeId 
            + '&cas4=' + mUserInfo.get('Account') + '&cas3=' + mUserInfo.get('Contact')
            + '&CF00Ni000000GOgjP=' + sInstallBaseName);
            
        oNewCasePage.setRedirect(true);
        return oNewCasePage;
    }catch(Exception e){ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'Error: ' + e.getMessage())); return null;}
    }
    
    public PageReference CancelCase(){
        PageReference oNewCasePage = new PageReference('/500/o');
        oNewCasePage.setRedirect(true);
        return oNewCasePage;
    }
    
    public List<SelectOption> getRecordTypes(){
        List<SelectOption> options = new List<SelectOption>();
        for(RecordType oRecType : lRecordTypes){
            options.add(new SelectOption(oRecType.Id,oRecType.Name));
        }
        return options;
    }
}