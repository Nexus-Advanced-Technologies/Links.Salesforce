public class OnOrderTriggerHelper {
    public static boolean hasContractOrder(Order newOrder){
        List<ContentDocumentLink> numberContentDocument = [SELECT LinkedEntityId FROM ContentDocumentLink WHERE LinkedEntityId =: newOrder.Id];
        return numberContentDocument.size()<1;
    }
}