/****
@description Classe de Teste para a Classe CasoWizardControllerPlus
@author Pedro Braz - Sys4b
@date 16/06/2021
@Classe referente a historia PLV-4938  
*****/

@isTest
public class CasoWizardPlusControllerTest {

	@isTest
	static void validarCasoWizardController() {
		Account conta = (Account) new AccountFactory.PessoaFisica().createRecord();
		Garantia__c garantia = (Garantia__c) new GarantiaFactory().createRecord();

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
        Parceiro__c parceiro = (Parceiro__c) new ParceiroFactory(conta, formaPagamento).createRecord();

		Contract contrato = (Contract) new ContratoFactory.ContratoFactoryComParam(conta, produtoComercial, parceiro).createRecord();
        contrato.Endosso__c = '0';
        contrato.NumeroApolice__c = '1234';
        update contrato;

        ContratanteContrato__c contratante = (ContratanteContrato__c) new ContratanteFactory(contrato).createRecord();
        GrupoContrato__c grupo = (GrupoContrato__c) new GrupoFactory(contratante).createRecord();
		SeguradoContrato__c segurado = (SeguradoContrato__c) new SeguradoContratoFactory(conta, grupo).createRecord();
		GarantiaSeguradoContrato__c garanSegCont = (GarantiaSeguradoContrato__c) new GarantiaSeguradoContratoFactory(segurado, garantia).createRecord();
        segurado.VigenciaInicial__c = system.today();
        segurado.VigenciaFinal__c = system.today().addMonths(1);
        update segurado;

		RamoSeguro__c ramoSeguro = (RamoSeguro__c) new RamoSeguroFactory(conta).createRecord();
        RamoGarantia__c ramoGarantia = (RamoGarantia__c) new RamoGarantiaFactory(garantia, ramoSeguro).createRecord();
        GarantiaProduto__c garanProdTec = (GarantiaProduto__c) new GarantiaProdutoFactory.GarantiaProdutoTec(garantia, produtoTecnico, ramoSeguro).createRecord();
        GarantiaProduto__c garanProdCom = (GarantiaProduto__c) new GarantiaProdutoFactory.GarantiaProdutoCom(produtoComercial, garantia, garanProdTec, ramoSeguro).createRecord();

		garanSegCont.GarantiaProduto__c = garanProdCom.Id;
		update garanSegCont;

		garanProdCom.VigenciaGarantia__c = 'Contratação até fim da apólice';
		update garanProdCom;

		Case caso = (Case) new CasoFactory.AtendimentoSinistro(conta).createRecord();

		Case caso2 = (Case) new CasoFactory.AtendimentoBeneficio(conta).createRecord();

		Test.startTest();
			List<String> retornos1 = CasoWizardPlusController.validarpreenchimento('123');

			caso.Dataocorrencia__c = null;
			update caso;
			List<String> retornos2 = CasoWizardPlusController.validarpreenchimento(caso.id);

			caso.Dataocorrencia__c = System.today();
			caso.Type = '';
			update caso;
        
			List<String> retornos3 = CasoWizardPlusController.validarpreenchimento(caso.id);

			caso.Type = 'Benefício';
			caso.Vitima__c = '';
			update caso;
			List<String> retornos4 = CasoWizardPlusController.validarpreenchimento(caso.id);

			caso.Type = 'Sinistro';
			update caso;
			List<String> retornos5 = CasoWizardPlusController.validarpreenchimento(caso.id);
			
			String retornoAgg = CasoWizardPlusController.pesquisacontratos(caso.Id, 'Acidente');
            
            CasoWizardPlusController.setError('TESTE');
			List<Case> retornos6 = CasoWizardPlusController.validarSinistroDuplicado(caso.Id, 'Acidente');

         //PLV-5469 - INICIO
         
            caso.Type = 'Sinistro';
            caso.Dataocorrencia__c = system.today().addMonths(-1);
            update caso;
         
            segurado.VigenciaInicial__c = system.today().addMonths(-2);
            segurado.VigenciaFinal__c = system.today().addMonths(-1);
            update segurado;
            
			List<String> retornos7 = CasoWizardPlusController.validarpreenchimento(caso.id);
            SYSTEM.debug('segurado.VigenciaInicial__c'+ segurado.VigenciaFinal__c+ ' e  caso.Dataocorrencia__c = '+ caso.Dataocorrencia__c );
        
        //PLV-5469 - FIM
        
            //CasoWizardPlusController.retornoTO pRetoro = (CasoWizardPlusController.retornoTO) JSON.deserializeUntyped(retornoAgg);
        
			Map<String,Object> mapParse = (Map<String,Object>) JSON.deserializeUntyped(retornoAgg);
         	List<CasoWizardPlusController.garantiaTO> listGarantiaTO = (List<CasoWizardPlusController.garantiaTO>) JSON.deserialize(JSON.serialize(mapParse.get('garantias')),List<CasoWizardPlusController.garantiaTO>.class);
            List<CasoWizardPlusController.contratoTO> listContratoTO = (List<CasoWizardPlusController.contratoTO>) JSON.deserialize(JSON.serialize(mapParse.get('contratos')),List<CasoWizardPlusController.contratoTO>.class);

            if(listGarantiaTO!=null && listGarantiaTO.size()>0){
                listGarantiaTO[0].selecionado = true;
            }


            Map<String, Object> pJSON = new Map<String, Object>();
            pJSON.put('recordId',caso.Id);
            pJSON.put('contratos',listContratoTO);
            pJSON.put('garantiasOriginais',listGarantiaTO);
            pJSON.put('garantiasModificadas',listGarantiaTO);
            pJSON.put('tipoEvento','Acidente');
            
            String requestSTR = '';
            
            CasoWizardPlusController.criaCasoSinistroPlus(JSON.serialize(pJSON));
       
		Test.stopTest();
    }
 //PLV-5469 - INICIO
    @isTest
	static void validarCasoVigenciaFinalMaiorIgualDataocorrencia() {
		Account conta = (Account) new AccountFactory.PessoaFisica().createRecord();
		Garantia__c garantia = (Garantia__c) new GarantiaFactory().createRecord();

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
        Parceiro__c parceiro = (Parceiro__c) new ParceiroFactory(conta, formaPagamento).createRecord();

		Contract contrato = (Contract) new ContratoFactory.ContratoFactoryComParam(conta, produtoComercial, parceiro).createRecord();
        contrato.Endosso__c = '1';
        contrato.NumeroApolice__c = '1234';
        update contrato;

        ContratanteContrato__c contratante = (ContratanteContrato__c) new ContratanteFactory(contrato).createRecord();
        GrupoContrato__c grupo = (GrupoContrato__c) new GrupoFactory(contratante).createRecord();
		SeguradoContrato__c segurado = (SeguradoContrato__c) new SeguradoContratoFactory(conta, grupo).createRecord();
		GarantiaSeguradoContrato__c garanSegCont = (GarantiaSeguradoContrato__c) new GarantiaSeguradoContratoFactory(segurado, garantia).createRecord();
        segurado.VigenciaInicial__c = system.today().addMonths(-2);
        segurado.VIgenciaFinal__c = system.today().addMonths(-1);
        update segurado;

		RamoSeguro__c ramoSeguro = (RamoSeguro__c) new RamoSeguroFactory(conta).createRecord();
        RamoGarantia__c ramoGarantia = (RamoGarantia__c) new RamoGarantiaFactory(garantia, ramoSeguro).createRecord();
        GarantiaProduto__c garanProdTec = (GarantiaProduto__c) new GarantiaProdutoFactory.GarantiaProdutoTec(garantia, produtoTecnico, ramoSeguro).createRecord();
        GarantiaProduto__c garanProdCom = (GarantiaProduto__c) new GarantiaProdutoFactory.GarantiaProdutoCom(produtoComercial, garantia, garanProdTec, ramoSeguro).createRecord();

		garanSegCont.GarantiaProduto__c = garanProdCom.Id;
		update garanSegCont;

		garanProdCom.VigenciaGarantia__c = 'Contratação até fim da apólice';
		update garanProdCom;
		Case caso = (Case) new CasoFactory.AtendimentoSinistro(conta).createRecord();

        Test.startTest();
			List<String> retornos1 = CasoWizardPlusController.validarpreenchimento('123');
			caso.Dataocorrencia__c = system.today().addMonths(-1);
			caso.Type = 'Sinistro';
			update caso;
        
			List<String> retornos3 = CasoWizardPlusController.validarpreenchimento(caso.id);

			String retornoAgg = CasoWizardPlusController.pesquisacontratos(caso.Id, 'Acidente');
                   
			Map<String,Object> mapParse = (Map<String,Object>) JSON.deserializeUntyped(retornoAgg);
         	List<CasoWizardPlusController.garantiaTO> listGarantiaTO = (List<CasoWizardPlusController.garantiaTO>) JSON.deserialize(JSON.serialize(mapParse.get('garantias')),List<CasoWizardPlusController.garantiaTO>.class);
            List<CasoWizardPlusController.contratoTO> listContratoTO = (List<CasoWizardPlusController.contratoTO>) JSON.deserialize(JSON.serialize(mapParse.get('contratos')),List<CasoWizardPlusController.contratoTO>.class);

            if(listGarantiaTO!=null && listGarantiaTO.size()>0){
                listGarantiaTO[0].selecionado = true;
            }

            Map<String, Object> pJSON = new Map<String, Object>();
            pJSON.put('recordId',caso.Id);
            pJSON.put('contratos',listContratoTO);
            pJSON.put('garantiasOriginais',listGarantiaTO);
            pJSON.put('garantiasModificadas',listGarantiaTO);
            pJSON.put('tipoEvento','Acidente');
            
            String requestSTR = '';
            
            CasoWizardPlusController.criaCasoSinistroPlus(JSON.serialize(pJSON));
       
		Test.stopTest();
    }
    
