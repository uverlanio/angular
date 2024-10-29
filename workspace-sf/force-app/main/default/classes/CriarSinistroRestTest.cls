/*******************************************************************************************************************************
* 
* @author Leonardo - Globant
* @date 16/06/2020
* @modifiedAt 
* Classe criada por conta da história PLV-3875
* Classe de testes para o serviço criar sinistro (Caso)
******************************************************************************************************************************/
@IsTest
public class CriarSinistroRestTest {

    @TestSetup
    static void setup(){
        ContadorCodigo__c contadorTecnico = (ContadorCodigo__c) new ContadorCodigoFactory.ProdutoTecnico().createRecord();
        ContadorCodigo__c contadorComercial = (ContadorCodigo__c) new ContadorCodigoFactory.ProdutoComercial().createRecord();

        Account conta = (Account) new AccountFactory.PessoaFisica().createRecord();
        //PLV-3904 - INICIO
        Garantia__c garantia = (Garantia__c) new GarantiaFactory().createRecord();
        garantia.Sigla__c = 'DBAG';
        update garantia;
        RamoSeguro__c ramoSeguro = (RamoSeguro__c) new RamoSeguroFactory(conta).createRecord();
        RamoGarantia__c ramoGarantia = (RamoGarantia__c) new RamoGarantiaFactory(garantia, ramoSeguro).createRecord();
        DadosCorretor__c dadosCorretor = (DadosCorretor__c) new DadosCorretorFactory(conta).createRecord();
        Modalidade__c modalidade = (Modalidade__c) new ModalidadeFactory(ramoSeguro).createRecord();
        
        Product2 produtoTecnico = (Product2) new ProdutoFactory.ProdutoTecnico().createRecord();
        produtoTecnico.Status__c = 'Em ativação';
        produtoTecnico.NumeroSusep__c = '123';
        produtoTecnico.VersaoRenovacao__c = 'Versão atual';
        update produtoTecnico;
        produtoTecnico.Status__c = 'Ativo';
        update produtoTecnico;
        Product2 produtoComercial = (Product2) new ProdutoFactory.ProdutoComercial(produtoTecnico).createRecord();
        

        GarantiaProduto__c garanProdTec = (GarantiaProduto__c) new GarantiaProdutoFactory.GarantiaProdutoTec(garantia, produtoTecnico, ramoSeguro).createRecord();
        GarantiaProduto__c garanProdCom = (GarantiaProduto__c) new GarantiaProdutoFactory.GarantiaProdutoCom(produtoComercial, garantia, garanProdTec, ramoSeguro).createRecord();

        garanProdCom.VigenciaGarantia__c = 'Contratação até fim da apólice';
		update garanProdCom;
        //PLV-3904 - FIM

        Opportunity orcamento = (Opportunity) new OrcamentoFactory.VidaIndividual(produtoComercial, conta).createRecord();
        Quote proposta = (Quote) new PropostaFactory(produtoComercial, ramoSeguro, conta, dadosCorretor, orcamento, modalidade).createRecord();
        FormaPagamento__c formaPagamento = (FormaPagamento__c) new FormaPagamentoFactory().createRecord();
        // Parceiro__c parceiro = (Parceiro__c) new ParceiroFactory(conta, formaPagamento).createRecord();
        RamoAtividade__c ramoAtividade = (RamoAtividade__c) new RamoAtividadeFactory().createRecord();
        
        Account contaParceiro = (Account) new AccountFactory.PessoaJuridica(ramoAtividade).createRecord();
        contaParceiro.Name = 'ASSISTCARD';
        update contaParceiro;

        Parceiro__c parceiroPrestadora = (Parceiro__c) new ParceiroFactory(contaParceiro, formaPagamento).createRecord();
        parceiroPrestadora.status__c = 'Ativo';
        parceiroPrestadora.Sucursal__c = '1';
        parceiroPrestadora.ramo__c = '1396';
        parceiroPrestadora.empresa__c = '1';
        update parceiroPrestadora;

        Contract contrato = (Contract) new ContratoFactory.ContratoFactoryComParam(conta, produtoComercial, parceiroPrestadora).createRecord();
        ContratanteContrato__c contratanteContrato = new ContratanteContrato__c(Contrato__c = contrato.Id, Conta__c = conta.Id, Tipo__c = 'Principal'); 
        insert contratanteContrato;

        GrupoContrato__c grupoContrato = (GrupoContrato__c) new GrupoFactory(contratanteContrato).createRecord();
        SeguradoContrato__c seguradoContrato = (SeguradoContrato__c) new SeguradoContratoFactory(conta, grupoContrato).createRecord(); 
        //PLV-3904 - INICIO
        seguradoContrato.VigenciaInicial__c = system.today();
        seguradoContrato.VigenciaFinal__c = system.today().addMonths(1);
        update seguradoContrato;
        //PLV-3904 - FIM
        
        
        insert new GarantiaContrato__c(Contrato__c = contrato.Id, Garantia__c = garantia.Id, Capital__c = 100.00, TipoCapital__c = 'Capital uniforme'); //PLV-4094 - INICIO/FIM
        
        GarantiaSeguradoContrato__c garantiaSeguradoContrato = (GarantiaSeguradoContrato__c) new GarantiaSeguradoContratoFactory(seguradoContrato,garantia).createRecord();
        garantiaSeguradoContrato.capital__c = 10;  //PLV-4094 - INICIO/FIM
        
        //PLV-3904 - INICIO
        garantiaSeguradoContrato.GarantiaProduto__c = garanProdCom.id;
        update garantiaSeguradoContrato;
        //PLV-3904 - FIM
        TipoRemuneracao__c tipoRemuneracao = (TipoRemuneracao__c) new TipoRemuneracaoFactory().createRecord();
        RemuneracaoContrato__c remCont = (RemuneracaoContrato__c) new RemuneracaoContratoFactory(tipoRemuneracao, contrato).createRecord();
        
        FavorecidoRemuneracaoContrato__c favRemCont = (FavorecidoRemuneracaoContrato__c) new FavorecidoRemuneracaoContratoFactory(remCont, dadosCorretor).createRecord();
        favRemCont.Papel__c = 'Corretor';
		favRemCont.Susep__c = 'P5005J';
		update favRemCont;     

		proposta.Produto__c = produtoComercial.Id;
        proposta.Status = 'Contratada';
        proposta.Parceiro__c = '';
        proposta.MeioComercializacao__c = 'CO2';
        proposta.tipo__c = 'Novo';
        proposta.Massificados__c = false;
        update proposta;
        
        contrato.NumeroApolice__c = '002353575';
        contrato.Name = '1-1-1396-002353575-0';//PLV-4509 - Inicio/Fim
        contrato.MeioComercializacao__c = 'CO2';
        contrato.ModalidadeSeguro__c = modalidade.Id;
        contrato.Proposta__c = proposta.Id;
        contrato.Produto__c = produtoComercial.Id;
        contrato.Tipo__c = 'Novo';
        contrato.Status = 'Emitido';
        update contrato;

        conta.Cpf__c = '398.169.840-16';
        update conta;
        
    }

