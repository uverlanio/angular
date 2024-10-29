/**
 * CasoWizardController 
 * @author GFS @ 08/03/2018
 **/
public class CasoWizardController {

  @AuraEnabled
  public static List<String> validarpreenchimento(String recordId) {

      List<String> retorno = new List<String>();
      
      List<Case> lstCaso = [Select Id, Dataocorrencia__c, Type, Vitima__c 
                            From Case 
                            Where Id =: recordId
                            Order by Id ASC
                            limit 1];

      if(lstCaso.size() == 0){
          retorno.add('nulo');  
          return retorno;
      }
      
      
      if(lstCaso[0].Dataocorrencia__c == null)
      {
          retorno.add('Data de ocorrência não informada.');
      } 
      if(lstCaso[0].Type == null || lstCaso[0].Type == '')
      {
          retorno.add('Tipo de Caso não informado.');
      }
      if(lstCaso[0].Vitima__c == null || lstCaso[0].Vitima__c == '')
      {
          retorno.add('Vítima não informada');
      }
      if(lstCaso[0].Vitima__c != null && lstCaso[0].Type != null && lstCaso[0].Dataocorrencia__c != null )
      {
          retorno.add('Todos os campos foram preenchidos');
      }
       
      return retorno;
  }

  //PLV-3777 - INICIO
  //Codigo removido por conta de Fix da historia PLV-3777
  
