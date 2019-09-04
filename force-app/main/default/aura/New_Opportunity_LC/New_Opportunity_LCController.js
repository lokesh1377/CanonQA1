({
	doInit : function(component, event, helper) {
     	var createRecordEvent = $A.get("e.force:createRecord");
      createRecordEvent.setParams({
         "entityApiName": "Opportunity",
          "Name" : "***DO NOT POPULATE***"// using account standard object for this sample
      });
      createRecordEvent.fire();
        
	}
})