/**
 * @author AVX - Daniel Zampieri
 * @date 2019-02-27
 * @description Produto Factory Class
 */
@isTest
public class ProdutoFactory {
	private static Map<String,Product2> mStaticRecord = new Map<String,Product2>();

// --------------------------------------Produto Tecnico--------------------------------------------------

	private static Product2 getRecordProdutoTecnico(){

		if(!mStaticRecord.containsKey('ProdutoTecnico')){
			Recordtype REC_ID_Product2 = RecordTypeBO.buscarTipoRegistro('Product2', 'ProdutoTecnico');
			System.debug('REC_ID_Product2 ' + REC_ID_Product2);
			mStaticRecord.put('ProdutoTecnico', new Product2(
				RecordTypeId = REC_ID_Product2.Id,
        		Name = 'TestProdutoTec',
        		Status__c = 'Em criação',
        		ProductCode = '92572',
        		VigenciaInicial__c = system.today(),
        		TipoCapital__c = 'Capital global',
        		Segmento__c = 'Individual',
        		TipoResponsavelPagamento__c = 'SEG',
        		NumeroSusep__c = '010101',
				RegistroSusep__c = '010101') //RVI-98 INICIO/FIM
			);
		}
		return mStaticRecord.get('ProdutoTecnico');
	}

	public class ProdutoTecnico extends SObjectFactory {

	public ProdutoTecnico() {

		super(getRecordProdutoTecnico());
		super.FIELD_INTERATOR = 'Name';
	}

	public void ativar() {

		Product2 produtoTecnico = mStaticRecord.get('ProdutoTecnico');
		System.debug('produtoTecnico.Status__c ' + produtoTecnico.Status__c);
		if (produtoTecnico.Status__c == 'Ativo') return;
		
		produtoTecnico.Status__c = 'Em ativação';
		produtoTecnico.NumeroSusep__c = '123';
		produtoTecnico.VersaoRenovacao__c = 'Versão atual';
		update produtoTecnico;
		produtoTecnico.Status__c = 'Ativo';
		update produtoTecnico;
	}
}

//---------------------------------------Produto Comercial------------------------------------------------

	private static Product2 getRecordProdutoComercial(Product2 produtoTec){

		if(!mStaticRecord.containsKey('ProdutoComercial')){

			Recordtype REC_ID_Product2 = RecordTypeBO.buscarTipoRegistro('Product2', 'ProdutoComercial');
			System.debug('produtoTec ' + produtoTec.Status__c);
            //Test
            produtoTec.Status__c = 'Ativo';
            update produtoTec;
            //Test
			mStaticRecord.put('ProdutoComercial', new Product2(
				RecordtypeId = REC_ID_Product2.Id,
				ProdutoTecnico__c = produtoTec.Id,
                GerarVoucher__c = produtoTec.GerarVoucher__c, //PLV 4440 INICIO/FIM
                Name = 'Nome Produto Comercial 2',
                Status__c = 'Em criação',
                ProductCode = '201700001',
                VigenciaInicial__c = System.today(),
                VigenciaFinal__c = System.today().addDays(1),
                TipoCapital__c = 'Capital uniforme',
                Segmento__c = 'Coletivo',
                TipoResponsavelPagamento__c = 'PAR',
                LimiteTotalCarregamento__c = 200,
				RegistroSusep__c = produtoTec.RegistroSusep__c, //RVI-98 INICIO/FIM
                NumeroSusep__c = '12345')
			);
		}
		return mStaticRecord.get('ProdutoComercial');
	}

	public class ProdutoComercial extends SObjectFactory {
	
		public ProdutoComercial() {

			this(
				(Product2) new ProdutoFactory.ProdutoTecnico().createRecord()
			);
		}

		public ProdutoComercial(Product2 produtoTec) {

			super(getRecordProdutoComercial(produtoTec));

		}

		public void ativar() {

			new ProdutoFactory.ProdutoTecnico().ativar();
			Product2 produtoComercial = mStaticRecord.get('ProdutoComercial');
			System.debug('produtoComercial.Status__c ' + produtoComercial.Status__c);

			if (produtoComercial.Status__c == 'Ativo') return;

			produtoComercial.Status__c = 'Ativo';
			produtoComercial.VigenciaInicial__c = System.now().date();
			produtoComercial.VigenciaFinal__c = System.now().date().addYears(1);        
			update produtoComercial;			
		}
	}

	/*public static Product2 ativar(Product2 produto){

		produto.Status__c = 'Ativo';
		update produto;

		return produto;
	}*/

}