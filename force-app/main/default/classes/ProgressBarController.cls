/**
 * @description       : 
 * @author            : 
 * @last modified on  : 25/01/2021
 * @last modified by  : ¤ → alessio.marra@nexusat.it
 * Modifications Log 
 * Ver   Date         Author                         Modification
 * 1.0                                               Initial Version
 * 1.1   25/01/2021   ¤ → alessio.marra@nexusat.it   Review ApiName Nomenclature
**/
public class ProgressBarController {
	@AuraEnabled
	public static Opportunity getOppFields(Id recordId){
		system.debug('Ø-recordId ' + recordId);
		Opportunity opp = [SELECT Id, Amount,TotalInDraft__c,TotalSentInvoices__c,TotalSettled__c,
							RevenueToPlan__c,TotalToBeInvoiced__c,TotalSettledPercentage__c,GapIndicator__c
							FROM Opportunity
							WHERE Id =: recordId];
		return opp;
	}
}