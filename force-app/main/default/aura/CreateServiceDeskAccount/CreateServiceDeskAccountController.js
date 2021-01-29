({
    gotoURL : function (component, event, helper) {
        var rand = Math.round(Math.random() * (5000 - 1000)) + 1000;
        window.setTimeout(
            $A.getCallback(function() {
        		var urlEvent = $A.get("e.force:navigateToURL");
                urlEvent.setParams({
                    "url": component.get("v.baseUrl")+
                    		"?summary="+component.get("v.Opportunity.Name")+
                    		"&customfield_12801="+component.get("v.Opportunity.Reference_Number__c")+
                    		"&customfield_13000="+component.get("v.Opportunity.Account.Name")
                });
                urlEvent.fire();
                var dismissActionPanel = $A.get("e.force:closeQuickAction");
                dismissActionPanel.fire();
            }), rand
        );
    }
})