({
    showToast : function(component, event, helper, controlBit, message ) {
        var toastEvent = $A.get("e.force:showToast");
        if (controlBit == true){
            toastEvent.setParams({
                "title": "Successo!",
                "type": "success",
                "message": message
            });
            
        }else{
            toastEvent.setParams({
                "title": "Errore!",
                "type": "error",
                "message": message
            });
        }
                 toastEvent.fire();
        
        var appEvent = $A.get("e.c:CloseModalEvent");
        appEvent.setParams({
            "closeMoldal" : true });
        appEvent.fire();
    },
})