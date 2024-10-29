/*
 *******************************************************************************************************************************************************************
 * Classe criada para pesquisar dados atrelados a garantia do segurado do contrato
 * autor: Diego Zampieri - Avanxo
 * Data de criação: 27/02/2018
 ******************************************************************************************************************************************************************* 
*/

public virtual class GarantiaSeguradoContratoDAO {

    private static final GarantiaSeguradoContratoDAO instancia = new GarantiaSeguradoContratoDAO();
    
    private GarantiaSeguradoContratoDAO(){ }
    
    public static GarantiaSeguradoContratoDAO getInstance(){
        return instancia;
    }
    
    public Map<Id, SeguradoContrato__c> buscarSeguradoeContrato(Set<Id> sIdSeg){
        Map<Id, SeguradoContrato__c> mapSegCont = new Map<Id, SeguradoContrato__c>();
        
        for(SeguradoContrato__c vSegCon : [SELECT Id, 
                                           GrupoContrato__r.ContratanteContrato__r.Contrato__c, 
                                           GrupoContrato__r.ContratanteContrato__r.Contrato__r.Name, 
                                           Conta__c,
                                           Conta__r.RecordTypeId,
                                           Conta__r.Cpf__c,
                                           Conta__r.Cnpj__c
                                           FROM SeguradoContrato__c
                                           WHERE Id IN :sIdSeg]){
             
                mapSegCont.put(vSegCon.Id, vSegCon);                               
        }
        
        return mapSegCont;
    }
    
    public Map<Id, Garantia__c> buscarDadosGarantia (Set<Id> sIdGarantia){
        Map<Id, Garantia__c> mapGarantia = new Map<Id, Garantia__c>();
        
        for(Garantia__c vGarantia : [SELECT Id, Name 
                                     FROM Garantia__c 
                                     WHERE Id IN :sIdGarantia]){
            
            mapGarantia.put(vGarantia.Id, vGarantia);
        }
        
        return mapGarantia;
    }

    //PLV-5147 - FIX02 - INICIO
    public List<GarantiaSeguradoContrato__c> buscarGarantiaSeguradoContrado(Set<Id> sidContrato) {

         return [SELECT 
                    Id, 
                    SeguradoContrato__c, 
                    PremioComercial__c, 
                    PremioPuro__c, 
                    PremioTotal__c,
                    TaxaComercial__c, 
                    TaxaPura__c, 
                    TaxaTotal__c, 
                    Garantia__r.Sigla__c,
                    DescontoAgravoMonetarioFormaPagto__c,
                    DescontoAgravoPercentualFormaPagto__c,
                    Capital__c, //PLV-4695-FIX3-INICIO/FIM
                    TipoDescontoAgravo__c,
                    IOF__c //PLV-4961 - INÍCIO/FIM
                    FROM GarantiaSeguradoContrato__c 
                    WHERE 
                        SeguradoContrato__r.GrupoContrato__r.ContratanteContrato__r.Contrato__c IN :sidContrato];

    }

    public List<GarantiaSeguradoContrato__c> buscarGarantiaSeguradoContradoeEndosso(String empresa, String sucursal, String ramo, String apolice) {
 
        String contratoNameLike = empresa + '-' + sucursal + '-' + ramo + '-' + apolice + '-%';
        List<GarantiaSeguradoContrato__c> results = [
                SELECT 
                    Garantia__r.Sigla__c, 
                    SeguradoContrato__c, 
                    Capital__c,
                    PremioComercial__c, 
                    PremioPuro__c, 
                    PremioIntegral__c, //PLV-5384 INICIO/FIM
                    PremioTotal__c, //PLV-5384 INICIO/FIM
                    TaxaComercial__c, 
                    TaxaPura__c, 
                    TaxaTotal__c,
                    DescontoAgravoMonetarioFormaPagto__c,
                    DescontoAgravoPercentualFormaPagto__c,
                    TipoDescontoAgravo__c,
                    IOF__c //PLV-4961 - INÍCIO/FIM
                FROM GarantiaSeguradoContrato__c         
                WHERE 
                    SeguradoContrato__r.GrupoContrato__r.ContratanteContrato__r.Contrato__r.Name  like :contratoNameLike
            ];
        /*AggregateResult[] results = [
                SELECT 
                    Garantia__r.Sigla__c Sigla, 
                    MAX(SeguradoContrato__c) SeguradoContrato, 
                    MAX(Capital__c) Capital,
                    SUM(PremioComercial__c) PremioComercial, 
                    SUM(PremioPuro__c) PremioPuro, 
                    PremioIntegral__c PremioIntegral, //PLV-5384 INICIO/FIM
                    PremioTotal__c PremioTotal, //PLV-5384 INICIO/FIM
                    SUM(TaxaComercial__c) TaxaComercial, 
                    SUM(TaxaPura__c) TaxaPura, 
                    SUM(TaxaTotal__c) TaxaTotal,
                    AVG(DescontoAgravoMonetarioFormaPagto__c) DescontoAgravoMonetarioFormaPagto,
                    AVG(DescontoAgravoPercentualFormaPagto__c) DescontoAgravoPercentualFormaPagto,
                    SUM(IOF__c) Iof //PLV-4961 - INÍCIO/FIM
                FROM GarantiaSeguradoContrato__c         
                WHERE 
                    SeguradoContrato__r.GrupoContrato__r.ContratanteContrato__r.Contrato__r.Name like :contratoNameLike
                GROUP BY Garantia__r.Sigla__c
            ];
            

        List<GarantiaSeguradoContrato__c> lstGaranSeguradoCon = new List<GarantiaSeguradoContrato__c>();
        for (AggregateResult ar : results) {
            GarantiaSeguradoContrato__c gseg = new GarantiaSeguradoContrato__c();
            Garantia__c gar = new Garantia__c();
            gar.Sigla__c = String.valueOf(ar.get('Sigla'));
            gseg.Garantia__r = gar;
            gseg.SeguradoContrato__c = String.valueOf(ar.get('SeguradoContrato'));
            gseg.Capital__c = (Decimal)ar.get('Capital');
            gseg.PremioComercial__c = (Decimal)ar.get('PremioComercial');
            gseg.PremioPuro__c = (Decimal)ar.get('PremioPuro');
            gseg.PremioTotal__c = (Decimal)ar.get('PremioTotal');
            gseg.TaxaComercial__c = (Decimal)ar.get('TaxaComercial');
            gseg.TaxaPura__c = (Decimal)ar.get('TaxaPura');
            gseg.TaxaTotal__c = (Decimal)ar.get('TaxaTotal');
            gseg.DescontoAgravoMonetarioFormaPagto__c = (Decimal)ar.get('DescontoAgravoMonetarioFormaPagto');
            gseg.DescontoAgravoPercentualFormaPagto__c = (Decimal)ar.get('DescontoAgravoPercentualFormaPagto');
            gseg.IOF__c = (Decimal)ar.get('Iof'); //PLV-4961 - INÍCIO/FIM
            
            lstGaranSeguradoCon.add(gseg);
        }
        */

        //return lstGaranSeguradoCon;
        return results;

    }

    //PLV-5147 - FIX02 - FIM
    //PLV-5747 INICIO
    // POR062-1 - INICIO
    public List<GarantiaSeguradoContrato__c> buscarPorIdDeContratoECobertura(Set<Id> idsContratos, Set<String> siglasGarantia) {
        List<GarantiaSeguradoContrato__c> garantiaSeguradoLista = [
            SELECT Id, Garantia__r.Name, Garantia__r.Sigla__c, Garantia__r.Descricao__c
			FROM GarantiaSeguradoContrato__c
			WHERE
                SeguradoContrato__R.GrupoContrato__r.ContratanteContrato__r.Contrato__c IN :idsContratos AND
                Garantia__r.Sigla__c IN :siglasGarantia
        ];
        return garantiaSeguradoLista;
    }
    // POR062-1 - FIM
    //PLV-5747 FIM
}