/*******************************************************************************************************************************
* Classe de Teste do serviço para atualização do campo ContratoInicial__c
* @author Squad Novos Ares
* @date 13/06/2022
* Classe criada por conta da história RVI-105
******************************************************************************************************************************/

@isTest
public with sharing class UpdateCtrInicialTest {
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
        // Opportunity orcamentoEndossado = TestDataFactory.gerarOrcamentoObjeto(contaTeste, produtoCom, canalDistribuicao);
        Opportunity orcamentoEndossado = new Opportunity(
                StageName = 'Em criação',
                CurrencyIsoCode = 'BRL',
                Name = 'ARQ-00006790',
                CloseDate = System.today().addDays(20),
                VigenciaInicial__c = System.today(),
                VigenciaFinal__c = System.today().addDays(1),
                Produto__c = produtoCom.Id,
                Probability = 10.0,
                RecordTypeId = RecordTypeBO.buscarTipoRegistro('Opportunity', 'VidaGrupo').Id,
                AccountId = contaTeste.Id,
                Numero__c = '00006790',
                CanalDistribuicao__c = canalDistribuicao.Id
        );
        insert orcamentoEndossado;
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
        contrato.StatusRenovacao__c = 'Renovação em andamento'; //RVI-160 - INICIO/FIM
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
        // Contract contratoEndossado = TestDataFactory.gerarContratoObjeto(produtoCom, ramoSegurado, contaTeste, dadosCorretor, cot);
        // contratoEndossado.Oportunidade__c = orcamentoEndossado.Id;
        // contratoEndossado.Name = contrato.Empresa__c + '-' + contrato.Sucursal__c  + '-' + contrato.CodigoRamo__c + '-' + contrato.NumeroApolice__c + '-1';
        // contratoEndossado.ContratoOriginal__c = contrato.Id;
        // contratoEndossado.ContratoRenovado__c = contrato.Id;
        // contratoEndossado.NumeroPropostaUnico__c = '18-00001911';
        // contratoEndossado.NumeroApolice__c = '000014419';
        // contratoEndossado.Tipo__c = 'Renovacao';
        // contratoEndossado.Status = 'Emitido';
        // contratoEndossado.Endosso__c = '0';
        // contratoEndossado.VigenciaFinal__c = System.today().addDays(366);		       		    		    
        // contratoEndossado.StatusRenovacao__c = 'Não Renovado';
        // contratoEndossado.CodigoRamo__c = '1391';           
        // update contratoEndossado;

        Contract contratoEndossado = new Contract();
        contratoEndossado.Oportunidade__c = orcamentoEndossado.Id;
        contratoEndossado.Produto__c = produtoCom.Id;        
        contratoEndossado.RamoSeguro__c = ramoSegurado.Id;
        contratoEndossado.Status = 'Em elaboração' ;
        contratoEndossado.Empresa__c = '22';
        contratoEndossado.CodigoCorretor__c = dadosCorretor.Id;
        contratoEndossado.Proposta__c = cot.Id;
        contratoEndossado.AccountId = contaTeste.Id;
        contratoEndossado.AlteraFormaPagto__c = false;
        contratoEndossado.Name = contrato.Empresa__c + '-' + contrato.Sucursal__c  + '-' + contrato.CodigoRamo__c + '-' + contrato.NumeroApolice__c + '-0';       
        contratoEndossado.PrimeiroContratoRenovacao__c = contrato.Id;		
        contratoEndossado.NumeroPropostaUnico__c = '18-00001911';
        contratoEndossado.NumeroApolice__c = '000014419';
        contratoEndossado.Tipo__c = 'Renovacao'; //RVI-160 - INICIO/FIM
        contratoEndossado.Endosso__c = '0';
        contratoEndossado.VigenciaFinal__c = System.today().addDays(366);		       		    		    
        contratoEndossado.StatusRenovacao__c = 'Não Renovado'; //RVI-160 - INICIO/FIM
        contratoEndossado.CodigoRamo__c = '1391';   
        contratoEndossado.ApolicePdfDownloadUrl__c = 'https://MestreChico.com';  //RVI-57 - INICIO/FIM 
        insert contratoEndossado;
        // RVI-186-FIX02 - FIM 
    }

    @isTest
    static void testUpdSuccess() {
        Test.startTest(); 

        UpdateCtrInicial upCtrInicial = new UpdateCtrInicial();
        Id batchId = Database.executeBatch(upCtrInicial);
        Test.stopTest();
        
        List<Contract> contratos = [SELECT  Id, 
                                            Empresa__c, 
                                            Sucursal__c, 
                                            CodigoRamo__c, 
                                            NumeroApolice__c,
                                            Endosso__c, 
			                                Name
                                    FROM    Contract
                                    WHERE   Endosso__c = '0'    		      
                                    AND     Tipo__c != 'Cancelamento'  		      
                                    AND     Status  != 'Cancelado'     		               
                                    AND     Segmento__c = 'Individual' 		       
                                    AND     StatusRenovacao__c = 'Não Renovado'      
                                    AND     CodigoRamo__c = '1391'                  
                                    AND     NumeroApolice__c != null                   
                                    ORDER BY NumeroApolice__c DESC, Endosso__c ASC];

        Set<String> filtrCtr = new Set<String>();
        Map<String, Contract> mapCtr = new Map<String, Contract>();
        List<Contract> lstToUpdate = new List<Contract>();

        for(Contract ctr : contratos){
            filtrCtr.add('%'+ctr.Empresa__c+'-'+ctr.Sucursal__c+'-'+ctr.CodigoRamo__c+'-'+ctr.NumeroApolice__c+'%');
            System.debug('1 - RVI-170: '+ filtrCtr);
        }

        List<Contract> lstRen = [SELECT Id, Name, ContratoInicial__c 
                        FROM Contract
                        WHERE Endosso__c > '0'
                        AND StatusRenovacao__c = 'Não Renovado'
                        AND Segmento__c = 'Individual' 	
                        AND Status != 'Cancelado'
                        AND Name like :filtrCtr
                        ORDER BY NumeroApolice__c DESC, Endosso__c ASC];
        System.debug('2 - RVI-170: '+  contratos);
        System.assertEquals(contratos.size(), 1);
    }
}