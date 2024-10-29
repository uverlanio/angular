/**
 * Controller para o componente SeletorGarantiasProduto.cmp
 * @author Fernando Barcellos @ 21/05/2018
 *
 **/
public class SeletorGarantiasProdutoController {
    //PLV_3046 - INICIO - Cadastro de Limite de garantia do produto - Viagem
    public class GarantiaProdutoWrapper{
		@AuraEnabled public String id {get;set;}
		@AuraEnabled public String Name {get;set;}
		@AuraEnabled public String RecordTypeId {get;set;}
		@AuraEnabled public String RecordTypeName {get;set;}
		@AuraEnabled public String GarantiaId {get;set;}
		@AuraEnabled public String GarantiaName {get;set;}
		@AuraEnabled public String GarantiaProdutoId {get;set;}
		@AuraEnabled public String RamoSeguroId {get;set;}
		@AuraEnabled public String RamoSeguroName {get;set;}
		@AuraEnabled public String FormaPagamento {get;set;}
		@AuraEnabled public String TipoGarantia {get;set;}
        @AuraEnabled public String CurrencyIsoCode {get;set;}
        @AuraEnabled public List<String> CurrencyIsoList {get;set;} 	//PLV_3046      
        //PLV_3450 - inicio  
        @AuraEnabled public String DemonstracaoPremio {get;set;}
        @AuraEnabled public List<String> DemonstracaoPremioList {get;set;} 
        //PLV_3450  - fim

		public GarantiaProdutoWrapper(){
			this.id = '';
			this.Name = '';
			this.RecordTypeId = '';
			this.RecordTypeName = '';
			this.GarantiaId = '';
			this.GarantiaName = '';
			this.GarantiaProdutoId = '';
			this.RamoSeguroId = '';
			this.RamoSeguroName = '';
			this.FormaPagamento = '';
			this.TipoGarantia = '';
			this.CurrencyIsoCode = '';
            this.CurrencyIsoList = new List<String>();	//PLV_3046       
            //PLV_3450 - inicio
            this.DemonstracaoPremioList = new List<String>();	
            this.DemonstracaoPremio = '';              
            //PLV_3450 - fim
		}
	}

