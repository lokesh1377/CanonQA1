({
	showQuotes : function(component,event) {
		console.log('Inside showQuotes Helper');
		var oppId = component.get('v.recordId');
		console.log('oppId:'+oppId);
		var showQuotesEvent = $A.get("e.c:TamsOppQuotesEVT");
        console.log('showQuotesEvent:'+showQuotesEvent);
        showQuotesEvent.setParams({"opportunityId":oppId});
        showQuotesEvent.fire();
        console.log('showQuotesEvent fired');
	},
})