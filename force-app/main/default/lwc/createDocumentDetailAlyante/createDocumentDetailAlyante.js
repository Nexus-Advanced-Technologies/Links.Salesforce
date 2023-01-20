/**
 * @description       : 
 * @author            : 
 * @last modified on  : 20/01/2023
 * @last modified by  : ¤ → alessio.marra@nexusat.it
**/
import { api, LightningElement, track, wire } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import getRecordDefaultValues from '@salesforce/apex/createDocumentDetailAlyanteController.getRecordDefaultValues';
import { refreshApex } from '@salesforce/apex';

// const fields = ['Content__c',
//                 'RevenueType__c', 'Document__c',
//                 'StartCompetence__c', 'Amount__c',
//                 'EndCompetence__c', 'Project__c',
//                 'Tags__c'];

const DEBOUNCE_INTERVAL = 300;
const OBJ_NAME = 'DocumentDetailAlyante__c';

export default class NavToNewRecordWithDefaults extends NavigationMixin(LightningElement) {
    @api recordId;      //TODO - rename in documentId
    @api recordTypeId;  //FIXME - not working
    objectApiName = OBJ_NAME;

    layout = {};

    //TODO - 
    label = {
        // cancel: 'Cancel',
        header: '',
        new: 'New',
        // save: 'Save'
    };

    fieldValues = [];
    // @api recordId;
    projectPopulated = false;
    projectValue;
    @track fetchedData;
    @wire(getRecordDefaultValues, {documentRecordId: '$recordId'})      //NOTE - rework/improve
    valuesFetched({error, data}) {
        if(data) {
            this.fetchedData = data;
            console.log('wiredStarted');
            // console.log('DATA -> ', data);
            if(data.Project__c) {
                this.projectValue = data.Project__c;
                // console.log(this.projectValue);
            }
        }
        if(error) {
            console.error(error);
        }
        this.projectPopulated = true;
        // this.formatElementValues();
    }

    renderedCallback() {
		console.debug('renderedCallback()');
        const fields = this.template.querySelectorAll('lightning-input-field');
        if (fields) {
            fields.forEach(field => {
                switch (field.fieldName) {
                    case 'RecordTypeId':
                        field.value = this.recordTypeId;
                        break;
                    case 'Document__c':
                        field.value = this.recordId;
                        break;
                    case 'Project__c':
                        field.value = this.projectValue;
                        break;
                    default:
                        field.value = null;
                        break;
                }
                console.debug('[default assignment]', field.fieldName, '=>', field.value);
            });
        }
	}

    handleLoad(evt) {
		console.debug('handleLoad() => ',JSON.parse(JSON.stringify(evt.detail)));
		// this.layout = this.modifyLayout(this.getEvtLayout(evt));
        this.layout = this.formatLayout(evt.detail.layout);

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

				//TODO - quantity not < 1
                //FIXME - Tags not deselect all

			}, DEBOUNCE_INTERVAL);
		} catch (error) {
			console.error(error);
		}
	}

    //TODO - handleSubmit

    handleSuccess(event) {
        var detailRecordId = event.detail.id;
        this.dispatchEvent(new ShowToastEvent({
            title: 'Record Created',        //TODO - custom label
            variant: 'success',
            message: 'The Record was successfully created'      //TODO - custom label
        }));
        this.navigateToRecordViewPage(this.recordId);
    }

    handleError(event) {
        //TODO - handle
    }

    timerId;
	debounce(fn, wait) {
		clearTimeout(this.timerId);
		this.timerId = setTimeout(fn, wait);
	}

    // formatElementValues() {
    //     this.fieldValues = fields.map( elm => {
    //         var value = '';
    //         var size = 6;
    //         switch (elm) {
    //             case 'Content__c':
    //                 size = 12;
    //                 break;
    //             case 'Document__c':
    //                 value = this.recordId;
    //                 break;
    //             case 'Project__c':
    //                 if(this.projectValue) {
    //                     value = this.projectValue;
    //                 }
    //                 break;
    //             case 'Tags__c':
    //                 size = 12;
    //                 break;
    //             default:
    //                 break;
    //         }
    //         return ({
    //             name: elm,
    //             value: value,
    //             size: size
    //         })
    //     })
    //     this.projectPopulated = true;
    // }

    navigateToRecordViewPage(recordId) {
        this[NavigationMixin.Navigate]({
            type: 'standard__recordPage',
            attributes: {
                recordId: recordId,
                actionName: 'view'
            }
        })
        this.resetFieldsAndRefresh();
    }

    resetFieldsAndRefresh() {       //FIXME - not working
        const inputFields = this.template.querySelectorAll(
            'lightning-input-field'
        );
        if (inputFields) {
            inputFields.forEach(field => {
                console.log(field.value);       //TODO - rework c log
                if(field.value != this.recordId && field.value != this.projectValue) {
                    field.reset();
                }
                
            });
        }
        // this.projectPopulated = false;
        // refreshApex(this.fetchedData);
    }

    goBack() {
        this.navigateToRecordViewPage(this.recordId);
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
}