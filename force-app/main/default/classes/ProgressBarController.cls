public class ProgressBarController {
    @AuraEnabled
    public static Opportunity getOppFields(Id recordId){
        system.debug('Ø-recordId ' + recordId);
        Opportunity opp = [SELECT Id, Amount,Totale_Draft__c,Totale_Fatture_Inviate__c,Totale_Saldato__c,
                                Fatturato_Da_Pianificare__c,Totale_Da_Fatturare__c,Totale_Saldato_Percentuale__c,Indicatore_Gap__c
                          FROM Opportunity
                          WHERE Id =: recordId];
        return opp;  
    }
}
