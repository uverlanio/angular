/*******************************************************************************************************************************
* Consulta dados Básicos de Apólice/Contrato
* @author Isabela - Globant
* @date 30/04/2020
* @modifiedAt 01/04/2020
* Classe criada por conta da história PLV-3719
******************************************************************************************************************************/
@IsTest
public class ConsultaApoliceRESTTest {
    
    @TestSetup
    static void setupUnit(){
        ContadorCodigo__c contadorTecnico = (ContadorCodigo__c) new ContadorCodigoFactory.ProdutoTecnico().createRecord();
        ContadorCodigo__c contadorComercial = (ContadorCodigo__c) new ContadorCodigoFactory.ProdutoComercial().createRecord();

        Account conta = (Account) new AccountFactory.PessoaFisica().createRecord();
        // MGRC-488 INICIO
        conta.DataExpedicao__c = Date.newInstance(2022, 06, 09);
        conta.EstadoCivil__c = 'Casado (a)';
        conta.Cpf__c = '43891231814';
        update conta;
        // MGRC-488 FIM
        RamoSeguro__c ramoSeguro = (RamoSeguro__c) new RamoSeguroFactory(conta).createRecord();
        DadosCorretor__c dadosCorretor = (DadosCorretor__c) new DadosCorretorFactory(conta).createRecord();
        CanalDistribuicao__c canalDistribuicao = (CanalDistribuicao__c) new CanalDistribuicaoFactory().createRecord(); //PLV - 4193 INICIO/FIM

        Modalidade__c modalidade = (Modalidade__c) new ModalidadeFactory(ramoSeguro).createRecord();
        
        Product2 produtoTecnico = (Product2) new ProdutoFactory.ProdutoTecnico().createRecord();
        produtoTecnico.Status__c = 'Em ativação';
        produtoTecnico.NumeroSusep__c = '123';
        produtoTecnico.VersaoRenovacao__c = 'Versão atual';
        update produtoTecnico;
        produtoTecnico.Status__c = 'Ativo';
        update produtoTecnico;
        Product2 produtoComercial = (Product2) new ProdutoFactory.ProdutoComercial(produtoTecnico).createRecord();
        
        Opportunity orcamento = (Opportunity) new OrcamentoFactory.VidaIndividual(produtoComercial, conta).createRecord();
        Quote proposta = (Quote) new PropostaFactory(produtoComercial, ramoSeguro, conta, dadosCorretor, orcamento, modalidade).createRecord();
        // PLV-5554-FIX-INICIO
        proposta.CodigoCorretor__r.Name = 'P5005J';
        update proposta;
        // PLV-5554-FIX-FIM
        FormaPagamento__c formaPagamento = (FormaPagamento__c) new FormaPagamentoFactory().createRecord(); //PLV - 4553 - INICIO/FIM
        CondicaoCobranca__c condicaoCobranca = (CondicaoCobranca__c) new CondicaoCobrancaFactory.CondicaoCobranca(produtoComercial,formaPagamento).createRecord();
        Parceiro__c parceiro = (Parceiro__c) new ParceiroFactory(conta, formaPagamento).createRecord();
        
        Contract contrato = (Contract) new ContratoFactory.ContratoFactoryComParam(conta, produtoComercial, parceiro).createRecord();
        //PLV-4376 - FIX - INICIO
        contrato.FormaPagamento__c = formaPagamento.Id; //PLV - 4553 - INICIO/FIM
        contrato.Proposta__c = proposta.Id; 
        update contrato;
        //PLV-4376 - FIX - FIM
        //PLV-4376 - INICIO
        ContratanteContrato__c contratanteContrato = new ContratanteContrato__c(Contrato__c = contrato.Id, Conta__c = conta.Id, Tipo__c = 'Principal');
        contratanteContrato.FormaPagamento__c = formaPagamento.Id; //PLV - 4553 - INICIO/FIM
        insert contratanteContrato;

        GrupoContrato__c grupoContrato = (GrupoContrato__c) new GrupoFactory(contratanteContrato).createRecord();
        SeguradoContrato__c seguradoContrato = (SeguradoContrato__c) new SeguradoContratoFactory(conta, grupoContrato).createRecord();
        //PLV-4376 - FIM

        Garantia__c garantia = (Garantia__c) new GarantiaFactory().createRecord();
        insert new GarantiaContrato__c(Contrato__c = contrato.Id, Garantia__c = garantia.Id, Capital__c = 10000.00, TipoCapital__c = 'Capital uniforme');

        //LECVPV-177 - INICIO
        BeneficiarioSeguradoContrato__c befSegContr1 = new BeneficiarioSeguradoContrato__c();
        befSegContr1.SeguradoContrato__c = seguradoContrato.Id;
        befSegContr1.conta__c = conta.Id;
        befSegContr1.participacao__c = Decimal.valueOf(50);
        insert befSegContr1;
        //LECVPV-177 - FIM
        //FNPVVEP-98 INICIO
        TipoRemuneracao__c tipoRemuneracao = (TipoRemuneracao__c) new TipoRemuneracaoFactory().createRecord();
        tipoRemuneracao.Name = 'AGENCIAMENTO';
        update tipoRemuneracao;
        TipoRemuneracao__c tipoRemuneracaoProposta = (TipoRemuneracao__c) new TipoRemuneracaoFactory().createRecord();
        tipoRemuneracaoProposta.Name = 'CORRETAGEM';
        update tipoRemuneracaoProposta;
        RemuneracaoContrato__c remCont = (RemuneracaoContrato__c) new RemuneracaoContratoFactory(tipoRemuneracao, contrato).createRecord();

        RemuneracaoProposta__c remuneracaoProposta = new RemuneracaoProposta__c(
              TipoRemuneracao__c = tipoRemuneracaoProposta.Id,
              Proposta__c = proposta.Id,
              Percentual__c = 30
        );
        insert remuneracaoProposta;
        //FNPVVEP-98 FIM
        
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
        
        contrato.NumeroApolice__c = '12345';
        contrato.Name = '12345';
        //contrato.MeioComercializacao__c = 'CO2';
        contrato.ModalidadeSeguro__c = modalidade.Id;
        contrato.Proposta__c = proposta.Id;
        contrato.Produto__c = produtoComercial.Id;
        contrato.Tipo__c = 'Novo';
        contrato.Status = 'Emitido';
        //PLV - 4193 INICIO
        contrato.CodigoCorretor__c = dadosCorretor.Id;
        contrato.CanalDistribuicao__c = canalDistribuicao.id;
        //PLV - 4193 FIM        

        update contrato;
        
        insert new SenhaCriptografia__c(Name = 'Senha',Senha__c = 'TesteCrypto'); //PLV-3745 - INICIO/FIM
    }


