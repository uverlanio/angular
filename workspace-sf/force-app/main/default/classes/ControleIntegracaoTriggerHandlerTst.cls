@isTest
public class ControleIntegracaoTriggerHandlerTst {
    @testSetup
    static void methodSetup(){
        //Bloco para criação de beneficiário - Início
        ContadorCodigo__c contCodigoTec2 = (ContadorCodigo__c) new ContadorCodigoFactory.ProdutoTecnico().createRecord();
        ContadorCodigo__c contCodigoCom2 = (ContadorCodigo__c) new ContadorCodigoFactory.ProdutoComercial().createRecord();
        Contact contato = (Contact) new ContactFactory().createRecord();
        Account contaPessoal = (Account) new AccountFactory.PessoaFisica().createRecord();
        Garantia__c garantia = (Garantia__c) new GarantiaFactory().createRecord();
        FormaPagamento__c formaPagamento = (FormaPagamento__c) new FormaPagamentoFactory().createRecord();
        Product2 produtoTecnico = (Product2) new ProdutoFactory.ProdutoTecnico().createRecord();
        produtoTecnico.Status__c = 'Em ativação';
        produtoTecnico.NumeroSusep__c = '123';
        produtoTecnico.VersaoRenovacao__c = 'Versão atual';
        update produtoTecnico;
        produtoTecnico.Status__c = 'Ativo';
        update produtoTecnico;
        Product2 produtoComercial = (Product2) new ProdutoFactory.ProdutoComercial(produtoTecnico).createRecord();
        Parceiro__c parceiro = (Parceiro__c) new ParceiroFactory(contaPessoal, formaPagamento).createRecord();
        Contract contrato = (Contract) new ContratoFactory.ContratoFactoryComParam(contaPessoal, produtoComercial, parceiro).createRecord();
        
        //Problema de pagamentos de Sinistros - INÍCIO
        RamoSeguro__c ramoSeguro = (RamoSeguro__c) new RamoSeguroFactory(contaPessoal).createRecord();
        contrato.Empresa__c = '12';
        contrato.RamoSeguro__c = ramoSeguro.Id;
        update contrato;
        //Problema de pagamentos de Sinistros - FIM
        
        ContratanteContrato__c contratante = (ContratanteContrato__c) new ContratanteFactory(contrato).createRecord();
        GrupoContrato__c grupo = (GrupoContrato__c) new GrupoFactory(contratante).createRecord();
        SeguradoContrato__c segurado = (SeguradoContrato__c) new SeguradoContratoFactory(contaPessoal, grupo).createRecord();
        GarantiaSeguradoContrato__c garantiaSegurado = (GarantiaSeguradoContrato__c) new GarantiaSeguradoContratoFactory(segurado, garantia).createRecord();
        Case casoAtendimento = (Case) new CasoFactory.AtendimentoSinistro().createRecord();   
        Case casoSinistro = (Case) new CasoFactory.Sinistro(casoAtendimento, contaPessoal).createRecord();
        //PLV-4535 - FIX 6 INICIO
        casoSinistro.DataDocumentacaoCompleta__c = system.today();
        update casoSinistro;
        //PLV-4535 - FIX 6 FIM        
        InformacaoBancaria__c infoBanc = (InformacaoBancaria__c) new InformacaoBancariaFactory.InfoPessoaFisica(contaPessoal).createRecord();
        PagamentoGarantia__c pagGaran = (PagamentoGarantia__c) new PagamentoGarantiaFactory(casoSinistro, garantiaSegurado).createRecord();
        BeneficiarioGarantia__c beneGaran = (BeneficiarioGarantia__c) new BeneficiarioGarantiaFactory.BenePessoaFisica(contaPessoal, infoBanc, pagGaran).createRecord();
        //Bloco para criação de beneficiário - Fim
        
        //Adaptaptações para regras de validação - Início
        casoSinistro.Contrato__c = contrato.Id;
        casoSinistro.ContactId = contato.id;
        casoSinistro.Garantia_do_segurado_do_contrato__c = garantiaSegurado.id;
        casoSinistro.NumeroSinistro__c = '';
        casoSinistro.Data_sinistro_avisado__c = System.today();
        casoSinistro.Status = 'Avisado';
        casoSinistro.Status_Dependente__c = 'Em Análise';
        casoSinistro.Segurado_do_Contrato__c = segurado.id;
        casoSinistro.ProcessaNumeroSinistro__c = true;
        update casoSinistro;
        System.debug('casoSinistro ' + casoSinistro);
        
        pagGaran.Fase__c = 'Em Análise';
        update pagGaran;
        
        //PLV-4198 - Inicio
        beneGaran.Observacao__c  = 'xpto';
        update beneGaran;
        //PLV-4198 - Fim
        
        casoSinistro.Status = 'Em Regulação';
        update casoSinistro;
        casoSinistro.Status = 'Liquidação';
        casoSinistro.Status_Dependente__c = 'Recusado';
        update casoSinistro;
        //Adaptaptações para regras de validação - Fim
    }
    
    //Problema de pagamentos de Sinistros - INÍCIO
    @isTest
    static void testUnitInsert() {
        BeneficiarioGarantia__c beneficiario = [SELECT Id FROM BeneficiarioGarantia__c LIMIT 1];
        ControleIntegracao__c controleIntegracao = (ControleIntegracao__c) new ControleIntegracaoFactory('75').getRecord();
        controleIntegracao.Status__c = 'Pendente';
        controleIntegracao.IdObjeto__c = beneficiario.Id;
        
        try {
            insert controleIntegracao;
			//PLV-4535 - FIX 6 INICIO
            /*List<ControleIntegracao__c> listCi = [SELECT Id, Status__c, CodigoIntegracao__c FROM ControleIntegracao__c WHERE Status__c = 'Pendente'];
            System.debug('listCi' + listCi);*/
			//PLV-4535 - FIX 6 FIM
            System.assertEquals(1, [SELECT COUNT() FROM ControleIntegracao__c WHERE Status__c = 'Pendente' AND (CodigoIntegracao__c = '75' OR CodigoIntegracao__c = '76')]);
        } catch (DmlException e) {
            System.assert(e.getMessage().contains('DUPLICATE_VALUE'));
        }
    }
    @isTest
    static void testUnitUpdate() {
        BeneficiarioGarantia__c beneficiario = [SELECT Id FROM BeneficiarioGarantia__c LIMIT 1];
        ControleIntegracao__c controleIntegracao = (ControleIntegracao__c) new ControleIntegracaoFactory('75').getRecord();
        controleIntegracao.Status__c = 'Processado';
        controleIntegracao.IdObjeto__c = beneficiario.Id;
        
        try {
            insert controleIntegracao;
            controleIntegracao.Status__c = 'Pendente';
            update controleIntegracao;
            System.assertEquals(1, [SELECT COUNT() FROM ControleIntegracao__c WHERE Status__c = 'Pendente' AND (CodigoIntegracao__c = '75' OR CodigoIntegracao__c = '76')]);
        } catch (DmlException e) {
            System.assert(e.getMessage().contains('DUPLICATE_VALUE'));
        }
    }
    //Problema de pagamentos de Sinistros - FIM
}