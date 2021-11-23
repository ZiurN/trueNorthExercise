({
	handleTNRefreshEvent: function(component, event) {
		let carType = event.getParam("carType");
		component.set('v.carId', carType.Id);
		component.set('v.carType', carType);
		component.set('v.carSelected', true);
		const action = component.get("c.getSalesDataFromCarType");
		action.setParams({
			'Id' : carType.Id
		});
		action.setCallback(this, resp => {
			if (resp.getState() === "SUCCESS") {
				const response =  resp.getReturnValue();
				if (!response.error) {
					component.set('v.dataFromCarType', response);
				} else {
					component.set('v.dataFromCarType', {});
					$A.get("e.force:showToast").setParams({
						"title": response.auraMessage.title,
						"type": response.auraMessage.status,
						"message": response.auraMessage.message
					}).fire();
				}
			} else {
				console.error(response.getError());
			}
		});
		$A.enqueueAction(action);
	}
})
