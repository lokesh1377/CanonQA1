global class Batch_ProcessAccountCaseSharesSchedule implements Schedulable{
	global void execute(SchedulableContext sc){
		Database.executeBatch(new Batch_ProcessAccountCaseShares());
	}
}