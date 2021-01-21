/*
 * LastModification
 * @author	¤
 * @date	16/11/2020
 * @see		CreateProjectStatusTest.apxc
 * @description
 *      Nel metodo createProjectStatus(Opportunity opp), i campi ReferenceNumber__c e Account__c
 *      verranno allineati con corrispettivi campi presenti nell'opportunity padre
 */
public class CreateProjectStatus {
    private static Map<Id, Quote> quoteMap = New Map<Id, Quote>();
    //Called from Proces Builder
    @InvocableMethod
    public static void createProjectStatusInvocable(List<Id> listOppIds){
        List<Project_Status__c> listProjectStatus = New List<Project_Status__c>();
        List<Opportunity> oppList = [SELECT Id, Name, SyncedQuoteId, Delivery_Project_Manager__c, Reference_Number__c, AccountId
                                    FROM Opportunity
                                    WHERE Id In : listOppIds];

        Map<Id, Opportunity> oppMap = New Map<Id, Opportunity>(oppList);
        quoteMap = New Map<Id, Quote>([SELECT Id, Status, Budget_gg__c FROM Quote WHERE Id in : getQuoteIdList(oppList)] );

        for(Opportunity opp : oppMap.values()){            
            //Check SyncedQuoteId != ''
            System.debug('Id +'+ opp.SyncedQuoteId);
            if(opp.SyncedQuoteId != null){
                if(quoteMap.get(opp.SyncedQuoteId).Status == 'Accepted'){
                    //call method that create project status
                    Project_Status__c ps = createProjectStatus(opp);
                    listProjectStatus.add(ps);
                }
            }
        }
        if(!listProjectStatus.isEmpty()){
            System.debug(listProjectStatus);
            insert listProjectStatus;
        }
    }
    //Create Project Status
    public static Project_Status__c createProjectStatus(Opportunity opp){
        //get the Opportunity Name without NX-0000
        //String psName = '';
        //psName = opp.Name.substring(9);

        Project_Status__c newProjectStatus = New Project_Status__c();
        //newProjectStatus.Name = 'Project - ' + psName;
        newProjectStatus.Name = 'Project - ' + opp.Name;
        newProjectStatus.Pm__c = opp.Delivery_Project_Manager__c;
        newProjectStatus.Opportunity__c = opp.Id;
        newProjectStatus.Budget_gg__c = quoteMap.get(opp.SyncedQuoteId).Budget_gg__c;
        newProjectStatus.ReferenceNumber__c = opp.Reference_Number__c;
        newProjectStatus.Account__c = opp.AccountId;

        return newProjectStatus;
    }
    //getQuoteIdList
    public static List<Id> getQuoteIdList(List<Opportunity> oppList){
        List<Id> quoteListId = New List<Id>();

        for(Opportunity opp : oppList){
            quoteListId.add(opp.SyncedQuoteId);
        }
        return quoteListId;
    }
}