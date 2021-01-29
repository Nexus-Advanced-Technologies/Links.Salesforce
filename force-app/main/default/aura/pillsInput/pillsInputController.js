({
    scriptsLoaded: function(component, event, helper) {
        component.set('v.scriptsLoaded', true);
        helper.init(component, helper);
    },
    
    init: function(component, event, helper) {
        helper.init(component, helper);
    },
    
    handlePillsChanged: function(component, event, helper) {
        helper.parsePillsToField(component, helper);
        console.log(component.get("{!v.pills}"));
    },
    
    handleValueChanged: function(component, event, helper) {
        if (component.get('v.valueDataLoaded') === false && component.get('v.scriptsLoaded') === true && component.get('v.value') !== null) {
            component.set('v.valueDataLoaded', true);
            helper.parseFieldToPills(component, helper);
            console.log(component.get("{!v.pills}"));
        }
    },
    
    onKeyUpInput: function(component, event, helper) {
        var delimiter = component.get('v.delimiter');
        var inputText = component.find('inputText').getElement();
        var currentInput = inputText.value;
        if (currentInput[currentInput.length - 1] === delimiter || event.keyCode === 13) {
            helper.addNewPills(component, helper, currentInput.split(delimiter));
            inputText.value = '';
        }
        console.log(component.get("{!v.pills}"));
    },
    
    onRemovePill: function(component, event, helper) {
        var pillId = event.getSource().get('v.name');
        var pills = component.get('v.pills');
        var checkPills = true;
        for (var i = 0; i < pills.length; i++) {
            if (pillId === pills[i].id) {
                pills.splice(i, 1);
                break;
            }
        }
        if (pills.length == 0){
            checkPills = false
        }else{
            for (var i = 0; i < pills.length; i++) {
                if (pills[i].isValid === false){
                    checkPills = false;
                }
            }
        }               
        component.set('v.pills', pills);
        var appEvent = $A.get("e.c:pillsEvent");
        appEvent.setParams({
            "checkPills" : checkPills });
        appEvent.fire();
    },
    
    handleApplicationEvent : function(component, event, helper) {
        var ToList = event.getParam("ToField");
        var pills = component.get('v.pills');
        pills.splice(0, pills.length);
        for (var i = 0; i < ToList.length; i++){
            helper.addFirstPills(component, helper, ToList[i]);
        }
    }
})