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
    async handleClick() {
        try {
            if(!this.fileData) {
                ShowToast.error(this, 'Missing file.');
                return;
            }

            this.showLoading = true;

            const { base64, filename, recordId } = this.fileData;
            await uploadFile({ base64, filename, recordId });

            this.fileData = null;
            ShowToast.success(this, `${filename} uploaded successfully!`);
            eval("$A.get('e.force:refreshView').fire();");
            this.showLoading = false
        } catch(e) {
            this.showLoading = false
            console.error(e)
            ShowToast.error(this, e.body.message);
        }
    }

}