({
	doInit : function(component, event, helper) {
		console.log('Inside doInit Controller');
        var action = component.get('c.getQuoteRecord');
        var opportunityId = component.get('v.recordId');
         console.log('opportunityId:'+opportunityId);
        action.setParams({"opportunityId":opportunityId});
      /* action.setCallback(this, function(response){
         var state = response.getState();
         console.log('state:'+state); 
        }*/
    }                 
})