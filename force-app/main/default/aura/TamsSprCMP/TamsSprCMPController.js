({
	createSPR_JS : function(component, event, helper) {
        console.log('Inside createSPR_JS');
        var action = component.get('c.createSPR');
        var quoteId = component.get('v.recordId');
        console.log('quoteId:'+quoteId);
        action.setParams({"quoteId":quoteId});
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
                            "url": "/"+resp+"/e"
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
	
})