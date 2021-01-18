global class OnProjectStatusSchedulable implements Schedulable {
	global void execute(SchedulableContext ctx) {
          OnProjectStatusHelper.CalculateDaysDiffExcludingHoliday();
          OnProjectStatusHelper.CalculateTotalFTE();
       
	}
}