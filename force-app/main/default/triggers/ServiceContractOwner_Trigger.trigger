/************************************************
 * Trigger to Change Contract Owner to SEG ASM. *
 * Condition: after insert)                     *
 * Calls:     ServiceContractOwnerTrigger       *
 *                                              *
 * @author:   Wendy B. Copeland                 *
 * @date:     August 25, 2016                   *
 *                                              *
 * @update                                      *
 ************************************************/
trigger ServiceContractOwner_Trigger on ServiceContract (after insert, after update) {
	// Check if Trigger is Insert
    if(trigger.isInsert){
       // Call TriggerHandler (Method UpdateContractOwnerWith ASM) passing in New Record
       ServiceContractOwnerTriggerHandler.UpdateContractOwnerWithASM(trigger.new);
    }else{
        // Call TriggerHandler (Method UpdateContractOwnerWith ASM) passing in New Record and Record before Changes
        ServiceContractOwnerTriggerHandler.UpdateContractOwnerWithASM(trigger.new, trigger.oldMap);
    }
}