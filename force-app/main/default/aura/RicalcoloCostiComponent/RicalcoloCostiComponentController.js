({
    doInit : function(component, event, helper) {
        var oppId = component.get("v.recordId");
        var initOpp = component.get("c.updateCosti");
        initOpp.setParams({
            recordId: oppId
        });
        location.reload();
        $A.enqueueAction(initOpp); 
    }    
})