import { LightningElement, api, wire, track } from 'lwc';
import { getRecord, getFieldValue } from 'lightning/uiRecordApi';
import { CloseActionScreenEvent } from 'lightning/actions';
import { NavigationMixin } from 'lightning/navigation';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

import fetchOpportunityId from '@salesforce/apex/CloneDraftInvoiceController.fetchOpportunityId';
import fetchInvoiceMilestoneId from '@salesforce/apex/CloneDraftInvoiceController.fetchInvoiceMilestoneId';
import cloneDocumentDetails from '@salesforce/apex/CloneDraftInvoiceController.cloneDocumentDetails';

import DOCUMENT_OBJ from '@salesforce/schema/DocumentAlyante__c';
import CONTENT_FIELD from '@salesforce/schema/DocumentAlyante__c.Content__c';
import ACCOUNT_ID_FIELD from '@salesforce/schema/DocumentAlyante__c.Account__c';
import DATE_FIELD from '@salesforce/schema/DocumentAlyante__c.Date__c';

export default class CloneDraftInvoiceQuickAction extends NavigationMixin(LightningElement) {
    @api recordId;

    @track showForm = true;
    @track opportunityIds;
    @track milestonesId;
    @track clonedDocumentId;

    @wire(fetchOpportunityId, { recordId: "$recordId" })
    getchOppIds({error, data}) {
        if(data) {
            this.opportunityIds = [...data];
        }
    }
    

    @wire(fetchInvoiceMilestoneId, { recordId: "$recordId"})
    getMilestoneIds({error, data}) {
        if(data) {
            this.milestonesId = [...data];
        }
    }

    @wire(getRecord, { recordId: "$recordId", fields: [CONTENT_FIELD, ACCOUNT_ID_FIELD, DATE_FIELD] })
    documentAlyante;

    get accountId() {
        return getFieldValue(this.documentAlyante.data, ACCOUNT_ID_FIELD);
    }

    get date() {
        return getFieldValue(this.documentAlyante.data, DATE_FIELD);
    }

    get content() {
        return getFieldValue(this.documentAlyante.data, CONTENT_FIELD);
    }

    handleCloneDetails(event) {
        this.clonedDocumentId = event.detail.clonedDocumentId;
        this.showForm = false;
    }

    cloneDetails() {
        cloneDocumentDetails({ recordId: this.recordId, clonedDocumentId: this.clonedDocumentId })
            .then(() => { 
                this.handleCloseAction();
            })
            .catch(err => {
                this.showToast('Error', 'error', err.body.message);
            })
    }

	handleCloseAction() {
		this.dispatchEvent(new CloseActionScreenEvent());
        this.showToast("Success", "success", "Document cloned successfully!");
        this.redirectToClonedDocument();
	}

    redirectToClonedDocument() {
		const config = {
			type: "standard__recordPage",
			attributes: {
				recordId: this.clonedDocumentId,
				objectApiName: DOCUMENT_OBJ.objectApiName,
				actionName: "view",
			}
		};
		this[NavigationMixin.Navigate](config);
    }

    showToast(title, variant, message, messageData = {}) {
		const toastEvt = new ShowToastEvent({
			title: title,
			variant: variant,
			message: message,
			messageData: messageData,
		});

		this.dispatchEvent(toastEvt);
	}
}