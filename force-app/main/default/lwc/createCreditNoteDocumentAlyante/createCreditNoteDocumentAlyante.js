import { LightningElement, api, wire } from 'lwc';
import { getRecord, getFieldValue } from 'lightning/uiRecordApi';
import DOCUMENT_OBJ from '@salesforce/schema/DocumentAlyante__c';
import CONTENT_FIELD from '@salesforce/schema/DocumentAlyante__c.Content__c';
import ACCOUNT_ID_FIELD from '@salesforce/schema/DocumentAlyante__c.Account__c';
import { CloseActionScreenEvent } from 'lightning/actions';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import getDocumentDetails from '@salesforce/apex/CloneDraftInvoiceController.getDocumentDetails';
// import cloneDocumentDetails from '@salesforce/apex/CloneDraftInvoiceController.cloneDocumentDetails';
export default class CreateCreditNoteDocumentAlyante extends LightningElement {
    @api createDocumentTitle = 'Create credit note Document';
    @api recordId;
    showForm = false;
    documentDetails;
    showRelatedForm = false;
    documentId;
    @wire(getDocumentDetails, { recordId: "$recordId" })
    getDocDetails({error, data}) {
        if(data) {
            console.log('fetch documents')
            this.documentDetails = data.map((record) => {
                return{
                    ...record,
                    ProjectName: record.Project__r.Name,
                    ProjectUrl: '/' + record.Project__c
                }      
            });
            console.log(this.documentDetails);
        }
        if(error) {
            console.log(error);
        }
    }

    @wire(getRecord, { recordId: "$recordId", fields: [CONTENT_FIELD, ACCOUNT_ID_FIELD] })
    documentAlyante;

    get accountId() {
        return getFieldValue(this.documentAlyante.data, ACCOUNT_ID_FIELD);
    }

    get content() {
        return getFieldValue(this.documentAlyante.data, CONTENT_FIELD);
    }

    get date() {
        console.log(new Date().toISOString().split('T')[0]);
        return new Date().toISOString().split('T')[0];
    }

    handleCreateSuccess(event) {
        this.documentId = event.detail.clonedDocumentId;
        this.showForm = false;
        this.showRelatedForm = true;
        // console.log('test');
        // this.showToast("Success", "success", "Document created successfully!")
        // console.log(event.detail.clonedDocumentId);
        // this.dispatchEvent(new CloseActionScreenEvent());
    }

    handleCloseAction() {
        this.dispatchEvent(new CloseActionScreenEvent());
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
    connectedCallback() {
        this.showForm = true;

    }
    detailSelected(event) {
        console.log('tests ', JSON.parse(JSON.stringify(event.detail)));
    }
}