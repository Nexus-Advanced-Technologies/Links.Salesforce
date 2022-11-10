/**
 * @description       : 
 * @author            : §
 * @group             : 
 * @last modified on  : 11/10/2022
 * @last modified by  : manolo.giannotta@nexusat.it
**/
@isTest
public class OnDocumentAlyanteTest {
	private static final Id PRE_INVOICE_RT = getDocumentRecordTypeIdByDeveloperName('PreInvoice');
	//private static final Id PASSIVE_INVOICE_RT = getDocumentRecordTypeIdByDeveloperName('PassiveInvoice');
	//private static final Id CREDIT_NOTE_RT = getDocumentRecordTypeIdByDeveloperName('CreditNote');
	private static final Id ACTIVE_INVOICE_RT = getDocumentRecordTypeIdByDeveloperName('ActiveInvoice');

	@TestSetup static void makeData() {
		User testUser = createUser();
		insert testUser;

		Account testAccount = createAccount('Test Account');
		insert testAccount;

		//DocumentAlyante__c creditNote = createDocumentAlyante('Emitted', testAccount.Id, CREDIT_NOTE_RT);
		//DocumentAlyante__c passiveInvoice = createDocumentAlyante('Emitted', testAccount.Id, PASSIVE_INVOICE_RT);
		DocumentAlyante__c preInvoice = createDocumentAlyante('Draft', testAccount.Id, PRE_INVOICE_RT);

		//insert new List<DocumentAlyante__c> {creditNote, passiveInvoice, preInvoice};
		insert new List<DocumentAlyante__c> {preInvoice};
		//Approval.unlock(creditNote.Id);

		DocumentAlyante__c documentChild = createDocumentAlyante('Draft', testAccount.Id, PRE_INVOICE_RT);
		DocumentAlyante__c documentParent = createDocumentAlyante('Draft', testAccount.Id, PRE_INVOICE_RT);
		insert new List<DocumentAlyante__c> {documentChild,documentParent};
		DocumentRelationAlyante__c relation = new DocumentRelationAlyante__c(
			Child__c = documentChild.Id,
			Parent__c = documentParent.Id
		);
		insert relation;
	}

	@isTest static void documentInsertTest() {
		TriggerUtilities.TriggerSettingDocumentAlyante = createCustomMetadata(true);
		User u = [SELECT Id FROM User WHERE LastName = 'Testing' LIMIT 1];
		Id accountId = [SELECT Id FROM Account LIMIT 1].Id;

		DocumentAlyante__c activeInvoice = createDocumentAlyante('Emitted', accountId, ACTIVE_INVOICE_RT);

		System.runAs(u) {
			Test.startTest();
			insert activeInvoice;
			Test.stopTest();
		}

		System.assert(Approval.isLocked(activeInvoice.Id));
		
	}

	// @isTest static void creditNoteUpdateTest() {
	// 	TriggerUtilities.TriggerSettingDocumentAlyante = createCustomMetadata(true);
	// 	User u = [SELECT Id FROM User WHERE LastName = 'Testing' LIMIT 1];

	// 	DocumentAlyante__c creditNote = [SELECT Id, Status__c FROM DocumentAlyante__c WHERE RecordTypeId = :CREDIT_NOTE_RT LIMIT 1];
	// 	creditNote.Status__c = 'Payed';

	// 	System.assert(!Approval.isLocked(creditNote.Id));

	// 	System.runAs(u) {
	// 		Test.startTest();
	// 		update creditNote;
	// 		Test.stopTest();
	// 	}

	// 	System.assert(Approval.isLocked(creditNote.Id));
	// }

	// @isTest static void passiveInvoiceTest() {
	// 	TriggerUtilities.TriggerSettingDocumentAlyante = createCustomMetadata(true);
	// 	User u = [SELECT Id FROM User WHERE LastName = 'Testing' LIMIT 1];

	// 	DocumentAlyante__c passiveInvoice = [SELECT Id, Status__c FROM DocumentAlyante__c WHERE RecordTypeId = :PASSIVE_INVOICE_RT LIMIT 1];
	// 	passiveInvoice.Status__c = 'Payed';

	// 	System.runAs(u) {
	// 		Test.startTest();
	// 		try {
	// 			update passiveInvoice;
	// 			System.assert(false);
	// 		} catch(Exception e) {
	// 			System.assert(true);
	// 		}
			
	// 		Test.stopTest();
	// 	}
	// }

	
	@isTest static void preInvoiceWithoutDetailsTest() {
		TriggerUtilities.TriggerSettingDocumentAlyante = createCustomMetadata(true);

		DocumentAlyante__c preInvoice = [SELECT Id, Status__c FROM DocumentAlyante__c WHERE RecordTypeId = :PRE_INVOICE_RT LIMIT 1];
		preInvoice.Status__c = 'ToBeEmitted';

		List<AggregateResult> groupedResults = [SELECT count(Id) c FROM DocumentDetailAlyante__c WHERE Document__c = :preInvoice.Id];
		System.assert(groupedResults[0].get('c') == 0);

		Test.startTest();
		try {
			update preInvoice;
			System.assert(false);
		} catch(Exception e) {
			System.assert(true);
		}
		
		Test.stopTest();
	}

	@isTest static void documentDeleteTest() {
		TriggerUtilities.TriggerSettingDocumentAlyante = createCustomMetadata(true);
		DocumentRelationAlyante__c relation = [SELECT Id, Child__c FROM DocumentRelationAlyante__c LIMIT 1];
		DocumentAlyante__c document = [SELECT Id FROM DocumentAlyante__c WHERE Id = :relation.Child__c LIMIT 1]; 
		Test.startTest();
		delete document;
		Test.stopTest();
	}

	private static User createUser() {
		Profile p = [SELECT Id FROM Profile WHERE Name = 'Standard User' LIMIT 1];
		String username = 'testuser@test' + Math.round(Math.random() * 10000) + '.com';

		return new User(
			Alias = 'standt',
			Email = username,
			EmailEncodingKey = 'UTF-8',
			LastName = 'Testing',
			LanguageLocaleKey = 'en_US',
			LocaleSidKey = 'en_US',
			ProfileId = p.Id,
			TimeZoneSidKey = 'America/Los_Angeles',
			UserName = username
		);
	}

	private static Id getDocumentRecordTypeIdByDeveloperName(String rtDeveloperName) {
		return Schema.sObjectType.DocumentAlyante__c.getRecordTypeInfosByDeveloperName().get(rtDeveloperName).getRecordTypeId();
	}

	private static Account createAccount(String name) {
		return new Account(
			Name = name
		);
	}

	private static DocumentAlyante__c createDocumentAlyante(String status, Id accountId, Id rtId) {
		return new DocumentAlyante__c(
			Status__c = status,
			Account__c = accountId,
			RecordTypeId = rtId
		);
	}

	private static List<TriggerSetting__mdt> createCustomMetadata(Boolean status) {
		List<TriggerSetting__mdt> triggerSettingMDT = (List<TriggerSetting__mdt>) Json.deserialize(
			'[' +
				'{' +
					'"DeveloperName": "Links",' +
					'"DocumentAlyanteAfterInsert__c": "' + status + '",' +
					'"DocumentAlyanteAfterUpdate__c": "' + status + '",' +
					'"DocumentAlyanteBeforeUpdate__c": "' + status + '",' +
					'"DocumentAlyanteBeforeDelete__c": "' + status + '"' +
				'}' +
			']'
			,List<TriggerSetting__mdt>.class
		);
		return triggerSettingMDT;
	}
}