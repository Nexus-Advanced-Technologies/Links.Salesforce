/**
 * @description       : 
 * @author            : ¤ → alessio.marra@nexusat.it
 * @last modified on  : 03/01/2023
 * @last modified by  : ¤ → alessio.marra@nexusat.it
**/
public class CreatePaymentTypeDetailController {
	
	@AuraEnabled
	public static Integer getMaxRankPaymentType(String paymentTypeId) {
		System.debug('¤ paymentTypeId: ' + paymentTypeId);
		
		AggregateResult[] aggrs = [
				SELECT PaymentType__c
						,MAX(Rank__c) max
				FROM PaymentTypeDetail__c
				WHERE PaymentType__c = :paymentTypeId
				GROUP BY PaymentType__c];
		if (aggrs.isEmpty()) {
			return 0;
		} else {
			return Integer.valueOf(aggrs[0].get('max'));
		}
	}
}