/*
 *******************************************************************************************************************************************************************
 * Classe criada para preencher a nomenclatura no objeto Garantia do Segurado do Contrato após a criação do registro
 * autor: Diego Zampieri - Avanxo
 * Data de criação: 27/02/2018
 ******************************************************************************************************************************************************************* 
*/

public virtual class GarantiaSeguradoContratoBO {
    
    public GarantiaSeguradoContratoBO(){ }
    
    private static final GarantiaSeguradoContratoBO instancia = new GarantiaSeguradoContratoBO();
    private GarantiaSeguradoContratoDAO dao = GarantiaSeguradoContratoDAO.getInstance();
    
    public static GarantiaSeguradoContratoBO getInstance(){
        return instancia;
    }

    public void preencherNomenclatura(List<GarantiaSeguradoContrato__c> lstGaranSegCon){
        
        Recordtype REC_ID_ACC = RecordTypeBO.buscarTipoRegistro('Account', 'PessoaFisica');
        Recordtype REC_ID_ACCJURI = RecordTypeBO.buscarTipoRegistro('Account', 'PessoaJuridica');
        Set<Id> setSegurado = new Set<Id>();
        Set<Id> setGarantia = new Set<Id>();
        Map<Id,GarantiaSeguradoContrato__c> mapGaranSegCon = new Map<Id, GarantiaSeguradoContrato__c>();
        for(GarantiaSeguradoContrato__c vGSC : lstGaranSegCon){
            if(vGSC.SeguradoContrato__c != null && vGSC.Garantia__c != null){
                setSegurado.add(vGSC.SeguradoContrato__c);
                setGarantia.add(vGSC.Garantia__c);
                mapGaranSegCon.put(vGSC.SeguradoContrato__c, vGSC.clone(true));
            }
        }
        
        if(mapGaranSegCon.isEmpty()) return;
        
        Map<Id, SeguradoContrato__c> mapSegContrato = dao.buscarSeguradoeContrato(setSegurado);
        Map<Id, Garantia__c> mapGaran = dao.buscarDadosGarantia(setGarantia);
        
        if(mapSegContrato.isEmpty()) return;
        if(mapGaran.isEmpty()) return;
        
        Map<Id,GarantiaSeguradoContrato__c> mapGaranSegConUp = new Map<Id,GarantiaSeguradoContrato__c>();
        
        for(GarantiaSeguradoContrato__c vGaSeCon : mapGaranSegCon.values()){
            SeguradoContrato__c vSeg = mapSegContrato.get(vGaSeCon.SeguradoContrato__c);
            Garantia__c vGa = mapGaran.get(vGaSeCon.Garantia__c);
            
            if(vSeg.Conta__c != null){
                if(vSeg.Conta__r.RecordTypeId == REC_ID_ACC.Id && vSeg.Conta__r.Cpf__c != null){
                    
                    String s1 = vSeg.Conta__r.Cpf__c.replace('.','');
                    s1 = s1.replace('-', '');
                    vGaSeCon.Nomenclatura_Pesquisa_Garantia_Segurado__c = s1 + '-' + vSeg.GrupoContrato__r.ContratanteContrato__r.Contrato__r.Name + '-' + vGa.Name;
                    mapGaranSegConUp.put(vGaSeCon.Id, vGaSeCon);
                    
                } else if(vSeg.Conta__r.RecordTypeId == REC_ID_ACCJURI.Id && vSeg.Conta__r.Cnpj__c != null){
                    String vCNPJ = vSeg.Conta__r.Cnpj__c.replace('.','');
                    vCNPJ = vCNPJ.replace('/', '');
                    vCNPJ = vCNPJ.replace('-', '');
                    vGaSeCon.Nomenclatura_Pesquisa_Garantia_Segurado__c = vCNPJ + '-' + vSeg.GrupoContrato__r.ContratanteContrato__r.Contrato__r.Name + '-' + vGa.Name;
                    mapGaranSegConUp.put(vGaSeCon.Id, vGaSeCon);
                }
                
            }
            
            //update mapGaranSegConUp.values(); //II-21 INCIO-FIM
        }
        update mapGaranSegConUp.values(); //II-21 INCIO-FIM
    }
    //PLV-4830 INICIO
    public void preencherLimiteUtilizacao(List<GarantiaSeguradoContrato__c> lstGaranSegCon){
        try {
            System.debug('Estou na trigger GarantiaSeguradoContrato!');
            Set<Id> SetGarantiaSegCon = new Set<Id>();
            for (GarantiaSeguradoContrato__c garantiaSegCon: lstGaranSegCon){
                SetGarantiaSegCon.add(garantiaSegCon.Id);
            }
            List<GarantiaSeguradoContrato__c> GarantiasSegContrato = [SELECT Id,ValorDias__c, Garantia__r.Name, Tipo_de_limite_de_utilizacao__c,Limite_de_Uso__c, Capital__c, GarantiaProduto__c, GarantiaProduto__r.TipoPagamento__c FROM GarantiaSeguradoContrato__c WHERE Id IN :SetGarantiaSegCon];
            System.debug('GarantiaSegContrato: ' + GarantiasSegContrato);
            for (GarantiaSeguradoContrato__c GaranSegContrato: GarantiasSegContrato){ 
                System.debug('GaranSegContrato.GarantiaProduto__c: ' + GaranSegContrato.GarantiaProduto__c);            
                System.debug('GaranSegContrato.GarantiaProduto__r.TipoPagamento__c: ' + GaranSegContrato.GarantiaProduto__r.TipoPagamento__c);            
                if (GaranSegContrato.GarantiaProduto__r.TipoPagamento__c.contains('Diária')) {
                    GaranSegContrato.Tipo_de_limite_de_utilizacao__c = 'Dias';
                    GaranSegContrato.Limite_de_Uso__c = GaranSegContrato.ValorDias__c;
                }else{
                    GaranSegContrato.Tipo_de_limite_de_utilizacao__c = 'Monetário';
                    GaranSegContrato.Limite_de_Uso__c = GaranSegContrato.Capital__c;
                }
            }
            update GarantiasSegContrato;
        } catch(Exception e) {
            System.debug('Linha: '+e.getLineNumber()+'   ===>>>    Mensagem:'+ e.getMessage());
        }
    }
    //PLV-4830 FIM
}