/**
 * Created by Alessandro Ponte on 12/06/2019.
 */

// PLV-2312-28 INICIO
public with sharing class AtualizarSistemasExternosBatch implements Database.Batchable<sObject>,Database.AllowsCallouts,Database.Stateful{

    private Integer contador;
    private static final Integer MAXIMO_TENTATIVAS = 1;


    public AtualizarSistemasExternosBatch(Integer contador){
        this.contador = contador;
    }

    public Database.QueryLocator start(Database.BatchableContext job){

        ServiceTO.ControleBatchTO controleBatchTO = new ServiceTO.ControleBatchTO();
        controleBatchTO.idjob = String.valueOf(job.getJobId());
        controleBatchTO.servico = 'contratos/processar-propostas-massificados';

        System.debug('ATUALIZAR SISTEMAS EXTERNOS BATCH EM EXECUCAO COM O ID ' + job.getJobId());

        // Verifica se atualizou o controle batch
        try{
            HerokuService.getInstance().atualizarIdJobControleBatch(controleBatchTO);
        }catch (Exception e){
            System.debug('ERRO NO INICIO DO BATCH DE ATUALIZACAO DOS SISTEMAS EXTERNOS: ' + e.getMessage() + ' LINHA: ' + e.getLineNumber());
            // Aborta o processamento do Batch em caso de erro na atualizacao
            System.abortJob(job.getJobId());
        }

        // Busco os contratos ativos com Garantia da Capitalização
        Database.QueryLocator retorno = Database.getQueryLocator([
                SELECT
                        Id,
                        Parceiro__c,
                        AccountId,
                        Account.Name,
                        Account.IdExterno__c,
                        Empresa__c,
                        Sucursal__c,
                        RamoSeguro__r.Codigo__c,
                        RamoSeguro__c,
                        Name,
                        Endosso__c,
                        IdContrato__c,
                        IdContratoParceiro__c,
                        CodigoRamo__c,
                        NumeroApolice__c,
                        Tipo__c,
                        Status,
                        StartDate,
                        VigenciaFinal__c,
                        CanalDistribuicao__r.Sigla__c,
                        CodigoCorretor__r.Name,
                        TipoEndosso__c,
                        DataEmissao__c,
                        MeioComercializacao__c,
                        Produto__c,
                        Produto__r.ProductCode,
                        Proposta__c,
                        Proposta__r.Id,
                        Proposta__r.Name,
                        Proposta__r.NumeroProposta__c,
                        Proposta__r.Origem__c,
                        Proposta__r.Status,
                        Proposta__r.Produto__c,
                        Proposta__r.Produto__r.ProductCode,
                        Proposta__r.Produto__r.Name,
                        Proposta__r.OpportunityId,
                        Proposta__r.Opportunity.Id,
                        Proposta__r.Opportunity.StageName,
                        Proposta__r.Opportunity.Numero__c,
                        Proposta__r.Opportunity.Name,
                        Proposta__r.Opportunity.MeioComercializacao__c,
                (
                        SELECT
                                Id,
                                QuantidadeParcelas__c,
                                PremioTotal__c,
                                VencimentoPrimeiraParcela__c,
                                ResponsavelPagamento__c,
                                TipoResponsavelPagamento__c,
                                Conta__c,
                                PremioComercial__c,
                                PremioPuro__c,
                                TaxaComercial__c,
                                TaxaPura__c,
                                IOF__c
                        FROM
                                ContratantesContrato__r
                ),
                (
                        SELECT
                                id,
                                Capital__c,
                                GarantiaProduto__c,
                                Garantia__c,
                                Garantia__r.Sigla__c,
                                LimiteCapital__c,
                                NumeroSerie__c,
                                NumeroSorte__c,
                                Percentual__c,
                                TipoCapital__c,
                                TipoDescontoAgravo__c,
                                PremioComercial__c,
                                PremioPuro__c,
                                PremioTotal__c,
                                CurrencyIsoCode, //PLV-3884 - INICIO/FIM - Retornando o campo de moeda para referencia
                                TaxaComercial__c,
                                TaxaPura__c,
                                TaxaTotal__c,
                                DescontoAgravoMonetarioComercial__c,
                                DescontoAgravoMonetarioInformado__c,
                                DescontoAgravoMonetarioTecnico__c,
                                DescontoAgravoPercentualComercial__c,
                                DescontoAgravoPercentualInformado__c,
                                DescontoAgravoPercentualTecnico__c
                        FROM
                                GarantiasContrato__r
                )
                FROM
                        Contract
                WHERE
                        Status = 'Em elaboração'
                // CHAMADO CH-5031619  INICIO
                // AND 
                //         Massificados__c = true
                // CHAMADO CH-5031619  FIM
        ]);

        return retorno;
    }

    public void execute(Database.BatchableContext jobId, List<Contract> listContrato){
        System.debug('EXECUCAO DA ATUALIZACAO DE SISTEMAS EXTERNOS PARA ' + listContrato.size() + ' contratos.');
        // Notificar os sistemas externos para todos os lotes
        new QuoteBO().atualizarSistemaExterno(listContrato);//PLV-4539 

    }

    public void finish(Database.BatchableContext jobId){
        System.debug('FIM DA EXECUCAO DA ATUALIZACAO DE SISTEMAS EXTERNOS DE TODOS OS LOTES');

        // Verifica se existem contratos de massificados em elaboracao
        Boolean temContratos = ContractBO.getInstance().verificarContratosMassificados();
        // Verifica se o retry ja chegou no limite de tentativas
        if(temContratos && contador < MAXIMO_TENTATIVAS){
            System.debug('PRÓXIMA TENTATIVA ' + contador++);
            Id jobBatchId = Database.executeBatch(new AtualizarSistemasExternosBatch(this.contador++), 12);
        }else {
            ServiceTO.ControleBatchTO controleBatchTO = new ServiceTO.ControleBatchTO();
            controleBatchTO.servico = 'contratos/processar-propostas-massificados';

            // Libera o controle batch do Heroku
            HerokuService.getInstance().encerrarServicoControleBatch(controleBatchTO);
        }
    }

}

// PLV-2312-28 FIM