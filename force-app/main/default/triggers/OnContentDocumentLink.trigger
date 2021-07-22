/**
 * @description       : 
 * @author            : ¤ → alessio.marra@nexusat.it
 * @last modified on  : 03/02/2021
 * @last modified by  : ¤ → alessio.marra@nexusat.it
 * Modifications Log 
 * Ver   Date         Author                         Modification
 * 1.0   02/02/2021   ¤ → alessio.marra@nexusat.it   Initial Version
**/
trigger OnContentDocumentLink on ContentDocumentLink (before insert) {

	OnContentDocumentLinkHelper.shareToChatterGroup(Trigger.new);
	// System.debug('¤ ContentDocumentLink before insert');
	// System.debug('¤ ContentDocumentId: ' + Trigger.new[0].ContentDocumentId);
	// System.debug('¤ LinkedEntityId: ' + Trigger.new[0].LinkedEntityId);
	// System.debug('¤ ShareType: ' + Trigger.new[0].ShareType);
	// System.debug('¤ Visibility: ' + Trigger.new[0].Visibility);

	// if (Trigger.new[0].ShareType == 'I') {
	// 	ContentDocumentLink cdl = new ContentDocumentLink();
	// 	cdl.ContentDocumentId = Trigger.new[0].ContentDocumentId;
	// 	cdl.LinkedEntityId = '0F97Y000000GnTZSA0';
	// 	cdl.ShareType = 'C';
	// 	insert cdl;
	// }
}