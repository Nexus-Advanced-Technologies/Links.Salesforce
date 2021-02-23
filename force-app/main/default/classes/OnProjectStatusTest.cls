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
@isTest
public class OnProjectStatusTest {

	@testSetup
	public static void testOnProjectStatus() {

		OpportunitySetting__c sett = new OpportunitySetting__c(
			FteWhere__c = 'Name = \'TestName\''
		);
		insert sett;

		Account account = new Account(
			name= 'TestName');
		insert account;
		
		Opportunity opportunity = new Opportunity(
			AccountId = account.id,
			Name = 'oppTest',
			StageName = 'Prospecting',
			CloseDate = Date.today());
		insert opportunity;
		
		ProjectStatus__c ProjectStatus = new ProjectStatus__c(
			name = 'TestName',
			BudgetDD__c = 10000,
			ExpectedEndDate__c = Date.today()+30,
			EstimatedToFinishDD__c = 5,
			Opportunity__c = opportunity.Id);
		insert ProjectStatus;
	}
	
	
	@istest
	public static void testOnProjectStatusSchedulable(){
		OnProjectStatusSchedulable ops = new OnProjectStatusSchedulable();
		String CRON_EXP = '0 0 0 15 3 ? 2022';
		System.schedule('test', CRON_EXP, ops);
		
	}
	
}