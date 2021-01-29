({
    doInit : function(component, event, helper) {
        var url = window.location.protocol + "//" + window.location.host;
        var message = "";
        //Action that initialized the date
        var oppId = component.get("v.recordId");
        var initOppField = component.get("c.createInvoiceMilestone");
        initOppField.setParams({
            recordId: oppId
        });
        initOppField.setCallback(this, function (response){ 
            var resp = response.getReturnValue();
            if(resp == true){
                message += "Invoice Milestone Inserite con successo"
            }else{
                    message += "Inserire un Dettaglio dello Schema di Fatturazione"; 
            }
          helper.showToast(component,event,helper,message,resp,oppId,url);
        });
        $A.enqueueAction(initOppField); 
    }
})