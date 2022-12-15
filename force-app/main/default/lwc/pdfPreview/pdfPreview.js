import getExtIdAlyante from '@salesforce/apex/PdfPreviewController.getExtIdAlyante';
import getCredentials from '@salesforce/apex/PdfPreviewController.getCredentials';
import { api, LightningElement, wire } from 'lwc';
// const baseUrl = 'https://intranet.linksmt.it/SalesforceWebApplicationTest/api/Alyante/PreviewDocument/';
// const credentials = {username: 'SalesforceDEV', password: '1gxP9ch7k0jc' };
export default class PdfPreview extends LightningElement {
    
    @api recordId;
    extId;
    response;
    showData = false;
    showLoader = true;
    showError = false;
    pdf;
    baseUrl;
    username;
    password;
    errorMessage = '';
    credentials;
    @wire(getCredentials, {})
    wiredCredentials({error, data}) {
        if(data) {
            this.baseUrl = data.BaseUrl__c;
            this.username = data.Username__c;
            this.password = data.Password__c;
            this.credentials = data;
            console.log(this.credentials);
        }
        else if(error) {
            console.log(error);
        }
    }
    @wire(getExtIdAlyante, {recordId: '$recordId', credentials: '$credentials'})
    wiredId({error, data}) {
        if(data) {
            this.showLoader = true;
            // console.log('DATA -> ',data);
            this.extId = data;
            this.getPDF();     
        }
        else if(error) {
            console.log('error -> ', data);
            this.showLoader = false;
            this.errorMessage = 'ExtIdAlyante non presente';
            this.showError = true;
        }
        else if(!data && !error) {
            if(this.extId == null) {
                console.log('error -> ', data);
                this.showLoader = false;
                this.errorMessage = 'ExtIdAlyante non presente';
                this.showError = true;
            }
        }
    }
    frameLoaded(evt) {
        setTimeout(() => {
            const iframe = this.template.querySelector('iframe');
            iframe.contentWindow.postMessage(this.base64, window.location.origin);
        })
    }
    connectedCallback() {
        console.log(this.recordId);
        // this.getPDF();
    }
    async getPDF() {
        var auth = btoa(`${this.username}:${this.password}`)
        console.log(auth);
        var response = await fetch(this.baseUrl + this.extId, {
            method: 'GET',
            headers: {
                'Authorization': 'Basic ' + auth, 
                'Content-Type' : 'application/json'
            }
            }).then(response => {
            if (!response.ok) {
                console.log('error');
                this.errorMessage = 'Non e\' stato possibile recuperare il pdf';
                this.showLoader = false;
                this.showError = true;
                throw new Error(response.status);
            } 
            return response.text();
        }).then((base64) => {
            this.base64 = base64.replace(/['"]+/g, '');
            // console.log(this.base64);
            this.showLoader = false;
            this.showError = false;
            this.showData = true;
        });
        // return response;
    }
}