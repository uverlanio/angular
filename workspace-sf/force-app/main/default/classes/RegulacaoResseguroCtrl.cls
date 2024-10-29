/*******************************************************************************************************************************
* @author: Guilherme/Leonardo
* @date 26/11/2020
* Classe criada por conta da história PLV-4523 - Vida Individual
* Description: Classe controller para o Modelo de email baseado em Visualforce: Regulação Resseguro
******************************************************************************************************************************/
public class RegulacaoResseguroCtrl {
    
    public String mCriticaId {get;set;} 
    public String dataInicio {get;set;}
    public String dataEvento {get;set;} 
    public CriticaSinistro__c mCritica  {get;set;}
    public List<CausaSinistro__c> causas {get;set;}
    
    public String getInit() {
        setCritica();
        
        if (mCritica != null) {
            setCausas();

            dataInicio = formatDate(mCritica.Sinistro__r.Contrato__r.StartDate);
            dataEvento = formatDate(mCritica.Sinistro__r.Dataocorrencia__c); 
        }

        return '';
    }

    private void setCritica() {
        
        List<CriticaSInistro__c> lista = [
            SELECT Id   
                ,Sinistro__c
                ,Sinistro__r.segurado_do_contrato__r.conta__r.name //PLV-4523 - FIX 2 - INICIO/FIM
                ,Sinistro__r.Account.Cpf__c
                ,Sinistro__r.NumeroSinistro__c
                ,Sinistro__r.Contrato__r.Produto__r.Segmento__c
                ,GarantiaSinistro__r.Garantia_do_segurado_do_contrato__r.Garantia__r.Sigla__c
                ,GarantiaSinistro__r.Garantia_do_segurado_do_contrato__r.Garantia__r.Name
                ,Sinistro__r.Contrato__r.StartDate
                ,Sinistro__r.Dataocorrencia__c
                ,Sinistro__r.Valor_Indenizado__c
            FROM CriticaSinistro__c
            WHERE Id =: mCriticaId
        ];

        if (lista.size() > 0) {
            mCritica = lista.get(0);
        }
    }

    private void setCausas() {
        causas = [
            SELECT Id
                ,Causa__r.Name
                ,Causa__r.Codigo__c
            FROM CausaSinistro__c
            WHERE Caso__c =: mCritica.Sinistro__c
        ];
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