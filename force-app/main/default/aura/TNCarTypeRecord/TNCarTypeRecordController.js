({
    doInit : function(component, event, helper) {
        //TO DO
    },
	handleTNRefreshEvent: function(component, event) {
		let carType = event.getParam("carType");
		component.set('v.carId', carType.Id);
	}
})