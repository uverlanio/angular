/**
 * @description       : 
 * @author            : ChangeMeIn@UserSettingsUnder.SFDoc
 * @group             : 
 * @last modified on  : 01-20-2023
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
**/
//INICIO | PLV-4495
/*
*  @author Squad Avanxo 
*  @Descrição: Classe de Teste da CriticaPropostaStatus
*/
@IsTest
public class CriticaPropostaStatusTest {
    
    @TestSetup
    public static void setup(){
        
        TestDataFactory.gerarDadosSetup();
        SenhaCriptografia__c sCripto = new SenhaCriptografia__c(Name = 'Senha', Senha__c = 'TesteCrypto');
        insert sCripto;
        
        Account contaTeste = TestDataFactory.gerarConta();        
        Endereco__c endereco = TestDataFactory.gerarEndereco(contaTeste);
        RamoSeguro__c ramoSegurado = TestDataFactory.gerarRamoSeguro(contaTeste);              
        Garantia__c garantia = TestDataFactory.gerarGarantia();
        
        Garantia__c garantiaCobertura = TestDataFactory.gerarGarantia();
        garantiaCobertura.name = 'Invalidez Permanente Total';
        update garantiaCobertura;
        
        Garantia__c garantiaCobertura2 = TestDataFactory.gerarGarantia();
        garantiaCobertura2.name = 'Morte';
        update garantiaCobertura2;        
       
        RamoGarantia__c ramoGarantia = TestDataFactory.gerarRamoGarantia(garantia, ramoSegurado);
        
        Product2 produtoTec = TestDataFactory.gerarProdutoTecnico();
        produtoTec.Status__c = 'Ativo';
        produtoTec.Segmento__c ='Individual';
        update produtoTec;
        
        Product2 produtoCom = TestDataFactory.gerarProdutoComericial(produtoTec);
        Map<String,List<SObject>> mapListSObject = TestDataFactory.gerarProdutoComercialAtivo(false);
        produtoCom.Status__c ='Ativo';
        produtoCom.Segmento__c ='Individual';        
        update produtoCom;
        
        
        CanalDistribuicao__c canalDistribuicao = TestDataFactory.gerarCanalDistribuicao();
        canalDistribuicao.Status__c = 'Ativo';
        update canalDistribuicao;
        
        ProdutoCanal__c produtoCanal = TestDataFactory.gerarProdutoCanal(canalDistribuicao, produtoCom);
        FormaPagamento__c formaPagamento = TestDataFactory.gerarFormaPagamento();
        Parceiro__C parceiro = TestDataFactory.gerarParceiro(contaTeste, formaPagamento);
        ProdutoParceiro__c produtoParceiro = TestDataFactory.gerarProdutoParceiro(parceiro, produtoCom);       
        Opportunity opp = TestDataFactory.gerarOrcamentoObjeto(contaTeste, produtoCom, canalDistribuicao);        
        
        GarantiaOrcamento__c garantiaOrcamento = TestDataFactory.gerarGarantiaOrcamento(garantiaCobertura,opp);
        garantiaOrcamento.PremioTotal__c=100;
        update garantiaOrcamento;
        
        GarantiaOrcamento__c garantiaOrcamento2 = TestDataFactory.gerarGarantiaOrcamento(garantiaCobertura2,opp);   
        
        DadosCorretor__c dadosCorretor = TestDataFactory.gerarDadosCorretor(contaTeste);
        TipoRemuneracao__c tipoRemuneracao = TestDataFactory.gerarTipoRemuneracao('COR', 100, 200, null);
        InformacaoBancaria__c InformacaoBancaria = TestDataFactory.gerarInformacaoBancaria(contaTeste);
        RemuneracaoProdutoParceiro__c RemuneracaoProdutoParceiro = TestDataFactory.gerarRemuneracaoProdutoParceiro(tipoRemuneracao, produtoParceiro, 20);
        FavorecidoRemuneracao__c favorecidoRemuneracao = TestDataFactory.gerarFavorecidoRemuneracao(contaTeste, 20.00, 'Corretor', true, remuneracaoProdutoParceiro,dadosCorretor, informacaoBancaria);        
        
        Modalidade__c modalidade = TestDataFactory.gerarModalidade(ramoSegurado);
        Quote quote = TestDataFactory.gerarPropostaObjeto(produtoCom, ramoSegurado, contaTeste, dadosCorretor, opp, modalidade);
        List<String> momentos = new List<String>{'Análise interna', 'Subscrição', 'Resseguro', 'Recalculo', 'Palavra final'};
        Integer qtd = 2;
        List<CriticaProposta__c> lstCritica = new List<CriticaProposta__c>();
        for(Integer i = 0; i < qtd; i++){
            for(String  momento : momentos){
                CriticaProposta__c critica = new CriticaProposta__c(Proposta__c = quote.Id, MomentoAnalise__c = momento,Status__c = 'Não iniciada');
                lstCritica.add(critica);   
            }
        }
        System.debug('lstCritica >>' + lstCritica);
        insert lstCritica;
        
        //PLV-4790 FIX 12 - INÍCIO
        ContratanteProposta__c segurado = new ContratanteProposta__c(
        conta__c = contaTeste.Id,
        Proposta__c = quote.Id,
        Tipo__c = 'Principal',
        FormaPagamento__c = formaPagamento.Id
            );
        insert segurado;
        //PLV-4790 FIX 12 - FIM

    }

