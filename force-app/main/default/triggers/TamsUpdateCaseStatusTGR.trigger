trigger TamsUpdateCaseStatusTGR on TAMS_Case_Task__c (after insert,after update) {
//First get all Tasks with Status NOT IN Assigned, Auto Reject or Auto In Planning  
    system.debug('Inside trigger TamsUpdateCaseStatusTGR');
    system.debug('updating:'+trigger.isUpdate);
    system.debug('inserting:'+trigger.isInsert);
    Set<ID> caseIds = new Set<ID>();

    for(TAMS_Case_Task__c task: Trigger.new)
    {
        system.debug('task Status:'+task.Task_Status__c);
        system.debug('task name:'+task.name);
        system.debug('Case ID:'+task.Case__c);
        if( task.Task_Status__c <> 'Assigned' && 
            task.Task_Status__c <> 'Auto In Planning' &&
            task.Task_Status__c <> 'Auto Reject' && 
            task.Task_Status__c <> 'Cancelled' &&
            task.Task_Status__c <> 'Planned'
            )
            caseIds.add(task.Case__c);
    }
    system.debug('cases not in required status size:'+caseIds.size());
//Now check how many of them are in Internal Status Open
    List<Case>  cases 
        =[
            SELECT
                ID
               ,Status
            FROM
                Case
            WHERE
                ID IN :caseIds
            AND Status = 'New'
            AND Internal_status__c = 'Open'
         ];
//Update all such cases to 'Working'
    system.debug('Open cases size:'+cases.size());
    for(Case c: cases)
    {
        c.Status = 'Working';
    }

    if (cases.size() > 0)
        update cases;
}