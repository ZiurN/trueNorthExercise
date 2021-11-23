({
	 doInit : function(component, event, helper) {
        const action = component.get("c.getCarTypes");
		action.setCallback(this, response => {
			if (response.getState() === "SUCCESS") {
				component.set('v.carTypeList', response.getReturnValue());
			} else {
				console.error(response.getError());
			}
		});
		$A.enqueueAction(action);
    },
    handleClick : function (component, event, helper) {
		let carTypes = component.get('v.carTypeList');
		let selectedId = event.getSource().get('v.value');
		let carType = carTypes.filter(carType => carType.Id == selectedId);
		let appEvent = $A.get("e.c:TNRefreshEvent");
        appEvent.setParams({
            "message" : "Event Fired",
			'carType': carType[0]
		 });
        appEvent.fire();
    }
})