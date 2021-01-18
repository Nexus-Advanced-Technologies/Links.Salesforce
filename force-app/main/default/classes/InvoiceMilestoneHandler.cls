public class InvoiceMilestoneHandler {
    @AuraEnabled
    public static Boolean startSendEmailWorkflow(String InvoiceMilestoneId){
        Boolean success;
        InvoiceMilestoneCustomSetting__c customSetting = [SELECT Id, StatoValueForSendEmail__c, isCurrentRecordUsed__c
                                                          FROM InvoiceMilestoneCustomSetting__c
                                                          WHERE isCurrentRecordUsed__c = true LIMIT 1];
        System.debug(customSetting);
        List<Invoice_Milestone__c> invoiceListToUpdate = new  List<Invoice_Milestone__c>();
    
        List<Invoice_Milestone__c> InvoiceMilestoneList = [SELECT Id, Name, Opportunity__c,startSendEmailWorkflow__c, Data_prevista__c, Stato__c
                                                           FROM Invoice_Milestone__c
                                                           WHERE Id =: InvoiceMilestoneId];
        if(InvoiceMilestoneList.size() > 0) {
            for(Invoice_Milestone__c currentInvoice : InvoiceMilestoneList) {
                System.debug(currentInvoice);
                if(currentInvoice.Stato__c == customSetting.StatoValueForSendEmail__c) {
                    currentInvoice.startSendEmailWorkflow__c = true;
                    invoiceListToUpdate.add(currentInvoice);
                }
            }
            try{
                Update invoiceListToUpdate;
                success = true;
                System.debug('update con successo');
            }catch (Exception ex) {
                success = false;
                System.debug('sono scoppiato');
                System.debug(ex.getMessage());
                System.debug(ex.getStackTraceString());
            }
        }
        return success;
    }
    }