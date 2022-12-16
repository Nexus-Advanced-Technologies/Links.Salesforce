/**
 * @description       : 
 * @author            : ¤ → alessio.marra@nexusat.it
 * @last modified on  : 16/12/2022
 * @last modified by  : ¤ → alessio.marra@nexusat.it
**/
import getDocumentRecord from '@salesforce/apex/PdfPreviewController.getDocumentRecord';
import getCredentials from '@salesforce/apex/PdfPreviewController.getCredentials';

import { api, LightningElement, wire } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
// import { getRecord, getFieldValue } from 'lightning/uiRecordApi';

import errorExtIdBlank from '@salesforce/label/c.PreviewDocumentExtIdBlank';
import errorHttpRequest from '@salesforce/label/c.PreviewDocumentHttpRequest';

// const DOCUMENT_FIELDS = [
//     'DocumentAlyante__c.ExtIdAlyante__c'
// ];

export default class PdfPreview extends LightningElement {
    
    @api recordId;

    showLoader;
    base64;
    errorMessage;
    alyanteId;

    get showError() {
        return this.errorMessage != null;
    }

    get showData() {
        return this.base64 != null;
    }
    
    // @wire(getRecord, { recordId: '$recordId', fields: DOCUMENT_FIELDS } )
    // wiredGetDocumentRecord ({error, data}) {
    //     if (error) {
    //         console.error(JSON.parse(JSON.stringify(error)));
    //     } else if (data) {
    //         console.debug(JSON.parse(JSON.stringify(data)));
    //         const alyanteId = getFieldValue(data, 'DocumentAlyante__c.ExtIdAlyante__c');
    //         this.alyanteId = alyanteId;
    //         console.log('alyante id setted');
    //     }
    // }

    frameLoaded(evt) {
        setTimeout(() => {
            const iframe = this.template.querySelector('iframe');
            iframe.contentWindow.postMessage(this.base64, window.location.origin);
        })
    }

    async connectedCallback() {
        this.showLoader = true;
        console.debug('recordId', this.recordId);

        const documentRecord = await getDocumentRecord({ recordId: this.recordId } );
        this.alyanteId = documentRecord.ExtIdAlyante__c;
        console.log('alyante id setted');

        console.log('alyanteId', this.alyanteId);
        if (this.alyanteId == null) {
            this.setError(errorExtIdBlank);
        } else {
            const credentials = await getCredentials();
            const base64 = await this.getPdfBase64(credentials);
            this.base64 = base64;
            console.log('base64 setted');
            this.showLoader = false;

            console.log('base64', this.base64);
            if (this.base64 == null) {
                this.setError(errorHttpRequest);
            }
        }
    }

    async getPdfBase64(credentials) {
        try {
            const auth = btoa(`${credentials.Username__c}:${credentials.Password__c}`);
            var endpoint = credentials.BaseUrl__c + credentials.PreviewDocumentEndpoint__c;
            endpoint = endpoint.replace('{ExtIdAlyante__c}', this.alyanteId);
            const response = await fetch( endpoint, {
                method: 'GET',
                headers: {
                    'Authorization': 'Basic ' + auth,
                    'Content-Type' : 'application/json'
                }
            });

            console.debug(response);

            if (!response.ok) {
                console.error(await response.json());
                throw new Error(`HTTP error! status: ${response.status}`);
            }
            const data = await response.json();
            return data;
        } catch (error) {
            console.error(error);
        }
    }

    setError(message) {
        this.showLoader = false;
        this.errorMessage = message;
        this.dispatchEvent(new ShowToastEvent({
            title: 'Error',
            message: message,
            variant: 'error'
        }));
    }

    // handleClick(evt) {
    //     console.log('showData : ',this.showData);
    //     console.log('showError : ',this.showError);
    //     console.log('showLoader : ',this.showLoader);
    //     console.log('errorMessage : ',this.errorMessage);
    // }

}