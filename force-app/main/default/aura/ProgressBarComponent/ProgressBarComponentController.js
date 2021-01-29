({
    doInit : function(component, event, helper) {
        //Action that initialized the opportunity field
       // component.set("v.ToField", "giuseppe.dedonno@nexusat.it");  
        var oppId = component.get("v.recordId");
        var initOpp = component.get("c.getOppFields");
        initOpp.setParams({
            recordId: oppId
        });
        initOpp.setCallback(this, function (response){ 
            component.set("v.oppList", response.getReturnValue());             
        });
        $A.enqueueAction(initOpp); 
    },
    //Method to go Back
    goBack : function (component, event, helper) {
        window.history.back();
    },
    
    openSendMailPopup : function(component, event, helper){
        
        var ToList = component.get("v.ToField");
        var appEvent = $A.get("e.c:pillsInputEvent");
        appEvent.setParams({
            "ToField" : ToList });
        appEvent.fire();
        
        var cmpTarget = component.find('Modalbox');
        $A.util.addClass(cmpTarget, 'slds-fade-in-open slds-backdrop slds-backdrop--open');
    },    
    
    handleCloseModalEvent : function(component, event, helper) {
        var closeModal = event.getParam("closeMoldal");
        if (closeModal == true){
            helper.closePopup(component,event,helper);
        }
    }
})