    @IsTest
    public static void automacaoProposta_Success(){
        Quote proposta = [SELECT Id, Name, Status, FaseStatus__c FROM Quote];
        //II-42 FIXO1 INICIO
        List<ContratoTO.PayloadTO> payloadList = new List<ContratoTO.PayloadTO>();
        ContratoTO.PayloadTO payload = new ContratoTO.PayloadTO();
        payload.contrato = new ContratoTO();
        
        payload.contrato.segmento = '';
        payload.contrato.meioComercializacao = '';
        //payload.contrato.idSeguradoParceiro = '';
        payload.contrato.codigoEmpresa = '';
        payload.contrato.ramoSeguro = '';
        payload.contrato.vigenciaInicial = '';
        payload.contrato.tipoVigencia = '';
        payload.contrato.origem = 0;
        payload.contrato.tipoSeguro = '';
        payload.contrato.numeroEndosso = 0;
        payload.contrato.canalDistribuicao = '';
        payload.contrato.nomeEmpresa = '';
        payload.contrato.numero = '';
        payload.contrato.codigoSucursal = '';
        payload.contrato.nomeRamoSeguro = '';
        payload.contrato.vigenciaFinal = '';
        payload.contrato.valorPremio = 0.0;
        payload.contrato.idContratoParceiro = '';
        payload.contrato.dataCalculo = '';
        payload.contrato.numeroApolice = 0;
        payload.contrato.nomeProduto = '';
        payload.contrato.codigoProdutoVida = '';
        payload.contrato.parceiro = '';
        payload.contrato.numeroSusepProduto = '';
        payload.contrato.nomeCanalDistribuicao = '';
        
        payload.contrato.geracaoApolice = new ContratoTO.GeracaoapoliceTO();
        payload.contrato.geracaoApolice.unidadeNegocio = '';
        payload.contrato.geracaoApolice.nomeArquivoJasper = '';
        payload.contrato.geracaoApolice.leituraApartir = '';
        payload.contrato.geracaoApolice.centroDeCustoPagador = '';
        payload.contrato.geracaoApolice.tipoExtensaoGerada = '';
        payload.contrato.geracaoApolice.idAplicacaoUtilizadora = '';
        payload.contrato.geracaoApolice.nomeRelatorioGerado = '';
        payload.contrato.geracaoApolice.fileSystem = '';
        payload.contrato.geracaoApolice.nomeDiretorioArquivo = '';
        payload.contrato.geracaoApolice.assinaturaDiretor = '';
        
        payload.contrato.geracaoApolice.arquivo = new ContratoTO.ArquivoTO();
        payload.contrato.geracaoApolice.arquivo.textoInformativo = '';
        payload.contrato.geracaoApolice.arquivo.mensagemAssistenciaFuneral = '';
        payload.contrato.geracaoApolice.arquivo.exibirMensagemRenovacao  = '';
        payload.contrato.geracaoApolice.arquivo.mensagemProcessoSusep  = '';
        payload.contrato.geracaoApolice.arquivo.numeroProcessoSusepCNSP315  = '';
        payload.contrato.geracaoApolice.arquivo.unidadeOperacional  = '';
        
        payload.contrato.geracaoApolice.arquivo.observacoes = new ContratoTO.ObservacoesTO();
        payload.contrato.geracaoApolice.arquivo.observacoes.condicoesGerais = '';
        
        payload.contrato.geracaoApolice.arquivo.cabecalho = new ContratoTO.CabecalhoTO();
        payload.contrato.geracaoApolice.arquivo.cabecalho.image = ''; 
        
        payloadList.add(payload);
       
        Test.setMock(HttpCalloutMock.class, new MockHttpResponse(JSON.serialize(payloadList), 200, 'OK')); 
        Test.startTest();
        proposta.Status = 'Em análise';
        update proposta;
        Test.stopTest();
        //for(CriticaProposta__c critica : [SELECT Id, Name, Status__c FROM CriticaProposta__c WHERE Proposta__c =: proposta.Id AND MomentoAnalise__c = 'Análise interna']){
            //System.assertEquals(critica.Status__c, 'Pendente');
        //}
        //proposta = [SELECT Id, Name, Status, FaseStatus__c FROM Quote WHERE Id =: proposta.Id];
        //System.assertEquals(proposta.FaseStatus__c, 'Análise interna');
        //II-42 FIXO1 FIM

    }