    public static CivSinistroTO.Request retornarDadosEntrada(){ //PLV-4094 - INICIO/FIM
        
        CivSinistroTO.Request dadosEntrada = new CivSinistroTO.Request(); //PLV-4094 - INICIO/FIM
        dadosEntrada.nomeSegurado            = 'Maria Alvares';
        dadosEntrada.cpfSegurado             = '398169840';
        dadosEntrada.digitoCpfSegurado       = '16';
        dadosEntrada.dataOcorrencia          = String.valueof(system.today()); //PLV-4094 - INICIO/FIM
        dadosEntrada.assunto                 = 'Aviso de sinistro';
        dadosEntrada.descricao               = 'Health - HOUSE CALL - GENERAL & MINOR: Fever';
        dadosEntrada.origem                  = 'Prestadora';
        dadosEntrada.prestadora              = 'ASSISTCARD';
        dadosEntrada.vitima                  = 'segurado';
        dadosEntrada.idAtendimentoPrestadora = 'IdAssist130';
        dadosEntrada.tipoEvento              = 'Viagem'; 
        dadosEntrada.empresa                 = '1';
        dadosEntrada.sucursal                = '1';
        dadosEntrada.ramo                    = '1396';
        dadosEntrada.apolice                 = '002353575';//PLV-4509 - Inicio/Fim
        dadosEntrada.endosso                 = '0';
        dadosEntrada.numeroSinistro          = '1.1369.2020.500048'; //PLV-4166 - INICIO/FIM
        dadosEntrada.sinistroPrioritario     = false;
        
        //PLV4921 INICIO        
        FormaPagamento__c formaPG = [Select Codigo__c, Name from FormaPagamento__c limit 1];
        Account contaFisica = [Select id from Account limit 1];
        
        dadosEntrada.setContaPrestadora(new Parceiro__c(
            DiaFaturamento__c = '10',
            DiaPreFaturamento__c = '08',
            PrazoVencimento__c = '30',
            Conta__c = contaFisica.Id,
            FaturaProdutosSeparados__c = 'Não' ,
            FormaPagamento__c = formaPG.Id,
            PossuiAnexoFatura__c = 'Sim',
            SiglaParceiro__c = 'PSEG',
            Empresa__c = '1',
            Sucursal__c = '1',
            Ramo__c = '1377'
        ));
        //PLV4921 - FIM
        //PLV-4509 - inicio 
        dadosEntrada.caseId					 = null;             
        //List Beneficiario
        List<CivSinistroTO.BeneficiarioSinistroTO> ListBeneficiario = new List<CivSinistroTO.BeneficiarioSinistroTO>();
        
        //Beneficiario Fisico
        CivSinistroTO.DadosPessoaFisicaSinistroTO  BeneficiarioFisico = new CivSinistroTO.DadosPessoaFisicaSinistroTO();
        BeneficiarioFisico.numeroDocumentoBeneficiario = '772.229.670-01';
        
        //Beneficiario Juridico
        CivSinistroTO.DadosPessoaJuridicaSinistroTO  BeneficiarioJuridico = new CivSinistroTO.DadosPessoaJuridicaSinistroTO();
        BeneficiarioJuridico.numeroDocumentoBeneficiario = '36.490.942/0001-42';
        BeneficiarioJuridico.documentoEstrangeiro = false;
        
        //beneficiario
        CivSinistroTO.BeneficiarioSinistroTO  Beneficiario1 = new CivSinistroTO.BeneficiarioSinistroTO();
        Beneficiario1.nomeBeneficiario = 'teste Fisico';
        Beneficiario1.tipo = 'FIS';
        Beneficiario1.valorIndenizacaoBeneficiario = '10';
        Beneficiario1.moeda = 'USD';
        Beneficiario1.dadosPessoaFisica = BeneficiarioFisico;
        
        CivSinistroTO.BeneficiarioSinistroTO  Beneficiario2 = new CivSinistroTO.BeneficiarioSinistroTO();
        Beneficiario2.nomeBeneficiario = 'teste juridico';
        Beneficiario2.tipo = 'JUR';
        Beneficiario2.valorIndenizacaoBeneficiario = '10';
        Beneficiario2.moeda = 'USD';
        Beneficiario2.dadosPessoaJuridica = BeneficiarioJuridico;
        
        ListBeneficiario.add(Beneficiario1);
        ListBeneficiario.add(Beneficiario2);
        //PLV-4509 - Fim
            
        CivSinistroTO.GarantiaSinistroTO garantia1 = new CivSinistroTO.GarantiaSinistroTO();//PLV-4094 - INICIO/FIM        
        garantia1.sigla = 'DBAG';
        garantia1.valorIndenizado = 10; //PLV-4094 - INICIO/FIM
        garantia1.moedaIndenizacao = 'BRL'; //PLV-4094 - INICIO/FIM
        garantia1.tipoValor = 'EST'; //PLV-4166 - INICIO/FIM 
        //PLV-4509 - inicio 
        //garantia1.beneficiarios = ListBeneficiario;
        //PLV-4509 - Fim          
        //PLV4921 - INCIO
        //garantia1.garantia = [SELECT ID, Sigla__c  FROM Garantia__c WHERE Sigla__c = 'DBAG'];
        //PLV4921 - FIM
        dadosEntrada.garantias.add(garantia1);

        return dadosEntrada;
    }

