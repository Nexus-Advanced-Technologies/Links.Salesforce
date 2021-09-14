/**
* @description       : 
* @author            : ↨ → giuseppe.alemanno@nexusat.it
* @last modified on  : 26/08/2021
* @last modified by  : ↨ → giuseppe.alemanno@nexusat.it
**/
public class QuotePicklistPathController {
    
    @AuraEnabled
    public static String oldValue(Id id){
        Quote quote = [SELECT id,Status FROM Quote WHERE Id =: id];
        return quote.Status;
    }
    
    @AuraEnabled
    public static void updateStatus(String statusApiName, Id recordId, String oldValue){
        
        Quote q = new Quote();
        q.Id = recordId;
        q.Status = statusApiName;
        
        try {
            if(q.Status == Null || q.Status == oldValue){
                throw new AuraException('ASSICURATI DI AVER SETTATO UNO STATO DIVERSO DA QUELLO CORRENTE');
            }else{
                update q;
            }
        } catch(System.DmlException e){
            system.debug('Message: '+e.getMessage());
            system.debug('StackTrace: '+e.getStackTraceString());
            throw new AuraHandledException(e.getDmlMessage(0));
        }
        catch (Exception e) {
            system.debug('Message: '+e.getMessage());
            system.debug('StackTrace: '+e.getStackTraceString());
            throw new AuraHandledException(e.getMessage());
        }
    }
}