    @IsTest
    public static void automacaoCriticaAnaliseInternaAprovada_Success(){
        //II-42 FIXO1 INICIO
        List<ContratoTO.PayloadTO> payloadList = new List<ContratoTO.PayloadTO>();
        ContratoTO.PayloadTO payload = new ContratoTO.PayloadTO();
        payload.contrato = new ContratoTO();
        
        payload.contrato.segmento = '';
        payload.contrato.meioComercializacao = '';
        //payload.contrato.idSeguradoParceiro = '';
        payload.contrato.codigoEmpresa = '';
        payload.contrato.ramoSeguro = '';
        payload.contrato.vigenciaInicial = '';
        payload.contrato.tipoVigencia = '';
        payload.contrato.origem = 0;
        payload.contrato.tipoSeguro = '';
        payload.contrato.numeroEndosso = 0;
        payload.contrato.canalDistribuicao = '';
        payload.contrato.nomeEmpresa = '';
        payload.contrato.numero = '';
        payload.contrato.codigoSucursal = '';
        payload.contrato.nomeRamoSeguro = '';
        payload.contrato.vigenciaFinal = '';
        payload.contrato.valorPremio = 0.0;
        payload.contrato.idContratoParceiro = '';
        payload.contrato.dataCalculo = '';
        payload.contrato.numeroApolice = 0;
        payload.contrato.nomeProduto = '';
        payload.contrato.codigoProdutoVida = '';
        payload.contrato.parceiro = '';
        payload.contrato.numeroSusepProduto = '';
        payload.contrato.nomeCanalDistribuicao = '';
        
        payload.contrato.geracaoApolice = new ContratoTO.GeracaoapoliceTO();
        payload.contrato.geracaoApolice.unidadeNegocio = '';
        payload.contrato.geracaoApolice.nomeArquivoJasper = '';
        payload.contrato.geracaoApolice.leituraApartir = '';
        payload.contrato.geracaoApolice.centroDeCustoPagador = '';
        payload.contrato.geracaoApolice.tipoExtensaoGerada = '';
        payload.contrato.geracaoApolice.idAplicacaoUtilizadora = '';
        payload.contrato.geracaoApolice.nomeRelatorioGerado = '';
        payload.contrato.geracaoApolice.fileSystem = '';
        payload.contrato.geracaoApolice.nomeDiretorioArquivo = '';
        payload.contrato.geracaoApolice.assinaturaDiretor = '';
        
        payload.contrato.geracaoApolice.arquivo = new ContratoTO.ArquivoTO();
        payload.contrato.geracaoApolice.arquivo.textoInformativo = '';
        payload.contrato.geracaoApolice.arquivo.mensagemAssistenciaFuneral = '';
        payload.contrato.geracaoApolice.arquivo.exibirMensagemRenovacao  = '';
        payload.contrato.geracaoApolice.arquivo.mensagemProcessoSusep  = '';
        payload.contrato.geracaoApolice.arquivo.numeroProcessoSusepCNSP315  = '';
        payload.contrato.geracaoApolice.arquivo.unidadeOperacional  = '';
        
        payload.contrato.geracaoApolice.arquivo.observacoes = new ContratoTO.ObservacoesTO();
        payload.contrato.geracaoApolice.arquivo.observacoes.condicoesGerais = '';
        
        payload.contrato.geracaoApolice.arquivo.cabecalho = new ContratoTO.CabecalhoTO();
        payload.contrato.geracaoApolice.arquivo.cabecalho.image = ''; 
        
        payloadList.add(payload);
       
        Test.setMock(HttpCalloutMock.class, new MockHttpResponse(JSON.serialize(payloadList), 200, 'OK'));
        Quote proposta = [SELECT Id, Name, Status, FaseStatus__c FROM Quote];
        proposta.Status = 'Em análise';
        update proposta;
        List<CriticaProposta__c> lstCritica = [SELECT Id, Name, Status__c FROM CriticaProposta__c WHERE Proposta__c =: proposta.Id AND MomentoAnalise__c = 'Análise interna'];
        System.assertEquals(lstCritica.size(), 2);
        lstCritica[0].Status__c = 'Liberado';
        update lstCritica[0];
        Test.startTest();
        lstCritica[1].Status__c = 'Liberado';
        update lstCritica[1];
        Test.stopTest();
        // proposta = [SELECT Id, Name, Status, FaseStatus__c FROM Quote WHERE Id =: proposta.Id];
        // System.assertEquals(proposta.FaseStatus__c, 'Subscrição');
        // for(CriticaProposta__c critica : [SELECT Id, Name, Status__c FROM CriticaProposta__c WHERE Proposta__c =: proposta.Id AND MomentoAnalise__c = 'Subscrição']){
        //     //System.assertEquals(critica.Status__c, 'Pendente'); //II-42 INICIO-FIM
        // }
        //II-42 FIXO1 FIM
    }

