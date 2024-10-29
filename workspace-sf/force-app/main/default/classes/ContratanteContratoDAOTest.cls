//FCVEP-29 - INICIO
@IsTest
public class ContratanteContratoDAOTest {

    @TestSetup
    static void makeData(){

            Account conta = new Account(
                RecordTypeId = RecordTypeBO.buscarTipoRegistro('Account', 'PessoaFisica').Id,
                LastName = 'Teste',
                Nacionalidade__c = 'Brasileira',
                CPF__c = '00478394659',
                Rg__c = '232323231',
                DataExpedicao__c = Date.today(),
                OrgaoExpedidor__c = '123132',
                PersonBirthDate = (Date.today()-7300),
                EstadoCivil__c = 'Solteiro (a)'
            );
            insert conta;            
            
            Opportunity oportunidade = new Opportunity(
                Name = 'Teste Contrato',
                StageName = 'Em criação',
                RecordTypeId = RecordTypeBO.buscarTipoRegistro('Opportunity', 'VidaIndividual').Id,
                AccountId = conta.Id,
                CloseDate = Date.today()
            );
            insert oportunidade;
    
            Account contaTeste = TestDataFactory.gerarConta();
            DadosCorretor__c dadosCorretor = TestDataFactory.gerarDadosCorretor(contaTeste);
            RamoSeguro__c ramoSegurado = TestDataFactory.gerarRamoSeguro(contaTeste);
            Garantia__c garantia1 = TestDataFactory.gerarGarantia();
            
            ContadorCodigo__c contCodigoTec = (ContadorCodigo__c) new ContadorCodigoFactory.ProdutoTecnico().createRecord();
            ContadorCodigo__c contCodigoCom = (ContadorCodigo__c) new ContadorCodigoFactory.ProdutoComercial().createRecord();
            
            Product2 produtoTec = TestDataFactory.gerarProdutoTecnico();
            produtoTec.Status__c = 'Ativo';
            update produtoTec;
            
            Product2 produtoCom = TestDataFactory.gerarProdutoComericial(produtoTec);
            produtoCom.Status__c 	= 'ativo';
            produtoCom.Segmento__c	= 'Viagem';
            update produtoCom;
    
            ParametroVigencia__c parametroCom = (ParametroVigencia__c) new ParametroVigenciaFactory.ParametroVigenciaComercial(produtoCom).createRecord();            
            CanalDistribuicao__c canalDistribuicao = TestDataFactory.gerarCanalDistribuicao();            
            Opportunity orcamentoContratado = TestDataFactory.gerarOrcamentoObjeto(contaTeste, produtoCom, canalDistribuicao);    
            ContadorCodigo__c contadorTecnico = (ContadorCodigo__c) new ContadorCodigoFactory.ProdutoTecnico().createRecord();
            ContadorCodigo__c contadorComercial = (ContadorCodigo__c) new ContadorCodigoFactory.ProdutoComercial().createRecord();    
            RamoSeguro__c ramoSeguro = (RamoSeguro__c) new RamoSeguroFactory(conta).createRecord();            
            Product2 produtoTecnico = (Product2) new ProdutoFactory.ProdutoTecnico().createRecord();

            produtoTecnico.Status__c = 'Em ativação';
            produtoTecnico.NumeroSusep__c = '123';
            produtoTecnico.VersaoRenovacao__c = 'Versão atual';
            update produtoTecnico;

            produtoTecnico.Status__c = 'Ativo';
            produtoTecnico.ProductCode = '49';
            produtoTecnico.Segmento__c = 'Individual';
            update produtoTecnico;

            Product2 produtoComercial = (Product2) new ProdutoFactory.ProdutoComercial(produtoTecnico).createRecord();
            produtoComercial.Status__c = 'Ativo';
            produtoComercial.ProductCode = 'APTLMKT';
            produtoComercial.Segmento__c = 'Individual';
            produtoComercial.CodigoPrecificaProduto__c = 'APTLMKT';
            update produtoComercial;
            
            ParametroVigencia__c parametroComViagem = (ParametroVigencia__c) new ParametroVigenciaFactory.ParametroVigenciaComercial(produtoComercial).createRecord();
            Modalidade__c modalidade = TestDataFactory.gerarModalidade(ramoSegurado);
            Quote cot = TestDataFactory.gerarPropostaObjeto(produtoCom, ramoSegurado, contaTeste, dadosCorretor, orcamentoContratado, modalidade);
            cot.NumeroProposta__c = '00001910';
            cot.Origem__c = '18';
            cot.PremioTotal__c = 0;
            update cot;
    
            Contract contrato = TestDataFactory.gerarContratoObjeto(produtoCom, ramoSegurado, contaTeste, dadosCorretor, cot);            
            contrato.Name 					= 'Erro';
            contrato.Usuario_temporario__c 	= '005L0000005jUuVIAU';
            contrato.Empresa__c 			= '1';
            contrato.Sucursal__c 			= '1';
            contrato.CodigoRamo__c 			= '1391';
            contrato.NumeroApolice__c 		= '000003417';
            contrato.Endosso__c 			= '0';
            contrato.Produto__c             = produtoCom.Id;
            contrato.Proposta__c            = cot.Id; 
            contrato.RamoSeguro__c          = ramoSeguro.Id; 
            contrato.Tipo__c                = 'Novo'; 
            contrato.VigenciaFinal__c       = System.today();         
            contrato.Origem__c              = '18'; 
            contrato.NumeroProposta__c      = cot.NumeroProposta__c; 
            update contrato;
    
            FormaPagamento__c formaPagamento = TestDataFactory.gerarFormaPagamento(ramoSeguro, modalidade, 'Cartão', '70');    
            Parceiro__c parceiro = TestDataFactory.gerarParceiro(conta, formaPagamento);            
            
            ContratanteContrato__c contratanteContrato = TestDataFactory.gerarContratanteContrato(contrato, contaTeste, conta);
            contratanteContrato.ResponsavelPagamento__c = conta.Id;
            contratanteContrato.QuantidadeParcelas__c = 12;
            contratanteContrato.TipoResponsavelPagamento__c = 'PAR';
            contratanteContrato.Iof__c = 14;
            contratanteContrato.PremioTotal__c = 1000;
            contratanteContrato.PremioComercial__c = 500;
            contratanteContrato.VencimentoDemaisParcelas__c = 'A cada 30 dias';
            contratanteContrato.VencimentoPrimeiraParcela__c = System.today();
            update contratanteContrato;
    }