  @AuraEnabled
  public static String pesquisacontratos(String recordId, String tipoEvento) {
    retornoTO objToReturn = new retornoTO();//PLV-4938
      system.debug('>>> Entrou no pesquisacontratos' );
    //PLV-4413 - INICIO
    system.debug('recordId'+recordId);
    Case caso = [SELECT AccountId, Account.Name, Dataocorrencia__c FROM Case WHERE Id = :recordId LIMIT 1];
    
    //PLV-4434 - INICIO
    List<SeguradoContrato__c> lsSegurCtr = [SELECT Id,GrupoContrato__r.ContratanteContrato__r.Contrato__c,
                                            VigenciaInicial__c, VigenciaFinal__c, 
                                            GrupoContrato__r.ContratanteContrato__r.Contrato__r.Tipo__c,
                                            GrupoContrato__r.ContratanteContrato__r.Contrato__r.empresa__c,
                                            GrupoContrato__r.ContratanteContrato__r.Contrato__r.sucursal__c,
                                            GrupoContrato__r.ContratanteContrato__r.Contrato__r.codigoRamo__c,
                                            GrupoContrato__r.ContratanteContrato__r.Contrato__r.NumeroApolice__c,
                                            GrupoContrato__r.ContratanteContrato__r.Contrato__r.Endosso__c
                                            FROM SeguradoContrato__c
                                            WHERE Conta__c = :caso.AccountId
                                            AND GrupoContrato__r.ContratanteContrato__r.Contrato__r.NumeroApolice__c != NULL];	
    //PLV-4434 - FIM
    System.debug('lsSegurCtr total'+lsSegurCtr.size());
    System.debug('lsSegurCtr: ' + lsSegurCtr);
    //PLV-4938 - INICIO
    if(lsSegurCtr.isEmpty()){
      objToReturn.retorno = 'Sem segurado';
      return JSON.serialize(objToReturn);
    }
    //PLV-4938 - FIM                                
    //PLV-3904 - INICIO - PEDRO AUGUSTO - SYS4B
    Map<Id,SeguradoContrato__c> mapSegurCtr = new Map<Id,SeguradoContrato__c>();
    Set<Id> Iniciados= new Set<Id>();
    Set<Id> NaoIniciados= new Set<Id>();
      
    //PLV-4434 - INICIO
    Map<String,SeguradoContrato__c> mEndosoContrato = new Map<String,SeguradoContrato__c>();
    for(SeguradoContrato__c vSeg : lsSegurCtr){
        if(vSeg.GrupoContrato__r.ContratanteContrato__r.Contrato__r.Endosso__c == '1'){
          String chaveMap = vSeg.GrupoContrato__r.ContratanteContrato__r.Contrato__r.empresa__c    + '-' 
                          + vSeg.GrupoContrato__r.ContratanteContrato__r.Contrato__r.sucursal__c   + '-' 
                          + vSeg.GrupoContrato__r.ContratanteContrato__r.Contrato__r.codigoRamo__c + '-' 
                          + vSeg.GrupoContrato__r.ContratanteContrato__r.Contrato__r.numeroApolice__c;
          mEndosoContrato.put(chaveMap,vSeg);
          //mEndosoContrato.put(vSeg.GrupoContrato__r.ContratanteContrato__r.Contrato__r.NumeroApolice__c,vSeg);
        }
    }

	  System.debug('mEndosoContrato'+mEndosoContrato);
    for(SeguradoContrato__c vSegCont : lsSegurCtr){
      if(vSegCont.GrupoContrato__r.ContratanteContrato__r.Contrato__r.Endosso__c == '0'){
        String vChaveSegurado = vSegCont.GrupoContrato__r.ContratanteContrato__r.Contrato__r.empresa__c    + '-' 
                              + vSegCont.GrupoContrato__r.ContratanteContrato__r.Contrato__r.sucursal__c   + '-' 
                              + vSegCont.GrupoContrato__r.ContratanteContrato__r.Contrato__r.codigoRamo__c + '-' 
                              + vSegCont.GrupoContrato__r.ContratanteContrato__r.Contrato__r.numeroApolice__c;                
        if(mEndosoContrato.containsKey(vChaveSegurado)){
          if(mEndosoContrato.get(vChaveSegurado).VigenciaInicial__c >= caso.Dataocorrencia__c){
                System.debug('Entrou mapSegurCtr endosso');
                mapSegurCtr.put(vSegCont.GrupoContrato__r.ContratanteContrato__r.Contrato__c, vSegCont);
          }
        }else if(vSegCont.VigenciaFinal__c >= caso.Dataocorrencia__c){
            System.debug('Entrou mapSegurCtr original'+vSegCont.GrupoContrato__r.ContratanteContrato__r.Contrato__c);
            mapSegurCtr.put(vSegCont.GrupoContrato__r.ContratanteContrato__r.Contrato__c, vSegCont); 
        }
        
        if(vSegCont.VigenciaInicial__c > caso.Dataocorrencia__c){
            NaoIniciados.add(vSegCont.GrupoContrato__r.ContratanteContrato__r.Contrato__c);
        }else if(vSegCont.VigenciaInicial__c <= caso.Dataocorrencia__c && vSegCont.VigenciaFinal__c >= caso.Dataocorrencia__c){
          //foi iniciado
          System.debug('Entrou');
          if(mEndosoContrato.containsKey(vChaveSegurado)){
            System.debug('Entrou map endosso iniciado');
            if(mEndosoContrato.get(vChaveSegurado).VigenciaInicial__c >= caso.Dataocorrencia__c){
                System.debug(vSegCont.GrupoContrato__r.ContratanteContrato__r.Contrato__c);
                Iniciados.add(vSegCont.GrupoContrato__r.ContratanteContrato__r.Contrato__c);
            }                
          }else{
              System.debug('Entrou iniciado contrato original');
              Iniciados.add(vSegCont.GrupoContrato__r.ContratanteContrato__r.Contrato__c); 
          }
        }
      }
        /*if(vSegCont.VigenciaFinal__c >= caso.Dataocorrencia__c){
            mapSegurCtr.put(vSegCont.GrupoContrato__r.ContratanteContrato__r.Contrato__c, vSegCont);
        }*/
        //Bloco para os filtros
        /*if(vSegCont.VigenciaInicial__c > caso.Dataocorrencia__c){
            NaoIniciados.add(vSegCont.GrupoContrato__r.ContratanteContrato__r.Contrato__c);
        }else if(vSegCont.VigenciaInicial__c <= caso.Dataocorrencia__c && vSegCont.VigenciaFinal__c >= caso.Dataocorrencia__c){
            //foi iniciado
            System.debug('Entrou');
            System.debug(vSegCont.GrupoContrato__r.ContratanteContrato__r.Contrato__c);
            Iniciados.add(vSegCont.GrupoContrato__r.ContratanteContrato__r.Contrato__c);
        }*/  
    }
    //PLV-4434 - FIM

    System.debug('NaoIniciados: '+NaoIniciados);
    System.debug('Iniciados: '+Iniciados);
	  system.debug('mapSegurCtr'+mapSegurCtr.size());
    //PLV-4938 - INICIO
    if(mapSegurCtr.isEmpty()){
      objToReturn.retorno = 'Sem vigencia';
      return JSON.serialize(objToReturn);
    }
    //PLV-4938 - FIM  
    //PLV-3904 - FIM - PEDRO AUGUSTO - SYS4B
    /*Map<String, SeguradoContrato__c> mSegurado = new  Map<String, SeguradoContrato__c> (); 
    Integer sequencialAnterior = -1; 
    String numeroAnterior = '';

    for(SeguradoContrato__c vTsc : mapSegurCtr.values()){
      if(vTsc.GrupoContrato__r.ContratanteContrato__r.Contrato__r.Endosso__c == null) continue;
      String numero = vTsc.GrupoContrato__r.ContratanteContrato__r.Contrato__r.NumeroApolice__c;
      Integer sequencialFinal = Integer.valueOf(vTsc.GrupoContrato__r.ContratanteContrato__r.Contrato__r.Endosso__c);

      if(numero != numeroAnterior) sequencialAnterior = -1;

      if(sequencialFinal > sequencialAnterior) mSegurado.put(numero, vTsc);

      sequencialAnterior = sequencialFinal;
      numeroAnterior = numero;
    }

    for(SeguradoContrato__c vtSc : mSegurado.values()){
      if(vtSc.GrupoContrato__r.ContratanteContrato__r.Contrato__r.Tipo__c == 'Cancelamento' && caso.Dataocorrencia__c >= vtSc.VigenciaInicial__c){ //PLV-4413 - INICIO/FIM
        mSegurado.remove(vtSc.GrupoContrato__r.ContratanteContrato__r.Contrato__r.NumeroApolice__c);
      }
    }*/
	
    //if(mSegurado.isEmpty()) return 'Sem vigencia';
    //PLV-3904 - INICIO - PEDRO AUGUSTO - SYS4B
    Set<Id> setIdContrato = new Set<Id>();
    Set<Id> setIdContratoIniciado = new Set<Id>();
    Set<Id> setIdContratoNaoIniciado = new Set<Id>();
    
    //for(SeguradoContrato__c vSegContrato : mSegurado.values()){
    for(SeguradoContrato__c vSegContrato : mapSegurCtr.values()){  

      if(Iniciados.contains(vSegContrato.GrupoContrato__r.ContratanteContrato__r.Contrato__c)){
        setIdContratoIniciado.add(vSegContrato.GrupoContrato__r.ContratanteContrato__r.Contrato__c);
      }else if (NaoIniciados.contains(vSegContrato.GrupoContrato__r.ContratanteContrato__r.Contrato__c)){
        setIdContratoNaoIniciado.add(vSegContrato.GrupoContrato__r.ContratanteContrato__r.Contrato__c);
      }
      //setIdContrato.add(vSegContrato.GrupoContrato__r.ContratanteContrato__r.Contrato__c);
      
    }

    System.debug('setIdContratoIniciado: '+setIdContratoIniciado);
    System.debug('setIdContratoNaoIniciado: '+setIdContratoNaoIniciado);


    List<AggregateResult> lstGaranCtr = new List<AggregateResult>();

    system.debug('tipoEvento'+tipoEvento);    
    if(!setIdContratoNaoIniciado.isEmpty()){
      List<AggregateResult> lstGaranCtrNiniciados = [SELECT Garantia__r.Sigla__c, Garantia__r.Name, Id //PLV-4499
                                          FROM GarantiaSeguradoContrato__c
                                          WHERE SeguradoContrato__r.GrupoContrato__r.ContratanteContrato__r.Contrato__c IN :setIdContratoNaoIniciado
                                          AND GarantiaProduto__r.OrigemSinistroBeneficio__c INCLUDES(:tipoEvento)
                                          AND GarantiaProduto__r.VigenciaGarantia__c IN ('Contratação até fim da apólice','Contratação até início da apólice')                                          
                                          GROUP BY Garantia__r.Sigla__c, Garantia__r.Name, Id
                                          ORDER BY Garantia__r.Sigla__c ASC];

                                         
      if(!lstGaranCtrNiniciados.isEmpty())
      lstGaranCtr.addAll(lstGaranCtrNiniciados);
    }
    if(!setIdContratoIniciado.isEmpty()){
      List<AggregateResult> lstGaranCtrIniciados = [SELECT Garantia__r.Sigla__c, Garantia__r.Name, Id //PLV-4499
                                         FROM GarantiaSeguradoContrato__c
                                         WHERE SeguradoContrato__r.GrupoContrato__r.ContratanteContrato__r.Contrato__c IN :setIdContratoIniciado
                                         AND GarantiaProduto__r.OrigemSinistroBeneficio__c INCLUDES(:tipoEvento)
                                         AND GarantiaProduto__r.VigenciaGarantia__c IN ('Contratação até fim da apólice','Mesma da apólice')
                                         GROUP BY Garantia__r.Sigla__c, Garantia__r.Name, Id
                                         ORDER BY Garantia__r.Sigla__c ASC];
      if(!lstGaranCtrIniciados.isEmpty())
      lstGaranCtr.addAll(lstGaranCtrIniciados);
    } 
    
    //PLV-3904 - FIM - PEDRO AUGUSTO - SYS4B

    //PLV-4499 - INICIO
    Set<Id> setIdgarantiaSeguradoContrato = new Set<id>();

    for (AggregateResult lstIds : lstGaranCtr){
      setIdgarantiaSeguradoContrato.add(lstIds.Id);
    }

    List<GarantiaSeguradoContrato__c> lstTipoPagamentoGarantiaSeguradoContrato = [SELECT Id, 
                                                GarantiaProduto__r.TipoPagamento__c, Garantia__r.Sigla__c,
                                                Garantia__r.Name
                                                FROM GarantiaSeguradoContrato__c
                                                WHERE Id IN: setIdgarantiaSeguradoContrato                                                
                                                ORDER BY Garantia__r.Sigla__c ASC];     
    //PLV-4499 - FIM        
    //PLV-4938 - INICIO
    if(lstGaranCtr.isEmpty()){
      objToReturn.retorno = 'Sem garantia';
      return JSON.serialize(objToReturn);
    }else{
      //return String.valueOf(JSON.serialize(lstTipoPagamentoGarantiaSeguradoContrato));
      objToReturn.retorno =null;
      objToReturn.garantias = new garantiaTO().dto(lstTipoPagamentoGarantiaSeguradoContrato);
      return JSON.serialize(objToReturn);
    }
    
    //PLV-4938 - FIM
    //PLV-4499 - INICIO
    //else return String.valueOf(JSON.serialize(lstGaranCtr));    
    //PLV-4499 - FIM
    //PLV-4413 - FIM
  }
  //PLV-4938 - INICIO
  public class retornoTO{
    @AuraEnabled public String retorno {get;set;}
    @AuraEnabled public List<garantiaTO> garantias {get;set;}
  }
  public class garantiaTO{
    @AuraEnabled public String id {get;set;}
    @AuraEnabled public String tipopagamento {get;set;}
    @AuraEnabled public String sigla {get;set;}
    @AuraEnabled public String name {get;set;}
    @AuraEnabled public String contrato {get;set;}
    @AuraEnabled public String minimo {get;set;}
    @AuraEnabled public String maximodias {get;set;}
    @AuraEnabled public String maximofranquia {get;set;}
    @AuraEnabled public Boolean exibircampo{get;set;}
    @AuraEnabled public Boolean exibircampofranquia{get;set;}
    @AuraEnabled public Boolean liberardiasfranquia{get;set;}
    @AuraEnabled public Boolean selecionado{get;set;}
    @AuraEnabled public String rotulocampo{get;set;}
    
