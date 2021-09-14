({
    handleSelect : function (component, event, helper) {
        var action = component.get('c.oldValue');
        var rid = component.get('v.recordId');
        var stepName = event.getParam("detail").value;
        component.set("v.nextStage",stepName);
        action.setParams({id  : rid});
        action.setCallback(this, function(data) {
            let returnValue = data.getReturnValue() !== stepName;
            console.log('returnValue ' + returnValue + 'data.getReturnValue()' + data.getReturnValue() + 'stepName ' + stepName);
            component.set("v.oldStage", data.getReturnValue());
            component.set("v.isTrue", returnValue);
        });	
        $A.enqueueAction(action);
        console.log(JSON.stringify(event.getParam("detail")));
        console.log(component.get("v.isTrue"));
    },
    updateStage: function (component, event, helper) {
        let action = component.get("c.updateStatus");
        var stepName = component.get("v.nextStage");
        action.setParams({
            statusApiName: stepName, recordId: component.get("v.recordId"), oldValue: component.get("v.oldStage")
        });
        action.setCallback(this, function(response){
            let State = response.getState();
            if(State === "SUCCESS"){
                component.set("v.oldStage", stepName);
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