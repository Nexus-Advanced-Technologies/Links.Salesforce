/**
 * @description       : 
 * @author            : 
 * @last modified on  : 25/01/2021
 * @last modified by  : ¤ → alessio.marra@nexusat.it
 * Modifications Log 
 * Ver   Date         Author                         Modification
 * 1.0                                               Initial Version
 * 1.1   25/01/2021   ¤ → alessio.marra@nexusat.it   Review ApiName Nomenclature
**/
public class SendEmailClass {
	
	//CSS for mail formatting
	public static String tableStyle = 'margin-bottom : 10px;';
	public static String thStyle = 'text-align:left; white-space: nowrap; border-bottom:1px solid #FE7D19; color:#000;color:#fe7d19;font-weight:bold;padding:0px 8px;font-size:0.8em';
	public static String thStyle2 = 'margin-top:30px; text-align:left; white-space: nowrap; border-bottom:1px solid #FE7D19; color:#000;color:#fe7d19;font-weight:bold;padding:0px 8px;font-size:0.8em';
	public static String valueStyleNew = 'min-height:16px;padding:8px;background:#eee';
	public static String valueStyleNew2 = 'min-height:16px;padding:8px;background:#fff';
	
	//Set Email Body
	public static void sendEmailVerifica(List<String> accountToUpdate, String subject, String body){
		
		//Get Email Address to send from Custom Setting
		FattureInCloudSettings__c fattSettings = FattureInCloudSettings__c.getOrgDefaults();
		String emailRef = fattSettings.AdministrationEmail__c;
		List<String> destinationAddress = New List<String>();
		destinationAddress.add(emailRef);
		
		//Create subject and body for email
		String bodyTest = body +': <ul>';
		
		for(String s : accountToUpdate){
			bodyTest += '<li>' + s + '</li>';
		}
		bodyTest += '</ul>';
		
		//Send Email Message       
		Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
		mail.setToAddresses(destinationAddress);
		mail.setSubject(subject);
		mail.setHtmlBody(bodyTest);
		Messaging.SendEmailResult[] result = Messaging.sendEmail(new Messaging.SingleEmailMessage[]{mail});
	}
	
