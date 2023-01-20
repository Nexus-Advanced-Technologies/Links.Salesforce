/**
 * @description       : 
 * @author            : mattia.miglietta@nexusat.it
 * @last modified on  : 20/01/2023
 * @last modified by  : ¤ → alessio.marra@nexusat.it
**/
({
    init : function(cmp, event, helper) {
        const pageReference = cmp.get("v.pageReference");
        console.log(JSON.parse(JSON.stringify(pageReference)));

        cmp.set("v.recordTypeId", pageReference.state.recordTypeId);

        var state = pageReference.state; // state holds any query params
        var base64Context = state.inContextOfRef;

        // For some reason, the string starts with "1.", if somebody knows why,
        // this solution could be better generalized.
        if (base64Context.startsWith("1\.")) {
            base64Context = base64Context.substring(2);
        }
        var addressableContext = JSON.parse(window.atob(base64Context));
        console.log(JSON.parse(JSON.stringify(addressableContext.attributes)));
        cmp.set("v.recordId", addressableContext.attributes.recordId);
    }
})