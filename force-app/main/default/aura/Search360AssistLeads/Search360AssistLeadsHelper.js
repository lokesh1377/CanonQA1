({
	searchLeadsHelper : function(component) {
        console.log('Inside searchLeads helper');
        var action = component.get('c.getLeads');
        console.log('action:'+action);
        var accountName = component.get("v.accountName");
        if(accountName == null){
            accountName = null;
        }
        console.log("accountName:"+accountName);
        var rank = component.get("v.rank");
        if(rank == null){
            rank = null;
        }
        console.log("rank:"+rank);        
        var leadName = component.get("v.leadName");
        if(leadName == null){
            leadName = null;
        }
        console.log("leadName:"+leadName);
        var status = component.get("v.status");
        console.log("status:"+status);
        var modality = component.get("v.modality");
        if(modality == null){
            modality = null;
        }     
        console.log("modality:"+modality);
        var sortBy = component.get("v.sortBy");
        if(sortBy == null){
            sortBy = null;
        }
        console.log("sortBy:"+sortBy);                
        action.setParams({"status":status,
                         "modality":modality,
                         "leadName":leadName,
                         "accountName":accountName,
                         "rank":rank,
                          "sortBy":sortBy}
                        );
        
        console.log('setting callback function');
        action.setCallback( this, function(response){
            var state = response.getState();
            console.log('state:'+state);
            var toastEvent = $A.get("e.force:showToast");
            if (state === "SUCCESS") {
                var leads = response.getReturnValue();
                var searchEvent = $A.get("e.c:Show360AssistLeads");
                console.log('searchEvent:'+searchEvent);

                searchEvent.setParams({"leads":leads});
                searchEvent.fire();
                console.log('searchEvent fired');
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
})