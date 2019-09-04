({
	showSearch : function(component, event, helper) {
        console.log('Inside showSearch');
        var accountName=event.getParam("accountName");
        console.log("accountName:"+accountName);
        component.set("v.accountName",accountName);

        var leadName=event.getParam("leadName");
        console.log("leadName:"+leadName);
        component.set("v.leadName",leadName);

        var status=event.getParam("status");
        console.log("status:"+status);
        component.set("v.status",status);

        var modality=event.getParam("modality");
        console.log("modality:"+modality);
        component.set("v.modality",modality);

        var rank=event.getParam("rank");
        console.log("rank:"+rank);
        component.set("v.rank",rank);

        var sortBy=event.getParam("sortBy");
        console.log("sortBy:"+sortBy);
        component.set("v.sortBy",sortBy);        
        console.log("after setting attributes in component");
        var leads2=component.get("v.leads");		
	}
})