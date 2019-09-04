({
	searchLeadsJS : function(component, event, helper) {
        console.log('Inside searchLeads controller');
		helper.searchLeadsHelper(component);
	},
	doInit : function(component, event, helper) {
        console.log('Inside doInit controller');
		helper.searchLeadsHelper(component);
	},    
})