    //PLV-5311-FIX - INICIO
    /*
    @IsTest
    public static void automacaoCriticaSubscricaoAprovada_Success(){
        Quote proposta = [SELECT Id, Name, Status, FaseStatus__c FROM Quote];
        proposta.Status = 'Em análise';
        proposta.FaseStatus__c = 'Subscrição';
        update proposta;
        List<CriticaProposta__c> lstCritica = [SELECT Id, Name, Status__c FROM CriticaProposta__c WHERE Proposta__c =: proposta.Id AND MomentoAnalise__c = 'Subscrição'];
        System.assertEquals(lstCritica.size(), 2);
        lstCritica[0].Status__c = 'Condicionada';
        update lstCritica[0];
        Test.startTest();
        lstCritica[1].Status__c = 'Condicionada';
        update lstCritica[1];
        Test.stopTest();
        proposta = [SELECT Id, Name, Status, FaseStatus__c FROM Quote WHERE Id =: proposta.Id];
        System.assertEquals(proposta.FaseStatus__c, 'Resseguro');
        for(CriticaProposta__c critica : [SELECT Id, Name, Status__c FROM CriticaProposta__c WHERE Proposta__c =: proposta.Id AND MomentoAnalise__c = 'Resseguro']){
            System.assertEquals(critica.Status__c, 'Pendente');
        }
    }*/
    //PLV-5311-FIX - FIM

    //PLV-5187 - INICIO
    @IsTest
    public static void automacaoCriticaRecalculoAprovada_Success(){
        Quote proposta = [SELECT Id, Name, Status, FaseStatus__c FROM Quote];
        proposta.Status = 'Em análise';
        proposta.FaseStatus__c = 'Recalculo';
        update proposta;
        List<CriticaProposta__c> lstCritica = [SELECT Id, Name, Status__c FROM CriticaProposta__c WHERE Proposta__c =: proposta.Id AND MomentoAnalise__c = 'Recalculo'];
        System.assertEquals(lstCritica.size(), 2);
        lstCritica[0].Status__c = 'Condicionada';
        update lstCritica[0];
        Test.startTest();
        lstCritica[1].Status__c = 'Pendente';
        update lstCritica[1];
        Test.stopTest();        
    }
    //PLV-5187 - FIM

