@IsTest
public class BatchGerarPDFTest {
    public BatchGerarPDFTest() {}
    
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

        Quote proposta = new Quote();
        proposta.OpportunityId = opp.Id;
        proposta.Name = 'asd';
        proposta.Status = 'Em análise';
        proposta.GerarPDF__c = true;
        proposta.RealizarEnvioDocusign__c = true;
        proposta.Produto__c = produtoComercial.id; //TKCL-246 FIX05 INICIO/FIM
        insert proposta;

        CriticaProposta__c critica = new CriticaProposta__c();
        critica.Proposta__c = proposta.Id;
        critica.Status__c = 'Pendente';
        critica.Integracao__c = 'DOCUSIGN';
        insert critica;

        ContentVersion file = new ContentVersion(
            Title = 'Proposta-' + proposta.Name,
            VersionData = Blob.valueOf('TEST'), 
            PathOnClient = 'Proposta-' + proposta.Name + '.pdf',
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

        BatchGerarPDF batch = new BatchGerarPDF();
        Database.executeBatch(batch);

    }
}