import { api, LightningElement, track, wire } from 'lwc';
import fetchRecords from '@salesforce/apex/JunctionRelatedListController.fetchRecords';

export default class JunctionRelatedList extends LightningElement {
    @api recordId;
    @api objectApiName;
    @api childRelation;
    @api otherParentObjectName;
    @api otherParentFieldNameRelation;
    @api otherParentFieldSet;

    @track wiredRecords;
    @track allRecords;
    @track records;
    
    columns;
    error;

    @wire(fetchRecords, {recordId: '$recordId', childRelation: '$childRelation', otherParentObjectName: '$otherParentObjectName', otherParentFieldNameRelation: '$otherParentFieldNameRelation', otherParentFieldSet: '$otherParentFieldSet'})
    fetchRecords(result) {
        this.wiredRecords = result;
        if(result.data) {
            this.allRecords = result.data;
            this.records = result.data;
            this.error = undefined
            this.setColumns(this.records[0].fields);
        } else if(result.error) {
            this.error = result.error;
            this.records = undefined;
        }
        
        //this.setColumns(this.records[0].fields);
    }

    setColumns(fields) {
        this.columns = [...fields.map(f => {
            return {
                label: f.label,
                fieldName: f.apiName,
                type: f.type,
            }
        })];
    }
}