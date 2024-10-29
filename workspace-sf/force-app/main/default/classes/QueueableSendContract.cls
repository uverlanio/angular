/*******************************************************************************************************************************
* Emissão de contratos por controle de fila
* @author Isabela/Pedro - Globant
* @Date 02/03/2020
* @ModifiedAt 02/03/2020
* Classe criada por conta da história PLV-3460
******************************************************************************************************************************/
public class QueueableSendContract implements Queueable, Database.AllowsCallouts {
    final List<Contract> newList;
    final Integer qtdRegistrosPorFila;
    public QueueableSendContract(List<Contract> newList, Integer qtdReg) {
        Debug.getInstance().setStart().log(new Map<Object, Object> { 'newList' => newList, 'qtdReg' => qtdReg }); // LECVP-69 - Inicio/Fim
        this.newList = newList;
        this.qtdRegistrosPorFila = qtdReg;
        Debug.getInstance().end(); // LECVP-69 - Inicio/Fim
    }
    public void execute(QueueableContext context) {
        Debug.getInstance().start(); // LECVP-69 - Inicio/Fim
        List<ServiceTO.ContratoTO> listContratoTO = new List<ServiceTO.ContratoTO>();
        List<Contract> contratosAtualizarHeroku = new List<Contract>();
        Set<Id> IdcontratosAtualizarHeroku = new Set<Id>();
        Set<Id> setContratosEmitidos = new Set<Id>();
       	List<Contract> listContratosAtuais = new List<Contract>();
        Integer i = 0;
        
        while(i<this.newList.size() && i<this.qtdRegistrosPorFila){
			listContratosAtuais.add(this.newList[0]);
			this.newList.remove(0);
            i++;
        }
        Debug.getInstance().log('Contratos selecionados para processamento', listContratosAtuais); // LECVP-69 - Inicio/Fim
        
        for(Contract contratoEmitido : listContratosAtuais){
			setContratosEmitidos.add(contratoEmitido.Id);
            
            Debug.getInstance().log( // LECVP-69 - Inicio
                new Map<Object, Object> {
                    'Contrato emitido' => contratoEmitido,
                    'Endosso existe?' => contratoEmitido?.TipoEndosso__c != null,
                    'Endosso igual INA?' => contratoEmitido?.TipoEndosso__c == 'INA',
                    'Contrato do endosso preenchido?' => contratoEmitido?.Proposta__r?.ContractId != null
                }
            ); // LECVP-69 - Fim
            if(contratoEmitido.TipoEndosso__c != null &&  contratoEmitido.TipoEndosso__c == 'INA'){
                if(contratoEmitido.Proposta__r.ContractId != null){
                    Id contratoOriginalId = contratoEmitido.Proposta__r.ContractId;
                    IdcontratosAtualizarHeroku.add(contratoOriginalId);
                }
            }
            // if(contratoEmitido.StatusHeroku__c != null && contratoEmitido.StatusHeroku__c == 'Aguardando Processamento'){
            //     contratosAtualizarHeroku.add(contratoEmitido);
            // }
        }
        Debug.getInstance().log('Contratos selecionados para atualizar heroku', IdcontratosAtualizarHeroku); // LECVP-69 - Inicio/Fim
        if(IdcontratosAtualizarHeroku.size() > 0){
            contratosAtualizarHeroku = [SELECT Id, StatusHeroku__c FROM Contract WHERE Id IN :IdcontratosAtualizarHeroku];
        }
        //System.debug('contratosAtualizarHeroku> ' + JSON.serializePretty(contratosAtualizarHeroku)); // LECVP-69 - Inicio
        //System.debug('setContratosEmitidos> ' + JSON.serializePretty(setContratosEmitidos)); // LECVP-69 - Fim
        //PLV-3393 - INICIO/FIM - Integração BCP --- Trecho de código reposicionado para o fim da classe
       	Map<Id, Contract> mapContratos = new Map<Id, Contract>([SELECT Id, NumeroApolice__c, Proposta__r.NumeroProposta__c FROM Contract WHERE Id IN :setContratosEmitidos]);
        Debug.getInstance().log('Contratos mapeados', mapContratos); // LECVP-69 - Inicio/Fim
		Map<String, String> mapPropostaApolice = new Map<String, String>();
		for(Contract contrato : listContratosAtuais){
            Debug.getInstance().log(new Map<Object, Object> { // LECVP-69 - Inicio
                'Contratos interado' => contrato.Id,
                'Número da proposta' => mapContratos.get(contrato.Id)?.Proposta__r?.NumeroProposta__c,
                'Número da apolice' => mapContratos.get(contrato.Id)?.NumeroApolice__c
            }); // LECVP-69 - Fim
            mapPropostaApolice.put(mapContratos.get(contrato.Id).Proposta__r.NumeroProposta__c, mapContratos.get(contrato.Id).NumeroApolice__c);
        }
        try{
            new QuoteBO().chamarCIVEmissao(setContratosEmitidos, mapPropostaApolice);//PLV-4539            
          
        }catch (Exception e){
            Debug.getInstance().log(e);
        }
		
        if(this.newList.size() > 0 && !Test.isRunningTest()){
            System.debug('reprocessar');
        	System.enqueueJob(new QueueableSendContract(this.newList, this.qtdRegistrosPorFila));
        }

        //PLV-3393 - INICIO - Integração BCP
        //As chamadas de métodos abaixo devem ser mantidas depois da chamada para o CIV pois contém operações DML
        if (!Test.isRunningTest()) ContractBO.getInstance().executarRegrasLog(listContratosAtuais);
        ContractBO.getInstance().criarApolice(listContratosAtuais);
        
        ContractBO.getInstance().criarEndosso(listContratosAtuais);//plv - 4014 inicio/fim
        //PLV-3990 - INICIO - Alteração nome do metodo
        ContractBO.getInstance().criarControlesIntegracao(listContratosAtuais);
        //PLV-3990 - FIM
        //PLV-3393 - FIM - Integração BCP

        if(contratosAtualizarHeroku.size() > 0){

            ApoliceInadimplenciaREST.Response response = new ApoliceInadimplenciaREST.Response();

            for(Contract contrato : contratosAtualizarHeroku){
                contrato.StatusHeroku__c = 'Processado';
                ApoliceInadimplenciaREST.ItemResponse item = new ApoliceInadimplenciaREST.ItemResponse();
                system.debug('contrato> ' + JSON.serializePretty(contrato));
                item.id = String.valueOf(contrato.Id);
                item.contrato = contrato.name;
                item.sucesso = true;
                response.itens.add(item);

            }
            TriggerHandler.bypass('ContractTriggerHandler');
            update contratosAtualizarHeroku;
            TriggerHandler.clearBypass('ContractTriggerHandler');
            //HerokuService.getInstance().atualizarStatusApolice(JSON.serialize(response));
        }
        Debug.getInstance().end(); // LECVP-69 - Inicio/Fim
	}
    public class QueueableSendContractException extends Exception{}

}