    @AuraEnabled
    public static List<SeletorGarantiasProdutoController.GarantiaProdutoWrapper> buscarGarantiasProdutoTecnico(Id produtoTecnicoId) {
        List<GarantiaProduto__c> garantiasProduto =
        [
            SELECT 
                Id,
                Name,
                RecordTypeId,
                RecordType.Name,
                Garantia__c,
                Garantia__r.Name,
                GarantiaProduto__c,
                RamoSeguro__c,
                RamoSeguro__r.Name,
                FormaPagamento__c,
                TipoGarantia__c,
                CurrencyIsoCode,
                DemonstracaoPremio__c,               //PLV_3450
                (SELECT id, CurrencyIsoCode FROM  LimitesGarantiaProduto__r)
            FROM
                GarantiaProduto__c
            WHERE
                Produto__c =: produtoTecnicoId
            ORDER BY
            	//PLV-3312 - INICIO
                Garantia__r.Name ASC
            	//PLV-3312 - FIM
        ];

        List<SeletorGarantiasProdutoController.GarantiaProdutoWrapper> garantiasWrappers = new List<SeletorGarantiasProdutoController.GarantiaProdutoWrapper>();
        
        //PLV_3450 - inicio
        for(GarantiaProduto__c g: garantiasProduto){
            SeletorGarantiasProdutoController.GarantiaProdutoWrapper myGarantia = new SeletorGarantiasProdutoController.GarantiaProdutoWrapper();
            System.debug('id obj: ' +g.id);
            myGarantia.id = (String)g.Id;
            System.debug('id garan: ' +myGarantia.id);
            myGarantia.Name = g.Name;
            myGarantia.RecordTypeId = g.RecordTypeId;
            myGarantia.RecordTypeName = g.RecordType.Name;
            myGarantia.GarantiaId = g.Garantia__c;
            myGarantia.GarantiaName = g.Garantia__r.Name;
            myGarantia.GarantiaProdutoId = g.GarantiaProduto__c;
            myGarantia.RamoSeguroId = g.RamoSeguro__c;
            myGarantia.RamoSeguroName = g.RamoSeguro__r.Name;
            myGarantia.FormaPagamento = g.FormaPagamento__c;
            myGarantia.TipoGarantia = g.TipoGarantia__c;
            
            for(LimiteGarantiaProduto__c lgp : g.LimitesGarantiaProduto__r )	myGarantia.CurrencyIsoList.add(lgp.CurrencyIsoCode);
            for(Schema.PicklistEntry ple : GarantiaProduto__c.DemonstracaoPremio__c.getDescribe().getPicklistValues() )	myGarantia.DemonstracaoPremioList.add('' + ple.getValue());  
            
            garantiasWrappers.add(myGarantia);
        }
        //PLV_3450 - fim

        System.debug('::: garantiasProduto: ' + garantiasProduto);

        return garantiasWrappers;
        //PLV_3046 - FIM - Cadastro de Limite de garantia do produto - Viagem
    }
    //PLV_3046 - INICIO - Cadastro de Limite de garantia do produto - Viagem
    @AuraEnabled
    public static List<SeletorGarantiasProdutoController.GarantiaProdutoWrapper> buscarGarantiasProdutoComercial(Id produtoComercialId) {
        List<GarantiaProduto__c> garantiasProduto =
        [
            SELECT 
                Id,
                Name,
                RecordTypeId,
                RecordType.Name,
                Garantia__c,
                Garantia__r.Name,
                GarantiaProduto__c,
                RamoSeguro__c,
                RamoSeguro__r.Name,
                FormaPagamento__c,
                TipoGarantia__c,
                CurrencyIsoCode
            FROM
                GarantiaProduto__c
            WHERE
                Produto__c =: produtoComercialId
            ORDER BY
            	//PLV-3312 - INICIO
                Garantia__r.Name ASC
            	//PLV-3312 - FIM
        ];

        List<SeletorGarantiasProdutoController.GarantiaProdutoWrapper> garantiasWrappers = new List<SeletorGarantiasProdutoController.GarantiaProdutoWrapper>();

        for(GarantiaProduto__c g: garantiasProduto){
            SeletorGarantiasProdutoController.GarantiaProdutoWrapper myGarantia = new SeletorGarantiasProdutoController.GarantiaProdutoWrapper();
            myGarantia.id = g.Id;
            myGarantia.Name = g.Name;
            myGarantia.RecordTypeId = g.RecordTypeId;
            myGarantia.RecordTypeName = g.RecordType.Name;
            myGarantia.GarantiaId = g.Garantia__c;
            myGarantia.GarantiaName = g.Garantia__r.Name;
            myGarantia.GarantiaProdutoId = g.GarantiaProduto__c;
            myGarantia.RamoSeguroId = g.RamoSeguro__c;
            myGarantia.RamoSeguroName = g.RamoSeguro__r.Name;
            myGarantia.FormaPagamento = g.FormaPagamento__c;
            myGarantia.TipoGarantia = g.TipoGarantia__c;
            String moeda = getPickListLabelIntoList2(g.CurrencyIsoCode);
            system.debug('moeda: '+ moeda);
            myGarantia.CurrencyIsoCode = moeda;
            garantiasWrappers.add(myGarantia);
        }

        System.debug('::: garantiasProduto: ' + garantiasProduto);

        return garantiasWrappers;
        //PLV_3046 - FIM - Cadastro de Limite de garantia do produto - Viagem
    }
    //PLV_3046 - INICIO - Cadastro de Limite de garantia do produto - Viagem
	@AuraEnabled
	public static String salvarGarantiasSelecionadas(String idsGarantiasSelecionadas, Id produtoComercialId, Id produtoTecnicoId, String moeda, String demonstracaoPremio) {   //PLV_3450
        Savepoint sp = Database.setSavepoint();

        try {
            System.debug('::: produtoTecnicoId: ' + produtoTecnicoId);
            System.debug('::: produtoComercialId: ' + produtoComercialId);
            System.debug('::: demonstracaoPremio: ' + demonstracaoPremio);
            //PLV_3046 - Inicio
            String moedaValue = moeda;
            // String moedaValue = getPickListValuesIntoList(moeda);
            // //PLV_3046 - Fim
            ProductBO.getInstance().clonarTodaEstruturaGarantiasSelecionadasProduto(idsGarantiasSelecionadas, produtoTecnicoId, produtoComercialId, true, moedaValue, demonstracaoPremio);   //PLV_3450 //PLV-4106

            return 'SUCCESS';
        }
        //PLV-3160 INÍCIO
        catch (DmlException e) {

           List<String> lMessage = new List<String>();

           for (Integer i = 0; i < e.getNumDml(); i++){
               List<String> lFields = e.getDmlFieldNames(i);
               String msg = e.getDmlMessage(i)+ (lFields.isEmpty() ? '' : ' Campo(s) ['+String.join(e.getDmlFieldNames(i), ', ')+']');
               lMessage.add(msg);
           }

           return String.join(lMessage, '\n');

        }
        //PLV-3160 FIM
        catch(Exception e) {
            System.debug('######## ERRO: ' + e.getLineNumber() + ', ' + e.getMessage());
            Database.rollback(sp);
            return 'ERROR';
        }
	}

