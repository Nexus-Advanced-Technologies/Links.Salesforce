({
    doInit : function(component, event, helper) {
        var mobile;
        var device = $A.get("$Browser.formFactor");
        if(device == "PHONE"){
            mobile = true;
        }else{
            mobile = false;
        }
        component.set("v.isOnMobile", mobile);
    },
    
    //Method to send mail with PDF 
    sendEmail : function(component, event, helper) {
        var message = '';
        var oppId = component.get("v.idObject");      
        var pillsComponent = component.find('pillsInput');
        var pillsList = pillsComponent.get('v.pills');
        var ToField = [];
        for (var i = 0; i < pillsList.length; i++){
            ToField[i] = pillsList[i].label;
        }
        var emailPdf = component.get("c.sendEmailAllStates");
        emailPdf.setParams({
            DestinationAddress : ToField,
            recordId : oppId            
        }); 
        emailPdf.setCallback(this,function(res){ 
            var resp = res.getReturnValue();
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
            helper.showToast(component, event, helper, resp,message);
        })
        $A.enqueueAction(emailPdf); 
    },
    closeSendMailPopup : function(component, event, helper){
        
        var appEvent = $A.get("e.c:CloseModalEvent");
        appEvent.setParams({
            "closeMoldal" : true });
        appEvent.fire();
    },
    
    handleApplicationEvent : function(component, event) {
        var checkPills = event.getParam("checkPills");
        if (checkPills === true ){
            component.set("v.checkSendMail",false);
        }else{
            component.set("v.checkSendMail",true);
        }
    },
})