({
	CloneOpportunityJS : function(component, event, helper) {
        console.log('Inside CloneOpportunityJS');
        var action = component.get('c.CloneOpp');
        var oppId = component.get('v.recordId');
        console.log('oppId:'+oppId);
        action.setParams({"origOpportunityId":oppId});
        action.setCallback(this, function(response){
            var state = response.getState();
            console.log('state:'+state);
            if (state === "SUCCESS") {
                var resp = ""+response.getReturnValue();
                console.log(resp);
                var sts = resp.substr(0,5); 
                console.log(sts);
                if(sts != "Error"){ 
                    $A.get("e.force:closeQuickAction").fire();
                    var urlEvent = $A.get("e.force:navigateToURL");
                    urlEvent.setParams({
                            "url": "/"+resp
                    });
                    urlEvent.fire();
                    // Close the action panel
                    
				}else{
                    console.log('Before showing error message');   
                    var errMsg = resp.substr(6);
                    console.log('errMsg:'+errMsg);        
                    var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                                mode: 'sticky',
                                message: errMsg,
                                type: 'error'
                                });
                    toastEvent.fire();
                    console.log('After showing error message');
                    var dismissActionPanel = $A.get("e.force:closeQuickAction");
                    dismissActionPanel.fire();
                    console.log('After closing action');
				/*
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
                */            
    			}
			}
        });
	$A.enqueueAction(action);

    },		
   
})