/**
 * @description       : 
 * @author            : §
 * @last modified on  : 01-28-2022
 * @last modified by  : §
**/
import { api, LightningElement, wire } from 'lwc';
import { getRecord, getFieldValue } from 'lightning/uiRecordApi';
import { CloseActionScreenEvent } from 'lightning/actions';
import { NavigationMixin } from 'lightning/navigation';

import INVOICE_ID_FIELD from '@salesforce/schema/InvoiceMilestone__c.Id';
import INVOICE_NAME_FIELD from '@salesforce/schema/InvoiceMilestone__c.Name';
import ACCOUNT_ID_FIELD from '@salesforce/schema/InvoiceMilestone__c.Opportunity__r.AccountId';
import OPPORTUNITY_ID_FIELD from '@salesforce/schema/InvoiceMilestone__c.Opportunity__c';


export default class NewDrafInvoiceQuickAction extends NavigationMixin(LightningElement) {

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
		return [getFieldValue(this.invoiceMilestone.data, OPPORTUNITY_ID_FIELD)];
	}

	get invoiceMilestoneId() {
		//return ["a", "b"];
		return [getFieldValue(this.invoiceMilestone.data, INVOICE_ID_FIELD)];
	}

	handleCloseAction() {
		this.dispatchEvent(new CloseActionScreenEvent());
	}
}