	//Get Opportunity Field 
	@AuraEnabled
	public static Opportunity getOppField(Id recordId){
		system.debug('Ø-recordId ' + recordId);
		Opportunity opp = [SELECT Id, Name, Amount,StageName,CloseDate
						   FROM Opportunity
						   WHERE Id =: recordId];  
		return opp;
	}
	//Called from Proces Builder
	@InvocableMethod
	public static void sendEmailInvocable(List<Id> listOppIds){
		
		for(Id oppId : listOppIds){
			sendEmail(oppId);
		}
	}
	//Send Email
	@AuraEnabled
	public static Boolean sendEmail(Id recordId){
		system.debug('Ø-recordId ' + recordId);
		Boolean check = false;
		
		try{
			String head = '';
			String body = '';
			String headQLI = '';
			String bodyQLI = '';
			String oppReferenceNumber= '';
			String oppTable = '';
			
			//Get User Current User Email
			// User currentUser = [select id, title, firstname, lastname, email, phone, mobilephone, fax, street, city, state, postalcode, country
			//                     FROM User WHERE id =: UserInfo.getUserId()];
			// String emailRef = currentUser.Email ;
			
			//Create List of Destination Address
			List<String> DestinationAddress = New List<String>();
			
			//Get Email Address From Custom Setting
			SetAddressSetting__c address = SetAddressSetting__c.getOrgDefaults();
			DestinationAddress.add(address.EmailCDG__c);
			DestinationAddress.add(address.OtherAddress__c);
			System.debug('Ø-DestinationAddress '+DestinationAddress);
			
			//Select Opportunity and Contact Field
			Opportunity opp = [SELECT Id,AccountId, Name, ReferenceNumber__c, StageName, SyncedQuoteId
							   FROM Opportunity 
							   WHERE Id =: recordId];

			List<Messaging.SingleEmailMessage> emailNew = New List<Messaging.SingleEmailMessage>();
			Messaging.SingleEmailMessage email = New Messaging.SingleEmailMessage();
			email.setToAddresses(DestinationAddress);
			email.setSubject('Opportunità '+opp.Name +' in Stato '+opp.StageName);
			email.setWhatId(recordId);            
			email.setTreatTargetObjectAsRecipient(false);
			
			//Get All Id of Content Document Link of Opportunity and create a final list of Id of Content Document to Send
			List<ContentDocumentLink> conDocLinkList = [SELECT Id, LinkedEntityId, ContentDocumentId, SystemModstamp 
														FROM ContentDocumentLink 
														where LinkedEntityId =: recordId
													   ];

			List<Id> contentdocumentId = New List<Id>();
			List<Id> contentdocumentIdToSend = New List<Id>();
			oppReferenceNumber = opp.ReferenceNumber__c;

			for(ContentDocumentLink cdl : conDocLinkList){
				contentdocumentId.add(cdl.ContentDocumentId);
			}
			
			List<ContentDocument> cdList = [SELECT Id, Title, FileExtension 
											FROM ContentDocument 
											WHERE Id IN :contentdocumentId];

			for(ContentDocument cd : cdList){
				String cdTitle = cd.Title;
				String cdFE = cd.FileExtension;
				if(cdTitle.startsWith(oppReferenceNumber) && (cdFE == 'pdf' || cdFE == 'docx' || cdFE == 'xlsx')){
					System.debug('cycle cdTitle---'+ cdTitle +'   cdfe'+cdFE);
					contentdocumentIdToSend.add(cd.Id);
				}
			}
			List<ContentVersion> cvList = [SELECT Id, IsLatest, ContentDocumentId, Title, FileType, VersionData,FileExtension 
										   FROM ContentVersion 
										   WHERE ContentDocumentId IN :contentdocumentIdToSend ];
			
			List<Messaging.Emailfileattachment> fileAttachments = new List<Messaging.Emailfileattachment>();
			
			for(ContentVersion cv : cvList){
				Messaging.EmailFileAttachment efa = new Messaging.EmailFileAttachment();
				efa.setFileName(cv.Title+'.'+cv.FileExtension);
				efa.setBody(cv.VersionData);
				fileAttachments.add(efa);                
			}
			email.setFileAttachments(fileAttachments);
			body = EmailBody(recordId);
			if(opp.StageName == 'Closed Won'){
				if(opp.SyncedQuoteId != null){
					bodyQLI = emailBodyQli(opp);
					if(bodyQLI.length()>0){
						Quote q = [SELECT Id, Name, OpportunityId,Pricebook2.Name,BudgetDD__c FROM Quote WHERE Id =: opp.SyncedQuoteId];
						//Compose Email's Head 
						headQLI = '<p>Riepilogo Budget: <ul><li>Budget (gg): '+q.BudgetDD__c +';</li><li>PriceBook: '+q.Pricebook2.Name +';</li></ul></p><table cellspacing="0" cellpadding="0" border="0" style="'+tableStyle+'"><thead><th style="'+thStyle2+'">Risorsa</th><th style="'+thStyle2+'">Quantità</th><th style="'+thStyle2+'">Costo Totale Interno</th><th style="'+thStyle2+'">Prezzo di Vendita Totale</th></thead><tbody>';   
					}
				}
			}
			if(body.length()>0){
				//Compose Email's Head 
				head = '<table cellspacing="0" cellpadding="0" border="0" style="'+tableStyle+'"><thead><th style="'+thStyle+'">Invoice Milestone Name </th><th style="'+thStyle+'">Descrizione</th><th style="'+thStyle+'">Stato</th><th style="'+thStyle+'">Imponibile</th><th style="'+thStyle+'">Data Prevista</th></thead><tbody>';   
			}
			
			oppTable = OppBody(recordId);
			email.setHtmlBody(oppTable + head + body + headQLI +bodyQLI);
			emailNew.add(email);
			Messaging.SendEmailResult [] r = Messaging.sendEmail(emailNew,false); 
			System.debug('Ø-r '+r);
			check = true;
			
		}catch (Exception ex){
			System.Debug('ex*********'+ex);
			throw new AuraHandledException('Inserire almeno un allegato. '+ex.getMessage());
		}
		return check;
	}
	//Send Email Fulvio
	@AuraEnabled
	public static Boolean sendEmailAllStates(Id recordId, List<String> DestinationAddress){
		system.debug('Ø-recordId ' + recordId);
		Boolean check = false;
		
		try{
			String head = '';
			String body = '';
			String headQLI = '';
			String bodyQLI = '';
			String oppReferenceNumber= '';
			String oppTable = '';
						
			//Select Opportunity and Contact Field
			Opportunity opp = [SELECT Id,AccountId, Name, ReferenceNumber__c, StageName, SyncedQuoteId
							   FROM Opportunity 
							   WHERE Id =: recordId];

			List<Messaging.SingleEmailMessage> emailNew = New List<Messaging.SingleEmailMessage>();
			Messaging.SingleEmailMessage email = New Messaging.SingleEmailMessage();
			email.setToAddresses(DestinationAddress);
			email.setSubject('Opportunità '+opp.Name +' in Stato '+opp.StageName);
			email.setWhatId(recordId);            
			email.setTreatTargetObjectAsRecipient(false);
			
			//Get All Id of Content Document Link of Opportunity and create a final list of Id of Content Document to Send
			List<ContentDocumentLink> conDocLinkList = [SELECT Id, LinkedEntityId, ContentDocumentId, SystemModstamp 
														FROM ContentDocumentLink 
														where LinkedEntityId =: recordId
													   ];

			List<Id> contentdocumentId = New List<Id>();
			List<Id> contentdocumentIdToSend = New List<Id>();
			oppReferenceNumber = opp.ReferenceNumber__c;

			for(ContentDocumentLink cdl : conDocLinkList){
				contentdocumentId.add(cdl.ContentDocumentId);
			}
			
			List<ContentDocument> cdList = [SELECT Id, Title, FileExtension 
											FROM ContentDocument 
											WHERE Id IN :contentdocumentId];

			for(ContentDocument cd : cdList){
				String cdTitle = cd.Title;
				String cdFE = cd.FileExtension;
				if(cdTitle.startsWith(oppReferenceNumber) && (cdFE == 'pdf' || cdFE == 'docx' || cdFE == 'xlsx')){
					System.debug('cycle cdTitle---'+ cdTitle +'   cdfe'+cdFE);
					contentdocumentIdToSend.add(cd.Id);
				}
			}
			List<ContentVersion> cvList = [SELECT Id, IsLatest, ContentDocumentId, Title, FileType, VersionData,FileExtension 
										   FROM ContentVersion 
										   WHERE ContentDocumentId IN :contentdocumentIdToSend ];
			
			List<Messaging.Emailfileattachment> fileAttachments = new List<Messaging.Emailfileattachment>();
			
			for(ContentVersion cv : cvList){
				Messaging.EmailFileAttachment efa = new Messaging.EmailFileAttachment();
				efa.setFileName(cv.Title+'.'+cv.FileExtension);
				efa.setBody(cv.VersionData);
				fileAttachments.add(efa);                
			}
			email.setFileAttachments(fileAttachments);
			body = EmailBody(recordId);
			if(opp.StageName == 'Closed Won'){
				if(opp.SyncedQuoteId != null){
					bodyQLI = emailBodyQli(opp);
					if(bodyQLI.length()>0){
						Quote q = [SELECT Id, Name, OpportunityId,Pricebook2.Name,BudgetDD__c FROM Quote WHERE Id =: opp.SyncedQuoteId];
						//Compose Email's Head 
						headQLI = '<p>Riepilogo Budget: <ul><li>Budget (gg): '+q.BudgetDD__c +';</li><li>PriceBook: '+q.Pricebook2.Name +';</li></ul></p><table cellspacing="0" cellpadding="0" border="0" style="'+tableStyle+'"><thead><th style="'+thStyle2+'">Risorsa</th><th style="'+thStyle2+'">Quantità</th><th style="'+thStyle2+'">Costo Totale Interno</th><th style="'+thStyle2+'">Prezzo di Vendita Totale</th></thead><tbody>';   
					}
				}
			}
			if(body.length()>0){
				//Compose Email's Head 
				head = '<table cellspacing="0" cellpadding="0" border="0" style="'+tableStyle+'"><thead><th style="'+thStyle+'">Invoice Milestone Name </th><th style="'+thStyle+'">Descrizione</th><th style="'+thStyle+'">Stato</th><th style="'+thStyle+'">Imponibile</th><th style="'+thStyle+'">Data Prevista</th></thead><tbody>';   
			}
			
			oppTable = OppBody(recordId);
			email.setHtmlBody(oppTable + head + body + headQLI +bodyQLI);
			emailNew.add(email);
			Messaging.SendEmailResult [] r = Messaging.sendEmail(emailNew,false); 
			System.debug('Ø-r '+r);
			check = true;
			
		}catch (Exception ex){
			System.Debug('ex*********'+ex);
			throw new AuraHandledException('Inserire almeno un allegato. '+ex.getMessage());
		}
		return check;
	}
	
