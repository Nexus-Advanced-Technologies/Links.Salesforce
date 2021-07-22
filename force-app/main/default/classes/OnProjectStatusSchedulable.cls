/**
 * @description       : 
 * @author            : 
 * @last modified on  : 29/01/2021
 * @last modified by  : ¤ → alessio.marra@nexusat.it
 * Modifications Log 
 * Ver   Date         Author                         Modification
 * 1.0                                               Initial Version
 * 1.1   25/01/2021   ¤ → alessio.marra@nexusat.it   Review ApiName Nomenclature
**/
global class OnProjectStatusSchedulable implements Schedulable {
	global void execute(SchedulableContext ctx) {
		//OnProjectStatusHelper.CalculateDaysDiffExcludingHoliday();
		OnProjectStatusHelper.CalculateTotalFTE();
	}
}