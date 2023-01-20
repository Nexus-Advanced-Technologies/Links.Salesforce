/**
 * @description       : 
 * @author            : ¤ → alessio.marra@nexusat.it
 * @last modified on  : 27/01/2022
 * @last modified by  : ¤ → alessio.marra@nexusat.it
**/
import { api, LightningElement, wire } from 'lwc';
import { getRecord, getFieldValue } from 'lightning/uiRecordApi';
import { NavigationMixin } from 'lightning/navigation';

import INVOICE_ID_FIELD from '@salesforce/schema/InvoiceMilestone__c.Id';
import INVOICE_NAME_FIELD from '@salesforce/schema/InvoiceMilestone__c.Name';
import ACCOUNT_ID_FIELD from '@salesforce/schema/InvoiceMilestone__c.Opportunity__r.AccountId';
import OPPORTUNITY_ID_FIELD from '@salesforce/schema/InvoiceMilestone__c.Opportunity__c';


export default class CreateAlyanteDocumentQuickAction extends NavigationMixin(LightningElement) {

	@api recordId;

	@wire(getRecord, { recordId: '$recordId', fields: [INVOICE_NAME_FIELD, ACCOUNT_ID_FIELD, OPPORTUNITY_ID_FIELD, INVOICE_ID_FIELD]})
	invoiceMilestone;

	get content() {
		return getFieldValue(this.invoiceMilestone.data, INVOICE_NAME_FIELD);
	}

	get accountId() {
		return getFieldValue(this.invoiceMilestone.data, ACCOUNT_ID_FIELD);
	}

	get today() {
		return new Date().toISOString();
	}

	get opportunityId() {
		return getFieldValue(this.invoiceMilestone.data, OPPORTUNITY_ID_FIELD);
	}

	get invoiceMilestoneId() {
		return getFieldValue(this.invoiceMilestone.data, INVOICE_ID_FIELD);
	}
}