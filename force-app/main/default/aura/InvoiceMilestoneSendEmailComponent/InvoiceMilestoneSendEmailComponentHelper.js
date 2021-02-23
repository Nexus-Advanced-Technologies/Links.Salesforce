({
    showToast: function (choosenTitle, choosenMessage, choosenToastType) {
        //This method displays a toast of success or error, based on the positive/negative Quote cloning
        //displays success or error messages
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            title: choosenTitle,
            message: choosenMessage,
            type: choosenToastType
        });
        toastEvent.fire();

    }
});