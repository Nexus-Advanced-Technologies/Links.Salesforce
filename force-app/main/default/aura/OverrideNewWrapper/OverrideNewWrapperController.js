/**
 * @description       : 
 * @author            : ¤ → alessio.marra@nexusat.it
 * @last modified on  : 02/01/2023
 * @last modified by  : ¤ → alessio.marra@nexusat.it
**/
({
	doInit: function(cmp, event, helper) {
		const pageReference = cmp.get("v.pageReference");
		console.log(JSON.parse(JSON.stringify(pageReference)));
		
		cmp.set("v.recordTypeId", pageReference.state.recordTypeId);
		cmp.set("v.additionalParams", pageReference.state.additionalParams);
	},
	
	handleClose: function (cmp, event, helper) {
		$A.get("e.force:closeQuickAction").fire();
	}
})