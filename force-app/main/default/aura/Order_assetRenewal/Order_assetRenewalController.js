({
    RunRenewAsset : function(component, event, helper) {
        
        
        var action = component.get("c.RenewAssets");
     
        console.log('IN Asset');
        action.setCallback(this, function(response) {
            var state = response.getState();
            console.log(state);
            if (state === "SUCCESS") {
                console.log('IN SUCCESS');
       		    	window.location.assign("/");
            }
            else if (state === "INCOMPLETE") {
                
            }
                else if (state === "ERROR") {
                     
                    var errors = response.getError();
                    if (errors) {
                        if (errors[0] && errors[0].message) {
                            console.log("Error message: " + errors[0].message);
                            alert("Error message: " + errors[0].message);
                        }
                    } else {
                        console.log("Unknown error");
                    }
                }
        });
        
        
        $A.enqueueAction(action);
    }
})