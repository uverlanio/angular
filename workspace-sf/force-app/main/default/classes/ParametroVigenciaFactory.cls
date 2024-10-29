//PLV-3460 Fix 5 - INICIO - Ajuste factory
//PLV-2673- Inicio
/**
 * @author AVX - Matheus Gomes
 * @date 2019-09-11
 * @description Factory Parâmetro de Vigência - PLV-2673
 */
@isTest
public class ParametroVigenciaFactory{
    
    private static Map<String,ParametroVigencia__c> mStaticRecord = new Map<String,ParametroVigencia__c>();
    
    //---------------------------------------Comercial------------------------------------------------

    public static ParametroVigencia__c getRecordParametroComercial(Product2 produto) {
      
      if(!mStaticRecord.containsKey('ParametroComercial')){

        Recordtype REC_ID_ACCOUNT = RecordTypeBO.buscarTipoRegistro('ParametroVigencia__c', 'ProdutoComercial');

        mStaticRecord.put('ParametroComercial', new ParametroVigencia__c(
          Produto__c = produto.Id,
                  ValidadeOrcamento__c = 30,
                  ValidadeProposta__c = 30,
                  PeriodoMaximoInadimplencia__c = 90,
                  TipoPeriodo__c = 'Anos',
                  PeriodoMaximoVigencia__c = 12,
                  PeriodoMinimoVigencia__c = 1,
          Tipo__c = 'Determinado'));
      }
		return mStaticRecord.get('ParametroComercial');
    }
    
    public class ParametroVigenciaComercial extends SObjectFactory{
      
      public ParametroVigenciaComercial() {

        this(
              (Product2) new ProdutoFactory.ProdutoComercial().createRecord()
            );
      }
    
      public ParametroVigenciaComercial(Product2 produto) {
    
        super(getRecordParametroComercial(produto));
      }
    }

    //---------------------------------------Tecnico------------------------------------------------

    public static ParametroVigencia__c getRecordParametroTecnico(Product2 produto) {
      
      if(!mStaticRecord.containsKey('ParametroTecnico')){

        Recordtype REC_ID_ACCOUNT = RecordTypeBO.buscarTipoRegistro('ParametroVigencia__c', 'ProdutoTecnico');

        mStaticRecord.put('ParametroTecnico', new ParametroVigencia__c(
          Produto__c = produto.Id,
                  ValidadeOrcamento__c = 30,
                  ValidadeProposta__c = 30,
                  PeriodoMaximoInadimplencia__c = 90,
                  TipoPeriodo__c = 'Anos',
                  PeriodoMaximoVigencia__c = 12,
                  PeriodoMinimoVigencia__c = 1,
          Tipo__c = 'Determinado'));
      }
		return mStaticRecord.get('ParametroTecnico');
    }
    
    public class ParametroVigenciaTecnico extends SObjectFactory{
      
      public ParametroVigenciaTecnico() {

        this(
              (Product2) new ProdutoFactory.ProdutoTecnico().createRecord()
            );
      }
    
      public ParametroVigenciaTecnico(Product2 produto) {
    
        super(getRecordParametroTecnico(produto));
      }
    }
}
//PLV-2673- Fim
//PLV-3460 Fix 5 - FIM