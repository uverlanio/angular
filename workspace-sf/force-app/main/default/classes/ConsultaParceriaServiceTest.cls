/****************************************************************************************************************************
 * Classe  de teste implementada para cobrir o serviço de consulta de contratos para parceiros                              *
 * @author : Globant                                                                                                        *
 * @date 21/08/2023                                                                                                         *
 * Classe implementada tendo como origem a história VIAG-17                                                                 *
 * **************************************************************************************************************************/

@isTest
public class ConsultaParceriaServiceTest {
    @testSetup
    public static void setupUnit(){
        Account conta = (Account) new AccountFactory.PessoaFisica().createRecord();
        ContadorCodigo__c contCodigoTec = (ContadorCodigo__c) new ContadorCodigoFactory.ProdutoTecnico().createRecord();
	    ContadorCodigo__c contCodigoCom = (ContadorCodigo__c) new ContadorCodigoFactory.ProdutoComercial().createRecord();
        
        Product2 produtoTecnico = (Product2) new ProdutoFactory.ProdutoTecnico().createRecord();
        produtoTecnico.NumeroSusep__c = '123';
        produtoTecnico.VersaoRenovacao__c = 'Versão atual';
        produtoTecnico.Status__c = 'Ativo';
        update produtoTecnico;
        
        Product2 produtoComercial = (Product2) new ProdutoFactory.ProdutoComercial(produtoTecnico).createRecord();
        produtoComercial.Status__c = 'Ativo';
        update produtoComercial;
        
        FormaPagamento__c formaPagamento = (FormaPagamento__c) new FormaPagamentoFactory().createRecord();
	    Parceiro__c parceiro = (Parceiro__c) new ParceiroFactory(conta, formaPagamento).createRecord();
        Contract contrato = (Contract) new ContratoFactory.ContratoFactoryComParam(conta, produtoComercial, parceiro).createRecord();
        
        ProdutoParceiro__c produtoParceiro = TestDataFactory.gerarProdutoParceiro(parceiro, produtoComercial);
        
        ContratanteContrato__c contratante = (ContratanteContrato__c) new ContratanteFactory(contrato).createRecord();
        contratante.Numero__c = 123;
        //PLV-3392 - INICIO
        contratante.IOF__c = 10;
        contratante.Contrato__c = contrato.Id;
        //PLV-3392 - FIM
        update contratante;
        
	    GrupoContrato__c grupo = (GrupoContrato__c) new GrupoFactory(contratante).createRecord();
        grupo.Numero__c = 123;
        update grupo;
        
	    SeguradoContrato__c segurado = (SeguradoContrato__c) new SeguradoContratoFactory(conta, grupo).createRecord();
        segurado.Numero__c = 123;
        update segurado;
        
        RamoSeguro__c ramoSeguro = (RamoSeguro__c) new RamoSeguroFactory(conta).createRecord();
        DadosCorretor__c dadosCorretor = (DadosCorretor__c) new DadosCorretorFactory(conta).createRecord();
        Modalidade__c modalidade = (Modalidade__c) new ModalidadeFactory(ramoSeguro).createRecord();    
        Opportunity orcamento = (Opportunity) new OrcamentoFactory.VidaIndividual(produtoComercial, conta).createRecord();
        Quote proposta = (Quote) new PropostaFactory(produtoComercial, ramoSeguro, conta, dadosCorretor, orcamento, modalidade).createRecord();
     	
       	contrato.Empresa__c = '1';
        contrato.Sucursal__c = '1';
        contrato.NumeroApolice__c = '12345';
        contrato.Endosso__c = '0';
        contrato.VigenciaFinal__c = contrato.StartDate.addMonths(3);  
        contrato.MeioComercializacao__c = 'ARQ';
        contrato.Proposta__c = proposta.Id;
        contrato.RamoSeguro__c = ramoSeguro.Id;
        contrato.Status = 'Emitido';
        contrato.StartDate = Date.parse('04/12/2023');
        contrato.PremioTotal__c = -600; //PLV-4588 INICIO/FIM
        update contrato;

        TipoRemuneracao__c tipoRemuneracao = TestDataFactory.gerarTipoRemuneracao('COR', 100, 200, null);

        RemuneracaoContrato__c remuneracaoContrato = TestDataFactory.gerarRemuneracaoContrato(contrato, tipoRemuneracao);
        RemuneracaoOrcamento__c remuneracaoOrcamento = TestDataFactory.gerarRemuneracaoOrcamento(orcamento, tipoRemuneracao);
        
        FavorecidoRemuneracaoContrato__c favorecidoRemuneracaoContrato = new FavorecidoRemuneracaoContrato__c();
        favorecidoRemuneracaoContrato.Conta__c = conta.Id;
        favorecidoRemuneracaoContrato.CorretorLider__c = TRUE;
        favorecidoRemuneracaoContrato.RemuneracaoContrato__c = remuneracaoContrato.Id;
        favorecidoRemuneracaoContrato.Susep__c ='P5005J';
        favorecidoRemuneracaoContrato.SusepEmissao__c ='P5005J';
        favorecidoRemuneracaoContrato.SusepOrcamento__c='P5005J';
        favorecidoRemuneracaoContrato.DadosCorretor__c = dadosCorretor.Id;
        favorecidoRemuneracaoContrato.Papel__c ='Corretor';
        favorecidoRemuneracaoContrato.Participacao__c =100;
        insert favorecidoRemuneracaoContrato;
    }

    @isTest
    static void testeConsultaContratos() 
    {
        String payload = '{"susep": "P5005J", "dataInicio": "04/12/2023", "dataFim": "04/12/2023"}';
        RestRequest requestPost = new RestRequest();
		requestPost.requestUri ='/services/apexrest/api/ConsultaPropostas';
		requestPost.httpMethod = 'POST';
		requestPost.requestBody = Blob.valueOf(payload);

		RestResponse resPost = new RestResponse();
		RestContext.response = resPost;
		RestContext.request = requestPost;
        RestContext.request.params.put('susep', 'P5005J');
        RestContext.request.params.put('dataInicio', '04/12/2023');
        RestContext.request.params.put('dataFim', '04/12/2023');
        
		ConsultaParceriaService.processarPost();
    }
}