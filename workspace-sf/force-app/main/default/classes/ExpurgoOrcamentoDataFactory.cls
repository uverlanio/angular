public class ExpurgoOrcamentoDataFactory {
    public static void setupData() {
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
        produtoCom.Status__c ='ativo';
        update produtoCom;
        
        CanalDistribuicao__c canalDistribuicao = TestDataFactory.gerarCanalDistribuicao();
        canalDistribuicao.Status__c = 'Ativo';
        update canalDistribuicao;
        
        TipoRemuneracao__c tipoRemuneracao = TestDataFactory.gerarTipoRemuneracao('COR', 100, 200, null);
        
        // Opportunity orcamentoContratado = TestDataFactory.gerarOrcamentoObjeto(contaTeste, produtoCom, canalDistribuicao);
        // GarantiaOrcamento__c garantiaOrcamento = TestDataFactory.gerarGarantiaOrcamento(garantia1, orcamentoContratado);   
        // RemuneracaoOrcamento__c remuneracaoOrcamento = TestDataFactory.gerarRemuneracaoOrcamento(orcamentoContratado, tipoRemuneracao);
        // ContratanteOrcamento__c contratanteOrcamento = TestDataFactory.gerarContratanteOrcamento(orcamentoContratado, contaTeste);
        // GrupoOrcamento__c grupoOrcamento = TestDataFactory.gerarGrupoOrcamento(contratanteOrcamento);
        // SeguradoOrcamento__c seguradoOrcamento = TestDataFactory.gerarSeguradoOrcamento(grupoOrcamento);
        // Attachment anexo = new Attachment();   	
    	// anexo.Name='Unit Test Attachment';
    	// Blob bodyBlob=Blob.valueOf('Unit Test Attachment Body');
    	// anexo.body=bodyBlob;
        // anexo.parentId=orcamentoContratado.id;
        // insert anexo;
        
        // Modalidade__c modalidade = TestDataFactory.gerarModalidade(ramoSegurado);
        // Quote cot = TestDataFactory.gerarPropostaObjeto(produtoCom, ramoSegurado, contaTeste, dadosCorretor, orcamentoContratado, modalidade);
        
        // Contract contrato = TestDataFactory.gerarContratoObjeto(produtoCom, ramoSegurado, contaTeste, dadosCorretor, cot);
        // contrato.Oportunidade__c = orcamentoContratado.Id;
        // update contrato;
        
        Opportunity orcamentoNaoContratado = TestDataFactory.gerarOrcamentoObjeto(contaTeste, produtoCom, canalDistribuicao);
        GarantiaOrcamento__c garantiaOrcamentoNC = TestDataFactory.gerarGarantiaOrcamento(garantia1, orcamentoNaoContratado);   
        RemuneracaoOrcamento__c remuneracaoOrcamentoNC = TestDataFactory.gerarRemuneracaoOrcamento(orcamentoNaoContratado, tipoRemuneracao);
        ContratanteOrcamento__c contratanteOrcamentoNC = TestDataFactory.gerarContratanteOrcamento(orcamentoNaoContratado, contaTeste);
        GrupoOrcamento__c grupoOrcamentoNC = TestDataFactory.gerarGrupoOrcamento(contratanteOrcamentoNC);
        SeguradoOrcamento__c seguradoOrcamentoNC = TestDataFactory.gerarSeguradoOrcamento(grupoOrcamentoNC);
        Attachment anexoNC = new Attachment();   	
    	anexoNC.Name ='Unit Test Attachment';
    	Blob bodyBlobNC = Blob.valueOf('Unit Test Attachment Body');
    	anexoNC.body = bodyBlobNC;
        anexoNC.parentId = orcamentoNaoContratado.id;
        insert anexoNC;        
    }
}