    @IsTest
    public static void criarCasoSinistroTest(){
    	RestRequest request = new RestRequest();
        request.requestURI = '/services/apexrest/sinistro/criar';
        request.httpMethod = 'POST';
    
        //PLV-4509 - inicio        
        system.debug('JSON entrada> '+retornarDadosEntrada());
        CivSinistroTO.Request dadosEntradaTeste = retornarDadosEntrada();
        dadosEntradaTeste.origem = '18';
        dadosEntradaTeste.idAtendimentoPrestadora = 'Prestadora1';
        //PLV-4509 - FIM

        Test.startTest();
        RestContext.request = request;         
        CivSinistroTO.Response retornoSinistro = CriarSinistroRest.novoSinistro(dadosEntradaTeste);//PLV-4094 - INICIO/FIM
        system.debug(retornoSinistro.data);
        // System.assertEquals('Avisado', retornoSinistro.data.sinistro.status);

        Test.stopTest();    
    }
     
    //PLV-4166 - INICIO
    @IsTest
    public static void atualizaCasoSinistroTest(){
    	RestRequest request = new RestRequest();
        request.requestURI = '/services/apexrest/sinistro/criar';
        request.httpMethod = 'POST';
        
        CivSinistroTO.GarantiaSinistroTO garantia2 = new CivSinistroTO.GarantiaSinistroTO();
        garantia2.sigla = 'DBAG';
        garantia2.valorIndenizado = 10; 
        garantia2.moedaIndenizacao = 'BRL'; 
        garantia2.tipoValor = 'SUB'; 
        
        CivSinistroTO.GarantiaSinistroTO garantia3 = new CivSinistroTO.GarantiaSinistroTO();
        garantia3.sigla = 'DBAG';
        garantia3.valorIndenizado = 10; 
        garantia3.moedaIndenizacao = 'BRL'; 
        garantia3.tipoValor = 'SOM';
    
        CivSinistroTO.Request dadosEntradaTeste = retornarDadosEntrada();
        dadosEntradaTeste.idAtendimentoPrestadora = 'Prestadora1';
        
        RestContext.request = request;
        CivSinistroTO.Response retornoSinistro = CriarSinistroRest.novoSinistro(dadosEntradaTeste);
        
        List<Case> relatedCases = [SELECT ID,Status,DataReabertura__c,TipoContagem__c, MotivosReabertura__c,						   Status_Dependente__c, NumeroSinistro__c, IdPrestadora__c, Contrato__c 
                                   from case where NumeroSinistro__c = :dadosEntradaTeste.numeroSinistro limit 1];
        
        if(relatedCases.isEmpty()) return;

        Test.startTest();
        
        relatedCases[0].Status_Dependente__c='Pago';
        update relatedCases;
        
        relatedCases[0].Status='Fechado';
        relatedCases[0].Status_Dependente__c='Pago';
        update relatedCases;        
 
        RestContext.request = request;                   
        dadosEntradaTeste.garantias.add(garantia2);
        CivSinistroTO.Response retornoSinistro2 = CriarSinistroRest.novoSinistro(dadosEntradaTeste);
          
        RestContext.request = request;   
        dadosEntradaTeste.garantias.add(garantia3);        
		CivSinistroTO.Response retornoSinistro3 = CriarSinistroRest.novoSinistro(dadosEntradaTeste);       
              
        Test.stopTest();    
    }
    