    @isTest
	static void validarCasoVigenciaInicialMaiorIgualDataocorrencia() {
		Account conta = (Account) new AccountFactory.PessoaFisica().createRecord();
		Garantia__c garantia = (Garantia__c) new GarantiaFactory().createRecord();

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
        Parceiro__c parceiro = (Parceiro__c) new ParceiroFactory(conta, formaPagamento).createRecord();

		Contract contrato = (Contract) new ContratoFactory.ContratoFactoryComParam(conta, produtoComercial, parceiro).createRecord();
        contrato.Endosso__c = '1';
        contrato.NumeroApolice__c = '1234';
        update contrato;

        ContratanteContrato__c contratante = (ContratanteContrato__c) new ContratanteFactory(contrato).createRecord();
        GrupoContrato__c grupo = (GrupoContrato__c) new GrupoFactory(contratante).createRecord();
		SeguradoContrato__c segurado = (SeguradoContrato__c) new SeguradoContratoFactory(conta, grupo).createRecord();
		GarantiaSeguradoContrato__c garanSegCont = (GarantiaSeguradoContrato__c) new GarantiaSeguradoContratoFactory(segurado, garantia).createRecord();
        segurado.VigenciaInicial__c = system.today().addMonths(-2);
        segurado.VIgenciaFinal__c = system.today().addMonths(-1);
        update segurado;

		RamoSeguro__c ramoSeguro = (RamoSeguro__c) new RamoSeguroFactory(conta).createRecord();
        RamoGarantia__c ramoGarantia = (RamoGarantia__c) new RamoGarantiaFactory(garantia, ramoSeguro).createRecord();
        GarantiaProduto__c garanProdTec = (GarantiaProduto__c) new GarantiaProdutoFactory.GarantiaProdutoTec(garantia, produtoTecnico, ramoSeguro).createRecord();
        GarantiaProduto__c garanProdCom = (GarantiaProduto__c) new GarantiaProdutoFactory.GarantiaProdutoCom(produtoComercial, garantia, garanProdTec, ramoSeguro).createRecord();

		garanSegCont.GarantiaProduto__c = garanProdCom.Id;
		update garanSegCont;

		garanProdCom.VigenciaGarantia__c = 'Contratação até fim da apólice';
		update garanProdCom;
		Case caso = (Case) new CasoFactory.AtendimentoSinistro(conta).createRecord();

        Test.startTest();
			List<String> retornos1 = CasoWizardPlusController.validarpreenchimento('123');
			caso.Dataocorrencia__c = system.today().addMonths(-2);
			caso.Type = 'Sinistro';
			update caso;
        
			List<String> retornos3 = CasoWizardPlusController.validarpreenchimento(caso.id);

			String retornoAgg = CasoWizardPlusController.pesquisacontratos(caso.Id, 'Acidente');
                   
			Map<String,Object> mapParse = (Map<String,Object>) JSON.deserializeUntyped(retornoAgg);
         	List<CasoWizardPlusController.garantiaTO> listGarantiaTO = (List<CasoWizardPlusController.garantiaTO>) JSON.deserialize(JSON.serialize(mapParse.get('garantias')),List<CasoWizardPlusController.garantiaTO>.class);
            List<CasoWizardPlusController.contratoTO> listContratoTO = (List<CasoWizardPlusController.contratoTO>) JSON.deserialize(JSON.serialize(mapParse.get('contratos')),List<CasoWizardPlusController.contratoTO>.class);

            if(listGarantiaTO!=null && listGarantiaTO.size()>0){
                listGarantiaTO[0].selecionado = true;
            }

            Map<String, Object> pJSON = new Map<String, Object>();
            pJSON.put('recordId',caso.Id);
            pJSON.put('contratos',listContratoTO);
            pJSON.put('garantiasOriginais',listGarantiaTO);
            pJSON.put('garantiasModificadas',listGarantiaTO);
            pJSON.put('tipoEvento','Acidente');
            
            String requestSTR = '';
            
            CasoWizardPlusController.criaCasoSinistroPlus(JSON.serialize(pJSON));
       
		Test.stopTest();
    }
    //PLV-5469 - FIM
    
}