    public List<garantiaTO> dto (List<GarantiaSeguradoContrato__c> pList){
      if(pList==null || pList.isEmpty()) return null;
      Set<String> siglasCampos = new  Set<String>{'AFI','AFF','DIT','DMHO','DIH'};
      Set<String> siglasCamposFranquia = new  Set<String>{'DIT','DIH'};
      List<garantiaTO> listToReturn = new List<garantiaTO>();
      for(GarantiaSeguradoContrato__c gs : pList){
        if(gs.Garantia__r.Sigla__c=='TELEMED') continue;
        garantiaTO g = new garantiaTO();
        g.id = gs.Id;
        g.tipopagamento = gs.GarantiaProduto__r.TipoPagamento__c;
        g.sigla = gs.Garantia__r.Sigla__c;
        g.name = gs.Garantia__r.Name;
        g.exibircampo = siglasCampos.contains(g.sigla);
        g.maximoDias = g.sigla =='DIT' ? '365' :g.sigla =='DIH'? '180':'9999999';
        g.maximoFranquia = g.sigla =='DIT' ? '30' : '9999999';
        g.exibircampofranquia = siglasCamposFranquia.contains(g.sigla) && g.maximoFranquia!='9999999';
        g.liberardiasfranquia = g.tipopagamento.contains('Diária') || g.tipopagamento.contains('Renda');
        g.rotulocampo = g.liberardiasfranquia ? 'Dias' : 'Valor';
        g.selecionado = false;
        listToReturn.add(g);
      }
      return listToReturn;
    }
  }
  //PLV-4938 - FIM