	//Set Milestone Information
	@AuraEnabled
	public static String EmailBody(Id recordId){
		String body = '';
		String imAccountName = '';
		Double imAmmontare = 0;
		String imDescription = '';
		Integer i = 1;
		
		List<InvoiceMilestone__c> imList = [SELECT Id,Name,AccountName__c,Amount__c,Description__c,ExpectedDate__c,Opportunity__r.Name,Stage__c,InvoiceExternalCode__c
											 FROM InvoiceMilestone__c
											 WHERE Opportunity__c =:recordId];
		if(!imList.isEmpty()){
			for(InvoiceMilestone__c im : imList){
				if(math.mod(i, 2) == 0 ){
					body += '<tr class="even"><td><div style="'+valueStyleNew +'">'+im.Name+'</div></td><td><div style="'+valueStyleNew +'">'+im.Description__c+'</div></td><td><div style="'+valueStyleNew +'">'+im.Stage__c+'</div></td><td><div style="'+valueStyleNew +'">€ '+im.Amount__c+'</div></td><td><div style="'+valueStyleNew +'">'+im.ExpectedDate__c.format()+'</div></td></tr>';
				}else{                
					body += '<tr class="odd"><td><div style="'+valueStyleNew2 +'">'+im.Name+'</div></td><td><div style="'+valueStyleNew2 +'">'+im.Description__c+'</div></td><td><div style="'+valueStyleNew2 +'">'+im.Stage__c+'</div></td><td><div style="'+valueStyleNew2 +'">€ '+im.Amount__c+'</div></td><td><div style="'+valueStyleNew2 +'">'+im.ExpectedDate__c.format()+'</div></td></tr>';
				}
				i++;
			}
			body += '</tbody></table>';
		}
		return body;
	}

