global class StatoPagamentoClienti implements Database.Batchable<sObject>, Database.Stateful {

    global Database.QueryLocator start(Database.BatchableContext bc) {
        return Database.getQueryLocator('SELECT Id, Name , NumeroInvoiceNonPagato__c FROM Account');
        // collect the batches of records or objects to be passed to execute  
    }

    global void execute(Database.BatchableContext bc, List<Account> scope){ // process each batch of records
        
        String whereClausole = FattureInCloudSettings__c.getOrgDefaults().StatoFattura__c; 
        Map<Id, Account> accountMap = new Map<Id, Account>(scope);
        
        List <AggregateResult> accountCount = [SELECT  Opportunity__r.AccountId acc, min(Data_Prevista__c) dtp
        FROM Invoice_Milestone__c
        WHERE Stato__c =: whereClausole and Data_Prevista__c < Today
        GROUP BY Opportunity__r.AccountId];

       
        if(accountCount.size() > 0){           
            for(AggregateResult agg:accountCount){
                Account acc = accountMap.get((id)agg.get('acc')); //prende Id dei vari account 
                if(acc != null){
                 acc.DifferenceDay__c = calculateDifferce((Date)agg.get('dtp')); //inserisce i giorni di differenza tra la data prevista ed oggi
                }
            }
        }
        
        if(accountMap.size() > 0){
            try{
                update accountMap.values();
            }catch(DmlException e){
                System.debug('*** The following exception has occurred: ' + e.getMessage());
            }
        }
    }

    global void finish(Database.BatchableContext bc){
        // execute any post-processing operations
    }    

    //Calcola la differenza dei giorni dalla data previst a quella odierna 
    public Integer calculateDifferce(Date dataPrevista){   
         return dataPrevista.daysBetween(Date.Today());
    }
}