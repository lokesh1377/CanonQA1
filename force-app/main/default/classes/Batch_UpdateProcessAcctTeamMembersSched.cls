global class Batch_UpdateProcessAcctTeamMembersSched implements Schedulable{
	global void execute(SchedulableContext sc){
		Database.executeBatch(new Batch_UpdateProcessAccountTeamMembers(), 1);
	}
}