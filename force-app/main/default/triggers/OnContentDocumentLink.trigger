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
}