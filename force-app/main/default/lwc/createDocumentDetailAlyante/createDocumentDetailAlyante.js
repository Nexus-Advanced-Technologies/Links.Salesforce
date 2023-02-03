/**
 * @description       : 
 * @author            : 
 * @last modified on  : 27/01/2023
 * @last modified by  : ¤ → alessio.marra@nexusat.it
**/
import { api, LightningElement, wire } from 'lwc';
import { getObjectInfo } from 'lightning/uiObjectInfoApi';
import { NavigationMixin } from 'lightning/navigation';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import getRecordDefaultValues from '@salesforce/apex/createDocumentDetailAlyanteController.getRecordDefaultValues';
import getRecordTypesAvailable from '@salesforce/apex/createDocumentDetailAlyanteController.getRecordTypesAvailable';
import { label } from './utils';
import { getDataConnectorSourceObjectDataPreviewWithFields } from 'lightning/analyticsWaveApi';

const DEBOUNCE_INTERVAL = 300;
const OBJ_NAME = 'DocumentDetailAlyante__c';
const INITIALIZE_LAYOUT = {};

export default class NavToNewRecordWithDefaults extends NavigationMixin(LightningElement) {
	@api documentId;
	@api recordTypeId;
	recordId;
	objectApiName = OBJ_NAME;
	objectInfo;

	layout = INITIALIZE_LAYOUT;
	alreadyRenderedDefaultValue = false;
	recordTypeChoiceContext={};

	label = label;

	projectValue;
	recordTypesAvailable;
    // formVisible = false;
    timerId;

	@wire(getObjectInfo, { objectApiName: '$objectApiName',})
	wiredGetObjectInfo({error, data}) {
		console.debug('wiredGetObjectInfo');
		if(data) {
			this.objectInfo = data;
		}
		if(error) {
			console.error(error);
		}
	};

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
	};

	@wire(getRecordTypesAvailable, {  })
	wiredGetRecordTypesAvailable({error, data}) {
		console.debug('wiredGetRecordTypesAvailable');
		if(data) {
			this.recordTypesAvailable = data;
		}
		if(error) {
			console.error(error);
		}
	};

	renderedCallback() {
		console.debug('renderedCallback()');
		if (!this.alreadyRenderedDefaultValue) {
			this.renderingDefaultValue();
			this.alreadyRenderedDefaultValue = true;
		}
	}

	handleNextChoiceRecordType(evt) {
        console.log('test');
		console.debug('handleNextChoiceRecordType() => ',JSON.parse(JSON.stringify(evt.detail)));
        console.log(this.recordTypeChoiceContext);
		const inputs = this.template.querySelectorAll('[data-id="recordType"]');
		inputs.forEach(x => x.reportValidity());
        this.recordTypeId = this.recordTypeChoiceContext['recordType'];
        if(this.projectValue == null) {
            this.dispatchEvent(new ShowToastEvent({
                title: this.label.projectWarning.title,
                variant: 'warning',
                message: this.label.projectWarning.message
            })); 
        }
		// var allInputsIsValid = inputs.reduce((validSoFar, input) => {
		// 	return validSoFar && input.checkValidity();
		// }, true);

		// console.log('allInputsIsValid : ',allInputsIsValid);

		// if (!allInputsIsValid) {
		// 	return;
		// }
        

		// this.recordTypeId = this.recordTypeChoiceContext['recordType'];
		// console.log('OUTPUT : ',JSON.parse(JSON.stringify(this.recordTypeChoiceContext)));
		// console.log('OUTPUT : ',this.recordTypeId);
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

		this.objectInfo = evt.detail.objectInfos[OBJ_NAME];
		this.setLabelHeader(evt.detail.record.recordTypeInfo?.name);
		// this.label.header = `${this.label.new} ${evt.detail.objectInfos[OBJ_NAME].label}: ${evt.detail.record.recordTypeInfo?.name}`;
	}

	handleInputChange(evt) {
        clearTimeout(this.timerId);
		console.debug('handleInputChange() => ',JSON.parse(JSON.stringify(evt.detail)));
		const target = evt.target;
        this.timerId = setTimeout(() => {
            try {
                const field = target.dataset.id;
                var context = target.dataset.context;
                var value = target.value;
                console.debug('[change]', context, '|', field, '=>', value);
                console.log(JSON.parse(JSON.stringify(evt.detail.value)));
                if (context == 'recordTypeChoice') {
                    this.recordTypeChoiceContext[field] = JSON.parse(JSON.stringify(evt.detail.value));
                    // if ((this.recordTypeChoiceContext || {}).hasOwnProperty(field)) {
                    // 	this.recordTypeChoiceContext[field] = value;
                    // } else {
                    // 	this.recordTypeChoiceContext = Object.assign({[field]: value}, this.recordTypeChoiceContext);
                    // }
                    console.debug('[update recordTypeChoiceContext]', JSON.parse(JSON.stringify(this.recordTypeChoiceContext)));
                }

            } catch (error) {
                console.error(error);
            }
        }, DEBOUNCE_INTERVAL);
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
        console.log('Values -> ' + this.recordTypeChoiceContext);
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
			title: this.label.genericErrorOnSave.title,
			variant: 'error',
			message: this.label.genericErrorOnSave.message
		}));
	}

	get formVisible() {
		return this.recordTypeId != null;
		// return false;
	}

	get layoutIsNotReady() {
		return (Object.keys(this.layout).length === 0);
	}

	get toChoiceRecordType() {
		if (this.objectInfo && this.recordTypeId == null) {
			this.setLabelHeader();
		}
		return this.recordTypeId == null && this.objectInfo != null && this.recordTypesAvailable != null;
		// return false;
	}

	get recordTypeOptions() {
		var options = [];
		if(this.objectInfo.recordTypeInfos) {
			console.debug('recordTypeInfos: ', JSON.parse(JSON.stringify(this.objectInfo.recordTypeInfos)));
			var recordTypeInfos = this.objectInfo.recordTypeInfos;
			for(let recordType in recordTypeInfos) {
				if(recordTypeInfos.hasOwnProperty(recordType)) {
					options.push({ label: recordTypeInfos[recordType].name, value: recordTypeInfos[recordType].recordTypeId });
				}
			}
			options = options.filter(x => this.recordTypesAvailable.includes(x.value));
		}
		return options;
	}

	// timerId;
	// debounce(fn, wait) {
	// 	clearTimeout(this.timerId);
	// 	this.timerId = setTimeout(fn, wait);
	// }

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
		//NOTE - è necessario per sbiancare i valori nel successivo run
        this.recordTypeId = null;
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
						// field.disabled = true;
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

	setLabelHeader(recordType) {
        console.log('set label header -> ' + recordType);
		this.label.header = `${this.label.new} ${this.objectInfo.label}`;
		if (recordType) {
			this.label.header += `: ${recordType}`;
		}
	}
}