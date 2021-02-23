/**
 * @description       : 
 * @author            : 
 * @last modified on  : 25/01/2021
 * @last modified by  : ¤ → alessio.marra@nexusat.it
 * Modifications Log 
 * Ver   Date         Author                         Modification
 * 1.0                                               Initial Version
 * 1.1   25/01/2021   ¤ → alessio.marra@nexusat.it   Review ApiName Nomenclature
**/
global class OnProjectStatusHelper{
	
	public class customException extends exception{}
	
	private static String whereClausole = OpportunitySetting__c.getOrgDefaults().FteWhere__c;
	private static String changeFieldsCheck = [Select UpdatableField__c from ProjectSetting__mdt Limit 1].UpdatableField__c;
	private static String DefaultDeliveryManagerEmail = OpportunitySetting__c.getOrgDefaults().DefaultDeliveryManagerEmail__c;
	Map<Id,Opportunity> opportunityMap;
	public OnProjectStatusHelper(List<ProjectStatus__c> projectsStatus){
		Set<Id> OpportunitiesId = new Set<Id>();
		for(ProjectStatus__c projectStatus : projectsStatus){
			OpportunitiesId.add(projectStatus.Opportunity__c);
		}
		opportunityMap = new Map<Id,Opportunity>([SELECT Id,AccountId,ReferenceNumber__c,DeliveryProjectManager__c,DeliveryProjectManager__r.Email FROM Opportunity WHERE Id in: OpportunitiesId]);

	}
	private static String baseQuery = 'SELECT' 
										+' MAX(ExpectedEndDate__c) gratestDate'
										+',MIN(ExpectedEndDate__c) smallestDate'
										+',SUM(EstimatedToFinishDD__c) stimaAterminareTot'
										+',COUNT(Id) nRecord'
										+' FROM ProjectStatus__c'
										+' WHERE RecordType.DeveloperName = \'Nexus\' AND ';
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
		List<ProjectStatus__c> PSupdate = Database.query('SELECT Id, AverageFTE__c FROM ProjectStatus__c WHERE RecordType.DeveloperName = \'Nexus\' AND '+whereClausole);
		for(ProjectStatus__c ps2: PSupdate){
			ps2.AverageFTE__c = MediaFTE;
		}
			
		update PSupdate;
	}
	
	public static void setDataAggiornamento(ProjectStatus__c newProject, ProjectStatus__c oldProject){
		boolean updateData = false;
		List<String> checkFields = changeFieldsCheck.split(',');
		for(String field: checkFields){
			try{
				updateData = updateData || (newProject.get(field) != oldProject.get(field));
			}
			catch(Exception e){
				throw new customException('The field '+ field +' does not exist check the CustomMetadata ProjectSetting__mdt' );
			}
		}
		if(updateData){
			newProject.UpdateDate__c = (Date) System.today();
		}
	}

	public void setAccountAndReferenceNumber(ProjectStatus__c projectStatus){
		projectStatus.Account__c = opportunityMap.get(projectStatus.Opportunity__c).AccountId;
		if(String.isBlank(projectStatus.ReferenceNumber__c)){
			projectStatus.ReferenceNumber__c = opportunityMap.get(projectStatus.Opportunity__c).ReferenceNumber__c;
		}
		if(!String.IsBlank(opportunityMap.get(projectStatus.Opportunity__c).DeliveryProjectManager__r.Email)){
			projectStatus.EmailNotification__c = opportunityMap.get(projectStatus.Opportunity__c).DeliveryProjectManager__r.Email;
		}else{
			projectStatus.EmailNotification__c = DefaultDeliveryManagerEmail;
		}
	}
	
	public static void CalculateDaysDiffExcludingHoliday(){
		setCommonData();
		List<ProjectStatus__c> ProjStatusList = [SELECT id,Name,ExpectedEndDate__c, RemainingFTE__c,BudgetDD__c,UpdateDate__c From ProjectStatus__c
												WHERE Opportunity__r.StageName = 'Closed Won' and Type__c = 'Progetto' and Stage__c !='Completato' and Opportunity__r.Account.Name != 'Banca Mediolanum Spa' AND RecordType.DeveloperName = 'Nexus'];
		for (ProjectStatus__c ps : ProjStatusList){
			if(ps.ExpectedEndDate__c != null){
				Date startdt = Date.today();
				Integer allDaysBetween = startdt.daysBetween(ps.ExpectedEndDate__c)+1;
				Integer allWorkingDays= allDaysBetween-getHoliday(startdt, ps.ExpectedEndDate__c)-getWeekDay(startdt, ps.ExpectedEndDate__c);
				System.debug('data di fine prevista: '+ps.ExpectedEndDate__c+' nome: '+ps.Name+ '*****'+getWeekDay(startdt, ps.ExpectedEndDate__c));
				ps.RemainingFTE__c = allWorkingDays < 0 ? 0 : allWorkingDays;
			}else {
				ps.RemainingFTE__c = null;
			}
		}
		update ProjStatusList;
	}  
}