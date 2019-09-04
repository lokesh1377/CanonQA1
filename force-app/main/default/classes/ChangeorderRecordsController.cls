/*********************************************************
        Author:         
        Purpose: This Class is used for displaying Related Change Orders on Change Order Page.        
        1.0 - Lokesh Tigulla              - Created
        1.1 - Lokesh Tigulla - 03/19/2019 - updated
        1.2 - Lokesh Tigulla - 03/21/2013 - updated(Changeorder)
**********************************************************/
public with sharing class ChangeorderRecordsController {
  public TAMS_ROA__c roa {get;set;}
  public String sidNumber;
  public Boolean showChangeorderExternal {get;set;}
  public Boolean showChangeOrderInternal {get;set;}
  public String  changeordername {get;set;}
  public String  repeatingChangeorder {get;set;}
  public ChangeorderRecordsController (ApexPages.StandardController stdcon) {
      roa = new TAMS_ROA__c();
        roa = (TAMS_ROA__c)stdcon.getRecord(); 
        System.debug('**ROA'+ roa);
      TAMS_ROA__c roas = [SELECT
                               Name
                              ,change_order_sid__c
                              ,Change_Requested_By__c
                              ,COH_Modality__c
                              ,Status__c
                               FROM
                               TAMS_ROA__c
                               WHERE
                               Id =: roa.Id LIMIT 1];
      System.debug('roas'+roas);
      repeatingChangeorder = roas.Name;
       sidNumber = roas.change_order_sid__c;
        if(roas.Change_Requested_By__c == 'External'){
            showChangeorderExternal = true;
            showChangeOrderInternal = false;
         }
         else if(roas.Change_Requested_By__c == 'Internal'){
            showChangeorderExternal = false;
            showChangeOrderInternal = true;
         }
         else{
              showChangeorderExternal = false;
              showChangeOrderInternal = false;
         }

     
    }
    public List<Schema.FieldSetMember> getFields() {
    System.debug('**Fields'+ SObjectType.TAMS_ROA__c.FieldSets.COFA_Columns_for_Item_Change_Layout.getFields());
        return SObjectType.TAMS_ROA__c.FieldSets.COFA_Columns_for_Item_Change_Layout.getFields();

    }

    public List<TAMS_ROA__c> getchangeorderExternal(){
    	System.debug('Sidnumber'+sidNumber);
       list<TAMS_ROA__c> lroa = [Select Id,Name,Change_Requested_By__c,Status__c,COH_Modality__c,CreatedById  From TAMS_ROA__c Where Change_Order_SID__c =: sidNumber AND Change_Requested_By__c = 'External' AND Name !=: repeatingChangeorder AND Status__c !=: 'Complete'];
       System.debug(lroa);
       return lroa;
  }

   public List<TAMS_ROA__c> getchangeorderInternal(){
        System.debug('Sidnumber'+sidNumber);
        System.debug('changeordername'+changeordername);
       list<TAMS_ROA__c> lroa = [Select Id,Name,Change_Requested_By__c,Status__c,COH_Modality__c,CreatedById  From TAMS_ROA__c Where Change_Order_SID__c =: sidNumber AND Name !=: repeatingChangeorder AND Status__c !=: 'Complete'];
       System.debug(lroa);
       return lroa;
  }
 
  public pagereference changeOrder(){
      System.debug('changeordername :'+ changeordername);
      id roaId = [select Id from TAMS_ROA__c Where Name =: changeordername ].Id;
        System.debug('roaId'+roaId);
        PageReference newPage=new PageReference('/'+roaId);
        return newPage.setRedirect(true);
  }
}

         // Used for Restriking visibility depends of the profile
              //  System.debug('Roa Status'+roas.Status__c);
               //  ChangeOrderSettings__c changeOrderSettings = ChangeOrderSettings__c.getValues('ChangeOrderVisibility');
               // System.debug('changeOrderSettings'+changeOrderSettings);
               // String changeOrderValue = changeOrderSettings.Value__c;
               // System.debug('changeOrderValue'+changeOrderValue);
               // if(String.isNotBlank(changeOrderValue)){
               //   List<String> lProfiles = changeOrderValue.split(',');
               //   String currentUserProfile = [Select name from profile where id =: UserInfo.getProfileId()].name;
               //   System.debug('currentUserProfile'+currentUserProfile);
               //   if(lProfiles.contains(currentUserProfile)){   
               //    if(roas.Change_Requested_By__c == 'External'){
               //       showChangeorderExternal = true;
               //       showChangeOrderInternal = false;
               //    }
               //    else if(roas.Change_Requested_By__c == 'Internal'){
               //       showChangeorderExternal = false;
               //       showChangeOrderInternal = true;
               //    }
               //    else{
               //         showChangeorderExternal = false;
               //         showChangeOrderInternal = false;
               //    }
               //  }
               //}