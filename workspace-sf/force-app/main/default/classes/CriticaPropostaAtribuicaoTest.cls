//INICIO | PLV-4517
/*
*  @author Squad Avanxo 
*  @Descrição: Classe de Teste da CriticaPropostaAtribuicao
*/
@IsTest
public class CriticaPropostaAtribuicaoTest {
    
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
        CriticaProposta__c ctp1 = new CriticaProposta__c(Proposta__c = quote.id, MomentoAnalise__c = 'Análise interna'); //II-42 FIX01 INICO-FIM
        CriticaProposta__c ctp2 = new CriticaProposta__c(Proposta__c = quote.id, MomentoAnalise__c = 'Análise interna'); //II-42 FIX01 INICO-FIM
        insert new List<CriticaProposta__c>{ctp1,ctp2};
        
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
    public static void FilaAceitacao_Success(){
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
		//II-42 FIX01 FIM
        List<CriticaProposta__c> lstCritica = [SELECT Id, Name, Status__c, MomentoAnalise__c, Setor__c, Integracao__c FROM CriticaProposta__c];
        System.debug('lstCritica> ' +lstCritica);
        lstCritica[0].Status__c = 'Pendente';
        lstCritica[0].MomentoAnalise__c = 'Análise interna';
        lstCritica[0].Setor__c = 'Aceitação';

        lstCritica[1].Status__c = 'Pendente';
        lstCritica[1].MomentoAnalise__c = 'Recalculo';
        lstCritica[1].Setor__c = 'Aceitação'; // PLV-4619-VI - Inicio/Fim - Isabela Fin - Globant

        Test.startTest();
            update lstCritica;
        Test.stopTest();
        Group fila = [SELECT Id From Group Where Type = 'Queue' And DeveloperName = 'Filaaceitacao'];
        for(CriticaProposta__c critica :[SELECT Id, Name, OwnerId From CriticaProposta__c]){
            System.assertEquals(critica.OwnerId, fila.Id);
        }
    }

    @IsTest
    public static void FilaEmissao_Success(){
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
		//II-42 FIX01 FIM
        List<CriticaProposta__c> lstCritica = [SELECT Id, Name, Status__c, MomentoAnalise__c, Setor__c, Integracao__c FROM CriticaProposta__c];
        
        lstCritica[0].Status__c = 'Pendente';
        lstCritica[0].MomentoAnalise__c = 'Análise interna';
        update lstCritica;

        lstCritica[0].Setor__c = 'Emissão';
        
        lstCritica[1].Status__c = 'Em aprovação';
        lstCritica[1].Integracao__c = 'DOCUSIGN';

        Test.startTest();
            update lstCritica;
        Test.stopTest();
        Group fila = [SELECT Id From Group Where Type = 'Queue' And DeveloperName = 'Filaemissao'];
        for(CriticaProposta__c critica :[SELECT Id, Name, OwnerId From CriticaProposta__c]){
            System.assertEquals(critica.OwnerId, fila.Id);
        }
    }

    @IsTest
    public static void FilaPalavraFinal_Success(){
        List<CriticaProposta__c> lstCritica = [SELECT Id, Name, Status__c, MomentoAnalise__c, Setor__c, Integracao__c FROM CriticaProposta__c];
        
        lstCritica[0].Status__c = 'Pendente';
        lstCritica[0].MomentoAnalise__c = 'Palavra final';
        
        lstCritica[1].Status__c = 'Pendente';
        lstCritica[1].MomentoAnalise__c = 'Palavra final';

        Test.startTest();
            update lstCritica;
        Test.stopTest();
        Group fila = [SELECT Id From Group Where Type = 'Queue' And DeveloperName = 'FilaPalavrafinalaceitacao'];
        for(CriticaProposta__c critica :[SELECT Id, Name, OwnerId From CriticaProposta__c]){
            System.assertEquals(critica.OwnerId, fila.Id);
        }
    }

}
//FIM | PLV-4517