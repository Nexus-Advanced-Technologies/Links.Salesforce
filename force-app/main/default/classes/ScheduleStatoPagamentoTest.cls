/**
 * @description       : 
 * @author            : 
 * @last modified on  : 02/02/2021
 * @last modified by  : ¤ → alessio.marra@nexusat.it
**/
@isTest
private class ScheduleStatoPagamentoTest{

	public ScheduleStatoPagamentoTest(){}

	private static List<TriggerSetting__mdt> createCustomMetadata(Boolean status) {
		List<TriggerSetting__mdt> triggerSettingMDT = (List<TriggerSetting__mdt>) Json.deserialize(
			'[' +
				'{' +
					'"DeveloperName": "Nexus",' +
					'"OpportunityBeforeInsert__c": "' + status + '"' +
				'}' +
			']'
			,List<TriggerSetting__mdt>.class
		); 
		return triggerSettingMDT;
	}

	@TestSetup
	static  void impostazioneDati(){

		List<Account> lstAccount = new List<Account>(); //lista account
		List<Opportunity> lstOpportunity = new List<Opportunity>(); //lista opportunity 
		List<InvoiceMilestone__c> lstInvoiceMilestone = new List<InvoiceMilestone__c>(); //lista Invoice Milestone

		Account acc = new Account();
		acc.Name = 'Name Test';
		acc.DifferenceDay__c = 20;
		insert acc;

		Opportunity opp = new Opportunity();
		opp.AccountId = acc.id;
		opp.Name = 'Opportunity Test';
		opp.StageName = 'Prospecting';
		opp.CloseDate = Date.today();
		insert opp;
		
		InvoiceMilestone__c inv = new InvoiceMilestone__c();
		inv.Name = 'Invoice Test';
		inv.ExpectedDate__c = Date.today().addDays(-1);
		inv.Stage__c = 'Fattura Pagata';
		inv.Opportunity__c = opp.id;
		insert inv;
	}
	@isTest
	static  void eseguiTest(){
		Test.startTest();
		TriggerUtilities.TriggerSettingOpportunity = createCustomMetadata(true);
		ScheduleStatoPagamentoClienti obj = new ScheduleStatoPagamentoClienti();
		String chron = '0 0 23 * * ?';
		System.schedule('Test Sched', chron, obj);
		Test.stopTest();
	}
}