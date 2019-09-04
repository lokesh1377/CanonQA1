/*********************************************************
        Author: NTT Centerstance
        Purpose: This Class is Controller for Strategy Dashboard
        1.0 - Nanda Tumurugoti - 08/20/2013 - Created
        2.0 - Hemant Kumar - 09/17/2015 - Updated
        3.0 - Hemant Kumar - 03/10/2016 - Updated
**********************************************************/

public with sharing class StrategyDashBoard{
    public Account account {get;set;}
    public List<InstallBaseModel> installBases {get;set;}
    Map<String, InstallBaseModel> installBasesMap {get;set;} //Map<Modality+Manufacturer+Range,InstallBasemodel>
    public List<String> Modalities {get;set;}
    public List<String> Companies {get;set;}
    public List<InstallBaseGroup> IBModalityGroups {get;set;} // holds Diffrent IB Model Groups for each Modality.
    public StrategyDashBoard(ApexPages.StandardController sc){
        account = (Account) sc.getRecord();
        system.debug('HK -1: Input Account Details: '+account );
           prepareData();           
    }

    private void prepareData(){
        installBases = new List<InstallBaseModel>();
        installBasesMap = new Map<String, InstallBaseModel>();
        system.debug('HK -2: Inside Data - Account Id : '+account.id);

        String parentAcct = 'N';   
        try{     
            for(Account acc : [select Id, ParentId from Account where id = :account.Id and Type = 'HQ']){
               system.debug('HK -2.1: Inside Select Parent: '+account.id );
               if(acc.ParentId == null){
                  parentAcct = 'Y';
                  system.debug('HK -2: Parent Account = Y : '+parentAcct);
                }
              }  
               system.debug('HK -3: Final Parent Account : '+parentAcct);   
         } catch(Exception e) {
            ErrorLog.storeException(e.getMessage());
        }       
        // Create IB Model cells for Parent Account.
        if(parentAcct == 'Y'){
        try{    
            for(Install_Base_TAMS__c ib : [select Id, Name, Modality_ALL__c, Range__c, Manufacturer_Dashboard__c from Install_Base_TAMS__c where Account_Name__c  in (Select id from account where ParentId = :account.Id) AND Modality_ALL__c != null AND Modality_ALL__c != 'Vital' AND Range__c != '' AND Active_IB__c = true ]){
                String key = ib.Modality_ALL__c+''+ ib.Manufacturer_Dashboard__c+''+ib.Range__c;
                InstallBaseModel ibModel = installBasesMap.get(key);
                if(ibModel==null){
                    String bgImg = ib.Manufacturer_Dashboard__c+(ib.Range__c=='0-2' ? '_Solid' : ib.Range__c=='3-6' ? '_Horizontal' : ib.Range__c=='No Install Date' ? '_Y' : '_Vertical')+'.png';
                    ibModel = new InstallBaseModel(ib.Modality_ALL__c, ib.Manufacturer_Dashboard__c,ib.Range__c,bgImg);
                }
                ibModel.recordCount ++;
                installBasesMap.put(key,ibModel);
            }
            
            for(TAMS_Competitor_IB__c ib : [select Id, Name, Modality_ALL__c, Range__c, Manufacturer_Dashboard__c from TAMS_Competitor_IB__c where Account_Name__c  in (Select id from account where ParentId = :account.Id) AND Modality_ALL__c != null AND Range__c != '' AND Active_IB__c = true ]){
                String key = ib.Modality_ALL__c+''+ ib.Manufacturer_Dashboard__c+''+ib.Range__c;
                InstallBaseModel ibModel = installBasesMap.get(key);
                if(ibModel==null){
                    String bgImg = ib.Manufacturer_Dashboard__c+(ib.Range__c=='0-2' ? '_Solid' : ib.Range__c=='3-6' ? '_Horizontal' : ib.Range__c=='No Install Date' ? '_Y' : '_Vertical')+'.png';
                    ibModel = new InstallBaseModel(ib.Modality_ALL__c, ib.Manufacturer_Dashboard__c,ib.Range__c,bgImg);
                }
                ibModel.recordCount ++;
                installBasesMap.put(key,ibModel);
            }            
        } catch(Exception e) {
            ErrorLog.storeException(e.getMessage());
        }
        }

        // Create IB Model cells for Parent Account.
        if(parentAcct == 'N'){
        try{    
            for(Install_Base_TAMS__c ib : [select Id, Name, Modality_ALL__c, Range__c, Manufacturer_Dashboard__c from Install_Base_TAMS__c where Account_Name__c  = :account.Id AND Modality_ALL__c != null AND Modality_ALL__c != 'Vital' AND Range__c != '' AND Active_IB__c = true ]){
                String key = ib.Modality_ALL__c+''+ ib.Manufacturer_Dashboard__c+''+ib.Range__c;
                InstallBaseModel ibModel = installBasesMap.get(key);
                if(ibModel==null){
                    String bgImg = ib.Manufacturer_Dashboard__c+(ib.Range__c=='0-2' ? '_Solid' : ib.Range__c=='3-6' ? '_Horizontal' : ib.Range__c=='No Install Date' ? '_Y' : '_Vertical')+'.png';
                    ibModel = new InstallBaseModel(ib.Modality_ALL__c, ib.Manufacturer_Dashboard__c,ib.Range__c,bgImg);
                }
                ibModel.recordCount ++;
                installBasesMap.put(key,ibModel);
            }
            
            for(TAMS_Competitor_IB__c ib : [select Id, Name, Modality_ALL__c, Range__c, Manufacturer_Dashboard__c from TAMS_Competitor_IB__c where Account_Name__c = :account.Id AND Modality_ALL__c != null AND Range__c != '' AND Active_IB__c = true ]){
                String key = ib.Modality_ALL__c+''+ ib.Manufacturer_Dashboard__c+''+ib.Range__c;
                InstallBaseModel ibModel = installBasesMap.get(key);
                if(ibModel==null){
                    String bgImg = ib.Manufacturer_Dashboard__c+(ib.Range__c=='0-2' ? '_Solid' : ib.Range__c=='3-6' ? '_Horizontal' : ib.Range__c=='No Install Date' ? '_Y' : '_Vertical')+'.png';
                    ibModel = new InstallBaseModel(ib.Modality_ALL__c, ib.Manufacturer_Dashboard__c,ib.Range__c,bgImg);
                }
                ibModel.recordCount ++;
                installBasesMap.put(key,ibModel);
            }            
        } catch(Exception e) {
            ErrorLog.storeException(e.getMessage());
        }
        }

        // Group cells by Modalities.
        Map<String, InstallBaseGroup> ModalityIBGroupMap = new Map<String, InstallBaseGroup>();
        for(InstallBaseModel ibModel : installBasesMap.values()){
            InstallBaseGroup IBGroup = ModalityIBGroupMap.get(ibModel.Modality); // get IBGroup instance for this Modality
            if(IBGroup==null){ // Create new IBGroup for this Modality if it's not already present
                IBGroup = new InstallBaseGroup(ibModel.Modality);
            }
            IBGroup.models.add(ibModel); // Add the IBModel to the model list of IBGroup of this Modality.
            ModalityIBGroupMap.put(ibModel.Modality,IBGroup); // add it to Map
        }
        IBModalityGroups = ModalityIBGroupMap.values();
        sortModelsByRange();
    }
    
    public void sortModelsByRange(){
        for(InstallBaseGroup ibGroup :IBModalityGroups){
            List<InstallBaseModel> models = ibGroup.models;
            for(Integer i=0;i<models.size();i++){               
                for(Integer j=i+1;j<models.size();j++){                 
                    if(models[i].RangeSortOrder > models[j].RangeSortOrder){
                        //Swap
                        InstallBaseModel ibm = models[i];
                        models[i] = models[j];
                        models[j] = ibm;
                    }                   
                }
            }
        }
    }
    
    public class InstallBaseModel{
        public String Modality {get;set;}
        public String Manufacturer {get;set;}
        public String Range {get;set;}
        public Integer recordCount {get;set;}
        public Integer RangeSortOrder {get;set;}
        public String backgroundImage {get;set;}
        public InstallBaseModel(String Modality, String Manufacturer, String Range, String bg){
            this.Modality = Modality;
            this.Manufacturer = Manufacturer;
            this.Range = Range;
            recordCount = 0;
            backgroundImage =bg; 
            string temp1 = Range == '0-2' ? '1' : Range == '3-6' ? '2' : Range == 'No Install Date' ? '4' :'3';
            string temp2 = Manufacturer == 'Toshiba' ? '1' : Manufacturer == 'GE' ? '2' : Manufacturer == 'Siemens' ? '3' : Manufacturer == 'Phillips' ? '4' : Manufacturer == 'Hitachi' ? '5' : '6';  
            RangeSortOrder = integer.valueOf(temp1 + temp2);
                   
          }
    }
    public class InstallBaseGroup{
        public String Modality {get;set;}
        public List<InstallBaseModel> models {get;set;} // List of cells for this Modality.
        
        public InstallBaseGroup(String Modality){
            this.Modality = Modality;
            models = new List<InstallBaseModel>();
        }
        public Integer getTotalRecordCount(){
            Integer counter = 0;
            for(InstallBaseModel ibm :models){
                counter += ibm.recordCount;
            }
            return counter;
        }
    }
}