import l_Cancel from '@salesforce/label/c.Cancel';
import l_Close from '@salesforce/label/c.Close';
import l_New from '@salesforce/label/c.New';
import l_Next from '@salesforce/label/c.Next';
import l_Save from '@salesforce/label/c.Save';

import l_RecordCreatedTitle from '@salesforce/label/c.RecordCreatedTitle';
import l_RecordCreatedMessage from '@salesforce/label/c.RecordCreatedMessage';
import l_GenericErrorOnSaveTitle from '@salesforce/label/c.GenericErrorOnSaveTitle';
import l_GenericErrorOnSaveMessage from '@salesforce/label/c.GenericErrorOnSaveMessage';

import l_SelectRecordType from '@salesforce/label/c.SelectRecordType';

import l_ProjWarnTitle from '@salesforce/label/c.ProjectWarningTitle';
import l_ProjWarnMessage from '@salesforce/label/c.ProjectWarningMessage';

const LABEL = {
	cancel: l_Cancel,
	close: l_Close,
	new: l_New,
	next: l_Next,
	save: l_Save,
	recordCreated: {
		title: l_RecordCreatedTitle,
		message: l_RecordCreatedMessage
	},
	genericErrorOnSave: {
		title: l_GenericErrorOnSaveTitle,
		message: l_GenericErrorOnSaveMessage
	},
	selectRecordType: l_SelectRecordType,
	projectWarning: {
		title: l_ProjWarnTitle,
		message: l_ProjWarnMessage
	}
};

export { LABEL as label }