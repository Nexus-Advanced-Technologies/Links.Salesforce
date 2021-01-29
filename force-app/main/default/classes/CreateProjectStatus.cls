/**
 * @description       : 
 * @author            : 
 * @last modified on  : 25/01/2021
 * @last modified by  : ¤ → alessio.marra@nexusat.it
 * Modifications Log 
 * Ver   Date         Author                         Modification
 * 1.0                                               Initial Version
 * 1.1   16/11/2020   ¤ → alessio.marra@nexusat.it   In the createProjectStatus (Opportunity opp) method, the ReferenceNumber__c and Account__c fields will be aligned with corresponding fields present in the parent opportunity
 * 1.2   25/01/2021   ¤ → alessio.marra@nexusat.it   Review ApiName Nomenclature
**/
public class CreateProjectStatus {
	private static Map<Id, Quote> quoteMap = New Map<Id, Quote>();
	private static Id recordTypeNexus = [SELECT Id FROM RecordType WHERE SObjectType = 'ProjectStatus__c' AND DeveloperName = 'Nexus' AND IsActive = true LIMIT 1].Id;
	
	//Called from Proces Builder
	@InvocableMethod
	public static void createProjectStatusInvocable(List<Id> listOppIds){
		List<ProjectStatus__c> listProjectStatus = New List<ProjectStatus__c>();
		List<Opportunity> oppList = [SELECT Id, Name, SyncedQuoteId, DeliveryProjectManager__c, ReferenceNumber__c, AccountId
										FROM Opportunity
										WHERE Id In : listOppIds];

		Map<Id, Opportunity> oppMap = New Map<Id, Opportunity>(oppList);
		quoteMap = New Map<Id, Quote>([SELECT Id, Status, BudgetDD__c FROM Quote WHERE Id in : getQuoteIdList(oppList)] );

		for(Opportunity opp : oppMap.values()) {
			//Check SyncedQuoteId != ''
			System.debug('Id +'+ opp.SyncedQuoteId);
			if(opp.SyncedQuoteId != null){
				if(quoteMap.get(opp.SyncedQuoteId).Status == 'Accepted'){
					//call method that create project status
					ProjectStatus__c ps = createProjectStatus(opp);
					listProjectStatus.add(ps);
				}
			}
		}
		if(!listProjectStatus.isEmpty()){
			System.debug(listProjectStatus);
			insert listProjectStatus;
		}
	}
	
	//Create Project Status
	public static ProjectStatus__c createProjectStatus(Opportunity opp) {
		//get the Opportunity Name without NX-0000
		//String psName = '';
		//psName = opp.Name.substring(9);

		ProjectStatus__c newProjectStatus = New ProjectStatus__c();
		//newProjectStatus.Name = 'Project - ' + psName;
		newProjectStatus.Name = 'Project - ' + opp.Name;
		newProjectStatus.Pm__c = opp.DeliveryProjectManager__c;
		newProjectStatus.Opportunity__c = opp.Id;
		newProjectStatus.BudgetDD__c = quoteMap.get(opp.SyncedQuoteId).BudgetDD__c;
		newProjectStatus.ReferenceNumber__c = opp.ReferenceNumber__c;
		newProjectStatus.Account__c = opp.AccountId;
		newProjectStatus.RecordTypeId = recordTypeNexus;

		return newProjectStatus;
	}

	//getQuoteIdList
	public static List<Id> getQuoteIdList(List<Opportunity> oppList){
		List<Id> quoteListId = New List<Id>();

		for(Opportunity opp : oppList){
			quoteListId.add(opp.SyncedQuoteId);
		}
		return quoteListId;
	}
}