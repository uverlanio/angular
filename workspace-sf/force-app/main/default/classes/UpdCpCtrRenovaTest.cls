/*******************************************************************************************************************************
* Classe de Teste do serviço para atualização do campo PrimeiroContratoRenovacao__c
* @author Squad Novos Ares
* @date 23/06/2022
* Classe criada por conta da história RVI-45
******************************************************************************************************************************/

@isTest
public with sharing class UpdCpCtrRenovaTest {
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
        insert orcamentoRenovado;
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
        // Contract contratoRenovado = TestDataFactory.gerarContratoObjeto(produtoCom, ramoSegurado, contaTeste, dadosCorretor, cot);
        // contratoRenovado.Oportunidade__c = orcamentoRenovado.Id;
        // contratoRenovado.Name = contrato.Empresa__c + '-' + contrato.Sucursal__c  + '-' + contrato.CodigoRamo__c + '-' + contrato.NumeroApolice__c + '-1';
        // contratoRenovado.ContratoRenovado__c = contrato.Id;		
        // contratoRenovado.NumeroPropostaUnico__c = '18-00001911';
        // contratoRenovado.NumeroApolice__c = '000014419';
        // contratoRenovado.Tipo__c = 'Renovacao';
        // contratoRenovado.Status = 'Emitido';        
        // contratoRenovado.Endosso__c = '1';
        // contratoRenovado.VigenciaFinal__c = System.today().addDays(366);		       		    		    
        // contratoRenovado.StatusRenovacao__c = 'Não Renovado';
        // contratoRenovado.CodigoRamo__c = '1391';           
        // update contratoRenovado;

        //Contract contratoRenovado = TestDataFactory.gerarContratoObjeto(produtoCom, ramoSegurado, contaTeste, dadosCorretor, cot);
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
        // RVI-186-FIX02 - FIM 
    }

    @isTest
    static void testUpdSuccess() {
        Test.startTest(); 
        
        UpdCpCtrRenova updCpCtrRen = new UpdCpCtrRenova();
        Id batchId = Database.executeBatch(updCpCtrRen);
        Test.stopTest();
        
        List<Contract> contratos = [SELECT Id,                       
										   Name,			                        
										   PrimeiroContratoRenovacao__c,           
										   ContratoRenovado__c               
									FROM   Contract                     		   
									WHERE  ContratoRenovado__c != null
                                    AND    PrimeiroContratoRenovacao__c = null
                                    AND    Tipo__c = 'Renovacao'
                                    AND    CodigoRamo__c != '1377'
                                    AND    Status != 'Cancelado'
                                    AND    Segmento__c = 'Individual'];     

        List<Contract> lstToUpdate = new List<Contract>();
		
		if (contratos.size() == 0) {
            System.debug('Nenhum Contrato encontrado para atualização com os parâmetros informados');
            return;
        }
        
		for(Contract ctrOrig : contratos){       
            ctrOrig.PrimeiroContratoRenovacao__c = ctrOrig.ContratoRenovado__c;
		    lstToUpdate.add(ctrOrig); 
		}
		
		if(lstToUpdate.size() > 0){
			update lstToUpdate;
		}    

        System.assertEquals(contratos.size(), 1);
    }
}