    @IsTest
    public static void automacaoCriticaAnaliseInternaRejeitada_Success(){
        //II-42 FIXO1 INICIO
        List<ContratoTO.PayloadTO> payloadList = new List<ContratoTO.PayloadTO>();
        ContratoTO.PayloadTO payload = new ContratoTO.PayloadTO();
        payload.contrato = new ContratoTO();
        
        payload.contrato.segmento = '';
        payload.contrato.meioComercializacao = '';
        //payload.contrato.idSeguradoParceiro = '';
        payload.contrato.codigoEmpresa = '';
        payload.contrato.ramoSeguro = '';
        payload.contrato.vigenciaInicial = '';
        payload.contrato.tipoVigencia = '';
        payload.contrato.origem = 0;
        payload.contrato.tipoSeguro = '';
        payload.contrato.numeroEndosso = 0;
        payload.contrato.canalDistribuicao = '';
        payload.contrato.nomeEmpresa = '';
        payload.contrato.numero = '';
        payload.contrato.codigoSucursal = '';
        payload.contrato.nomeRamoSeguro = '';
        payload.contrato.vigenciaFinal = '';
        payload.contrato.valorPremio = 0.0;
        payload.contrato.idContratoParceiro = '';
        payload.contrato.dataCalculo = '';
        payload.contrato.numeroApolice = 0;
        payload.contrato.nomeProduto = '';
        payload.contrato.codigoProdutoVida = '';
        payload.contrato.parceiro = '';
        payload.contrato.numeroSusepProduto = '';
        payload.contrato.nomeCanalDistribuicao = '';
        
        payload.contrato.geracaoApolice = new ContratoTO.GeracaoapoliceTO();
        payload.contrato.geracaoApolice.unidadeNegocio = '';
        payload.contrato.geracaoApolice.nomeArquivoJasper = '';
        payload.contrato.geracaoApolice.leituraApartir = '';
        payload.contrato.geracaoApolice.centroDeCustoPagador = '';
        payload.contrato.geracaoApolice.tipoExtensaoGerada = '';
        payload.contrato.geracaoApolice.idAplicacaoUtilizadora = '';
        payload.contrato.geracaoApolice.nomeRelatorioGerado = '';
        payload.contrato.geracaoApolice.fileSystem = '';
        payload.contrato.geracaoApolice.nomeDiretorioArquivo = '';
        payload.contrato.geracaoApolice.assinaturaDiretor = '';
        
        payload.contrato.geracaoApolice.arquivo = new ContratoTO.ArquivoTO();
        payload.contrato.geracaoApolice.arquivo.textoInformativo = '';
        payload.contrato.geracaoApolice.arquivo.mensagemAssistenciaFuneral = '';
        payload.contrato.geracaoApolice.arquivo.exibirMensagemRenovacao  = '';
        payload.contrato.geracaoApolice.arquivo.mensagemProcessoSusep  = '';
        payload.contrato.geracaoApolice.arquivo.numeroProcessoSusepCNSP315  = '';
        payload.contrato.geracaoApolice.arquivo.unidadeOperacional  = '';
        
        payload.contrato.geracaoApolice.arquivo.observacoes = new ContratoTO.ObservacoesTO();
        payload.contrato.geracaoApolice.arquivo.observacoes.condicoesGerais = '';
        
        payload.contrato.geracaoApolice.arquivo.cabecalho = new ContratoTO.CabecalhoTO();
        payload.contrato.geracaoApolice.arquivo.cabecalho.image = ''; 
        
        payloadList.add(payload);
       
        Test.setMock(HttpCalloutMock.class, new MockHttpResponse(JSON.serialize(payloadList), 200, 'OK'));
        Quote proposta = [SELECT Id, Name, Status, FaseStatus__c FROM Quote];
        proposta.Status = 'Em análise';
        proposta.FaseStatus__c = 'Análise interna';
        proposta.CodigoMotivoDevolucao__c = '18'; //II-48 INCIO-FIM
        update proposta;
        List<CriticaProposta__c> lstCritica = [SELECT Id, Name, Status__c FROM CriticaProposta__c WHERE Proposta__c =: proposta.Id AND MomentoAnalise__c = 'Análise interna'];
        System.assertEquals(lstCritica.size(), 2);
        lstCritica[0].Status__c = 'Recusado';
        update lstCritica[0];
        Test.startTest();
        lstCritica[1].Status__c = 'Recusado';
        update lstCritica[1];
        Test.stopTest();
        // proposta = [SELECT Id, Name, Status, FaseStatus__c FROM Quote WHERE Id =: proposta.Id];
        // System.assertEquals(proposta.Status, 'Recusada');
        // System.assertEquals(proposta.FaseStatus__c, 'Análise interna');
        // for(CriticaProposta__c critica : [SELECT Id, Name, Status__c FROM CriticaProposta__c WHERE Proposta__c =: proposta.Id AND MomentoAnalise__c != 'Análise interna']){
        //     //System.assertEquals(critica.Status__c, 'Cancelada');//PLV-4944 - INICIO/FIM 
        // }
        //II-42 FIXO1 FIM
    }

