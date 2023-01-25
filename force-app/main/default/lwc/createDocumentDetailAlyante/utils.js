import l_New from '@salesforce/label/c.New';
import l_Close from '@salesforce/label/c.Close';
import l_Cancel from '@salesforce/label/c.Cancel';
import l_Save from '@salesforce/label/c.Save';
import l_RecordCreatedTitle from '@salesforce/label/c.RecordCreatedTitle';
import l_RecordCreatedMessage from '@salesforce/label/c.RecordCreatedMessage';
import l_GenericErrorTitle from '@salesforce/label/c.GenericErrorTitle';
import l_GenericErrorMessage from '@salesforce/label/c.GenericErrorMessage';

const LABEL = {
	new: l_New,
	close: l_Close,
	cancel: l_Cancel,
	save: l_Save,
	recordCreated: {
		title: l_RecordCreatedTitle,
		message: l_RecordCreatedMessage
	},
	genericError: {
		title: l_GenericErrorTitle,
		message: l_GenericErrorMessage
	}
};

export { LABEL as label }