    @IsTest
    public static void atualizaCasoSinistroTest2(){
    	RestRequest request = new RestRequest();
        request.requestURI = '/services/apexrest/sinistro/criar';
        request.httpMethod = 'POST';
        
        system.debug('dados entrada > '+retornarDadosEntrada());
        CivSinistroTO.Request dadosEntradaTeste = retornarDadosEntrada();
        dadosEntradaTeste.idAtendimentoPrestadora = 'Prestadora1';
        
        RestContext.request = request;
        CivSinistroTO.Response retornoSinistro = CriarSinistroRest.novoSinistro(dadosEntradaTeste);
        
        List<PagamentoGarantia__c> Listgarantia = [
            SELECT ID, Caso__c, MoedaGarantia__c, Garantia_do_segurado_do_contrato__r.Garantia__r.Sigla__c,
            Garantia_do_segurado_do_contrato__c, Name,  Fase__c, Caso__r.NumeroSinistro__c,
            CurrencyIsoCode, Valor_indenizado__c, Capital__c, Status_do_pagamento__c 
			FROM PagamentoGarantia__c 
            WHERE Caso__r.NumeroSinistro__c = :dadosEntradaTeste.numeroSinistro limit 1
        ];

        if(Listgarantia.IsEmpty()) return;
        
        Test.startTest();        
        Listgarantia[0].Fase__c = 'Em análise';
        Listgarantia[0].Status_do_pagamento__c = 'Aguardando Pagamento';
        update Listgarantia;        

        RestContext.request = request;
        CivSinistroTO.Response retornoSinistro2 = CriarSinistroRest.novoSinistro(dadosEntradaTeste);//PLV-4094 - INICIO/FIM          
        
        Test.stopTest();
    }
     //PLV-4166 - FIM
    
