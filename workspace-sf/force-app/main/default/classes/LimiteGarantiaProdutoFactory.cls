/**
 * @author AVX - Leonardo Camacho
 * @date 2019-12-27
 * @description: Classe Factory do objeto LimiteGarantiaProduto__c.
 * Criada para a história PLV_3046
 */
public class LimiteGarantiaProdutoFactory extends SObjectFactory {
//PLV - 3046 - INICIO
    private static Map<String, LimiteGarantiaProduto__c> mStaticRecord = new Map<String, LimiteGarantiaProduto__c>();

    public static LimiteGarantiaProduto__c getRecordStatic(GarantiaProduto__c garantiaProdutoTecnico){
        
        if(mStaticRecord.isEmpty()){
            mStaticRecord.put('BRL', new LimiteGarantiaProduto__c(
                GarantiaProduto__c = garantiaProdutoTecnico.id,
                CurrencyIsoCode = 'BRL',
                LimiteCapitalMinimo__c = 1,
                LimiteCapitalMaximo__c = 100000)
            );

            mStaticRecord.put('EUR', new LimiteGarantiaProduto__c(
                GarantiaProduto__c = garantiaProdutoTecnico.id,
                CurrencyIsoCode = 'EUR',
                LimiteCapitalMinimo__c = 1,
                LimiteCapitalMaximo__c = 100000)
            );

            mStaticRecord.put('USD', new LimiteGarantiaProduto__c(
                GarantiaProduto__c = garantiaProdutoTecnico.id,
                CurrencyIsoCode = 'USD',
                LimiteCapitalMinimo__c = 1,
                LimiteCapitalMaximo__c = 100000)
            );
        }

        upsert mStaticRecord.values();

        return mStaticRecord.get('BRL');
    }

    public LimiteGarantiaProdutoFactory(){

        this(
            (GarantiaProduto__c) new GarantiaProdutoFactory.GarantiaProdutoTec().createRecord()        
        );
    }

    public LimiteGarantiaProdutoFactory(garantiaProduto__c garantiaProdutoTecnico){

        super(getRecordStatic(garantiaProdutoTecnico));
    }
//PLV - 3046 - FIM

}