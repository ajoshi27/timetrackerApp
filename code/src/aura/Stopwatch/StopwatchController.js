({
	doInit : function(component, event, helper) {
		helper.loadTimeEntry(component,event,helper);
	},
    doScriptLoad : function(component, event, helper) {

	},
    onClick : function(component, event, helper) {
       helper.setTimer(component,event,helper);
	}
})