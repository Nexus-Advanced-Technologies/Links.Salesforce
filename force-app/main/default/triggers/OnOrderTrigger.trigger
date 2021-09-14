trigger OnOrderTrigger on Order (before update) {
    Map<String, List<Order>> triggerNewSplittedMap = TriggerUtilities.splitByCompany(Trigger.new);
    Map<String, TriggerSetting__mdt> triggerSettings = new Map<String, TriggerSetting__mdt>();
    for (TriggerSetting__mdt var : TriggerUtilities.TriggerSettingOrder) {
        triggerSettings.put(var.DeveloperName, var);
    }
    if (triggerNewSplittedMap.containsKey('Links')) {
        List<Order> triggerNewSplitted = triggerNewSplittedMap.get('Links');
        if(Trigger.isBefore && Trigger.isUpdate){
            if (triggerSettings.get('Links').OrderBeforeUpdate__c) {
                for(Order order : triggerNewSplitted){
                    if(order.Status == 'Activated' && Trigger.OldMap.get(order.Id).Status != 'Activated'){
                        if(OnOrderTriggerHelper.hasContractOrder(order)){
                            order.addError('NON PUOI PASSARE ALLO STATO WITH ODA SE NON VI E\' ALMENO UN CONTRATTO ALLEGATO');
                        }
                    }
                }
            }
        }
    }
}