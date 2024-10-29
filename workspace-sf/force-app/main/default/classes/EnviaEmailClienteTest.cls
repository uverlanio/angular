/*
@description  Classe de teste para as classes EnviaEmailCliente.cls e EnviaEmailCorretor.cls
@author Rogerio Menezes - Globant
@date 27/07/2022
@Classe criada por conta da história RVI-57
*/

@isTest
public class EnviaEmailClienteTest {
    @TestSetup
    static void makeData(){
        Account contaTeste = TestDataFactory.gerarConta();
        DadosCorretor__c dadosCorretor = TestDataFactory.gerarDadosCorretor(contaTeste);
        RamoSeguro__c ramoSegurado = TestDataFactory.gerarRamoSeguro(contaTeste);
        Garantia__c garantia1 = TestDataFactory.gerarGarantia();
        RamoGarantia__c ramoGarantia = TestDataFactory.gerarRamoGarantia(garantia1, ramoSegurado);
        
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

        GarantiaProduto__c garantiaTecnica = TestDataFactory.gerarGarantiaProdutoTecnico(produtoTec, garantia1, ramoSegurado);

        GarantiaProduto__c garantiaComercial = TestDataFactory.gerarGarantiaProdutoComercial(produtoCom, garantia1, garantiaTecnica, ramoSegurado);

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
        cot.email__c = 'abcd@qualqueremail.com';
        update cot;

        //RamoSeguro__c ramoSeguro, Modalidade__c modalidade, String name, String codigo
        FormaPagamento__c formPag = TestDataFactory.gerarFormaPagamento(ramoSegurado, modalidade, 'CARTAO DE CREDITO (TODAS PARC.EM CARTAO)', '62');

        Contract contrato = TestDataFactory.gerarContratoObjeto(produtoCom, ramoSegurado, contaTeste, dadosCorretor, cot);
        contrato.AlteraFormaPagto__c = false; // RVI-186-FIX02 - INICIO/FIM
        contrato.Oportunidade__c = orcamentoContratado.Id;
        contrato.NumeroPropostaUnico__c = '18-00001910';
        contrato.NumeroApolice__c = '000014419';
        contrato.Tipo__c = 'Novo';   //RVI-160 - INICIO/FIM
        contrato.Status = 'Emitido'; //RVI-160 - INICIO/FIM
        contrato.Endosso__c = '0';
        contrato.VigenciaFinal__c = System.today().addDays(30);		       		    		    
        contrato.StatusRenovacao__c = 'Renovação em andamento'; //RVI-160 - INICIO/FIM
        contrato.CodigoRamo__c = '1391';    
        contrato.ApolicePdfDownloadUrl__c = 'https://MestreChico.com'; //RVI-57 - INICIO/FIM       
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

        TipoRemuneracao__c tipoRemuneracao = TestDataFactory.gerarTipoRemuneracao('Contrato', 15, 1000, 'Integral');

        RemuneracaoContrato__c remCon = TestDataFactory.gerarRemuneracaoContrato(contrato, tipoRemuneracao);
        remCon.CurrencyIsoCode = 'BRL';
        remCon.Percentual__c = 10;
        remCon.Porcentagem_de_Retencao__c = 0;
        update remCon;

        //RVI-160 - INICIO
        RemuneracaoContrato__c remConRen = TestDataFactory.gerarRemuneracaoContrato(contratoRenovado, tipoRemuneracao);
        remConRen.CurrencyIsoCode = 'BRL';
        remConRen.Percentual__c = 10;
        remConRen.Porcentagem_de_Retencao__c = 0;
        update remConRen;
        //RVI-160 - FIM

        FavorecidoRemuneracaoContrato__c favRemCon = new FavorecidoRemuneracaoContrato__c();
        favRemCon.Conta__c = contaTeste.Id;
        favRemCon.CorretorLider__c = true;
        favRemCon.AntecipacaoComissao__c = true;
        favRemCon.RemuneracaoContrato__c = remCon.Id;
        favRemCon.Papel__c = 'Corretor';
        insert favRemCon;
        
        //RVI-160 - INICIO
        FavorecidoRemuneracaoContrato__c favRemConRen = new FavorecidoRemuneracaoContrato__c();
        favRemConRen.Conta__c = contaTeste.Id;
        favRemConRen.CorretorLider__c = true;
        favRemConRen.AntecipacaoComissao__c = true;
        favRemConRen.RemuneracaoContrato__c = remConRen.Id;
        favRemConRen.Papel__c = 'Corretor';
        insert favRemConRen;
        //RVI-160 - FIM

        GarantiaContrato__c garCtr = TestDataFactory.gerarGarantiaContrato(contrato, garantiaComercial);
        GarantiaContrato__c garCtrRen = TestDataFactory.gerarGarantiaContrato(contratoRenovado, garantiaComercial); //RVI-160 - INICIO/FIM
    }

