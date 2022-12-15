import getExtIdAlyante from '@salesforce/apex/PdfPreviewController.getExtIdAlyante';
import getCredentials from '@salesforce/apex/PdfPreviewController.getCredentials';
import { api, LightningElement, wire } from 'lwc';
import errorExtIdBlank from '@salesforce/label/c.PreviewDocumentExtIdBlank';
// Example :- import greeting from '@salesforce/label/c.greeting';
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
        }
        if(error) {
            console.error(error);
        }
    }
    @wire(getExtIdAlyante, {recordId: '$recordId', credentials: '$credentials'})
    wiredId({error, data}) {
        if(data) {
            this.showLoader = true;
            this.extId = data;
            this.getPDF();
        } else{
            error = errorExtIdBlank;
        }

        if (error) {
            this.setError(error);
        }
    }

    frameLoaded(evt) {
        setTimeout(() => {
            const iframe = this.template.querySelector('iframe');
            iframe.contentWindow.postMessage(this.base64, window.location.origin);
        })
    }

    connectedCallback() {
        console.log('recordId', this.recordId);
    }

    async getPDF() {
        var auth = btoa(`${this.username}:${this.password}`)
        
        await fetch(this.baseUrl + this.extId, {
            method: 'GET',
            headers: {
                'Authorization': 'Basic ' + auth,
                'Content-Type' : 'application/json'
            }
        })
        .then((response) => {
            if (response.ok) {
                return response.json();
            }
            return Promise.reject(response);
            })
        .then((json) => {
            this.base64 = json;
            this.showLoader = false;
            this.showError = false;
            this.showData = true;
        })
        .catch((responseError) => {
            console.error(responseError.status, responseError.statusText);
            responseError.json()
            .then((json) => {
                this.setError(json);
            })
        });
    }

    setError(message) {
        console.error(message);
        this.showLoader = false;
        this.errorMessage = message;
        this.showError = true;
    }
}