	public static String emailBodyQli(Opportunity opp){
		String body = '';
		Integer i = 1;
		Quote q = [SELECT Id, Name, OpportunityId,Pricebook2.Name,BudgetDD__c FROM Quote WHERE Id =: opp.SyncedQuoteId];
		
		List<QuoteLineItem> qliList = [SELECT Id, Product2.Name, Quantity, UnitPrice, TotalPrice,TotalInternalCost__c FROM QuoteLineItem WHERE QuoteId =: q.Id];

		  if(!qliList.isEmpty()){
			for(QuoteLineItem qli : qliList){
				if(math.mod(i, 2) == 0 ){
					body += '<tr class="even"><td><div style="'+valueStyleNew +'">'+qli.Product2.Name+'</div></td><td><div style="'+valueStyleNew +'">'+qli.Quantity+'</div></td><td><div style="'+valueStyleNew +'">€ '+qli.TotalInternalCost__c+'</div></td><td><div style="'+valueStyleNew +'">€ '+qli.TotalPrice+'</div></td></tr>';
				}else{                
					body += '<tr class="odd"><td><div style="'+valueStyleNew2 +'">'+qli.Product2.Name+'</div></td><td><div style="'+valueStyleNew2 +'">'+qli.Quantity+'</div></td><td><div style="'+valueStyleNew2 +'">€ '+qli.TotalInternalCost__c+'</div></td><td><div style="'+valueStyleNew2 +'">€ '+qli.TotalPrice+'</div></td></tr>';
				}
				i++;
			}
			body += '</tbody></table>';
		}
		return body;
	}
	
