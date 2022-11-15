import { api, LightningElement, wire } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import getRecordDefaultValues from '@salesforce/apex/createDocumentDetailAlyanteController.getRecordDefaultValues';

const fields = ['Document__c',
                'Content__c', 'RevenueType__c',
                'Amount__c', 'StartCompetence__c',
                'Project__c', 'EndCompetence__c',
                'Tags__c'];
export default class NavToNewRecordWithDefaults extends NavigationMixin(LightningElement) {
    fieldValues = [];
    @api recordId;
    projectPopulated = false;
    projectValue;
    @wire(getRecordDefaultValues, {documentRecordId: '$recordId'})
    valuesFetched({error, data}) {
        if(data) {
            // console.log('DATA -> ', data);
            if(data.Project__c) {
                this.projectValue = data.Project__c;        
                // console.log(this.projectValue);
            }
        }
        if(error) {
            console.log('ERROR -> ', error)
        }
        this.formatElementValues();
    }
    handleSuccess(event) {
        var detailRecordId = event.detail.id;
        this.dispatchEvent(new ShowToastEvent({
            title: 'Record Created',
            variant: 'success',
            message: 'The Record was successfully created',
        }));
        this.navigateToRecordViewPage(detailRecordId);
    }
    handleError(event) {
        // console.log('ERROR -> ', event);
    }
    connectedCallback() {
        // console.log('connsected');
        // this.formatElementValues();
    }
    formatElementValues() {
        // console.log(this.projectValue);
        // console.log('formatting');
        this.fieldValues = fields.map( elm => {
            var value = '';
            if(elm == 'Document__c' && this.recordId) { 
                value = this.recordId;
            }
            if(elm == 'Project__c') {
                if(this.projectValue) {
                    value = this.projectValue;
                }
            }
            return ({
                name: elm, value: value
            })
        })
        // console.log('formatting data -> ', this.fieldValues);
    }
    navigateToRecordViewPage(recordId) {
        // View a custom object record.
        this[NavigationMixin.Navigate]({
            type: 'standard__recordPage',
            attributes: {
                recordId: recordId,
                actionName: 'view'
            }
        });
    }
    goBack() {
        this.navigateToRecordViewPage(this.recordId);
    }
}