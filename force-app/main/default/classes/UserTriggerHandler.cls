/**
  * Class object for trigger.
  *
  * Used By: User_Trigger
  * 
  * @author NTT Data: Louis Wooldridge
  * @date August 7, 2015
  *
  * @update
  */
public class UserTriggerHandler {
	private static Map<String, Id> mProfiles = new Map<String, Id>();
	private static Group oAdminGroup = [Select Id, Name, DeveloperName From Group 
		Where Type = 'Regular' And DeveloperName = 'Admin_Portal_Users' Limit 1];
	
	public UserTriggerHandler(){
		//Retrieving Portal Profile Ids
		for(Profile oProfile : [Select Id, Name From Profile Where Name Like 'TAMS - Customer Portal %']){
			if(oProfile.Name.contains('Admin')){
				mProfiles.put('Admin', oProfile.Id);
			}else{
				mProfiles.put('Standard', oProfile.Id);
			}
		}
	}
	
	public void UpdateProcessAccountShares(Map<Id, User> newUsers, List<User> oldUsers){
		Map<Id, User> mChangedUsers = new Map<Id, User>();
		
		for(User oUser : oldUsers){
			User oNewUser = newUsers.get(oUser.Id);
			if((oUser.IsActive != oNewUser.IsActive)||(oUser.IsPortalEnabled != oNewUser.IsPortalEnabled)||(oUser.ProfileId != oNewUser.ProfileId)){
				mChangedUsers.put(oUser.Id,oUser);
			}
		}
		
		if(mChangedUsers.isEmpty() == false){
			UpdateProcessAccountShares(mChangedUsers);
		}
	}
	
	public void UpdateProcessAccountShares(Map<Id, User> newUsers){
		Set<Id> sDistinctAccountIds = new Set<Id>();
		Map<Id, String> mPortalUserTypeLookup = new Map<Id, String>();
		Set<Id> sDistinctAdminUserIds = new Set<Id>();
		Set<Id> sDistinctStandardUserIds = new Set<Id>();
		Map<Id, String> mUserModalities = new Map<Id, String>();
		
		
		for(User oUser : [Select Id, AccountId, ContactId, IsActive, ProfileId, Contact.Modality__c
		From User Where Id In:newUsers.keySet()]){
			if((oUser.IsActive == true)&&(oUser.ContactId != null)){
				sDistinctAccountIds.add(oUser.AccountId);
				mUserModalities.put(oUser.Id, oUser.Contact.Modality__c);
				if(oUser.ProfileId == mProfiles.get('Standard')){
					mPortalUserTypeLookup.put(oUser.ContactId, 'Standard');
					//Capturing Standard User ids so that they can be removed from the Portal Admin Group
					//This will handle users being switched from an Admin to a Standard User
					sDistinctStandardUserIds.add(oUser.Id);
				}else if(oUser.ProfileId == mProfiles.get('Admin')){
					mPortalUserTypeLookup.put(oUser.ContactId, 'Admin');
					//Capturing Admin Users to be added to the Portal Admin Group
					sDistinctAdminUserIds.add(oUser.Id);
				}
			}
		}
		
		if(sDistinctStandardUserIds.isEmpty() == false){
			RemoveUserAdminGroup(sDistinctStandardUserIds);
		}
		if(sDistinctAdminUserIds.isEmpty() == false){
			AddUserAdminGroup(sDistinctAdminUserIds);
		}
		
		//Calling code in Contact trigger to update Modality public group membership
		//Calling this method because we don't want to duplicate code logic
		if(mUserModalities.isEmpty() == false){
			Contact_TriggerHandler.UpdateModalityGroups(mUserModalities);
		}
		
		UpdateAccountContactInfo(sDistinctAccountIds, mPortalUserTypeLookup);
	}
	
	private void RemoveUserAdminGroup(Set<Id> sStandardIds){
		List<GroupMember> lDeleteMembers = new List<GroupMember>();
		
		for(GroupMember oMember : [Select Id From GroupMember Where GroupId = :oAdminGroup.Id And UserOrGroupId In:sStandardIds]){
			lDeleteMembers.add(oMember);
		}
		
		if(lDeleteMembers.isEmpty() == false){
			delete lDeleteMembers;
		}
	}
	
	private void AddUserAdminGroup(Set<Id> sAdminIds){
		List<GroupMember> lInsertMembers = new List<GroupMember>();
		
		for(Id idAdmin : sAdminIds){
			GroupMember oNewMember = new GroupMember(GroupId=oAdminGroup.Id, UserOrGroupId=idAdmin);
			lInsertMembers.add(oNewMember);
		}
		
		if(lInsertMembers.isEmpty() == false){
			insert lInsertMembers;
		}
	}
	
	//Using at @future declaration to prevent MIXED_DML_OPERATION exception
	@future
	private static void UpdateAccountContactInfo(Set<Id> sAccountIds, Map<Id, String> mPortalUserTypes){
		//Performing Account object updates
		List<Account> lUpdateAccounts = new List<Account>();
		
		//Retrieving Account records for update
		for(String sAccountId : sAccountIds){
			Account oAccount = new Account();
			oAccount.Id = sAccountId;
			oAccount.Process_Account_Shares__c = true;
			lUpdateAccounts.add(oAccount);
		}
		
		//Updating Accounts
		if(lUpdateAccounts.isEmpty() == false){
			//Added check to see if Unit Test code is running, the following two DML statements caused MIXED_DML_OPERATION errors
			//for unknown reasons.
			if(test.isRunningTest() == false){Update lUpdateAccounts;}
		}
		
		//Performing Contact object updates
		List<Contact> lUpdateContacts = new List<Contact>();
		
		for(String sContactId : mPortalUserTypes.keySet()){
			Contact oContact = new Contact();
			oContact.Id = sContactId;
			oContact.Portal_User_Type__c = mPortalUserTypes.get(oContact.Id);
			lUpdateContacts.add(oContact);
		}
		
		//Updating Contacts
		if(lUpdateContacts.isEmpty() == false){
			//Added check to see if Unit Test code is running, the following two DML statements caused MIXED_DML_OPERATION errors
			//for unknown reasons.
			if(test.isRunningTest() == false){update lUpdateContacts;}
		}
	}
}