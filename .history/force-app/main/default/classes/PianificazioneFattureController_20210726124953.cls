/**
 * @description       : 
 * @author            : 
 * @last modified on  : 04/02/2021
 * @last modified by  : ¤ → alessio.marra@nexusat.it
 * Modifications Log 
 * Ver   Date         Author                         Modification
 * 1.0                                               Initial Version
 * 1.1   25/01/2021   ¤ → alessio.marra@nexusat.it   Review ApiName Nomenclature
 * 1.2   04/02/2021   ¤ → alessio.marra@nexusat.it   BuxFixing RecordType Nomenclature
**/
public without sharing class PianificazioneFattureController {
	//Called from Proces Builder
	@InvocableMethod
	public static void createInvoiceMilestoneInvocable(List<Id> listOppIds){
		for(Id oppId : listOppIds){
			createInvoiceMilestone(oppId);
		}
	}
	@AuraEnabled
	public static Boolean createInvoiceMilestone(Id recordId){
		Boolean check = false;
		try{
			Opportunity opp = [SELECT Id, StageName, Name, RecordType.DeveloperName, CloseDate, PaymentType__c, ReferenceNumber__c,Amount,CustomerOrderNumber__c,Account.Acronym__c,Account.Name
								FROM Opportunity
								WHERE Id =: recordId];
			deleteInvoiceMilestonePresenti(opp);
			//if(opp.StageName == 'Proposal/Price Quote' && opp.Tipo_Pagamento__c != null){
			List<InvoiceMilestone__c> imList;
			if( opp.PaymentType__c != null){                    
				PaymentType__c tp = [SELECT Id, Type__c,Description__c,IsDeleted__c,Name
										FROM PaymentType__c
										WHERE Id =: opp.PaymentType__c];
				List<PaymentTypeDetail__c> tpdList = [SELECT Id, Name,FeeCount__c,RecordTypeId,PaymentType__c,MeasurementUnitMonthly__c,Value__c,FeeValue__c,Rank__c
																FROM PaymentTypeDetail__c
																WHERE PaymentType__c =: opp.PaymentType__c
																ORDER BY Rank__c ASC
															];
				if(tp.Type__c == 'Recursive')
				{
					imList = createInvoiceMilestoneRecursive(opp,tp,tpdList);
				}else if(tp.Type__c == 'One Shot')
				{
					imList = createInvoiceMilestoneOneShot(opp,tpdList);
				}
			}else{
				throw new AuraException('Insert Payment Type');
			}
			if(!imList.isEmpty()){
				insert imList;
				check = true;
			}
		}catch(Exception e){
			throw new AuraException(e);
		}
		return check;
	}
	private static List<InvoiceMilestone__c> createInvoiceMilestoneRecursive(Opportunity opp,PaymentType__c tp,List<PaymentTypeDetail__c> tpdList){
		List<InvoiceMilestone__c> imList = New List<InvoiceMilestone__c>();
		Id rtId = null;
		String imStringName = '';
		Double numCanoni;
				Integer mensilit;
		if(opp.RecordType.DeveloperName == 'Nexus'){
			rtId = getInvoiceRecordType('NexusRecursive');
		}else if(opp.RecordType.DeveloperName == 'Links'){
			rtId = getInvoiceRecordType('LinksRecursive');
		}else{
			throw new AuraException('Record Type Wrong');
		}
		for(PaymentTypeDetail__c tpd1 : tpdList){
			numCanoni = tpd1.FeeCount__c;
			mensilit = Integer.valueOf(tpd1.MeasurementUnitMonthly__c);
			for(Integer i = 0; i< numCanoni; i++){
				for(PaymentTypeDetail__c tpd2 : tpdList){
					Date oppDate = opp.CloseDate;
					String monthName = getMonthName(oppDate.addMonths(mensilit*i).month());
					String yearName = String.valueof(oppDate.addMonths(mensilit*i).year());
					InvoiceMilestone__c im = New InvoiceMilestone__c(
						Opportunity__c  = opp.Id,
						RecordTypeId = rtId,
						ExpectedDate__c = oppDate.addMonths(mensilit*i)
					);
					
					if(opp.Account.Acronym__c != null){
						imStringName = String.valueOf(opp.ReferenceNumber__c)+' - '+ ' '+ opp.Account.Acronym__c+' - '+tp.Name +' - '+monthName+' '+yearName;
					}else{
						imStringName = String.valueOf(opp.ReferenceNumber__c)+' - '+ ' '+opp.Account.Name.left(3)+' - '+tp.Name +' - '+monthName+' '+yearName;
					}
					im.Name = imStringName;
					im.Amount__c = opp.Amount / tpd2.FeeCount__c;
					im.Description__c = 'Servizio a Canone - '+opp.Name ;
					im.CustomerOrderNumber__c = opp.CustomerOrderNumber__c;
					im.Year__c = yearName;
					imList.add(im);		
				}
			}
		}
		return imList;
	}
	private static List<InvoiceMilestone__c> createInvoiceMilestoneOneShot(Opportunity opp,List<PaymentTypeDetail__c> tpdList){
		List<InvoiceMilestone__c> imList = New List<InvoiceMilestone__c>();
		Id rtId = null;
		if(opp.RecordType.DeveloperName == 'Nexus'){
			rtId = getInvoiceRecordType('NexusOneShot');
			}
		else if(opp.RecordType.DeveloperName  == 'Links'){
			rtId = getInvoiceRecordType('LinksOneShot');
		}else{
			throw new AuraException('Record Type Whrong');
		}
		for(PaymentTypeDetail__c tpd : tpdList){
			InvoiceMilestone__c im = new InvoiceMilestone__c(
				Name = getInvoiceName(opp,tpd.Name),
				Rank__c = tpd.Rank__c,
				Opportunity__c = opp.Id,
				RecordTypeId = rtId,
				ExpectedDate__c = Date.today(),
				Year__c = String.valueof(Date.today().year()),
				Amount__c = (opp.Amount * tpd.Value__c) / 100,
				Description__c = tpd.Name +' - '+ opp.Name,
				CustomerOrderNumber__c = opp.CustomerOrderNumber__c
			);
			imList.add(im);	
		}
		return imList;
	}

	//Delete Invoice Milestone
	@AuraEnabled
	public static void deleteInvoiceMilestonePresenti(Opportunity opp){

		List<InvoiceMilestone__c> invoiceMilestoneToDelete = [SELECT Id, Opportunity__c FROM InvoiceMilestone__c WHERE Opportunity__c =: opp.Id];

		if(!invoiceMilestoneToDelete.isEmpty()){
			delete invoiceMilestoneToDelete;
		}
	}
	private static String getInvoiceName(Opportunity opp,String End){
		String imStringName;
		if(opp.Account.Acronym__c != null ){
			imStringName = String.valueOf(opp.ReferenceNumber__c)+' - '+ opp.Account.Acronym__c+' - '+ End;
		}else{
			imStringName = String.valueOf(opp.ReferenceNumber__c)+' - '+ opp.Account.Name.left(3)+' - '+ End;
		}
		return imStringName;
	}
	private static String getMonthName(Integer monthNumber){
		String monthName = '';
		if(monthNumber == 1){
			monthName = 'January';
		}else if(monthNumber == 2){
			monthName = 'February';
		}else if(monthNumber == 3){
			monthName = 'March';
		}else if(monthNumber == 4){
			monthName = 'April';
		}else if(monthNumber == 5){
			monthName = 'May';
		}else if(monthNumber == 6){
			monthName = 'June';
		}else if(monthNumber == 7){
			monthName = 'July';
		}else if(monthNumber == 8){
			monthName = 'August';
		}else if(monthNumber == 9){
			monthName = 'September';
		}else if(monthNumber == 10){
			monthName = 'October';
		}else if(monthNumber == 11){
			monthName = 'November';
		}else if(monthNumber == 12){
			monthName = 'December';
		}else{
			throw new  AuraException('Month Number Wrong');
		}
		return monthName;
	}
	private static Id getInvoiceRecordType(String developerName){
		return [SELECT Id, DeveloperName 
		FROM RecordType 
		WHERE DeveloperName = :developerName AND SObjectType = 'InvoiceMilestone__c'].Id;
	}
}