    //PLV-4376 - FIX - INICIO
    //MÉTODO: valida_parametros_completos REMOVIDO
    @Istest
    static void valida_parametros_CPF_Susep(){
        Contract contrato = [SELECT Id, Proposta__c FROM Contract LIMIT 1];
        ConsultaApoliceService.listMockedRequest = new public_arquivoecm__x[]{
            new public_arquivoecm__x(nomearquivo__c='Voucher_123',idecm__c='123',status__c='CRIADO',idsf__c=contrato.Proposta__c),
            new public_arquivoecm__x(nomearquivo__c='Apolice_321',idecm__c='321',status__c='CRIADO',idsf__c=contrato.Id)
        };
       	
        RestRequest req = new RestRequest();
        req.params.put('cpfContratante','43891231814'); //Conforme factory
        req.params.put('susep','P5005J');
        
        RestContext.request = req;

        Test.startTest();
        ConsultaApoliceREST.Response result = ConsultaApoliceREST.consultar();
        //System.assert(result != null && !result.data.apolices.isEmpty()); // PLV-5554-FIX-INICIO/FIM
        Test.stopTest();
    }

    @Istest
    static void valida_parametros_Canal_IdCanal(){
        Contract contrato = [SELECT Id, Proposta__c FROM Contract LIMIT 1];
        ConsultaApoliceService.listMockedRequest = new public_arquivoecm__x[]{
            new public_arquivoecm__x(nomearquivo__c='Voucher_123',idecm__c='123',status__c='CRIADO',idsf__c=contrato.Proposta__c),
            new public_arquivoecm__x(nomearquivo__c='Apolice_321',idecm__c='321',status__c='CRIADO',idsf__c=contrato.Id)
        };
       	
        RestRequest req = new RestRequest();
        req.params.put('canal','Canal Distribuição Teste 001');//Conforme factory
        req.params.put('idCanal','001');//Conforme factory
        
        RestContext.request = req;

        Test.startTest();
        ConsultaApoliceREST.Response result = ConsultaApoliceREST.consultar();
        System.debug(JSON.serialize(result));
        System.assert(result != null && !result.data.apolices.isEmpty());
        Test.stopTest();
    }