    @IsTest
    public static void automacaoCriticaPalavraFinalRejeitada_Success(){
        //II-42 FIXO1 INICIO
        List<ContratoTO.PayloadTO> payloadList = new List<ContratoTO.PayloadTO>();
        ContratoTO.PayloadTO payload = new ContratoTO.PayloadTO();
        payload.contrato = new ContratoTO();
        
        payload.contrato.segmento = '';
        payload.contrato.meioComercializacao = '';
        //payload.contrato.idSeguradoParceiro = '';
        payload.contrato.codigoEmpresa = '';
        payload.contrato.ramoSeguro = '';
        payload.contrato.vigenciaInicial = '';
        payload.contrato.tipoVigencia = '';
        payload.contrato.origem = 0;
        payload.contrato.tipoSeguro = '';
        payload.contrato.numeroEndosso = 0;
        payload.contrato.canalDistribuicao = '';
        payload.contrato.nomeEmpresa = '';
        payload.contrato.numero = '';
        payload.contrato.codigoSucursal = '';
        payload.contrato.nomeRamoSeguro = '';
        payload.contrato.vigenciaFinal = '';
        payload.contrato.valorPremio = 0.0;
        payload.contrato.idContratoParceiro = '';
        payload.contrato.dataCalculo = '';
        payload.contrato.numeroApolice = 0;
        payload.contrato.nomeProduto = '';
        payload.contrato.codigoProdutoVida = '';
        payload.contrato.parceiro = '';
        payload.contrato.numeroSusepProduto = '';
        payload.contrato.nomeCanalDistribuicao = '';
        
        payload.contrato.geracaoApolice = new ContratoTO.GeracaoapoliceTO();
        payload.contrato.geracaoApolice.unidadeNegocio = '';
        payload.contrato.geracaoApolice.nomeArquivoJasper = '';
        payload.contrato.geracaoApolice.leituraApartir = '';
        payload.contrato.geracaoApolice.centroDeCustoPagador = '';
        payload.contrato.geracaoApolice.tipoExtensaoGerada = '';
        payload.contrato.geracaoApolice.idAplicacaoUtilizadora = '';
        payload.contrato.geracaoApolice.nomeRelatorioGerado = '';
        payload.contrato.geracaoApolice.fileSystem = '';
        payload.contrato.geracaoApolice.nomeDiretorioArquivo = '';
        payload.contrato.geracaoApolice.assinaturaDiretor = '';
        
        payload.contrato.geracaoApolice.arquivo = new ContratoTO.ArquivoTO();
        payload.contrato.geracaoApolice.arquivo.textoInformativo = '';
        payload.contrato.geracaoApolice.arquivo.mensagemAssistenciaFuneral = '';
        payload.contrato.geracaoApolice.arquivo.exibirMensagemRenovacao  = '';
        payload.contrato.geracaoApolice.arquivo.mensagemProcessoSusep  = '';
        payload.contrato.geracaoApolice.arquivo.numeroProcessoSusepCNSP315  = '';
        payload.contrato.geracaoApolice.arquivo.unidadeOperacional  = '';
        
        payload.contrato.geracaoApolice.arquivo.observacoes = new ContratoTO.ObservacoesTO();
        payload.contrato.geracaoApolice.arquivo.observacoes.condicoesGerais = '';
        
        payload.contrato.geracaoApolice.arquivo.cabecalho = new ContratoTO.CabecalhoTO();
        payload.contrato.geracaoApolice.arquivo.cabecalho.image = ''; 
        
        payloadList.add(payload);
       
        Test.setMock(HttpCalloutMock.class, new MockHttpResponse(JSON.serialize(payloadList), 200, 'OK'));
        Quote proposta = [SELECT Id, Name, Status, FaseStatus__c FROM Quote];
        proposta.Status = 'Em análise';
        proposta.FaseStatus__c = 'Palavra final';
        proposta.CodigoMotivoDevolucao__c = '18'; //II-48 INCIO-FIM
        update proposta;
        List<CriticaProposta__c> lstCritica = [SELECT Id, Name, Status__c FROM CriticaProposta__c WHERE Proposta__c =: proposta.Id AND MomentoAnalise__c = 'Palavra final'];
        System.assertEquals(lstCritica.size(), 3);
        lstCritica[0].Status__c = 'Recusado';
        update lstCritica[0];
        lstCritica[1].Status__c = 'Recusado';
        update lstCritica[1];
        lstCritica[2].Status__c = 'Recusado';
        Test.startTest();
        update lstCritica[2];
        Test.stopTest();
        // proposta = [SELECT Id, Name, Status, FaseStatus__c FROM Quote WHERE Id =: proposta.Id];
        // System.assertEquals(proposta.Status, 'Recusada');
        // System.assertEquals(proposta.FaseStatus__c, 'Palavra final');
        //II-42 FIXO1 FIM
    }