    @IsTest
    public static void testObterContratoPorId() {

        Test.startTest();

        Contract contrato = [SELECT Id FROM Contract LIMIT 1];

        ContratanteContrato__c contratanteContrato = new ContratanteContrato__c(
            Contrato__c = contrato.Id
        );

        insert contratanteContrato;
        
        ContratanteContrato__c cttCtr = ContratanteContratoDAO.getInstance().obterContratoPorId(contratanteContrato.Id);
        
        Test.stopTest();

        System.assertEquals(contratanteContrato.Contrato__c, cttCtr.Contrato__c, 'Contrato do contratante encontrado.');
    }
    
    @IsTest
    public static void testObterContratCtr() {

        Test.startTest();

        Contract contrato = [SELECT Id FROM Contract LIMIT 1];

        ContratanteContrato__c contratanteContrato = new ContratanteContrato__c(
            Contrato__c = contrato.Id
        );

        insert contratanteContrato;
        
        List<ContratanteContrato__c> cttsCtr = ContratanteContratoDAO.getInstance().obterContratCtr(contratanteContrato.Contrato__c);
        
        Test.stopTest();

        System.assertEquals(contratanteContrato.Contrato__c, cttsCtr[0].Contrato__c, 'Contrato do contratante encontrado.');
    }
    
    @IsTest
    public static void testObterParcCtr() {

        public_parcelacontrato__x parcela = new public_parcelacontrato__x(
            idexterno__c = '123',
            datavencimento__c = Date.today(),
            status__c = 'IDANIMPLENTE'
        );

        Test.startTest();
        
        ContratanteContratoDAO.getInstance().obterParcCtr(parcela.idexterno__c);
        
        Test.stopTest();
    }
}
//FCVEP-29 - FIM