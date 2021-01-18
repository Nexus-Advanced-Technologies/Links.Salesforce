@isTest
private class StatoPagamentoTest {

    public StatoPagamentoTest() {
    }

    @TestSetup
    static  void impostazioneDati(){

        List<Account> lstAccount = new List<Account>(); //lista account
        List<Opportunity> lstOpportunity = new List<Opportunity>(); //lista opportunity 
        List<Invoice_Milestone__c> lstInvoiceMilestone = new List<Invoice_Milestone__c>(); //lista Invoice Milestone
        FattureInCloudSettings__c fattureInCloudeSettings = new FattureInCloudSettings__c();
        fattureInCloudeSettings.StatoFattura__c = 'Fattura Inviata';

        insert fattureInCloudeSettings;

        //Valorizzo una lista di 200 account
        for(Integer i=0 ;i <200;i++){
            Account acc = new Account();
            acc.Name ='Name'+i;
            acc.NumeroInvoiceNonPagato__c = i;
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
                Invoice_Milestone__c inv = new Invoice_Milestone__c();
                inv.Name = 'intTest' + i;
                inv.Data_prevista__c = Date.today() - 1;
                inv.Stato__c = 'Fattura Inviata';
                inv.Opportunity__c = opp.id;
                lstInvoiceMilestone.add(inv);
            }
        }
        insert lstInvoiceMilestone;
    }

    @isTest
    static  void eseguiTest(){
        Test.startTest();
        StatoPagamentoClienti obj = new StatoPagamentoClienti();
        DataBase.executeBatch(obj); 
        Test.stopTest();
    }
}