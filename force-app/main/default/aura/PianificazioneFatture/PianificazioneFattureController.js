/**
 * @description       : 
 * @author            : 
 * @last modified on  : 04/02/2021
 * @last modified by  : ¤ → alessio.marra@nexusat.it
**/
({
	doInit : function(component, event, helper) {
		var url = window.location.protocol + "//" + window.location.host;
		var message = "";
		//Action that initialized the date
		var oppId = component.get("v.recordId");
		var initOppField = component.get("c.createInvoiceMilestone");
		initOppField.setParams({
			recordId: oppId
		});
		initOppField.setCallback(this, function (response){ 
			var resp = response.getReturnValue();
			if(resp == true) {
				message += $A.get("$Label.c.NexusInvoiceMilestonSuccess");
			}else{
				message += $A.get("$Label.c.NexusInvoiceMilestonError");
			}
		  helper.showToast(component,event,helper,message,resp,oppId,url);
		});
		$A.enqueueAction(initOppField); 
	}
})