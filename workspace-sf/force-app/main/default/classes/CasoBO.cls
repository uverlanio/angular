/**************************************************************************************************************************************************************************
*
*  Classe responsável pelo negócio do objeto Caso 
*
**************************************************************************************************************************************************************************/
public virtual class CasoBO
{ 
    
    public CasoBO() { } 
    
    private static final CasoBO instancia = new CasoBO();
    private static HerokuService herokuServ = HerokuService.getInstance();
    private static CIVServices civServ = CIVServices.getInstance();
    
    //PLV-4516 INICIO
    private RecordType sinistroRecordType;
    //PLV-4516 FIM
    
    //PLV-4560 - Inicio
    private static final RecordType RECORDTYPE_CASE_SINISTRO = RecordTypeBO.buscarTipoRegistro('Case', 'Sinistro');
    private static final string STATUS_ANALISE = 'Em Análise';
    private static final string TIPO_BENEFICIARIO_HENDEIRO = 'Herdeiros legais';
    private static final string TIPO_BENEFICIARIO_SEGURADO_HENDEIRO = 'Herdeiros legais, conforme artigo 792 do código civil.';// PLV-4524-FIX INICIO/FIM
    private static final string TIPO_BENEFICIARIO_SEGURADO = 'O próprio segurado';
    private static final string STATUS_PENDENTE = 'Pendente';
    //PLV-4560 - Fim

    //PLV-4707 - Inicio
    private static final string STATUS_CASE_AVISADO             = 'Avisado';
    private static final string STATUS_CASE_FECHADO             = 'Fechado';
    private static final string STATUS_DEPENDENTE_CASE_RECUSADO = 'Recusado';
    private static final string ENDOSSO_CONTRACT_SIN            = 'SIN';
    private static final string MOTIVO_RECUSA_CASE_FRAUDE       = '4';
    //PLV-4707 - Fim
    
    private CasoDAO dao = CasoDAO.getInstance();
    public static CasoBO getInstance(){
        return instancia;
    }
    
    //Método alterado para a história PLV-1722
    public void preencheContratonoCaso(List<Case> casos, Map<Id,Case> mCasosOld) 
    {

        Recordtype REC_ID_SINISTRO = RecordTypeBO.buscarTipoRegistro('Case', 'Sinistro');
        List<Case> LstCasos = new List<Case>();
        List<Case> LstCasos2Update = new List<Case>();
        
        Set<Id> sGarantia = new Set<Id>();
        
        
        for (Case caso : casos){
            Case caseOld = mCasosOld.get(caso.Id);
            //PLV-3870 - INICIO
            /*
if(caso.Garantia_do_segurado_do_contrato__c == null &&
caseOld.Garantia_do_segurado_do_contrato__c != null && caso.RecordTypeId == REC_ID_SINISTRO.Id && caso.Caso_Filho_Criado_Automaticamente__c == false){
caso.Garantia__c = null;
caso.Contrato__c = null;
caso.Segurado_do_contrato__c = null;
}
else 
*/
            //PLV-3870 - FIM
            if(((caso.Garantia_do_segurado_do_contrato__c != null &&
                 caseOld.Garantia_do_segurado_do_contrato__c == null) ||
                (caso.Garantia_do_segurado_do_contrato__c != caseOld.Garantia_do_segurado_do_contrato__c)) && caso.Caso_Filho_Criado_Automaticamente__c == false){
                    sGarantia.add(caso.Garantia_do_segurado_do_contrato__c);
                }
        }
        
        if (sGarantia.isEmpty()) return;
        
        Map<Id, GarantiaSeguradoContrato__c> mSeguradoContrato = dao.buscarcontratos(sGarantia);
        
        for (Case caso : casos) {
            
            if (caso.Garantia_do_segurado_do_contrato__c == null) continue;
            
            GarantiaSeguradoContrato__c vGarantia = mSeguradoContrato.get(caso.Garantia_do_segurado_do_contrato__c);
            if(vGarantia == null) continue;
            
            caso.Contrato__c = vGarantia.SeguradoContrato__r.GrupoContrato__r.ContratanteContrato__r.Contrato__c;
            caso.Garantia__c = vGarantia.Garantia__c;
            caso.Segurado_do_contrato__c = vGarantia.SeguradoContrato__c;
        }
    }
    
    /*public void listaBeneficiarios(List<Case> casos){
for (Case caso : casos) {
if (caso.Status_Dependente__c != 'Em análise'){
continue;
}
}  
}*/
    
    public void preencherDataLimite(List<Case> casos, Map<Id,Case> mCasosOld){
        
        System.debug('XXX - CASOS: ' + JSON.serialize(casos));
        System.debug('XXX - mCasosOld: ' + JSON.serialize(mCasosOld));

        Recordtype REC_ID_SINISTRO = RecordTypeBO.buscarTipoRegistro('Case', 'Sinistro');
        
        List<Case> lstCase = new List<Case>();
        Set<Id> setIdGaran = new Set<Id>();
        Set<Id> setIdContrato = new Set<Id>();
        for(Case c : casos){
            Case casoOld = Trigger.isInsert ? null : mCasosOld.get(c.Id);
            if(c.RecordTypeId == REC_ID_SINISTRO.Id && 
               c.Contrato__c != null && 
               c.Garantia__c != null && 
               (Trigger.isInsert || (Trigger.isUpdate && c.Contrato__c != casoOld.Contrato__c 
                                     || c.Garantia__c != casoOld.Garantia__c))){
                                        
                                         lstCase.add(c);
                                         setIdGaran.add(c.Garantia__c);
                                         setIdContrato.add(c.Contrato__c);
                                     }
            //PLV-3870 - INICIO
            if(/*c.Garantia__c == null &&*/c.Contrato__c == null){
                c.Data_limite_aviso_sinistro__c = null;
            }
            //PLV-3870 - FIM
        }
        
        if(lstCase.isEmpty()) return;
        
        Map<Id,Contract> mapContract = new Map<Id,Contract>(
            [SELECT Id, Produto__c FROM Contract WHERE Produto__c != null AND Id IN :setIdContrato]
        );
        
        Map<Id,Map<Id,GarantiaProduto__c>> mapGarantia = new Map<Id,Map<Id,GarantiaProduto__c>>(); 
        
        for(GarantiaProduto__c vGaranProd : [SELECT Id, Produto__c, Garantia__c, PrazoAvisoSinistro__c, TipoPrazoAvisoSinistro__c 
                                             FROM GarantiaProduto__c WHERE Produto__c != null AND Garantia__c IN :setIdGaran]){
                                                 if(vGaranProd == null) break;
                                                 Map<Id,GarantiaProduto__c> mapGaranProdutos;
                                                 if(mapGarantia.containsKey(vGaranProd.Garantia__c)){
                                                     mapGaranProdutos = mapGarantia.get(vGaranProd.Garantia__c);
                                                 } else {
                                                     mapGaranProdutos = new Map<Id,GarantiaProduto__c>();
                                                 }
                                                 
                                                 mapGaranProdutos.put(vGaranProd.Produto__c,vGaranProd);
                                                 mapGarantia.put(vGaranProd.Garantia__c,mapGaranProdutos);
                                             }
        
        for(Case c : lstCase){
            if(mapGarantia.isEmpty()) break;
            Contract vContract = mapContract.get(c.Contrato__c);
            Map<Id,GarantiaProduto__c> mapGaranProdutos = mapGarantia.get(c.Garantia__c);
            
            if(mapGaranProdutos.containsKey(vContract.Produto__c)){
                GarantiaProduto__c vGPro = mapGaranProdutos.get(vContract.Produto__c);
                
                if(vGPro.TipoPrazoAvisoSinistro__c == 'Ano' && vGPro.PrazoAvisoSinistro__c != null){
                    c.Data_limite_aviso_sinistro__c = c.Dataocorrencia__c.addYears(vGPro.PrazoAvisoSinistro__c.intValue());
                } else if(vGPro.TipoPrazoAvisoSinistro__c == 'Mês' && vGPro.PrazoAvisoSinistro__c != null){
                    c.Data_limite_aviso_sinistro__c = c.Dataocorrencia__c.addMonths(vGPro.PrazoAvisoSinistro__c.intValue());
                } else if(vGPro.TipoPrazoAvisoSinistro__c == 'Dia' && vGPro.PrazoAvisoSinistro__c != null){
                    c.Data_limite_aviso_sinistro__c = c.Dataocorrencia__c.addDays(vGPro.PrazoAvisoSinistro__c.intValue());
                }
            }
            
        }
        
        
    }
    
    //AVX SP24 - PLV - 1893 - Controle de duplicidade
    public void validaDuplicidade(List<Case> casos, Map<Id,Case> mCasosOld){
        Recordtype REC_ID_ATENDIMENTO = RecordTypeBO.buscarTipoRegistro('Case', 'Atendimento');
        Map<Id,Case> mapCase = new Map<Id,Case>();
        // store the composite keys
        Set<String> sCompositeKeys = new Set<String>();
        
        for(Case caso : casos){
            
            if(caso.AccountId != null && 
               caso.RecordTypeId == REC_ID_ATENDIMENTO.Id && 
               caso.Dataocorrencia__c != null && 
               caso.Vitima__c != null)
            {
                mapCase.put(caso.AccountId, caso);
                
                String key = caso.AccountId +'|'+ caso.RecordTypeId +'|'+ caso.Dataocorrencia__c +'|'+ caso.Vitima__c;
                if (sCompositeKeys.contains(key)) caso.addError('Este caso não pode ser inserido porque esta em duplicidade na própria carga!');
                else sCompositeKeys.add(key);
                
            }
        }
        
        if(mapCase.isEmpty()) return;
        
        Map<Id,Case> mapCasosDuplic = dao.buscarCasosDaConta(mapCase.keySet());
        
        if(mapCasosDuplic.isEmpty()) return;
        
        for(Case c : mapCasosDuplic.values()){
            
            if(Trigger.isUpdate){
                if(mCasosOld.containsKey(c.Id)) continue;
            }
            
            Case c1 = mapCase.get(c.AccountId);
            if(c1.Dataocorrencia__c == c.Dataocorrencia__c && c1.Vitima__c == c.Vitima__c && c1.RecordTypeId == c.RecordTypeId){
                c1.addError('Este caso não pode ser finalizado pois já existe o caso de número ' + c.CaseNumber + ' com as informações fornecidas.');
            }
            
            
        }
    }
    
    public void PreencheCorretorCaso(List<Case> casos) 
    {
        Recordtype REC_ID_SINISTRO = RecordTypeBO.buscarTipoRegistro('Case', 'Sinistro');
        Recordtype REC_ID_BENEFICIO = RecordTypeBO.buscarTipoRegistro('Case', 'Beneficio');
        
        Set<Id> sContrato = new Set<Id>();
        List<Case> LstCaso = new List<Case>();
        
        for(Case caso : casos){ 
            
            //caso seja do tipo de registro sinistro então...
            if(caso.RecordTypeId == REC_ID_SINISTRO.Id || caso.RecordTypeId == REC_ID_BENEFICIO.Id){
                //PLV-3777 - INICIO
                LstCaso.add(caso); 
                
                //aqui muda para garantia do segurado do contrato
                sContrato.add(caso.Contrato__c);
                //PLV-3777 - FIM
            }
        }
        
        if (sContrato.isempty()) return;
        
        Map<Id, FavorecidoRemuneracaoContrato__c> mFavRemunCont = dao.buscarCorretores(sContrato);
        
        for(Case caso : LstCaso)
        {
            if (caso.Contrato__c == null || !mFavRemunCont.containsKey(caso.Contrato__c)) continue;
            
            FavorecidoRemuneracaoContrato__c vFavRemCont = mFavRemunCont.get(caso.Contrato__c);

            system.debug('Email corretor debug 0000: '+ vFavRemCont.DadosCorretor__r.NomeCorretor__r.PersonEmail);
            
            if(vFavRemCont.DadosCorretor__r.NomeCorretor__r.Email__c == null){
                caso.Email_do_Corretor__c = vFavRemCont.DadosCorretor__r.NomeCorretor__r.PersonEmail;
                caso.Codigo_Corretor__c = vFavRemCont.DadosCorretor__r.Name;
                caso.Nome_do_Corretor__c = vFavRemCont.DadosCorretor__r.NomeCorretor__r.Name;
            }else{
                
                caso.Email_do_Corretor__c = vFavRemCont.DadosCorretor__r.NomeCorretor__r.Email__c;
                caso.Codigo_Corretor__c = vFavRemCont.DadosCorretor__r.Name;
                caso.Nome_do_Corretor__c = vFavRemCont.DadosCorretor__r.NomeCorretor__r.Name;
            }
        }
    }

   // POR062-48 - INICIO
   public Decimal calcularCapitalCaso(List<MovimentoSinistro__c> movimentos, SinistroJuridicoBO.Request sinistro){

        Decimal totalDasGarantias = 0;
        Set<Id> idGarantias = new Set<Id>();
   
        for(MovimentoSinistro__c movimento : movimentos){
            if(movimento.SinistroJudicial__c == true && sinistro.movimento == MovimentoSinistroTO.AVISO_MAIS.valor){
                List<Garantia__c> garantias = GarantiaDAO.getInstance().buscarGarantiasPorSigla(new Set<String> { sinistro.cobertura });
                if(!garantias.isEmpty()){
                    for(Garantia__c garantia : garantias){
                        idGarantias.add(garantia.id);
                    }
                }
                AggregateResult[] ars = [SELECT SUM(Capital__c) totalCapital FROM GarantiaSeguradoContrato__c WHERE Garantia__c IN :idGarantias];               
                for(AggregateResult ar : ars){
                    totalDasGarantias = (Decimal)ar.get('totalCapital');
                }           
            }
        }

        return totalDasGarantias;
    }
    // POR062-48 - FIM
    
    /*public void validarCasoFilhoAutomatico(List<Case> plNewCase) {

Id REC_ID_PAI = RecordTypeBO.buscarTipoRegistro('Case', 'Atendimento').Id;
List<Case> lCasePai = new List<Case>();

for (Case c : plNewCase) {

if (c.RecordTypeId == REC_ID_PAI && c.Criar_caso_filho_automaticamente__c == true)
lCasePai.add(c);
}

if (lCasePai.isEmpty()) return;

Map<Id,Case> mCase = new Map<Id,Case>(
[SELECT Id, (SELECT Id FROM Cases WHERE Caso_Filho_Criado_Automaticamente__c = true)
FROM Case
WHERE Id IN :lCasePai]
);

for (Case c : plNewCase) {

if (!mCase.get(c.Id).Cases.isEmpty())c.addError('Caso já possui registros filhos gerados automaticamente!');
}
}*/
    
    
    //AVX - Metodo before que preenche origem e numero da proposta quando validacaoCapivida = Heroku
    /*public void validaProposta(List<Case> casos){
if(checkRecursive.runOnce()) 
{ 
if((casos[0].FlagNumeroSorte__c !=  true))
{    
String labelPortoCap = Label.Id_Cliente_CapiVida;
Map<Id,Case> mapCasePaiValProp = new Map<Id,Case>();
Map<Id,Case> mapCaseParent = new Map<Id,Case>();
List<Case> LstCase = new List<Case>();

for(Case c : casos)
{
mapCaseParent.put(c.ParentId, c);
}

if(mapCaseParent.isEmpty()) return;

List<Case> lstCaseParent = [SELECT Id, 
Type,
Garantia__c, 
Garantia__r.Name, 
Numero_Proposta__c,
Origem_Proposta__c 
FROM Case
WHERE Id IN :mapCaseParent.keySet()];

Account acc = [SELECT Id FROM Account WHERE Id = :labelPortoCap];

for(Case c1 : lstCaseParent){

Case c2 = mapCaseParent.get(c1.Id);

if(c1.Type == 'Benefício' && c1.Garantia__r.Name == 'Capitalização' && c1.Numero_Proposta__c != null && c1.Origem_Proposta__c !=null)
{
c2.Numero_Proposta__c = c1.Numero_Proposta__c;
c2.Origem_Proposta__c = c1.Origem_Proposta__c;
mapCasePaiValProp.put(c1.Garantia__c, c2);
}
}

if(mapCasePaiValProp.isEmpty()) return;

List<GarantiaSeguradoContrato__c> lsGaranSeg = [SELECT Id, Garantia__c, SeguradoContrato__r.Conta__c, 
SeguradoContrato__r.Vigencia_inicial__c, 
SeguradoContrato__r.VIgencia_final__c,
SeguradoContrato__r.GrupoContrato__r.ContratanteContrato__r.Contrato__c,
SeguradoContrato__r.GrupoContrato__r.ContratanteContrato__r.Contrato__r.Proposta__r.NumeroProposta__c
FROM GarantiaSeguradoContrato__c 
WHERE Garantia__c IN :mapCasePaiValProp.keySet()];

for(GarantiaSeguradoContrato__c garanSeg : lsGaranSeg)
{
Case c = mapCasePaiValProp.get(garanSeg.Garantia__c);

if(garanSeg.SeguradoContrato__r.GrupoContrato__r.ContratanteContrato__r.Contrato__r.Proposta__r.NumeroProposta__c == c.Numero_Proposta__c){
c.Validacao_CapiVida__c = 'SalesForce';
} else 
{
c.Validacao_CapiVida__c = 'Heroku';
c.AccountId = acc.Id;


for(Case caso : mapCasePaiValProp.values())
{

if(caso.Numero_Proposta__c != null && caso.Numero_Proposta__c != '' &&
caso.Origem_Proposta__c != null && caso.Origem_Proposta__c != '')
{

LstCase.add(caso);
}

}
}
casos[0].Origem_Proposta__c = LstCase[0].Origem_Proposta__c;
casos[0].Numero_Proposta__c = LstCase[0].Numero_Proposta__c;
}
}    
}
}



//AVX - Metodo after que chama o callout que recupera o numero da sorte 
public void recuperanumerosorte(List<Case> casos)
{
if(CasoTriggerHandler.isFirstTime)
{
CasoTriggerHandler.isFirstTime = false;

for(Case cs : casos)
{
if((cs.FlagNumeroSorte__c !=  true)&&(cs.Validacao_CapiVida__c =='Heroku'))
{
ChamaNumerodaSorte(cs.Origem_Proposta__c, cs.Numero_Proposta__c, cs.Id);

}
}
}
}

//AVX - Metodo que busca no heroku o numero da sorte
@future(callout=true)
public static void ChamaNumerodaSorte(String origem, String numero, String casoid) 
{
Http h = new Http(); 
String json = '{"numeroproposta": "'+numero+'","origemproposta": "'+origem+'"}';

CredencialOAuth2__mdt  credencial = MetadataDAO.getInstance().buscarCredencial('VidaCloudApi');
Servico__mdt servico = MetadataDAO.getInstance().buscarServico('Recupera_Numero_Sorte');
String Token = CIVServices.getInstance().gerarTokenOAuth2('CIV');

HttpRequest req = new HttpRequest();
req.setBody(json);
req.setHeader('Content-Type', 'application/json');
req.setHeader('Authorization', Token);
req.setEndpoint(credencial.Audience__c + '/api/' + servico.Endpoint__c); 
req.setMethod('POST');

HttpResponse res = h.send(req);  

List<Case> LstCaso = new List<Case>();
if (res.getStatusCode() == 200) 
{   
List<Object> tmpResultCaso = (List<Object>)system.JSON.deserializeUntyped(res.getBody());

List<Object> lstjson = new List<Object>();                      
for (Object o: tmpResultCaso)
{
lstjson.add(system.JSON.serialize(o));
}
Map<Id,Object> mapCasoObj = new Map<Id,Object>();

List<String> LstSorte = new List<String>();

if(lstjson.size()==0)
{
for(case cs : [Select Id,Numero_sorte__c,FlagNumeroSorte__c from Case where Id=: casoid])
{
cs.Validacao_CapiVida__c = 'Não Encontrado';
cs.FlagNumeroSorte__c = true;
LstCaso.add(cs); 
}
}else
{//se o numero estiver preenchido, p
for(Object s:lstjson)
{
String j = String.valueof(s);
Map<String, Object> tmpResultObjectCaso = (Map<String, Object>) system.JSON.deserializeUntyped(j);
LstSorte.add(String.valueof(tmpResultObjectCaso.values()[0]));
}   

for(case cs : [Select Id,Numero_sorte__c,FlagNumeroSorte__c from Case where Id=: casoid])
{
cs.Numero_sorte__c = LstSorte[0];
cs.FlagNumeroSorte__c = true;
LstCaso.add(cs);    
}



}




}
if(!LstCaso.isempty()) update(LstCaso);
}*/
    
    
    /*public void validaGarantiaNoCaso(List<Case> casos){

Recordtype REC_ID_PAI = RecordTypeBO.buscarTipoRegistro('Case', 'Atendimento');

Map<Id,Case> mapCasePai = new Map<Id,Case>();
Map<Id,Case> mapAccount = new Map<Id,Case>();

for(Case c : casos){

//aqui preenche o caso pai
if(c.RecordTypeId == REC_ID_PAI.Id && c.Criar_caso_filho_automaticamente__c == true && c.Garantia__c != null && c.Type == 'Sinistro'){
mapCasePai.put(c.Garantia__c, c);
mapAccount.put(c.AccountId, c);
}
}

if(mapCasePai.isEmpty()) return;

//aqui eu vejo se a garantia match com a conta
List<GarantiaSeguradoContrato__c> lsGaranSeg = [SELECT Id, Garantia__c, SeguradoContrato__r.Conta__c, 
SeguradoContrato__r.VigenciaInicial__c, 
SeguradoContrato__r.VIgenciaFinal__c,
SeguradoContrato__r.GrupoContrato__r.ContratanteContrato__r.Contrato__c
FROM GarantiaSeguradoContrato__c 
WHERE Garantia__c IN :mapCasePai.keySet()
AND SeguradoContrato__r.Conta__c IN :mapAccount.keySet()];

//se n tiver garantina informa que não foi localizada garantia
for(Case c : mapCasePai.values()){
if(lsGaranSeg.isEmpty()){c.addError('Não localizado seguro para a garantia informada');
} else {
break;
}
}

List<Case> lstCase = new List<Case>();
Set<Id> setIdGaran = new Set<Id>();
Set<Id> setIdContrato = new Set<Id>();

List<Id> lstCaseFilhoBeforeForaData = new List<Id>();

for(GarantiaSeguradoContrato__c vGS : lsGaranSeg){

Case c = mapCasePai.get(vGS.Garantia__c);



if(c.Dataocorrencia__c >= vGS.SeguradoContrato__r.VigenciaInicial__c &&
c.Dataocorrencia__c <= vGS.SeguradoContrato__r.VIgenciaFinal__c){

lstCaseFilhoBeforeForaData.add(c.Id);

}else
{
c.addError('Não localizado seguro vigente para a data de ocorrência informada'); 
}


if( vGS.SeguradoContrato__r.Conta__c == c.AccountId &&
c.Dataocorrencia__c >= vGS.SeguradoContrato__r.VigenciaInicial__c &&
c.Dataocorrencia__c <= vGS.SeguradoContrato__r.VIgenciaFinal__c){
c.Contrato__c = vGS.SeguradoContrato__r.GrupoContrato__r.ContratanteContrato__r.Contrato__c;
lstCase.add(c);
setIdGaran.add(c.Garantia__c);
setIdContrato.add(vGS.SeguradoContrato__r.GrupoContrato__r.ContratanteContrato__r.Contrato__c);
}
}

List<Case> lstCaseErro = new List<Case>();
Map<Id,Contract> mapContract = new Map<Id,Contract>(
[SELECT Id, Produto__c FROM Contract WHERE Produto__c != null AND Id IN :setIdContrato]
);


Map<Id,Map<Id,GarantiaProduto__c>> mapGarantia = new Map<Id,Map<Id,GarantiaProduto__c>>(); 

for(GarantiaProduto__c vGaranProd : [SELECT Id, Produto__c, Garantia__c, PrazoAvisoSinistro__c, TipoPrazoAvisoSinistro__c 
FROM GarantiaProduto__c WHERE Produto__c != null AND Garantia__c IN :setIdGaran]){
Map<Id,GarantiaProduto__c> mapGaranProdutos;
if(mapGarantia.containsKey(vGaranProd.Garantia__c)){
mapGaranProdutos = mapGarantia.get(vGaranProd.Garantia__c);
} else {
mapGaranProdutos = new Map<Id,GarantiaProduto__c>();
}

mapGaranProdutos.put(vGaranProd.Produto__c,vGaranProd);
mapGarantia.put(vGaranProd.Garantia__c,mapGaranProdutos);
}
for(Case c : lstCase){
Contract vContract = mapContract.get(c.Contrato__c);
Map<Id,GarantiaProduto__c> mapGaranProdutos = mapGarantia.get(c.Garantia__c);
if(mapGaranProdutos == null || vContract == null) continue;

if(mapGaranProdutos.containsKey(vContract.Produto__c)){
GarantiaProduto__c vGPro = mapGaranProdutos.get(vContract.Produto__c);

if(vGPro.TipoPrazoAvisoSinistro__c == 'Ano' && vGPro.PrazoAvisoSinistro__c != null){
c.Data_limite_aviso_sinistro__c = c.Dataocorrencia__c.addYears(vGPro.PrazoAvisoSinistro__c.intValue());
} else if(vGPro.TipoPrazoAvisoSinistro__c == 'Mês' && vGPro.PrazoAvisoSinistro__c != null){
c.Data_limite_aviso_sinistro__c = c.Dataocorrencia__c.addMonths(vGPro.PrazoAvisoSinistro__c.intValue());
} else if(vGPro.TipoPrazoAvisoSinistro__c == 'Dia' && vGPro.PrazoAvisoSinistro__c != null){
c.Data_limite_aviso_sinistro__c = c.Dataocorrencia__c.addDays(vGPro.PrazoAvisoSinistro__c.intValue());
}
}

if(c.Data_Aviso_Cliente__c < c.Data_limite_aviso_sinistro__c){
lstCaseErro.add(c);
} 

if(lstCaseErro.isEmpty()){c.addError('Prazo para avisar o sinistro excedido');
}
}




}*/
    
    
    /*public void criarCasosFilhos(List<Case> casos){

Recordtype REC_ID_PAI = RecordTypeBO.buscarTipoRegistro('Case', 'Atendimento');
Recordtype REC_ID_SINISTRO = RecordTypeBO.buscarTipoRegistro('Case', 'Sinistro');
Recordtype REC_ID_BENEFICIO = RecordTypeBO.buscarTipoRegistro('Case', 'Beneficio');

Map<Id,Case> mapCasePai = new Map<Id,Case>();
Map<Id,Case> mapAccount = new Map<Id,Case>();

for(Case c : casos){

if(c.RecordTypeId == REC_ID_PAI.Id && c.Criar_caso_filho_automaticamente__c == true){
mapCasePai.put(c.Garantia__c, c.clone(true));
mapAccount.put(c.AccountId, c);
}
}

if(mapCasePai.isEmpty()) return;

List<GarantiaSeguradoContrato__c> lsGaranSeg = [SELECT Id, Garantia__c, SeguradoContrato__r.Conta__c, 
SeguradoContrato__r.VigenciaInicial__c, 
SeguradoContrato__r.VIgenciaFinal__c,
SeguradoContrato__r.GrupoContrato__r.ContratanteContrato__r.Contrato__c
FROM GarantiaSeguradoContrato__c 
WHERE Garantia__c IN :mapCasePai.keySet()
AND SeguradoContrato__r.Conta__c IN :mapAccount.keySet()];
if(lsGaranSeg.isEmpty()) return;

Map<Id,Case> mapCaseFilho = new Map<Id,Case>();
Map<Id,List<GarantiaSeguradoContrato__c>> mapGarantia = new Map<Id,List<GarantiaSeguradoContrato__c>>();

for(GarantiaSeguradoContrato__c vGS : lsGaranSeg){

Case c = mapCasePai.get(vGS.Garantia__c);

if( vGS.SeguradoContrato__r.Conta__c == c.AccountId &&
c.Dataocorrencia__c >= vGS.SeguradoContrato__r.VigenciaInicial__c &&
c.Dataocorrencia__c <= vGS.SeguradoContrato__r.VIgenciaFinal__c){

c.Criar_caso_filho_automaticamente__c = false;

List<GarantiaSeguradoContrato__c> lGarantia;

if (mapGarantia.containsKey(c.Id)) {lGarantia = mapGarantia.get(c.Id);
} else {
lGarantia = new List<GarantiaSeguradoContrato__c>();
}

lGarantia.add(vGS);
mapGarantia.put(c.Id, lGarantia);
mapCaseFilho.put(c.Id, c);
}
}

if(mapCaseFilho.isEmpty()) return;

List<Case> lsCaseFilhos = new List<Case>();

for(Case c : mapCaseFilho.values()){


for (GarantiaSeguradoContrato__c garantia : mapGarantia.get(c.Id)) {


Case cFilho = new Case();
if(c.Type == 'Sinistro'){

cFilho.RecordTypeId = REC_ID_SINISTRO.Id;
cFilho.AccountId = c.AccountId;
cFilho.ContactId = c.ContactId;
cFilho.Dataocorrencia__c = c.Dataocorrencia__c;
cFilho.Subject = c.Subject;
cFilho.Description = c.Description;
cFilho.Type = c.Type;
cFilho.Origin = 'Pai';
cFilho.Status = 'Avisar';
cFilho.Status_Dependente__c = 'Em Análise';
cFilho.ParentId = c.Id;
cFilho.Garantia__c = c.Garantia__c;
cFilho.TipoEvento__c = c.TipoEvento__c;
cFilho.Vitima__c = c.Vitima__c;
cFilho.Garantia_do_segurado_do_contrato__c = garantia.Id;
cFilho.Contrato__c = garantia.SeguradoContrato__r.GrupoContrato__r.ContratanteContrato__r.Contrato__c;
cFilho.Caso_Filho_Criado_Automaticamente__c = true;


lsCaseFilhos.add(cFilho);

}
}
}


Database.SaveResult[] lstSr = Database.insert(lsCaseFilhos, false);
Integer i = 0;
for(Database.SaveResult sr : lstSr){
if(!sr.isSuccess()){
for(Database.Error err : sr.getErrors()){
if (err.getMessage() != 'Prazo para avisar o sinistro excedido'){
Case casoFilho = lsCaseFilhos.get(i);
mapCaseFilho.get(casoFilho.ParentId).addError(err.getMessage());
}
}
}
i++;
}
insert lsCaseFilhos;
update mapCaseFilho.values();
}*/
    
    /*public void preencherBeneficiarioSinistro(List<Case> casos, Map<Id,Case> mCasosOld){
if(checkRecursive.runOnce())
{    
Recordtype REC_ID_SINISTRO = RecordTypeBO.buscarTipoRegistro('Case', 'Sinistro');

Set<Id> setIdCase = new Set<Id>();
for(Case c : casos){
//se o status do filho for avisado e o status antigo dele for avisa entra              
if(c.RecordTypeId == REC_ID_SINISTRO.Id && c.Status == 'Avisado' && mCasosOld.get(c.Id).Status == 'Avisar'){   
setIdCase.add(c.Id);
}
}


if(!setIdCase.isEmpty()){        
List<Case> lstCase = [SELECT Id, Garantia_do_segurado_do_contrato__r.SeguradoContrato__r.Id 
FROM Case
WHERE Id IN :setIdCase];
Set<Id> setIdSegurado = new Set<Id>();
Map<Id,Id> mSegurado = new Map<Id,Id>();
for(Case c2 : lstCase){
setIdSegurado.add(c2.Garantia_do_segurado_do_contrato__r.SeguradoContrato__r.Id);
mSegurado.put(c2.Garantia_do_segurado_do_contrato__r.SeguradoContrato__r.Id, c2.Id);
}
List<BeneficiarioSeguradoContrato__c> lstBuscaBenSegContr = [SELECT Conta__c, GrauParentesco__c, TipoBeneficiario__c, Participacao__c, SeguradoContrato__c 
FROM BeneficiarioSeguradoContrato__c 
WHERE SeguradoContrato__c IN :setIdSegurado AND TipoBeneficiario__c != 'Conforme artigo 792 do código civil'];

List<BeneficiarioSinistro__c> lstBenSin = new List<BeneficiarioSinistro__c>();
for(BeneficiarioSeguradoContrato__c vBSC : lstBuscaBenSegContr){

BeneficiarioSinistro__c bs = new BeneficiarioSinistro__c();
bs.Conta__c = vBSC.Conta__c;
bs.RelacionamentoSegurado__c = vBSC.GrauParentesco__c;
bs.Percentual_de_indenizacao__c = vBSC.Participacao__c;
bs.Status__c = 'Pendente';
bs.Caso__c = mSegurado.containsKey(vBSC.SeguradoContrato__c) ? mSegurado.get(vBSC.SeguradoContrato__c) : null;

lstBenSin.add(bs);
}

if(!lstBenSin.isEmpty()){
database.insert(lstBenSin);
}

}
}
}*/
    
    
    
    //AVX SP24 - História pendente que atualiza o Heroku nas alterções de alguns status do caso.
    public void criarRegistrosFilhosSinistro(List<Case> plCasoNew, Map<Id,Case> pmCasoOld) {
        if(CasoTriggerHandler.isFirstTime)
        {
            if(!Test.isRunningTest()) CasoTriggerHandler.isFirstTime = false;
            
            Id REC_ID_SINISTRO = RecordTypeBO.buscarTipoRegistro('Case', 'Sinistro').Id;
            
            Set<Id> sCasosId = new Set<Id>();
        
            for (Case casoNew : plCasoNew) {
                if (casoNew.RecordTypeId == REC_ID_SINISTRO && (casoNew.Status !=  'Avisar') &&
                    (casoNew.Status ==  'Avisado' || casoNew.Status ==  'Em Regulação' || casoNew.Status ==  'Liquidação' ||
                     casoNew.Status_Dependente__c != pmCasoOld.get(casoNew.Id).Status_Dependente__c)) {
                        
                         sCasosId.add(casoNew.Id);
                     }
            }
            

            if (sCasosId.isEmpty()) return;
            
            //Início Incidente 3688206
            if(system.isFuture()){
                criarArquivoLoteSinistroHerokuFuture(sCasosId);
            }
            else{
                criarArquivoLoteSinistroHeroku(sCasosId);
            }
            //Fim Incidente 3688206
            
        }
    }
    
    //Início Incidente 3688206
    public static void criarArquivoLoteSinistroHerokuFuture(Set<Id> psIdCaso) {
        List<Case> lCaso = [SELECT Id, AccountId, Dataocorrencia__c, Data_sinistro_avisado__c, Status,
                            Status_Dependente__c, NumeroSinistro__c,
                            Contrato__r.Parceria__c, Contrato__r.Parceria__r.Codigo__c,
                            Contrato__r.Produto__c, Contrato__r.Proposta__r.Origem__c,
                            Contrato__r.Proposta__r.QuoteNumber, Contrato__r.NumeroApolice__c,
                            Contrato__r.Proposta__r.NumeroProposta__c,
                            Contrato__r.IdContratoParceiro__c,
                            Contrato__r.IdSeguradoParceiro__c,
                            Account.Cpf__c, Account.Name,
                            (SELECT Id, ValorIndenizado__c FROM Pagamentos_de_garantia__r)
                            FROM Case
                            WHERE Id IN :psIdCaso];
        
        Set<Id> sPagamentoId = new Set<Id>();
        Set<Id> sParceiroId = new Set<Id>();
        
        for (Case caso : lCaso){
            sParceiroId.add(caso.Contrato__r.Parceria__c);
            
            for (PagamentoGarantia__c pagamento : caso.Pagamentos_de_garantia__r)
                sPagamentoId.add(pagamento.Id);
        }
        
        // Map<Id do Pagamento, Lista do Beneficiario>
        Map<Id, List<BeneficiarioGarantia__c>> mPagamento = new Map<Id, List<BeneficiarioGarantia__c>>();
        
        for (PagamentoGarantia__c pagamento : [SELECT Id,
                                               (SELECT Id, Conta__r.Cpf__c, Conta__r.Cnpj__c, Conta__r.Name FROM Beneficiarios_Garantia__r)
                                               FROM PagamentoGarantia__c
                                               WHERE Id IN :sPagamentoId]) {
                                                   mPagamento.put(pagamento.Id, pagamento.Beneficiarios_Garantia__r);
                                               }
        
        Map<Id,OperacaoProdutoParceiro__c> mProduto;
        Map<Id,Map<Id,OperacaoProdutoParceiro__c>> mProdParceiro = new Map<Id,Map<Id,OperacaoProdutoParceiro__c>>();
        
        for (OperacaoProdutoParceiro__c operacao : [SELECT Id, Sigla__c, OperacaoParceiro__c,
                                                    ProdutoParceiro__r.Parceiro__c,
                                                    ProdutoParceiro__r.Produto__c,
                                                    ProdutoParceiro__r.CodigoProdutoParceiro__c
                                                    FROM OperacaoProdutoParceiro__c
                                                    WHERE Tipo__c = 'Sinistro'
                                                    AND ProdutoParceiro__r.Parceiro__c IN :sParceiroId
                                                    ORDER BY ProdutoParceiro__r.Parceiro__c]) {
                                                        
                                                        
                                                        
                                                        if (mProdParceiro.containsKey(operacao.ProdutoParceiro__r.Parceiro__c)) mProduto = mProdParceiro.get(operacao.ProdutoParceiro__r.Parceiro__c);
                                                        else mProduto = new Map<Id,OperacaoProdutoParceiro__c>(); 
                                                        
                                                        mProduto.put(operacao.ProdutoParceiro__r.Produto__c, operacao);
                                                        mProdParceiro.put(operacao.ProdutoParceiro__r.Parceiro__c, mProduto);
                                                    }
        
        List<Case> lCasoUpdate = new List<Case>();
        
        CriarArquivoLoteSinistroTO body = new CriarArquivoLoteSinistroTO();
        CriarArquivoLoteSinistroTO.ArquivoTO arquivo = body.arquivo;
        String codigoparceiro;
        
        for (Case caso : lCaso) {
            
            if (caso.Contrato__r.Parceria__c == null) { caso.ErroIntegracao__c = 'O caso não possui um Parceiro vinculado em seu contrato!';
                                                       lCasoUpdate.add(caso);
                                                       continue;
                                                       
                                                      } else if (!mProdParceiro.containsKey(caso.Contrato__r.Parceria__c)) { caso.ErroIntegracao__c = 'O parceiro do caso não possui produtos do tipo Sinistro cadastrados nas operações';
                                                                                                                            lCasoUpdate.add(caso);
                                                                                                                            continue;
                                                                                                                           }
            
            mProduto = mProdParceiro.get(caso.Contrato__r.Parceria__c);
            
            if (caso.Contrato__r.Produto__c == null) { caso.ErroIntegracao__c = 'O caso não possui um Produto vinculado em seu contrato!';
                                                      lCasoUpdate.add(caso);
                                                      continue;
                                                      
                                                     } else if (!mProduto.containsKey(caso.Contrato__r.Produto__c)) { caso.ErroIntegracao__c = 'O produto do Contrato do Caso não é igual ao produto do Parceiro!';
                                                                                                                     lCasoUpdate.add(caso);
                                                                                                                     continue;
                                                                                                                    }
            
            OperacaoProdutoParceiro__c operacao = mProduto.get(caso.Contrato__r.Produto__c);
            
            arquivo.tipoarquivo = 'SINISTRO';
            arquivo.sigla = operacao.Sigla__c;
            arquivo.produto = operacao.ProdutoParceiro__r.CodigoProdutoParceiro__c;
            arquivo.nomearquivo = 'PORTO_RENNER_'+arquivo.produto+'_'+arquivo.sigla+'_<loteparceiro>_'+operacao.OperacaoParceiro__c+'.PRO';
            arquivo.direcao = 'SAIDA';
            arquivo.codigoparceiro = caso.Contrato__r.Parceria__r.Codigo__c;
            arquivo.loteparceiro = '<sequencial>'; // vai ser um sequencial setado no heroku
            arquivo.versaoarquivo = 0;
            arquivo.status = 'PENDENTE';
            
            CriarArquivoLoteSinistroTO.LoteTO lote = body.lote;
            lote.nome = arquivo.nomearquivo;
            lote.status = 'PENDENTE';
            
            if(caso.Pagamentos_de_garantia__r == null || caso.Pagamentos_de_garantia__r.size() == 0)
            {
                CriarArquivoLoteSinistroTO.SinistroTO sinistro = new CriarArquivoLoteSinistroTO.SinistroTO();
                
                sinistro.cpf = caso.Account.Cpf__c;
                sinistro.idlote = '<idlote>';
                sinistro.nome = caso.Account.Name;
                sinistro.dataocorrencia = caso.Dataocorrencia__c;
                sinistro.dataaviso = caso.Data_sinistro_avisado__c;
                sinistro.numerosinistro = caso.NumeroSinistro__c;
                sinistro.idseguradoparceiro = caso.Contrato__r.IdSeguradoParceiro__c;
                
                String CasoDep;
                if(caso.Status_Dependente__c == 'Em Análise')
                {
                    CasoDep = 'EM ANALISE';
                }else{ 
                    CasoDep = caso.Status_Dependente__c;
                }
                sinistro.status = CasoDep;
                sinistro.origemproposta = caso.Contrato__r.Proposta__r.Origem__c;
                sinistro.numeropropostaporto = caso.Contrato__r.Proposta__r.NumeroProposta__c; 
                sinistro.numerocontratoparceiro = caso.Contrato__r.IdContratoParceiro__c;
                sinistro.fase = caso.Status;
                sinistro.idcaso = caso.Id;
                sinistro.codigoprodutoparceiro = operacao.ProdutoParceiro__r.CodigoProdutoParceiro__c;
                
                body.sinistros.add(sinistro);
                
            }
            
            //caso existam beneficiarios            
            for (PagamentoGarantia__c pagamento : caso.Pagamentos_de_garantia__r) {
                List<BeneficiarioGarantia__c> lBeneficiario = mPagamento.get(pagamento.Id);
                if (lBeneficiario == null) continue;
                for (BeneficiarioGarantia__c beneficiario : lBeneficiario) {
                    CriarArquivoLoteSinistroTO.SinistroTO sinistro = new CriarArquivoLoteSinistroTO.SinistroTO();
                    
                    sinistro.cpf = caso.Account.Cpf__c;
                    sinistro.idlote = '<idlote>';
                    sinistro.nome = caso.Account.Name;
                    sinistro.dataocorrencia = caso.Dataocorrencia__c;
                    sinistro.dataaviso = caso.Data_sinistro_avisado__c;
                    sinistro.numerosinistro = caso.NumeroSinistro__c;
                    sinistro.idseguradoparceiro = caso.Contrato__r.IdSeguradoParceiro__c;
                    
                    String CasoDep;
                    
                    if(caso.Status_Dependente__c == 'Em Análise')
                    {
                        CasoDep = 'EM ANALISE';
                    }else{ 
                        CasoDep = caso.Status_Dependente__c;
                    }
                    sinistro.status = CasoDep;
                    
                    sinistro.origemproposta = caso.Contrato__r.Proposta__r.Origem__c;
                    
                    sinistro.numeropropostaporto = caso.Contrato__r.Proposta__r.NumeroProposta__c; 
                    sinistro.numerocontratoparceiro = caso.Contrato__r.IdContratoParceiro__c;
                    //sinistro.dataindenizacao = '<dataindenizacao>';
                    sinistro.valorindenizado = pagamento.ValorIndenizado__c;
                    String CPFCNPJ;
                    
                    if(beneficiario.Conta__r.Cpf__c != null)
                    {
                        CPFCNPJ = beneficiario.Conta__r.Cpf__c;
                    }else{
                        CPFCNPJ = beneficiario.Conta__r.Cnpj__c;
                    }
                    sinistro.observacao = CPFCNPJ +'|'+ beneficiario.Conta__r.Name;
                    //sinistro.idarquivo = '<idarquivo>';
                    sinistro.fase = caso.Status;
                    sinistro.idcaso = caso.Id;
                    sinistro.codigoprodutoparceiro = operacao.ProdutoParceiro__r.CodigoProdutoParceiro__c;
                    
                    body.sinistros.add(sinistro);
                }
            }              
            
            codigoparceiro = caso.Contrato__r.Parceria__r.Codigo__c;
            
            //chamar HerokuService
            String Retorno = HerokuService.getInstance().gerarArquivoLoteSinistro(codigoparceiro, body);
            
            List<ControleIntegracao__c> lstLog = new List<ControleIntegracao__c>();
            
            List<ControleIntegracao__c> LstCTI = [Select Id 
                                                  From ControleIntegracao__c 
                                                  Where CodigoIntegracao__c = '69'
                                                  limit 1];
            
            if(LstCTI.size() != 0)
            {
                if(Retorno != null) 
                {
                    ControleIntegracao__c log = new ControleIntegracao__c();
                    log.Id = LstCTI[0].Id;
                    log.CodigoIntegracao__c   = '69';
                    log.DataCriacaoRegistro__c   = Date.today();
                    log.IdObjeto__c       = String.valueof(Retorno); 
                    log.Status__c         = 'Pendente'; 
                    lstLog.add(log);
                    
                    if(!lstLog.isempty()) database.update(lstLog);
                }
            }else{
                if(Retorno != null) 
                {
                    ControleIntegracao__c log = new ControleIntegracao__c();
                    log.CodigoIntegracao__c   = '69';
                    log.DataCriacaoRegistro__c   = Date.today();
                    log.IdObjeto__c       = String.valueof(Retorno); 
                    log.Status__c         = 'Pendente'; 
                    lstLog.add(log);
                    if(!lstLog.isempty()) database.insert(lstLog);
                }   
            }
        }
    }
    
    //Fim Incidente 3688206
    
    
    //AVX SP24 - Metódo futuro que chama Heroku Service a partir do método acima.
    @future(callout=true)
    public static void criarArquivoLoteSinistroHeroku(Set<Id> psIdCaso) {    
        
        List<Case> lCaso = [SELECT Id, AccountId, Dataocorrencia__c, Data_sinistro_avisado__c, Status,
                            Status_Dependente__c, NumeroSinistro__c,
                            Contrato__r.Parceria__c, Contrato__r.Parceria__r.Codigo__c,
                            Contrato__r.Produto__c, Contrato__r.Proposta__r.Origem__c,
                            Contrato__r.Proposta__r.QuoteNumber, Contrato__r.NumeroApolice__c,
                            Contrato__r.Proposta__r.NumeroProposta__c,
                            Contrato__r.IdContratoParceiro__c,
                            Contrato__r.IdSeguradoParceiro__c,
                            Account.Cpf__c, Account.Name,
                            (SELECT Id, ValorIndenizado__c FROM Pagamentos_de_garantia__r)
                            FROM Case
                            WHERE Id IN :psIdCaso];
        
        Set<Id> sPagamentoId = new Set<Id>();
        Set<Id> sParceiroId = new Set<Id>();
        
        
        for (Case caso : lCaso){
            
            sParceiroId.add(caso.Contrato__r.Parceria__c);
            
            for (PagamentoGarantia__c pagamento : caso.Pagamentos_de_garantia__r)
                sPagamentoId.add(pagamento.Id);
        }
        
        
        // Map<Id do Pagamento, Lista do Beneficiario>
        Map<Id, List<BeneficiarioGarantia__c>> mPagamento = new Map<Id, List<BeneficiarioGarantia__c>>();
        
        for (PagamentoGarantia__c pagamento : [SELECT Id,
                                               (SELECT Id, Conta__r.Cpf__c, Conta__r.Cnpj__c, Conta__r.Name FROM Beneficiarios_Garantia__r)
                                               FROM PagamentoGarantia__c
                                               WHERE Id IN :sPagamentoId]) {
                                                   mPagamento.put(pagamento.Id, pagamento.Beneficiarios_Garantia__r);
                                               }
        
        //(SELECT Id, Conta__r.Cpf__c, Conta__r.Name FROM Beneficiarios_do_sinistro__r)
        Map<Id,OperacaoProdutoParceiro__c> mProduto;
        Map<Id,Map<Id,OperacaoProdutoParceiro__c>> mProdParceiro = new Map<Id,Map<Id,OperacaoProdutoParceiro__c>>();
        
        for (OperacaoProdutoParceiro__c operacao : [SELECT Id, Sigla__c, OperacaoParceiro__c,
                                                    ProdutoParceiro__r.Parceiro__c,
                                                    ProdutoParceiro__r.Produto__c,
                                                    ProdutoParceiro__r.CodigoProdutoParceiro__c
                                                    FROM OperacaoProdutoParceiro__c
                                                    WHERE Tipo__c = 'Sinistro'
                                                    AND ProdutoParceiro__r.Parceiro__c IN :sParceiroId
                                                    ORDER BY ProdutoParceiro__r.Parceiro__c]) {
                                                        
                                                        
                                                        
                                                        if (mProdParceiro.containsKey(operacao.ProdutoParceiro__r.Parceiro__c)) mProduto = mProdParceiro.get(operacao.ProdutoParceiro__r.Parceiro__c);
                                                        else mProduto = new Map<Id,OperacaoProdutoParceiro__c>(); 
                                                        
                                                        mProduto.put(operacao.ProdutoParceiro__r.Produto__c, operacao);
                                                        mProdParceiro.put(operacao.ProdutoParceiro__r.Parceiro__c, mProduto);
                                                    }
        
        List<Case> lCasoUpdate = new List<Case>();
        
        
        CriarArquivoLoteSinistroTO body = new CriarArquivoLoteSinistroTO();
        CriarArquivoLoteSinistroTO.ArquivoTO arquivo = body.arquivo;
        String codigoparceiro;
        
        for (Case caso : lCaso) {
            
            if (caso.Contrato__r.Parceria__c == null) { caso.ErroIntegracao__c = 'O caso não possui um Parceiro vinculado em seu contrato!';
                                                       lCasoUpdate.add(caso);
                                                       continue;
                                                       
                                                      } else if (!mProdParceiro.containsKey(caso.Contrato__r.Parceria__c)) { caso.ErroIntegracao__c = 'O parceiro do caso não possui produtos do tipo Sinistro cadastrados nas operações';
                                                                                                                            lCasoUpdate.add(caso);
                                                                                                                            continue;
                                                                                                                           }
            
            mProduto = mProdParceiro.get(caso.Contrato__r.Parceria__c);
            
            if (caso.Contrato__r.Produto__c == null) { caso.ErroIntegracao__c = 'O caso não possui um Produto vinculado em seu contrato!';
                                                      lCasoUpdate.add(caso);
                                                      continue;
                                                      
                                                     } else if (!mProduto.containsKey(caso.Contrato__r.Produto__c)) { caso.ErroIntegracao__c = 'O produto do Contrato do Caso não é igual ao produto do Parceiro!';
                                                                                                                     lCasoUpdate.add(caso);
                                                                                                                     continue;
                                                                                                                    }
            
            OperacaoProdutoParceiro__c operacao = mProduto.get(caso.Contrato__r.Produto__c);
            
            
            arquivo.tipoarquivo = 'SINISTRO';
            arquivo.sigla = operacao.Sigla__c;
            arquivo.produto = operacao.ProdutoParceiro__r.CodigoProdutoParceiro__c;
            arquivo.nomearquivo = 'PORTO_RENNER_'+arquivo.produto+'_'+arquivo.sigla+'_<loteparceiro>_'+operacao.OperacaoParceiro__c+'.PRO';
            arquivo.direcao = 'SAIDA';
            arquivo.codigoparceiro = caso.Contrato__r.Parceria__r.Codigo__c;
            arquivo.loteparceiro = '<sequencial>'; // vai ser um sequencial setado no heroku
            arquivo.versaoarquivo = 0;
            arquivo.status = 'PENDENTE';
            
            CriarArquivoLoteSinistroTO.LoteTO lote = body.lote;
            lote.nome = arquivo.nomearquivo;
            lote.status = 'PENDENTE';
            
            
            // se não existir pagamento da garantia relacionado ao caso, criar sinistro com informacoes
            // de cabecalho apenas
            
            if(caso.Pagamentos_de_garantia__r == null || caso.Pagamentos_de_garantia__r.size() == 0)
            {
                CriarArquivoLoteSinistroTO.SinistroTO sinistro = new CriarArquivoLoteSinistroTO.SinistroTO();
                
                sinistro.cpf = caso.Account.Cpf__c;
                sinistro.idlote = '<idlote>';
                sinistro.nome = caso.Account.Name;
                sinistro.dataocorrencia = caso.Dataocorrencia__c;
                sinistro.dataaviso = caso.Data_sinistro_avisado__c;
                sinistro.numerosinistro = caso.NumeroSinistro__c;
                sinistro.idseguradoparceiro = caso.Contrato__r.IdSeguradoParceiro__c;
                
                String CasoDep;
                
                if(caso.Status_Dependente__c == 'Em Análise')
                {
                    CasoDep = 'EM ANALISE';
                }else{ 
                    CasoDep = caso.Status_Dependente__c;
                }
                sinistro.status = CasoDep;
                sinistro.origemproposta = caso.Contrato__r.Proposta__r.Origem__c;
                sinistro.numeropropostaporto = caso.Contrato__r.Proposta__r.NumeroProposta__c; 
                sinistro.numerocontratoparceiro = caso.Contrato__r.IdContratoParceiro__c;
                sinistro.fase = caso.Status;
                sinistro.idcaso = caso.Id;
                sinistro.codigoprodutoparceiro = operacao.ProdutoParceiro__r.CodigoProdutoParceiro__c;
                
                body.sinistros.add(sinistro);
                
            }
            
            //caso existam beneficiarios            
            for (PagamentoGarantia__c pagamento : caso.Pagamentos_de_garantia__r) {
                
                List<BeneficiarioGarantia__c> lBeneficiario = mPagamento.get(pagamento.Id);
                
                if (lBeneficiario == null) continue;
                
                for (BeneficiarioGarantia__c beneficiario : lBeneficiario) {
                    
                    CriarArquivoLoteSinistroTO.SinistroTO sinistro = new CriarArquivoLoteSinistroTO.SinistroTO();
                    
                    sinistro.cpf = caso.Account.Cpf__c;
                    sinistro.idlote = '<idlote>';
                    sinistro.nome = caso.Account.Name;
                    sinistro.dataocorrencia = caso.Dataocorrencia__c;
                    sinistro.dataaviso = caso.Data_sinistro_avisado__c;
                    sinistro.numerosinistro = caso.NumeroSinistro__c;
                    sinistro.idseguradoparceiro = caso.Contrato__r.IdSeguradoParceiro__c;
                    
                    String CasoDep;
                    
                    if(caso.Status_Dependente__c == 'Em Análise')
                    {
                        CasoDep = 'EM ANALISE';
                    }else{ 
                        CasoDep = caso.Status_Dependente__c;
                    }
                    sinistro.status = CasoDep;
                    
                    sinistro.origemproposta = caso.Contrato__r.Proposta__r.Origem__c;
                    
                    sinistro.numeropropostaporto = caso.Contrato__r.Proposta__r.NumeroProposta__c; 
                    sinistro.numerocontratoparceiro = caso.Contrato__r.IdContratoParceiro__c;
                    //sinistro.dataindenizacao = '<dataindenizacao>';
                    sinistro.valorindenizado = pagamento.ValorIndenizado__c;
                    String CPFCNPJ;
                    
                    if(beneficiario.Conta__r.Cpf__c != null)
                    {
                        CPFCNPJ = beneficiario.Conta__r.Cpf__c;
                    }else{
                        CPFCNPJ = beneficiario.Conta__r.Cnpj__c;
                    }
                    sinistro.observacao = CPFCNPJ +'|'+ beneficiario.Conta__r.Name;
                    //sinistro.idarquivo = '<idarquivo>';
                    sinistro.fase = caso.Status;
                    sinistro.idcaso = caso.Id;
                    sinistro.codigoprodutoparceiro = operacao.ProdutoParceiro__r.CodigoProdutoParceiro__c;
                    
                    body.sinistros.add(sinistro);
                }
            }              
            
            
            codigoparceiro = caso.Contrato__r.Parceria__r.Codigo__c;
            
            //chamar HerokuService
            String Retorno = HerokuService.getInstance().gerarArquivoLoteSinistro(codigoparceiro, body);
            
            List<ControleIntegracao__c> lstLog = new List<ControleIntegracao__c>();
            
            List<ControleIntegracao__c> LstCTI = [Select Id 
                                                  From ControleIntegracao__c 
                                                  Where CodigoIntegracao__c = '69'
                                                  limit 1];
            
            if(LstCTI.size() != 0)
            {
                if(Retorno != null) 
                {
                    ControleIntegracao__c log = new ControleIntegracao__c();
                    log.Id = LstCTI[0].Id;
                    log.CodigoIntegracao__c   = '69';
                    log.DataCriacaoRegistro__c   = Date.today();
                    log.IdObjeto__c       = String.valueof(Retorno); 
                    log.Status__c         = 'Pendente'; 
                    lstLog.add(log);
                    
                    if(!lstLog.isempty()) database.update(lstLog);
                }
            }else{
                if(Retorno != null) 
                {
                    ControleIntegracao__c log = new ControleIntegracao__c();
                    log.CodigoIntegracao__c   = '69';
                    log.DataCriacaoRegistro__c   = Date.today();
                    log.IdObjeto__c       = String.valueof(Retorno); 
                    log.Status__c         = 'Pendente'; 
                    lstLog.add(log);
                    if(!lstLog.isempty()) database.insert(lstLog);
                }   
            }
        }
    }
    
    
    
    
    //PLV-2433 - Início - Removido para subir a história de numeração sinistro - aguardando a história voltar
    /* 
//AVX SP28 - PLV-1933 - Cancelamento de Contrato
//PLV-1933 - Início - Código alterado para adaptar chamada do serviço à batch
public void cancelacontrato(List<Case> plCasoNew, Map<Id,Case> mCaseOld) {
//PLV-1096 - Início - Código inserido para ajuste do processo
if(System.isBatch() || System.isFuture()) return;
//PLV-1096 - Fim - Código inserido para ajuste do processo
Id REC_ID_SINISTRO = RecordTypeBO.buscarTipoRegistro('Case', 'Sinistro').Id;
List<Case> lCaso = new List<Case>();
for(Case caso : plCasoNew){
if(caso.RecordtypeId == REC_ID_SINISTRO && caso.Status_da_Integracao__c == 'Aguardando' && 
(caso.Status == 'Avisado' || (caso.Status == 'Fechado' && caso.Status_Dependente__c == 'Pago') && 
(caso.Status != mCaseOld.get(caso.Id).Status))){
lCaso.add(caso);
}
}

if(lCaso.isEmpty()) return;

Map<Id, Case> mCaso = new Map<Id, Case>([SELECT id, 
Garantia_do_segurado_do_contrato__r.GarantiaProduto__r.MomentoCancelamento__c, 
Garantia_do_segurado_do_contrato__r.GarantiaProduto__r.CancelaSegurado__c,
ServicoIntegracao__c
FROM Case 
WHERE Id = :lCaso]);

Boolean processarBatch = false;
//Select de Caso para trazer os campos da Garantia do Produto que são : MomentoCancelamento__c e CancelaSegurado__c;
for(Case caso : lCaso){
Case casoDB = mCaso.get(caso.id);
//Se Na Garantia do Seguro for MomentoCancelamento = Aviso e CancelaSegurado for selecionado entra no if abaixo                     
if(casoDB.Garantia_do_segurado_do_contrato__r.GarantiaProduto__r.CancelaSegurado__c== true &&
(casoDB.Garantia_do_segurado_do_contrato__r.GarantiaProduto__r.MomentoCancelamento__c == 'Aviso' 
|| casoDB.Garantia_do_segurado_do_contrato__r.GarantiaProduto__r.MomentoCancelamento__c == 'Pagamento')){

caso.ProcessaCancelamento__c = true;
processarBatch = true;
//Chamar Batch
}
}

if (!processarBatch) return;

Integer qtdInProcess = [SELECT COUNT()
FROM AsyncApexJob
WHERE Status IN ('Holding','Queued')
AND ApexClass.Name = 'CIVCancelamentoBatch'
AND JobType = 'BatchApex'];

// Em teste não pode invocar o Batch porque ele executa na mesma thread dando erro no callout
// O batch sera coberto pelo classe de teste dele
if (qtdInProcess == 0 && !Test.isRunningTest())
Database.executeBatch(new CIVCancelamentoBatch(), 5);
}
//PLV-1933 - Fim - Código alterado para adaptar chamada do serviço à batch

//PLV-1933- Código removido para adaptar chamada do serviço à batch
*/
    //PLV-2433 - Fim - Removido para subir a história de numeração sinistro - aguardando a história voltar
    
    
    public void atualizaStatusIntegracao(List<Case> casos, Map<Id,Case> mCaseOld){
        for (Case caso: casos){ 
            //PLV-1933- Código alterado para adaptar chamada do serviço á batch
            if(caso.Status == 'Avisado' && mCaseOld.get(caso.id).Status != 'Avisado'){
                caso.Status_da_Integracao__c = 'Aguardando'; 
            }
        }
    }
    
    //AVX SP 28 - PLV 2296
    public void atualizaAvisadoMovimentoSinistro(List<Case> casos, Map<Id, Case> mCaseOld){
        //PLV-2341 - Início - Codigo alterado para atender regra de negocio.
        Map<Id, Case> mCaso = new Map<Id, Case>(); 
        for(Case caso: casos){
            if(caso.Status == 'Avisado' && mCaseOld.get(caso.id).Status != 'Avisado'){
                mCaso.put(caso.Id, caso);
            }
        }
        
        if(mCaso.isEmpty()) return;
        Set<Id> sCasos = new Set<Id>();
        
        Recordtype REC_ID_SINISTRO = RecordTypeBO.buscarTipoRegistro('Case', 'Sinistro');
        Recordtype REC_ID_BENEFICIO = RecordTypeBO.buscarTipoRegistro('Case', 'Beneficio');
        
        for(Case caso: mCaso.values()) {
            
            if(caso.RecordTypeId == REC_ID_BENEFICIO.Id && caso.GerarMovimentacaoContabil__c == true) {
                sCasos.add(caso.Id);
            } else if(caso.RecordTypeId == REC_ID_SINISTRO.Id) {
                sCasos.add(caso.Id);
            }
        }
        
        if(sCasos.isEmpty()) return;
        
        //PLV-4037 - Início
        Map<Id, List<PagamentoGarantia__c>> mapCaseIdToListPagGarantia = new Map<Id, List<PagamentoGarantia__c>>();
        
        for( PagamentoGarantia__c pagGarantia : [   SELECT  Id, Caso__c, Valor_indenizado__c //PLV - 4818 - GUSTAVO PEREIRA - SYS4B INICIO/FIM
                                                 FROM    PagamentoGarantia__c
                                                 WHERE   Caso__c IN : sCasos 
                                                ]){
                                                    
                                                    List<PagamentoGarantia__c> lstPagGarantiaAux = new List<PagamentoGarantia__c>();
                                                    
                                                    if( mapCaseIdToListPagGarantia.containsKey(pagGarantia.Caso__c) ){
                                                        lstPagGarantiaAux = mapCaseIdToListPagGarantia.get(pagGarantia.Caso__c);
                                                    }
                                                    
                                                    lstPagGarantiaAux.add( pagGarantia );
                                                    
                                                    mapCaseIdToListPagGarantia.put( pagGarantia.Caso__c, lstPagGarantiaAux );
                                                }
        
        Set<String> sMovSinistro = new Set<String>();
        
        for(MovimentoSinistro__c movSinistro : [SELECT id, Caso__c, PagamentoGarantia__c
                                                FROM MovimentoSinistro__c
                                                WHERE Caso__c IN : sCasos
                                                AND TipoMovimento__c = 'Aviso'
                                                AND DescricaoMovimento__c = '1']){
                                                    sMovSinistro.add(movSinistro.Caso__c + '' + movSinistro.PagamentoGarantia__c);
                                                }
        
        List<MovimentoSinistro__c> lMovSin2Insert = new List<MovimentoSinistro__c>();
        
        Map<Id, Integer> mSequenciaMov = SequenciaMovimentoSinistroHelper.sequenciaMovimentos(sCasos);
        // POR062-1 - INICIO
        for(Id idCaso : sCasos){
            
            if( mapCaseIdToListPagGarantia.containsKey(idCaso) ){
                
                List<PagamentoGarantia__c> lstPagGarantiaAux = new List<PagamentoGarantia__c>();
                lstPagGarantiaAux = mapCaseIdToListPagGarantia.get(idCaso);
                
                Case caso = mCaso.get(idCaso);
                for( PagamentoGarantia__c pagGarantia : lstPagGarantiaAux ){
                    
                    //PLV-2341 - Fim - Codigo alterado para atender regra de negocio.
                    if(sMovSinistro.contains(idCaso + '' + pagGarantia.Id)) continue;
                    
                    Integer sequencia;
                    if(mSequenciaMov == null){
                        mSequenciaMov = new Map<Id, Integer>();
                        sequencia = 1;
                    }else if(mSequenciaMov.containsKey(idCaso)){
                        sequencia = mSequenciaMov.get(idCaso) + 1;
                    }else{
                        sequencia = 1;
                    }
                    
                    MovimentoSinistro__c movimentoSin = new MovimentoSinistro__c();
                    movimentoSin.Caso__c = idCaso;
                    movimentoSin.DataMovimento__c = system.now();
                    movimentoSin.TipoMovimento__c = 'Aviso';
                    movimentoSin.DescricaoMovimento__c = '1';
                    movimentoSin.SequenciaMovimento__c = String.valueOf(sequencia);
                    movimentoSin.PagamentoGarantia__c = pagGarantia.Id;
                    movimentoSin.SinistroJudicial__c = caso.Sinistro_Judicial__c;
                    movimentoSin.ValorMovimento__c = pagGarantia.Valor_indenizado__c; //PLV - 4818 - GUSTAVO PEREIRA - SYS4B INICIO/FIM
                    lMovSin2Insert.add(movimentoSin);
                    mSequenciaMov.put(idCaso, sequencia);
                    
                }
            }
        }
         // POR062-1 - FIM
        //PLV-4037 - Fim
        
        if(!lMovSin2Insert.isEmpty()) Database.insert(lMovSin2Insert);
        
    }
    
    //AVX SP 28 - PLV 2296
    public void atualizaRecusadoMovimentoSinistro(List<Case> casos, Map<Id, Case> mCaseOld){
        //PLV-2341 - Início - Codigo alterado para atender regra de negocio.
        //PLV-4037 - Início
        Map<Id, Case> mCaso = new Map<Id, Case>();
        
        for(Case caso: casos){
            
            Case caseOld = mCaseOld.get(caso.Id);
            Boolean isFaseFechado = ( caso.Status == 'Fechado' );
            Boolean isStatusRecusado = ( caso.Status_Dependente__c == 'Recusado' || caso.Status_Dependente__c == 'Cancelado' );
            Boolean isFaseChanged = ( caso.Status != caseOld.Status );
            Boolean isStatusChanged = ( caso.Status_Dependente__c != caseOld.Status_Dependente__c );
            
            if( (isFaseChanged || isStatusChanged) && isFaseFechado  && isStatusRecusado ){
                mCaso.put(caso.Id, caso);
            }
            
        }
        
        if(mCaso.isEmpty()) return;
        Set<Id> sCaso = new Set<Id>();
        
        Recordtype REC_ID_SINISTRO = RecordTypeBO.buscarTipoRegistro('Case', 'Sinistro');
        Recordtype REC_ID_BENEFICIO = RecordTypeBO.buscarTipoRegistro('Case', 'Beneficio');
        
        for(Case caso: mCaso.values()) {
            
            if(caso.RecordTypeId == REC_ID_BENEFICIO.Id && caso.GerarMovimentacaoContabil__c == true) {
                sCaso.add(caso.Id);
            } else if(caso.RecordTypeId == REC_ID_SINISTRO.Id) {
                sCaso.add(caso.Id);
            }
        }
        
        if(sCaso.isEmpty()) return;
        
        Map<Id, List<PagamentoGarantia__c>> mapCaseIdToListPagGarantia = new Map<Id, List<PagamentoGarantia__c>>();
        
        for( PagamentoGarantia__c pagGarantia : [   SELECT  Id, Caso__c
                                                 FROM    PagamentoGarantia__c
                                                 WHERE   Caso__c IN : sCaso 
                                                ]){
                                                    
                                                    List<PagamentoGarantia__c> lstPagGarantiaAux = new List<PagamentoGarantia__c>();
                                                    
                                                    if( mapCaseIdToListPagGarantia.containsKey(pagGarantia.Caso__c) ){
                                                        lstPagGarantiaAux = mapCaseIdToListPagGarantia.get(pagGarantia.Caso__c);
                                                    }
                                                    
                                                    lstPagGarantiaAux.add( pagGarantia );
                                                    
                                                    mapCaseIdToListPagGarantia.put( pagGarantia.Caso__c, lstPagGarantiaAux );
                                                }
        
        Set<String> sMovSinistro = new Set<String>();
        
        for(MovimentoSinistro__c movSinistro : [SELECT Id, Caso__c, PagamentoGarantia__c
                                                FROM MovimentoSinistro__c
                                                WHERE Caso__c IN :sCaso
                                                AND TipoMovimento__c = 'Aviso'
                                                AND DescricaoMovimento__c = '24']){
                                                    sMovSinistro.add(movSinistro.Caso__c + '' + movSinistro.PagamentoGarantia__c);
                                                }
        
        List<MovimentoSinistro__c> lMovSin2Insert = new List<MovimentoSinistro__c>();
        
        Map<Id, Integer> mSequenciaMov = SequenciaMovimentoSinistroHelper.sequenciaMovimentos(sCaso);
        
        for(Id caso : sCaso){
            
            if( mapCaseIdToListPagGarantia.containsKey(caso) ){
                
                List<PagamentoGarantia__c> lstPagGarantiaAux = new List<PagamentoGarantia__c>();
                lstPagGarantiaAux = mapCaseIdToListPagGarantia.get(caso);
                
                for( PagamentoGarantia__c pagGarantia : lstPagGarantiaAux ){
                    
                    //PLV-2341 - Fim - Codigo alterado para atender regra de negocio.
                    if(sMovSinistro.contains(caso + '' + pagGarantia.Id)) continue;
                    
                    
                    Integer sequencia;
                    if(mSequenciaMov == null){
                        mSequenciaMov = new Map<Id, Integer>();
                        sequencia = 1;
                    }else if(mSequenciaMov.containsKey(caso)){
                        sequencia = mSequenciaMov.get(caso) + 1;
                    }else{
                        sequencia = 1;
                    }
                    // PLV-4551 - INICIO
                    /* MovimentoSinistro__c movimentoSin = new MovimentoSinistro__c();
movimentoSin.Caso__c = caso;
movimentoSin.DataMovimento__c = system.now();
movimentoSin.TipoMovimento__c = 'Aviso';
movimentoSin.DescricaoMovimento__c = '24';
movimentoSin.SequenciaMovimento__c = String.valueOf(sequencia);
movimentoSin.PagamentoGarantia__c = pagGarantia.Id;
lMovSin2Insert.add(movimentoSin); */
                    // PLV-4551 - FIM
                    mSequenciaMov.put(caso, sequencia);
                    
                }
            }
        }
        
        //PLV-4037 - Fim
        
        if(!lMovSin2Insert.isEmpty()) Database.insert(lMovSin2Insert);
    }
    
    
    //PLV-2433 - Início - Removido para subir a história de numeração sinistro - aguardando a história voltar
    /* 

//PLV-1096 - Início - Método criado para atender chamada do serviço CIV ODM
public void consultaODM(List<Case> casos, Map<Id, Case> mCaseOld){

Recordtype REC_ID_SINISTRO = RecordTypeBO.buscarTipoRegistro('Case', 'Sinistro');
Boolean processarBatch = false; 

for(Case caso: casos){
if(caso.Status == 'Avisado' && mCaseOld.get(caso.Id).Status != 'Avisado' 
&& caso.Data_sinistro_avisado__c != null && caso.RecordtypeId == REC_ID_SINISTRO.Id){
caso.ProcessaODM__c = true;
processarBatch = true;
}
}

if (!processarBatch) return;

Integer qtdInProcess = [SELECT COUNT()
FROM AsyncApexJob
WHERE Status IN ('Holding','Queued')
AND ApexClass.Name = 'CIVODMBatch'
AND JobType = 'BatchApex'];

// Em teste não pode invocar o Batch porque ele executa na mesma thread dando erro no callout
// O batch sera coberto pelo classe de teste dele
if (qtdInProcess == 0 && !Test.isRunningTest())
Database.executeBatch(new CIVODMBatch(), 5);
}
//PLV-1096 - Fim - Método criado para atender chamada do serviço CIV ODM

*/
    //PLV-2433 - Fim - Removido para subir a história de numeração sinistro - aguardando a história voltar
    
    
    //PLV-2433 - Início - Ajuste Codigo e remoção de debugs    
    public void preenchenumsinistro(List<Case> casos, Map<Id, Case> mCaseOld){
        if(System.isBatch() || System.isFuture()) return;
        Recordtype REC_ID_SINISTRO = RecordTypeBO.buscarTipoRegistro('Case', 'Sinistro');
        Set<Id> sCaso = new Set<Id>();
        for (Case caso: casos){  
            if(caso.Status == 'Avisado' && mCaseOld.get(caso.Id).Status == 'Avisar'){
                sCaso.add(caso.Id);
            }
        }
        List<Case> LstCase = [SELECT Id, Contrato__r.Empresa__c, Contrato__r.RamoSeguro__r.Codigo__c, NumeroSinistro__c, ProcessaNumeroSinistro__c
                              FROM Case
                              WHERE Id =: sCaso];
        
        if(LstCase.isempty()) return;
        
        String empresa;
        String ramo;
        Integer ano;
        Date hoje = system.today();
        
        empresa = LstCase[0].Contrato__r.Empresa__c;
        ramo = LstCase[0].Contrato__r.RamoSeguro__r.Codigo__c;
        ano = hoje.year(); 
        
        for(Case registro : LstCase) {
            if(String.isBlank(registro.NumeroSinistro__c))
            {
                CasoBO.ChamaNumeroSinistro(empresa, ramo, ano, registro.Id);
            }
        }
    }
    

    @future(callout=true)
    public static void ChamaNumeroSinistro(String empresa, String ramo, Integer ano, String idcaso) 
    {
        if(CasoTriggerHandler.isFirstTime)
        {
            CasoTriggerHandler.isFirstTime = false;
            
            String Response;  
            String SJson = '{' + String.format(
                '"empresa":{0},"ramo":{1},"anosinistro":{2}',
                new String []
                {
                    empresa, ramo, String.valueOf(ano)
                }
            ) + '}';
            try{
                if(!Test.isRunningTest())
                {
                    Response = herokuServ.GeraNumeroSinistro(SJson);
                }else{
                    Response = '1.1377.2019.500065';
                }
                
                String numerosinistro = Response.replaceAll('"', '');
                
                String[] sinistrosplit = numerosinistro.split('\\.');
                
                List<Case> lstCaso = [Select Id, Type From Case Where Id =: idcaso];
                
                Case Caso = new Case();
                Caso.id = lstCaso[0].id;
                Caso.NumeroSinistro__c = numerosinistro;
                
                //PLV-4485 - Inicio
                /*if(lstCaso[0].Type == 'Sinistro')
{
Caso.AnoSinistroSplit__c = ano;



Caso.NumeroSinistroSplit__c = Decimal.valueof(sinistrosplit[3]); 
}
else*/ 
                if(lstCaso[0].Type == 'Benefício')
                {
                    Caso.AnoBeneficioSplit__c = ano;
                    Caso.NumeroBeneficioSplit__c = Decimal.valueof(sinistrosplit[3]);
                }
                //PLV-4485 - Fim
                
                Caso.EmpresaSplit__c = Decimal.valueof(empresa);
                Caso.RamoSplit__c = Decimal.valueof(ramo);
                
                update Caso;
            }
            catch(Exception ex){
                System.debug('###### ERROR: (' + ex.getLineNumber() + '): ' + ex.getMessage());
            }  
        }
    }
    //PLV-2433 - Fim - Ajuste Codigo e remoção de debugs    
    
    // PLV-4095 - Remover trecho codigo - INICIO
    // PLV-2015 - FIX - INICIO 
    /*
public void chamaEnvioSinistroBCP(List<Case> sinistros, Map<Id, Case> mSinOld){
if(System.isBatch() || System.isFuture()) return;
if(mSinOld == null) {
List<Id> sinIds = new List<Id>();
for(Case sin : sinistros)    
if(sin.Type == 'Sinistro' && sin.Contrato__c != null)     
sinIds.add(sin.Id);
EnvioSinistroBCP.envioSinistroBCP(sinIds, true);
}
if(mSinOld != null){
List<Id> sinIds = new List<Id>();
for(Case sin : sinistros)
if(sin.Type == 'Sinistro' && sin.Contrato__c != null && sin.Status != mSinOld.get(sin.Id).Status)
sinIds.add(sin.Id);
EnvioSinistroBCP.envioSinistroBCP(sinIds, false);
}
}*/
    // PLV-2015 - FIX - FIM
    // PLV-4095 - Remover trecho codigo - FIM
    
    
    //PLV-4096 - Inicio
    public void integracaoCivSinistro(List<Case> casos, Map<Id, Case> mCaseOld){
        if(System.isBatch() || System.isFuture()) return;
        Recordtype REC_ID_SINISTRO = RecordTypeBO.buscarTipoRegistro('Case', 'Sinistro');
        Set<Id> sCaso = new Set<Id>();
        Set<Id> sCasoPrestadora = new Set<Id>();
        
        //PLV-3916 ajuste para não sobrescrever o NumeroSinistro__c
        for (Case caso: casos){ 
            //PLV-4870 INICIO
            if(caso.NumeroSinistro__c != null){
                continue;
            }
            //PLV-4870 FIM 
            //PLV-4826 - Inicio
            if(mCaseOld != null){
                
                if(caso.Status == 'Avisado' && mCaseOld.get(caso.Id).Status == 'Avisar' ){
                    sCaso.add(caso.Id);
                }
                
                if(caso.Origin == 'Prestadora' && caso.Status == 'Avisado' ){
                    sCasoPrestadora.add(caso.Id);
                }
            }else{
                if(caso.Origin == 'Prestadora' && caso.Status == 'Avisado' ){
                    sCasoPrestadora.add(caso.Id);
                }
            }
        //PLV-4826 - Fim
        }
        
        if(!sCaso.isEmpty()){
            //chamar integração ConsultaCivSinistroTicketBCPIntegracao		    
            if(!test.isRunningTest())
            enviarRequisicaoCIV(sCaso);			//PLV-4826 - Inicio/Fim
        }
        
        //PLV-3918 Alteração para chamar a CriarPagamentoSinistro No avisado - Inicio
        if(!sCasoPrestadora.isEmpty()){
            if(!test.isRunningTest())
                //CriarPagamentoSinistro.inserirPagamentoSinistro(sCasoPrestadora); //PLV-4826 - Inicio/Fim
                enviarRequisicaoCIV(sCasoPrestadora);	//PLV-4826 - Inicio/Fim
        }
        //PLV-3918 Alteração para chamar a CriarPagamentoSinistro No avisado - Fim
        
    }
    //PLV-4096 - Fim
    
    //PLV-3918 Alteração para chamar a CriarPagamentoSinistro No avisado - Inicio
    public void criarPagamentoSinistro(List<Case> casos){
        
        if(System.isBatch() || System.isFuture()) return;
        Recordtype REC_ID_SINISTRO = RecordTypeBO.buscarTipoRegistro('Case', 'Sinistro');
        
        Set<Id> sCasoPrestadora = new Set<Id>();
        
        for (Case caso: casos){              					
            
            if(caso.Origin == 'Prestadora' && caso.Status == 'Avisado' ){
                sCasoPrestadora.add(caso.Id);
            }
        }		
        
        if(!sCasoPrestadora.isEmpty()){
            if(!test.isRunningTest())
                CriarPagamentoSinistro.inserirPagamentoSinistro(sCasoPrestadora);
        }		
        
    }
    //PLV-3918 Alteração para chamar a CriarPagamentoSinistro No avisado - Fim
    
    //PLV-4009 - Codigo removido
    
    //PLV-3918 Alteração para chamar a CriarPagamentoSinistro No avisado - Inicio
    //PLV-3918 - Inicio
    /*public void inserirPagamentoSinistroBO(List<Case> casos, Map<Id, Case> mCaseOld){
if(System.isBatch() || System.isFuture()) return;
Recordtype REC_ID_SINISTRO = RecordTypeBO.buscarTipoRegistro('Case', 'Sinistro');
Set<Id> sCaso = new Set<Id>();

for (Case caso: casos){  
//PLV-4176 - Inicio
if(caso.Status == 'Liquidação' && caso.Origin == 'Prestadora' && mCaseOld.get(caso.Id).Status != 'Liquidação'){
sCaso.add(caso.Id); 
}
//PLV-4176 - Fim
}

if(!sCaso.isEmpty()){
//chamar integração ConsultaCivSinistroTicketBCPIntegracao		    
if(!test.isRunningTest())
CriarPagamentoSinistro.inserirPagamentoSinistro(sCaso);
}
}*/
    //PLV-3918 - Fim
    //PLV-3918 Alteração para chamar a CriarPagamentoSinistro No avisado - Fim
    
    //PLV-4198 - Inicio
    public void fecharGarantiaBeneficiario(List<Case> lstNewCase, Map<Id, Case> mapOldCase){
        Set<Id> setCasosRecusado = new Set<Id>();
        Set<Id> setCasosCancelado = new Set<Id>();
        
        Recordtype REC_ID_SINISTRO = RecordTypeBO.buscarTipoRegistro('Case', 'Sinistro');
        
        for( Case newCase : lstNewCase ){
            
            Case oldCase =  mapOldCase.get(newCase.Id);
            
            Boolean isCasoSinistro = ( newCase.RecordtypeId == REC_ID_SINISTRO.Id );
            Boolean isStatusChanged = ( newCase.Status_Dependente__c != oldCase.Status_Dependente__c );
            Boolean isCasoRecusado = ( newCase.Status_Dependente__c == 'Recusado' );
            Boolean isCasoCancelado = ( newCase.Status_Dependente__c == 'Cancelado' );
            
            if( isCasoSinistro && isStatusChanged ){
                
                if( isCasoRecusado )
                    setCasosRecusado.add(newCase.Id);
                if( isCasoCancelado )
                    setCasosCancelado.add(newCase.Id);
            }
            
        }
        
        if( setCasosRecusado.isEmpty() && setCasosCancelado.isEmpty() )
            return;
        
        //PLV-4198 - FIX 6 - Inicio        
        Map<Id, BeneficiarioGarantia__c> mapBeneficiarioUpdate = new Map<Id, BeneficiarioGarantia__c>();
        Map<Id, PagamentoGarantia__c> mapGarantiaUpdate = new Map<Id, PagamentoGarantia__c>();
        Set<String> setGarantiaId = new Set<String>();
        
        Set<String> setPagamentoFechado = new Set<String>();
        setPagamentoFechado.add('Cancelado');
        setPagamentoFechado.add('Recusado');
        setPagamentoFechado.add('Pago');
        
        
        if( !setCasosCancelado.isEmpty() ){
            
            
            for( PagamentoGarantia__c garantia : [SELECT Id, Name, Fase__c, Status_do_pagamento__c, Caso__c
                                                  FROM    PagamentoGarantia__c 
                                                  WHERE   Status_do_pagamento__c NOT IN : setPagamentoFechado
                                                  AND     Fase__c != 'Fechado'
                                                  AND     Caso__c IN : setCasosCancelado]){
                                                      
                                                      garantia.Fase__c = 'Fechado';
                                                      garantia.Status_do_pagamento__c = 'Cancelado';
                                                      
                                                      mapGarantiaUpdate.put(garantia.Id, garantia);
                                                      setGarantiaId.add(garantia.Id);
                                                  }
        }
        
        if( !setCasosRecusado.isEmpty() ){
            
            for( PagamentoGarantia__c garantia : [SELECT Id, Name, Fase__c, Status_do_pagamento__c, Caso__c
                                                  FROM    PagamentoGarantia__c 
                                                  WHERE   Status_do_pagamento__c NOT IN : setPagamentoFechado
                                                  AND     Fase__c != 'Fechado'
                                                  AND     Caso__c IN : setCasosRecusado]){
                                                      
                                                      garantia.Fase__c = 'Fechado';
                                                      garantia.Status_do_pagamento__c = 'Recusado';
                                                      
                                                      mapGarantiaUpdate.put(garantia.Id, garantia);
                                                      setGarantiaId.add(garantia.Id);
                                                  }
        }
        
        if( !setGarantiaId.isEmpty() ){
            
            for( BeneficiarioGarantia__c beneficiario : [SELECT Id, Name, Status__c, Pagamento_de_garantia__r.Caso__c
                                                         FROM    BeneficiarioGarantia__c 
                                                         WHERE   Status__c NOT IN : setPagamentoFechado
                                                         AND     Pagamento_de_garantia__c IN : setGarantiaId ]){
                                                             
                                                             beneficiario.Status__c = 'Cancelado';
                                                             beneficiario.Observacao__c = 'Cancelado';
                                                             
                                                             mapBeneficiarioUpdate.put(beneficiario.Id, beneficiario);
                                                         }
        }
        
        Map<Id, String> mapCaseIdError = new Map<Id, String>();
        
        if( !mapBeneficiarioUpdate.isEmpty() ){
            
            Database.SaveResult[] srListBeneficiario = Database.update(mapBeneficiarioUpdate.values(), false);
            
            for( Integer i=0; i<srListBeneficiario.size(); i++ ){
                
                // DML operation failed
                if( !srListBeneficiario.get(i).isSuccess() ){
                    
                    Database.Error error = srListBeneficiario.get(i).getErrors().get(0);
                    
                    BeneficiarioGarantia__c beneficiario = mapBeneficiarioUpdate.values().get(i);
                    String msgErro = beneficiario.Name + ': ' + error.getMessage();
                    
                    mapCaseIdError.put( beneficiario.Pagamento_de_garantia__r.Caso__c, msgErro );
                    
                }
                
            }
            
        }
        
        if( !mapGarantiaUpdate.isEmpty() ){
            
            Database.SaveResult[] srListGarantia = Database.update(mapGarantiaUpdate.values(), false);
            
            for( Integer i=0; i<srListGarantia.size(); i++ ){
                
                // DML operation failed
                if( !srListGarantia.get(i).isSuccess() ){
                    
                    Database.Error error = srListGarantia.get(i).getErrors().get(0);
                    
                    PagamentoGarantia__c garantia = mapGarantiaUpdate.values().get(i);
                    String msgErro = garantia.Name + ': ' + error.getMessage();
                    
                    mapCaseIdError.put( garantia.Caso__c, msgErro );
                    
                }
            }
        }
        
        //PLV-4198 - FIX 6 - Fim
        if( !mapCaseIdError.isEmpty() ){
            
            for( Case newCase : lstNewCase ){
                
                if( mapCaseIdError.containsKey(newCase.Id) ){
                    
                    String msgErro = mapCaseIdError.get(newCase.Id);
                    newCase.addError(msgErro);
                    
                }
                
            }
        }
    }
    //PLV-4198 - Fim
    
    //PLV-3916 - Inicio
    //FIX 6 Mudado para Workflow
    /*public void enviaAvisoSinistro(List<Case> casos, Map<Id, Case> mCaseOld){

if(System.isBatch() || System.isFuture()) return;
Recordtype REC_ID_SINISTRO = RecordTypeBO.buscarTipoRegistro('Case', 'Sinistro');
Set<Id> sCaso = new Set<Id>();
Set<Id> sContrato = new Set<Id>();
Map<Id, Case> mCaso = new Map<Id, Case>(); 
Set<Id> sAccount = new Set<Id>();

for (Case caso: casos){  
//fix 5 - ajuste de mudança de status
if((caso.Status == 'Avisado' && mCaseOld.get(caso.Id).Status == 'Avisar') || (caso.Status == 'Liquidação' && mCaseOld.get(caso.Id).Status != 'Liquidação'))
{               
sCaso.add(caso.Id);
mCaso.put(caso.Id, caso);
sContrato.add(caso.Contrato__c);
sAccount.add(caso.AccountId);
}
}

if(!sCaso.isEmpty()){

List<Messaging.SingleEmailMessage> allMessageList = new List<Messaging.SingleEmailMessage>();
Map<Id, FavorecidoRemuneracaoContrato__c> mFavRemunCont = dao.buscarCorretores(sContrato);
String emailCorretor;
EmailTemplate templateContato   = [Select id,body,Subject from EmailTemplate where name = 'Caso:Aviso de Sinistro - Contato'];
EmailTemplate templateCorretor  = [Select id,body,Subject from EmailTemplate where name = 'Caso:Aviso de Sinistro - Corretor'];
List<Case> caseToUpdList        = new List<Case>();
Id contactId;
Map<Id, List<Contact>> contactMap   = new Map<Id, List<Contact>>();
//FIX 1            
OrgWideEmailAddress[] owea 			= [select Id from OrgWideEmailAddress where Address = 'sinistro.vida@portoseguro.com.br'];

for(Contact a : [Select Id, AccountId From Contact Where AccountId in :sAccount])
{
contactMap.put(a.AccountId, new List<Contact>());
contactMap.get(a.AccountId).add(a);
}

for(Case caso: mCaso.values()) {
contactId = null;

if (contactMap.containsKey(caso.AccountId))
{
for (Contact c : contactMap.get(caso.AccountId))
{
if(caso.AccountId == c.AccountId)
{
contactId = c.Id;
}
}
}

//FIX 1 - 
//FIX 3  - exceção quando não tiver número de sinistro
if (caso.Contrato__c != null && mFavRemunCont.containsKey(caso.Contrato__c) && contactId != null && owea.size() > 0 && caso.NumeroSinistro__c != null){

FavorecidoRemuneracaoContrato__c vFavRemCont = mFavRemunCont.get(caso.Contrato__c);
List<string> toadd = new List<string>();

if(vFavRemCont.DadosCorretor__r.NomeCorretor__r.Email__c == null){
emailCorretor = vFavRemCont.DadosCorretor__r.NomeCorretor__r.PersonEmail;
}else{
emailCorretor = vFavRemCont.DadosCorretor__r.NomeCorretor__r.Email__c;
}
toadd.add(emailCorretor);

if(templateCorretor == null) continue;

//FIX 5 - ajuste de envio de emails
if( caso.Origin == 'Prestadora' && (caso.Status == 'Liquidação' && mCaseOld.get(caso.Id).Status != 'Liquidação')){
Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();                    
mail.setToAddresses(toadd);
mail.setTargetObjectId(contactId);
mail.setTemplateID(templateCorretor.Id); 
mail.setWhatId(caso.Id);
mail.setOrgWideEmailAddressId(owea.get(0).Id);
allMessageList.add(mail);                        
}

//FIX 5 - ajuste de envio de emails	
if(caso.Origin != 'Prestadora' && (caso.Status == 'Avisado' && mCaseOld.get(caso.Id).Status == 'Avisar')){
Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();                    
mail.setToAddresses(toadd);
mail.setTargetObjectId(contactId);
mail.setTemplateID(templateCorretor.Id); 
mail.setWhatId(caso.Id);
mail.setOrgWideEmailAddressId(owea.get(0).Id);
allMessageList.add(mail);                        

if(templateContato == null) continue;
List<string> toadd2 = new List<string>();
toadd2.add(caso.Account.PersonEmail);
Messaging.SingleEmailMessage mail2 = new Messaging.SingleEmailMessage();                    
mail2.setToAddresses(toadd2);
mail.setTargetObjectId(contactId);
mail2.setTemplateID(templateContato.Id); 
mail2.setWhatId(caso.Id);
mail2.setOrgWideEmailAddressId(owea.get(0).Id);
allMessageList.add(mail2);
}

caseToUpdList.add(caso);
}

}

if(allMessageList.size() > 0){
Messaging.sendEmail(allMessageList,false);
}
}

}*/
    //PLV-3916 - Fim   
    
    //PLV-4516 INICIO
    
    public void enviarSinistroEmRegulacaoODM(List<Case> sinistrosNew, Map<Id, Case> sinistrosOldMap) {
        if(System.isBatch()) return;
        
        if(CasoTriggerHandler.isFirstTime) {
            Set<Id> sinistrosIds = new Set<Id>();
            
            if (this.sinistroRecordType == null) {
                this.sinistroRecordType = RecordTypeBO.buscarTipoRegistro('Case', 'Sinistro');
            }
            
            for (Case sinistro : sinistrosNew) {
                
                if (sinistro.RecordTypeId == sinistroRecordType.Id 
                    && sinistro.Status == 'Em Regulação' 
                    && (sinistrosOldMap == null || sinistro.Status != sinistrosOldMap.get(sinistro.Id).Status)) {
                        sinistrosIds.add(sinistro.Id);
                    }
            }
            
            if (sinistrosIds.size() > 0) { 
                RegulacaoSinistro.enviarSinistrosParaRegulacao(sinistrosIds);
            }
        }
    }
    
    //PLV-4516 FIM
    
    //PLV-4560 - Inicio
    public void preencherBeneficiariosSinistro2(List<Case> triggerNew) {
        Boolean                                         prosseguir          =   false;
        Boolean                                         prosseguirNoTest    =   false;
        Boolean                                         possuiBene          =   true;
        Set<ID>                                         stCaseId            =   new Set<id>();
        Set<ID>                                         stGarantiaSinistro  =   new Set<id>();
        Set<ID>                                         stAccountId         =   new Set<id>();
        Set<ID>                                         stSeguradoContrato  =   new Set<id>();
        Map<Id,Id>                                      mpContaEndereco     =   new Map<Id,Id>();
        List<BeneficiarioGarantia__c>                   ltInsertBeneFinal   =   new List<BeneficiarioGarantia__c>();
        Map<Id, Boolean>                                mapGarantiaBene     =   new Map<Id, Boolean>();
        Map<Id, List<BeneficiarioSeguradoContrato__c>>  mapCasoBeneficiario =   new Map<Id, List<BeneficiarioSeguradoContrato__c>>();
        
        //PLV-4560 - Separa os ids dos casos de sinistros e os segurados de contrato, ambos serão usados em 
        //           query a seguir.
        //PLV-4870 - Inicio
        List<Case> allCases = [ SELECT  Segurado_do_contrato__c, Account.FirstName, Valor_Indenizado__c, Garantia_do_segurado_do_contrato__r.GarantiaProduto__r.TipoBeneficiario__c,
                               Garantia_do_segurado_do_contrato__c, Segurado_do_contrato__r.Conta__c, Garantia_do_segurado_do_contrato__r.GarantiaProduto__c, Criado_por_Servico__c,
                               (SELECT Id, Name, Garantia_do_segurado_do_contrato__r.GarantiaProduto__r.TipoBeneficiario__c, ValorIndenizadoInicial__c
                                FROM   Pagamentos_de_garantia__r)
                               FROM    Case
                               WHERE   ID in: triggerNew
                               AND     RecordTypeid =: RECORDTYPE_CASE_SINISTRO.Id];

        for(Case caseVerificador : allCases){
            if(caseVerificador.Criado_por_Servico__c){
                continue;
            }
            //PLV-4870 - Fim
            stCaseId.add(caseVerificador.Id);
            stSeguradoContrato.add(caseVerificador.Segurado_do_contrato__c);
            if(caseVerificador.Account.FirstName == 'SillasTest'){
                prosseguirNoTest = true;
            }
            if(caseVerificador.Pagamentos_de_garantia__r != null){
                prosseguir = true;
                for(PagamentoGarantia__c pagGarantiaLoop : caseVerificador.Pagamentos_de_garantia__r){
                    stGarantiaSinistro.add(pagGarantiaLoop.Id);
                }
                
            }
        }
        if(!Test.isRunningTest() || (Test.isRunningTest() && prosseguirNoTest)){
            for(PagamentoGarantia__c pagGarantiaLoop: [SELECT   ID,
                                                       (SELECT ID FROM Beneficiarios_Garantia__r)
                                                       FROM PagamentoGarantia__c
                                                       WHERE ID IN: stGarantiaSinistro]){
                                                           if(!pagGarantiaLoop.Beneficiarios_Garantia__r.isEmpty()){                                           
                                                               mapGarantiaBene.put(pagGarantiaLoop.ID, true);
                                                           }else{
                                                               possuiBene = false;
                                                               mapGarantiaBene.put(pagGarantiaLoop.ID, false);
                                                           }
                                                       }
            
            if(prosseguir == true && possuiBene == false){
                
                //PLV-4560 - Separa os Beneficiarios do Seguro que serão inseridos em Beneficiario da Garantia
                for(SeguradoContrato__c lsSegurCtr : [SELECT Id, GrupoContrato__r.ContratanteContrato__r.Contrato__c,
                                                      (SELECT Id, Conta__c, Participacao__c, SeguradoContrato__c, TipoBeneficiario__c, GrauParentesco__c, Nome__c, Data_de_Nascimento__c //PLV-4988-INICIO/FIM
                                                       FROM Benefici_rios_dos_segurados_do_contrato__r
                                                       WHERE TipoBeneficiario__c != : TIPO_BENEFICIARIO_SEGURADO_HENDEIRO)
                                                      FROM SeguradoContrato__c 
                                                      WHERE ID IN :stSeguradoContrato])
                {
                    
                    for(BeneficiarioSeguradoContrato__c beneficiarioContrato : lsSegurCtr.Benefici_rios_dos_segurados_do_contrato__r){
                        stAccountId.add(beneficiarioContrato.Conta__c);
                        if(mapCasoBeneficiario.get(beneficiarioContrato.SeguradoContrato__c) == null){
                            mapCasoBeneficiario.put(beneficiarioContrato.SeguradoContrato__c, new List<BeneficiarioSeguradoContrato__c>{beneficiarioContrato});
                        }else{
                            List<BeneficiarioSeguradoContrato__c> ltBen = mapCasoBeneficiario.get(beneficiarioContrato.SeguradoContrato__c);
                            ltBen.add(beneficiarioContrato);
                            mapCasoBeneficiario.put(beneficiarioContrato.SeguradoContrato__c, ltBen);
                        }
                    }
                }
                
                //PLV-4560 - De acordo com os valores das contas dentro do caso, separa o endereço das contas pelo mais atual
                if(! stAccountId.isEmpty()){
                    for(Endereco__c enderecoAccount : [SELECT Id, Conta__c, MaisAtual__c FROM Endereco__c WHERE Conta__c In: stAccountId AND MaisAtual__c = true]){
                        mpContaEndereco.put(enderecoAccount.Conta__c, enderecoAccount.Id);
                    }
                }
                
                //PLV-4560 - Analisa o tpo de beneficiario através de: Caso ->  Pagamento Garantia -> Garantia segurado do Contrato -> Garantia do Produto
                //           após identificar o tipo do beneficiario, insere em Garantia do seguro(PagamentoGarantia__c), os beneficiarios.
                for(Case casoLoop : allCases){
                    if(casoLoop.Pagamentos_de_garantia__r != null){
                        for(PagamentoGarantia__c pagGarantiaLoop : casoLoop.Pagamentos_de_garantia__r){
                            if(pagGarantiaLoop.Garantia_do_segurado_do_contrato__r.GarantiaProduto__r.TipoBeneficiario__c != null){ 
                                String tiposBeneficiarios = pagGarantiaLoop.Garantia_do_segurado_do_contrato__r.GarantiaProduto__r.TipoBeneficiario__c;
                                
                                if(tiposBeneficiarios.containsIgnoreCase(TIPO_BENEFICIARIO_SEGURADO) ){
                                    BeneficiarioGarantia__c novoBeneficiarioSinistro    	=   new BeneficiarioGarantia__c();
                                    novoBeneficiarioSinistro.Pagamento_de_garantia__c  		=   pagGarantiaLoop.Id;
                                    novoBeneficiarioSinistro.conta__c                   	=   casoLoop.Segurado_do_contrato__r.Conta__c;
                                    novoBeneficiarioSinistro.ValorIndenizacao__c			= 	pagGarantiaLoop.ValorIndenizadoInicial__c;
                                    novoBeneficiarioSinistro.Percentual_de_indenizacao__c	=	Decimal.valueOf(100);
                                    novoBeneficiarioSinistro.Endereco__c                	=   mpContaEndereco.get(casoLoop.Segurado_do_contrato__r.Conta__c) != null ? mpContaEndereco.get(casoLoop.Segurado_do_contrato__r.Conta__c) : null;
                                    if(novoBeneficiarioSinistro.Pagamento_de_garantia__c  != null && mapGarantiaBene.get(pagGarantiaLoop.Id) == false){
                                        ltInsertBeneFinal.add(novoBeneficiarioSinistro);
                                    }
                                        
                                }else if(!tiposBeneficiarios.containsIgnoreCase(TIPO_BENEFICIARIO_SEGURADO) && tiposBeneficiarios != '' && !tiposBeneficiarios.containsOnly(TIPO_BENEFICIARIO_HENDEIRO) ){                                
                                    List<BeneficiarioSeguradoContrato__c> ltBeneficiarios= mapCasoBeneficiario.get(casoLoop.Segurado_do_contrato__c);
                                    if(ltBeneficiarios != null){
                                        if(! ltBeneficiarios.isEmpty()){
                                            for(BeneficiarioSeguradoContrato__c beneficiariosLoop : ltBeneficiarios){
                                                if(beneficiariosLoop.TipoBeneficiario__c != TIPO_BENEFICIARIO_SEGURADO_HENDEIRO){
                                                    BeneficiarioGarantia__c novoBeneficiarioSinistro        =   new BeneficiarioGarantia__c();
                                                    novoBeneficiarioSinistro.Pagamento_de_garantia__c  		=   pagGarantiaLoop.Id;
                                                    novoBeneficiarioSinistro.Status__c                      =   STATUS_PENDENTE;
                                                    novoBeneficiarioSinistro.RelacionamentoSegurado__c      =   beneficiariosLoop.GrauParentesco__c;
                                                    novoBeneficiarioSinistro.ValorIndenizacao__c			= 	(pagGarantiaLoop.ValorIndenizadoInicial__c != null && pagGarantiaLoop.ValorIndenizadoInicial__c > 0) ? pagGarantiaLoop.ValorIndenizadoInicial__c / ltBeneficiarios.size() : 0;
                                                    //novoBeneficiarioSinistro.ValorIndenizacao__c			=	pagGarantiaLoop.ValorIndenizadoInicial__c / ltBeneficiarios.size();
                                                    novoBeneficiarioSinistro.conta__c                       =   beneficiariosLoop.conta__c;
                                                    novoBeneficiarioSinistro.Percentual_de_indenizacao__c   =   beneficiariosLoop.participacao__c;
                                                    novoBeneficiarioSinistro.Endereco__c                    =   mpContaEndereco.get(beneficiariosLoop.conta__c) != null ? mpContaEndereco.get(beneficiariosLoop.conta__c) : null;
                                                    novoBeneficiarioSinistro.NomeBeneficiario__c	        =   beneficiariosLoop.Nome__c; //PLV-4988-INICIO/FIM
                                                    novoBeneficiarioSinistro.DataNascimento__c	            =   beneficiariosLoop.Data_de_Nascimento__c; //PLV-4988-INICIO/FIM
                                                    if(novoBeneficiarioSinistro.Pagamento_de_garantia__c  != null && mapGarantiaBene.get(pagGarantiaLoop.Id) == false){
                                                        ltInsertBeneFinal.add(novoBeneficiarioSinistro);
                                                    }
                                                }
                                            }   
                                        }
                                    }
                                }else if(tiposBeneficiarios.containsIgnoreCase(TIPO_BENEFICIARIO_HENDEIRO)){
                                    break;
                                }
                            }
                        }   
                    }  
                }
                if(!ltInsertBeneFinal.isEmpty()){
                    CasoTriggerHandler.beneCriado = true;
                    insert ltInsertBeneFinal;
                }
            }
        }
    }
    
    //PLV-4560 - Fim

    //PLV-4707 - Inicio
    public void realizarEndossoAutomatico(List<Case> triggerNew, Map<Id, Case> MapTriggerOld){
        List<Case> casosFiltrados = new List<Case>();

        for(Case loopCaseTriggerNew : triggerNew){
            //4707 - Mudança de Status para avisado
            if( loopCaseTriggerNew.Status != MapTriggerOld.get(loopCaseTriggerNew.Id).Status && 
                loopCaseTriggerNew.Status == STATUS_CASE_AVISADO){
                casosFiltrados.add(loopCaseTriggerNew);

            //4707 - Cancelamento por Fraude
            }else if(loopCaseTriggerNew.Status != MapTriggerOld.get(loopCaseTriggerNew.Id).Status &&
                     loopCaseTriggerNew.Motivos_de_recusa__c == MOTIVO_RECUSA_CASE_FRAUDE &&
                     loopCaseTriggerNew.Status == STATUS_CASE_FECHADO &&
                     loopCaseTriggerNew.Status_Dependente__c == STATUS_DEPENDENTE_CASE_RECUSADO){
                casosFiltrados.add(loopCaseTriggerNew);
            }
            
        }
        if(! casosFiltrados.isEmpty() ){
            List<Case> allCases = [ SELECT  Segurado_do_contrato__c, Account.FirstName, Valor_Indenizado__c, Segurado_do_contrato__r.VigenciaInicial__c, 
                                            Garantia_do_segurado_do_contrato__r.GarantiaProduto__r.TipoBeneficiario__c, Segurado_do_contrato__r.VigenciaFinal__c, 
                                            Garantia_do_segurado_do_contrato__c, Segurado_do_contrato__r.Conta__c, Garantia_do_segurado_do_contrato__r.GarantiaProduto__c, 
                                            Data_sinistro_avisado__c, Dataocorrencia__c, Contrato__c, Motivos_de_recusa__c, Status_Dependente__c,
                                            (SELECT Id, Name, Garantia_do_segurado_do_contrato__r.GarantiaProduto__r.CancelaSegurado__c 
                                            FROM Pagamentos_de_garantia__r) 
                                    FROM    Case
                                    WHERE   ID in: casosFiltrados
                                    AND     RecordTypeid =: RECORDTYPE_CASE_SINISTRO.Id];

            for(Case casoLoop : allCases){
                if( casoLoop.Pagamentos_de_garantia__r != null && 
                    casoLoop.Segurado_do_contrato__r.VigenciaInicial__c <= casoLoop.Dataocorrencia__c &&
                    casoLoop.Segurado_do_contrato__r.VigenciaFinal__c >= casoLoop.Dataocorrencia__c){
                    for(PagamentoGarantia__c pagGarantiaLoop : casoLoop.Pagamentos_de_garantia__r){
                        if(pagGarantiaLoop.Garantia_do_segurado_do_contrato__r.GarantiaProduto__r.CancelaSegurado__c){
                            chamarCIVCancelamento(casoLoop.Contrato__c, casoLoop.Dataocorrencia__c);
                        }
                    }
                }

                if( casoLoop.Segurado_do_contrato__r.VigenciaInicial__c <= casoLoop.Dataocorrencia__c &&
                    casoLoop.Segurado_do_contrato__r.VigenciaFinal__c >= casoLoop.Dataocorrencia__c &&
                    casoLoop.Motivos_de_recusa__c == MOTIVO_RECUSA_CASE_FRAUDE){
                        chamarCIVCancelamento(casoLoop.Contrato__c, casoLoop.Dataocorrencia__c);
                    }
            }
        }
    }

    @future(callout=true)
    public static void chamarCIVCancelamento(Id idContrato, date dataOcorrencia){
        cancelarContratoSelecionado(idContrato, ENDOSSO_CONTRACT_SIN, dataOcorrencia);
    }

    public static void cancelarContratoSelecionado(Id idContrato, String tipoEndosso, date dataOcorrencia){ 
		ServiceTO.ParamOrcamentoCalculoTO param = new ServiceTO.ParamOrcamentoCalculoTO();
        ServiceTO.OrcamentoCalculoTO orcamento  = new ServiceTO.OrcamentoCalculoTO();
        ContractDAO contractDAO                 = ContractDAO.getInstance();	
        Contract contrato                       = contractDAO.buscarContratoById(idContrato);		
        
		if(contrato.Status != 'Cancelado') {
			orcamento.empresa               = contrato.Empresa__c;
			orcamento.sucursal              = contrato.Sucursal__c;
			orcamento.ramo                  = contrato.RamoSeguro__r.Codigo__c;
            orcamento.apolice               = contrato.NumeroApolice__c;
            orcamento.segmento              = contrato.Segmento__c;
			orcamento.tipoSeguro            = 'CAN';
			orcamento.tipoEndosso           = tipoEndosso;
			orcamento.dataCalculo           = dataOcorrencia;
			orcamento.vigenciaInicial       = contrato.StartDate;
			orcamento.meioComercializacao   = contrato.MeioComercializacao__c;
			           
			param.orcamento = orcamento;
			try{
				ServiceTO.DataCancelamentoTO retornoCalculo = CIVServices.getInstance().calculoOrcamentoOferta(param); //MGRC-1657 - INICIO/FIM
                if(! retornoCalculo.data.ofertas.isEmpty()){
                    for(ServiceTO.OrcamentoCancelamentoTO orcamentoLoop : retornoCalculo.data.ofertas){
                        BotaoCancelarContratoController.gerarPropostaEndosso(Integer.valueOf(orcamentoLoop.orcamento.numeroOrcamento), idContrato, dataOcorrencia);
                   
                    }
                }
                
			} catch(Exception e){
                System.debug('4707 ERRO:' + e.getLineNumber() + ': ' + e.getMessage());
                
			}
		}
	}

    //PLV-4707 - Fim

    //PLV-4535 - INICIO
	//PLV-4535 - FIX 6 INICIO
    public void atualizaPrazoSusep(List<Case> casesNew, Map<Id, Case> mapCasesOld){
        
        if(String.ValueOf(casesNew[0].DataDocumentacaoCompleta__c) != '' && casesNew[0].DataDocumentacaoCompleta__c != null && casesNew[0].DataDocumentacaoCompleta__c >= casesNew[0].Dataocorrencia__c){//PLV-4535 - FIX 6 INICIO/FIM //PLV-4892-INICIO-FIM-FIX06
            List<Case> listCase = new List<Case>();
            List<Id> idsCase = new List<Id>();
            Map<Id, CaseMilestone> mapMarcos = new Map<Id, CaseMilestone>();
            List<CaseMilestone> listMarcos = new List<CaseMilestone>();
            
            for(Case cs : casesNew){
                idsCase.add(cs.id);
            }
            //MilestoneType marcoTipo = [SELECT id FROM MilestoneType WHERE name = 'Prazo Susep' LIMIT 1];
            
            List<CaseMilestone> listMarcosTemp = [SELECT Id, CaseId FROM CaseMilestone WHERE CaseId IN :idsCase AND MilestoneType.Name = 'Prazo Susep' AND IsCompleted = false];
            
            for(CaseMilestone marco : listMarcosTemp){
                mapMarcos.put(marco.CaseId, marco);
            }
           
            for(Case caseNew : casesNew){
                Case caseOld = (mapCasesOld) != null ? mapCasesOld.get(caseNew.id) : null;
                
                if(String.ValueOf(caseOld.DataDocumentacaoCompleta__c) != '' && caseNew.DataDocumentacaoCompleta__c != null && caseNew.DataDocumentacaoCompleta__c >= caseNew.Dataocorrencia__c){ //PLV - 4535 - FIX 5 //PLV-4892-INICIO-FIM-FIX06
                    CaseMilestone marco = mapMarcos.get(caseNew.Id);
                    if(marco != null){
                    //PLV-4535 - FIX 7 INICIO

                    //PLV-4892-INICIO-FIX06
                    Date dataDocumento = caseNew.DataDocumentacaoCompleta__c.addDays(1);
                    Integer dia = dataDocumento.day();
                    Integer mes = dataDocumento.month();
                    Integer ano = dataDocumento.year();
                    DateTime novaDataHora = (DateTime) dataDocumento;
                    DateTime novaDataHoraRegra = (DateTime) caseNew.DataDocumentacaoCompleta__c;
                    
                    novaDataHoraRegra = novaDataHoraRegra.addHours(3); 
                    novaDataHora = novaDataHora.addHours(3);
                    System.debug('novaDataHora: '+ novaDataHora);
                    
                    String diaSemana = novaDataHora.format('EEEEE');
                    System.debug('diaSemana: '+ diaSemana);
                    String diaSemanaRegra = novaDataHoraRegra.format('EEEEE');

                    if(diaSemanaRegra != 'Thursday') {
                        if(diaSemana == 'Friday'){
                            dia = dataDocumento.addDays(3).day();
                            system.debug('dia: '+dia);
                        } else if(diaSemana == 'Saturday'){
                            dia = dataDocumento.addDays(2).day();
                        } else if(diaSemana == 'Sunday'){
                            dia = dataDocumento.addDays(1).day();
                        }
                    }    
                    //PLV-4892-FIM-FIX06
                    
                    DateTime novaData = DateTime.newInstance(ano, mes, dia, 00, 00, 00);
                    marco.StartDate = novaData;
                    listMarcos.add(marco);
                    //PLV-4535 - FIX 7 FIM
                    }
                }
            }
            if(!listMarcos.isEmpty()){
                update listMarcos;
            }
        }
    }
    //PLV-4535 - FIM
	//PLV-4535 - FIX 6 FIM
    
    //PLV-4826 - Inicio
    @future(Callout=true) 
    public static void enviarRequisicaoCIV(Set<Id> listIds){
        SensediaServices.getInstance().ConsultaCivSinistroTicketBCPIntegracao(listIds);//MGRC-1259 - INICIO/FIM
    }
    //PLV-4826 - Fim

    // POR062-1 - INICIO /* Obs: Deletar o método gerarMovimentoJuridico desta classe(CasoBO). Não será mais usado. */
    public List<Case> recuperarCasosAdministrativos(List<Case> casos) {
        List<Case> casosAdministrativos = new List<Case>();
        for(Case caso : casos) {
            if(!caso.Sinistro_Judicial__c) { casosAdministrativos.add(caso); }
        }
        return casosAdministrativos;
    }

    // LECVPV-140-FIX02 INICIO
    public List<Case> recuperarCasosJuridicos(List<Case> casos) {
        List<Case> casosJuridicos = new List<Case>();
        for(Case caso : casos) {
            if(caso.Sinistro_Judicial__c) { casosJuridicos.add(caso); }
        }
        return casosJuridicos;
    }
    // LECVPV-140-FIX02 FIM

    // LECVPV-140-FIX02 INICIO
    public List<MovimentoSinistro__c> gerarMovimentosEncerramento(List<Case> casos) { 
        List<MovimentoSinistro__c> novosMovimentos = new List<MovimentoSinistro__c>();
        List<Case> casosAdministrativos = this.recuperarCasosAdministrativos(casos);
        List<Case> casosJuridicos = this.recuperarCasosJuridicos(casos);
        if(!casosAdministrativos.isEmpty())
        {
            Set<Id> idCasos = Util.recuperarIdsPorCampoDeSObject(casosAdministrativos, Schema.Case.Id);
            List<MovimentoSinistro__c> movimentos = MovimentoSinistroDAO.getInstance().buscarPorIdCaso(idCasos);
            Map<Id, List<MovimentoSinistro__c>> movimentosPorIdCaso = MovimentoSinistroBO.getInstance().mapearListaMovimentosPorIdCaso(
                movimentos
            );
            for(Case caso : casosAdministrativos)
            {
                List<MovimentoSinistro__c> movimentosDoCaso = movimentosPorIdCaso.get(caso.Id);
                if(movimentosDoCaso != null)
                {
                    novosMovimentos.addAll(
                        MovimentoSinistroBO.getInstance().criarMovimentoFechamento(caso.Id, movimentosDoCaso,false,true) // LECVPV-216 INICIO/FIM
                    );
                }
            }
        }
        if(!casosJuridicos.isEmpty())
        {
            Set<Id> idCasos = Util.recuperarIdsPorCampoDeSObject(casosJuridicos, Schema.Case.Id);
            List<MovimentoSinistro__c> movimentos = MovimentoSinistroDAO.getInstance().buscarPorIdCaso(idCasos);
            Map<Id, List<MovimentoSinistro__c>> movimentosPorIdCaso = MovimentoSinistroBO.getInstance().mapearListaMovimentosPorIdCaso(
                movimentos
            );
            for(Case caso : casosJuridicos)
            {
                List<MovimentoSinistro__c> movimentosDoCaso = movimentosPorIdCaso.get(caso.Id);
                if(movimentosDoCaso != null)
                {
                    novosMovimentos.addAll(
                        MovimentoSinistroBO.getInstance().criarMovimentoFechamento(caso.Id, movimentosDoCaso, true,false) // LECVPV-216 INICIO/FIM
                    );
                }
            }
        }
        return novosMovimentos;
    }
    // LECVPV-140-FIX02 FIM
    // POR062-1 - FIM
    //LECVP-317 - INICIO
    public void obrigarPreenchimentoAssistCard(List<Case> casoAssist, Map<Id, Case> mapCasoAssistOld){

        String cobertura = 'DMHO';
        String codigoRamo = '1369';
        Boolean devePreencPagtoAssit = false;

        Case casoTrigger = new Case();
        Case casoOldTrigger = new Case();
        casoTrigger = casoAssist[0];

        casoOldTrigger = ((List<Case>)mapCasoAssistOld.values())[0];        

            if(casoOldTrigger.Status == 'Avisar' || casoTrigger.Status == 'Avisar'){
        
                List<PagamentoGarantia__c> pgtoGar = CasoDAO.getInstance().buscarPgtoGarCasoSinCobCodRamo(new Set<Id>{casoTrigger.Id}, cobertura, codigoRamo);
                
                if(!pgtoGar.isEmpty()){
                    Case caso = CasoDAO.getInstance().getCaseBySetId(new Set<Id>{casoTrigger.Id})[0];
                    Case casoTela = new Case();

                    if(Trigger.newMap != null){
                        casoTela = ((Case)Trigger.newMap.get(casoTrigger.Id));
                    }

                    if(caso.Contrato__r.TipoViagem__c == 'Internacional'){

                        if(Trigger.newMap != null && Trigger.isAfter){

                            verificarPagtoAssistCardInterncnl(casoAssist, casoTela);

                            if(casoTela.PagtoAssistCardInternacional__c == 'Sim'){
                                adicionarMensagemErro(casoAssist, casoTela);
                            }
                            
                        }else if(Test.isRunningTest()){
                            verificarPagtoAssistCardInterncnl(casoAssist, casoTela);

                            if(casoTela.PagtoAssistCardInternacional__c == 'Sim'){
                                adicionarMensagemErro(casoAssist, casoTela);
                            }
                        }         
                    }
                }
            }
    }

    public void adicionarMensagemErro(List<Case> casoAssist, Case casoTela){

        if(casoTela.Data_pagamento__c == null){
            casoAssist[0].Data_pagamento__c.addError('Escolha uma data.');
        }
        if(casoTela.Invoice__c == null || casoTela.Invoice__c == ''){
            casoAssist[0].Invoice__c.addError('Preencha o campo.');
        }
    }

    public void verificarPagtoAssistCardInterncnl(List<Case> casoAssist, Case casoTela){

        if(casoTela.PagtoAssistCardInternacional__c == null){
            casoAssist[0].PagtoAssistCardInternacional__c.addError('Favor escolha uma opção.');
        }
    }

    //LECVP-317 - FIM
}