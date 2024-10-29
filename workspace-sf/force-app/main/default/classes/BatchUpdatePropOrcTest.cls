@IsTest
private class BatchUpdatePropOrcTest{
    
    @TestSetup
    static void makeData(){

        Recordtype REC_ID_PERSONACCOUNT = RecordTypeBO.buscarTipoRegistro('Account', 'PessoaFisica');

        Recordtype REC_ID_PERSONACCOUNT2 = RecordTypeBO.buscarTipoRegistro('Account', 'PessoaFisica');

        Recordtype REC_ID_PERSONACCOUNT3 = RecordTypeBO.buscarTipoRegistro('Account', 'PessoaFisica');


        Account contaTeste = new Account(
            RecordTypeId = REC_ID_PERSONACCOUNT.Id,
            FirstName = 'FRANCIS',
            LastName = 'LIU',
            Nacionalidade__c = 'Brasileira',
            CPF__c = '518.179.180-87',
            Rg__c = '232323231',
            DataExpedicao__c = Date.today(),
            OrgaoExpedidor__c = '123132',
            PersonBirthDate = (Date.today()-7300),
            EstadoCivil__c = 'Solteiro (a)',
            Sucursal__c = 'c'
        );
        insert contaTeste;

        Account contaCorretor1 = new Account(
            RecordTypeId = REC_ID_PERSONACCOUNT2.Id,
            FirstName = 'LIU',
            LastName = 'LIU',
            Nacionalidade__c = 'Brasileira',
            CPF__c = '149.613.666-77',
            Rg__c = '232323235',
            DataExpedicao__c = Date.today(),
            OrgaoExpedidor__c = '123132',
            PersonBirthDate = (Date.today()-7300),
            EstadoCivil__c = 'Solteiro (a)',
            Sucursal__c = 'a'
        );
        insert contaCorretor1;

        Account contaCorretor2 = new Account(
            RecordTypeId = REC_ID_PERSONACCOUNT3.Id,
            FirstName = 'FRAN',
            LastName = 'LIU',
            Nacionalidade__c = 'Brasileira',
            CPF__c = '149.613.666-76',
            Rg__c = '121212121',
            DataExpedicao__c = Date.today(),
            OrgaoExpedidor__c = '123131',
            PersonBirthDate = (Date.today()-7300),
            EstadoCivil__c = 'Solteiro (a)',
            Sucursal__c = 'b'
        );
        insert contaCorretor2;

        DadosCorretor__c dadosCorretor = TestDataFactory.gerarDadosCorretor(contaTeste);

        DadosCorretor__c dadosCorretor2 = TestDataFactory.gerarDadosCorretor(contaCorretor1);

        DadosCorretor__c dadosCorretor3 = TestDataFactory.gerarDadosCorretor(contaCorretor2);
    
        RamoSeguro__c ramoSegurado = TestDataFactory.gerarRamoSeguro(contaTeste);

        Modalidade__c modalidade = TestDataFactory.gerarModalidade(ramoSegurado);

        FormaPagamento__c formaPagamento = TestDataFactory.gerarFormaPagamento(ramoSegurado,modalidade,'Boleto','1234');

        CanalDistribuicao__c canalDistribuicao = TestDataFactory.gerarCanalDistribuicao();

        Product2 produtoTec = TestDataFactory.gerarProdutoTecnico();
        produtoTec.Status__c = 'Ativo';
        produtoTec.Segmento__c = 'Individual';
        update produtoTec;

        Product2 produtoCom = TestDataFactory.gerarProdutoComericial(produtoTec);
        produtoCom.Status__c ='Ativo';
        produtoCom.Segmento__c = 'Individual';
        update produtoCom;

        Opportunity orcamentoContratado = TestDataFactory.gerarOrcamentoObjeto(contaTeste, produtoCom, canalDistribuicao);
        orcamentoContratado.Type = 'Novo'; 
        orcamentoContratado.StageName = 'Disponível para contratação';  
        update orcamentoContratado;

        Quote proposta = TestDataFactory.gerarPropostaObjeto(produtoCom, ramoSegurado, contaTeste, dadosCorretor, orcamentoContratado, modalidade);
        proposta.Status = 'Disponível para Contração';
        proposta.Tipo__c = 'Novo';
        proposta.VigenciaInicial__c = System.today().addDays(10);
        proposta.NumeroProposta__c = '00001234';
        proposta.Origem__c = '18';
        proposta.QuantidadeParcelas__c = 12;
        update proposta;

        Contract contrato = TestDataFactory.gerarContratoObjeto(produtoCom, ramoSegurado, contaTeste, dadosCorretor, proposta);
        contrato.Proposta__c = proposta.Id;
        contrato.StatusRenovacao__c = 'Não renovado';
        contrato.AlteraFormaPagto__c = false;
        contrato.Empresa__c = '1';
        contrato.CodigoRamo__c = '1391';
        contrato.Sucursal__c = '35';
        contrato.NumeroApolice__c = '000002668';
        contrato.Endosso__c = '0';
        contrato.Name = '1-35-1391-000002668-0';
        contrato.FormaPagamento__c = formaPagamento.id;
        contrato.ValorPremio__c = 1000;
        contrato.Tipo__c = 'Novo';  
        contrato.TipoEndosso__c = 'INA';
        update contrato;
        
        TipoRemuneracao__c tipoRemuneracao = new TipoRemuneracao__c();
        tipoRemuneracao.Name = 'COMISSÃO';
        tipoRemuneracao.Descricao__c = 'Lorem ipsum dolor sit amet, consectetur adipisicing elit.';
        tipoRemuneracao.ModeloRecuperacao__c = 'Integral';
        tipoRemuneracao.Codigo__c = 'COM';
        tipoRemuneracao.LimiteMinimo__c = 10;
        tipoRemuneracao.LimiteMaximo__c = 50;
        INSERT tipoRemuneracao;

        RemuneracaoContrato__c remuneracaoContrato = new RemuneracaoContrato__c();
        remuneracaoContrato.Contrato__c = contrato.Id;
        remuneracaoContrato.TipoRemuneracao__c = tipoRemuneracao.Id;
        INSERT remuneracaoContrato;

        FavorecidoRemuneracaoContrato__c favorecidoRemuneracaoContrato = new FavorecidoRemuneracaoContrato__c();
        favorecidoRemuneracaoContrato.AntecipacaoComissao__c = true;
        favorecidoRemuneracaoContrato.Conta__c = contaTeste.Id;
        favorecidoRemuneracaoContrato.CorretorLider__c = true;
        favorecidoRemuneracaoContrato.DadosCorretor__c = dadosCorretor.Id;
        favorecidoRemuneracaoContrato.Papel__c = 'Corretor';
        favorecidoRemuneracaoContrato.Participacao__c = 50;
        favorecidoRemuneracaoContrato.RemuneracaoContrato__c = remuneracaoContrato.Id;
        favorecidoRemuneracaoContrato.Susep__c = '123';
        favorecidoRemuneracaoContrato.SusepEmissao__c = '123';
        favorecidoRemuneracaoContrato.SusepOficialCorretor__c = '123';
        favorecidoRemuneracaoContrato.SusepOrcamento__c = '123';

        TransferenciaCorretagem__c tranferenciaCorretagem = new TransferenciaCorretagem__c();
        tranferenciaCorretagem.PercPriCoCorretor__c = 50;
        tranferenciaCorretagem.PercSusepLider__c = 50;
        tranferenciaCorretagem.SusepAtual__c = dadosCorretor3.Id;
        tranferenciaCorretagem.SusepOriginal__c = dadosCorretor2.Id;
        tranferenciaCorretagem.TransferirCarteira__c = false;
        tranferenciaCorretagem.ValidoAte__c = System.today();
        insert tranferenciaCorretagem;

    }
}