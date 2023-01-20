import { LightningElement, api } from 'lwc';

export default class CloneRelatedList extends LightningElement {
    tableData;
    documentDetailsToUpdate = {};
    documetDetailsCloned;
    submitBtnDisabled = true;
    hideTableFooter = false;
    docDetailsToInsert;
    @api documentId;
    @api documentDetails;
    columns = [
        { label: 'Name', fieldName: 'Name' },
        { label: 'Project', fieldName: 'ProjectUrl', type: 'url',
        typeAttributes: {label: { fieldName: 'ProjectName' }, target: '_blank'} },
        { label: 'Revenue Type', fieldName: 'RevenueType__c'},
        { label: 'Start Competence', fieldName: 'StartCompetence__c', type: 'date' },
        { label: 'End Competence', fieldName: 'EndCompetence__c', type: 'date' },
        { label: 'Amount', fieldName: 'Amount__c', type: 'currency', editable: true}
    ];
    handleSave(event) {
        console.log(event.detail.draftValues);
        this.hideTableFooter = true;
        for(let value of event.detail.draftValues) {
            var index = value.id.replace('row-', '');
            console.log(value.Amount__c)
            console.log(this.documentDetails[index].Amount__c)
            console.log(this.documentDetails[index].Id)
            this.documentDetailsToUpdate[this.documentDetails[index].Id] = value.Amount__c;
            console.log(this.documentDetailsToUpdate);
            //  = this.documentDetailsToUpdate.map((elm) => {
            //     return{
            //         ...elm,
            //         [this.documentDetails[index].Id]: value.Amount__c 
            //     }
            // }) 
        }
        
        // var index = event.detail.draftValues[0].id;
        // console.log(index)
        // var index = index.replace('row-', '');
        // console.log(index)
        // console.log(this.documentDetails[index].Amount__c)
        
    }
    getSelectedDetail(event) {
        const selectedRows = event.detail.selectedRows;
        
    }
    createRecordDetails() {
        var selectedRecords = JSON.parse(JSON.stringify(this.template.querySelector("lightning-datatable").getSelectedRows()));
        console.log(JSON.parse(JSON.stringify(selectedRecords)));
        var recordUpdated = [];
        for (const ind in selectedRecords) {
            var amount;
            console.log(selectedRecords[ind].Id)
            console.log(this.documentDetailsToUpdate[selectedRecords[ind].Id]);
            if(this.documentDetailsToUpdate[selectedRecords[ind].Id]) {
                console.log('test', selectedRecords[ind].Amount__c);
                recordUpdated.push({... selectedRecords[ind], Amount__c:  this.documentDetailsToUpdate[selectedRecords[ind].Id], Document__c: this.documentId});
            }
        }
        if(recordUpdated.length > 0) {
            recordUpdated.forEach(element => {
                delete element.ProjectName;
                delete element.ProjectUrl;
                delete element.Project__r;
            });
            this.docDetailsToInsert = recordUpdated;
        }
        else {
            selectedRecords.forEach(element => {
                delete element.ProjectName;
                delete element.ProjectUrl;
                delete element.Project__r;
            });
            this.docDetailsToInsert = selectedRecords;
        }
        this.dispatchEvent(new CustomEvent('docdetailselected', {detail: {clonedDocDetails: this.docDetailsToInsert}}));
        // console.log(JSON.parse(JSON.stringify(this.docDetailsToInsert)));
       
    }
}