//PLV-4772-INICIO
/*
*  @author Squad Avanxo 
*  @Descrição: Classe de teste da PayloadTransmissao
*/
@isTest 
public class PayloadTransmissaoTeste {
    @isTest
	private static void gerarEndossoPagamentoTest() {
        
        GrupoProfissoes__c grupoProfissao = new GrupoProfissoes__c();
        GrupoRisco__c grupoRisco = new GrupoRisco__c();
        Profissao__c profissao = new Profissao__c();

        profissao.CodigoProfissao__c = '2111-05';
        profissao.Name = 'Atuário';
        profissao.Status__c = 'Ativo';
        insert profissao;
        grupoRisco.Name = 'DIT';
        Insert grupoRisco;
        grupoProfissao.grupoRisco__c = grupoRisco.Id;
        grupoProfissao.profissao__c = profissao.Id;
        insert grupoProfissao;

        Account contaPessoal = (Account) new AccountFactory.PessoaFisica().createRecord();
        contaPessoal.Renda__c = 1902.00;
        contaPessoal.Profissao__c = profissao.Id;
        update contaPessoal;
        Garantia__c garantia = (Garantia__c) new GarantiaFactory().createRecord();
        Contact contato = (Contact) new ContactFactory().createRecord();
        ContadorCodigo__c contCodigoTec = (ContadorCodigo__c) new ContadorCodigoFactory.ProdutoTecnico().createRecord();
        ContadorCodigo__c contCodigoCom = (ContadorCodigo__c) new ContadorCodigoFactory.ProdutoComercial().createRecord();
        
        Product2 produtoTecnico = (Product2) new ProdutoFactory.ProdutoTecnico().createRecord();
        produtoTecnico.Status__c = 'Em ativação';
        produtoTecnico.NumeroSusep__c = '123';
        produtoTecnico.VersaoRenovacao__c = 'Versão atual';
        update produtoTecnico;
        produtoTecnico.Status__c = 'Ativo';
        update produtoTecnico;
        Product2 produtoComercial = (Product2) new ProdutoFactory.ProdutoComercial(produtoTecnico).createRecord();

        FormaPagamento__c formaPagamento = (FormaPagamento__c) new FormaPagamentoFactory().createRecord();
        Parceiro__c parceiro = (Parceiro__c) new ParceiroFactory(contaPessoal, formaPagamento).createRecord();
        ProdutoParceiro__c prodParc = (ProdutoParceiro__c) new ProdutoParceiroFactory(parceiro, produtoComercial).createRecord();
        OperacaoProdutoParceiro__c oProdParc = (OperacaoProdutoParceiro__c) new OperacaoProdutoParceiroFactory(prodParc).createRecord();

        Contract contrato = (Contract) new ContratoFactory.ContratoFactoryComParam(contaPessoal, produtoComercial, parceiro).createRecord();
        contrato.Origem__c = '18';
        contrato.CodigoRamo__c = '1381';
        contrato.FormaPagamento__c = formaPagamento.Id;
        update contrato;

        ContratanteContrato__c contratante = (ContratanteContrato__c) new ContratanteFactory(contrato).createRecord();
        contratante.Conta__c = contaPessoal.Id;
        update contratante;
        GrupoContrato__c grupo = (GrupoContrato__c) new GrupoFactory(contratante).createRecord();
        SeguradoContrato__c segurado = (SeguradoContrato__c) new SeguradoContratoFactory(contaPessoal, grupo).createRecord();

        RamoSeguro__c ramoSeguro = (RamoSeguro__c) new RamoSeguroFactory(contaPessoal).createRecord();
        RamoGarantia__c ramoGarantia = (RamoGarantia__c) new RamoGarantiaFactory(garantia, ramoSeguro).createRecord();
        GarantiaProduto__c garanProdTec = (GarantiaProduto__c) new GarantiaProdutoFactory.GarantiaProdutoTec(garantia, produtoTecnico, ramoSeguro).createRecord();
        garanProdTec.CancelaGarantia__c = true;
        garanProdTec.PercentualMaximoCancelamento__c = 100;
        update garanProdTec;
        GarantiaProduto__c garanProdCom = (GarantiaProduto__c) new GarantiaProdutoFactory.GarantiaProdutoCom(produtoComercial, garantia, garanProdTec, ramoSeguro).createRecord();
        
        DadosCorretor__c dadosCorretor = (DadosCorretor__c) new DadosCorretorFactory(contaPessoal).createRecord();
        TipoRemuneracao__c tipoRemuneracao = (TipoRemuneracao__c) new TipoRemuneracaoFactory().createRecord();
        RemuneracaoContrato__c remCont = (RemuneracaoContrato__c) new RemuneracaoContratoFactory(tipoRemuneracao, contrato).createRecord();
        FavorecidoRemuneracaoContrato__c favRemCont = (FavorecidoRemuneracaoContrato__c) new FavorecidoRemuneracaoContratoFactory(remCont, dadosCorretor).createRecord();

        ControleIntegracao__c controlInte = (ControleIntegracao__c) new ControleIntegracaoFactory().createRecord();
        
        Case casoAtendimento = (Case) new CasoFactory.AtendimentoSinistro().createRecord();
        InformacaoBancaria__c infoBanc = (InformacaoBancaria__c) new InformacaoBancariaFactory.InfoPessoaFisica(contaPessoal).createRecord();
        GarantiaSeguradoContrato__c garantiaSeguradoContrato = (GarantiaSeguradoContrato__c) new GarantiaSeguradoContratoFactory(segurado, garantia).createRecord();
        garantiaSeguradoContrato.GarantiaProduto__c = garanProdTec.Id;
        update garantiaSeguradoContrato;
        
        GarantiaContrato__c garantiaContract = new GarantiaContrato__c();
        garantiaContract.Contrato__c = contrato.Id;
        garantiaContract.GarantiaProduto__c = garanProdTec.Id;    
        garantiaContract.Garantia__c = garantia.Id;
        insert garantiaContract;
        Endereco__c endereco = TestDataFactory.gerarEndereco(contaPessoal);
        Recordtype REC_ID_CASESINISTRO = RecordTypeBO.buscarTipoRegistro('Case', 'Sinistro');
        
		Case casoSinistro =  new Case(
            RecordTypeId = REC_ID_CASESINISTRO.Id,
            Status = 'Avisar',
            Status_Dependente__c = 'Em Análise',
            Origin = 'Atendimento',
            Contrato__c = contrato.Id,
            ParentId = casoAtendimento.Id,
            AccountId = contaPessoal.Id,
            Subject = 'Test Caso Sinistro',
            Vitima__c = 'Filhos',
            IdPrestadora__c = 'Teste',
            Description = 'TestCasoSinistro',
            Dataocorrencia__c = System.today(),
            Type = 'Sinistro',
            TipoEvento__c = 'Acidente');
            insert casoSinistro;
            
            Case casoSinistro2 =  new Case(
                RecordTypeId = REC_ID_CASESINISTRO.Id,
				Status = 'Avisar',
				Status_Dependente__c = 'Em Análise',
				Origin = 'Atendimento',
                Contrato__c = contrato.Id,
				ParentId = casoAtendimento.Id,
				AccountId = contaPessoal.Id,
				Subject = 'Test Caso Sinistro',
				Vitima__c = 'Filhos',
				Description = 'TestCasoSinistro',
				Dataocorrencia__c = System.today(),
				Type = 'Sinistro',
            	Lista_de_pendencias__c = 'RG',
				TipoEvento__c = 'Acidente');
                insert casoSinistro2;
                
                PagamentoGarantia__c pagamentoGarantia = (PagamentoGarantia__c) new PagamentoGarantiaFactory(casoSinistro2, garantiaSeguradoContrato).createRecord();
                pagamentoGarantia.Garantia_do_segurado_do_contrato__c =  garantiaSeguradoContrato.Id;
                update pagamentoGarantia;
                Date dtPagamento = system.today().addDays(+20);
                
                String mock = '{"ofertas":[{'
                                    +'"orcamento":{'
                                        +'"numeroOrcamento":"32446"'
                                        +'}'
                                    +'}'
                                +']'
                                +'}';
                Test.setMock(HttpCalloutMock.class, new MockHttpResponse(mock, 200, 'OK'));

                Test.startTest();
                
                Integer emailbefore = Limits.getEmailInvocations();
                
                
                Pagamento_de_Sinistro__c pagamento = new Pagamento_de_Sinistro__c();
                pagamento.Caso_de_Sinistro__c               = casoSinistro.Id;
                pagamento.Status__c                         = 'Liberado';
                pagamento.Data_Programada_de_Pagamento__c   = dtPagamento;
                insert pagamento;
                
                pagamento.Status__c                         = 'Em pagamento';        	
                update pagamento;
                
                
                
                Pagamento_de_Sinistro__c pagamento2 = new Pagamento_de_Sinistro__c();
                pagamento2.Caso_de_Sinistro__c               = casoSinistro2.Id;
                pagamento2.Status__c                         = 'Em pagamento';
                pagamento2.Data_Programada_de_Pagamento__c   = dtPagamento;
                pagamento2.Valor_total_a_ser_indenizado__c   = 1000;
            insert pagamento2;
	
        	Pagamento_de_Sinistro__c pagamento3 = new Pagamento_de_Sinistro__c();
            pagamento3.Caso_de_Sinistro__c               = casoSinistro2.Id;
            pagamento3.Status__c                         = 'Cancelado';
            pagamento3.Data_Programada_de_Pagamento__c   = dtPagamento;
            pagamento2.Valor_total_a_ser_indenizado__c   = 1000000;
            pagamento3.Tipo_de_OP__c = 'Indenização';
            pagamento3.OP_SAP__c = casoSinistro.Id;
            insert pagamento3; 
            List<Pagamento_de_Sinistro__c> listPagamentos = new List<Pagamento_de_Sinistro__c>();
            listPagamentos.add(pagamento2);
            listPagamentos.add(pagamento3);

            set<Id> sCasos = new set<Id>();
            sCasos.add(casoSinistro2.Id);
            set<Id> sPag = new set<Id>();
            sPag.add(pagamento3.Id);
                        
            EmissaoTO orcamento = new EmissaoTO();
            orcamento.numeroOrcamento = '00005369';
            EmissaoTO.VersoesCalculo vc = new EmissaoTO.VersoesCalculo();
            vc.tipo = 'FPG';
            vc.opcao = 3;
            vc.descontoAgravo = -15;
            orcamento.versoesCalculos = new List<EmissaoTO.VersoesCalculo>();
            orcamento.versoesCalculos.add(vc);
            orcamento.contratoOriginal = new EmissaoTO();
            orcamento.contratoOriginal.numeroOrcamento = '000025637';
            orcamento.contratoOriginal.codigoProdutoVida = 'VI-PESSOAS';
            EmissaoTO.RemuneracaoTO remuneracao = new EmissaoTO.RemuneracaoTO();
            remuneracao.tipoRemuneracao = 'COR';
            remuneracao.percentual = 25;
            EmissaoTo.FavorecidoTO favorecido = new EmissaoTo.FavorecidoTO();
            favorecido.susep = 'P5005J';
            favorecido.pessoa = new EmissaoTO.PessoaTO();
            favorecido.pessoa.nome = 'Teste test';
            favorecido.participacao = 100;
            favorecido.papel = 'Corretor';
            favorecido.corretorLider = true;
            remuneracao.favorecidos = new List<EmissaoTO.FavorecidoTO>();
            remuneracao.favorecidos.add(favorecido);
            orcamento.contratoOriginal.remuneracoes = new List<EmissaoTO.RemuneracaoTO>();
            orcamento.contratoOriginal.remuneracoes.add(remuneracao);
            orcamento.contratoOriginal.precificacao = new EmissaoTO.PrecificacaoTO();



            orcamento.contratoOriginal.precificacao.premio = new EmissaoTO.PremioTO();
            orcamento.contratoOriginal.precificacao.premio.total = 1493.39;
            orcamento.contratoOriginal.precificacao.premio.puro = 673.4;
            orcamento.contratoOriginal.precificacao.premio.comercial = 1487.75;
            orcamento.contratoOriginal.precificacao.juros = 0;
            orcamento.contratoOriginal.precificacao.iof = 0.01;
            orcamento.contratoOriginal.precificacao.encargos = 0;
            EmissaoTO.DescontoAgravoTO descAgravo = new EmissaoTO.DescontoAgravoTO();
            descAgravo.tipo = '';
            descAgravo.percentual = 0;
            descAgravo.monetario = 0;
            orcamento.contratoOriginal.precificacao.descontoAgravo = new List<EmissaoTO.DescontoAgravoTO>();
            orcamento.contratoOriginal.precificacao.descontoAgravo.add(descAgravo);
            EmissaoTO.ContratanteTO contratantePrec = new EmissaoTO.ContratanteTO();
            contratantePrec.premio = new EmissaoTO.PremioTO();
            contratantePrec.premio.total = 0;
            contratantePrec.premio.puro = 0;
            contratantePrec.premio.comercial = 0;
            contratantePrec.numero = '1';
            contratantePrec.iof = 0.01;
            EmissaoTO.GrupoTO grupoPrec = new EmissaoTO.GrupoTO();
            grupoPrec.premio = new EmissaoTO.PremioTO();
            grupoPrec.premio.total = 0;
            grupoPrec.premio.puro = 0;
            grupoPrec.premio.comercial = 0;
            grupoPrec.numero = '1';
            grupoPrec.iof = 0.01;

            grupoPrec.descontoAgravo = new List<EmissaoTO.DescontoAgravoTO>();
            grupoPrec.descontoAgravo.add(descAgravo);

            EmissaoTO.SeguradoTO seguradoPrec = new EmissaoTO.SeguradoTO();
            seguradoPrec.premio = new EmissaoTO.PremioTO(); 
            seguradoPrec.premio.total = 0;
            seguradoPrec.premio.puro = 0;
            seguradoPrec.premio.comercial = 0;
            seguradoPrec.numero = '1';
            seguradoPrec.iof = 0.01;

            seguradoPrec.descontoAgravo = new List<EmissaoTO.DescontoAgravoTO>();
            seguradoPrec.descontoAgravo.add(descAgravo);

            EmissaoTO.CoberturaTO coberturaPrec = new EmissaoTO.CoberturaTO();
            coberturaPrec.sigla = 'IPA';
            coberturaPrec.iof = 0.01;
            coberturaPrec.taxa = new EmissaoTO.TaxaTO();
            coberturaPrec.taxa.total = 0;
            coberturaPrec.taxa.pura = 0;
            coberturaPrec.taxa.comercial = 0;
            coberturaPrec.premio = new EmissaoTO.PremioTO();
            coberturaPrec.premio.total = 0;
            coberturaPrec.premio.puro = 0;
            coberturaPrec.premio.comercial = 0;
            coberturaPrec.descontoAgravo = new List<EmissaoTO.DescontoAgravoTO>();
            coberturaPrec.descontoAgravo.add(descAgravo);
            seguradoPrec.coberturas = new List<EmissaoTO.CoberturaTO>();
            grupoPrec.segurados = new List<EmissaoTO.SeguradoTO>();
            grupoPrec.segurados.add(seguradoPrec);
            contratantePrec.grupos = new List<EmissaoTO.GrupoTO>();
            contratantePrec.grupos.add(grupoPrec);
            contratantePrec.descontoAgravo = new List<EmissaoTO.DescontoAgravoTO>();
            contratantePrec.descontoAgravo.add(descAgravo);
            orcamento.contratoOriginal.precificacao.contratantes = new List<EmissaoTO.ContratanteTO>();
            orcamento.contratoOriginal.precificacao.contratantes.add(contratantePrec);
            orcamento.contratoOriginal.precificacao.coberturas = new List<EmissaoTO.CoberturaTO>();
            orcamento.contratoOriginal.precificacao.coberturas.add(coberturaPrec);
            
            EmissaoTO.ContratanteTo novoContratante = new EmissaoTO.ContratanteTo();
            novoContratante.tipo = 'PRI';
            novoContratante.numero = '1';
            EmissaoTO.GrupoTO novoGrupo = new EmissaoTO.GrupoTO();
            novoGrupo.tipoCalculo = '';
            EmissaoTO.SeguradoTO novoSegurado = new EmissaoTO.SeguradoTO();
            novoSegurado.pessoa = new EmissaoTO.PessoaTO();
            novoSegurado.pessoa.tipo = 'FIS';
            novoSegurado.pessoa.rendaMensal = 7172;
            novoSegurado.pessoa.nome = 'XXZY NCGMLU AHBTNH';
            novoSegurado.pessoa.dadosPessoaFisica = new EmissaoTO.DadosPessoaFisicaTO();
            novoSegurado.pessoa.dadosPessoaFisica.sexo = 'MASC';
            novoSegurado.pessoa.dadosPessoaFisica.regimeTrabalho = 'CLT';
            novoSegurado.pessoa.dadosPessoaFisica.profissao = '2111-05';
            novoSegurado.pessoa.dadosPessoaFisica.numeroCpf = '434.652.184-34';
            novoSegurado.pessoa.dadosPessoaFisica.fumante = false;
            novoSegurado.pessoa.dadosPessoaFisica.digitoCpf = '';
            novoSegurado.pessoa.dadosPessoaFisica.dataNascimento = '1964-08-20 00:00:00';
            novoSegurado.numero = '1';
            novoGrupo.segurados = new List<EmissaoTO.SeguradoTO>();
            novoGrupo.segurados.add(novoSegurado);
            novoGrupo.qtdeVidas = 1;
            novoGrupo.numero = '1';
            novoGrupo.nome = 'XXZY NCGMLU AHBTNH';
            novoContratante.grupos = new List<EmissaoTO.GrupoTO>();
            novoContratante.grupos.add(novoGrupo);
            orcamento.contratantes = new List<EmissaoTO.ContratanteTo>();
            orcamento.contratantes.add(novoContratante);
            orcamento.contratoOriginal.contratantes = new List<EmissaoTO.ContratanteTo>();
            orcamento.contratoOriginal.contratantes.add(novoContratante);
            EmissaoTO.BeneficiarioTO beneficiario = new EmissaoTO.BeneficiarioTO();
            beneficiario.tipoBeneficiario = 'Conforme artigo 792 do código civil';
            beneficiario.percentualIndenizacao = 100;
            beneficiario.participacao = 100;
            beneficiario.imprimirCertificado = false;
            orcamento.contratoOriginal.contratantes[0].grupos[0].segurados[0].beneficiarios = new List<EmissaoTO.BeneficiarioTO>();
            orcamento.contratoOriginal.contratantes[0].grupos[0].segurados[0].beneficiarios.add(beneficiario);
            PayloadTransmissao.gerarEndossoPagamento(new List<Id>(sCasos)[0], orcamento);
        Test.stopTest();
    }
}
//PLV-4772-FIM