    @istest static void envioCliTest(){
        List<EnviaEmailCliente.FlowInputs> requestIds = New List<EnviaEmailCliente.FlowInputs>();
        // RVI-186-FIX02 - INICIO
        Contract contratoOrginal = [SELECT Id,Tipo__c FROM Contract WHERE Tipo__c = 'Novo'];
        Contract contratoRenovado = [SELECT Id,Tipo__c, Status, ContratoRenovado__c FROM Contract WHERE Tipo__c = 'Renovacao'];
        contratoRenovado.Status = 'Emitido';
        contratoRenovado.ContratoRenovado__c = contratoOrginal.Id;
        update contratoRenovado;
        // RVI-186-FIX02 - FIM 

        List<Contract> lstCtrRen = [SELECT id, NumeroApolice__c, VigenciaFinal__c, email__c, Name, Proposta__r.Name, ApolicePdfDownloadUrl__c 
                                    FROM Contract WHERE Tipo__c = 'Renovacao' AND Status = 'Emitido' LIMIT 1];
        EnviaEmailCliente.FlowInputs flowTest = new EnviaEmailCliente.FlowInputs();
        flowTest.contratoId = lstCtrRen[0].Id;
        flowTest.email = lstCtrRen[0].email__c;
        flowTest.linkApolice = lstCtrRen[0].ApolicePdfDownloadUrl__c;
        flowTest.nome = lstCtrRen[0].Name;
        flowTest.numeroApolice = lstCtrRen[0].NumeroApolice__c;
        flowTest.proposta = lstCtrRen[0].Proposta__r.Name;
        flowTest.vigenciaFinal = String.valueOf(lstCtrRen[0].VigenciaFinal__c);
        requestIds.add(flowTest);
        Test.startTest();       
        EnviaEmailCliente.formatarEmailCliente(requestIds);
        Test.stopTest();
    }

    @istest static void envioCorTest(){
        List<EnviaEmailCorretor.FlowInputs> requestIds = New List<EnviaEmailCorretor.FlowInputs>();
        // RVI-186-FIX02 - INICIO
        Contract contratoOrginal = [SELECT Id,Tipo__c FROM Contract WHERE Tipo__c = 'Novo'];
        Contract contratoRenovado = [SELECT Id,Tipo__c, Status, ContratoRenovado__c FROM Contract WHERE Tipo__c = 'Renovacao'];
        contratoRenovado.Status = 'Emitido';
        contratoRenovado.ContratoRenovado__c = contratoOrginal.Id;
        update contratoRenovado; 
        // RVI-186-FIX02 - FIM 

        List<Contract> lstCtrRenCor = [SELECT id, NumeroApolice__c, VigenciaFinal__c, email__c, Name, Proposta__r.Name, ApolicePdfDownloadUrl__c 
                                       FROM Contract WHERE Tipo__c = 'Renovacao' AND Status = 'Emitido' LIMIT 1];
        EnviaEmailCorretor.FlowInputs flowTestCor = new EnviaEmailCorretor.FlowInputs();
        flowTestCor.contratoId = lstCtrRenCor[0].Id;
        flowTestCor.email = lstCtrRenCor[0].email__c;
        flowTestCor.linkApolice = lstCtrRenCor[0].ApolicePdfDownloadUrl__c;
        flowTestCor.nome = lstCtrRenCor[0].Name;
        flowTestCor.numeroApolice = lstCtrRenCor[0].NumeroApolice__c;
        flowTestCor.proposta = lstCtrRenCor[0].Proposta__r.Name;
        flowTestCor.vigenciaFinal = String.valueOf(lstCtrRenCor[0].VigenciaFinal__c);
        requestIds.add(flowTestCor);
        Test.startTest();
        EnviaEmailCorretor.formatEmailPagCartao(requestIds);
        Test.stopTest();
    }

