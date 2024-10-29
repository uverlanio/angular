({
		pesquisaGarantias : function(component, event, helper, queryTerm) {
			
			var recId = component.get('v.recordId');

			var action = component.get('c.pesquisaGarantiaSegContrato');

			action.setParams({recordId: recId,term: queryTerm});

			action.setCallback(this, function(response){
				var state = response.getState();

				if(state === 'SUCCESS'){
					var ret = response.getReturnValue();

					if(ret == 'Sem segurado'){
						component.set("v.semsegurado", 'Favor informar um Segurado no caso de Sinistro para que a busca seja realizada.');
						component.set("v.data", null);
                    }else if(ret == 'Sem garantia'){
						component.set("v.semgarantias", 'Garantia informada não encontrada na Apólice.');
						component.set("v.data", null);
                    }else{
						var rows = JSON.parse(ret);
						/*rows.forEach(function(record){
							record.linkName = '/'+record.Id;
							record.linkName2 = '/'+recId;
						});*/
                        for(var i = 0; i < rows.length; i++){
                            var row = rows[i];
                            if(row.Garantia__r) row.Garantia = row.Garantia__r.Name;
                        }
                        component.set("v.data", rows);
                        component.set("v.semsegurado", null);
                        component.set("v.semgarantias", null);
						//component.set("v.garantias", jsonObject);
					}
				} else{
					console.log('Error, response state: ' + state);
				}
			});
			$A.enqueueAction(action);
		},

		updatePag : function(component, event, helper, record){

			var recId = component.get('v.recordId');
			var rec = JSON.stringify(record);
			console.log(recId);
			console.log(record);
			var action = component.get('c.updatePagamentoGarantia');

			action.setParams({recordId: recId, garanSeg: rec});

			console.log(action);
			action.setCallback(this, function(response){

				var state = response.getState();
				console.log(state);
				if(state === 'SUCCESS'){
					
					var resultsToast = $A.get("e.force:showToast");
                	resultsToast.setParams({
                    	/*'title': title,*/
                    	'type' : 'success',
                    	'message': 'Pagamento de garantia "'+component.get("v.nomepag")+'" foi salvo(a).'
					});
					
					$A.get("e.force:closeQuickAction").fire();
					$A.get("e.force:refreshView").fire();
					resultsToast.fire();

				} else{
					console.log('Error, response state: ' + state);
				}
			});
			$A.enqueueAction(action);
		},

		buscaNomePagamentoGarantia : function(component, event, helper){

			var recId = component.get('v.recordId');

			var action = component.get('c.buscaNomePagamentoGarantia');

			action.setParams({recordId: recId});

			action.setCallback(this, function(response){

				var state = response.getState();

				if(state === 'SUCCESS'){
					var ret = response.getReturnValue();

					component.set("v.nomepag", ret);
				}else{
					console.log('Error, response state: ' + state);
				}
			});
			$A.enqueueAction(action);
		}

})