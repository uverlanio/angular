/**
 * Created by Alessandro Ponte on 04/02/2019.
 */

@IsTest
public with sharing class PropostaMassificadosCancelamentoBdrTest {

    public static EmissaoTO.PayloadTO payloadTO;

    private static final String PROPOSTA_MEIO_COMERCIALIZACAO_ARQUIVO = 'ARQ';
    private static final String PROPOSTA_TIPO_SEGURO_CANCELAMENTO = 'CAN';
    private static final String PROPOSTA_TIPO_ENDOSSO_DESISTENCIA = 'DES';
    private static Set<String> setSiglaCobertura = new Set<String>();
    private static Integer quantidadeContratantes = 1;
    private static final String COBERTURA1 = 'DBAG';
    private static final String COBERTURA2 = 'DMHO';
    private static Integer quantidadeGrupos = 1;
    private static Integer quantidadeSegurados = 1;


    @TestSetup
    static void setup(){
        /*TestDataFactory.gerarDadosSetup();
        //PLV-3744 - INICIO
        //TestDataFactory.Token();
        //PLV-3744 - FIM 

        // Gera o contrato
	    // PLV-2312-28 INICIO
        Map<String,List<SObject>> mapListObject = TestDataFactory.gerarContrato(true);

        Quote proposta = (Quote) mapListObject.get('Quote')[0];
        Contract contrato = (Contract) mapListObject.get('Contract')[0];

        // recupera o parceiro
        Parceiro__c parceiro = [SELECT Id,Codigo__c FROM Parceiro__c];*/

        Account contaTeste = TestDataFactory.gerarConta();

        Account contaPF = (Account) new AccountFactory.PessoaFisica().createRecord();
        Account contaPJ = (Account) new AccountFactory.PessoaJuridica().createRecord();

        Account contasegurado = new Account(
             RecordTypeId = RecordTypeBO.buscarTipoRegistro('Account', 'PessoaFisica').Id,
             LastName = 'Teste',
             NomeSocial__c = 'Teste TI', //LECVPV_190 FIX03 - INICIO/FIM
             Nacionalidade__c = 'Brasileira',
             CPF__c = '00478394659',
             Rg__c = '232323231',
             DataExpedicao__c = Date.today(),
             OrgaoExpedidor__c = '123132',
             PersonBirthDate = (Date.today()-7300),
             EstadoCivil__c = 'Solteiro (a)',
             PersonEmail = 'abc@portoseguro.com.br'
         );
        insert contasegurado;
        DadosCorretor__c dadosCorretor = TestDataFactory.gerarDadosCorretor(contaPF);
        RamoSeguro__c ramoSegurado = TestDataFactory.gerarRamoSeguro(contaPF);
        Garantia__c garantia1 = TestDataFactory.gerarGarantia();
        RamoGarantia__c ramoGarantia = TestDataFactory.gerarRamoGarantia(garantia1, ramoSegurado);
        
        ContadorCodigo__c contCodigoTec = (ContadorCodigo__c) new ContadorCodigoFactory.ProdutoTecnico().createRecord();
	    ContadorCodigo__c contCodigoCom = (ContadorCodigo__c) new ContadorCodigoFactory.ProdutoComercial().createRecord();
        
        Product2 produtoTec = TestDataFactory.gerarProdutoTecnico();
        produtoTec.Status__c = 'Ativo';
        update produtoTec;
        
        Product2 produtoCom = TestDataFactory.gerarProdutoComericial(produtoTec);
        produtoCom.Status__c ='ativo';
        produtoCom.Segmento__c = 'Individual';
        update produtoCom;

        GarantiaProduto__c garantiaProdutoTec = TestDataFactory.gerarGarantiaProdutoTecnico(produtoTec, garantia1, ramoSegurado);
        GarantiaProduto__c garantiaProdutoCom = TestDataFactory.gerarGarantiaProdutoTecnico(produtoCom, garantia1, ramoSegurado);
        Questionario__c questionarioProdCom = TestDataFactory.gerarQuestionario();
        QuestionarioProduto__c questionarioProduto = TestDataFactory.gerarQuestionarioProduto(questionarioProdCom, produtoCom, garantiaProdutoCom);
        ParametroVigencia__c parametroCom = (ParametroVigencia__c) new ParametroVigenciaFactory.ParametroVigenciaComercial(produtoCom).createRecord(); //PLV-5768 INICIO/FIM
	    QueueableQTD__c qtdRecordDetails = (QueueableQTD__c) new QueueableQTDFactory().createRecord();
        QueueableQTD__c qtdRecordSend = qtdRecordDetails.clone();
        qtdRecordSend.Name = 'QueueableContractDetails';
        qtdRecordSend.Quantidade__c = 20;
        insert qtdRecordSend;
        CanalDistribuicao__c canalDistribuicao = TestDataFactory.gerarCanalDistribuicao();
        canalDistribuicao.Status__c = 'Ativo';
        canalDistribuicao.Sigla__c = 'VAR';
        canalDistribuicao.Name = 'Varejista';
        canalDistribuicao.Papeis__c = 'Varejo';
        update canalDistribuicao;
        
        TipoRemuneracao__c tipoRemuneracao = TestDataFactory.gerarTipoRemuneracao('COR', 100, 200, null);
        
        //Opportunity orcamentoContratado = TestDataFactory.gerarOrcamentoObjeto(contasegurado, produtoCom, canalDistribuicao);

        Opportunity orcamentoContratado = (Opportunity) new OrcamentoFactory.VidaIndividual(produtoCom, contaPF).createRecord();
        orcamentoContratado.StageName = 'Disponível para contratação';
        orcamentoContratado.NumeroOferta__c = '1234';
        orcamentoContratado.Origem__c = '18';
        update orcamentoContratado;
        GarantiaOrcamento__c garantiaOrcamento = TestDataFactory.gerarGarantiaOrcamento(garantia1, orcamentoContratado);   
        RemuneracaoOrcamento__c remuneracaoOrcamento = TestDataFactory.gerarRemuneracaoOrcamento(orcamentoContratado, tipoRemuneracao);
        ContratanteOrcamento__c contratanteOrcamento = TestDataFactory.gerarContratanteOrcamento(orcamentoContratado, contaPF);
        GrupoOrcamento__c grupoOrcamento = TestDataFactory.gerarGrupoOrcamento(contratanteOrcamento);
        SeguradoOrcamento__c seguradoOrcamento = TestDataFactory.gerarSeguradoOrcamento(grupoOrcamento);
        
        Modalidade__c modalidade = TestDataFactory.gerarModalidade(ramoSegurado);
        FormaPagamento__c formapagamento = TestDataFactory.gerarFormaPagamento();
        Parceiro__c parceiro = (Parceiro__c) new ParceiroFactory(contaPF, formaPagamento).createRecord();
        update parceiro;

        Quote proposta = (Quote) new PropostaFactory(produtoCom, ramoSegurado, contaPF, dadosCorretor, orcamentoContratado, modalidade).getRecord();
        proposta.Tipo__c = 'Novo';
        proposta.Status = 'Em análise';
        proposta.Parceiro__c = parceiro.Codigo__c;
        proposta.MeioComercializacao__c = 'ARQ'; 
        insert proposta;

        proposta.Status = 'Contratada';
        
        update proposta;
        GarantiaProposta__c garantiaProposta = TestDataFactory.gerarGarantiaProposta(proposta, garantiaProdutoTec);
        RemuneracaoProposta__c remuneracaoProposta = TestDataFactory.gerarRemuneracaoProposta(proposta, tipoRemuneracao);
        ContratanteProposta__c contratanteProposta = TestDataFactory.gerarContratanteProposta(contaPF, proposta, formaPagamento);
        GrupoProposta__c grupoProposta = TestDataFactory.gerarGrupoProposta(contratanteProposta);
        SeguradoProposta__c seguradoProposta = TestDataFactory.gerarSeguradoProposta(contaPF, grupoProposta, formaPagamento);
        BeneficiarioSeguradoProposta__c beneficiarioSeguradoProposta = TestDataFactory.gerarBeneficiarioSeguradoProposta(contaPF, seguradoProposta);

        Contract contrato = TestDataFactory.gerarContratoObjeto(produtoCom, ramoSegurado, contaPF, dadosCorretor, proposta);
        //Contract contrato = (Contract) new ContratoFactory.ContratoFactoryComParam(contaPF, produtoCom, contaPF).createRecord();
        contrato.Oportunidade__c = orcamentoContratado.Id;
        contrato.Proposta__c = proposta.Id;
        contrato.Parceiro__c = parceiro.Codigo__c;
        contrato.NumeroProposta__c = proposta.NumeroProposta__c;
        contrato.NumeroApolice__c = '12345';
        update contrato;
        
        List<Garantia__c> garantias = new List<Garantia__c>();
        Garantia__c garantia = (Garantia__c) new GarantiaFactory().getRecord();
        garantia.Sigla__c = COBERTURA1;
        garantias.add(garantia);

        Garantia__c garantia2 = new Garantia__c(
            Name = COBERTURA2,
            Status__c = 'Ativo',
            Sigla__c = COBERTURA2,
            Tipo__c = 'Cobertura',
            VigenciaInicial__c = System.today(),
            TipoEvento__c = 'Morte'
        );
        garantias.add(garantia2);
        insert garantias;

        List<GarantiaContrato__c> garantiasContrato = new List<GarantiaContrato__c>();
        GarantiaContrato__c garantiaContrato1 = new GarantiaContrato__c(
            Contrato__c = contrato.Id, Garantia__c = garantia.Id, Capital__c = 10000.00, TipoCapital__c = 'Capital uniforme'
        );
        garantiasContrato.add(garantiaContrato1);
        GarantiaContrato__c garantiaContrato2 = new GarantiaContrato__c(
            Contrato__c = contrato.Id, Garantia__c = garantia2.Id, Capital__c = 20000.00, TipoCapital__c = 'Capital uniforme'
        );
        garantiasContrato.add(garantiaContrato2);
        insert garantiasContrato;

        ContratanteContrato__c ContratanteContrato = (ContratanteContrato__c) new ContratanteFactory(contrato).createRecord();
        GrupoContrato__c GrupoContrato = (GrupoContrato__c) new GrupoFactory(ContratanteContrato).createRecord();
        SeguradoContrato__c SeguradoContrato = (SeguradoContrato__c) new SeguradoContratoFactory(contaPF, GrupoContrato).createRecord();
        GarantiaSeguradoContrato__c GarantiaSeguradoContrato = (GarantiaSeguradoContrato__c) new GarantiaSeguradoContratoFactory(
            SeguradoContrato, garantia
        ).createRecord();
        
        // Atualiza a proposta
        proposta.MeioComercializacao__c = 'ARQ'; //PLV-4550 INICIO/FIM
        proposta.Status = 'Contratada';
        proposta.Tipo__c = 'Cancelamento';
        proposta.Contract = contrato;
        // PLV-2312-28 FIM

        // Atualiza o contrato
        contrato.Status = 'Emitido';

        update proposta;
        update contrato;

        //system.debug('Current SOQL Queries:' + Limits.getQueries() + '/' + Limits.getLimitQueries()); //PLV05795 FIX01 INICO-FIM
    }

    /*@IsTest
    static void testGerarFilhosContrato(){
        //List<Contract> contrato = [SELECT id FROM Contract LIMIT 1];
        //Set<Id> setIds = new set<Id>();
        //setIds.add(contrato[0].id);
        //List<Contract> listContrato = ContractDAO.getInstance().buscarContratosPorId(setIds);
        //Contract contratoOriginal = listContrato[0];
        Test.startTest();
        PropostaMassificadosCancelamentoBuilder.getInstance().clonarFilhosContrato();
    }*/

    @IsTest
    static void testEmitirPropostaCancelamento(){

        Test.setMock(HttpCalloutMock.class, new MockHttpResponse('{}', 200, 'OK'));
        Test.startTest();

        payloadTO = gerarPayloadTO();

        payloadTO.proposta.meioComercializacao = PROPOSTA_MEIO_COMERCIALIZACAO_ARQUIVO;
        payloadTO.proposta.tipoSeguro = PROPOSTA_TIPO_SEGURO_CANCELAMENTO;
        payloadTO.proposta.tipoEndosso = PROPOSTA_TIPO_ENDOSSO_DESISTENCIA;
        payloadTO.proposta.dataCancelamento = String.valueOf(System.today());

        System.debug('GERACAO PAYLOAD');
        System.debug(JSON.serialize(payloadTO, true));

        RestRequest request = new RestRequest();
        request.requestUri ='/services/apexrest/proposta/massificados/cancelamento';
        request.httpMethod = 'POST';
        request.requestBody = Blob.valueOf(Json.serialize(payloadTO));

        RestContext.request = request;
        RestContext.response = new RestResponse();

        PropostaREST.processarPost();

        // get response in map
        Map<String, Object> mapReturnObjectsByParam = (Map<String, Object>) JSON.deserializeUntyped(RestContext.response.responseBody.toString());
        RetornoPropostaRestTO.ValidacaopropostaTO retorno = (RetornoPropostaRestTO.ValidacaopropostaTO) JSON.deserialize(JSON.serialize(mapReturnObjectsByParam.get('data')), RetornoPropostaRestTO.ValidacaopropostaTO.class);
        RetornoRestTO.MetaTO metaTO = (RetornoRestTO.MetaTO) JSON.deserialize(JSON.serialize(mapReturnObjectsByParam.get('meta')),RetornoRestTO.MetaTO.class);

        System.debug('RETORNO DA GERACAO DE PROPOSTA DE CANCELAMENTO');
        System.debug(JSON.serialize(retorno, true));
        //PLV-5795 FIX-01 INICIO
        // Recupera os segurados e seus filhos gerados
        // System.assertEquals('REMOVER',JSON.serialize(retorno));
        //List<SeguradoProposta__c> listSeguradoProposta = [ SELECT Id,(SELECT Id FROM BeneficiariosSeguradosProposta__r),(SELECT Id FROM GarantiasSeguradoProposta__r) FROM SeguradoProposta__c WHERE GrupoProposta__r.ContratanteProposta__r.Proposta__r.NumeroProposta__c =: String.valueOf(retorno.proposta.numero).leftPad(8,'0') ];
        //List<BeneficiarioSeguradoProposta__c> listBeneficiarioSeguradoproposta = listSeguradoProposta[0].BeneficiariosSeguradosProposta__r;
        //List<GarantiaSeguradoProposta__c> listGarantiaSeguradoProposta = listSeguradoProposta[0].GarantiasSeguradoProposta__r;

        // Recupera os grupos e seus filhos gerados
        //List<GrupoProposta__c> listGrupoProposta = [ SELECT Id, (SELECT Id FROM GarantiasGrupoProposta__r) FROM GrupoProposta__c WHERE ContratanteProposta__r.Proposta__r.NumeroProposta__c =: String.valueOf(retorno.proposta.numero).leftPad(8,'0') ];
        //List<GarantiasGrupoProposta__c> listGarantiaGrupoProposta = listGrupoProposta[0].GarantiasGrupoProposta__r;

        // Recupera os contratantes e seus filhos gerados
        //List<ContratanteProposta__c> listContratanteProposta = [ SELECT Id, (SELECT Id FROM GarantiasContratanteProposta__r) FROM ContratanteProposta__c WHERE Proposta__r.NumeroProposta__c =: String.valueOf(retorno.proposta.numero).leftPad(8,'0') ];
        //List<GarantiaContratanteProposta__c> listGarantiaContratanteProposta = listContratanteProposta[0].GarantiasContratanteProposta__r;

        // Recupera a proposta e seus filhos gerados
        //Quote proposta = [ SELECT Id, ContractId, (SELECT Id FROM GarantiasProposta__r), (SELECT Id FROM CriticasProposta__r) FROM Quote WHERE NumeroProposta__c =: String.valueOf(retorno.proposta.numero).leftPad(8,'0') LIMIT 1];
        //List<GarantiaProposta__c> listGarantiaProposta = proposta.GarantiasProposta__r;
        //List<CriticaProposta__c> listCriticaProposta = proposta.CriticasProposta__r;

        Test.stopTest();

        System.assertEquals(metaTO.statusHttp,200);
        System.assertEquals(metaTO.statusHttp,200);
        System.debug('Danilo código: '+ retorno.devolutivas[0].codigo);
        //PLV-5884 FIX-02 INICIO
        //System.assertEquals(retorno.devolutivas[0].codigo, 0); 
        //System.assert(retorno.proposta.numero != null);
        //PLV-5884 FIX-02 FIM
        //System.assert(proposta.ContractId != null);
        //System.assert(!listSeguradoProposta.isEmpty());
        //System.assert(!listBeneficiarioSeguradoproposta.isEmpty());
        //System.assert(!listGarantiaSeguradoProposta.isEmpty());
        //System.assert(!listGrupoProposta.isEmpty());
        //System.assert(!listGarantiaGrupoProposta.isEmpty());
        //System.assert(!listContratanteProposta.isEmpty());
        //System.assert(!listGarantiaContratanteProposta.isEmpty());
        //System.assert(!listGarantiaProposta.isEmpty());
        //System.assert(!listCriticaProposta.isEmpty());
        //PLV-5795 FIX-01 FIM
    }

    @IsTest
    static void testEmitirPropostaCancelamentoSemProposta(){

        Test.setMock(HttpCalloutMock.class, new MockHttpResponse('{}', 200, 'OK'));
        Test.startTest();

        payloadTO = gerarPayloadTO();

        payloadTO.proposta.meioComercializacao = PROPOSTA_MEIO_COMERCIALIZACAO_ARQUIVO;
        payloadTO.proposta.tipoSeguro = PROPOSTA_TIPO_SEGURO_CANCELAMENTO;
        payloadTO.proposta.tipoEndosso = PROPOSTA_TIPO_ENDOSSO_DESISTENCIA;
        payloadTO.proposta.dataCancelamento = String.valueOf(System.today());

        System.debug('GERACAO PAYLOAD');
        System.debug(JSON.serialize(payloadTO, true));

        List<Quote> propostaCriada = [SELECT id FROM quote];
        delete propostaCriada;
        List<Contract> contractsCriados = [SELECT id FROM contract];
        for(contract contractCriado : contractsCriados){
            contractCriado.Proposta__c = null;
        }
        update contractsCriados;

        RestRequest request = new RestRequest();
        request.requestUri ='/services/apexrest/proposta/massificados/cancelamento';
        request.httpMethod = 'POST';
        request.requestBody = Blob.valueOf(Json.serialize(payloadTO));

        RestContext.request = request;
        RestContext.response = new RestResponse();

        PropostaREST.processarPost();

        // get response in map
        
        Map<String, Object> mapReturnObjectsByParam = (Map<String, Object>) JSON.deserializeUntyped(RestContext.response.responseBody.toString());
        RetornoPropostaRestTO.ValidacaopropostaTO retorno = (RetornoPropostaRestTO.ValidacaopropostaTO) JSON.deserialize(JSON.serialize(mapReturnObjectsByParam.get('data')), RetornoPropostaRestTO.ValidacaopropostaTO.class);
        RetornoRestTO.MetaTO metaTO = (RetornoRestTO.MetaTO) JSON.deserialize(JSON.serialize(mapReturnObjectsByParam.get('meta')),RetornoRestTO.MetaTO.class);

        Test.stopTest();

        System.assertEquals(metaTO.statusHttp,200);
        System.assertEquals(metaTO.statusHttp,200);
        System.debug('Danilo código: '+ retorno.devolutivas[0].codigo);
    }

    private static EmissaoTO.PayloadTO gerarPayloadTO(){

        // Instancias
        payloadTO = new EmissaoTO.PayloadTO();
        payloadTO.proposta = new EmissaoTO();
        payloadTO.calculo = new EmissaoTO.CalculoTO();
        payloadTO.calculo.precificacao = new EmissaoTO.PrecificacaoTO();
        payloadTO.proposta.contratoOriginal = new EmissaoTO();
        payloadTO.proposta.contratoOriginal.contratantes = new List<EmissaoTO.ContratanteTO>();
        payloadTO.proposta.contratoOriginal.precificacao = new EmissaoTO.PrecificacaoTO();
	// PLV-2372-29 INICIO
        Contract contratoOriginal = [SELECT Id, Proposta__c, Status FROM Contract WHERE Status = 'Emitido' LIMIT 1];
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
                WHERE Id =: contratoOriginal.Proposta__c
                LIMIT 1
        ];
	// PLV-2372-29 FIM

        // Popula o set de sigla de coberturas
        for(GarantiaProposta__c garantiaProposta : propostaOriginal.GarantiasProposta__r){
            setSiglaCobertura.add(garantiaProposta.Garantia__r.Sigla__c);
        }


        // 1o nivel
        payloadTO.proposta.meioComercializacao = PROPOSTA_MEIO_COMERCIALIZACAO_ARQUIVO;
        payloadTO.proposta.tipoSeguro = PROPOSTA_TIPO_SEGURO_CANCELAMENTO;
        payloadTO.proposta.tipoEndosso = PROPOSTA_TIPO_ENDOSSO_DESISTENCIA;
        payloadTO.proposta.dataCancelamento = String.valueOf(System.today());

        // gera os contratoOriginal
	// PLV-2372-29 INICIO
        popularContratoOriginal(payloadTO.proposta.contratoOriginal,propostaOriginal, contratoOriginal);
	// PLV-2372-29 FIM

        // Gera os contratantes
        for(Integer i = 0; i < quantidadeContratantes; i ++){
            payloadTO.proposta.contratoOriginal.contratantes.add(gerarContratanteTO(i+1, false, false));
        }

        // Popula a precificacao do contrato de cancelamento
        popularPrecificacaoTO(payloadTO.calculo.precificacao);

        // Popula a precificacao do contrato original
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

    // PLV-2372-29 INICIO
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
    // PLV-2372-29 FIM

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