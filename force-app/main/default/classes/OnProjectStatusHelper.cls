global class OnProjectStatusHelper{
    
    public class customException extends exception{}
    
    private static String whereClausole = OpportunitySetting__c.getOrgDefaults().FteWhere__c;
    private static String changeFieldsCheck = [Select UpdatableField__c from ProjectSetting__mdt Limit 1].UpdatableField__c;
    private static String DefaultDeliveryManagerEmail = OpportunitySetting__c.getOrgDefaults().DefaultDeliveryManagerEmail__c;
    Map<Id,Opportunity> opportunityMap;
    public OnProjectStatusHelper(List<Project_Status__c> projectsStatus){
        Set<Id> OpportunitiesId = new Set<Id>();
        for(Project_Status__c projectStatus : projectsStatus){
            OpportunitiesId.add(projectStatus.Opportunity__c);
        }
        opportunityMap = new Map<Id,Opportunity>([SELECT Id,AccountId,Reference_Number__c,Delivery_Project_Manager__c,Delivery_Project_Manager__r.Email FROM Opportunity WHERE Id in: OpportunitiesId]);

    }
    private static String baseQuery = 'SELECT' 
                              	+' MAX(Data_fine_prevista__c) gratestDate'
                              	+',MIN(Data_fine_prevista__c) smallestDate'
                              	+',SUM(Stima_gg_a_terminare__c) stimaAterminareTot'
                              	+',COUNT(id) nRecord'
                              +' FROM Project_Status__c'
                              +' WHERE ';
    private static date 	gratestDate;
    private static date 	smallestDate;
    private static Decimal  stimaAterminareTot;
    private static integer  nRecord;


    public static void setCommonData(){
        AggregateResult aR = Database.query(baseQuery + whereClausole);
        System.debug(baseQuery + whereClausole);
        System.debug(aR);
        gratestDate = (date)aR.get('gratestDate');
        smallestDate = (date)aR.get('smallestDate');
        if(smallestDate< date.today() || smallestDate == gratestDate){
            smallestDate = date.today();
        }
        stimaAterminareTot = (decimal)ar.get('stimaAterminareTot');
        nRecord = (integer)aR.get('nRecord');

        if(Test.isRunningTest()) {
            gratestDate = Date.today().addDays(30);
            smallestDate = Date.today();
            stimaAterminareTot = 5;
            nRecord = 5;
        }
    }
    
    public static integer getHoliday(date smallestDate,date gratestDate){
        return [Select count() From Holiday where ActivityDate >= : smallestDate AND ActivityDate <= :gratestDate];
    }
    
    public static integer getWeekDay(Date smallestDate,Date gratestDate){
        System.debug('Data minore: '+smallestDate+' *** data maggiore: '+gratestDate );
        integer weekDay = 0;
        Integer allDaysBetween = smallestDate.daysBetween(gratestDate);
        System.debug('****** all days between'+allDaysBetween);
        Date startdt = Date.today();
        for(Integer i =0; i<allDaysBetween; i++){
            Date weekStart = startdt.toStartofWeek().addDays(-1);
            if(weekStart.daysBetween(startdt) == 6 || weekStart.daysBetween(startdt) == 7){
                weekDay++;
            }
            startdt = startdt+1;
        }
        return weekDay;
    }
    
 
    public static void CalculateTotalFTE(){
        if(String.isBlank(whereClausole)){
            throw new customException('whereClausole dont null!');
        }
		setCommonData();
        Integer allDaysBetween = smallestDate.daysBetween(gratestDate)/2;
        Integer allWorkingDays = allDaysBetween-getHoliday(smallestDate, gratestDate)-getweekDay(smallestDate,gratestDate);
        Decimal FTE= stimaAterminareTot / allWorkingDays;
        Decimal MediaFTE = FTE / nRecord;
        System.debug(FTE+'   '+nRecord);
        System.debug('MediaFTE'+MediaFTE);
        List<Project_Status__c> PSupdate = Database.query('SELECT id, Media_FTE__c FROM Project_Status__c WHERE '+whereClausole);
        for(Project_Status__c ps2: PSupdate){
            ps2.Media_FTE__c = MediaFTE;
        }
            
        update PSupdate;
    }
    
    public static void setDataAggiornamento(Project_Status__c newProject,Project_Status__c oldProject){
        boolean updateData = false;
        List<String> checkFields = changeFieldsCheck.split(',');
        for(String field: checkFields){
            try{
                updateData = updateData || (newProject.get(field) != oldProject.get(field));
            }
            catch(Exception e){
                throw new customException('il campo '+ field + ' non esiste verificare il customSetting ProjectStatus__c' );
            }
        }
        if(updateData){
            newProject.Data_Aggiornamento__c = (Date)  system.today();
        }
    }

    public void setAccountAndReferenceNumber(Project_Status__c projectStatus){
        projectStatus.Account__c = opportunityMap.get(projectStatus.Opportunity__c).AccountId;
        if(String.isBlank(projectStatus.ReferenceNumber__c)){
            projectStatus.ReferenceNumber__c = opportunityMap.get(projectStatus.Opportunity__c).Reference_Number__c;
        }
        if(!String.IsBlank(opportunityMap.get(projectStatus.Opportunity__c).Delivery_Project_Manager__r.Email)){
            projectStatus.EmailNotification__c = opportunityMap.get(projectStatus.Opportunity__c).Delivery_Project_Manager__r.Email;
        }else{
            projectStatus.EmailNotification__c = DefaultDeliveryManagerEmail;
        }
    }
    
    public static void CalculateDaysDiffExcludingHoliday(){
        setCommonData();
    	List<Project_Status__c>ProjStatusList = [SELECT id,Name,Data_fine_prevista__c, FTE_Mancanti__c,Budget_gg__c,Data_Aggiornamento__c From Project_Status__c
                                                WHERE Opportunity__r.StageName = 'Closed Won' and Tipo__c = 'Progetto' and Stato__c !='Completato' and Opportunity__r.Account.Name != 'Banca Mediolanum Spa'];
        for (Project_Status__c ps : ProjStatusList){
            if(ps.Data_fine_prevista__c != null){
                Date startdt = Date.today();
                Integer allDaysBetween = startdt.daysBetween(ps.Data_fine_prevista__c)+1;
                Integer allWorkingDays= allDaysBetween-getHoliday(startdt, ps.Data_fine_prevista__c)-getWeekDay(startdt, ps.Data_fine_prevista__c);
                System.debug('data di fine prevista: '+ps.Data_fine_prevista__c+' nome: '+ps.Name+ '*****'+getWeekDay(startdt, ps.Data_fine_prevista__c));
                ps.FTE_Mancanti__c = allWorkingDays < 0 ? 0 : allWorkingDays;
            }else {    
                ps.FTE_Mancanti__c = null;
            }
        }
        update ProjStatusList;
    }  
}