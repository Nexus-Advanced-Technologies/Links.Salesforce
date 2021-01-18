public class PianificazioneFattureController {
    //Called from Proces Builder
    @InvocableMethod
    public static void createInvoiceMilestoneInvocable(List<Id> listOppIds){
        
        for(Id oppId : listOppIds){
            createInvoiceMilestone(oppId);
        }
    }
    @AuraEnabled
    public static Boolean createInvoiceMilestone(Id recordId){
        List<Invoice_Milestone__c> imList = New List<Invoice_Milestone__c>();
        Boolean check = false;
        Id rtId = null;
        String imStringName = '';
        try{
            Opportunity opp = [SELECT Id, StageName, Name, CloseDate, Tipo_Pagamento__c, Reference_Number__c,Amount,Numero_Ordine_del_Cliente__c,Account.Acronimo__c,Account.Name
                                FROM Opportunity
                                WHERE Id =: recordId];
            deleteInvoiceMilestonePresenti(opp);
            //if(opp.StageName == 'Proposal/Price Quote' && opp.Tipo_Pagamento__c != null){
            if( opp.Tipo_Pagamento__c != null){                    
                    Double numCanoni;
                    Integer mensilit;
                    
                    Tipo_Pagamento__c tp = [SELECT Id, Tipo__c,Descrizione__c,isDeleted__c,Name
                                            FROM Tipo_Pagamento__c
                                            WHERE Id =: opp.Tipo_Pagamento__c];
                    
                    System.debug('Ø-opp.Tipo_Pagamento__c '+opp.Tipo_Pagamento__c);
                    
                    //Get Tipo di Pagamento dettaglio Object
                    List<Tipo_Pagamento_Dettaglio__c> tpdList = [SELECT Id, Name,Numero_Canoni__c,RecordTypeId,Tipo_Pagamento__c,Unit_di_misura__c,Valore__c,Valore_Canone__c,Rank__c
                                                                 FROM Tipo_Pagamento_Dettaglio__c
                                                                 WHERE Tipo_Pagamento__c =: opp.Tipo_Pagamento__c
                                                                 ORDER BY Rank__c ASC
                                                                ];
                    
                    //Get RecordType and Create Invoice Milestone
                    if(tp.Tipo__c == 'Recursive')
                    {
                        rtId = [SELECT Id, DeveloperName 
                                FROM RecordType 
                                WHERE DeveloperName = 'Recursive'].Id;
                        System.debug('Ø-rtId '+rtId);
                        
                        for(Tipo_Pagamento_Dettaglio__c tpd1 : tpdList){
                            numCanoni = tpd1.Numero_Canoni__c;
                            System.System.debug('Ø*** numero canoni: '+numCanoni);
                            mensilit = Integer.valueOf(tpd1.Unit_di_misura__c);
                            System.System.debug('Ø*** unità di misura: '+mensilit);
                            for(Integer i = 0; i< numCanoni; i++){
                                for(Tipo_Pagamento_Dettaglio__c tpd2 : tpdList){
                                    Invoice_Milestone__c im = New Invoice_Milestone__c();
                                    im.Opportunity__c = opp.Id;
                                    im.RecordTypeId = rtId;
                                    Date oppDate = opp.CloseDate;
                                    im.Data_prevista__c = oppDate.addMonths(mensilit*i);
                                    System.System.debug('Ø*** Invoice Milestone - Data prevista: '+im.Data_prevista__c);
                                    Integer monthNumber = im.Data_prevista__c.month();
                                    String monthName = '';
                                    if(monthNumber == 1)
                                        monthName = 'January';
                                    else if(monthNumber == 2)
                                        monthName = 'February';
                                    else if(monthNumber == 3)
                                        monthName = 'March';
                                    else if(monthNumber == 4)
                                        monthName = 'April';
                                    else if(monthNumber == 5)
                                        monthName = 'May';
                                    else if(monthNumber == 6)
                                        monthName = 'June';
                                    else if(monthNumber == 7)
                                        monthName = 'July';
                                    else if(monthNumber == 8)
                                        monthName = 'August';
                                    else if(monthNumber == 9)
                                        monthName = 'September';
                                    else if(monthNumber == 10)
                                        monthName = 'October';
                                    else if(monthNumber == 11)
                                        monthName = 'November';
                                    else if(monthNumber == 12)
                                        monthName = 'December';
                                    String yearName = String.valueof(im.Data_prevista__c.year());
                                    if(opp.Account.Acronimo__c != null){
                                        imStringName = String.valueOf(opp.Reference_Number__c)+' - '+ ' '+ opp.Account.Acronimo__c+' - '+tp.Name +' - '+monthName+' '+yearName;
                                    }else{
                                        imStringName = String.valueOf(opp.Reference_Number__c)+' - '+ ' '+ opp.Account.Name.left(3)+' - '+tp.Name +' - '+monthName+' '+yearName;
                                    }
                                    im.Name = imStringName;
                                    im.Ammontare__c = opp.Amount / tpd2.Numero_Canoni__c;
                                    im.Description__c = 'Servizio a Canone - '+opp.Name ;
                                    im.Numero_Ordine_del_Cliente__c = opp.Numero_Ordine_del_Cliente__c;
                                    im.Anno__c = yearName;
                                    System.System.debug('im.Numero_Ordine_del_Cliente__c');
                                    imList.add(im);		
                                }
                            }
                        }
                    }
                    
                    //Get RecordType and Create Invoice Milestone
                    if(tp.Tipo__c == 'One Shot')
                    {
                        rtId = [SELECT Id, DeveloperName 
                                FROM RecordType 
                                WHERE DeveloperName = 'One_Shot'].Id;
                        System.debug('Ø-rtId '+rtId);
                        
                        for(Tipo_Pagamento_Dettaglio__c tpd : tpdList){
                            Invoice_Milestone__c im = New Invoice_Milestone__c();
                            if(opp.Account.Acronimo__c != null ){
                                im.Name = String.valueOf(opp.Reference_Number__c)+' - '+ opp.Account.Acronimo__c+' - '+ tpd.Name;
                            }else{
                                im.Name = String.valueOf(opp.Reference_Number__c)+' - '+ opp.Account.Name.left(3)+' - '+ tpd.Name;
                            }                            
                            im.Rank__c = tpd.Rank__c;
                            im.Opportunity__c = opp.Id;
                            im.RecordTypeId = rtId;
                            im.Data_prevista__c = Date.today();
                            im.Anno__c = String.valueOf(Date.today().year());
                        	String yearName = String.valueof(im.Data_prevista__c.year());      ///**********************
                            im.Anno__c = String.valueOf(Date.today().year());
                            im.Anno__c = yearName;
                            im.Ammontare__c = (opp.Amount * tpd.Valore__c) / 100;
                            im.Description__c = tpd.Name +' - '+ opp.Name;
                            im.Numero_Ordine_del_Cliente__c = opp.Numero_Ordine_del_Cliente__c;
                            imList.add(im);		
                        }
                    }
                }
                if(!imList.isEmpty()){
            insert imList;
            check = true;
                }
        }catch(Exception ex){
        System.debug('Exception : '+ex+', message: '+ex.getMessage()+' - '+ex.getLineNumber()+' - '+ex.getCause());
        }
        return check;
    }
    //Delete Invoice Milestone
    @AuraEnabled
    public static void deleteInvoiceMilestonePresenti(Opportunity opp){

        List<Invoice_Milestone__c> invoiceMilestoneToDelete = [SELECT Id, Opportunity__c FROM Invoice_Milestone__c WHERE Opportunity__c =: opp.Id];

        if(!invoiceMilestoneToDelete.isEmpty()){
            delete invoiceMilestoneToDelete;
        }
    }
}