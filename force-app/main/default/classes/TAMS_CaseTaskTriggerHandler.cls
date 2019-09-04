/**
  * Class object for trigger.
  *
  * Used By: TAMS_Case_Task_Trigger
  * 
  * @author NTT Data: Louis Wooldridge
  * @date August 26, 2015
  *
  * @update
  */
public class TAMS_CaseTaskTriggerHandler {
	private static Map<String, Id> mLookupUser = new Map<String, Id>();
	
	public TAMS_CaseTaskTriggerHandler(){
		for(User oUser : [Select Id, EmployeeNumber From User 
		Where IsActive = true And EmployeeNumber != null]){
			mLookupUser.put(oUser.EmployeeNumber, oUser.Id);
		}
	}
	
	public void UpdateOwner(List<TAMS_Case_Task__c> newTasks){
		for(TAMS_Case_Task__c oTask : newTasks){
			if(mLookupUser.keySet().contains(oTask.Employee_Number__c)){
				oTask.OwnerId = mLookupUser.get(oTask.Employee_Number__c);
			}
		}
	}
	
	public void UpdateOwner(List<TAMS_Case_Task__c> newTasks, Map<Id, TAMS_Case_Task__c> oldTasks){
		List<TAMS_Case_Task__c> lUpdatedAssignees = new List<TAMS_Case_Task__c>();
		
		for(TAMS_Case_Task__c oTask : newTasks){
			if(oTask.Employee_Number__c != oldTasks.get(oTask.Id).Employee_Number__c){
				lUpdatedAssignees.add(oTask);
			}
		}
		
		if(lUpdatedAssignees.isEmpty() == false){
			UpdateOwner(lUpdatedAssignees);
		}
	}
}