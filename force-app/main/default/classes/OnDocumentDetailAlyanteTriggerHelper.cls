public class OnDocumentDetailAlyanteTriggerHelper {
    
    public static List<DocumentDetailAlyante__c> blockCreateRecords(List<DocumentDetailAlyante__c> triggerNew) {
        
        if(isAdminUser()) {
            return new List<DocumentDetailAlyante__c>();
        }
        
        List<DocumentDetailAlyante__c> documentDetailsToBlock = new List<DocumentDetailAlyante__c>();
        Map<Id, List<DocumentDetailAlyante__c>> documentDetailsByDocument = new Map<Id, List<DocumentDetailAlyante__c>>();
        
        for (DocumentDetailAlyante__c documentDetail : triggerNew){
            List<DocumentDetailAlyante__c> details = new List<DocumentDetailAlyante__c>();
            if(documentDetailsByDocument.containsKey(documentDetail.Document__c)){
                details.addAll(documentDetailsByDocument.get(documentDetail.Document__c));
            }
            details.add(documentDetail);
            documentDetailsByDocument.put(documentDetail.Document__c, details);
        }
        
        for (Id documentId : documentDetailsByDocument.keySet()) {
            if(Approval.isLocked(documentId)){
                for(DocumentDetailAlyante__c documentDetail : documentDetailsByDocument.get(documentId)){
                    documentDetailsToBlock.add(documentDetail);
                }
            }
        }
        return documentDetailsToBlock;
    }
    
    private static Boolean isAdminUser() {
        return [SELECT PermissionsModifyAllData FROM Profile WHERE Id = :UserInfo.getProfileId() LIMIT 1].PermissionsModifyAllData;
    }
}