({
	showLeadsJS : function(component, event, helper) {
        console.log('Inside showLeadsJS');
        var leads=event.getParam("leads");
        //console.log(JSON.stringify(leads));
		component.set("v.leads",leads);
        component.set("v.leadsCount",leads.length);
        console.log("after setting leads in component");
	},
    doInit: function(component) {
        console.log('Inside Init');
    },
 	onClick: function(component,event) {
        console.log('Inside onClick');
		var selectedItem = event.currentTarget;
        var leadId = selectedItem.id
        console.log(leadId);
        var urlEvent = $A.get("e.force:navigateToURL");
                    urlEvent.setParams({
                            "url": "/"+leadId
                    });
        urlEvent.fire();        
    },    
})