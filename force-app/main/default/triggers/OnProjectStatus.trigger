trigger OnProjectStatus on Project_Status__c (after insert, after update,before insert,before update) {

    TriggerCustomSetting__c triggerCustomSettings = TriggerCustomSetting__c.getOrgDefaults();

    if(Trigger.isAfter && Trigger.isInsert) {
        if (triggerCustomSettings.NexusProjectStatusAfterInsert__c == true) {
            afterNexus();
        }
    }

    if(Trigger.isAfter && Trigger.isUpdate) {
        if (triggerCustomSettings.NexusProjectStatusAfterUpdate__c == true) {
            afterNexus();
        }
    }

    if(Trigger.isBefore && Trigger.isInsert) {
        if (triggerCustomSettings.NexusProjectStatusBeforeInsert__c == true) {
            beforeNexus();
        }
    }

    if(Trigger.isBefore && Trigger.isUpdate) {
        if (triggerCustomSettings.NexusProjectStatusBeforeUpdate__c == true) {
            beforeNexus();
        }
    }

    private void afterNexus() {
        if(CheckRecursive.runOnce() && CheckRecursive.getRecursionCounter() == 1){
            //OnProjectStatusHelper.setDataAggiornamento(trigger.new);
            OnProjectStatusHelper.CalculateDaysDiffExcludingHoliday();
            OnProjectStatusHelper.CalculateTotalFTE();
        } else {
            System.debug('ENTRATO NELL ELSE');
            checkRecursive.resetRunOnce();        
        }
    }

    private void beforeNexus() {
        OnProjectStatusHelper opsh = new OnProjectStatusHelper(trigger.New);
        for(Project_Status__c project : trigger.New){
            opsh.setAccountAndReferenceNumber(project);
            if(trigger.isUpdate){
                if(! trigger.oldMap.containsKey(project.id)){
                    project.Data_Aggiornamento__c = (Date)  system.today();
                }else{
                    OnProjectStatusHelper.setDataAggiornamento(project,trigger.oldMap.get(project.id));
                }
            }else{
                project.Data_Aggiornamento__c = (Date)  system.today();
            }
        }
    }
}