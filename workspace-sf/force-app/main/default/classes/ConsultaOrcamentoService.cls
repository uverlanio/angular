/*******************************************************************************************************************************
* Consulta dados de Orcamento
* @author Carlos - Meta
* @date 30/07/2020
* Classe criada por conta da história PLV-4204
******************************************************************************************************************************/
public with sharing class ConsultaOrcamentoService {
    private ConsultaOrcamentoREST.ConsultaParam param;

    public ConsultaOrcamentoService(ConsultaOrcamentoREST.ConsultaParam param) {
        this.param = param;
    }

    //PLV-4313 - INCIO
    public ConsultaOrcamentoREST.DataTO consultar(){
        ConsultaOrcamentoREST.DataTO resposta =  new ConsultaOrcamentoREST.DataTO();

        //PLV-4928 - INICIO
        String idCanal = param.idCanal;
        String canal = param.canal;
        
        String SOQL = 'SELECT Id, MeioComercializacao__c, Name, StageName, '
            + 'PremioTotal__c, Customizavel__c, Produto__r.Segmento__c, CreatedDate, '
            + 'Produto__c, '  //II-124 FIX01 INICIO/FIM 
            + 'Produto__r.Name, '  //PLV-4928 - FIX - INICIO
            + 'NomeOrcamento__c '  //PLV-4928 - FIX - FIM
            + 'FROM Opportunity WHERE CodigoCorretor__r.Name =: idCanal '
            + 'AND CanalDistribuicao__r.Name =: canal ' 
            + 'AND (Type = \'Seguro novo\' OR Type= \'Novo\') ';
            
        String SOQLOrderLimit = 'Order by CreatedDate DESC '
                             + 'LIMIT 1000';

        if(String.isNotBlank(this.param.nomeSegurado)){
            String nomeSegurado = '%' + this.param.nomeSegurado + '%';
            //PLV-4928 - FIX - INICIO
            SOQL += 'AND NomeOrcamento__c LIKE :nomeSegurado '; 
            //PLV-4928 - FIX - FIM
        }

        //II-124 FIX01 INICIO
        if(String.isNotBlank(param.codigoOferta)){
            String oferta = param.codigoOferta.toUpperCase();
            Set<String> ofertas = new Set<String>{oferta};
            List<Constante__mdt> produto = MetadataDAO.getInstance().buscarConstantes(ofertas);
            if (produto != null && !produto.isEmpty()) {
                String idProduto = produto[0].Valor__c;
                Set<String> idProdutoSet = new Set<String>(idProduto.split(','));
                SOQL += 'AND Produto__c IN : idProdutoSet ';
            }
        }
        //II-124 FIX01 FIM
        
        if(String.isNotBlank(this.param.numeroOrcamento)){
            String numeroOrcamento = this.param.numeroOrcamento;
            SOQL += 'AND Name =: numeroOrcamento ';  
        }
        
        if(String.isNotBlank(this.param.dataProposta)) {
            Date dataProposta = Date.parse(this.param.dataProposta);
            SOQL += 'AND DAY_ONLY(CreatedDate) =: dataProposta ';
        }
        
        SOQL += SOQLOrderLimit;
        
        resposta.orcamentos = this.atribuirModel(new Map<Id, Opportunity>((Opportunity[]) Database.query(SOQL)));
        //PLV-4928 - FIM
        resposta.statusChamada = 200;
        return resposta;
    }

    private List<ConsultaOrcamentoREST.ConsultaOrcamentoTO> atribuirModel(Map<Id, Opportunity> mapOrcamentos){

        List<ConsultaOrcamentoREST.ConsultaOrcamentoTO> retorno = new List<ConsultaOrcamentoREST.ConsultaOrcamentoTO>();
        Map<String, List<GarantiaOrcamento__c>> mapGarantias = new Map<String, List<GarantiaOrcamento__c>>();
        
        for(GarantiaOrcamento__c garantia : [
                SELECT Id, Orcamento__c, Capital__c, Garantia__r.Name, GarantiaProduto__r.OrdemPrioridade__c
                FROM GarantiaOrcamento__c WHERE Orcamento__c IN: mapOrcamentos.keySet()
        ]){

            List<GarantiaOrcamento__c> lsGarantiaOrcamento = mapGarantias.get(garantia.Orcamento__c);
            if(lsGarantiaOrcamento == null) lsGarantiaOrcamento = new List<GarantiaOrcamento__c>(); 
            lsGarantiaOrcamento.add(garantia);
            mapGarantias.put(garantia.Orcamento__c, lsGarantiaOrcamento);
        }

        for(Opportunity orcamento : mapOrcamentos.values()){
            ConsultaOrcamentoREST.ConsultaOrcamentoTO orcamentoModel = new ConsultaOrcamentoREST.ConsultaOrcamentoTO();
            orcamentoModel.meioComercializacao = orcamento.MeioComercializacao__c;
            orcamentoModel.orcamento = orcamento.Name;
            orcamentoModel.status = orcamento.StageName;
            orcamentoModel.premio = orcamento.PremioTotal__c;
            orcamentoModel.segmento = orcamento.Produto__r.Segmento__c; //PLV-4393 - Inicio-Fim
            orcamentoModel.produto = orcamento.Produto__r.Name;  //PLV-4928 - FIX - INICIO/FIM
            orcamentoModel.customizavel = orcamento.Customizavel__c; //PLV-4393 - Inicio-Fim
            orcamentoModel.dataCriacao = date.ValueOf(orcamento.CreatedDate).format();//PLV-4393 - Inicio-Fim
            orcamentoModel.garantias = new List<ConsultaOrcamentoREST.ConsultaOrcamentoGarantiaTO>();
            
            List<GarantiaOrcamento__c> lsGarantias = mapGarantias.get(orcamento.Id);
            if(lsGarantias == null) continue;
            for(GarantiaOrcamento__c garantia : lsGarantias){
                ConsultaOrcamentoREST.ConsultaOrcamentoGarantiaTO garantiaTO = new ConsultaOrcamentoREST.ConsultaOrcamentoGarantiaTO();
                garantiaTO.nome = garantia.Garantia__r.Name;
                garantiaTO.ordemPrioridade = garantia.GarantiaProduto__r.OrdemPrioridade__c;
                garantiaTo.capital = garantia.Capital__c;
                orcamentoModel.garantias.add(garantiaTO);
            }

            //PLV-4928 - INICIO
            orcamentoModel.nomeCliente = orcamento.NomeOrcamento__c; //PLV-4928 - FIX - INICIO/FIM
            //PLV-4928 - FIM
           
            retorno.add(orcamentoModel); //PLV-4393 - Inicio-Fim
        }
        return retorno;
    }
    //PLV-4313 - FIM
}