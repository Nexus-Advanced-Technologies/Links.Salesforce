/**
 * @description       : 
 * @author            : alessio.marra@nexusat.it ¤
 * @last modified on  : 22/01/2021
 * @last modified by  : alessio.marra@nexusat.it ¤
 * Modifications Log 
 * Ver   Date         Author                       Modification
 * 1.0   22/01/2021   alessio.marra@nexusat.it ¤   Initial Version
**/
global class RicalcoloCosti {}
//implements Database.Batchable<sObject> {
//     private String oppId;
    
//     global RicalcoloCosti(String oppId){
//         this.oppId = oppId;
//     }
    
//     @AuraEnabled
//     public static void updateCosti(Id recordId){
//         system.debug('Ø-recordId ' + recordId);
//         database.executebatch(new RicalcoloCosti(recordId));
//     }
    
//     global Database.QueryLocator start(Database.BatchableContext bc) {
//         Id prjId = [SELECT Opportunity__c, Id FROM Project_Status__c WHERE Opportunity__c =: oppId].Id;
//         return Database.getQueryLocator('SELECT Id, Name, Issue__c FROM Worklog__c WHERE Issue__r.Project__c =: prjId');
//     }
    
//     global void execute(Database.BatchableContext bc, List<Worklog__c> scope){
//         update scope;
//     }
    
//     global void finish(Database.BatchableContext bc){
//         // execute any post-processing operations
//     } 
// }