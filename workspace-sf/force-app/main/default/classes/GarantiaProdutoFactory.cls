/**
 * @author AVX - Daniel Zampieri
 * @date 2019-03-06
 * @description GarantiaProduto__c Factory Class
 */
@isTest
public class GarantiaProdutoFactory {
	private static Map<String,GarantiaProduto__c> mStaticRecord = new Map<String,GarantiaProduto__c>();

// --------------------------------------Pessoa Física--------------------------------------------------

	private static GarantiaProduto__c getRecordGarantiaProdutoTec(Garantia__c garantia, Product2 produtoTec, RamoSeguro__c ramoSegurado){

		if(!mStaticRecord.containsKey('ProdutoTec')){
			Recordtype REC_ID_GarantiaProdutoTec = RecordTypeBO.buscarTipoRegistro('GarantiaProduto__c', 'ProdutoTecnico');
			Date datePersonBirthdate = Date.newInstance(1985, 02, 02);

			mStaticRecord.put('ProdutoTec', new GarantiaProduto__c(
				Garantia__c = garantia.Id,
                Produto__c = produtoTec.Id,
                RamoSeguro__c = ramoSegurado.Id,
                OrdemPrioridade__c = 1,
                RecordTypeId = REC_ID_GarantiaProdutoTec.Id,
                TipoGarantia__c = 'Cobertura',
				TipoCapital__c = 'Capital uniforme',
				TipoBeneficiario__c = 'O próprio segurado',
                CodigoPromocao__c = 'VITST',
                VersaoTitulo__c = '1')
			);
		}

		insert mStaticRecord.values();

		LimiteGarantiaProduto__c listaLimiteGarantiaProdTec = (LimiteGarantiaProduto__c) new LimiteGarantiaProdutoFactory(mStaticRecord.get('ProdutoTec')).createRecord();

		return mStaticRecord.get('ProdutoTec');
	}

public class GarantiaProdutoTec extends SObjectFactory {

	public GarantiaProdutoTec(){
		this(
			(Garantia__c) new GarantiaFactory().createRecord(),
			(Product2) new ProdutoFactory.ProdutoTecnico().createRecord(),
			(RamoSeguro__c) new RamoSeguroFactory().createRecord()
		);
	}

	public GarantiaProdutoTec(Garantia__c garantia, Product2 produtoTec, RamoSeguro__c ramoSegurado) {

		super(getRecordGarantiaProdutoTec(garantia, produtoTec, ramoSegurado));		
	}
}

//---------------------------------------Pessoa Jurídica------------------------------------------------

	private static GarantiaProduto__c getRecordGarantiaProdutoCom(Product2 produtoCom, Garantia__c garantia, GarantiaProduto__c garantiaProdutoTec, RamoSeguro__c ramoSegurado){

		if(!mStaticRecord.containsKey('ProdutoCom')){

			Recordtype REC_ID_GarantiaProdutoCom = RecordTypeBO.buscarTipoRegistro('GarantiaProduto__c', 'ProdutoComercial');

			mStaticRecord.put('ProdutoCom', new GarantiaProduto__c(
				Garantia__c = garantia.Id,
                GarantiaProduto__c = garantiaProdutoTec.Id,
                Produto__c = produtoCom.Id,
                OrdemPrioridade__c = 1,
                RecordTypeId = REC_ID_GarantiaProdutoCom.Id,
                TipoGarantia__c = 'Cobertura',
                TipoCapital__c = 'Capital uniforme',
                RamoSeguro__c = ramoSegurado.Id,
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
				OrigemSinistroBeneficio__c = 'Acidente', //PLV-3777 - INICIO/FIM
				//PLV-3046 - INICIO
				LimiteCapitalMinimo__c = 20,
				LimiteCapitalMaximo__c = 900,
				currencyIsoCode = 'BRL'
				//PLV-3046 - FIM
				
                //PLV-3560 - Inicio
                ,TipoBeneficiario__c = 'Mãe'
                //PLV-3560 - Fim
                
                //PLV-4707 - Inicio
                ,CancelaSegurado__c = true
                //PLV-4707 - Fim
				)
			);
		}
		return mStaticRecord.get('ProdutoCom');
	}

public class GarantiaProdutoCom extends SObjectFactory {
	
	public GarantiaProdutoCom() {

		this(
			(Product2) new ProdutoFactory.ProdutoComercial().createRecord(),
			(Garantia__c) new GarantiaFactory().createRecord(),
			(GarantiaProduto__c) new GarantiaProdutoFactory.GarantiaProdutoTec().createRecord(),
			(RamoSeguro__c) new RamoSeguroFactory().createRecord()
		);
	}

	public GarantiaProdutoCom(Product2 produtoCom, Garantia__c garantia, GarantiaProduto__c garantiaProdutoTec, RamoSeguro__c ramoSegurado) {

		super(getRecordGarantiaProdutoCom(produtoCom, garantia, garantiaProdutoTec, ramoSegurado));
	}
}
}