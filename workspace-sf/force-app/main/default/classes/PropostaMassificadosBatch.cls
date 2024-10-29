/**
 * Created by Alessandro Ponte on 06/06/2019.
 */

// PLV-2312-28 INICIO
// TODO: BATCH NAO MAIS UTILIZADO, AGUARDAR OS TESTES, SE TUDO OCORRER BEM, APAGAR ESSE BATCH
public with sharing class PropostaMassificadosBatch implements Database.Batchable<sObject>,Database.AllowsCallouts,Database.Stateful {

    private Integer contador;
    private static final Integer MAXIMO_TENTATIVAS = 1;

    public PropostaMassificadosBatch(Integer contador){
        this.contador = contador;
    }

    public Database.QueryLocator start(Database.BatchableContext job){

        // Verifica se eh um retry e atualiza o id do job no controle batch do Heroku
        if(this.contador > 0){
            System.debug('TENTATIVA DE EMISSAO DE NÚMERO ' + contador);
            ServiceTO.ControleBatchTO controleBatchTO = new ServiceTO.ControleBatchTO();
            controleBatchTO.idjob = String.valueOf(job.getJobId());
            controleBatchTO.servico = 'contratos/processar-propostas-massificados';

            System.debug('ATUALIZAR ID DO JOB NO CONTROLE BATCH PARA O ID ' + job.getJobId());

            // Verifica se atualizou o controle batch
            try {
                HerokuService.getInstance().atualizarIdJobControleBatch(controleBatchTO);
            } catch (Exception e) {
                System.debug('ERRO NO INICIO DO BATCH DE PROPOSTAS MASSIFICADOS: ' + e.getMessage() + ' LINHA: ' + e.getLineNumber());
                // Aborta o processamento do Batch em caso de erro na atualizacao
                System.abortJob(job.getJobId());
            }
        }

        // Busco os contratos ativos com Garantia da Capitalização
        Database.QueryLocator retorno = Database.getQueryLocator([
                SELECT
                        Id,
                        Name,
                        NumeroProposta__c,
                        CartaoCredito__c,
                        ContactId,
                        ContractId,
                        Contract.NumeroApolice__c,
                        DataCriacaoPortal__c,
                        DataEmissao__c,
                        DataProtocolo__c,
                        DiasAnalise__c,
                        Discount,
                        Email,
                        Empresa__c,
                        CanalDistribuicao__c,
                        GrandTotal,
                        ImprimirCertificadoSeguro__c,
                        InformacaoBancaria__c,
                        IOF__c,
                        IPCA__c,
                        Modalidade__c,
                        OpportunityId,
                        Phone,
                        PremioParcela__c,
                        QuantidadeParcelas__c,
                        RecordTypeId,
                        Reenquadramento__c,
                        ResponsavelFinanceiro__c,
                        TipoCusteio__c,
                        TipoCusteioEstipulante__c,
                        TipoCusteioSegurado__c,
                        TecnicoResponsavel__c,
                        AccountId,
                        MeioComercializacao__c,
                        Produto__c,
                        Status,
                        Origem__c,
                        DataCalculo__c,
                        TipoVigencia__c,
                        VigenciaInicial__c,
                        VigenciaFinal__c,
                        Tipo__c,
                        ValorPremio__c,
                        TipoEvento__c,
                        InformacoesEvento__c,
                        TipoViagem__c,
                        RamoSeguro__c,
                        CodigoCorretor__c,
                        Description,
                        FormaPagamento__c,
                        IdContratoParceiro__c,
                        IdContratanteParceiro__c,
                        Parceiro__c,
                        AdditionalAddress,
                        AdditionalName,
                        BillingAddress,
                        BillingName,
                        CanalDistribuicao__r.Sigla__c,
                        CanalDistribuicao__r.Name,
                        Produto__r.ProductCode,
                        Produto__r.Description,
                        Produto__r.NumeroSusep__c,
                        Produto__r.Empresa__r.CodigoEmpresa__c,
                        Produto__r.Empresa__r.Name,
                        Produto__r.Empresa__c,
                        Produto__r.Name,
                        HistoricoStatus__c,
                        CodigoCorretor__r.Name,
                        CodigoCorretor__r.SucursalVinculo__c,
                        Empresa__r.CodigoEmpresa__c,
                        RamoSeguro__r.Codigo__c,
                        RamoSeguro__r.Name,
                        Empresa__r.Sucursal__c,
                        Account.Idade__c,
                        RecordType.DeveloperName,
                        Empresa__r.Name,
                        Modalidade__r.Codigo__c,
                        Modalidade__r.Descricao__c,
                        Opportunity.Numero__c,
                        Opportunity.NumeroPortal__c,
                        Opportunity.CanalDistribuicao__c,
                        Opportunity.CanalDistribuicao__r.Sigla__c,
                        Opportunity.HaControlePublico__c,
                        Opportunity.EventoLocalFechadoDelimitado__c,
                        Opportunity.ViagemAventura__c,
                        Opportunity.UtilizaMoto__c,
                        Opportunity.IncluiPaisEuropeu__c,
                        Opportunity.PossuiTrackageBagagem__c,
                        Opportunity.QuantidadePassageirosNaoIdosos__c,
                        Opportunity.QuantidadePassageirosIdosos__c,
                        Opportunity.PaisesDestino__c,
                        Payload__c,
                        PremioComercial__c,
                        PremioPuro__c,
                        PremioTotal__c,
                        TaxaComercial__c,
                        TaxaPura__c,
                        TaxaTotal__c,
                        TipoEndosso__c,
                        DescontoAgravoPercentualTecnico__c,
                        DescontoAgravoPercentualComercial__c,
                        DescontoAgravoMonetarioComercial__c,
                        DescontoAgravoMonetarioTecnico__c,
                        DescontoAgravoPercentualInformado__c,
                        DescontoAgravoMonetarioInformado__c,
                        EntradaNegocio__c,
                (
                        SELECT
                                Id,
                                Name,
                                Empresa__c,
                                Sucursal__c,
                                RamoSeguro__c,
                                RamoSeguro__r.Id,
                                RamoSeguro__r.Codigo__c,
                                Endosso__c,
                                NumeroApolice__c,
                                Status
                        FROM
                                Contratos__r
                ),
                (
                        SELECT
                                Id,
                                Garantia__c,
                                GarantiaProduto__c,
                                LimiteCapital__c ,
                                Proposta__c,
                                TipoCapital__c,
                                NumeroSerie__c,
                                NumeroSorte__c,
                                DataSorteio__c,
                                Capital__c,
                                PremioPuro__c,
                                PremioComercial__c,
                                PremioTotal__c,
                                TaxaPura__c,
                                TaxaComercial__c,
                                TaxaTotal__c,
                                DataSolicitacaoCapitalizacao__c,
                                StatusCapitalizacao__c,
                                VersaoTitulo__c,
                                NumeroTitulo__c,
                                LoteCapitalizacao__c,
                                DescontoAgravoPercentualTecnico__c,
                                DescontoAgravoPercentualComercial__c,
                                DescontoAgravoMonetarioComercial__c,
                                DescontoAgravoMonetarioTecnico__c,
                                DescontoAgravoPercentualInformado__c,
                                DescontoAgravoMonetarioInformado__c,
                                GarantiaProduto__r.OrdemPrioridade__c,
                                GarantiaProduto__r.Modalidade__c
                        FROM
                                GarantiasProposta__r
                ),
                (
                        SELECT
                                Id,
                                Codigo__c,
                                DataConclusao__c,
                                Descricao__c,
                                // INICIO | PLV-4647-VI-Guilherme Brito
                                MensagemCliente__c,
                                MensagemInterna__c,
                                MensagemRepresentante__c,
                                Procedimento__c, 
                                //FIM| PLV-4647-VI-Guilherme Brito
                                Origem__c,
                                Proposta__c,
                                RecordTypeId,
                                Severidade__c,
                                Status__c,
                                Tipo__c,
                                Area__c
                        FROM
                                CriticasProposta__r
                )
                FROM
                        Quote
                WHERE
                Status = 'Disponível para contratação'
                AND
                MeioComercializacao__c = 'ARQ'
                // PLV-2378-29 - INICIO
                AND
                Massificados__c = true
                // PLV-2378-29 - FINAL
        ]);

        return retorno;
    }

    public void execute(Database.BatchableContext job, List<Quote> listProposta){
        try{
            QuoteBO.getInstance().processarPropostaParaContrato(listProposta);
        }catch (Exception e){
            String exceptionCatch = 'ERRO NO PROCESSAMENTO DE PROPOSTAS PARA CONTRATO. LINHA: ' + e.getLineNumber() + ' MENSAGEM: ' + e.getMessage();
            System.debug(exceptionCatch);
            throw new PropostaException(exceptionCatch);
        }
    }

    public void finish(Database.BatchableContext job){
        System.debug('FIM DA EXECUCAO DE TODOS OS LOTES DO PROCESSAMENTO DE PROPOSTAS PARA CONTRATO');

        // Verifica se existem propostas de massificados disponiveis para contratação
        Boolean temPropostas = QuoteBO.getInstance().VerificarPropostasMassificados();
        // Verifica se o retry ja chegou no limite de tentativas
        if(temPropostas && contador < MAXIMO_TENTATIVAS){
            System.debug('PRÓXIMA TENTATIVA ' + this.contador++);
            Id jobId = Database.executeBatch(new PropostaMassificadosBatch(this.contador++), 4);
        }else if(!Test.isRunningTest()){
            // Executa o batch de atualizacao dos sistemas externos para todos os lotes
            Id jobBatchId = Database.executeBatch(new AtualizarSistemasExternosBatch(0), 12);
            System.debug('INICIOU O BATCH ATUALIZAR O CONTROLE BATCH COM O ID JOB ' + jobBatchId);
        }
    }

    public class PropostaException extends Exception{}
}
// PLV-2312-28 FIM