    @AuraEnabled
    public static String removerGarantiasSelecionadas(List<id> idsGarantiasSelecionadas, Id produtoComercialId, Id produtoTecnicoId) {
        Savepoint sp = Database.setSavepoint();

        try {
            System.debug('::: produtoTecnicoId: ' + produtoTecnicoId);
            System.debug('::: produtoComercialId: ' + produtoComercialId);

            ProductBO.getInstance().removerTodaEstruturaGarantiasSelecionadasProduto(idsGarantiasSelecionadas, produtoTecnicoId, produtoComercialId, false);

            return 'SUCCESS';
        }
        catch(Exception e) {
            System.debug('######## ERRO: ' + e.getLineNumber() + ', ' + e.getMessage());
            Database.rollback(sp);
            return 'ERROR';
        }
    }

    @AuraEnabled
	public static List<String> getPickListLabelIntoList(){
		List<String> CurrencyList = new List<String>();
		List<Schema.PicklistEntry> valuesMoeda = LimiteGarantiaProduto__c.CurrencyIsoCode.getDescribe().getPicklistValues();
		for(Schema.PicklistEntry v : valuesMoeda ) {
			CurrencyList.add(v.getLabel());
            System.debug('moeda: '+v.getLabel());
		}
		return CurrencyList;
	}

    @AuraEnabled
	public static String getPickListValuesIntoList(String value){
        System.debug('value an: '+ value);
		String CurrencyList = '';
        System.debug('label: ' + value);
		List<Schema.PicklistEntry> valuesMoeda = LimiteGarantiaProduto__c.CurrencyIsoCode.getDescribe().getPicklistValues();
		for(Schema.PicklistEntry v : valuesMoeda ) {
            if(v.getLabel() == value){
                CurrencyList = v.getValue();
                break;
            }
		}
        System.debug('CurrencyList: '+ CurrencyList);
		return CurrencyList;
	}
    @AuraEnabled
	public static String getPickListLabelIntoList2(String Label){
        System.debug('value an: '+ Label);
		String CurrencyList = '';
        System.debug('label: ' + Label);
		List<Schema.PicklistEntry> valuesMoeda = LimiteGarantiaProduto__c.CurrencyIsoCode.getDescribe().getPicklistValues();
		for(Schema.PicklistEntry v : valuesMoeda ) {
            if(v.getValue() == Label){
                CurrencyList = v.getLabel();
                break;
            }
		}
        System.debug('CurrencyList: '+ CurrencyList);
		return CurrencyList;
	}

}