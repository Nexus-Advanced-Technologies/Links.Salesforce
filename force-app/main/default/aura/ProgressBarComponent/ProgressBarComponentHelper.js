({
    showToast : function(component, event, helper, message, controlBit, oppId, url) {
        var toastEvent = $A.get("e.force:showToast");
        if (controlBit == true){
            toastEvent.setParams({
                "title": "Successo!",
                "type": "success",
                "message": message
            });
            setTimeout( 
                function () { 
                    window.open(url+"/lightning/r/Opportunity/"+oppId+"/view",'_top');
                }, 2000); 
        }else{
            toastEvent.setParams({
                "title": "Errore!",
                "type": "error",
                "message": message
            });
        }
        toastEvent.fire();
    },
    closePopup : function(component, event, helper){
        var cmpTarget = component.find('Modalbox');
        $A.util.removeClass(cmpTarget,'slds-fade-in-open slds-backdrop slds-backdrop--open');
    },
})