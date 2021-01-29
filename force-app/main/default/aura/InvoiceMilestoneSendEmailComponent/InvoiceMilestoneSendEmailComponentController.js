({
	 doInit: function (component, event, helper) {
        var recordId = component.get("v.recordId");  
       if(recordId){
        var initAction = component.get("c.startSendEmailWorkflow");
        initAction.setParams({
            InvoiceMilestoneId : recordId
        });
        initAction.setCallback(this, function (response) {
            var resp = response.getReturnValue();            	
            if(resp){
                helper.showToast("Operazione riuscita", 'la mail è stata inviata', "Success");
               }    
            else if(!resp)
             helper.showToast("Operazione fallita", 'errore nell\'invio dell\'e-mail, controllare la classe: InvoiceMilestoneHandler' , "Error");
            
            $A.get("e.force:closeQuickAction").fire();              
        });
        $A.enqueueAction(initAction);
       }else{
        $A.get("e.force:closeQuickAction").fire();
        helper.showToast("ERRORE!", 'RecordId non presente, contatta l\'admin Salesforce', "Error");
       }
    },
})