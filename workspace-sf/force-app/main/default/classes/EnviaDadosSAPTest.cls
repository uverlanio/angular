//PLV-4148 - INICIO
@isTest
public class EnviaDadosSAPTest {
     
    @testSetup 
    static void setup() {
        Account contaFisica = (Account) new AccountFactory.PessoaJuridica().createRecord();
        contact cont = new contact(
            FirstName = 'santana',
            LastName = 'santana',
            AccountId  = contaFisica.Id
        );
        insert cont;
        contact contato = [SELECT Id FROM Contact WHERE AccountId =: contaFisica.Id];
        ContadorCodigo__c contCodigoTec = (ContadorCodigo__c) new ContadorCodigoFactory.ProdutoTecnico().createRecord();
        ContadorCodigo__c contCodigoCom = (ContadorCodigo__c) new ContadorCodigoFactory.ProdutoComercial().createRecord();
        Product2 produtoTecnico = (Product2) new ProdutoFactory.ProdutoTecnico().createRecord();
        produtoTecnico.Status__c = 'Ativo';
        update produtoTecnico;
        Product2 produtoComercial = (Product2) new ProdutoFactory.ProdutoComercial(produtoTecnico).createRecord();
        FormaPagamento__c formaPagamento = (FormaPagamento__c) new FormaPagamentoFactory().createRecord();
        Parceiro__c parceiro = (Parceiro__c) new ParceiroFactory(contaFisica, formaPagamento).createRecord();
        Contract contrato = (Contract) new ContratoFactory.ContratoFactoryComParam(contaFisica, produtoComercial, parceiro).createRecord();
        
        //PLV-4148 - INICIO
        RamoSeguro__c ramo = new RamoSeguro__c();
        ramo.Name = 'Segurado';
        ramo.CodigoEmpresa__c = '214';
        ramo.Codigo__c = '1369';
        ramo.IdExterno__c = '214_9';
        ramo.Status__c = 'Ativo';
        ramo.CodigoOrigemDoMovimentoBCP__c = '32';
        insert ramo;
        
        Modalidade__c modalidade = new Modalidade__c();
        modalidade.RamoSeguro__c = ramo.Id;
        modalidade.Name = 'Factory';
        modalidade.Codigo__c = '0';
        insert modalidade;
        
        //PLV-4148 - FIM        
        
        
        Recordtype casoAtendimento = RecordTypeBO.buscarTipoRegistro('Case', 'Atendimento');
        case caso = new case();
        
        Id IdRegistro = [SELECT Id, Name, DeveloperName, SobjectType	FROM RecordType where Name = 'Atendimento'].Id;
        //Recordtype REC_ID_SINISTRO = RecordTypeBO.buscarTipoRegistro('Case', 'Sinistro');
        caso.RecordTypeId = IdRegistro;
        caso.AccountId = contaFisica.Id;
        caso.ContactId = contato.Id;
        caso.Status_Dependente__c = 'Avisado';
        caso.Parceiro__c = parceiro.Id;
        caso.Nome_Segurado__c = 'Teste';
        caso.Cpf_Segurado__c = '075.487.587-87';
        //caso.digitoCpfSegurado = casoObj.Cpf_Segurado__c.substring(12, 14); //Digito CPF
        //caso.Dataocorrencia__c = Date.valueOf('2005-10-10');
        caso.Subject = 'Teste';
        caso.Description = 'Teste';			
        caso.Origin = 'Prestadora';
        caso.Numero_titulo__c = '14587452';
        caso.Vitima__c = 'Segurado';
        caso.IdPrestadora__c = 'Teste';
        //caso.Id = '254785478';
        caso.TipoEvento__c = 'Acidente';
        //caso.avisado = 'true';
        //caso.EmpresaSplit__c = 52.5;
        //caso.sucursal__c = 'Teste';
        caso.RamoSplit__c = 54.5;
        caso.Numero_Apolice__c  = '102458798754';
        //caso.endosso = objCasoSinistro.apolice.substring(10, 11);
        caso.SinistroPrioritario__c = True;
        //caso.edsTip = '2';
        caso.Type = 'Padrão';
        
        caso.Data_Aviso_Cliente__c = system.today();
        caso.Dataocorrencia__c = system.today();
        //caso.CurrencyIsoCode = 'USD';
        System.debug('casoPai = ' + caso);
        
        
        insert caso;
        
        case casoFilho = new case();
        
        Id IdRegistro1 = [SELECT Id, Name, DeveloperName, SobjectType	FROM RecordType where Name = 'Sinistro'].Id;
        //Recordtype REC_ID_SINISTRO = RecordTypeBO.buscarTipoRegistro('Case', 'Sinistro');
        //casoFilho.ParentId = caso.Id;
        casoFilho.RecordTypeId = IdRegistro1;
        casoFilho.ParentId = caso.Id;
        casoFilho.AccountId = contaFisica.Id;
        casoFilho.ContactId = contato.Id;
        casoFilho.Status_Dependente__c = 'Aberto';
        
        casoFilho.Data_Aviso_Cliente__c = system.today();
        casoFilho.Dataocorrencia__c = system.today().addDays(-30);
        casoFilho.CurrencyIsoCode = 'USD';
        casoFilho.Parceiro__c = parceiro.Id;
      
        casoFilho.Contrato__c = contrato.Id;
      
        insert casoFilho;
        //PLV-4148-FIX1 - INICIO
        TestDataFactory.gerarFatura();
		Fatura__c fatura = [SELECT Id FROM Fatura__c LIMIT 1];             
        
        Requisicao_de_Pagamento__c rq = new Requisicao_de_Pagamento__c();
        rq.Valor_da_Cotacao_de_Moeda_Estrangeira__c = 4;
        rq.Valor_Total_Prestadora__c = 100;
        rq.Data_de_Final_de_Periodo__c = Date.today().addDays(20);
        rq.Data_de_Inicio_de_Periodo__c = Date.today().addDays(-10);
        rq.Contas_de_Parceiro__c = contaFisica.Id;
        rq.Status__c = 'Enviar para Registro Financeiro';
    	rq.Fatura__c = fatura.Id;
        rq.RecordTypeId = RecordTypeBO.buscarTipoRegistro('Requisicao_de_Pagamento__c', 'Indenizacao_de_sinistros').Id;      
        
        insert rq;  
        //PLV-4148-FIX1 - FIM
        
        Pagamento_de_Sinistro__c ps = new Pagamento_de_Sinistro__c();
        ps.Beneficiario_da_Garantia__c = contaFisica.Id;
        ps.Requisicao_de_Pagamento__c = rq.Id;
        ps.Caso_de_Sinistro__c = casoFilho.Id;
        //PLV-4148-FIX1 - INICIO
        ps.Valor_total_a_ser_indenizado__c = 10;
        //PLV-4148-FIX1 - FIM
        insert ps;
  
        
    }
    public static testmethod  void testaServicoSAP(){
        String json = '{'+
            '   \"ordempagamento\":{'+
            '      \"codigoOrigem\":\"35\",'+
            '      \"empresa\":\"01\",'+
            '      \"moeda\":\"BRL\",'+
            '      \"numeroDocumento\":\"RP-12\",'+
            '      \"numeroSinistroAno\":\"12334/2020\",'+
            '      \"localRiscoUF\":\"SP\",'+
            '      \"tipoUsuAprov\":\"F\",'+
            '      \"codigoEmpMatAprov\":\"01\",'+
            '      \"matriculaRespAprov\":\"14677\",'+
            '      \"tipoUsuarioRequisitante\":\"F\",'+
            '      \"codigoEmpMatRequisitante\":\"01\",'+
            '      \"matriculaRespRequisitante\":\"07701\",'+
            '      \"dataAprovLegado\":\"29072020\",'+
            '      \"dataContabil\":\"29072020\",'+
            '      \"indTributavel\":\"N\",'+
            '      \"categoriaContaContrato\":\"SG\",'+
            '      \"grupoPrevTesouraria\":\"PG\",'+
            '      \"visaoContaExterna\":\"E\",'+
            '      \"categoriaObjetoSeguro\":\"PG\",'+
            '      \"numeroApolice\":\"1\",'+
            '      \"numeroProposta\":\"\",'+
            '      \"numeroEndosso\":\"0\",'+
            '      \"dataVigenciaInicio\":\"\",'+
            '      \"dataVigenciaFinal\":\"\",'+
            '      \"susepCorretor\":\"L880YJ\",'+
            '      \"dataCobertura\":\"\",'+
            '      \"dataEmissao\":\"01072020\",'+
            '      \"fornecedor\":{'+
            '         \"origemDados\":\"Z018\",'+
            '         \"nome\":\"TESTE\",'+
            '         \"complementoNome\":\"Ltda\",'+
            '         \"termoPequisa\":\"TESTE\",'+
            '         \"tipoPessoa\":\"PJ\",'+
            '         \"cpfCnpj\":\"27351731\",'+
            '         \"ordemCnpj\":\"0001\",'+
            '         \"digitoCpfCnpj\":\"38\",'+
            '         \"email\":\"\",'+
            '         \"tipoParceiroNegocio\":\"0001\",'+
            '         \"endereco\":{'+
            '            \"endereco\":\"RUA DE TESTE\",'+
            '            \"complemento\":\"BLOCO 1\",'+
            '            \"cidade\":\"SAO PAULO\",'+
            '            \"numero\":\"100\",'+
            '            \"bairro\":\"TESTE\",'+
            '            \"uf\":\"SP\",'+
            '            \"cep\":\"02722-030\",'+
            '            \"pais\":\"BR\",'+
            '            \"prefixoTelefone\":\"\",'+
            '            \"telefone\":\"\"'+
            '         },'+
            '         \"tipoCategoriaCtaContrato\":\"PR\",'+
            '         \"grupoPrevisaoTesouraria\":\"PG\",'+
            '         \"visaoCtaExterna\":\"E\",'+
            '         \"requisitante\":{'+
            '            \"tipoUsuario\":\"1\",'+
            '            \"codigoEmpresaMatricula\":\"VIDA\",'+
            '            \"matriculaResponsavel\":\"USUARIO\"'+
            '         }'+
            '      },'+
            '      \"fatura\":{'+
            '         \"codigoSucursal\":\"11\",'+
            '         \"dataFatura\":\"01042020\",'+
            '         \"montanteBruto\":\"508.49\",'+
            '         \"dataBaseCalculoVenc\":\"01092020\",'+
            '         \"condicaoPagamento\":\"CP01\",'+
            '         \"categoriaNotaFiscal\":\"ZQ\",'+
            '         \"dadosBancarios\":{'+
            '            \"paisBanco\":\"\",'+
            '            \"banco\":\"\",'+
            '            \"agencia\":\"\",'+
            '            \"digitoAgencia\":\"\",'+
            '            \"contaCorrente\":\"\",'+
            '            \"digitoContaCorrente\":\"\"'+
            '         },'+
            '         \"aliquotaISS\":\"0\",'+
            '         \"numeroDocCompras\":\"\"'+
            '      },'+
            '      \"itens\":['+
            '         {'+
            '            \"numeroParcela\":\"1\",'+
            '            \"valorParcela\":\"508.49\",'+
            '            \"dataVencimento\":\"20082020\",'+
            '            \"formaPagamento\":\"B\",'+
            '            \"codigoSucursal\":\"011\",'+
            '            \"codigoMunicipio\":\"\",'+
            '            \"codigoRamoModalidade\":\"1369000\",'+
            '            \"centroCusto\":\"\",'+
            '            \"codigoDespesa\":\"19\",'+
            '            \"criterioOperacaoSub\":\"0\",'+
            '            \"grupoPrevTesouraria\":\"\",'+
            '            \"bloqueioDocumento\":\"\",'+
            '            \"descricaoOrdemPagamento\":\"\"'+
            '         }'+
            '      ]'+
            '   }'+
            '}';
        
        
       String retorno = '{'+
		'   \"retornofornecedor\":{'+
		'      \"nroDocCPFCNPJFornecedor\":\"27351731000138\",'+
		'      \"mensagens\":['+
		'         {'+
		'  \"codigoRetorno\":\"003\",'+
		'  \"mensagemRetorno\":\"Fornecedor 8567002 atualizado\"'+
		'}'+
		'      ]'+
		'   },'+
		'   \"retornoop\":{'+
		'      \"numeroDocumento\":\"RP-0135\",'+
		'      \"numeroDocumentoOrdemPag\":\"10037311043\",'+
		'      \"mensagens\":['+
		'         {'+
		'  \"codigoRetorno\":\"000\",'+
		'  \"mensagemErro\":\"\"'+
		'}'+
		'      ]'+
		'   }'+
		'}';
        
        Test.setMock(HttpCalloutMock.class, new MockHttpResponse(retorno, 200, 'OK'));
        
		        
        
        Test.startTest();
        //PLV-4148-FIX1 - INICIO
        Requisicao_de_Pagamento__c rq = [SELECT Id, Status__c, Name  FROM Requisicao_de_Pagamento__c limit 1];
        EnviaDadosSAP.mockRequisicaoPagamento = rq;
               
        EnviaDadosSAP.enviaRequicaoPagamentoAPI(json, rq.Name);
        //PLV-4148-FIX1 - FIM
        
        Test.stopTest();
        //System.assertEquals(true, (retorno != null));
        
    }
    
   	 
}
//PLV-4148 - FIM