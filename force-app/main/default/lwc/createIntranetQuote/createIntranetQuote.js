import { LightningElement, api, track } from 'lwc';
import uploadFile from '@salesforce/apex/createIntranetQuote.uploadFile'
import { String, ShowToast, Delay, HandleError } from "c/utils";
export default class FileUploaderCompLwc extends LightningElement {
    @api recordId;
    fileData = null;
    @track showLoading = false;
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


    }
    handleClick() {
        try {
            if(!this.fileData){
                console.log('error filedata');         
                throw new Error('Missing file.');
            }
            this.showLoading = true;
            const { base64, filename, recordId } = this.fileData
            uploadFile({ base64, filename, recordId }).then(result => {
                this.fileData = null
                let title = `${filename} uploaded successfully!`
                ShowToast.success(this, title);
                eval("$A.get('e.force:refreshView').fire();");
                this.showLoading = false
            }).catch(error => {
                this.showLoading = false
                let title2 = 'Quote already generated or Payment Type is empty.';
                ShowToast.error(this, title2);
                throw new Error('Quote already generated or Payment Type is empty.');
                // HandleError.withToast(this, error);
            })
        } catch(error){
            let title1 = 'Quote already generated or file not uploaded.';
            ShowToast.error(this, title1);
            throw new Error('Quote already generated or file not uploaded.');
            //HandleError.withToast(this, error);
        }
    }

}