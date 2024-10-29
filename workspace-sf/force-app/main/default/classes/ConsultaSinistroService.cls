/*******************************************************************************************************************************
* Consulta dados Básicos de Apólice/Contrato
* @author Gabriel Roetger- Globant
* @date 20/07/2020
* Classe criada por conta da história PLV-3967 / PLV-4525
******************************************************************************************************************************/
public class ConsultaSinistroService {
    private String numApolice {get;set;}
    private String numSinistro {get;set;}

    public ConsultaSinistroService(String numApolice, String numSinistro){
        this.numApolice = numApolice;
        this.numSinistro = numSinistro;
    }

    public ConsultaSinistroRest.Response getSinistros(){
        ConsultaSinistroRest.Response response = new ConsultaSinistroRest.Response();

        Map<Id, Case> mapCase = this.getMapCase();
        
        if(mapCase.isEmpty()) return response;
        Map<Id, List<BeneficiarioGarantia__c>> lstBeneficiarios = this.getBeneficiarios(mapCase.keySet());
        
        for (String key : mapCase.keySet()) {
            Case cs = mapCase.get(key);
            List<ConsultaSinistroRest.GarantiaDoSinistro> garantias = new List<ConsultaSinistroRest.GarantiaDoSinistro>();

            for(PagamentoGarantia__c rawGarantia : cs.Pagamentos_de_garantia__r) {
                garantias.add(new ConsultaSinistroRest.GarantiaDoSinistro(rawGarantia, lstBeneficiarios.get(rawGarantia.id)));
            }

            response.data.add(new ConsultaSinistroRest.Sinistro(mapCase.get(key),!garantias.isEmpty()? garantias : null));
        }
        response.meta.error = null;
        return response;
    }
    
    private Map<Id, Case> getMapCase(){
		System.debug('has args: '+ !(this.numApolice == null && this.numSinistro == null));
        if(this.numApolice == null && this.numSinistro == null) return new Map<Id, Case>();

        String paramType = 'Sinistro';
        String soql = 'SELECT NumeroSinistro__c, Contact.Name,'
                    + 'CreatedDate, Status, Status_Dependente__c,'
                    + 'Contrato__r.ContractNumber, Dataocorrencia__c,'
                    + '(SELECT CommentBody, CreatedDate FROM CaseComments  ORDER BY CreatedDate ASC), '
                    + '(SELECT ID, QuantidadeDias__c, Name, Capital__c, Caso__c, FranquiaContrato__c,Franquias__c FROM Pagamentos_de_garantia__r)'
                    + ' FROM Case'
                    + ' WHERE  Contrato__c != null'
                    + ' AND NumeroSinistro__c != null'
                    + ' AND Type = :paramType';
                    
        if(this.numApolice  != null){
            String paramNumApolice = this.numApolice;
            soql += ' AND Contrato__r.IdExterno__c = :paramNumApolice';
        }

        if(this.numSinistro != null){
            String paramNumSinistro = this.numSinistro;
            soql += ' AND NumeroSinistro__c =: paramNumSinistro';
        }

        soql += ' ORDER BY CreatedDate ASC';
        
        Case[] lsResult = Database.query(soql);

        return lsResult.isEmpty() ? new Map<Id, Case>() : new Map<Id, Case>(lsResult);

    }
    
    @testVisible
    private Map<Id, List<BeneficiarioGarantia__c>> getBeneficiarios(Set<Id> setCaseId){
        Map<Id, List<BeneficiarioGarantia__c>> response = new Map<Id, List<BeneficiarioGarantia__c>>();
        if(setCaseId.isEmpty()){
            return response;
        } 

        List<BeneficiarioGarantia__c> lstBeneficiarios = [
            SELECT                  
                Conta__r.Name,
                Pagamento_de_garantia__c,
                Percentual_de_indenizacao__c,
                Tipo_de_Pagamento__c,
                Data_programada_do_pagamento__c,
                DataPagamento__c,
                ValorPago__c,
                Sucursal_Destino_de_Cheque__c,
                Pagamento_de_Sinistro__r.Dados_Bancarios__r.Agencia__c,
                Pagamento_de_Sinistro__r.Dados_Bancarios__r.Banco__c,
                Pagamento_de_Sinistro__r.Dados_Bancarios__r.Digito__c,                
                Pagamento_de_Sinistro__r.Dados_Bancarios__r.NumeroConta__c,
                Pagamento_de_Sinistro__r.Dados_Bancarios__r.Papel__c,
                Pagamento_de_Sinistro__r.Valor_total_a_ser_indenizado__c,
                Pagamento_de_Sinistro__r.Tipo_de_Pagamento__c, 
                Pagamento_de_Sinistro__r.Sucursal_Destino_de_Cheque__c,                 
                Pagamento_de_Sinistro__r.Data_Programada_de_Pagamento__c, 
                Pagamento_de_Sinistro__r.Data_de_pagamento__c                 
            FROM BeneficiarioGarantia__c
            WHERE Pagamento_de_garantia__r.caso__c IN :setCaseId
            ORDER BY CreatedDate ASC
       ];
       
       for (BeneficiarioGarantia__c rawBeneficiario : lstBeneficiarios) {
            String key = rawBeneficiario.Pagamento_de_garantia__c;

            if(!response.containsKey(key)){
                response.put(key, new List<BeneficiarioGarantia__c>());
            }
            response.get(key).add(rawBeneficiario);
        }
        return response;
    }
}