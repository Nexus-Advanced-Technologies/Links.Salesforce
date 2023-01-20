/**
 * @description       : 
 * @author            : 
 * @last modified on  : 19/12/2022
 * @last modified by  : ¤ → alessio.marra@nexusat.it
**/
import { api, LightningElement, track, wire } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import getRecordDefaultValues from '@salesforce/apex/createDocumentDetailAlyanteController.getRecordDefaultValues';
import { refreshApex } from '@salesforce/apex';

const fields = ['Content__c',
                'RevenueType__c', 'Document__c',
                'StartCompetence__c', 'Amount__c',
                'EndCompetence__c', 'Project__c',
                'Tags__c'];
export default class NavToNewRecordWithDefaults extends NavigationMixin(LightningElement) {
    fieldValues = [];
    @api recordId;
    projectPopulated = false;
    projectValue;
    @track fetchedData;
    @wire(getRecordDefaultValues, {documentRecordId: '$recordId'})
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
        this.navigateToRecordViewPage(this.recordId);
    }
    handleError(event) {
        // console.log('ERROR -> ', event);
    }
    // connectedCallback() {
    //    console.log('connsected');
    //    this.formatElementValues();
    // }
    formatElementValues() {
        this.fieldValues = fields.map( elm => {
            var value = '';
            var size = 6;
            switch (elm) {
                case 'Content__c':
                    size = 12;
                    break;
                case 'Document__c':
                    value = this.recordId;
                    break;
                case 'Project__c':
                    if(this.projectValue) {
                        value = this.projectValue;
                    }
                    break;
                case 'Tags__c':
                    size = 12;
                    break;
                default:
                    break;
            }
            return ({
                name: elm,
                value: value,
                size: size
            })
        })
        this.projectPopulated = true;
    }
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
    resetFieldsAndRefresh() {
        const inputFields = this.template.querySelectorAll(
            'lightning-input-field'
        );
        if (inputFields) {
            inputFields.forEach(field => {
                console.log(field.value);
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
}