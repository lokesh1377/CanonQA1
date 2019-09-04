/**
  * Class object for trigger.
  *
  * Used By: Contact_Trigger
  * 
  * @author NTT Data: Louis Wooldridge
  * @date August 7, 2015
  *
  * @update
  */
public class Contact_TriggerHandler {
	public static void UpdateAccountProcessShareFlag(List<Contact> newContacts, Map<Id, Contact> oldContacts){
		Set<Id> sAccountIds = new Set<Id>();
		List<Account> lUpdateAccounts = new List<Account>();
		
		//If Portal User Type field changes for a Contact, want to flag related Accounts
		//to be processed by the batch job Batch_ProcessAccountShares
		for(Contact oContact : newContacts){
			if((oContact.Portal_User_Type__c != oldContacts.get(oContact.Id).Portal_User_Type__c)||
			(oContact.Modality__c != oldContacts.get(oContact.Id).Modality__c)){
				sAccountIds.add(oContact.AccountId);
			}
		}
		
		for(Account oAccount : [Select Id, Process_Account_Shares__c From Account 
		Where Id In:sAccountIds And Process_Account_Shares__c = false]){
			oAccount.Process_Account_Shares__c = true;
			lUpdateAccounts.add(oAccount);
		}
		
		if(lUpdateAccounts.isEmpty() == false){
			update lUpdateAccounts;
		}
	}
	
	public static void UpdateContactUserInfo(List<Contact> newContacts, Map<Id, Contact> oldContacts){
		Map<Id, String> mModalities = new Map<Id, String>();
		Map<Id, Boolean> mFrozen = new Map<Id, Boolean>();
		Map<Id, Id> mLookupUserId =new Map<Id, Id>();
		
		//Retrieving related User records for the Contacts
		for(User oUser : [Select Id, ContactId From User Where ContactId In:oldContacts.keySet()
		And ContactId != null]){
			mLookupUserId.put(oUser.ContactId, oUser.Id);
		}
		
		for(Contact oContact : newContacts){
			//Collecting the Modalities for each Contact so that the related User 
			//Group Membership can be updated in a @Future call.
			if((oContact.Modality__c != oldContacts.get(oContact.Id).Modality__c)||
			(oContact.Portal_User_Type__c != oldContacts.get(oContact.Id).Portal_User_Type__c)){
				if(mLookupUserId.keySet().contains(oContact.Id) == true){
					mModalities.put(mLookupUserId.get(oContact.Id), oContact.Modality__c);
				}
			}
			//Collecting Ids for Contacts that have Frozen/Unfrozen so that the related User
			//can be updated in a @Future call.
			if(oContact.Is_Frozen__c != oldContacts.get(oContact.Id).Is_Frozen__c){
				mFrozen.put(mLookupUserId.get(oContact.Id), oContact.Is_Frozen__c);
			}
		}
		
		if((mFrozen.isEmpty() == false)||(mModalities.isEmpty() == false)){
			UpdateUserInfo(mFrozen, mModalities);
		}
	}
	
	//Using at @future declaration to prevent MIXED_DML_OPERATION exception
	@future
	private static void UpdateUserInfo(Map<Id, Boolean> mUserIsFrozen, Map<Id, String> mUserModalities){
		//Checking to see if any User records were found linked to the Contacts
		if(mUserIsFrozen.isEmpty() == false){
			List<UserLogin> lLogins = new List<UserLogin>();
			for(UserLogin oLogin : [Select Id, IsFrozen, UserId From UserLogin 
			Where UserId In:mUserIsFrozen.keySet()]){
				oLogin.IsFrozen = mUserIsFrozen.get(oLogin.UserId);
				lLogins.add(oLogin);
			}
			
			if(lLogins.isEmpty() == false){
				update lLogins;
			}
		}
		
		if(mUserModalities.isEmpty() == false){
			UpdateModalityGroups(mUserModalities);
		}
	}
	
	public static void UpdateModalityGroups(Map<Id, String> mUserModalities){
		if(mUserModalities.isEmpty() == false){
			//Retrieving the Modality public groups
			Map<String, Id> mModalityGrpIdLookup = new Map<String, Id>();
			for(Group oGroup : [Select Id, Name From Group Where Type = 'Regular' And Name Like 'Modality%']){
				mModalityGrpIdLookup.put(oGroup.Name.right(2), oGroup.Id);
			}
			
			//Deleting existing GroupMember records for User
			List<GroupMember> lDeleteMembers = [Select Id From GroupMember 
				Where UserOrGroupId In:mUserModalities.keySet() 
				And GroupId In:mModalityGrpIdLookup.values()];
			
			if(lDeleteMembers.isEmpty() == false){
				delete lDeleteMembers;
			}
			
			List<GroupMember> lInsertMembers = new List<GroupMember>();
			for(Id idUser : mUserModalities.keySet()){
				String sModalities = mUserModalities.get(idUser);
				if(sModalities != null){
					for(String sModality : sModalities.split(';', 0)){
						GroupMember oNewMember = new GroupMember();
						if(mModalityGrpIdLookup.keySet().contains(sModality)){
							oNewMember.GroupId = mModalityGrpIdLookup.get(sModality);
							oNewMember.UserOrGroupId = idUser;
							lInsertMembers.add(oNewMember);
						}
					}
				}
			}
			
			if(lInsertMembers.isEmpty() == false){
				insert lInsertMembers;
			}
		}
	}
}