/**
 * Created by Alessandro Ponte on 25/10/2018.
 */
({
    aprovarProduto : function(component,event) {
        let action = component.get('c.aprovarProduto');

        action.setParams({
            idProduto : component.get('v.recordId')
        });

        action.setCallback(this, function(response){

            let state = response.getState();
            console.log(state);
            if(state === 'SUCCESS'){
                component.find("cmpModalAcaoBotao").callback(response);
            }else{
                var errors = response.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        console.log("Error message: " +
                            errors[0].message);
                    }
                } else {
                    console.log("Unknown error");
                }
            }
        });

        $A.enqueueAction(action);
    }
})