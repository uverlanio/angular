//PLV-2549 - Avanxo - Inicio - Classe de teste criada para cobrir os métodos validarGarantiaRelacionada e compararCamposGarantias da classe RegrasFabricaProdutos
@isTest
public class RegrasFabricaProdutosTest {
    @isTest 
    static void TesteRegras(){
        
    	Account contaPessoal = (Account) new AccountFactory.PessoaFisica().createRecord();
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
        
        RamoSeguro__c ramoSeguro = (RamoSeguro__c) new RamoSeguroFactory(contaPessoal).createRecord();
        RamoGarantia__c ramoGarantia2 = (RamoGarantia__c) new RamoGarantiaFactory(garantia, ramoSeguro).createRecord();
        
        GarantiaProduto__c garanProdTec = (GarantiaProduto__c) new GarantiaProdutoFactory.GarantiaProdutoTec(garantia, produtoTecnico, ramoSeguro).createRecord();
        Recordtype REC_ID_GarantiaProdutoTec = RecordTypeBO.buscarTipoRegistro('GarantiaProduto__c', 'ProdutoTecnico');
        GarantiaProduto__c garanProdTec2 = new GarantiaProduto__c(
            	Garantia__c = garantia.Id,
                Produto__c = produtoTecnico.Id,
                RamoSeguro__c = ramoSeguro.Id,
                OrdemPrioridade__c = 1,
                RecordTypeId = REC_ID_GarantiaProdutoTec.Id,
                TipoGarantia__c = 'Cobertura',
                TipoCapital__c = 'Capital uniforme',
                CodigoPromocao__c = 'VITST',
                VersaoTitulo__c = '1');
            
				insert garanProdTec2;
                
                // PLV - 3046 - INICIO
                LimiteGarantiaProduto__c lim = new LimiteGarantiaProduto__c(
                                                            GarantiaProduto__c = garanProdTec2.id,
                                                            CurrencyIsoCode = 'USD',
                                                            LimiteCapitalMinimo__c = 1,
                                                            LimiteCapitalMaximo__c = 100000
                                                            );
                insert lim;
                // PLV - 3046 - FIM
        
        GarantiaProduto__c garanProdCom = (GarantiaProduto__c) new GarantiaProdutoFactory.GarantiaProdutoCom(produtoComercial, garantia, garanProdTec, ramoSeguro).createRecord();
		Recordtype REC_ID_GarantiaProdutoCom = RecordTypeBO.buscarTipoRegistro('GarantiaProduto__c', 'ProdutoComercial');
        GarantiaProduto__c garanProdCom2 = new GarantiaProduto__c(
				Garantia__c = garantia.Id,
                GarantiaProduto__c = garanProdTec2.Id,
                Produto__c = produtoComercial.Id,
                OrdemPrioridade__c = 1,
                RecordTypeId = REC_ID_GarantiaProdutoCom.Id,
                TipoGarantia__c = 'Cobertura',
                TipoCapital__c = 'Capital uniforme',
                RamoSeguro__c = ramoSeguro.Id,
                TipoCaracteristicaEspecial__c = 'Cestas',
                LimiteMaximoCaracteristicaEspecial__c = 100,
                LimiteMinimoCaracteristicaEspecial__c = 10,
                CodigoPromocao__c = 'VITST',
                VersaoTitulo__c = '1',
                Obrigatoria__c = true,
                PrazoMaximoLiquidacao__c = 10,
                TipoPrazoMaximoLiquidacao__c = 'Dia',
                PrazoAvisoSinistro__c = 20,
                TipoPrazoAvisoSinistro__c = 'Ano',
                // PLV - 3046 - INICIO
				LimiteCapitalMinimo__c = 20,
				LimiteCapitalMaximo__c = 900,
				currencyIsoCode = 'USD');
                // PLV - 3046 - INICIO
        insert garanProdCom2;      
        
        GarantiaRelacionada__c garantiaRelTest = (GarantiaRelacionada__c) new GarantiaRelacionadaFactory.ProdutoTecnico(garanProdTec, garanProdTec2).createRecord();
        GarantiaRelacionada__c garantiaRelTest2 = (GarantiaRelacionada__c) new GarantiaRelacionadaFactory.ProdutoComercial(garanProdCom, garanProdCom2).createRecord();
        
        //PLV-3667 - INICIO
        garantiaRelTest2.Acumulativa__c = false;
        update garantiaRelTest2;
        //PLV-3667 - FIM
        
    }
}

//PLV-2549 - Avanxo - Fim