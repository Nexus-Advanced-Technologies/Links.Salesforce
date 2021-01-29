@isTest
private class ScheduleStatoPagamentoTest{

	public ScheduleStatoPagamentoTest(){}

	@TestSetup
	static  void impostazioneDati(){

		List<Account> lstAccount = new List<Account>(); //lista account
		List<Opportunity> lstOpportunity = new List<Opportunity>(); //lista opportunity 
		List<InvoiceMilestone__c> lstInvoiceMilestone = new List<InvoiceMilestone__c>(); //lista Invoice Milestone

	   

		//Valorizzo una lista di 200 account
		for(Integer i=0 ;i <200;i++){
			Account acc = new Account();
			acc.Name ='Name'+i;
			acc.DifferenceDay__c = 20 ;
			lstAccount.add(acc);
		}
		insert lstAccount;   

		 //ciclo la lista di account e per ognuno di essi inserisco le opportunity
		for(Account ac : lstAccount){     
			for(Integer i=0 ;i <3;i++){
				Opportunity opp1 = new Opportunity();
					opp1.AccountId = ac.id;
					opp1.Name = 'oppTest'+ i;
					opp1.StageName = 'Prospecting' + i;
					opp1.CloseDate = Date.today();
					lstOpportunity.add(opp1);
			}
		}
		insert lstOpportunity;
		
		//ciclo la lista di opportunity e per ognuna di esse inserisco le invoice milestone
		for(Opportunity opp: lstOpportunity){
			for(Integer i=0 ;i <3;i++){
				InvoiceMilestone__c inv = new InvoiceMilestone__c();
				inv.Name = 'intTest' + i;
				inv.ExpectedDate__c = Date.today() - 1;
				inv.Stage__c = 'Fattura Pagata';
				inv.Opportunity__c = opp.id;
				lstInvoiceMilestone.add(inv);
			}
		}
		insert lstInvoiceMilestone;
	}
	@isTest
	static  void eseguiTest(){
		Test.startTest();
		ScheduleStatoPagamentoClienti obj = new ScheduleStatoPagamentoClienti();
		String chron = '0 0 23 * * ?';        
		System.schedule('Test Sched', chron, obj);
		Test.stopTest();
	}
}