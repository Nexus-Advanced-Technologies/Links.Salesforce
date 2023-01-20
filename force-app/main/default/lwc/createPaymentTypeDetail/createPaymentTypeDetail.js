/**
 * @description       :
 * @author            : ¤ → alessio.marra@nexusat.it
 * @last modified on  : 03/01/2023
 * @last modified by  : ¤ → alessio.marra@nexusat.it
**/
import { LightningElement, api, wire } from 'lwc';
import { getRecord, getFieldValue } from 'lightning/uiRecordApi';
import { getObjectInfo } from 'lightning/uiObjectInfoApi';
import { NavigationMixin } from 'lightning/navigation';

import getMaxRankPaymentType from '@salesforce/apex/CreatePaymentTypeDetailController.getMaxRankPaymentType';

import l_cancel from '@salesforce/label/c.Cancel';
import l_new from '@salesforce/label/c.New';
import l_save from '@salesforce/label/c.Save';


const DEBOUNCE_INTERVAL = 300;
const DEFAULT_RANK = 0;
const OBJ_NAME = 'PaymentTypeDetail__c';
const PARENT_OBJ_NAME = 'PaymentType__c';
const REGEX_ADDITIONAL_PARAMS = /id=(?<id>\S+)\&/;

// One Shot - https://links--dev.sandbox.lightning.force.com/lightning/o/PaymentTypeDetail__c/new?recordTypeId=01209000000l0oGAAQ&count=1
// Recursive - https://links--dev.sandbox.lightning.force.com/lightning/o/PaymentTypeDetail__c/new?recordTypeId=01209000000l0oHAAQ&count=1
// https://links--dev.sandbox.lightning.force.com/lightning/r/PaymentType__c/a037Y00000WuOXHQA3/view

export default class CreatePaymentTypeDetail extends NavigationMixin(LightningElement) {
	@api recordId;
	@api recordTypeId;
	@api objectApiName;
	@api additionalParams;

	@api paymentTypeId;

	// paymentType;
	// paymentTypeDetailObjInfo;

	rank;
	// paymentTypeLayout = {};
	layout = {};
	label = {
		cancel: l_cancel,
		header: '',
		save: l_save
	}
	
	// @wire(getRecord, { recordId: '$paymentTypeId', fields: [ 'Type__c' ] } )
	// wiredGetRecordPaymentType ({error, data}) {
	// 	if (error) {
	// 		// TODO: Error handling
	// 		console.error(error);
	// 	} else if (data) {
	// 		console.log('wiredGetRecordPaymentType');
	// 		this.paymentType = data;
	// 	}
	// }

	constructor() {
		super();
		if(!this.objectApiName) {
			this.objectApiName = OBJ_NAME;
		}
	}

	connectedCallback() {
		console.log('connectedCallback()');
		if (this.additionalParams) {
			var id = REGEX_ADDITIONAL_PARAMS.exec(this.additionalParams).groups.id;
			if (id) {
				this.paymentTypeId = id;
				console.log('paymentTypeId : ',this.paymentTypeId);
			}
		}
	}

	renderedCallback() {
		console.log('renderedCallback()');
		this.setDefaultValue();
	}

	// handlePaymentTypeLoad(evt) {
	// 	console.log('handlePaymentTypeLoad() => ',JSON.parse(JSON.stringify(evt.detail)));
	// 	this.paymentTypeLayout = this.modifyLayout(this.getEvtLayout(evt));
	// }

	handleLoad(evt) {
		console.log('handleLoad() => ',JSON.parse(JSON.stringify(evt.detail)));
		this.layout = this.modifyLayout(this.getEvtLayout(evt));

		this.label.header = `${l_new} ${evt.detail.objectInfos[OBJ_NAME].label}: ${evt.detail.record.recordTypeInfo?.name}`;
	}

	handleInputChange(evt) {
		console.info('handleInputChange() => ',JSON.parse(JSON.stringify(evt.detail)));
		try {
			const target = evt.target;
			this.debounce(function() {
				const fieldApiName = target.dataset.id;
				var value = target.value;
				console.log('[change]', fieldApiName, '=>', value);

				// FIXME - not working
				// console.log('pre fun: ');
				// this.inputChange(fieldApiName, value);
				// console.log('post fun: ');

			}, DEBOUNCE_INTERVAL);
		} catch (error) {
			console.error(error);
		}
	}