    //PLV-3904 - INICIO
    @IsTest
    public static void validarIniciada(){
    	RestRequest request = new RestRequest();
        request.requestURI = '/services/apexrest/sinistro/criar';
        request.httpMethod = 'POST';
    
        CivSinistroTO.Request dadosEntradaTeste = retornarDadosEntrada();//PLV-4094 - INICIO/FIM
        dadosEntradaTeste.idAtendimentoPrestadora = 'Prestadora1';
        
        List<GarantiaProduto__c> lgp = new List<GarantiaProduto__c>();
        for(GarantiaProduto__c gp : [SELECT Id FROM GarantiaProduto__c]){
            gp.VigenciaGarantia__c = 'Mesma da apólice';
            lgp.add(gp);
        }
        update lgp;

		//PLV-4094 - INICIO
        List<SeguradoContrato__c> listaSeguradoContrato = [
            SELECT Id, VigenciaInicial__c, VigenciaFinal__c
            FROM SeguradoContrato__c
        ];

        List<SeguradoContrato__c> segurados4Update = new List<SeguradoContrato__c>();
        for(SeguradoContrato__c seguradoContrato : listaSeguradoContrato){
            seguradoContrato.VigenciaInicial__c = system.today().addMonths(1);
            seguradoContrato.VigenciaFinal__c = system.today().addMonths(2);
            segurados4Update.add(seguradoContrato);
        }
    
        update segurados4Update;
		//PLV-4094 - FIM

        Test.startTest();
        RestContext.request = request;         
        CivSinistroTO.Response retornoSinistro = CriarSinistroRest.novoSinistro(dadosEntradaTeste);//PLV-4094 - INICIO/FIM
        system.debug(retornoSinistro);
        system.debug('MENSAGEM RETORNO: '+retornoSinistro.data.mensagem);

		//PLV-4094 - INICIO
        System.assertEquals(true, retornoSinistro.data.erro);
        // System.assert(String.isNotBlank(retornoSinistro.data.mensagem) && retornoSinistro.data.mensagem.indexOf('Não é possível realizar a abertura')!=-1); 
		//PLV-4094 - FIM
        Test.stopTest();    

    }
    //PLV-3904 - FIM


    

