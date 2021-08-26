({
    handleSelect : function (component, event, helper) {
        console.log(JSON.stringify(event.getParam("detail")));
        var stepName = event.getParam("detail").value;
        component.set("v.nextStage",stepName);
    },
    updateStage: function (component, event, helper) {
    	 let action = component.get("c.updateStatus");
        var stepName = component.get("v.nextStage");
        action.setParams({
            statusApiName: stepName, recordId: component.get("v.recordId")
        });
        action.setCallback(this, function(response){
            let State = response.getState();
            if(State === "SUCCESS"){
               if(stepName == "2" || stepName == "3"){
                     setTimeout( 
                    function () { 
                        window.location.reload(true);
                    });
                }else{ 
                $A.get('e.force:refreshView').fire();
                }
            }else{
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    "title": "Error!",                   
                    "message": response.getError()[0].message,
                    "type": "error"
                });
                toastEvent.fire();
                $A.get('e.force:refreshView').fire();
            }})
        $A.enqueueAction(action);
    }
})