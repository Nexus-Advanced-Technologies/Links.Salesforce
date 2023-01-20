/**
 * @description       : 
 * @author            : ¤ → alessio.marra@nexusat.it
 * @last modified on  : 03/01/2023
 * @last modified by  : ¤ → alessio.marra@nexusat.it
**/
import { LightningElement, api, wire } from 'lwc';
import LightningModal from 'lightning/modal';
import { NavigationMixin } from 'lightning/navigation';
import { encodeDefaultFieldValues } from 'lightning/pageReferenceUtils';
import { CloseActionScreenEvent } from 'lightning/actions';
import { getObjectInfo } from 'lightning/uiObjectInfoApi';
import l_cancel from '@salesforce/label/c.Cancel';
import l_new from '@salesforce/label/c.New';
import l_save from '@salesforce/label/c.Save';

const DEBOUNCE_INTERVAL = 300;
const OBJ_NAME = 'PaymentType__c';

//https://links--dev.sandbox.lightning.force.com/lightning/o/PaymentTypeDetail__c/new?count=1&PaymentType__c=a037Y00000WuNuEQAV&RecordTypeId=01209000000l0oGAAQ

export default class CreatePaymentType extends NavigationMixin(LightningModal) {
	@api recordId;
	@api objectApiName;
	layout = {};
	label = {
		cancel: l_cancel,
		header: '',
		save: l_save
	}
	toCreateDetail;
	recordTypeIdDetail;
	paymentTypeDetailObjInfo;
	type;
	
	@wire(getObjectInfo, { objectApiName: 'PaymentTypeDetail__c' } )
	paymentTypeDetailObjInfo

	constructor() {
		super();
		if(!this.objectApiName) {
			this.objectApiName = OBJ_NAME;
		}
	}

	renderedCallback() {
		const fields = this.template.querySelectorAll('lightning-input-field');
		if (fields) {
			fields.forEach(field => {
				field.value = this.getDefaultValue(field.fieldName)
				console.log('[default assignment]', field.fieldName, '=>', field.value);
			});
		}
	}

	handleLoad(evt) {
		console.info('handleLoad() => ',JSON.parse(JSON.stringify(evt.detail)));
		this.layout = this.modifyLayout(this.getEvtLayout(evt));
		
		this.label.header = `${l_new} ${evt.detail.objectInfos[OBJ_NAME].label}`;
	}

	handleInputChange(evt) {
		console.info('handleInputChange() => ',JSON.parse(JSON.stringify(evt.detail)));
		try {
			const target = evt.target;
			this.debounce(function() {
				const fieldApiName = target.dataset.id;
				var value = target.value;
				console.log('[change]', fieldApiName, '=>', value);

				//TODO - 

			}, DEBOUNCE_INTERVAL);
		} catch (error) {
			console.error(error);
		}
	}

	handleSubmit(evt) {
		try {
			console.info('handleSubmit() => ',JSON.parse(JSON.stringify(evt.detail)));
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
			console.log('fields: ',JSON.parse(JSON.stringify(fields)));
			this.type = fields.Type__c;

			// NOTE - other assignment
			this.template.querySelector("lightning-record-edit-form").submit(fields);
		} catch (error) {
			console.error(error);
		}
	}

	handleClose(evt) {
		console.log('handleClose() => ',JSON.parse(JSON.stringify(evt.detail)));
		//FIXME - not working
		this.close();
		
	}

	handleSuccess(evt) {
		console.log('handleSuccess() => ',JSON.parse(JSON.stringify(evt.detail)));
		console.log('recordId ', evt.detail.id);
		this.recordId = evt.detail.id;

		// TODO - redirect

		var rtInfos = this.paymentTypeDetailObjInfo.data.recordTypeInfos;
		this.recordTypeIdDetail = Object.keys(rtInfos).find(x => rtInfos[x].name == this.type);

		this.toCreateDetail = true;
	}

	handlePaymentTypeDetailClose(evt) {
		console.log('handlePaymentTypeDetailClose() => ',JSON.parse(JSON.stringify(evt.detail)));
		// TODO - check se ci sono detail creati
		// TODO - throw exc ed eliminare il record
	}

	timerId;
	debounce(fn, wait) {
		clearTimeout(this.timerId);
		this.timerId = setTimeout(fn, wait);
	}

	getDefaultValue(field) {
		var value;
		switch (field) {
			case 'Name':
				value = 'name default';
				break;
			case 'Description__c':
				value = 'description';
				break;
			default:
				value = null;
				break;
		}
		return value;
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

	close() {
		// this.dispatchEvent(new CloseActionScreenEvent());
		const event = new CustomEvent('close', {
			detail: {  }
		});
		this.dispatchEvent(event);
	}

	// showToast(title, variant, message, messageData = {}) {
	// 	const toastEvt = new ShowToastEvent({
	// 		title: title,
	// 		variant: variant,
	// 		message: message,
	// 		messageData: messageData,
	// 	});

	// 	this.dispatchEvent(toastEvt);
	// }
}