    @IsTest
    public static void validacaoParametroObrigatorioTest(){       

    	RestRequest request = new RestRequest();
        request.requestURI = '/services/apexrest/sinistro/criar';
        request.httpMethod = 'POST';
    
        Test.startTest();
        CivSinistroTO.Request dadosEntrada = retornarDadosEntrada();//PLV-4094 - INICIO/FIM
        dadosEntrada.cpfSegurado = '121131141';
        dadosEntrada.idAtendimentoPrestadora = 'IdAssist199';

        RestContext.request = request;         
        CriarSinistroRest.novoSinistro(dadosEntrada);
        Test.stopTest();
    
    }
    
    
    @IsTest
    public static void validacaoGarantiaNaoExisteNoContratoTest(){       

    	RestRequest request = new RestRequest();
        request.requestURI = '/services/apexrest/sinistro/criar';
        request.httpMethod = 'POST';
    
        Test.startTest();
        CivSinistroTO.Request dadosEntrada = retornarDadosEntrada();//PLV-4094 - INICIO/FIM
        dadosEntrada.idAtendimentoPrestadora = 'IdAssist140';
        
        List<Garantia__c> listaGarantiaMock = [SELECT sigla__c FROM Garantia__c];
        
        if(!listaGarantiaMock.IsEmpty()) listaGarantiaMock[0].sigla__c = 'TC';
        
        update listaGarantiaMock;

        RestContext.request = request;
        CriarSinistroRest.novoSinistro(dadosEntrada);
        Test.stopTest();    
    }

    
    @IsTest
    public static void validacaoGarantiasNaoEncontradasTest(){       

    	RestRequest request = new RestRequest();
        request.requestURI = '/services/apexrest/sinistro/criar';
        request.httpMethod = 'POST';
    
        Test.startTest();
        CivSinistroTO.Request dadosEntrada = retornarDadosEntrada();//PLV-4094 - INICIO/FIM
        dadosEntrada.idAtendimentoPrestadora = 'IdAssist150';

        CivSinistroTO.GarantiaSinistroTO garantia2 = new CivSinistroTO.GarantiaSinistroTO();//PLV-4094 - INICIO/FIM
        garantia2.sigla = 'EB';
        garantia2.valorIndenizado = 123; //PLV-4094 - INICIO/FIM
        garantia2.moedaIndenizacao = 'USD';
        
        dadosEntrada.garantias.add(garantia2);

        CivSinistroTO.GarantiaSinistroTO garantia3 = new CivSinistroTO.GarantiaSinistroTO();//PLV-4094 - INICIO/FIM
        garantia3.sigla = 'TM';
        garantia3.valorIndenizado = 124; //PLV-4094 - INICIO/FIM
        garantia3.moedaIndenizacao = 'USD';
        
        dadosEntrada.garantias.add(garantia3);

        RestContext.request = request;         
        CriarSinistroRest.novoSinistro(dadosEntrada);
        Test.stopTest();    
    }


    @IsTest
    public static void validacaoApoliceNaoEncontradaTest(){       

        RestRequest request = new RestRequest();
        request.requestURI = '/services/apexrest/sinistro/criar';
        request.httpMethod = 'POST';

        Test.startTest();
        CivSinistroTO.Request dadosEntrada = retornarDadosEntrada();//PLV-4094 - INICIO/FIM
        dadosEntrada.apolice = '002333555';
        dadosEntrada.idAtendimentoPrestadora = 'IdAssist160';

        RestContext.request = request;         
        CriarSinistroRest.novoSinistro(dadosEntrada);
        Test.stopTest();    
    }


    @IsTest
    public static void validacaoClienteNaoEncontradoTest(){       

        RestRequest request = new RestRequest();
        request.requestURI = '/services/apexrest/sinistro/criar';
        request.httpMethod = 'POST';

        //PLV-4509 - Inicio - 
        Test.startTest();
        CivSinistroTO.Request dadosEntrada = retornarDadosEntrada();//PLV-4094 - INICIO/FIM
        dadosEntrada.apolice = '002353575---0';      
        dadosEntrada.idAtendimentoPrestadora = 'IdAssist160';
       

        RestContext.request = request;         
        CriarSinistroRest.novoSinistro(dadosEntrada);
		dadosEntrada.apolice = '002353575---0';  
        CriarSinistroRest.novoSinistro(dadosEntrada);
        Test.stopTest();
        //PLV-4509 - Fim
    }


    @IsTest
    public static void validacaoContaPrestadoraNaoEncontradaTest(){       

        RestRequest request = new RestRequest();
        request.requestURI = '/services/apexrest/sinistro/criar';
        request.httpMethod = 'POST';

        CivSinistroTO.Request dadosEntrada = retornarDadosEntrada();//PLV-4094 - INICIO/FIM
        dadosEntrada.idAtendimentoPrestadora = 'IdAssist180';

        Test.startTest();
        List<Parceiro__c> listaParceiro = [SELECT ramo__c FROM Parceiro__c];

        if(!listaParceiro.IsEmpty()) listaParceiro[0].ramo__c = '1234';
        update listaParceiro;

        RestContext.request = request;         
        CriarSinistroRest.novoSinistro(dadosEntrada);
        Test.stopTest();    
    }
}