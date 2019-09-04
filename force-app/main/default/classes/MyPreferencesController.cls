public with sharing class MyPreferencesController {
	
	public List<TAMS_Email_Opt_In_Out__c> myEmailPref { get; set; }
	
	public MyPreferencesController() {
		
		myEmailPref = new List<TAMS_Email_Opt_In_Out__c>();
		
		List<MyPreferencesEmailList__c> emailList = [select Id, Name from MyPreferencesEmailList__c order by Sort_Order__c ASC];
		List<TAMS_Email_Opt_In_Out__c> myOptOut = [select Id, Email__c, Is_Opt_Out__c from TAMS_Email_Opt_In_Out__c where User__c =: UserInfo.getUserId()];
		
		myEmailPref = new List<TAMS_Email_Opt_In_Out__c>();
		
		for (MyPreferencesEmailList__c pref : emailList){
			Boolean found = false;
			for (TAMS_Email_Opt_In_Out__c opt : myOptOut){
				if (opt.Email__c == pref.Name){
					found = true;
					myEmailPref.add(opt);
				}

			}
			
			if (!found){
				TAMS_Email_Opt_In_Out__c optNew = new TAMS_Email_Opt_In_Out__c();
				optNew.User__c = UserInfo.getUserId();
				optNew.Email__c = pref.Name;
				myEmailPref.add(optNew);
			}
			
		}

    }
    
    public void save() {
        try {
        	List<TAMS_Email_Opt_In_Out__c> optToAdd = new List<TAMS_Email_Opt_In_Out__c>();
        	List<TAMS_Email_Opt_In_Out__c> optToRemove = new List<TAMS_Email_Opt_In_Out__c>();
        	
        	for (TAMS_Email_Opt_In_Out__c opt : myEmailPref){
        		if (opt.Id == null && opt.Is_Opt_Out__c){
        			optToAdd.add(opt);
        		} else if (opt.Id != null && !opt.Is_Opt_Out__c){
        			optToRemove.add(opt);
        		}
        		
        	}
        	
        	if (optToAdd.size() != 0){
        		insert optToAdd;
        	}
        	
        	if (optToRemove.size() != 0){
        		delete optToRemove;
        	}
        	
          
        } catch(Exception e) {
            ApexPages.addMessages(e);
        }
        
        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.CONFIRM,'Email preferences successfully saved!'));
        
    }

}