  //PLV-3914 - INICIO - Notificação de Sinistro duplicado
  @AuraEnabled
  public static List<Case> validarSinistroDuplicado(String recordId, String tipoEvento){

    Case caso = [SELECT Id, Account.Name, Dataocorrencia__c, Vitima__c, Subject, 
                Description, AccountId, ContactId, Type FROM Case WHERE Id = :recordId];

    List<SeguradoContrato__c> lstSeguradosContrato = [
      SELECT Id,GrupoContrato__r.ContratanteContrato__r.Contrato__c      
      FROM SeguradoContrato__c 
      WHERE Conta__c = :caso.AccountId
      // AND VigenciaInicial__c <= :caso.Dataocorrencia__c
      // AND VigenciaFinal__c >= :caso.Dataocorrencia__c
      AND GrupoContrato__r.ContratanteContrato__r.Contrato__r.Tipo__c != 'Cancelamento'
    ];

    Set<String> setContratos = new Set<String>();
    Set<String> setIdsegurados = new Set<String>();

    for(SeguradoContrato__c seguradoContrato : lstSeguradosContrato){
      setContratos.add(seguradoContrato.GrupoContrato__r.ContratanteContrato__r.Contrato__c);
      setIdsegurados.add(seguradoContrato.id);
    }

    List<Case> listCasosExistentes = [
      SELECT Id, CaseNumber, Status, Status_Dependente__c, Origin, TipoEvento__c
      FROM Case 
      WHERE Dataocorrencia__c = :caso.Dataocorrencia__c
      AND Contrato__c = :setContratos
      AND Segurado_do_contrato__c = :setIdsegurados
      AND TipoEvento__c = :tipoEvento];

    system.debug('listCasosExistentes:' + listCasosExistentes);
    if(listCasosExistentes.isEmpty()) return null;
    return listCasosExistentes;
  }
  //PLV-3914 - FIM - Notificação de Sinistro duplicado