	//Set Opportunity Information
	@AuraEnabled
	public static String OppBody(Id recordId){
		String text = '';
		String serType = '';
		String delMan = '';
		String tipPaga = '';
		String oppfatt = '';
		String tp = '';
		String recOwn = '';
		Double traPro = 0.0;
		Double grosMar = 0.0;

		Opportunity opp = [SELECT Id, Account.Name, Name, Amount, StageName, CloseDate, ReferenceNumber__c, ServiceType__c,
							DeliveryProjectManager__r.Name, PaymentType__r.Name, Invoicing__c, Type, BusinessManager__c,TradingProfit__c, GrossMargin__c, BillingOpportunity__r.Name
						   FROM Opportunity 
						   WHERE Id =: recordId];
		String dataPrevista = opp.CloseDate.format();
		serType = (opp.ServiceType__c <> null)? opp.ServiceType__c :'N.A.';
		delMan = (opp.DeliveryProjectManager__r <> null)? opp.DeliveryProjectManager__r.Name :'N.A.';
		tipPaga = (opp.PaymentType__r.Name <> null)? opp.PaymentType__r.Name :'N.A.';
		oppfatt = (opp.BillingOpportunity__r.Name <> null)? opp.BillingOpportunity__r.Name :'N.A.';
		tp = (opp.Type <> null)? opp.Type :'N.A.';
		recOwn = (opp.BusinessManager__c <> null)? opp.BusinessManager__c :'N.A.';
		traPro = (opp.TradingProfit__c <> null)? opp.TradingProfit__c : 0.0;
		grosMar = (opp.GrossMargin__c <> null)? opp.GrossMargin__c : 0.0;

		text = '<div><p>Gentile Amministrazione NexusAT,</p> <p> l\'Opportunità N° '+ opp.Name+' è in Stato di '+opp.StageName;
		text += '<p>Di seguito le informazioni principali: </p><ul><li>Nome Account : '+opp.Account.Name +'</li><li>Imponibile: € '+opp.Amount +'</li><li>Stato: '+opp.StageName +'</li><li>Data Prevista: '+ dataPrevista +'</li>';
		text += '<li>Reference Number: '+opp.ReferenceNumber__c +'</li>';
		text += '<li>Service Type: '+serType +'</li>';
		text += '<li>Delivery Project Manager: '+ delMan+'</li>';
		text += '<li>Tipo Pagamento: '+ tipPaga +'</li>';
		text += '<li>Account Jira di Riferimento: '+oppfatt +'</li>';
		text += '<li>Type: '+ tp+'</li>';
		text += '<li>Business Manager: '+recOwn +'</li>';
		text += '<li>Trading Profit: € '+traPro +'</li>';
		text += '<li>Gross Margin: '+ grosMar +' %</li>';
		text += '</ul><p>Il piano di fatturazione è:</p></div>';
		return text;
	}
}