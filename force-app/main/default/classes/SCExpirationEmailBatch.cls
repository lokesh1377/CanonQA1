global with sharing class SCExpirationEmailBatch implements Database.batchable<sObject>, Database.Stateful {
	
	global final List<String> optedOutUsers;
	global final Map<String, MyPreferencesEmailList__c> prefs;
	global final Map<Id, User> usrs;
	global Integer EmailCount;

	global SCExpirationEmailBatch() {
		optedOutUsers = new List<Id>();
		
		List<MyPreferencesEmailList__c> pref = [select Name, Template_Id__c, Expiration_Email_to_Send__c from MyPreferencesEmailList__c where Expiration_Email__c = true];
		prefs = new Map<String, MyPreferencesEmailList__c>();
		List<String> emails = new List<String>();
		for (MyPreferencesEmailList__c p : pref){
			prefs.put(p.Expiration_Email_to_Send__c, p); 
			emails.add(p.Name);
		}

		List<TAMS_Email_Opt_In_Out__c> emailOpts  = [select User__c from TAMS_Email_Opt_In_Out__c where Email__c = : emails and Is_Opt_Out__c = true];
		for (TAMS_Email_Opt_In_Out__c opt : emailOpts) {
			optedOutUsers.add(opt.User__c);
		}

		usrs = new Map<Id, User>([select Id, AccountId, Email from User where isActive = true and IsPortalEnabled = true and Id not in: optedOutUsers]);
		EmailCount = 0;
	}
	
	global Database.QueryLocator start(Database.BatchableContext info) {
		
		String returnQuery = 'select Id, AccountId, EndDate, ASM_Email__c, Expiration_Email_to_Send__c, X30_Day_Email_Alert_Sent__c, X60_Day_Email_Alert_Sent__c, X90_Day_Email_Alert_Sent__c from ServiceContract where ';
			   returnQuery += ' Contract_Status__c = \'Active\' and (Expiration_Email_to_Send__c != \'No Email to Send\')';
		
		System.Debug('qry: ' + returnQuery );
        return Database.getQueryLocator(returnQuery);        
	}
	
	global void execute(Database.BatchableContext info, List<sObject> sobjectList) {
		
		List<ServiceContract> servContracts = (List<ServiceContract>) sobjectList;
		
		List<Id> SCIds = new List<Id>();
		for (ServiceContract servCont : servContracts) {
			SCIds.add(servCont.Id);
		}

		List<ServiceContractShare> scss = [select Id, ParentId, UserOrGroupId from ServiceContractShare where UserOrGroupId =: usrs.KeySet() and ParentId =: SCIds];
		
		Messaging.SingleEmailMessage[] singleEmails = new List<Messaging.SingleEmailMessage>();
		List<ServiceContract> servContToUpdate = new List<ServiceContract>();
		for (ServiceContract servCont : servContracts) {
			if ((servCont.Expiration_Email_to_Send__c == '30 Days' && servCont.X30_Day_Email_Alert_Sent__c == false) ||	
				(servCont.Expiration_Email_to_Send__c == '60 Days' && servCont.X60_Day_Email_Alert_Sent__c == false) ||	
				(servCont.Expiration_Email_to_Send__c == '90 Days' && servCont.X90_Day_Email_Alert_Sent__c == false)){
				List<String> toAddresses = new List<String>();
				String userId = '';
				for (ServiceContractShare scShare : scss){
					if(servCont.Id == scShare.ParentId){
						if (usrs.containsKey(scShare.UserOrGroupId)){
							User usr = usrs.get(scShare.UserOrGroupId);
							if (String.isBlank(userId)){
								userId = usr.Id;
							}
							toAddresses.add(usr.Email);
						}
						if (!String.isBlank(servCont.ASM_Email__c)) {
							toAddresses.add(servCont.ASM_Email__c); 
						}
					}	
				}
				
				
				
				if (String.isBlank(userId)) userId = UserInfo.getUserId();
				
				Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
				mail.setToAddresses(toAddresses);
				mail.setTargetObjectId(userId);   
			   	mail.setBccSender(false);
			   	mail.setUseSignature(false);
			   	mail.setSaveAsActivity(false);
		        mail.setTemplateId(prefs.get(servCont.Expiration_Email_to_Send__c).Template_Id__c);
		        mail.setWhatId(servCont.Id);
		        
		        if (emailCount <= 1000){
			        singleEmails.add(mail);
			        emailCount++;
			        
			        
			        if (servCont.Expiration_Email_to_Send__c == '30 Days'){
			        	servCont.X30_Day_Email_Alert_Sent__c = true;
			        } else  if (servCont.Expiration_Email_to_Send__c == '60 Days'){
			        	servCont.X60_Day_Email_Alert_Sent__c = true;
			        } else  if (servCont.Expiration_Email_to_Send__c == '90 Days'){
			        	servCont.X90_Day_Email_Alert_Sent__c = true;
			        } 
			        
		
			        servContToUpdate.add(servCont);
		        }
			}
		}
		
		if (singleEmails.size() > 0 && !Test.isRunningTest()){
			Messaging.sendEmail(singleEmails);
		}
		
		update servContToUpdate;
	}
	
	global void finish(Database.BatchableContext info) {}

}