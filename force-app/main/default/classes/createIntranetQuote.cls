/**
 * @description       : 
 * @author            : Massimo Frangiamore
 * @group             : 
 * @last modified on  : 09-06-2022
 * @last modified by  : Massimo Frangiamore
**/
public with sharing class createIntranetQuote {
    @AuraEnabled
    public static String uploadFile(String base64, String filename, String recordId) {
        system.debug('si sono qui');
        return null;
    }
    private static ContentVersion createContentVersion(String base64, String filename) {
        ContentVersion cv = new ContentVersion();
        cv.VersionData = EncodingUtil.base64Decode(base64);
        cv.Title = filename;
        cv.PathOnClient = filename;
        try {
            insert cv;
            return cv;
        } catch(DMLException e) {
            System.debug(e);
            return null;
        }
    }
    private static ContentDocumentLink createContentLink(String contentVersionId, String recordId) {
        if (contentVersionId == null || recordId == null) { return null; }
        ContentDocumentLink cdl = new ContentDocumentLink();
        cdl.ContentDocumentId = [
        SELECT ContentDocumentId 
        FROM ContentVersion 
        WHERE Id =: contentVersionId
        ].ContentDocumentId;
        cdl.LinkedEntityId = recordId;
        // ShareType is either 'V', 'C', or 'I'
        // V = Viewer, C = Collaborator, I = Inferred
        cdl.ShareType = 'V';
        try {
            insert cdl;
        return cdl;
        } catch(DMLException e) {
            System.debug(e);
        return null;
        }
    }
}
