public virtual class SeguradoContratoBO {

    public SeguradoContratoBO(){ }
    
    private static final SeguradoContratoBO instancia = new SeguradoContratoBO();
    private SeguradoContratoDAO dao = SeguradoContratoDAO.getInstance();
    
    public static SeguradoContratoBO getInstance(){
        return instancia;
    }
    
    public void preencherNomenclaturaSegurado(List<SeguradoContrato__c> lstSeg){
        
        Recordtype REC_ID_PFISICA = RecordTypeBO.buscarTipoRegistro('Account', 'PessoaFisica');
        Recordtype REC_ID_PJURIDICA = RecordTypeBO.buscarTipoRegistro('Account', 'PessoaJuridica');
        Set<Id> setConta = new Set<Id>();
        Map<Id, SeguradoContrato__c> mapSegCont = new Map<Id, SeguradoContrato__c>();
        
        for(SeguradoContrato__c vSeg : lstSeg){
            if(vSeg.Conta__c != null){
                setConta.add(vSeg.Conta__c);
                mapSegCont.put(vSeg.Id, vSeg.clone(true));
            }
        }
        
        if(mapSegCont.isEmpty()) return;
        
        Map<Id,Account> mapAccSeg = dao.buscaDadosContaSeg(setConta);
        
        if(mapAccSeg.isEmpty()) return;
        
        Map<Id,SeguradoContrato__c> mapSegContUp = new Map<Id,SeguradoContrato__c>();
        
        for(SeguradoContrato__c vSegCon : mapSegCont.values()){
            Account acc = mapAccSeg.get(vSegCon.Conta__c);
            
            if(acc.RecordTypeId == REC_ID_PFISICA.Id && acc.Cpf__c != null){
                String vCPF = acc.Cpf__c.replace('.','');
                vCPF = vCPF.replace('-', '');
                vSegCon.Nomenclatura_Pesquisa_Segurado_Contrato__c = acc.Name + '-' + vCPF;
                mapSegContUp.put(vSegCon.Id, vSegCon);
            } else if(acc.RecordTypeId == REC_ID_PJURIDICA.Id && acc.Cnpj__c != null){
                String vCNPJ = acc.Cnpj__c.replace('.','');
                vCNPJ = vCNPJ.replace('/', '');
                vCNPJ = vCNPJ.replace('-', '');
                vSegCon.Nomenclatura_Pesquisa_Segurado_Contrato__c = acc.Name + '-' + vCNPJ;
                mapSegContUp.put(vSegCon.Id, vSegCon);
            }
        }
        
        update mapSegContUp.values();
    }
}