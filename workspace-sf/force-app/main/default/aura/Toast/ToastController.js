({
	handleChange : function(component, event, helper) {

		//var options = ['info', 'success', 'warning', 'error'];
		var messages = component.get('v.messages');
		var duration = component.get('v.duration');
		//console.log('ToasController.handleChange:messages',messages);

		if ($A.util.isEmpty(messages) ||
			(messages.info.length == 0 && messages.success.length == 0 && messages.warning.length == 0 && messages.error.length == 0))
			return;
		
		if (duration > 0) {

			window.setTimeout(
		        $A.getCallback(function() {
		            //console.log('ToasController.handleChange:messages callback',messages);
		            if(component.isValid()){

		                messages.info.length = 0;
						messages.success.length = 0;
						messages.warning.length = 0;
						messages.error.length = 0;
						component.set('v.messages', messages);
		            }
		            else{
		                console.log('Component is Invalid');
		            }
		        }), duration
		    );
		}
	},

	doClose : function(component, event, helper) {

		var messageId = event.target.id;
		var messages = component.get('v.messages');
		console.log('ToasController.doClose:messages',messages);

		switch (messageId) {

			case 'success': messages.success.length = 0; break;
			case 'error': messages.error.length = 0; break;
			case 'info': messages.info.length = 0; break;
			case 'warning': messages.warning.length = 0; break;
		}
		component.set('v.messages', messages);
	}
})