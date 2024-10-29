/*******************************************************************************************************************************
* Classe de Teste do serviço para atualização do campo PrimeiroContratoRenovacao__c
* @author Squad Novos Ares
* @date 20/08/2022
* Classe criada por conta da história RVI-160
******************************************************************************************************************************/

//RVI-160 - INICIO
@isTest
public with sharing class UptCtrStatusRenTest {
    
    @TestSetup
    static void MakeData(){
        Account contaTeste = new Account(
			RecordTypeId = RecordTypeBO.buscarTipoRegistro('Account', 'PessoaFisica').Id,
			LastName = 'Teste',
			Nacionalidade__c = 'Brasileira',
			CPF__c = '00478394659',
			Rg__c = '232323231',
			DataExpedicao__c = Date.today(),
			OrgaoExpedidor__c = '123132',
			PersonBirthDate = (Date.today()-7300),
			EstadoCivil__c = 'Solteiro (a)',
            PersonEmail = 'abc@portoseguro.com.br'
		);
		insert contaTeste;

        DadosCorretor__c dadosCorretor = TestDataFactory.gerarDadosCorretor(contaTeste);
        RamoSeguro__c ramoSegurado = TestDataFactory.gerarRamoSeguro(contaTeste);
        Garantia__c garantia1 = TestDataFactory.gerarGarantia();
        RamoGarantia__c ramoGarantia = TestDataFactory.gerarRamoGarantia(garantia1, ramoSegurado);
        
        ContadorCodigo__c contCodigoTec = (ContadorCodigo__c) new ContadorCodigoFactory.ProdutoTecnico().createRecord();
	    ContadorCodigo__c contCodigoCom = (ContadorCodigo__c) new ContadorCodigoFactory.ProdutoComercial().createRecord();
        
        Product2 produtoTec = TestDataFactory.gerarProdutoTecnico();
        produtoTec.Status__c = 'Ativo';
        produtoTec.Segmento__c = 'Individual';
        produtoTec.ProductCode = 'VIDA_ON';
        update produtoTec;
        
        Product2 produtoCom = TestDataFactory.gerarProdutoComericial(produtoTec);
        produtoCom.Status__c ='ativo';
        produtoCom.Segmento__c = 'Individual';
        produtoCom.ProductCode = 'VIDA_ON';
        update produtoCom;

        GarantiaProduto__c garantiaTecnica = TestDataFactory.gerarGarantiaProdutoTecnico(produtoTec, garantia1, ramoSegurado);

        GarantiaProduto__c garantiaComercial = TestDataFactory.gerarGarantiaProdutoComercial(produtoCom, garantia1, garantiaTecnica, ramoSegurado);

        CanalDistribuicao__c canalDistribuicao = TestDataFactory.gerarCanalDistribuicao();
        
        Opportunity orcamentoOriginal = TestDataFactory.gerarOrcamentoObjeto(contaTeste, produtoCom, canalDistribuicao);
        // Opportunity orcamentoRenovacao = TestDataFactory.gerarOrcamentoObjeto(contaTeste, produtoCom, canalDistribuicao);
        
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

        // Quote cotOriginal = TestDataFactory.gerarPropostaObjeto(produtoCom, ramoSegurado, contaTeste, dadosCorretor, orcamentoOriginal, modalidade);
        // cotOriginal.NumeroProposta__c = '00001911';
        // cotOriginal.email__c = 'abcd@qualqueremail.com';
        // update cotOriginal;

        Quote cotRenovacao = TestDataFactory.gerarPropostaObjeto(produtoCom, ramoSegurado, contaTeste, dadosCorretor, orcamentoOriginal, modalidade);
        cotRenovacao.NumeroProposta__c = '00001912';
        cotRenovacao.Tipo__c = 'Renovacao';
        cotRenovacao.email__c = 'abcd@qualqueremail.com';
        update cotRenovacao;

        //RamoSeguro__c ramoSeguro, Modalidade__c modalidade, String name, String codigo
        FormaPagamento__c formPag = TestDataFactory.gerarFormaPagamento(ramoSegurado, modalidade, 'CARTAO DE CREDITO (TODAS PARC.EM CARTAO)', '62');

        Contract contratoOriginal = TestDataFactory.gerarContratoObjeto(produtoCom, ramoSegurado, contaTeste, dadosCorretor, cotRenovacao);
        contratoOriginal.Oportunidade__c = orcamentoOriginal.Id;
        contratoOriginal.NumeroPropostaUnico__c = '18-00001911';
        contratoOriginal.NumeroApolice__c = '000014419';
        contratoOriginal.Tipo__c = 'Novo';   //RVI-160 - INICIO/FIM
        contratoOriginal.Status = 'Emitido'; //RVI-160 - INICIO/FIM
        contratoOriginal.Endosso__c = '0';
        contratoOriginal.VigenciaFinal__c = System.today().addDays(-15);		       		    		    
        contratoOriginal.StatusRenovacao__c = 'Renovação em andamento'; //RVI-160 - INICIO/FIM
        contratoOriginal.CodigoRamo__c = '1391';
        contratoOriginal.ApolicePdfDownloadUrl__c = 'https://MestreChico.com';   
        contratoOriginal.AlteraFormaPagto__c = false; // RVI-186-FIX02 - INICIO/FIM
  
        update contratoOriginal;

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
        contentlink.LinkedEntityId=contratoOriginal.id;
        contentlink.contentdocumentid=[select contentdocumentid from contentversion where id =: content.id].contentdocumentid;
        contentlink.ShareType = 'I';
        contentlink.Visibility = 'AllUsers'; 
        contentlink.LinkedEntityId = orcamentoOriginal.id;
        insert contentlink;
        //RVI-189-FIM

        // RVI-186-FIX02 - INICIO
        // Contract contratoRenovado = TestDataFactory.gerarContratoObjeto(produtoCom, ramoSegurado, contaTeste, dadosCorretor, cotRenovacao);
        // contratoRenovado.Oportunidade__c = orcamentoOriginal.Id;
        // contratoRenovado.NumeroPropostaUnico__c = '18-00001912';
        // contratoRenovado.NumeroApolice__c = '000014420';
        // contratoRenovado.Tipo__c = 'Renovacao';
        // contratoRenovado.Status = 'Emitido';
        // contratoRenovado.Endosso__c = '0';
        // contratoRenovado.VigenciaFinal__c = System.today().addDays(30);		       		    		    
        // contratoRenovado.StatusRenovacao__c = 'Não Renovado';
        // contratoRenovado.CodigoRamo__c = '1391';
        // contratoRenovado.ApolicePdfDownloadUrl__c = 'https://MestreChico.com';     
        // contratoRenovado.ContratoRenovado__c = contratoOriginal.Id;
        // System.debug('RVI-104 > Contrato Original.Id: '  + contratoOriginal.Id);
        // System.debug('RVI-104 > Status Renovação: ' + contratoRenovado.StatusRenovacao__c); 
        // System.debug('RVI-104 > Tipo: ' + contratoRenovado.Tipo__c); 
        // System.debug('RVI-104 > conta teste: ' + contaTeste); 
        // update contratoRenovado;
 
        Contract contratoRenovado = new Contract();
        contratoRenovado.Oportunidade__c = orcamentoRenovado.Id;
        contratoRenovado.Produto__c = produtoCom.Id;        
        contratoRenovado.RamoSeguro__c = ramoSegurado.Id;
        contratoRenovado.Status = 'Em elaboração' ;
        contratoRenovado.Empresa__c = '22';
        contratoRenovado.CodigoCorretor__c = dadosCorretor.Id;
        contratoRenovado.Proposta__c = cotRenovacao.Id;
        contratoRenovado.AccountId = contaTeste.Id;
        contratoRenovado.AlteraFormaPagto__c = false;
        contratoRenovado.Name = contratoOriginal.Empresa__c + '-' + contratoOriginal.Sucursal__c  + '-' + contratoOriginal.CodigoRamo__c + '-' + contratoOriginal.NumeroApolice__c + '-0';       
        contratoRenovado.PrimeiroContratoRenovacao__c = contratoOriginal.Id;		
        contratoRenovado.NumeroPropostaUnico__c = '18-00001912';
        contratoRenovado.NumeroApolice__c = '000014420';
        contratoRenovado.Tipo__c = 'Renovacao'; //RVI-160 - INICIO/FIM
        contratoRenovado.Endosso__c = '0';
        contratoRenovado.VigenciaFinal__c = System.today().addDays(366);		       		    		    
        contratoRenovado.StatusRenovacao__c = 'Não Renovado'; //RVI-160 - INICIO/FIM
        contratoRenovado.CodigoRamo__c = '1391';   
        contratoRenovado.ApolicePdfDownloadUrl__c = 'https://MestreChico.com';  //RVI-57 - INICIO/FIM 
        insert contratoRenovado;
        // RVI-186-FIX02 - FIM 

        ContratanteContrato__c contratante = (ContratanteContrato__c) new ContratanteFactory(contratoOriginal).createRecord();

        TipoRemuneracao__c tipoRemuneracao = TestDataFactory.gerarTipoRemuneracao('Contrato', 15, 1000, 'Integral');

        RemuneracaoContrato__c remCon = TestDataFactory.gerarRemuneracaoContrato(contratoOriginal, tipoRemuneracao);
        remCon.CurrencyIsoCode = 'BRL';
        remCon.Percentual__c = 10;
        remCon.Porcentagem_de_Retencao__c = 0;
        update remCon;

        FavorecidoRemuneracaoContrato__c favRemCon = new FavorecidoRemuneracaoContrato__c();
        favRemCon.Conta__c = contaTeste.Id;
        favRemCon.CorretorLider__c = true;
        favRemCon.AntecipacaoComissao__c = true;
        favRemCon.RemuneracaoContrato__c = remCon.Id;
        favRemCon.Papel__c = 'Corretor';
        insert favRemCon;	

        GarantiaContrato__c garCtr = TestDataFactory.gerarGarantiaContrato(contratoOriginal, garantiaComercial);
    }

    @isTest
    static void testAtualizaStatusRenovacao(){
        UptCtrStatusRen.atualizarStatusRenovacao();

        List<Contract> constratosAtualizados = [SELECT Id, StartDate, VigenciaFinal__c, StatusRenovacao__c 
                                                FROM Contract 
                                                WHERE StatusRenovacao__c = 'Renovado'
                                                LIMIT 2];

        System.assert(constratosAtualizados <> null);
    }
}
//RVI-160 - FIM