	handleSubmit(evt) {
		try {
			console.info(evt.type, '=>', JSON.parse(JSON.stringify(evt.detail)));

			evt.preventDefault();
			// evt.stopPropagation();
	
			//NOTE - Custom validation
			const inputFields = this.template.querySelectorAll('lightning-input-field');
			var hasError = false;
			if (inputFields) {
				inputFields.forEach(field => {
					var value = field.value;
					var errorMessage;
					switch (field.fieldName) {
						// case 'Name':
						// 	if (value) {
						// 		errorMessage = 'Name is required';
						// 	}
						// 	break;
						default:
							break;
					}
					if (errorMessage) {
						field.setErrors(JSON.parse(`{"body":{"output":{"fieldErrors":{"${field.fieldName}":[{"message":"${errorMessage}"}]}}}}`));
						hasError = true;
					}
				});
			}

			if (hasError) {
				return;
			}
			
			const fields = evt.detail.fields;
			// NOTE - other assignment
			this.template.querySelector("lightning-record-edit-form").submit(fields);
		} catch (error) {
			console.error(error);
		}
	}

	handleSuccess(evt) {
		console.info(evt.type, '=>', JSON.parse(JSON.stringify(evt.detail)));
		this.recordId = evt.detail.id;
		this.redirectTo(this.paymentTypeId, PARENT_OBJ_NAME, 'view');
	}

	handleError(evt) {
		console.info(evt.type, '=>', JSON.parse(JSON.stringify(evt.detail)));
	}

	getEvtLayout(evt) {
		var layout;
		if(evt.detail.layout) {
			layout = evt.detail.layout;
		}
		else {
			layout = evt.detail.layouts;
			layout = layout[Object.keys(layout)[0]];	//.ObjectApiName
			layout = layout[Object.keys(layout)[0]];	//.RecordId
			layout = layout[Object.keys(layout)[0]];	//.LayoutType
			layout = layout[Object.keys(layout)[0]];	//.Mode
		}
		console.log('evt Layout => ',JSON.parse(JSON.stringify(layout)));
		return layout;
	}

	modifyLayout(layout) {
		const isModeView = layout.mode == "View";
		const isModeCreate = layout.mode == "Create";
		const sections = layout.sections.map( section => {
			const sectionColumns = section.columns || 1;
			const layoutRows = section.layoutRows.map(layoutRow => {
				const layoutItems = layoutRow.layoutItems.map(layoutItem => {
					var size = Math.round(12/sectionColumns);
					var editable = isModeView ? false : (isModeCreate ? layoutItem.editableForNew : layoutItem.editableForUpdate);
					if (layoutItem.layoutComponents[0].apiName == PARENT_OBJ_NAME) {
						editable = (this.paymentTypeId == null);
					}
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
		layout = {
			...layout,
			sections: sections
		};
		console.log('Layout => ',JSON.parse(JSON.stringify(layout)));
		return layout;
	}

	timerId;
	debounce(fn, wait) {
		clearTimeout(this.timerId);
		this.timerId = setTimeout(fn, wait);
	}

	inputChange(field, value) {
		switch (field) {
			case PARENT_OBJ_NAME:
				if (this.paymentTypeId != value) {
					this.paymentTypeId = value;
					this.setDefaultValue();		//serve per popolare rank
				}
				break;
			default:
				break;
		}
	}

	setDefaultValue() {
		this.getMaxRankPaymentType();
		const fields = this.template.querySelectorAll('lightning-input-field');
		if (fields) {
			fields.forEach(field => {
				field.value = this.getDefaultValue(field.fieldName)
				console.log('[default assignment]', field.fieldName, '=>', field.value);
			});
		}
	}

	getDefaultValue(field) {
		var value;
		switch (field) {
			case 'Rank__c':
				value = this.rank;
				// NOTE - cercare di far funzionare così
				// value = await getMaxRankPaymentType({ paymentTypeId: this.paymentTypeId });
				break;
			case PARENT_OBJ_NAME:
				value = this.paymentTypeId;
				break;
			case 'RecordTypeId':
				value = this.recordTypeId;
				break;
			default:
				value = null;
				break;
		}
		return value;
	}

	getMaxRankPaymentType() {
		getMaxRankPaymentType({ paymentTypeId: `$paymentTypeId` })
			.then(result => {
				this.rank = result +1;
			})
			.catch(error => {
				console.error(error);
				this.rank = DEFAULT_RANK;
			});
	}

	redirectTo(recordId, objectApiName, actionName) {
		const config = {
			type: "standard__recordPage",
			attributes: {
				recordId: recordId,
				objectApiName: objectApiName,
				actionName: actionName,
			}
		};
		this[NavigationMixin.Navigate](config);
	}
}