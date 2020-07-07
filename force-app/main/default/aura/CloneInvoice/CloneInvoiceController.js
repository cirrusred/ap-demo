({
	myAction : function(cmp, event, helper) {
		this.toggle(cmp, event);
        
	},
    
    toggle: function (cmp, event) {
        var spinner = cmp.find("mySpinner");
        $A.util.toggleClass(spinner, "slds-hide");
    }
})