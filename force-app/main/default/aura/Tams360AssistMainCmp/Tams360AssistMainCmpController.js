({
	showSearch : function(component, event, helper) {
        console.log('Inside showSearch');
		var searchCmp = component.find("searchDiv").getElement();
        console.log('searchCmp:'+searchCmp);
        $A.util.removeClass(searchCmp,"slds-hide");
        $A.util.addClass(searchCmp, "slds-show");
		var searchBtn = component.find("searchButton").getElement();
        console.log('searchBtn:'+searchBtn);
        $A.util.removeClass(searchBtn,"slds-show");
        $A.util.addClass(searchBtn, "slds-hide");        
	},
	hideSearch : function(component, event, helper) {
        console.log('Inside hideSearch');
		var searchCmp = component.find("searchDiv").getElement();
        console.log('searchCmp:'+searchCmp);
        $A.util.removeClass(searchCmp,"slds-show");
        $A.util.addClass(searchCmp, "slds-hide");
		var searchBtn = component.find("searchButton").getElement();
        console.log('searchBtn:'+searchBtn);
        $A.util.removeClass(searchBtn,"slds-hide");
        $A.util.addClass(searchBtn, "slds-show");                
    },    
})