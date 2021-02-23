({
    init: function(component, helper) {
        if (component.get('v.scriptsLoaded') === true) {
            helper.parseFieldToPills(component, helper);
        }
    },
    
    addFirstPills: function(component, helper, value) {
        var pills = component.get('v.pills');
        var isValid = true;
        var check = helper.isInputValid(component, helper, value);
        pills.push({
            id: lexUtil.guidGenerator(),
            label: value,
            isValid: check
        });        
        var appEvent = $A.get("e.c:pillsEvent");
        appEvent.setParams({
            "checkPills" : check });
        appEvent.fire();        
        component.set('v.pills', pills);
    },
    
    addNewPills: function(component, helper, values) {
        var pills = component.get('v.pills');
        var checkPills = true;
        var isValid = true;
        for (var i = 0; i < values.length; i++) {
            var trimmedVal = values[i].trim();
            if (trimmedVal !== "") {
                pills.push({
                    id: lexUtil.guidGenerator(),
                    label: trimmedVal,
                    isValid: helper.isInputValid(component, helper, trimmedVal)
                });
            }
        }        
        for (var i = 0; i < pills.length; i++) {
            if(pills[i].isValid == false){
                checkPills = false;
            }
        }
        var appEvent = $A.get("e.c:pillsEvent");
        appEvent.setParams({
            "checkPills" : checkPills });
        appEvent.fire();
        component.set('v.pills', pills);
    },
    
    isInputValid: function(component, helper, value) {
        return regexUtil.validateInput(component.get('v.validationTypes'), value);
    },
    
    parsePillsToField: function(component, helper) {
        var pills = component.get('v.pills');
        var delimiterInDatabase = component.get('v.delimiterInDatabase');
        var fieldStr = '';
        for (var i = 0; i < pills.length; i++) {
            
            fieldStr += pills[i].label + delimiterInDatabase;
        }
        
        try {
            component.set('v.value', fieldStr);
        } catch (e) {
            //ignore issue that occurs when trying to set unbinded value
        }
    },
    
    parseFieldToPills: function(component, helper) {
        var fieldStr = component.get('v.value');
        var delimiterInDatabase = component.get('v.delimiterInDatabase');
        var pills = [];
        var splitFieldStr = [];
        var isValid = true;
        var checkPills = true;
        if (fieldStr != null) {
            splitFieldStr = fieldStr.split(delimiterInDatabase);
        }
        
        for (var i = 0; i < splitFieldStr.length; i++) {
            isValid = helper.isInputValid(component, helper, splitFieldStr[i]);
            if (splitFieldStr[i] != "") {
                
                pills.push({
                    id: lexUtil.guidGenerator(),
                    label: splitFieldStr[i],
                    isValid: isValid
                });
            }
            if (isValid == false){
                checkPills = false;
            }
        }
        component.set('v.pills', pills);
    }
})