  @AuraEnabled
  //PLV-4176 adicionado parametro garantiasPrices
  //PLV-4938 - Adicionado parametro garantiasarray - basicamente é o mesmo array de garantiaTO que montamos para enviar ao front
  //ele serve para sabermos quais garantias foram de fato selecionadas e fazer o match com a regra enviada ao front
  public static void criaCasoSinistro(String recordId, List<String> garantias, String tipoEvento, String garantiasPrices, String garantiasarray) {
    system.debug('entrou criar sisnistro>>>>');
    system.debug('garantiasPrice:'+ garantiasPrices);
    system.debug('garantiasarray:'+ garantiasarray);
    system.debug('tipoEvento:'+ tipoEvento);
    system.debug('garantias:'+ JSON.serialize(garantias));
    system.debug('recordId:'+ recordId);
    //PLV-3997 - INICIO
	  //PLV-4176 - INICIO
    Case caso = [SELECT Id, Account.Name, Dataocorrencia__c, Vitima__c, Subject, 
    Description, AccountId, ContactId, Type, Origin, Parceiro__c FROM Case WHERE Id = :recordId];
    //PLV-4176 - INICIO
	  //PLV-3997 - FIM
    //PLV-4938 - INICIO - PEDRO AUGUSTO BRAZ
    //List<garantiaTO> garantiasfront = String.isNotBlank(garantiasarray) ? (List<garantiaTO>) JSON.deserialize(garantiasarray, garantiaTO.class) : new List<garantiaTO>();
    Map<String,Map<String,GarantiaSeguradoContrato__c>> contratoGarantia = new Map<String,Map<String,GarantiaSeguradoContrato__c>>();
    //PLV-4938 - FIM - PEDRO AUGUSTO BRAZ
    //PLV-4434 - INICIO
    List<SeguradoContrato__c> lstSegurados = [SELECT Id,GrupoContrato__r.ContratanteContrato__r.Contrato__c,
                                            GrupoContrato__r.ContratanteContrato__r.Contrato__r.empresa__c,
                                            GrupoContrato__r.ContratanteContrato__r.Contrato__r.sucursal__c,
                                            GrupoContrato__r.ContratanteContrato__r.Contrato__r.codigoRamo__c,
                                            GrupoContrato__r.ContratanteContrato__r.Contrato__r.Endosso__c,
                                            GrupoContrato__r.ContratanteContrato__r.Contrato__r.NumeroApolice__c,
                                            VigenciaInicial__c, VigenciaFinal__c
                                            FROM SeguradoContrato__c 
                                            WHERE Conta__c = :caso.AccountId
                                            //PLV-3904 - INICIO - PEDRO AUGUSTO - SYS4B (COMPLEMENTO DA HISTORIA)
                                            //AND VigenciaInicial__c <= :caso.Dataocorrencia__c
                                            //PLV-3904 - FIM - PEDRO AUGUSTO - SYS4B (COMPLEMENTO DA HISTORIA)
                                            AND VigenciaFinal__c >= :caso.Dataocorrencia__c];
                                            //AND GrupoContrato__r.ContratanteContrato__r.Contrato__r.Tipo__c != 'Cancelamento'];
    //PLV-4434 - FIM - Alteração na query

    System.debug('lstSegurados: ' + lstSegurados);
    
    //PLV-4434 - INICIO
    Map<String, SeguradoContrato__c> mapEndossos =  new Map<String, SeguradoContrato__c>();
    //Adiciona os contratos do tipo Endosso no mapEndossos
    for(SeguradoContrato__c seguradoObj : lstSegurados){
      if(seguradoObj.GrupoContrato__r.ContratanteContrato__r.Contrato__r.Endosso__c == '1'){
        String chaveMap = seguradoObj.GrupoContrato__r.ContratanteContrato__r.Contrato__r.empresa__c    + '-' 
                        + seguradoObj.GrupoContrato__r.ContratanteContrato__r.Contrato__r.sucursal__c   + '-' 
                        + seguradoObj.GrupoContrato__r.ContratanteContrato__r.Contrato__r.codigoRamo__c + '-' 
                        + seguradoObj.GrupoContrato__r.ContratanteContrato__r.Contrato__r.numeroApolice__c;
        mapEndossos.put(chaveMap, seguradoObj);
      }
    }
    system.debug('mapEndossos: ' + mapEndossos.values());
 
    List<SeguradoContrato__c> listaSeguradosEmVigencia = new List<SeguradoContrato__c>();
    for(SeguradoContrato__c seguradoObj2 : lstSegurados){
      if(seguradoObj2.GrupoContrato__r.ContratanteContrato__r.Contrato__r.Endosso__c == '0'){
        String chaveMap = seguradoObj2.GrupoContrato__r.ContratanteContrato__r.Contrato__r.empresa__c    + '-' 
                        + seguradoObj2.GrupoContrato__r.ContratanteContrato__r.Contrato__r.sucursal__c   + '-' 
                        + seguradoObj2.GrupoContrato__r.ContratanteContrato__r.Contrato__r.codigoRamo__c + '-' 
                        + seguradoObj2.GrupoContrato__r.ContratanteContrato__r.Contrato__r.numeroApolice__c;
        if(mapEndossos.containsKey(chaveMap)){
          if(mapEndossos.get(chaveMap).VigenciaInicial__c >= caso.Dataocorrencia__c)
            listaSeguradosEmVigencia.add(seguradoObj2); 
        }else
          listaSeguradosEmVigencia.add(seguradoObj2);        
      }
    }
    //PLV-4434 - FIM

    Set<Id> setIdContrato = new Set<Id>();

    Integer sequencialAnterior = -1; 
    String numeroAnterior = '';

    for(SeguradoContrato__c vTsc :listaSeguradosEmVigencia){ //PLV-4434 - INICIO/FIM
      if(vTsc.GrupoContrato__r.ContratanteContrato__r.Contrato__r.Endosso__c == null) continue;
      String numero = vTsc.GrupoContrato__r.ContratanteContrato__r.Contrato__r.NumeroApolice__c;
      Integer sequencialFinal = Integer.valueOf(vTsc.GrupoContrato__r.ContratanteContrato__r.Contrato__r.Endosso__c);

      if(numero != numeroAnterior) sequencialAnterior = -1;

      if(sequencialFinal > sequencialAnterior) setIdContrato.add(vTsc.GrupoContrato__r.ContratanteContrato__r.Contrato__c);

      sequencialAnterior = sequencialFinal;
      numeroAnterior = numero;
    }

    System.debug(setIdContrato);
    
    List<String> siglas = new List<String>();
    
    for(String garantia :garantias) {
      siglas.add(garantia.split('--')[0]);
    }
          
    List<GarantiaSeguradoContrato__c> listaGaratiaSegurado = [SELECT Garantia__c, Garantia__r.Name, Garantia__r.Sigla__c, Capital__c,
                                                              SeguradoContrato__r.GrupoContrato__r.ContratanteContrato__r.Contrato__c,
                                                              GarantiaProduto__r.TipoPagamento__c, Id //PLV-4499                                                              
                                                              FROM GarantiaSeguradoContrato__c
                                                              WHERE GarantiaProduto__r.OrigemSinistroBeneficio__c INCLUDES (:tipoEvento)
                                                              AND Garantia__r.Sigla__c IN :siglas
                                                              AND SeguradoContrato__r.Conta__c = :caso.AccountId
                                                              //PLV-3904 - INICIO - PEDRO AUGUSTO - SYS4B (COMPLEMENTO DA HISTORIA)
                                                              //AND SeguradoContrato__r.VigenciaInicial__c <= :caso.Dataocorrencia__c
                                                              //PLV-3904 - FIM - PEDRO AUGUSTO - SYS4B
                                                              AND SeguradoContrato__r.VigenciaFinal__c >= :caso.Dataocorrencia__c
                                                              AND SeguradoContrato__r.GrupoContrato__r.ContratanteContrato__r.Contrato__c IN :setIdContrato];
    
    System.debug(JSON.serialize(listaGaratiaSegurado));  
        
    //PLV-4499 - INICIO
    Set<Id> setIdgarantiaContratoFranquia = new Set<id>();
    for (GarantiaSeguradoContrato__c lstContratoFranquiaIds : listaGaratiaSegurado){
      setIdgarantiaContratoFranquia.add(lstContratoFranquiaIds.SeguradoContrato__r.GrupoContrato__r.ContratanteContrato__r.Contrato__c);      
      //PLV-4938 INICIO
      String idContrato = lstContratoFranquiaIds.SeguradoContrato__r.GrupoContrato__r.ContratanteContrato__r.Contrato__c;
      String sigla = lstContratoFranquiaIds.Garantia__r.Sigla__c;
      Map<String,GarantiaSeguradoContrato__c> siglaGarantia = new Map<String,GarantiaSeguradoContrato__c>();
      if(contratoGarantia.containsKey(idContrato)){
        siglaGarantia = contratoGarantia.get(idContrato);
      }else{
        contratoGarantia.put(idContrato, new Map<String,GarantiaSeguradoContrato__c>());
      }
      siglaGarantia.put(sigla,lstContratoFranquiaIds);
      contratoGarantia.put(idContrato, siglaGarantia);
      //PLV-4938 FIM
    }
    
    List<GarantiaContrato__c> lstGarantiasContratoFranquia = [SELECT Name, FranquiaGarantia__r.Franquia__r.Descricao__c, Contrato__c, //PLV-4499 - ALTERAÇÃO
                                                              Garantia__r.Name, Garantia__r.Sigla__c 
                                                              FROM GarantiaContrato__c
                                                              WHERE Contrato__c IN: setIdgarantiaContratoFranquia
                                                              AND Garantia__r.Sigla__c IN :siglas];
    //PLV-4499 - FIM

    //Arranjo de dados criado considerando que uma conta pode estar presente como segurado apenas uma vez por contrato
    Map<Id, List<GarantiaSeguradoContrato__c>> mapContratoGarantiaSegurado = new Map<Id, List<GarantiaSeguradoContrato__c>>();
    Map<Id, SeguradoContrato__c> mapContratoSegurado = new Map<Id, SeguradoContrato__c>();
   	
    //PLV-4176 inicio
    Map<String, List<GarantiaSeguradoContrato__c>> mapValoresGantatias = new Map<String, List<GarantiaSeguradoContrato__c>>(); //PLV-4176  
   	//PLV-4176 fim
    for(GarantiaSeguradoContrato__c garantia :listaGaratiaSegurado) {
      Id contratoId = garantia.SeguradoContrato__r.GrupoContrato__r.ContratanteContrato__r.Contrato__c;
      if(mapContratoGarantiaSegurado.containsKey(contratoId)) {
        List<GarantiaSeguradoContrato__c> garantiasSegurado = mapContratoGarantiaSegurado.get(contratoId);
        garantiasSegurado.add(garantia);
        mapContratoGarantiaSegurado.put(contratoId,garantiasSegurado);
      }
      else{
        mapContratoGarantiaSegurado.put(contratoId, new List<GarantiaSeguradoContrato__c>{garantia});
      }
	  
      //PLV-4176 - inicio  
      mapValoresGantatias.put(garantia.Garantia__r.Sigla__c, new List<GarantiaSeguradoContrato__c>());
      mapValoresGantatias.get(garantia.Garantia__r.Sigla__c).add(garantia);      
      //PLV-4176 - fim  
        
      mapContratoSegurado.put(contratoId,garantia.SeguradoContrato__r);
    }
    System.debug(JSON.serialize(mapContratoGarantiaSegurado));

    List<Case> lstCasoFilho = new List<Case>();
    Id REC_ID_FILHO;

    if(caso.Type == 'Sinistro') {
      REC_ID_FILHO = RecordTypeBO.buscarTipoRegistro('Case', 'Sinistro').Id;
    } else if(caso.Type == 'Benefício') {
      REC_ID_FILHO = RecordTypeBO.buscarTipoRegistro('Case', 'Beneficio').Id;
    }

    for(Id contratoId :mapContratoGarantiaSegurado.keySet()){
      Case casoFilho = new Case();
      
      casoFilho.RecordTypeId = REC_ID_FILHO;
      casoFilho.AccountId = caso.AccountId;
      casoFilho.ContactId = caso.ContactId;
      casoFilho.ParentId = caso.Id;
      casoFilho.Dataocorrencia__c = caso.Dataocorrencia__c;
      casoFilho.Vitima__c = caso.Vitima__c;
      casoFilho.Segurado_do_contrato__c = mapContratoSegurado.get(contratoId).Id;
      casoFilho.Contrato__c = contratoId;
      casoFilho.Status = 'Avisar';
      casoFilho.Status_Dependente__c = 'Em Análise';
      casoFilho.Subject = caso.Subject;
      casoFilho.Description = caso.Description;
      //PLV-3997 - INICIO
      casoFilho.Origin = String.isNotBlank(caso.Origin) ? caso.Origin : 'Atendimento';
      //PLV-3997 - FIM

	  //PLV-4176 - Inicio
	  if(casoFilho.Origin == 'Prestadora'){
		casoFilho.Parceiro__c = caso.Parceiro__c;
	  }
	  //PLV-4176 - Fim

      casoFilho.TipoEvento__c = tipoEvento;
      casoFilho.Type = caso.Type;
      casoFilho.Caso_Filho_Criado_Automaticamente__c = true;

      lstCasoFilho.add(casoFilho);
    }

    try{
      insert lstCasoFilho;
    }catch(DmlException e){
      System.debug('Erro: ' + e.getMessage() + ' - Linha: ' + e.getLineNumber());
      throw new AuraHandledException('Erro ao criar sinistro(s)');
    }

    System.debug(JSON.serialize(lstCasoFilho));
    
    List<PagamentoGarantia__c> listaGarantiasCasoFilho = new List<PagamentoGarantia__c>();
	  //PLV-4176 - inicio  
    Double precoGarantia;
    String garantiaCodigo;
    Double franquiaDias; //PLV-4499
    Boolean calculaFranquiaDias; //PLV-4499
    String franquiaGarantiaNome; //PLV-4499

    if(garantiasPrices == null){
       garantiasPrices = '[{"valor":".","price":"0"}]';
    }  
    List<CasoWizardController.listasdePrecos> precosGarantia = (List<CasoWizardController.listasdePrecos>)JSON.deserialize(garantiasPrices, List<CasoWizardController.listasdePrecos>.class);
    //PLV-4176 - fim 
    
   	for(Case casoFilho :lstCasoFilho){
      for(GarantiaSeguradoContrato__c garantia :mapContratoGarantiaSegurado.get(casoFilho.Contrato__c)){        
        //PLV-4176 - inicio 
        precoGarantia = 0;                        
        if(garantia.Garantia__r.Sigla__c != null && precosGarantia.size()>0){
            //PLV-4499 - INICIO
            franquiaDias = 0;
            calculaFranquiaDias = false;
            franquiaGarantiaNome = '';
            //PLV-4499 - FIM
            for (CasoWizardController.listasdePrecos p : precosGarantia) {                                
                garantiaCodigo = p.valor.split('--')[0];                                
                if(garantiaCodigo == garantia.Garantia__r.Sigla__c )
                {                                    
                    //PLV-4499 - INICIO                    
                    if(p.valor == p.valor.split('--')[0]+'--'+p.valor.split('--')[1]+'--Franquia'){                      
                      franquiaDias = decimal.valueOf(p.price);                      
                      calculaFranquiaDias = true;    
                      for(GarantiaContrato__c lstFranquiaGarantiaPagtoContrato : lstGarantiasContratoFranquia){      
                        if(lstFranquiaGarantiaPagtoContrato.Garantia__r.Sigla__c == garantia.Garantia__r.Sigla__c){
                          franquiaGarantiaNome = lstFranquiaGarantiaPagtoContrato.FranquiaGarantia__r.Franquia__r.Descricao__c; //PLV-4499 - ALTERAÇÃO                         
                        }                        
                      }                  
                    }else{                                          
                      //precoGarantia = decimal.valueOf(p.price);//PLV-4938 INICIO/FIM
                      precoGarantia = contratoGarantia.get(casoFilho.Contrato__c).get(garantiaCodigo).Capital__c;//PLV-4938 INICIO/FIM
                    }
                    //PLV-4499 - FIM
                }
            }               
        }
        //PLV-4176 - fim  
 
        PagamentoGarantia__c garantiaSinistro = new PagamentoGarantia__c();
        garantiaSinistro.Caso__c = casoFilho.Id;
        garantiaSinistro.Garantia_do_segurado_do_contrato__c = garantia.Id;
        garantiaSinistro.Fase__c = 'Aberto';
        garantiaSinistro.Name = garantia.Garantia__r.Name;
        garantiaSinistro.Capital__c = garantia.Capital__c;             

        //PLV-4176 - inicio 
        //PLV-4499 - INICIO  
        if(calculaFranquiaDias){
          garantiaSinistro.Valor_indenizado__c = (garantiaSinistro.Capital__c * (precoGarantia - franquiaDias));
          garantiaSinistro.ValorIndenizadoInicial__c = (garantiaSinistro.Capital__c * (precoGarantia - franquiaDias));            
          garantiaSinistro.QuantidadeDias__c = precoGarantia;
          garantiaSinistro.Franquias__c = franquiaDias;
          garantiaSinistro.FranquiaContrato__c = franquiaGarantiaNome;          
        }else{ 
          garantiaSinistro.Valor_indenizado__c = precoGarantia;
          garantiaSinistro.ValorIndenizadoInicial__c = precoGarantia;
          garantiaSinistro.QuantidadeDias__c = null;
          garantiaSinistro.Franquias__c = null;
          garantiaSinistro.FranquiaContrato__c = null;
        }       
        //PLV-4499 - FIM
        //PLV-4176 - fim

        listaGarantiasCasoFilho.add(garantiaSinistro);
      }
    }

    try{
      insert listaGarantiasCasoFilho;
    }catch(DmlException e){
      System.debug('Erro: ' + e.getMessage() + ' - Linha: ' + e.getLineNumber());
      throw new AuraHandledException('Erro ao criar garantias do(s) sinistro(s)');
    }
  }
  //PLV-3777 - FIMc()  

  //PLV-4176 - inicio  
  public class listasdePrecos{
     String valor;
     String price;
  } 
  //PLV-4176 - fim  
  
}