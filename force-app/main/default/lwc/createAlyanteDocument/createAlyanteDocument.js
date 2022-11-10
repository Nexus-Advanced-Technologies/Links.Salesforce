/**
 * @description       : 
 * @author            : ¤ → alessio.marra@nexusat.it
 * @last modified on  : 01-28-2022
 * @last modified by  : §
**/
import { api, LightningElement, track, wire } from 'lwc';
import { createRecord, deleteRecord } from 'lightning/uiRecordApi';
import { getObjectInfo } from 'lightning/uiObjectInfoApi';
import { NavigationMixin } from 'lightning/navigation';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import fetchOpportunityOptions from '@salesforce/apex/CreateAlyanteDocumentController.fetchOpportunityOptions';
import fetchMilestoneOptions from '@salesforce/apex/CreateAlyanteDocumentController.fetchMilestoneOptions';

import DOCUMENT_OBJ from '@salesforce/schema/DocumentAlyante__c';
import OPP_DOC_OBJ from '@salesforce/schema/OpportunityDocumentAlyante__c';
import INV_DOC_OBJ from '@salesforce/schema/InvoiceMilestoneDocumentAlyante__c';

export default class CreateAlyanteDocument extends NavigationMixin(LightningElement) {

	@api recordTypeName;
	@api recordTypeId;
	@api status;
	@api content;
	@api accountId;
	@api date;
	@api opportunitiesId;
	@api invoiceMilestonesId;
	@api isClone = false;

	@track opportunityOptions = [];
	@track milestonesOptions = [];
	@track opportunityId;
	@track milestoneId;
	@track isOpportunityDisabled = false;
	@track isMilestoneDisabled = false;

	@wire(getObjectInfo, { objectApiName: DOCUMENT_OBJ })
	handleObjectInfo({error, data}) {
		if(data) {
			const rtis = data.recordTypeInfos;
			this.recordTypeId = Object.keys(rtis).find(rti => rtis[rti].name.toLowerCase() == this.recordTypeName);
		}
	}

	@wire(fetchOpportunityOptions, { opprtunityIds: "$opportunitiesId"})
	handleFetchOpportunityOptions({error, data}) {
		if(data) {
			let options = [];
			data.map(d => {
				options = [...options, { label: d.Name, value: d.Id }]
			});
			this.opportunityOptions = [...options];
			if(this.opportunityOptions.length === 1) {
				this.opportunityId = this.opportunityOptions[0].value;
				this.isOpportunityDisabled = true;
			}
		} else if(error) {
			console.log(error);
		}
	}

	@wire(fetchMilestoneOptions, { milestoneIds: "$invoiceMilestonesId"})
	handleFetchMilestoneOptions({error, data}) {
		if(data) {
			let options = [];
			data.map(d => {
				options = [...options, { label: d.Name, value: d.Id }]
			});
			this.milestonesOptions = [...options];
			if(this.milestonesOptions.length === 1) {
				this.milestoneId = this.milestonesOptions[0].value;
				this.isMilestoneDisabled = true;
			}
		} else if(error) {
			console.log(error);
		}
	}
	
	closeForm(){
		const closeEvt = new CustomEvent("quickactionclose");
		this.dispatchEvent(closeEvt);
	}

	handleFormSubmission(event) {
		const form = this.template.querySelector("lightning-record-edit-form");
		form.submit();
	}

	handleSuccess(event) {
		const documentId = event.detail.id;
		const oppDoc = this.createOpportunityDocument(documentId);
		const invDoc = this.createInvoiceMilestoneDocument(documentId);

		Promise.all([createRecord(oppDoc), createRecord(invDoc)])
			.then(() => {
				if(this.isClone) {
					const cloneEvent = new CustomEvent("cloned", {
						detail: {
							clonedDocumentId: documentId,
						}
					});
					this.dispatchEvent(cloneEvent);
				} else {
					this.closeForm();
					this.showToast("Success", "success", "Document created successfully!");
					this.redirectToDocument(event.detail.id);
				}
			})
			.catch(err => {
				deleteRecord(documentId);
				this.showToast('Error', 'error', err.body.message);
			})
	}

	createOpportunityDocument(documentId) {
		const fields = {};
		fields["DocumentAlyante__c"] = documentId;
		fields["Opportunity__c"] = this.opportunityId;
		
		const record = { apiName: OPP_DOC_OBJ.objectApiName, fields };
		return record;
	}

	createInvoiceMilestoneDocument(documentId) {
		const fields = {};
		fields["DocumentAlyante__c"] = documentId;
		fields["InvoiceMilestone__c"] = this.milestoneId;
		
		const record = { apiName: INV_DOC_OBJ.objectApiName, fields };
		return record;
	}


	redirectToDocument(documentId) {
		const config = {
			type: "standard__recordPage",
			attributes: {
				recordId: documentId,
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

	choiceOpportunityDisplay() {
		var a = !((Array.isArray(this.opportunitiesId) && this.opportunitiesId.length === 1))

		if(!a) this.opportunityId = this.opportunitiesId[0];

		return a;
	}

	get opportunityOptions(){
		return [
			{ label: 'New', value: 'new' },
			{ label: 'In Progress', value: 'inProgress' },
			{ label: 'Finished', value: 'finished' },
		];
	}

	handleOpportunity(event) {
		this.opportunityId = event.detail.value;
	}

	handleMilestone(event) {
		this.milestoneId = event.detail.value;
	}

	choiceInvoiceMilestoneDisplay() {
		var a = !((Array.isArray(this.invoiceMilestonesId) && this.invoiceMilestonesId.length === 1));

		if(!a) this.milestoneId = this.invoiceMilestonesId[0];

		return a;
	}

}