    @Istest
    static void valida_parametro_CPF(){
        Contract contrato = [SELECT Id, Proposta__c FROM Contract LIMIT 1];
        ConsultaApoliceService.listMockedRequest = new public_arquivoecm__x[]{
            new public_arquivoecm__x(nomearquivo__c='Voucher_123',idecm__c='123',status__c='CRIADO',idsf__c=contrato.Proposta__c),
            new public_arquivoecm__x(nomearquivo__c='Apolice_321',idecm__c='321',status__c='CRIADO',idsf__c=contrato.Id)
        };
       	
        RestRequest req = new RestRequest();
        req.params.put('cpfContratante','43891231814'); //Conforme factory
               
        RestContext.request = req;

        Test.startTest();
        ConsultaApoliceREST.Response result = ConsultaApoliceREST.consultar();
        System.debug(JSON.serialize(result));
        System.assert(result != null && !result.data.apolices.isEmpty());
        Test.stopTest();
    }
    //PLV-4376 - FIX - FIM

    @IsTest
    static void busca_apolice_por_numero(){       
        RestRequest req = new RestRequest();
        req.params.put('numeroApolice','12345');
        RestContext.request = req;           
        
        Test.startTest();             
            ConsultaApoliceREST.Response result = ConsultaApoliceREST.consultar();
            System.debug('resposta: ' + JSON.serialize(result));
            System.assert(result != null && !result.data.apolices.isEmpty());
        Test.stopTest();
    }
    
    @IsTest
    static void busca_apolice_sem_retorno(){
        RestRequest req = new RestRequest();
        req.params.put('numeroApolice', '54321');
        RestContext.request = req;
        Test.startTest();
            ConsultaApoliceREST.Response result = ConsultaApoliceREST.consultar();
            System.debug('resposta: ' + JSON.serialize(result));
            //System.assert(result != null && result.data.apolices.isEmpty() && result.data.statusChamada == 0); //FNPVVEP-44 INICIO/FIM
        Test.stopTest();
    }
    
    @IsTest
    static void busca_apolice_sem_parametros(){
        RestContext.request = new RestRequest();
        Test.startTest();
            ConsultaApoliceREST.Response result = ConsultaApoliceREST.consultar();
            System.debug('resposta: ' + JSON.serializePretty(result));
            System.assert(result != null && result.data.apolices.isEmpty() && result.data.statusChamada == -1 );
        Test.stopTest();
    }
    
    //FNPVVEP-44 INICIO
    @IsTest
    static void sizeApoliceTest1(){       
        RestRequest req = new RestRequest();
        req.params.put('numeroApolice','1-1-1391');
        RestContext.request = req;           
        
        Test.startTest();             
            ConsultaApoliceREST.Response result = ConsultaApoliceREST.consultar();
        Test.stopTest();
    }
    @IsTest
    static void sizeApoliceTest2(){       
        RestRequest req = new RestRequest();
        req.params.put('numeroApolice','1-1-1391-000015431');
        RestContext.request = req;           
        
        Test.startTest();             
            ConsultaApoliceREST.Response result = ConsultaApoliceREST.consultar();
        Test.stopTest();
    }
    
    @IsTest
    static void sizeApoliceTest3(){       
        RestRequest req = new RestRequest();
        req.params.put('numeroApolice','1-1391-000015431-1');
        req.params.put('statusApolice','Emitido');
        req.params.put('nomeSegurado','Francis Liu');
        //FNPVVEP-98 INICIO
        req.params.put('codigoOferta','VIDA_INDIVIDUAL');
        req.params.put('quantidadeDeMeses', '6');
        req.params.put('Origem', '18');
        req.params.put('Proposta', '00006767');
        req.params.put('susep','P5005J');
        req.params.put('cpf','43891231814');
        req.params.put('canal','Canal Distribuição Teste 001');
        req.params.put('idCanal','001');
        RestContext.request = req;  
        Account conta = [SELECT id, Cpf__c FROM Account LIMIT 1];   
        conta.Cpf__c = '438.912.318-14';  
        update conta;  
        //FNPVVEP-98 FIM
        Test.startTest();             
            ConsultaApoliceREST.Response result = ConsultaApoliceREST.consultar();
        Test.stopTest();
    }
    @IsTest
    static void sizeApoliceTest4(){       
        RestRequest req = new RestRequest();
        req.params.put('numeroApolice','1-1-1391-000015431-1');
        RestContext.request = req;           
        
        Test.startTest();             
            ConsultaApoliceREST.Response result = ConsultaApoliceREST.consultar();
        Test.stopTest();
    }
    //FNPVVEP-44 FIM
}