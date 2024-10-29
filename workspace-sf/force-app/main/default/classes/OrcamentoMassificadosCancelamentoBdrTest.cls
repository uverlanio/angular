/**
 * Created by Alessandro Ponte on 04/02/2019.
 */

@IsTest
public with sharing class OrcamentoMassificadosCancelamentoBdrTest {

    public static EmissaoTO.PayloadTO payloadTO;

    private static final String ORCAMENTO_MEIO_COMERCIALIZACAO_ARQUIVO = 'ARQ';
    private static final String ORCAMENTO_TIPO_SEGURO_CANCELAMENTO = 'CAN';
    private static final String ORCAMENTO_TIPO_ENDOSSO_DESISTENCIA = 'DES';
    private static Set<String> setSiglaCobertura = new Set<String>();
    private static Integer quantidadeContratantes = 1;
    private static Integer quantidadeGrupos = 1;
    private static Integer quantidadeSegurados = 1;


    @TestSetup
    static void setup(){

        TestDataFactory.gerarDadosSetup();
        //PLV-3744 - INICIO
        //TestDataFactory.Token();
        //PLV-3744 - FIM 

	    // PLV-2312-28 INICIO
        // Gera a proposta
        Map<String,List<SObject>> mapListObject = TestDataFactory.gerarContrato(true);

        Quote proposta = (Quote) mapListObject.get('Quote')[0];
	    //PLV-2372-29 INICIO
        Contract contract = (Contract) mapListObject.get('Contract')[0];

        // Recupera o parceiro
        Parceiro__c parceiro = [SELECT Id,Codigo__c FROM Parceiro__c];

        // Atualiza a proposta
        proposta.MeioComercializacao__c = 'ARQ';//PLV-4550 INICIO/FIM
        proposta.Status = 'Contratada';
        proposta.Parceiro__c = parceiro.Codigo__c;
        // PLV-2312-28 FIM


        // Atualiza o contrato
        contract.Status = 'Emitido';

        update proposta;
        update contract;

        //system.debug('Current SOQL Queries:' + Limits.getQueries() + '/' + Limits.getLimitQueries()); //PLV-5795 FIX01 INICO-FIM
	    //PLV-2372-29 FIM
    }

    @IsTest
    static void testEmitirOrcamentoCancelamento(){

        Test.startTest();
        //payloadTO = gerarPayloadTO();
        String jsonPayload = '{"retornoValidacaoProduto":null,"retornosCalculo":null,"retornoIntegracoes":null,"retornoFinanceiro":null,"retornoCalculo":null,"retornoAceitacao":null,"resultadosIntegracoes":null,"recusada":null,"propostas":null,"proposta2":null,"proposta":{"vigenciaInicial":null,"vigenciaFinal":null,"viagem":null,"versoesCalculos":null,"varConsultivo":null,"transferenciaCongenere":null,"tipoVigencia":null,"tiposEndosso":null,"tipoSeguro":"CAN","tipoResponsavelPagamento":null,"tipoEndosso":"DES","tipoBeneficiario":null,"termoResponsabilidade":null,"termoGuarda":null,"tempoRendaProtegida":null,"tarifa":null,"susepOrcamento":null,"sucursal":null,"status":null,"setorOrigem":null,"segmento":null,"scoreSerasa":null,"scoreFraude":null,"retornoAceitacao":null,"resultadoIntegracoes":null,"remuneracoes":null,"remuneracao":null,"reaproveitarAssinatura":null,"ramoSeguro":null,"ramo":null,"proposta":null,"ProductCode":null,"premioPago":null,"precificacao":null,"pendencias":null,"parceiro":null,"origemRequisicao":null,"origemOriginal":null,"origem":null,"ordemPortal":null,"observacoesGerais":null,"numeroSucursal":null,"numeroPortal":null,"numeroOriginal":null,"numeroOrcamento":null,"numeroEndosso":null,"numeroApolice":null,"numero":null,"nomeEmpresa":null,"nomeArquivo":null,"modalidade":null,"mensagemStatus":null,"melhorPeriodo":null,"meioComercializacao":"ARQ","IndiceIPCA":null,"indice":null,"imprimirCertificadoSeguro":null,"idProtocolo":null,"idProdutoSf":null,"idlote":null,"idContratoRenovado":null,"idContratoParceiro":null,"idContratanteParceiro":null,"formaReceberApolice":null,"flagReentrada":null,"evento":null,"entradaNegocio":null,"endosso":null,"empresa":null,"descricaoStatus":null,"descricaoRamo":null,"descricaoProduto":null,"descricaoModalidade":null,"descontoEmissaoEspecial":null,"dependentesFinanceiros":null,"dataProtocolo":null,"dataEndosso":null,"dataEmissao":null,"dataCriacaoPortal":null,"dataCancelamento":"2023-05-12","dataCalculo":null,"dadosDevolucao":null,"customizavel":null,"cupomDesconto":null,"contratoOriginal":{"vigenciaInicial":"2023-05-12","vigenciaFinal":"2023-06-12","viagem":null,"versoesCalculos":null,"varConsultivo":null,"transferenciaCongenere":null,"tipoVigencia":null,"tiposEndosso":null,"tipoSeguro":null,"tipoResponsavelPagamento":null,"tipoEndosso":null,"tipoBeneficiario":null,"termoResponsabilidade":null,"termoGuarda":null,"tempoRendaProtegida":null,"tarifa":null,"susepOrcamento":null,"sucursal":null,"status":null,"setorOrigem":null,"segmento":null,"scoreSerasa":null,"scoreFraude":null,"retornoAceitacao":null,"resultadoIntegracoes":null,"remuneracoes":null,"remuneracao":null,"reaproveitarAssinatura":null,"ramoSeguro":null,"ramo":null,"proposta":null,"ProductCode":null,"premioPago":null,"precificacao":{"taxa":{"total":0.005363,"puroResseguro":null,"puroInterno":null,"pura":0.007462,"mensal":null,"comercial":0.0002185,"anual":null},"premio":{"total":0.005363,"puroResseguro":null,"puroInterno":null,"puroDesconto":null,"puro":0.007462,"premioPago":null,"integral":null,"informado":null,"comercialDesconto":null,"comercial":0.0002185},"juros":0,"iof":1.24,"encargos":0,"descontoAgravo":null,"custoDeApolice":null,"custoApolice":0,"contratantes":[{"tipo":null,"taxa":{"total":0.005363,"puroResseguro":null,"puroInterno":null,"pura":0.007462,"mensal":null,"comercial":0.0002185,"anual":null},"recorrencia":null,"premio":{"total":0.005363,"puroResseguro":null,"puroInterno":null,"puroDesconto":null,"puro":0.007462,"premioPago":null,"integral":null,"informado":null,"comercialDesconto":null,"comercial":0.0002185},"pessoa":null,"objSfO":null,"objSf":null,"numero":"1","manterPlanoParcelamento":null,"iof":1.24,"idSf":null,"grupos":[{"valorDoBem":null,"valorDescontoAgravo":null,"tipoSegurado":null,"tipoCalculo":null,"taxa":{"total":0.005363,"puroResseguro":null,"puroInterno":null,"pura":0.007462,"mensal":null,"comercial":0.0002185,"anual":null},"tarifa":null,"segurados":[{"vigenciaInicial":null,"vigenciaFinal":null,"taxa":{"total":0.005363,"puroResseguro":null,"puroInterno":null,"pura":0.007462,"mensal":null,"comercial":0.0002185,"anual":null},"responsavelFinanceiroSeguro":null,"responsavelFinanceiro":null,"ramoAtividade":null,"questionario":null,"profissao":null,"premio":{"total":0.005363,"puroResseguro":null,"puroInterno":null,"puroDesconto":null,"puro":0.007462,"premioPago":null,"integral":null,"informado":null,"comercialDesconto":null,"comercial":0.0002185},"pessoa":null,"ocupacaoProfissionalPrincipal":null,"objSfO":null,"objSF":null,"numeroCpf":null,"numero":"1","nome":null,"limiteProfissao":null,"iof":1.24,"formaTrabalho":null,"faixaRenda":null,"empresaQueTrabalha":null,"digitoCpf":null,"descontoAgravo":null,"dataNascimento":null,"dadosPagamento":null,"contatoEmergencia":null,"coberturas":[{"versaoCapitalizacao":null,"valorDescontoAgravo":null,"valor":null,"tituloCapitalizacao":null,"taxa":{"total":0.005363,"puroResseguro":null,"puroInterno":null,"pura":0.007462,"mensal":null,"comercial":0.0002185,"anual":null},"statusCapitalizacao":null,"sigla":"CAP","quantidade":null,"premio":{"total":0.005363,"puroResseguro":null,"puroInterno":null,"puroDesconto":null,"puro":0.007462,"premioPago":null,"integral":null,"informado":null,"comercialDesconto":null,"comercial":0.0002185},"percentualIndenizacaoEspecial":null,"percentualFilhos":null,"percentual":null,"numeroSorte":null,"numeroSerie":null,"loteCapitalizacao":null,"limiteminimo":null,"limitemaximo":null,"iof":1.24,"inclusaoIndenizacaoEspecial":null,"inclusaoFilhos":null,"importancia":null,"idSf":null,"garantiaReferenciada":null,"franquia":null,"escolhaDescontoAgravo":null,"descontoAgravo":null,"desconto":null,"dataSorteio":null,"dataSolicitacao":null,"clausulaReducaoFranquiaAcidente":null,"caracteristicaespecialvalor":null,"caracteristicaespecialtipo":null,"capitalContratacao":null,"capital":119.8,"agravo":null}],"cid":null,"beneficiarios":null,"afastado":null}],"saldoDevedor":null,"qtdeVidas":null,"premio":{"total":0.005363,"puroResseguro":null,"puroInterno":null,"puroDesconto":null,"puro":0.007462,"premioPago":null,"integral":null,"informado":null,"comercialDesconto":null,"comercial":0.0002185},"prazoMaximoFinanciamentoPrestamista":null,"objSFO":null,"objSF":null,"numero":"1","nome":null,"iof":1.24,"idSf":null,"idArquivoVidas":null,"escolhaDescontoAgravo":null,"descontoAgravo":null,"desconto":null,"coberturas":[{"versaoCapitalizacao":null,"valorDescontoAgravo":null,"valor":null,"tituloCapitalizacao":null,"taxa":{"total":0.005363,"puroResseguro":null,"puroInterno":null,"pura":0.007462,"mensal":null,"comercial":0.0002185,"anual":null},"statusCapitalizacao":null,"sigla":"CAP","quantidade":null,"premio":{"total":0.005363,"puroResseguro":null,"puroInterno":null,"puroDesconto":null,"puro":0.007462,"premioPago":null,"integral":null,"informado":null,"comercialDesconto":null,"comercial":0.0002185},"percentualIndenizacaoEspecial":null,"percentualFilhos":null,"percentual":null,"numeroSorte":null,"numeroSerie":null,"loteCapitalizacao":null,"limiteminimo":null,"limitemaximo":null,"iof":1.24,"inclusaoIndenizacaoEspecial":null,"inclusaoFilhos":null,"importancia":null,"idSf":null,"garantiaReferenciada":null,"franquia":null,"escolhaDescontoAgravo":null,"descontoAgravo":null,"desconto":null,"dataSorteio":null,"dataSolicitacao":null,"clausulaReducaoFranquiaAcidente":null,"caracteristicaespecialvalor":null,"caracteristicaespecialtipo":null,"capitalContratacao":null,"capital":119.8,"agravo":null}],"agravo":null}],"formaReceberApolice":null,"descontoAgravo":null,"dadosPagamento":null,"contato":null,"contaSf":null,"conta":null,"coberturas":[{"versaoCapitalizacao":null,"valorDescontoAgravo":null,"valor":null,"tituloCapitalizacao":null,"taxa":{"total":0.005363,"puroResseguro":null,"puroInterno":null,"pura":0.007462,"mensal":null,"comercial":0.0002185,"anual":null},"statusCapitalizacao":null,"sigla":"CAP","quantidade":null,"premio":{"total":0.005363,"puroResseguro":null,"puroInterno":null,"puroDesconto":null,"puro":0.007462,"premioPago":null,"integral":null,"informado":null,"comercialDesconto":null,"comercial":0.0002185},"percentualIndenizacaoEspecial":null,"percentualFilhos":null,"percentual":null,"numeroSorte":null,"numeroSerie":null,"loteCapitalizacao":null,"limiteminimo":null,"limitemaximo":null,"iof":1.24,"inclusaoIndenizacaoEspecial":null,"inclusaoFilhos":null,"importancia":null,"idSf":null,"garantiaReferenciada":null,"franquia":null,"escolhaDescontoAgravo":null,"descontoAgravo":null,"desconto":null,"dataSorteio":null,"dataSolicitacao":null,"clausulaReducaoFranquiaAcidente":null,"caracteristicaespecialvalor":null,"caracteristicaespecialtipo":null,"capitalContratacao":null,"capital":119.8,"agravo":null}]}],"coberturas":[{"versaoCapitalizacao":null,"valorDescontoAgravo":null,"valor":null,"tituloCapitalizacao":null,"taxa":{"total":0.005363,"puroResseguro":null,"puroInterno":null,"pura":0.007462,"mensal":null,"comercial":0.0002185,"anual":null},"statusCapitalizacao":null,"sigla":"CAP","quantidade":null,"premio":{"total":0.005363,"puroResseguro":null,"puroInterno":null,"puroDesconto":null,"puro":0.007462,"premioPago":null,"integral":null,"informado":null,"comercialDesconto":null,"comercial":0.0002185},"percentualIndenizacaoEspecial":null,"percentualFilhos":null,"percentual":null,"numeroSorte":null,"numeroSerie":null,"loteCapitalizacao":null,"limiteminimo":null,"limitemaximo":null,"iof":1.24,"inclusaoIndenizacaoEspecial":null,"inclusaoFilhos":null,"importancia":null,"idSf":null,"garantiaReferenciada":null,"franquia":null,"escolhaDescontoAgravo":null,"descontoAgravo":null,"desconto":null,"dataSorteio":null,"dataSolicitacao":null,"clausulaReducaoFranquiaAcidente":null,"caracteristicaespecialvalor":null,"caracteristicaespecialtipo":null,"capitalContratacao":null,"capital":119.8,"agravo":null}]},"pendencias":null,"parceiro":null,"origemRequisicao":null,"origemOriginal":null,"origem":18,"ordemPortal":null,"observacoesGerais":null,"numeroSucursal":null,"numeroPortal":null,"numeroOriginal":null,"numeroOrcamento":null,"numeroEndosso":null,"numeroApolice":null,"numero":"00006767","nomeEmpresa":null,"nomeArquivo":null,"modalidade":null,"mensagemStatus":null,"melhorPeriodo":null,"meioComercializacao":null,"IndiceIPCA":null,"indice":null,"imprimirCertificadoSeguro":null,"idProtocolo":null,"idProdutoSf":null,"idlote":null,"idContratoRenovado":null,"idContratoParceiro":null,"idContratanteParceiro":null,"formaReceberApolice":null,"flagReentrada":null,"evento":null,"entradaNegocio":null,"endosso":null,"empresa":null,"descricaoStatus":null,"descricaoRamo":null,"descricaoProduto":null,"descricaoModalidade":null,"descontoEmissaoEspecial":null,"dependentesFinanceiros":null,"dataProtocolo":null,"dataEndosso":null,"dataEmissao":null,"dataCriacaoPortal":null,"dataCancelamento":null,"dataCalculo":null,"dadosDevolucao":null,"customizavel":null,"cupomDesconto":null,"contratoOriginal":null,"contratantes":[{"tipo":null,"taxa":null,"recorrencia":null,"premio":null,"pessoa":null,"objSfO":null,"objSf":null,"numero":"1","manterPlanoParcelamento":null,"iof":null,"idSf":null,"grupos":null,"formaReceberApolice":null,"descontoAgravo":null,"dadosPagamento":{"vigenciaInicial":null,"vencimentoPrimeiraParcela":null,"vencimentoDemaisParcelas":null,"valorPrimeiraParcela":null,"valorDemaisParcelas":null,"tipoResponsavelPagamento":null,"responsavelPagamento":null,"responsavelFinanceiroSeguro":null,"responsavelFinanceiro":null,"quantidadeParcelas":2,"premioTotal":null,"parcelas":[{"valorParcela":1.68,"valorIOF":0.42,"status":"PENDENTE","numeroTitulo":null,"numeroParcela":"1","meioPagamento":null,"dataVencimentoParcela":"2023-06-12","dadosPagamento":null,"boleto":null},{"valorParcela":1.68,"valorIOF":0.42,"status":"PENDENTE","numeroTitulo":null,"numeroParcela":"2","meioPagamento":null,"dataVencimentoParcela":"2023-07-12","dadosPagamento":null,"boleto":null}],"opcao":null,"idPlanoParcelamento":null,"formaPagamento":null,"formaInfoCartao":null,"diasPagamento":null,"descricaoFormaPagamento":null,"descricao":null,"dadosCartaoCredito":null,"dadosBancarios":null,"codigoMeioRecebimento":null,"codigoFormaPagamento":null,"codigo":null,"cartaoCredito":null,"boleto":null},"contato":null,"contaSf":null,"conta":null,"coberturas":null}],"codigoProdutoVida":null,"codigoEmpresa":null,"coberturas":null,"chaveContrato":"800DP0000049jBFYAY","canalDistribuicao":null,"assinaturaEletronica":null,"arquivos":null,"apolice":null},"contratantes":null,"codigoProdutoVida":null,"codigoEmpresa":null,"coberturas":null,"chaveContrato":null,"canalDistribuicao":null,"assinaturaEletronica":null,"arquivos":null,"apolice":null},"origemRecusa":null,"orcamentos":null,"orcamento":null,"ofertas":null,"devolutivas":null,"contratantes":null,"calculo":null,"atualizarOrcamento":null}';
        payloadTO = (EmissaoTO.PayloadTO)JSON.deserialize(jsonPayload, EmissaoTO.PayloadTO.class);

        OrcamentoMassificadosCancelamentoBuilder orcamentoMassificadosCancelamentoBuilder = OrcamentoMassificadosCancelamentoBuilder.getInstance();
        Orcamento orcamento = orcamentoMassificadosCancelamentoBuilder.montarOrcamento(payloadTO, null, true);

        Test.stopTest();

        // Orcamento
        //System.assert(orcamento.orcamentoWrapper.sfOrcamento != null);
        //System.assert(orcamento.orcamentoWrapper.sfOrcamento.Id != null);
        //System.assertEquals(false,orcamento.orcamentoWrapper.RemuneracaoOrcamentoWrapper.isEmpty());
        //System.assert(orcamento.orcamentoWrapper.RemuneracaoOrcamentoWrapper[0].sfRemuneracaoOrcamento.Id != null);
        //System.assertEquals(false,orcamento.orcamentoWrapper.garantiasWrapper.isEmpty());
        //System.assertEquals(false,orcamento.orcamentoWrapper.criticas.isEmpty());
        //System.assert(orcamento.orcamentoWrapper.criticas[0].Id != null);

        //// Contratantes
        //System.assertEquals(false,orcamento.orcamentoWrapper.contratantesWrapper.isEmpty());
        //System.assert(orcamento.orcamentoWrapper.contratantesWrapper[0].sfContratante.Id != null);
        //System.assert(orcamento.orcamentoWrapper.contratantesWrapper[0].pessoaWrapper != null);
        //System.assert(orcamento.orcamentoWrapper.contratantesWrapper[0].pessoaWrapper != null);
        //System.assertEquals(false,orcamento.orcamentoWrapper.contratantesWrapper[0].garantiasWrapper.isEmpty());
        //System.assert(orcamento.orcamentoWrapper.contratantesWrapper[0].garantiasWrapper[0].sfGarantiasContratanteOrcamento.Id != null);
        //// Grupos
        //System.assertEquals(false,orcamento.orcamentoWrapper.contratantesWrapper[0].gruposWrapper.isEmpty());
        //System.assert(orcamento.orcamentoWrapper.contratantesWrapper[0].gruposWrapper[0].sfGrupo.Id != null);
        //System.assertEquals(false,orcamento.orcamentoWrapper.contratantesWrapper[0].gruposWrapper[0].garantiasWrapper.isEmpty());
        //System.assert(orcamento.orcamentoWrapper.contratantesWrapper[0].gruposWrapper[0].garantiasWrapper[0].sfGarantiaGrupoOrcamento.Id != null);

        //// Segurados
        //System.assertEquals(false,orcamento.orcamentoWrapper.contratantesWrapper[0].gruposWrapper[0].seguradosWrapper.isEmpty());
        //System.assert(orcamento.orcamentoWrapper.contratantesWrapper[0].gruposWrapper[0].seguradosWrapper[0].sfSegurado.Id != null);
        //System.assert(orcamento.orcamentoWrapper.contratantesWrapper[0].gruposWrapper[0].seguradosWrapper[0].pessoaWrapper != null);
        //System.assertEquals(false,orcamento.orcamentoWrapper.contratantesWrapper[0].gruposWrapper[0].seguradosWrapper[0].garantiasWrapper.isEmpty());
        //System.assert(orcamento.orcamentoWrapper.contratantesWrapper[0].gruposWrapper[0].seguradosWrapper[0].garantiasWrapper[0].sfGarantiaSeguradoOrcamento.Id != null);

    }

    private static EmissaoTO.PayloadTO gerarPayloadTO(){

        // Instancias
        payloadTO = new EmissaoTO.PayloadTO();
        payloadTO.proposta = new EmissaoTO();
        payloadTO.proposta.contratoOriginal = new EmissaoTO();
        payloadTO.proposta.contratoOriginal.contratantes = new List<EmissaoTO.ContratanteTO>();
        payloadTO.proposta.contratoOriginal.precificacao = new EmissaoTO.PrecificacaoTO();
	    //PLV-2372-29 INICIO
        Contract contratoOriginal = [SELECT Id, Proposta__c, Name, Status FROM Contract WHERE Status = 'Emitido' LIMIT 1];
        Quote propostaOriginal = [
                SELECT
                        Id,
                        NumeroProposta__c,
                        VigenciaInicial__c,
                        VigenciaFinal__c,
                (
                        SELECT
                                Id,
                                Garantia__r.Sigla__c
                        FROM
                                GarantiasProposta__r
                ) FROM Quote
                WHERE
                        Id =: contratoOriginal.Proposta__c
                LIMIT 1
        ];
	    //PLV-2372-29 FIM

        // Popula o set de sigla de coberturas
        for(GarantiaProposta__c garantiaProposta : propostaOriginal.GarantiasProposta__r){
            setSiglaCobertura.add(garantiaProposta.Garantia__r.Sigla__c);
        }

        // 1o nivel
        payloadTO.proposta.meioComercializacao = ORCAMENTO_MEIO_COMERCIALIZACAO_ARQUIVO;
        payloadTO.proposta.tipoSeguro = ORCAMENTO_TIPO_SEGURO_CANCELAMENTO;
        payloadTO.proposta.tipoEndosso = ORCAMENTO_TIPO_ENDOSSO_DESISTENCIA;
        payloadTO.proposta.dataCancelamento = String.valueOf(System.today());

	    //PLV-2372-29 INICIO
        // gera os contratoOriginal
        popularContratoOriginal(payloadTO.proposta.contratoOriginal,propostaOriginal, contratoOriginal);
	    //PLV-2372-29 FIM

        // Gera os contratantes
        for(Integer i = 0; i < quantidadeContratantes; i ++){
            payloadTO.proposta.contratoOriginal.contratantes.add(gerarContratanteTO(i+1, false, false));
        }

        // Popula a precificacao
        popularPrecificacaoTO(payloadTO.proposta.contratoOriginal.precificacao);

        return payloadTO;

    }

    // Popula a precificacao
    private static void popularPrecificacaoTO(EmissaoTO.PrecificacaoTO precificacaoTO){

        // Instancias
        List<EmissaoTO.CoberturaTO> listCoberturaTO = new List<EmissaoTO.CoberturaTO>();
        precificacaoTO.contratantes = new List<EmissaoTO.ContratanteTO>();

        try{
            precificacaoTO.taxa = gerarTaxaTO();
            precificacaoTO.premio = gerarPremioTO();
            precificacaoTO.juros = 0;
            precificacaoTO.iof = 1.24;
            precificacaoTO.encargos = 0;
            precificacaoTO.custoApolice = 0;

        }catch (Exception e){
            throw new PropostaBuilder.PropostaBuilderException('Erro ao popular a precificacao');
        }

        // Gera as coberturas da proposta
        for(String sigla : setSiglaCobertura){
            listCoberturaTO.add(gerarCoberturaTO(sigla, true));
        }
        precificacaoTO.coberturas = listCoberturaTO;

        // gera contratantes para precificacao
        for(Integer i = 0; i < quantidadeContratantes; i ++){
            precificacaoTO.contratantes.add(gerarContratanteTO(i+1,true, true));
        }

    }

    // Gera coberturaTO
    private static EmissaoTO.CoberturaTO gerarCoberturaTO(String sigla, Boolean ehPrecificacao){

        EmissaoTO.CoberturaTO coberturaTO = new EmissaoTO.CoberturaTO();

        try{
            if(ehPrecificacao){

                coberturaTO.premio = gerarPremioTO();
                coberturaTO.taxa = gerarTaxaTO();
                coberturaTO.sigla = sigla;
                coberturaTO.capital = 119.8;
                coberturaTO.iof = 1.24;

            }

        }catch (Exception e){
            throw new PropostaBuilder.PropostaBuilderException('Erro ao popular a precificacao');
        }

        return coberturaTO;

    }

    // gera a taxaTO
    private static EmissaoTO.TaxaTO gerarTaxaTO(){
        EmissaoTO.TaxaTO taxaTO = new EmissaoTO.TaxaTO();

        try{
            taxaTO.comercial  = 0.0002185;
            taxaTO.pura = 0.007462;
            taxaTO.total = 0.005363;

        }catch (Exception e){
            throw new PropostaBuilder.PropostaBuilderException('Erro ao gerar a taxa');
        }

        return taxaTO;
    }

    // gera a premioTO
    private static EmissaoTO.PremioTO gerarPremioTO(){
        EmissaoTO.PremioTO premioTO = new EmissaoTO.PremioTO();

        try{
            premioTO.comercial  = 0.0002185;
            premioTO.puro = 0.007462;
            premioTO.total = 0.005363;

        }catch (Exception e){
            throw new PropostaBuilder.PropostaBuilderException('Erro ao gerar o premio');
        }

        return premioTO;
    }

    // Gera o contrante
    private static EmissaoTO.ContratanteTO gerarContratanteTO(Integer numero,Boolean ehPrecificacao, Boolean temGrupo){

        // Instancias
        EmissaoTO.ContratanteTO contratanteTO = new EmissaoTO.ContratanteTO();

        try{
            contratanteTO.numero = String.valueOf(numero);

            if(ehPrecificacao){
                contratanteTO.taxa = gerarTaxaTO();
                contratanteTO.premio = gerarPremioTO();
                contratanteTO.iof = 1.24;
            }

        }catch (Exception e){
            throw new PropostaBuilder.PropostaBuilderException('Erro ao gerar o contratante de numero: ' + numero);
        }

        if(ehPrecificacao){

            List<EmissaoTO.CoberturaTO> listCoberturaTO = new List<EmissaoTO.CoberturaTO>();

            // Gera as coberturas do contratante
            for(String sigla : setSiglaCobertura){
                listCoberturaTO.add(gerarCoberturaTO(sigla,true));
            }

            contratanteTO.coberturas = listCoberturaTO;

        }else{

            // Gerar dados de pagamento
            contratanteTO.dadosPagamento = gerarDadosPagamentoTO(numero, 2);
        }

        if(temGrupo){
            List<EmissaoTO.GrupoTO> listGrupoTO = new List<EmissaoTO.GrupoTO>();

            for(Integer i = 0; i < quantidadeGrupos; i ++) {
                // Gera o grupo
                listGrupoTO.add(gerarGrupoTO(i+1,true, true));
            }
            contratanteTO.grupos = listGrupoTO;
        }

        return contratanteTO;


    }

    // Gera grupoTO
    private static EmissaoTO.GrupoTO gerarGrupoTO(Integer numeroGrupo, Boolean ehPrecificacao, Boolean temSegurado){

        EmissaoTO.GrupoTO grupoTO = new EmissaoTO.GrupoTO();

        try{

            grupoTO.numero = String.valueOf(numeroGrupo);

            if(ehPrecificacao){
                grupoTO.taxa = gerarTaxaTO();
                grupoTO.premio = gerarPremioTO();
                grupoTO.iof = 1.24;
            }

        }catch (Exception e){
            throw new PropostaBuilder.PropostaBuilderException('Erro ao gerar o grupo numero ' + numeroGrupo);
        }

        if(ehPrecificacao){

            List<EmissaoTO.CoberturaTO> listCoberturaTO = new List<EmissaoTO.CoberturaTO>();

            for(String sigla : setSiglaCobertura) {
                listCoberturaTO.add(gerarCoberturaTO(sigla,true));
            }

            grupoTO.coberturas = listCoberturaTO;

        }

        if(temSegurado){

            List<EmissaoTO.SeguradoTO> listSeguradoTO = new List<EmissaoTO.SeguradoTO>();

            for(Integer i = 0; i < quantidadeSegurados; i ++) {
                // Gera o segurado
                listSeguradoTO.add(gerarSeguradoTO(i+1,true));
            }

            grupoTO.segurados = listSeguradoTO;
        }

        return grupoTO;

    }

    // Gera grupoTO
    private static EmissaoTO.SeguradoTO gerarSeguradoTO(Integer numeroGrupo, Boolean ehPrecificacao){

        EmissaoTO.SeguradoTO seguradoTO = new EmissaoTO.SeguradoTO();

        try{

            seguradoTO.numero = String.valueOf(numeroGrupo);

            if(ehPrecificacao){
                seguradoTO.taxa = gerarTaxaTO();
                seguradoTO.premio = gerarPremioTO();
                seguradoTO.iof = 1.24;
            }

        }catch (Exception e){
            throw new PropostaBuilder.PropostaBuilderException('Erro ao gerar o grupo numero ' + numeroGrupo);
        }

        if(ehPrecificacao){
            List<EmissaoTO.CoberturaTO> listCoberturaTO = new List<EmissaoTO.CoberturaTO>();

            for(String sigla : setSiglaCobertura) {
                listCoberturaTO.add(gerarCoberturaTO(sigla,true));
            }

            seguradoTO.coberturas = listCoberturaTO;

        }


        return seguradoTO;

    }

    // Gera dados de pagamento
    private static EmissaoTO.DadosPagamentoTO gerarDadosPagamentoTO(Integer numeroContrante, Integer quantidadeParcelas){

        // Instancias
        EmissaoTO.DadosPagamentoTO dadosPagamentoTO = new EmissaoTO.DadosPagamentoTO();
        List<EmissaoTO.ParcelaTO> listParcelaTO = new List<EmissaoTO.ParcelaTO>();

        try{
            dadosPagamentoTO.quantidadeParcelas = quantidadeParcelas;
        }catch (Exception e){
            throw new PropostaBuilder.PropostaBuilderException('Erro ao gerar os dados de pagemento do contratante ' + numeroContrante);
        }

        // Gera as parcelas do contratante
        for(Integer i = 0; i < quantidadeParcelas; i++){
            listParcelaTO.add(gerarParcelaTO(i+1));
        }

        dadosPagamentoTO.parcelas = listParcelaTO;

        return dadosPagamentoTO;

    }

    //PLV-2372-29 INICIO
    // Popula o contrato original
    private static EmissaoTO popularContratoOriginal(EmissaoTO contratoOriginalTO, Quote propostaOriginal, Contract contratoOriginal){

        if(propostaOriginal == null){
            throw new PropostaBuilder.PropostaBuilderException('Proposta original não encontrada');
        }

        try{
            contratoOriginalTO.chaveContrato = contratoOriginal.Id;
            contratoOriginalTO.origem = 18;
            contratoOriginalTO.numero = propostaOriginal.NumeroProposta__c;
            contratoOriginalTO.vigenciaInicial = String.valueOf(System.today());
            contratoOriginalTO.vigenciaFinal = String.valueOf(propostaOriginal.VigenciaFinal__c);
        }catch (Exception e){
            throw new PropostaBuilder.PropostaBuilderException('Erro ao gerar o contrato original');
        }

        return contratoOriginalTO;

    }
    //PLV-2372-29 FIM

    private static EmissaoTO.ParcelaTO gerarParcelaTO(Integer numeroParcela){

        EmissaoTO.ParcelaTO parcelaTO = new EmissaoTO.ParcelaTO();

        try{
            parcelaTO.numeroParcela = String.valueOf(numeroParcela);
            parcelaTO.valorParcela = 1.68;
            parcelaTO.valorIOF = 0.42;
            parcelaTO.dataVencimentoParcela = String.valueOf(System.today().addMonths(numeroParcela));
            parcelaTO.status = 'PENDENTE';

        }catch (Exception e){
            throw new PropostaBuilder.PropostaBuilderException('Erro ao gerar a parcela de número ' + numeroParcela);
        }

        return parcelaTO;

    }

}