    //AV-796 - INICIO
    @IsTest
    public static void atualizaCriticaPropostaHub_Success(){
        //II-42 FIXO1 INICIO
        List<ContratoTO.PayloadTO> payloadList = new List<ContratoTO.PayloadTO>();
        ContratoTO.PayloadTO payload = new ContratoTO.PayloadTO();
        payload.contrato = new ContratoTO();
        
        payload.contrato.segmento = '';
        payload.contrato.meioComercializacao = '';
        //payload.contrato.idSeguradoParceiro = '';
        payload.contrato.codigoEmpresa = '';
        payload.contrato.ramoSeguro = '';
        payload.contrato.vigenciaInicial = '';
        payload.contrato.tipoVigencia = '';
        payload.contrato.origem = 0;
        payload.contrato.tipoSeguro = '';
        payload.contrato.numeroEndosso = 0;
        payload.contrato.canalDistribuicao = '';
        payload.contrato.nomeEmpresa = '';
        payload.contrato.numero = '';
        payload.contrato.codigoSucursal = '';
        payload.contrato.nomeRamoSeguro = '';
        payload.contrato.vigenciaFinal = '';
        payload.contrato.valorPremio = 0.0;
        payload.contrato.idContratoParceiro = '';
        payload.contrato.dataCalculo = '';
        payload.contrato.numeroApolice = 0;
        payload.contrato.nomeProduto = '';
        payload.contrato.codigoProdutoVida = '';
        payload.contrato.parceiro = '';
        payload.contrato.numeroSusepProduto = '';
        payload.contrato.nomeCanalDistribuicao = '';
        
        payload.contrato.geracaoApolice = new ContratoTO.GeracaoapoliceTO();
        payload.contrato.geracaoApolice.unidadeNegocio = '';
        payload.contrato.geracaoApolice.nomeArquivoJasper = '';
        payload.contrato.geracaoApolice.leituraApartir = '';
        payload.contrato.geracaoApolice.centroDeCustoPagador = '';
        payload.contrato.geracaoApolice.tipoExtensaoGerada = '';
        payload.contrato.geracaoApolice.idAplicacaoUtilizadora = '';
        payload.contrato.geracaoApolice.nomeRelatorioGerado = '';
        payload.contrato.geracaoApolice.fileSystem = '';
        payload.contrato.geracaoApolice.nomeDiretorioArquivo = '';
        payload.contrato.geracaoApolice.assinaturaDiretor = '';
        
        payload.contrato.geracaoApolice.arquivo = new ContratoTO.ArquivoTO();
        payload.contrato.geracaoApolice.arquivo.textoInformativo = '';
        payload.contrato.geracaoApolice.arquivo.mensagemAssistenciaFuneral = '';
        payload.contrato.geracaoApolice.arquivo.exibirMensagemRenovacao  = '';
        payload.contrato.geracaoApolice.arquivo.mensagemProcessoSusep  = '';
        payload.contrato.geracaoApolice.arquivo.numeroProcessoSusepCNSP315  = '';
        payload.contrato.geracaoApolice.arquivo.unidadeOperacional  = '';
        
        payload.contrato.geracaoApolice.arquivo.observacoes = new ContratoTO.ObservacoesTO();
        payload.contrato.geracaoApolice.arquivo.observacoes.condicoesGerais = '';
        
        payload.contrato.geracaoApolice.arquivo.cabecalho = new ContratoTO.CabecalhoTO();
        payload.contrato.geracaoApolice.arquivo.cabecalho.image = ''; 
        
        payloadList.add(payload);
       
        Test.setMock(HttpCalloutMock.class, new MockHttpResponse(JSON.serialize(payloadList), 200, 'OK'));
        //II-42 FIXO1 FIM
        Quote proposta = [SELECT Id, Name, Status, FaseStatus__c FROM Quote];
        proposta.Status = 'Em análise';
        update proposta;
        List<CriticaProposta__c> lstCritica = [SELECT Id, Name, Status__c, Origem__c FROM CriticaProposta__c WHERE Proposta__c =: proposta.Id LIMIT 1];
        lstCritica[0].Status__c = 'Pendente';
        lstCritica[0].Origem__c = 'HUB';
        update lstCritica[0];

        List<CriticaProposta__c> lstCritica1 = [SELECT Id, Name, Status__c FROM CriticaProposta__c WHERE Proposta__c =: proposta.Id LIMIT 1];
        System.assertEquals(lstCritica1.size(), 1);
        lstCritica1[0].Status__c = 'Liberado';
      
        Test.startTest();
            update lstCritica1[0];
        Test.stopTest();
        
    }
    
