/*******************************************************************************************************************************
* @author: Guilherme/Leonardo
* @date 26/11/2020
* Classe criada por conta da história PLV-4523 - Vida Induvidual
* Description: Classe controller para o Modelo de email baseado em Visualforce: Prevenção Fraude
******************************************************************************************************************************/
public class PrevencaoFraudeController {
    
    public String mCriticaId {get;set;} 
    public String dataOcorrencia {get;set;}
    public String dataAviso {get;set;} 
    public CriticaSinistro__c mCritica  {get;set;}
    
    public String getInit() {
        setCritica();

        if(mCritica != null){
            this.dataOcorrencia = formatDate(mCritica.sinistro__r.Dataocorrencia__c);
            this.dataAviso = formatDate(mCritica.sinistro__r.Data_Aviso_Cliente__c);
        }

        return '';
    }


    private void setCritica(){

        List<CriticaSinistro__c> listaCriticas = [
            SELECT 
            sinistro__r.NumeroSinistro__c,
            sinistro__r.Data_Aviso_Cliente__c,
            sinistro__r.Dataocorrencia__c,
            sinistro__r.segurado_do_contrato__r.conta__r.name, //PLV-4523 - FIX 2 - INICIO/FIM
            sinistro__r.Codigo_Corretor__c,
            sinistro__r.Nome_do_Corretor__c,
            sinistro__r.Contrato__r.name, //PLV-4523 - FIX 2 - INICIO/FIM
            GarantiaSinistro__r.Garantia_do_segurado_do_contrato__r.Garantia__r.Sigla__c,
            GarantiaSinistro__r.Garantia_do_segurado_do_contrato__r.Garantia__r.Name, //PLV-4523 - FIX 3 - INICIO/FIM
            GarantiaSinistro__r.ValorIndenizado__c
            FROM CriticaSinistro__c
            WHERE Id = :this.mCriticaId
        ];

        if(!listaCriticas.isEmpty()) this.mCritica = listaCriticas[0];
    }
    
    private String formatDate( Date value ) {
        String result = '';
        
        if (value != null){
            String sMonth = String.valueof( value.month() );
            String sDay = String.valueof( value.day() );
            
            if( sMonth.length() == 1 ) {
                sMonth = '0' + sMonth;
            }
            
            if ( sDay.length() == 1 ) {
                sDay = '0' + sDay;
            }
        
            result = sDay + '/' + sMonth + '/' + String.valueof(value.year());
        }
        return result;
    }
}