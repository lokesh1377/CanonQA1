/*********************************************************
        Author:         
        Purpose: This Class is used in Creating Change Order From Account.        
        1.0 - Lokesh Tigulla              - Created
        1.1 - Lokesh Tigulla - 02/19/2019 - updated
        1.2 - Lokesh Tigulla - 03/13/2019 - updated(Related Change Orders)
        1.3 - Lokesh Tigulla - 04/04/2019 - updated(Saving PBom)
**********************************************************/
public with sharing class ChangeOrderExt {
 private Account acct;
 public String bookId {get;set;}
 public Decimal sidNumber {get;set;}
 public Boolean showChangeRequestedBy {get;set;}
 public Boolean showSID {get;set;}
 public Boolean showChangeorderExternal {get;set;}
 public Boolean showChangeOrderInternal {get;set;}
 public String accountNumber {get;set;}
 private Id accountId {get;set;}
 public Change_Order_OFA__c coOfa {get;set;}
 public Boolean showotherSID {get;set;}
 public Boolean showOrderNUmber {get;set;}
 public Boolean showOA {get;set;}
 public TAMS_ROA__c newChangeOrderHeader {get;set;}
 public Id customerId {get;set;}
 private Set<Order_Master__c> sOrderMaster;
 public String pbom {get;set;}
    public ChangeOrderExt(ApexPages.StandardController stdController) {
         this.acct =  (Account)stdController.getRecord();
         this.accountNumber = acct.TAMS_Account_Number_TAMS__c;
         this.accountId = acct.id;
         this.showChangeorderExternal = false;
         this.showChangeOrderInternal = false;
         System.debug('accountId'+accountId);
         newChangeOrderHeader = new TAMS_ROA__c();
         coOfa = new Change_Order_OFA__c();
         sOrderMaster = new Set<Order_Master__c>();
         for(Order_Master__c orderMaster: [SELECT 
                                                Id
                                                ,Customer_Name__c
                                                ,SID_Order__c
                                           FROM 
                                                Order_Master__c 
                                           where 
                                                Account_Number_Order__c =: accountNumber
                                                ]){
            sOrderMaster.add(orderMaster);
            System.debug('sOrderMaster'+sOrderMaster);
         }
      }
            
     public pagereference saveOrder()
    {      
      System.debug('Inside Save');
        System.debug('sidNumber'+sidNumber);
        System.debug('Sid Number Id'+bookId);
        List<Order_Master__c> lModality = [Select Id,Modality_Order__c From Order_Master__c Where SID_Order__c =: sidNumber];
        System.debug('Modality:'+lModality);
        //sid not null and if sid number populate , then check for valid sid
        if(newChangeOrderHeader.ROA_Type__c != 'Other'){
           if(isvalidSid(sidNumber) && isRequriedFieldsPopulated(newChangeOrderHeader)){
             System.debug('customerId'+customerId);
              newChangeOrderHeader.Account__c = customerId;
              newChangeOrderHeader.change_order_sid__c = String.valueOf(sidNumber);
              newChangeOrderHeader.COH_Modality__c = lModality.get(0).Modality_Order__c;
              List<Opportunity> lPbom = [select PBOM__c From Opportunity Where SID_TAMS__c =: String.valueOf(sidNumber)];
               if(lPbom.isEmpty()){
                   List<Order_Financial_Analysis__c> lofa = [select PBOM__c From Order_Financial_Analysis__c Where SID__c =: String.valueOf(sidNumber)];
                  newChangeOrderHeader.COH_PBOM__c = lofa.get(0).PBOM__c; 
               }else{
                    newChangeOrderHeader.COH_PBOM__c = lPbom.get(0).PBOM__c;
               }
              insert newChangeOrderHeader;
              System.debug('***newChangeOrderHeader**'+ newChangeOrderHeader);
              createChangeOrderOFA(newChangeOrderHeader);
              PageReference newPage = new PageReference('/'+newChangeOrderHeader.Id);
              return newPage.setRedirect(true);
          }else{
             Apexpages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'Please check the SID Number'));            
         }
        }else{
             newChangeOrderHeader.Account__c = acct.Id;
             insert newChangeOrderHeader;
              PageReference newPage = new PageReference('/'+newChangeOrderHeader.Id);
             return newPage.setRedirect(true);
        }
        return null;
    }                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                             
    public static void createChangeOrderOFA(TAMS_ROA__c cho){
          
          List<Order_Financial_Analysis__c> lOfas= [SELECT
                                                       id
                                                      FROM
                                                      Order_Financial_Analysis__c
                                                     where
                                                      SID__c =: cho.change_order_sid__c]; 

        List<Change_Order_OFA__c> lCOO = new List<Change_Order_OFA__c>();
        for(Order_Financial_Analysis__c ofa : lOfas){
            lCOO.add(new Change_Order_OFA__c(OFA__c = ofa.id, Change_Order_Header__c = cho.id));
            System.debug('list of Change order ofa'+lCOO);
        }
        try{
            insert lCOO;
        }
        catch(DmlException e){
             System.debug(e.getMessage());
        }
     }
     public pagereference cancel()
    {
        PageReference newPage=new PageReference('/'+acct.ID);
        return newPage.setRedirect(true);
    }
    @TestVisible private boolean isvalidSid(Decimal sidNumber){
        System.debug('***sSid'+sOrderMaster);
        System.debug('sidnumber'+sidNumber);
        for(Order_Master__c ordmaster :sOrderMaster){
            System.debug('ordmaster***'+ ordmaster);
            if(ordmaster.SID_Order__c == sidNumber && sidNumber != null){
                System.debug('ordmaster.Customer_Name__c'+ordmaster.Customer_Name__c);
                if(ordmaster.Customer_Name__c != null){
               customerId = ordmaster.Customer_Name__c;
                return true;
            }else if(ordmaster.Customer_Name__c == null){
                customerId = acct.Id;
                return true;
            }
        }
    }
           return false;
    }
   @TestVisible private boolean isRequriedFieldsPopulated(TAMS_ROA__c changeorderheader){
            return true;
       }

    public pagereference changeRequestedBy(){
        System.debug('Change Order Type'+newChangeOrderHeader.ROA_Type__c);
         if(newChangeOrderHeader.ROA_Type__c == 'Item Change'){
            showChangeRequestedBy = true;
            showChangeorderExternal = false;
            showChangeOrderInternal = false;
         }else{
            showChangeRequestedBy = false;
            showChangeorderExternal = false;
            showChangeOrderInternal = false;
         }

         if(newChangeOrderHeader.ROA_Type__c == 'Other'){
            showSID = false;
            showotherSID = true;
            showOrderNUmber = true;
            showOA = true;
            showChangeorderExternal = false;
            showChangeOrderInternal = false;
         }else{
            showSID = true;
            showotherSID = false;
            showOrderNUmber = false;
            showOA = false;
            showChangeorderExternal = false;
            showChangeOrderInternal = false;
         }

         return null;
    }  
  //While Creating a change order according to the sid Number already existing change order should be shown.
   public pagereference changeorders(){
        
      if(newChangeOrderHeader.Change_Requested_By__c == 'External'){
            showChangeorderExternal = true;
            showChangeOrderInternal = false;
         }
         else if(newChangeOrderHeader.Change_Requested_By__c == 'Internal'){
            showChangeorderExternal = false;
            showChangeOrderInternal = true;
         }
         else{
              showChangeorderExternal = false;
              showChangeOrderInternal = false;
         }

       return null;
       //   ChangeOrderSettings__c changeOrderSettings = ChangeOrderSettings__c.getValues('ChangeOrderVisibility');
      //System.debug('changeOrderSettings'+changeOrderSettings);
      //String changeOrderValue = changeOrderSettings.Value__c;
      //System.debug('changeOrderValue'+changeOrderValue);
     // if(String.isNotBlank(changeOrderValue)){
     //   List<String> lProfiles = changeOrderValue.split(',');
     //   String currentUserProfile = [Select name from profile where id =: UserInfo.getProfileId()].name;
     //   System.debug('currentUserProfile'+currentUserProfile);
     //   if(lProfiles.contains(currentUserProfile)){   
     //     System.debug('entered');
     //     System.debug('sidNumber'+sidNumber);
     //     System.debug('bookId'+bookId);
     //    if(newChangeOrderHeader.Change_Requested_By__c == 'External'){
     //       showChangeorderExternal = true;
     //       showChangeOrderInternal = false;
     //    }
     //    else if(newChangeOrderHeader.Change_Requested_By__c == 'Internal'){
     //       showChangeorderExternal = false;
     //       showChangeOrderInternal = true;
     //    }
     //    else{
     //         showChangeorderExternal = false;
     //         showChangeOrderInternal = false;
     //    }
     //  }
     //}
     }
   
    public List<TAMS_ROA__c> getchangeorderExternal(){
    String changeordersid = String.valueOf(sidNumber);
       list<TAMS_ROA__c> lroa = [Select Id,Name,Change_Requested_By__c,Status__c,COH_Modality__c From TAMS_ROA__c Where Change_Order_SID__c =: changeordersid AND Change_Requested_By__c = 'External'];
       System.debug(lroa);
       return lroa;
  }

   public List<TAMS_ROA__c> getchangeorderInternal(){
    String changeordersid = String.valueOf(sidNumber);
       list<TAMS_ROA__c> lroa = [Select Id,Name,Change_Requested_By__c,Status__c,COH_Modality__c From TAMS_ROA__c Where Change_Order_SID__c =: changeordersid ];
       System.debug(lroa);
       return lroa;
  }
}