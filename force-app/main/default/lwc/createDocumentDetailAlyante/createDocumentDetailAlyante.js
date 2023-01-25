/**
 * @description       : 
 * @author            : 
 * @last modified on  : 25/01/2023
 * @last modified by  : ¤ → alessio.marra@nexusat.it
**/
import { api, LightningElement, track, wire } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import getRecordDefaultValues from '@salesforce/apex/createDocumentDetailAlyanteController.getRecordDefaultValues';
import { label } from './utils';

const DEBOUNCE_INTERVAL = 300;
const OBJ_NAME = 'DocumentDetailAlyante__c';
const INITIALIZE_LAYOUT = {};

export default class NavToNewRecordWithDefaults extends NavigationMixin(LightningElement) {
	@api documentId;
	@api recordTypeId;
	recordId;
	objectApiName = OBJ_NAME;

	layout = INITIALIZE_LAYOUT;
	formVisible = false;
	alreadyRenderedDefaultValue = false;

	label = label;

	projectValue;

	@wire(getRecordDefaultValues, {documentRecordId: '$documentId'})
	wiredGetRecordDefaultValues({error, data}) {
		console.debug('wiredGetRecordDefaultValues');
		if(data) {
			if(data.Project__c) {
				this.projectValue = data.Project__c;
			}
		}
		if(error) {
			console.error(error);
		}
		this.formVisible = true;
	}

	renderedCallback() {
		console.debug('renderedCallback()');
		if (!this.alreadyRenderedDefaultValue) {
			this.renderingDefaultValue();
			this.alreadyRenderedDefaultValue = true;
		}
	}

	handleLoad(evt) {
		console.debug('handleLoad() => ',JSON.parse(JSON.stringify(evt.detail)));
		//NOTE - con più run in sequenza, il 1° onLoad ha il RT della precedente esecuzione
		if (evt.detail.recordTypeId != this.recordTypeId) {
			this.layout = INITIALIZE_LAYOUT;
		}
		if (this.layoutIsNotReady) {
			this.layout = this.formatLayout(evt.detail.layout);
			this.alreadyRenderedDefaultValue = false;
		}

		this.label.header = `${this.label.new} ${evt.detail.objectInfos[OBJ_NAME].label}: ${evt.detail.record.recordTypeInfo?.name}`;
	}

	handleInputChange(evt) {
		console.debug('handleInputChange() => ',JSON.parse(JSON.stringify(evt.detail)));
		try {
			const target = evt.target;
			this.debounce(function() {
				const fieldApiName = target.dataset.id;
				var value = target.value;
				console.debug('[change]', fieldApiName, '=>', value);
			}, DEBOUNCE_INTERVAL);
		} catch (error) {
			console.error(error);
		}
	}

	handleSubmit(evt) {
		try {
			console.info('handleSubmit() => ',JSON.parse(JSON.stringify(evt.detail)));
			evt.preventDefault();
	
			//NOTE - Custom validation
			const inputFields = this.template.querySelectorAll('lightning-input-field');
			var hasError = false;
			// if (inputFields) {
			// 	inputFields.forEach(field => {
			// 		var value = field.value;
			// 		var errorMessage;
			// 		switch (field.fieldName) {
			// 			case 'Name':
			// 				if (value) {
			// 					errorMessage = 'Name is required';
			// 				}
			// 				break;
			// 			default:
			// 				break;
			// 		}
			// 		if (errorMessage) {
			// 			field.setErrors(JSON.parse(`{"body":{"output":{"fieldErrors":{"${field.fieldName}":[{"message":"${errorMessage}"}]}}}}`));
			// 			hasError = true;
			// 		}
			// 	});
			// }

			if (hasError) {
				return;
			}
			
			const fields = evt.detail.fields;
			console.log('fields: ',JSON.parse(JSON.stringify(fields)));
			// NOTE - Other assignment

			this.template.querySelector("lightning-record-edit-form").submit(fields);
		} catch (error) {
			console.error(error);
		}
	}

	handleSuccess(evt) {
		console.info('handleSuccess() => ',JSON.parse(JSON.stringify(evt.detail)));
		this.recordId = evt.detail.id;
		this.dispatchEvent(new ShowToastEvent({
			title: this.label.recordCreated.title,
			variant: 'success',
			message: this.label.recordCreated.message
		}));
		this.navigateToRecordViewPage(this.documentId);
	}

	handleError(evt) {
		console.error('handleError() => ',JSON.parse(JSON.stringify(evt.detail)));
		this.dispatchEvent(new ShowToastEvent({
			title: this.label.genericError.title,
			variant: 'error',
			message: this.label.genericError.message
		}));
	}

	get layoutIsNotReady() {
		return (Object.keys(this.layout).length === 0)
	}

	timerId;
	debounce(fn, wait) {
		clearTimeout(this.timerId);
		this.timerId = setTimeout(fn, wait);
	}

	goBack() {
		this.navigateToRecordViewPage(this.documentId);
	}

	navigateToRecordViewPage(recordId) {
		this[NavigationMixin.Navigate]({
			type: 'standard__recordPage',
			attributes: {
				recordId: recordId,
				actionName: 'view'
			}
		});
		//NOTE - è necessario sbiancare i valori nel successivo run
		this.alreadyRenderedDefaultValue = false;
	}

	formatLayout(layout) {
		const isModeView = layout.mode == "View";
		const isModeCreate = layout.mode == "Create";
		const sections = layout.sections.map( section => {
			const sectionColumns = section.columns || 1;
			const layoutRows = section.layoutRows.map(layoutRow => {
				const layoutItems = layoutRow.layoutItems.map(layoutItem => {
					var size = Math.round(12/sectionColumns);
					var editable = isModeView ? false : (isModeCreate ? layoutItem.editableForNew : layoutItem.editableForUpdate);
					return {
						...layoutItem,
						size: size,
						editable: editable
					};
				});
				return {
					...layoutRow,
					layoutItems: layoutItems
				};
			});
			return {
				...section,
				layoutRows: layoutRows
			};
		});
		var sectionsWithoutSystemInfo = sections.filter(item => item.heading != 'System Information');
		layout = {
			...layout,
			sections: sectionsWithoutSystemInfo
		};

		console.log('Layout => ',JSON.parse(JSON.stringify(layout)));
		return layout;
	}

	renderingDefaultValue() {
		const fields = this.template.querySelectorAll('lightning-input-field');
		if (fields) {
			fields.forEach(field => {
				switch (field.fieldName) {
					case 'RecordTypeId':
						field.value = this.recordTypeId;
						break;
					case 'Document__c':
						field.value = this.documentId;
						field.disabled = true;
						break;
					case 'Project__c':
						field.value = this.projectValue;
						field.disabled = true;
						break;
					case 'Quantity__c':
						field.value = 1;
						break;
					default:
						field.value = null;
						break;
				}
				console.debug('[default assignment]', field.fieldName, '=>', field.value);
			});
		}
	}
}