global class SCExpirationEmailSchedule implements Schedulable{
	
	 global void execute(SchedulableContext ctx) {

   	  SCExpirationEmailBatch sceeb = new SCExpirationEmailBatch();
      Database.executebatch(sceeb, 10);
   	}

}