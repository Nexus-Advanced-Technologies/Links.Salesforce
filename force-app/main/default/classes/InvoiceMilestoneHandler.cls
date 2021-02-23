public class InvoiceMilestoneHandler {
	@AuraEnabled
	public static Boolean startSendEmailWorkflow(String InvoiceMilestoneId){
		Boolean success;
		InvoiceMilestoneSetting__c customSetting = [SELECT Id, StatoValueForSendEmail__c, IsCurrentRecordUsed__c
														  FROM InvoiceMilestoneSetting__c
														  WHERE IsCurrentRecordUsed__c = true LIMIT 1];
		System.debug(customSetting);
		List<InvoiceMilestone__c> invoiceListToUpdate = new  List<InvoiceMilestone__c>();
	
		List<InvoiceMilestone__c> InvoiceMilestoneList = [SELECT Id, Name, Opportunity__c,StartSendEmailWorkflow__c, ExpectedDate__c, Stage__c
														   FROM InvoiceMilestone__c
														   WHERE Id =: InvoiceMilestoneId];
		if(InvoiceMilestoneList.size() > 0) {
			for(InvoiceMilestone__c currentInvoice : InvoiceMilestoneList) {
				System.debug(currentInvoice);
				if(currentInvoice.Stage__c == customSetting.StatoValueForSendEmail__c) {
					currentInvoice.StartSendEmailWorkflow__c = true;
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