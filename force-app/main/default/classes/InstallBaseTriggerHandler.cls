/**
  * Class object for trigger.
  *
  * Used By: Install_Base_TAMS_Trigger
  * 
  * @author NTT Data: Louis Wooldridge
  * @date July 31, 2015
  *
  * @update
  */
public class InstallBaseTriggerHandler {
	public static void UpdateProductSubFamilyLookup(List<Install_Base_TAMS__c> newInstallBase){
		Map<String,Id> mLookupProductSubFamily = new Map<String,Id>();
		Set<String> sDistinctSubFamilies = new Set<String>();
		
		for(Install_Base_TAMS__c oInstallBase : newInstallBase){
			sDistinctSubFamilies.add(oInstallBase.TAMS_Product_Sub_Family__c);
		}
		
		//Retrieving Product Sub Family records for the distinct codes on the Install Base records
		for(TAMS_Product_Sub_Family__c oSubFamily : [Select Id, Name From TAMS_Product_Sub_Family__c 
		Where Name In:sDistinctSubFamilies]){
			mLookupProductSubFamily.put(oSubFamily.Name, oSubFamily.Id);
		}
		
		//Updating lookup field to Product Sub Family
		List<Install_Base_TAMS__c> lUpdateInstallBase = new List<Install_Base_TAMS__c>();
		for(Install_Base_TAMS__c oInstallBase : newInstallBase){
			oInstallBase.TAMS_Product_Sub_Family_lookup__c = mLookupProductSubFamily.get(oInstallBase.TAMS_Product_Sub_Family__c);
		}
		update lUpdateInstallBase;
	}
	
	public static void UpdateAccountTeam(List<Install_Base_TAMS__c> newInstallBase){
		Set<Id> sDistinctAccountIds = new Set<Id>();
		
		for(Install_Base_TAMS__c oInstallBase : newInstallBase){
			sDistinctAccountIds.add(oInstallBase.Account_Name__c);
		}
		
		//Updating flag to rebuild Account Team for affected Accounts
		List<Account> lUpdateAccounts = new List<Account>();
		for(Account oAccount : [Select Id, Process_Account_Team_Members__c From Account Where Id In:sDistinctAccountIds]){
			oAccount.Process_Account_Team_Members__c = true;
			lUpdateAccounts.add(oAccount);
		}
		
		update lUpdateAccounts;
	}
	
	public static void UpdateAccountTeam(List<Install_Base_TAMS__c> newInstallBase, Map<Id,Install_Base_TAMS__c> oldInstallBase){
		List<Install_Base_TAMS__c> lModifiedInstallBases = new List<Install_Base_TAMS__c>();
		
		for(Install_Base_TAMS__c oInstallBase : newInstallBase){
			Install_Base_TAMS__c oOldInstallBase = oldInstallBase.get(oInstallBase.Id);
			
			//Only processing records where the Primary CE or ASM was changed.
			if((oInstallBase.Primary_CE_lookup__c != oOldInstallBase.Primary_CE_lookup__c)||(oInstallBase.ASM_lookup__c != oOldInstallBase.ASM_lookup__c)){
				lModifiedInstallBases.add(oInstallBase);
			}
		}
		
		if(lModifiedInstallBases.isEmpty() == false){
			UpdateAccountTeam(lModifiedInstallBases);
		}
	}
}