    // RVI-186 - INICIO 
    @isTest static void enviaBoletoTest(){
        List<EnviaEmailCorretor.FlowInputs> requestIds = New List<EnviaEmailCorretor.FlowInputs>();

        Account conta = [SELECT Id From Account];
        RamoSeguro__c ramoSeguro = [SELECT Id, Empresa__c FROM RamoSeguro__c WHERE Empresa__c =: conta.Id];
        Modalidade__c modalidade = [SELECT Id, RamoSeguro__c FROM Modalidade__c WHERE RamoSeguro__c =: ramoSeguro.Id];

        FormaPagamento__c formaPagamento = new FormaPagamento__c();
		formaPagamento.Name = 'FRAC.1.A PARCELA CARNE';
		formaPagamento.Codigo__c = '41';
        formaPagamento.RamoSeguro__c = ramoSeguro.Id;
        formaPagamento.Modalidade__c = modalidade.Id;
        System.debug('FRAC.1.A PARCELA CARNE ' + formaPagamento.Name);
		insert formaPagamento;

        Quote proposta = [SELECT Id FROM Quote];
        proposta.FormaPagamento__c = formaPagamento.Id;
        update proposta;

        // RVI-186-FIX02 - INICIO  
        Contract contratoOrginal = [SELECT Id,Tipo__c, AlteraFormaPagto__c FROM Contract WHERE Tipo__c = 'Novo'];
        contratoOrginal.AlteraFormaPagto__c = true;
        update contratoOrginal;

        Contract contratoRenovado = [SELECT Id,Tipo__c, Status, ContratoRenovado__c FROM Contract WHERE Tipo__c = 'Renovacao'];
        contratoRenovado.Status = 'Emitido';
        contratoRenovado.ContratoRenovado__c = contratoOrginal.Id;
        update contratoRenovado; 

        List<Contract> lstCtrRenCor = [SELECT id, NumeroApolice__c, VigenciaFinal__c, email__c, Name, Proposta__r.Name, ApolicePdfDownloadUrl__c 
                                       FROM Contract WHERE Tipo__c = 'Renovacao' AND Status = 'Emitido' LIMIT 1];
        EnviaEmailCorretor.FlowInputs flowTestCor = new EnviaEmailCorretor.FlowInputs();
        flowTestCor.contratoId = lstCtrRenCor[0].Id;
        flowTestCor.email = lstCtrRenCor[0].email__c;
        flowTestCor.linkApolice = lstCtrRenCor[0].ApolicePdfDownloadUrl__c;
        flowTestCor.nome = lstCtrRenCor[0].Name;
        flowTestCor.numeroApolice = lstCtrRenCor[0].NumeroApolice__c;
        flowTestCor.proposta = lstCtrRenCor[0].Proposta__r.Name;
        flowTestCor.vigenciaFinal = String.valueOf(lstCtrRenCor[0].VigenciaFinal__c);
        requestIds.add(flowTestCor);
        Test.startTest();
        EnviaEmailCorretor.formatEmailPagCartao(requestIds);
        Test.stopTest();
        // RVI-186-FIX02 - FIM 

    }
    // RVI-186 - FIM 
}