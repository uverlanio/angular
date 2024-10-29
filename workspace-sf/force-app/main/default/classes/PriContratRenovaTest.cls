/*******************************************************************************************************************************
* Classe de Teste da Controller do componente ContractRenList
* @author Squad Novos Ares
* @date 01/07/2022
* Classe criada por conta da história RVI-95
******************************************************************************************************************************/

@isTest
public with sharing class PriContratRenovaTest {
    @TestSetup
    static void makeData(){
        Account contaTeste = TestDataFactory.gerarConta();
        DadosCorretor__c dadosCorretor = TestDataFactory.gerarDadosCorretor(contaTeste);
        RamoSeguro__c ramoSegurado = TestDataFactory.gerarRamoSeguro(contaTeste);
        Garantia__c garantia1 = TestDataFactory.gerarGarantia();
        
        ContadorCodigo__c contCodigoTec = (ContadorCodigo__c) new ContadorCodigoFactory.ProdutoTecnico().createRecord();
	    ContadorCodigo__c contCodigoCom = (ContadorCodigo__c) new ContadorCodigoFactory.ProdutoComercial().createRecord();
        
        Product2 produtoTec = TestDataFactory.gerarProdutoTecnico();
        produtoTec.Status__c = 'Ativo';
        produtoTec.Segmento__c = 'Individual';
        update produtoTec;
        
        Product2 produtoCom = TestDataFactory.gerarProdutoComericial(produtoTec);
        produtoCom.Status__c ='ativo';
        produtoCom.Segmento__c = 'Individual';
        update produtoCom;

        CanalDistribuicao__c canalDistribuicao = TestDataFactory.gerarCanalDistribuicao();
        
        Opportunity orcamentoContratado = TestDataFactory.gerarOrcamentoObjeto(contaTeste, produtoCom, canalDistribuicao);
        
        // RVI-186-FIX02 - INICIO
        Opportunity orcamentoRenovado = new Opportunity(
            StageName = 'Em criação',
            CurrencyIsoCode = 'BRL',
            Name = 'ARQ-00006780',
            CloseDate = System.today().addDays(20),
            VigenciaInicial__c = System.today(),
            VigenciaFinal__c = System.today().addDays(1),
            Produto__c = produtoCom.Id,
            Probability = 10.0,
            RecordTypeId = RecordTypeBO.buscarTipoRegistro('Opportunity', 'VidaGrupo').Id,
            AccountId = contaTeste.Id,
            Numero__c = '00006780',
            CanalDistribuicao__c = canalDistribuicao.Id
        );
        insert orcamentoRenovado;

        Opportunity orcamentoNovo = new Opportunity(
            StageName = 'Em criação',
            CurrencyIsoCode = 'BRL',
            Name = 'ARQ-00006781',
            CloseDate = System.today().addDays(20),
            VigenciaInicial__c = System.today(),
            VigenciaFinal__c = System.today().addDays(1),
            Produto__c = produtoCom.Id,
            Probability = 10.0,
            RecordTypeId = RecordTypeBO.buscarTipoRegistro('Opportunity', 'VidaGrupo').Id,
            AccountId = contaTeste.Id,
            Numero__c = '00006781',
            CanalDistribuicao__c = canalDistribuicao.Id
        );
        insert orcamentoNovo;

        Opportunity orcamentoFinal = new Opportunity(
            StageName = 'Em criação',
            CurrencyIsoCode = 'BRL',
            Name = 'ARQ-00006782',
            CloseDate = System.today().addDays(20),
            VigenciaInicial__c = System.today(),
            VigenciaFinal__c = System.today().addDays(1),
            Produto__c = produtoCom.Id,
            Probability = 10.0,
            RecordTypeId = RecordTypeBO.buscarTipoRegistro('Opportunity', 'VidaGrupo').Id,
            AccountId = contaTeste.Id,
            Numero__c = '00006782',
            CanalDistribuicao__c = canalDistribuicao.Id
        );
        insert orcamentoFinal;
        // RVI-186-FIX02 - FIM

        Modalidade__c modalidade = TestDataFactory.gerarModalidade(ramoSegurado);

        ParametroVigencia__c paramVigencia = TestDataFactory.gerarParametroVigenciaProdutoComercial(produtoCom);
        paramVigencia.VigenciaMinimaRenovacao__c = 90;
        paramVigencia.Tipo__c = 'Periódico';
        update paramVigencia;

        Quote cot = TestDataFactory.gerarPropostaObjeto(produtoCom, ramoSegurado, contaTeste, dadosCorretor, orcamentoContratado, modalidade);
        cot.NumeroProposta__c = '00001910';

        Contract contrato = TestDataFactory.gerarContratoObjeto(produtoCom, ramoSegurado, contaTeste, dadosCorretor, cot);
        contrato.Oportunidade__c = orcamentoContratado.Id;
        contrato.NumeroPropostaUnico__c = '18-00001910';
        contrato.NumeroApolice__c = '000014419';
        contrato.Tipo__c = 'Novo';   //RVI-160 - INICIO/FIM
        contrato.Status = 'Emitido'; //RVI-160 - INICIO/FIM
        contrato.Endosso__c = '0';
        contrato.VigenciaFinal__c = System.today().addDays(30);		       		    		    
        contrato.StatusRenovacao__c = 'Não Renovado';
        contrato.CodigoRamo__c = '1391'; 
        contrato.AlteraFormaPagto__c = false; // RVI-186 - FIX02 - INICIO/FIM          
        update contrato;

        //RVI-189-INICIO
        ContentVersion content=new ContentVersion(); 
        content.Title='Header_Picture1_localStorage'; 
        content.PathOnClient='/' + content.Title + '.jpg'; 
        Blob bodyBlob=Blob.valueOf('Unit Test ContentVersion Body'); 
        content.VersionData=bodyBlob; 
        //content.LinkedEntityId=sub.id;
        content.origin = 'H';
        insert content;
                
        ContentDocumentLink contentlink=new ContentDocumentLink();
        contentlink.LinkedEntityId=contrato.id;
        contentlink.contentdocumentid=[select contentdocumentid from contentversion where id =: content.id].contentdocumentid;
        contentlink.ShareType = 'I';
        contentlink.Visibility = 'AllUsers'; 
        contentlink.LinkedEntityId = orcamentoContratado.id;
        insert contentlink;
        //RVI-189-FIM

    // RVI-186-FIX02 - INICIO 
        // Contract contratoRenovado = TestDataFactory.gerarContratoObjeto(produtoCom, ramoSegurado, contaTeste, dadosCorretor, cot);
        // contratoRenovado.Oportunidade__c = orcamentoRenovado.Id;
        // contratoRenovado.Name = contrato.Empresa__c + '-' + contrato.Sucursal__c  + '-' + contrato.CodigoRamo__c + '-' + contrato.NumeroApolice__c + '-1';       
        // contratoRenovado.PrimeiroContratoRenovacao__c = contrato.Id;		
        // contratoRenovado.NumeroPropostaUnico__c = '18-00001911';
        // contratoRenovado.NumeroApolice__c = '000014420';
        // contratoRenovado.ContratoRenovado__c = contrato.Id; //RVI-160 - INICIO/FIM
        // contratoRenovado.Tipo__c = 'Renovacao'; //RVI-160 - INICIO/FIM
        // contratoRenovado.Status = 'Emitido';    //RVI-160 - INICIO/FIM
        // contratoRenovado.Endosso__c = '1';
        // contratoRenovado.VigenciaFinal__c = System.today().addDays(366);		       		    		    
        // contratoRenovado.StatusRenovacao__c = 'Não Renovado'; //RVI-160 - INICIO/FIM
        // contratoRenovado.CodigoRamo__c = '1391';           
        // update contratoRenovado;

        Contract contratoRenovado = new Contract();
        contratoRenovado.Oportunidade__c = orcamentoRenovado.Id;
        contratoRenovado.Produto__c = produtoCom.Id;        
        contratoRenovado.RamoSeguro__c = ramoSegurado.Id;
        contratoRenovado.Status = 'Em elaboração' ;
        contratoRenovado.Empresa__c = '22';
        contratoRenovado.CodigoCorretor__c = dadosCorretor.Id;
        contratoRenovado.Proposta__c = cot.Id;
        contratoRenovado.AccountId = contaTeste.Id;
        contratoRenovado.AlteraFormaPagto__c = false;
        contratoRenovado.Name = contrato.Empresa__c + '-' + contrato.Sucursal__c  + '-' + contrato.CodigoRamo__c + '-' + contrato.NumeroApolice__c + '-1';       
        contratoRenovado.PrimeiroContratoRenovacao__c = contrato.Id;		
        contratoRenovado.NumeroPropostaUnico__c = '18-00001911';
        contratoRenovado.NumeroApolice__c = '000014419';
        contratoRenovado.Tipo__c = 'Renovacao'; //RVI-160 - INICIO/FIM
        contratoRenovado.Endosso__c = '1';
        contratoRenovado.VigenciaFinal__c = System.today().addDays(366);		       		    		    
        contratoRenovado.StatusRenovacao__c = 'Não Renovado'; //RVI-160 - INICIO/FIM
        contratoRenovado.CodigoRamo__c = '1391';   
        contratoRenovado.ApolicePdfDownloadUrl__c = 'https://MestreChico.com';  //RVI-57 - INICIO/FIM 
        insert contratoRenovado;
       
        // Contract contratoNovo = TestDataFactory.gerarContratoObjeto(produtoCom, ramoSegurado, contaTeste, dadosCorretor, cot);
        // contratoNovo.Oportunidade__c = orcamentoNovo.Id;
        // contratoNovo.Name = contrato.Empresa__c + '-' + contrato.Sucursal__c  + '-' + contrato.CodigoRamo__c + '-' + contrato.NumeroApolice__c + '-1';       
        // contratoNovo.ContratoRenovado__c = contratoRenovado.Id;		
        // contratoNovo.NumeroPropostaUnico__c = '18-00001912';
        // contratoNovo.NumeroApolice__c = '000014421';
        // contratoNovo.Tipo__c = 'Renovacao';
        // contratoNovo.Status = 'Emitido';        
        // contratoNovo.Endosso__c = '1';
        // contratoNovo.VigenciaFinal__c = System.today().addDays(366);		       		    		    
        // contratoNovo.StatusRenovacao__c = 'Não Renovado';
        // contratoNovo.CodigoRamo__c = '1391';           
        // update contratoNovo;

        Contract contratoNovo = new Contract();
        contratoNovo.Oportunidade__c = orcamentoNovo.Id;
        contratoNovo.Produto__c = produtoCom.Id;        
        contratoNovo.RamoSeguro__c = ramoSegurado.Id;
        contratoNovo.Status = 'Em elaboração' ;
        contratoNovo.Empresa__c = '22';
        contratoNovo.CodigoCorretor__c = dadosCorretor.Id;
        contratoNovo.Proposta__c = cot.Id;
        contratoNovo.AccountId = contaTeste.Id;
        contratoNovo.AlteraFormaPagto__c = false;
        contratoNovo.Name = contrato.Empresa__c + '-' + contrato.Sucursal__c  + '-' + contrato.CodigoRamo__c + '-' + contrato.NumeroApolice__c + '-1';       
        contratoNovo.PrimeiroContratoRenovacao__c = contrato.Id;		
        contratoNovo.NumeroPropostaUnico__c = '18-00001912';
        contratoNovo.NumeroApolice__c = '000014421';
        contratoNovo.Tipo__c = 'Renovacao'; //RVI-160 - INICIO/FIM
        contratoNovo.Endosso__c = '1';
        contratoNovo.VigenciaFinal__c = System.today().addDays(366);		       		    		    
        contratoNovo.StatusRenovacao__c = 'Não Renovado'; //RVI-160 - INICIO/FIM
        contratoNovo.CodigoRamo__c = '1391';   
        contratoNovo.ApolicePdfDownloadUrl__c = 'https://MestreChico.com';  //RVI-57 - INICIO/FIM 
        insert contratoNovo;
      
        // Contract contratoFinal = TestDataFactory.gerarContratoObjeto(produtoCom, ramoSegurado, contaTeste, dadosCorretor, cot);
        // contratoFinal.Oportunidade__c = orcamentoFinal.Id;
        // contratoFinal.Name = contrato.Empresa__c + '-' + contrato.Sucursal__c  + '-' + contrato.CodigoRamo__c + '-' + contrato.NumeroApolice__c + '-1';       
        // contratoFinal.ContratoRenovado__c = contrato.Id;		
        // contratoFinal.NumeroPropostaUnico__c = '18-00001913';
        // contratoFinal.NumeroApolice__c = '000014422';
        // contratoFinal.Tipo__c = 'Renovacao';
        // contratoFinal.Status = 'Emitido';        
        // contratoFinal.Endosso__c = '1';
        // contratoFinal.VigenciaFinal__c = System.today().addDays(366);		       		    		    
        // contratoFinal.StatusRenovacao__c = 'Não Renovado';
        // contratoFinal.CodigoRamo__c = '1391';           
        // update contratoFinal;

        Contract contratoFinal = new Contract();
        contratoFinal.Oportunidade__c = orcamentoFinal.Id;
        contratoFinal.Produto__c = produtoCom.Id;        
        contratoFinal.RamoSeguro__c = ramoSegurado.Id;
        contratoFinal.Status = 'Em elaboração' ;
        contratoFinal.Empresa__c = '22';
        contratoFinal.CodigoCorretor__c = dadosCorretor.Id;
        contratoFinal.Proposta__c = cot.Id;
        contratoFinal.AccountId = contaTeste.Id;
        contratoFinal.AlteraFormaPagto__c = false;
        contratoFinal.Name = contrato.Empresa__c + '-' + contrato.Sucursal__c  + '-' + contrato.CodigoRamo__c + '-' + contrato.NumeroApolice__c + '-1';       
        contratoFinal.PrimeiroContratoRenovacao__c = contrato.Id;		
        contratoFinal.NumeroPropostaUnico__c = '18-00001913';
        contratoFinal.NumeroApolice__c = '000014422';
        contratoFinal.Tipo__c = 'Renovacao'; //RVI-160 - INICIO/FIM
        contratoFinal.Endosso__c = '1';
        contratoFinal.VigenciaFinal__c = System.today().addDays(366);		       		    		    
        contratoFinal.StatusRenovacao__c = 'Não Renovado'; //RVI-160 - INICIO/FIM
        contratoFinal.CodigoRamo__c = '1391';   
        contratoFinal.ApolicePdfDownloadUrl__c = 'https://MestreChico.com';  //RVI-57 - INICIO/FIM 
        insert contratoFinal;
    // RVI-186-FIX02 - FIM 
    }

    //RVI-95 - FIX01 - INICIO
    @isTest
    static void testUpdCtr() {  

        String idCTR;
        
        List<Contract> lstCtr = [SELECT Id, PrimeiroContratoRenovacao__c, 
                                        ContratoRenovado__c, Tipo__c
                                FROM Contract]; 

        Test.startTest();     
        PriContratRenova priCtrREN = new PriContratRenova();           
        priCtrREN.updContracts(lstCTR);
        Test.stopTest();    

        System.assertEquals(lstCTR.size(), 4);
    }    
    //RVI-95 - FIX01 - FIM
}