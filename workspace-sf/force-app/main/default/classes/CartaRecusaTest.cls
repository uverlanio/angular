/*
PLV-4632 - CRIADO EM 22/11/2020
AUTOR: JEFERSON SANTANA
DESCRIÇÃO: CLASSE DE TESTE REFERENTE A CLASSE geracartarecusa
*/
@IsTest
public class CartaRecusaTest {
    @Istest
    public static void validarCartaRecusaTest(){
        Account contaPessoal = (Account) new AccountFactory.PessoaFisica().createRecord();
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
        ContratanteContrato__c contratante = (ContratanteContrato__c) new ContratanteFactory(contrato).createRecord();
        GrupoContrato__c grupo = (GrupoContrato__c) new GrupoFactory(contratante).createRecord();
        SeguradoContrato__c segurado = (SeguradoContrato__c) new SeguradoContratoFactory(contaPessoal, grupo).createRecord();
        GarantiaSeguradoContrato__c garantiaSegurado = (GarantiaSeguradoContrato__c) new GarantiaSeguradoContratoFactory(segurado, garantia).createRecord();

        RamoSeguro__c ramoSeguro = (RamoSeguro__c) new RamoSeguroFactory(contaPessoal).createRecord();
        RamoGarantia__c ramoGarantia = (RamoGarantia__c) new RamoGarantiaFactory(garantia, ramoSeguro).createRecord();
        GarantiaProduto__c garanProdTec = (GarantiaProduto__c) new GarantiaProdutoFactory.GarantiaProdutoTec(garantia, produtoTecnico, ramoSeguro).createRecord();
        GarantiaProduto__c garanProdCom = (GarantiaProduto__c) new GarantiaProdutoFactory.GarantiaProdutoCom(produtoComercial, garantia, garanProdTec, ramoSeguro).createRecord();

        DadosCorretor__c dadosCorretor = (DadosCorretor__c) new DadosCorretorFactory(contaPessoal).createRecord();
        TipoRemuneracao__c tipoRemuneracao = (TipoRemuneracao__c) new TipoRemuneracaoFactory().createRecord();
        RemuneracaoContrato__c remCont = (RemuneracaoContrato__c) new RemuneracaoContratoFactory(tipoRemuneracao, contrato).createRecord();
        FavorecidoRemuneracaoContrato__c favRemCont = (FavorecidoRemuneracaoContrato__c) new FavorecidoRemuneracaoContratoFactory(remCont, dadosCorretor).createRecord();

        ControleIntegracao__c controlInte = (ControleIntegracao__c) new ControleIntegracaoFactory().createRecord();

        Case casoAtendimento = (Case) new CasoFactory.AtendimentoSinistro().createRecord();
        
		Case casoSinistro = (Case) new CasoFactory.Sinistro(casoAtendimento, contaPessoal).createRecord();
        InformacaoBancaria__c infoBanc = (InformacaoBancaria__c) new InformacaoBancariaFactory.InfoPessoaFisica(contaPessoal).createRecord();
        PagamentoGarantia__c pagGaran = (PagamentoGarantia__c) new PagamentoGarantiaFactory(casoSinistro, garantiaSegurado).createRecord();
        BeneficiarioGarantia__c beneGaran = (BeneficiarioGarantia__c) new BeneficiarioGarantiaFactory.BenePessoaFisica(contaPessoal, infoBanc, pagGaran).createRecord();
        beneGaran.Observacao__c = 'TESTE';
        update beneGaran;
        Recordtype REC_ID_CASESINISTRO = RecordTypeBO.buscarTipoRegistro('Case', 'Sinistro');
        Test.startTest();
            casoSinistro.ContactId = contato.id;
            casoSinistro.Contrato__c = contrato.id;
            casoSinistro.Garantia_do_segurado_do_contrato__c = garantiaSegurado.id;
            casoSinistro.NumeroSinistro__c = '321';
            casoSinistro.Data_sinistro_avisado__c = System.today();
            casoSinistro.Status = 'Avisado';
            casoSinistro.Status_Dependente__c = 'Em Análise';
            casoSinistro.Segurado_do_Contrato__c = segurado.id;
            casoSinistro.ProcessaNumeroSinistro__c = true;
        	casoSinistro.RecordTypeId = REC_ID_CASESINISTRO.Id;
            update casoSinistro;
            Case sinistro1 = [SELECT Status, Status_Dependente__c FROM Case Where Id =: casoSinistro.Id];
           
            sinistro1.Status = 'Liquidação';
            sinistro1.Status_Dependente__c = 'Recusado';
            update sinistro1;

			Case sinistro2 = [SELECT Status, Status_Dependente__c, Motivos_de_recusa__c, Descricao_da_Recusa__c, Email_para_envio_da_recusa__c FROM Case Where Id =: sinistro1.Id];
            sinistro2.Status = 'Fechado';
        	//sinistro2.Status_Dependente__c = 'Recusado';
            sinistro2.Motivos_de_recusa__c = '6';
            sinistro2.Descricao_da_Recusa__c = 'teste';
            sinistro2.Email_para_envio_da_recusa__c = 'teste@teste.com.br';            
            update sinistro2;

            PastaECM__c dadosEDM = new PastaECM__c(Id_Pasta__c = '123', Name = 'carta recusa');
            insert dadosEDM;
        
           	Case sinistro3 = [SELECT Status, Status_Dependente__c, Motivos_de_recusa__c, Descricao_da_Recusa__c, Email_para_envio_da_recusa__c FROM Case Where Id =: sinistro1.Id];
            sinistro3.Status = 'Fechado';
        	sinistro3.Status_Dependente__c = 'Pago';
        	sinistro2.Motivos_de_recusa__c = 'teste';
            sinistro3.Descricao_da_Recusa__c = 'teste';
            sinistro3.Email_para_envio_da_recusa__c = 'teste@teste.com.br';            
            update sinistro3;
           

            //GeraCartaRecusa.validarCartaRecusa(lcasos);
        Test.stopTest();
    }

}