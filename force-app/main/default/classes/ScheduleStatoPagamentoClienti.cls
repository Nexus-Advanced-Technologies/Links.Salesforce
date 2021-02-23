global class ScheduleStatoPagamentoClienti implements Schedulable {

	global void execute(SchedulableContext ctx) {
		
		azzera();
		controlloFatturePagate();

		StatoPagamentoClienti spc = new StatoPagamentoClienti();
		Database.executebatch(spc);
	}

	private void azzera(){
		List<Account> accountReset = [SELECT Id,name,DifferenceDay__c FROM Account WHERE DifferenceDay__c != null]; 
		for(Account acc : accountReset){
			acc.DifferenceDay__c = null;
		}
		update accountReset;
	}
	private void controlloFatturePagate(){
		List <AggregateResult> accountCount = [SELECT  Opportunity__r.AccountId acc
																						FROM InvoiceMilestone__c
																						WHERE Stage__c = 'Fattura Pagata'
																						GROUP BY Opportunity__r.AccountId];

																						List<Account> accountSaldoOk = new List <Account>();

		for(AggregateResult agg : accountCount){
			Account a = new Account(
				Id = (id)agg.get('acc'),
				DifferenceDay__c = 0
			);
			accountSaldoOk.add(a);
		}
	}
}