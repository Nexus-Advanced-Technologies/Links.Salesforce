/**
 * @description       : 
 * @author            : alessio.marra@nexusat.it ¤
 * @last modified on  : 22/01/2021
 * @last modified by  : alessio.marra@nexusat.it ¤
 * Modifications Log 
 * Ver   Date         Author                       Modification
 * 1.0   22/01/2021   alessio.marra@nexusat.it ¤   Initial Version
**/
@isTest
public class RicalcoloCostiTest {}

//     private static void insertCustomSettings() {
//         OpportunitySetting__c customSettings = new OpportunitySetting__c();
//         customSettings.FteWhere__c = 'Name = \'Project Test\'';
//         insert customSettings;
//     }
    
// 	private static Id insertAccount(String name) {
//         Account acc = new Account();
//         acc.Name = name;
//         insert acc;
//         return acc.Id;
//     }
    
//     private static Id insertOpportunity(String name, Id accId) {
//         Opportunity opp = new Opportunity();
//         opp.Name = name;
//         opp.accountId = accId;
//         opp.StageName = 'Prospect';
//         opp.CloseDate = Date.today();
//         insert opp;
//         return opp.Id;
//     }
    
//     private static Id insertProjectStatus(String name, Id oppId) {
//         Project_Status__c prj = new Project_Status__c();
//         prj.Name = name;
//         prj.Budget_gg__c = 10000;
//         prj.Data_fine_prevista__c = Date.today()+30;
//         prj.Stima_gg_a_terminare__c = 5;
//         prj.Opportunity__c = oppId;
//         insert prj;
//         return prj.Id;
//     }
        
//     private static Id insertIssue(String jiraId, Id prjId) {
//         Issue__c issue = new Issue__c();
//         issue.JiraId__c = jiraId;
//         issue.Project__c = prjId;
//         insert issue;
//         return issue.Id;
//     }
    
//     private static Id insertWorklog(String idTempo, Id issId) {
//         Worklog__c worklog = new Worklog__c();
//         worklog.IdTempo__c = idTempo;
//         worklog.Issue__c = issId;
//         insert worklog;
//         return worklog.Id;
//     }
    
//     @TestSetup
//     static void makeData(){
//         insertCustomSettings();
//         Id accId = insertAccount('Account Test');
//         Id oppId = insertOpportunity('Opportunity Test', accId);
//         Id prjId = insertProjectStatus('Project Test', oppId);
//         Id issId = insertIssue('JiraId Test', prjId);
//         insertWorklog('IdTempo Test', issId);
//     }
    
//     @isTest
//     static void updateCosti(){
//         Id oppId = [SELECT Id FROM Opportunity LIMIT 1].Id;
//         Test.StartTest();
//         RicalcoloCosti.updateCosti(oppId);
//         Test.StopTest();
//     }
// }