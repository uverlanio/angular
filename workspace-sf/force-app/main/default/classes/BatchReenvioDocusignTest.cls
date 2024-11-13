@IsTest
public class BatchReenvioDocusignTest {
    public BatchReenvioDocusignTest() {}
    
    @IsTest
    static void sendBatch() {

        Opportunity opp = new Opportunity();
        opp.Name = 'asd';
        opp.StageName = 'Em criação';
        opp.CloseDate = System.today();
        insert opp;

        //TKCL-246 FIX05 INICIO
        ContadorCodigo__c contadorTecnico = (ContadorCodigo__c) new ContadorCodigoFactory.ProdutoTecnico().createRecord();
        ContadorCodigo__c contadorComercial = (ContadorCodigo__c) new ContadorCodigoFactory.ProdutoComercial().createRecord();

        Account conta = (Account) new AccountFactory.PessoaFisica().createRecord();
        RamoSeguro__c ramoSeguro = (RamoSeguro__c) new RamoSeguroFactory(conta).createRecord();
        CanalDistribuicao__c canalDistribuicao = (CanalDistribuicao__c) new CanalDistribuicaoFactory().createRecord(); 

        Modalidade__c modalidade = (Modalidade__c) new ModalidadeFactory(ramoSeguro).createRecord();
        
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
        //TKCL-246 FIX05 FIM

        // PLV-4545 - INICIO
        CriticaOrcamento__c criticaOrcamento = new CriticaOrcamento__c();
        criticaOrcamento.Acao__c = 'auto'; //INICIO/FIM | PLV-4647-VI-Guilherme Brito
        criticaOrcamento.Status__c = 'Pendente';
        criticaOrcamento.Origem__c = 'ODM';
        criticaOrcamento.Orcamento__c = opp.Id;
        criticaOrcamento.Justificativa__c = '123';
        insert criticaOrcamento;
        
        Canal_Subscricao__c cs = new Canal_Subscricao__c();
        cs.Name = 'QTR_INTERNO'; //ANNVI-222 INICIO/FIM
        cs.Marca_Docusign__c = 'Marcadeexemplodocusign';
        insert cs;
        
        PastaECM__c pasta = new PastaECM__c();
        pasta.Name = 'Proposta';
        pasta.Id_Pasta__c = '12312312321';
        insert pasta;
		// PLV-4545 - FIM

        //ANNVI-222 INICIO
        FormaPagamento__c formaPagamento = (FormaPagamento__c) new FormaPagamentoFactory().createRecord();
        formaPagamento.Codigo__c = '62';
        update formaPagamento;
        //ANNVI-222 FIM
        
        Quote proposta = new Quote();
        proposta.OpportunityId = opp.Id;
        proposta.Name = 'asd';
        proposta.Status = 'Em análise';
        proposta.RealizarEnvioDocusign__c = true;
        proposta.Produto__c = produtoComercial.id; //TKCL-246 FIX05 INICIO/FIM
        insert proposta;
        
        //ANNVI-222 INICIO
        ContratanteProposta__c contratanteProposta = (ContratanteProposta__c) new ContratantePropostaFactory(proposta, formaPagamento).getRecord();
        contratanteProposta.Conta__c = conta.Id;
        insert contratanteProposta;
        //ANNVI-222 FIM

        CriticaProposta__c critica = new CriticaProposta__c();
        critica.Proposta__c = proposta.Id;
        critica.Status__c = 'Pendente';
        critica.Integracao__c = 'DOCUSIGN';
        insert critica;

        ContentVersion file = new ContentVersion(
            Title = 'Proposta_' + proposta.Name,
            VersionData = Blob.valueOf('TEST'), 
            PathOnClient = 'Proposta_' + proposta.Name + '.pdf',
            origin = 'H'
        );

        insert file;

        file = [Select id, ContentDocumentId FROM ContentVersion WHERE Id =: file.Id];

        ContentDocumentLink fileLink = new ContentDocumentLink(
            LinkedEntityId = proposta.Id,
            ContentDocumentId = file.ContentDocumentId,
            ShareType = 'V'
        );

        insert fileLink;

        BatchReenvioDocusign batch = new BatchReenvioDocusign();
        Database.executeBatch(batch);

    }
}