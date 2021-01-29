({
    doInit : function(component, event, helper) {
        //Action that initialized the date
        var oppId = component.get("v.recordId");
        var initOppField = component.get("c.getOppField");
        initOppField.setParams({
            recordId: oppId
        });
        initOppField.setCallback(this, function (response){ 
            component.set("v.oppList", response.getReturnValue());             
        });
        $A.enqueueAction(initOppField); 
        
    },
    
    sendMail : function(component, event, helper) {
        var url = window.location.protocol + "//" + window.location.host;
        var message = '';
        
        var oppId = component.get("v.recordId");
        var sendmail1 = component.get("c.sendEmail");
        sendmail1.setParams({
            recordId : oppId
        });
        sendmail1.setCallback(this, function (response){ 
            var resp = response.getReturnValue();
            if(resp == true){
                message += "Inoltro avvenuto con successo"
            }else{
                var errors = response.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) 
                        message += "Errore: " + errors[0].message;                  
                } else {
                    message += "Errore sconosciuto, rivolgiti al tuo Amministratore di Sistema"; 
                }
            }
            helper.showToast(component,event,helper,message,resp,oppId,url);
        });
        $A.enqueueAction(sendmail1);
    }
})