    @IsTest
    public static void atualizaCriticaPropostaHub_Recusado(){
        //II-42 FIXO1 INICIO
        List<ContratoTO.PayloadTO> payloadList = new List<ContratoTO.PayloadTO>();
        ContratoTO.PayloadTO payload = new ContratoTO.PayloadTO();
        payload.contrato = new ContratoTO();
        
        payload.contrato.segmento = '';
        payload.contrato.meioComercializacao = '';
        payload.contrato.codigoEmpresa = '';
        payload.contrato.ramoSeguro = '';
        payload.contrato.vigenciaInicial = '';
        payload.contrato.tipoVigencia = '';
        payload.contrato.origem = 0;
        payload.contrato.tipoSeguro = '';
        payload.contrato.numeroEndosso = 0;
        payload.contrato.canalDistribuicao = '';
        payload.contrato.nomeEmpresa = '';
        payload.contrato.numero = '';
        payload.contrato.codigoSucursal = '';
        payload.contrato.nomeRamoSeguro = '';
        payload.contrato.vigenciaFinal = '';
        payload.contrato.valorPremio = 0.0;
        payload.contrato.idContratoParceiro = '';
        payload.contrato.dataCalculo = '';
        payload.contrato.numeroApolice = 0;
        payload.contrato.nomeProduto = '';
        payload.contrato.codigoProdutoVida = '';
        payload.contrato.parceiro = '';
        payload.contrato.numeroSusepProduto = '';
        payload.contrato.nomeCanalDistribuicao = '';
        
        payload.contrato.geracaoApolice = new ContratoTO.GeracaoapoliceTO();
        payload.contrato.geracaoApolice.unidadeNegocio = '';
        payload.contrato.geracaoApolice.nomeArquivoJasper = '';
        payload.contrato.geracaoApolice.leituraApartir = '';
        payload.contrato.geracaoApolice.centroDeCustoPagador = '';
        payload.contrato.geracaoApolice.tipoExtensaoGerada = '';
        payload.contrato.geracaoApolice.idAplicacaoUtilizadora = '';
        payload.contrato.geracaoApolice.nomeRelatorioGerado = '';
        payload.contrato.geracaoApolice.fileSystem = '';
        payload.contrato.geracaoApolice.nomeDiretorioArquivo = '';
        payload.contrato.geracaoApolice.assinaturaDiretor = '';
        
        payload.contrato.geracaoApolice.arquivo = new ContratoTO.ArquivoTO();
        payload.contrato.geracaoApolice.arquivo.textoInformativo = '';
        payload.contrato.geracaoApolice.arquivo.mensagemAssistenciaFuneral = '';
        payload.contrato.geracaoApolice.arquivo.exibirMensagemRenovacao  = '';
        payload.contrato.geracaoApolice.arquivo.mensagemProcessoSusep  = '';
        payload.contrato.geracaoApolice.arquivo.numeroProcessoSusepCNSP315  = '';
        payload.contrato.geracaoApolice.arquivo.unidadeOperacional  = '';
        
        payload.contrato.geracaoApolice.arquivo.observacoes = new ContratoTO.ObservacoesTO();
        payload.contrato.geracaoApolice.arquivo.observacoes.condicoesGerais = '';
        
        payload.contrato.geracaoApolice.arquivo.cabecalho = new ContratoTO.CabecalhoTO();
        payload.contrato.geracaoApolice.arquivo.cabecalho.image = ''; 
        
        payloadList.add(payload);
       
        Test.setMock(HttpCalloutMock.class, new MockHttpResponse(JSON.serialize(payloadList), 200, 'OK'));
        //II-42 FIXO1 FIM
        Quote proposta = [SELECT Id, Name, Status, FaseStatus__c FROM Quote];
        proposta.Status = 'Em análise';
        proposta.CodigoMotivoDevolucao__c = '18'; //II-48 INCIO-FIM
        update proposta;
        List<CriticaProposta__c> lstCritica = [SELECT Id, Name, Status__c, Origem__c FROM CriticaProposta__c WHERE Proposta__c =: proposta.Id LIMIT 1];
        lstCritica[0].Status__c = 'Pendente';
        lstCritica[0].Origem__c = 'HUB';
        update lstCritica[0];



        List<CriticaProposta__c> lstCritica1 = [SELECT Id, Name, Status__c FROM CriticaProposta__c WHERE Proposta__c =: proposta.Id LIMIT 1];
        System.assertEquals(lstCritica1.size(), 1);
        lstCritica1[0].Status__c = 'Recusado';
      
        Test.startTest();
            update lstCritica1[0];
        Test.stopTest();
        
    }

    //AV-796 - FIM

}
//FIM | PLV-4495