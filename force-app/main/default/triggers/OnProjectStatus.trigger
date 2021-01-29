/**
 * @description       : 
 * @author            : 
 * @last modified on  : 29/01/2021
 * @last modified by  : ¤ → alessio.marra@nexusat.it
 * Modifications Log 
 * Ver   Date         Author                         Modification
 * 1.0                                               Initial Version
 * 1.1   25/01/2021   ¤ → alessio.marra@nexusat.it   Added controll to enable/disable
**/
trigger OnProjectStatus on ProjectStatus__c (after insert, after update, before insert, before update) {
	System.debug('¤ OnProjectStatus {');
		
	//Get Trigger.new List splitted by company in Map(company, list)
	Map<String, List<ProjectStatus__c>> triggerNewSplittedMap = TriggerUtilities.splitByCompany(Trigger.new);

	//Get CustomMetadata with trigger information for each company
	Map<String, TriggerSetting__mdt> triggerSettings = new Map<String, TriggerSetting__mdt>();
	for (TriggerSetting__mdt var : [SELECT DeveloperName, ProjectStatusAfterInsert__c, ProjectStatusAfterUpdate__c, ProjectStatusBeforeInsert__c, ProjectStatusBeforeUpdate__c FROM TriggerSetting__mdt]) {
		triggerSettings.put(var.DeveloperName, var);
	}

	if (triggerNewSplittedMap.containsKey('Nexus')) {
		List<ProjectStatus__c> triggerNewSplitted = triggerNewSplittedMap.get('Nexus');

		if (Trigger.isAfter && Trigger.isInsert) {
			if (triggerSettings.get('Nexus').ProjectStatusAfterInsert__c) {
				afterNexus();
			}
		}

		if (Trigger.isAfter && Trigger.isUpdate) {
			if (triggerSettings.get('Nexus').ProjectStatusAfterUpdate__c) {
				afterNexus();
			}
		}

		if (Trigger.isBefore && Trigger.isInsert) {
			if (triggerSettings.get('Nexus').ProjectStatusBeforeInsert__c) {
				beforeNexus(triggerNewSplitted, new List<ProjectStatus__c>());
			}
		}

		if (Trigger.isBefore && Trigger.isUpdate) {
			Map<String, List<ProjectStatus__c>> triggerOldSplittedMap = TriggerUtilities.splitByCompany(Trigger.old);
			List<ProjectStatus__c> triggerOldSplitted = triggerOldSplittedMap.get('Nexus');
			if (triggerSettings.get('Nexus').ProjectStatusBeforeUpdate__c) {
				beforeNexus(triggerNewSplitted, triggerOldSplitted);
			}
		}
	}
	System.debug('¤ } OnProjectStatus');


	void afterNexus() {
		if(CheckRecursive.runOnce() && CheckRecursive.getRecursionCounter() == 1){
			//OnProjectStatusHelper.setDataAggiornamento(trigger.new);
			//OnProjectStatusHelper.CalculateDaysDiffExcludingHoliday();
			//OnProjectStatusHelper.CalculateTotalFTE();
		} else {
			System.debug('ENTRATO NELL ELSE');
			checkRecursive.resetRunOnce();
		}
	}

	void beforeNexus(List<ProjectStatus__c> triggerNew, List<ProjectStatus__c> triggerOld) {
		Map<Id, ProjectStatus__c> triggerOldMap = new Map<Id, ProjectStatus__c>();
		for (ProjectStatus__c var : triggerOld) {
			triggerOldMap.put(var.Id, var);
		}

		OnProjectStatusHelper opsh = new OnProjectStatusHelper(triggerNew);
		for(ProjectStatus__c project : triggerNew){
			opsh.setAccountAndReferenceNumber(project);
			if(trigger.isUpdate){
				if(! triggerOldMap.containsKey(project.id)){
					project.UpdateDate__c = (Date) System.today();
				}else{
					OnProjectStatusHelper.setDataAggiornamento(project,triggerOldMap.get(project.id));
				}
			}else{
				project.UpdateDate__c = (Date) System.today();
			}
		}
	}
}