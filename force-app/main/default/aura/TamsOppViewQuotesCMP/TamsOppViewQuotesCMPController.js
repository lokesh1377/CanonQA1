({
	getQuotesJS : function(component, event, helper) {
		console.log('inside getQuotesJS controller');
		var oppId=event.getParam("opportunityId");
		console.log('oppId:'+oppId);
        component.set("v.opportunityId",oppId);
        var action = component.get('c.getQuotes');
        console.log('action:'+action);
        action.setParams({"opportunityId":oppId});		
        console.log('setting callback function');
        action.setCallback( this, function(response){
            var state = response.getState();
            console.log('state:'+state);
            var toastEvent = $A.get("e.force:showToast");
            if (state === "SUCCESS") {
                var quotes = response.getReturnValue();
                console.log('quotes:'+quotes);
                component.set("v.quotes",quotes);
                console.log('After setting quotes in component');
            }else{
				toastEvent.setParams({
                        "title": "Error!",
                        "message": " Please contact Administrator"
                });
                toastEvent.fire();
            }
        	
        });       
	    $A.enqueueAction(action);        		
	},

    onSelect : function(component, event, helper) {
        console.log('inside onSelect controller');
        //var src = event.getSource();
        var src = event.currentTarget;
        console.log('src:'+src);
        //var quoteId = src.getLocalId();
        var quoteId = src.id;
        console.log('quoteId:'+quoteId);
        var action = component.get('c.setPrimary');
        console.log('action:'+action);
        action.setParams({"quoteId":quoteId});      
        console.log('setting callback function');
        
        action.setCallback( this, function(response){
            var state = response.getState();
            console.log('state:'+state);
            if (state === "SUCCESS") {
                var oppId=component.get("v.opportunityId");
                console.log('inside callback oppId:'+oppId);
                var showQuotesEvent = $A.get("e.c:TamsOppQuotesEVT");
                console.log('showQuotesEvent:'+showQuotesEvent);
                showQuotesEvent.setParams({"opportunityId":oppId});
                showQuotesEvent.fire();
                console.log('showQuotesEvent fired');                        
            }else{
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                        "title": "Error!",
                        "message": " Please contact Administrator"
                });
                toastEvent.fire();
            }
            
        });       
        $A.enqueueAction(action);               
        
    },
    onReturn : function(component, event, helper) {
        console.log('inside onReturn controller');
        var oppId = component.get("v.opportunityId");
        console.log('oppId:'+oppId);
        var urlEvent = $A.get("e.force:navigateToURL");
                    urlEvent.setParams({
                            "url": "/"+oppId
                    });
        urlEvent.fire();
    },            
})