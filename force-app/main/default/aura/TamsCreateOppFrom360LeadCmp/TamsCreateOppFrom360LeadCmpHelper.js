({
	CreateOpportunity : function(component) {
        console.log('Inside CreateOpportunity of helper');
        var action = component.get('c.createOpportunity');
        var leadID = component.get('v.recordId');
        console.log('leadID:'+leadID);
        action.setParams({"leadID":leadID});
        action.setCallback(this, function(response){
            var state = response.getState();
            console.log('state:'+state);
            if (state === "SUCCESS") {
                var resp = ""+response.getReturnValue();
                console.log(resp);
                var sts = resp.substr(0,5); 
                console.log(sts);
                if(sts != "Error"){ 
                    var urlEvent = $A.get("e.force:navigateToURL");
                    urlEvent.setParams({
                            "url": "/"+resp
                    });
                    urlEvent.fire();
				}else{ 
					$A.createComponents([
                        ["ui:message",{
                            "title" : "Error:",
                            "severity" : "error",
                        }],
                        ["ui:outputText",{
                            "value" : resp
                        }]
                        ],
                        function(components, status, errorMessage){
                            if (status === "SUCCESS") {
                                var message = components[0];
                                var outputText = components[1];
                                message.set("v.body", outputText);
                                var div1 = component.find("div1");
                                div1.set("v.body", message);
                            }
                            else if (status === "INCOMPLETE") {
                                console.log("No response from server or client is offline.")
                            }
                            else if (status === "ERROR") {
                                console.log("Error: " + errorMessage);
                            }
                        }
            		);        
    			}
			}else
            {
               
            }
        });
	 $A.enqueueAction(action);
    },
	goBack : function(component) {
        console.log('Inside goBack of helper');
        var leadID = component.get('v.recordId');
        console.log('leadID:'+leadID);    
        var urlEvent = $A.get("e.force:navigateToURL");
        urlEvent.setParams({
            "url": "/"+leadID
        });
        urlEvent.fire();        
    },    
})