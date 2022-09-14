import { LightningElement, api, track } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import uploadFile from '@salesforce/apex/createIntranetQuote.uploadFile'
export default class FileUploaderCompLwc extends LightningElement {
    @api recordId;
    fileData
    @track showLoading=false;
    fileUploaded=false;
    openfileUpload(event) {
        const file = event.target.files[0]
        var reader = new FileReader()
        reader.onload = () => {
            var base64 = reader.result.split(',')[1]
            this.fileData = {
                'filename': file.name,
                'base64': base64,
                'recordId': this.recordId
            }
            console.log(this.fileData)
        }
        reader.readAsDataURL(file)
        if (reader.result) {
            this.fileUploaded=true;
        }
    }
    
    handleClick(){
        if (this.fileUploaded) {
            this.showLoading=true
            const {base64, filename, recordId} = this.fileData
            
                uploadFile({ base64, filename, recordId }).then(result=>{
                    this.fileData = null
                    this.showLoading=false
                    let title = `${filename} uploaded successfully!!`
                    this.toast(title)
                    eval("$A.get('e.force:refreshView').fire();");
                }).catch(error=>{   
                                    const title = 'Upload failed because field PaymentType__c is empty'
                                    const toastEvent1 = new ShowToastEvent({
                                    title, 
                                    variant:"error"
                                    })
                                    console.log(title)
                                    this.dispatchEvent(toastEvent1)  
                                    this.showLoading=false              
                                })
        }
        else {
            const title = 'File not uploaded'
            const toastEvent2 = new ShowToastEvent({
            title, 
            variant:"error"
        })
        this.dispatchEvent(toastEvent2)
        }   
       }
    toast(title){
        const toastEvent = new ShowToastEvent({
            title, 
            variant:"success"
        })
        this.dispatchEvent(toastEvent)
    }
    
    
}