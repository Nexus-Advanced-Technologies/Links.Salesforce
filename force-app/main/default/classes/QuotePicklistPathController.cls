/**
* @description       : 
* @author            : ↨ → giuseppe.alemanno@nexusat.it
* @last modified on  : 26/08/2021
* @last modified by  : ↨ → giuseppe.alemanno@nexusat.it
**/
public class QuotePicklistPathController {
    
    @AuraEnabled
    public static void updateStatus(String statusApiName, Id recordId){
        
        Quote q = new Quote();
        q.Id = recordId;
        q.Status = statusApiName;
        
        try {
            update q;
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