public class wizardteste {


    public class retornoTO{
        @AuraEnabled public String retorno {get;set;}
        @AuraEnabled public List<contratoTO> contratos {get;set;}
        @AuraEnabled public List<garantiaTO> garantias {get;set;}
        @AuraEnabled public List<franquiaTO> franquias {get;set;}
    }

    public class franquiaTO{
        @AuraEnabled public String id {get;set;}
        @AuraEnabled public String name {get;set;}
        @AuraEnabled public String garantiaprodutoId {get;set;}
        @AuraEnabled public String descricao {get;set;}
        @AuraEnabled public String sigla {get;set;}

        public List<franquiaTO> dto (List<FranquiaGarantia__c> pList){
            if(pList==null || pList.isEmpty()) return null;
            
            List<franquiaTO> listToReturn = new List<franquiaTO>();
            for(FranquiaGarantia__c fg : pList){
                franquiaTO fto = new franquiaTO();
                    fto.id  = fg.id;
                    fto.name  = fg.name;
                    fto.garantiaprodutoId  = fg.GarantiaProduto__c;
                    fto.sigla  = fg.GarantiaProduto__r.garantia__r.sigla__c;
                    fto.descricao  = fg.franquia__r.Descricao__c;
                listToReturn.add(fto);
            }
            return listToReturn;
        }

    }
    public class contratoTO{
        @AuraEnabled public String id {get;set;}
        @AuraEnabled public String segmento {get;set;}
        @AuraEnabled public String inicioVigencia {get;set;}
        @AuraEnabled public String fimVigencia {get;set;}
        @AuraEnabled public String numero {get;set;}
        @AuraEnabled public String seguradoId {get;set;}
        @AuraEnabled public String tipo {get;set;}
        

        public List<contratoTO> dto (List<Contract> pList){
            if(pList==null || pList.isEmpty()) return null;
            
            List<contratoTO> listToReturn = new List<contratoTO>();
            for(Contract c : pList){
                contratoTO cto = new contratoTO();
                    cto.id  = c.id;
                    cto.segmento  = c.Segmento__c;
                    cto.inicioVigencia  = String.valueOf(c.StartDate);
                    cto.fimVigencia = String.valueOf(c.VigenciaFinal__c);
                    cto.numero = c.Name;
                    cto.tipo = 'Endosso'.equalsIgnoreCase(c.Tipo__c) && String.isNotBlank(c.TipoEndosso__c) ? c.TipoEndosso__c : c.Tipo__c ;
                listToReturn.add(cto);
            }
            return listToReturn;
        }

        public contratoTO dtoSeguradoInfo (contratoTO pSegurado, SeguradoContrato__c pSC){
            if(pSegurado==null || pSC==null) return null;
            pSegurado.seguradoId = pSC.Id;
            return pSegurado;
        }
    }
    
    public class garantiaTO{
        @AuraEnabled public String id {get;set;}
        @AuraEnabled public String tipopagamento {get;set;}
        @AuraEnabled public String sigla {get;set;}
        @AuraEnabled public String name {get;set;}
        @AuraEnabled public String contratoId {get;set;}
        @AuraEnabled public Boolean selecionado{get;set;}
        @AuraEnabled public Boolean valorfixo{get;set;}
        @AuraEnabled public Boolean liberardiasfranquia{get;set;}
        @AuraEnabled public Decimal capital {get;set;}
        @AuraEnabled public Decimal capitalmaximo {get;set;}
        @AuraEnabled public Decimal franquia {get;set;}
        @AuraEnabled public String maximofranquia {get;set;}
        @AuraEnabled public String minimofranquia {get;set;}
        @AuraEnabled public Decimal dias {get;set;}
        @AuraEnabled public String maximodias {get;set;}
        @AuraEnabled public String minimodias {get;set;}
        @AuraEnabled public Decimal totalutilizado {get;set;}
        @AuraEnabled public String descricaofranquia {get;set;}
        @AuraEnabled public String codigofranquia {get;set;}
        @AuraEnabled public String tipofranquia {get;set;}
        





        @AuraEnabled public String minimo {get;set;}
        @AuraEnabled public String rotulocampo {get;set;}
        @AuraEnabled public Boolean exibircampofranquia{get;set;}
        @AuraEnabled public Boolean exibircampo{get;set;}
        @AuraEnabled public Boolean selecionaremtodos{get;set;}
        @AuraEnabled public string garantiaprodutoId {get;set;}

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
                    g.garantiaprodutoId = gs.GarantiaProduto__c;
                    g.totalutilizado = gs.Total_utilizado__c;
                    g.contratoId = gs.SeguradoContrato__r.GrupoContrato__r.ContratanteContrato__r.Contrato__c;
                    g.sigla = gs.Garantia__r.Sigla__c;
                    g.name = gs.Garantia__r.Name;
                    g.exibircampo = siglasCampos.contains(g.sigla);
                    g.descricaofranquia = descricaofranquia;
                    g.valorfixo = !g.exibircampo;
                    g.maximoDias = g.sigla =='DIT' ? '365' :g.sigla =='DIH'? '180':'9999999';
                    g.maximofranquia = g.sigla =='DIT' ? '30' : '9999999';
                    g.exibircampofranquia = siglasCamposFranquia.contains(g.sigla) && g.maximoFranquia!='9999999';
                    g.liberardiasfranquia = g.valorfixo ? false : g.tipopagamento.contains('Diária') || g.tipopagamento.contains('Renda');
                    g.rotulocampo = g.liberardiasfranquia ? 'Dias' : 'Valor';
                    g.capital = g.sigla =='IPA' && gs.Capital__c!=null ? gs.Capital__c * 0.15 : gs.Capital__c;
                    g.capitalmaximo = g.capital;
                    g.selecionado = false;
                listToReturn.add(g);
            }
            return listToReturn;
        }


        public garantiaTO dtoFranquia (garantiaTO pGarantia,GarantiaContrato__c gc){
            if(pGarantia==null || gc == null)
                return pGarantia;
            pGarantia.codigofranquia = gc.FranquiaGarantia__r.Franquia__r.CodigoFranquia__c;
            pGarantia.descricaofranquia = gc.FranquiaGarantia__r.Franquia__r.Descricao__c;
            pGarantia.tipofranquia = gc.FranquiaGarantia__r.Franquia__r.Tipo__c;
            return pGarantia;
        }
    }

    public static String buildChave (SeguradoContrato__c seg){
        String chaveMap = seg.GrupoContrato__r.ContratanteContrato__r.Contrato__r.empresa__c    + '-' 
                            + seg.GrupoContrato__r.ContratanteContrato__r.Contrato__r.sucursal__c   + '-' 
                            + seg.GrupoContrato__r.ContratanteContrato__r.Contrato__r.codigoRamo__c + '-' 
                            + seg.GrupoContrato__r.ContratanteContrato__r.Contrato__r.numeroApolice__c;
        return chaveMap;
    }
    @AuraEnabled
    public static string pesquisacontratos(String recordId, String tipoEvento) {
        retornoTO objToReturn = new retornoTO();
        system.debug('>>> Entrou no pesquisacontratos' );
        system.debug('recordId'+recordId);
        Case caso = [SELECT AccountId, Account.Name, Dataocorrencia__c FROM Case WHERE Id = :recordId LIMIT 1];
        Map<String,SeguradoContrato__c> contratoxSegurado = new Map<String,SeguradoContrato__c>();
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
        
        if(lsSegurCtr.isEmpty()){
            objToReturn.retorno = 'O segurado não foi localizado.';
            return JSON.serialize(objToReturn);
        }

        Map<Id,SeguradoContrato__c> mapSegurCtr = new Map<Id,SeguradoContrato__c>();
        Set<Id> Iniciados= new Set<Id>();
        Set<Id> NaoIniciados= new Set<Id>();
        
        Map<String,SeguradoContrato__c> mEndosoContrato = new Map<String,SeguradoContrato__c>();
        /*for(SeguradoContrato__c vSeg : lsSegurCtr){
            contratoxSegurado.put(vSeg.GrupoContrato__r.ContratanteContrato__r.Contrato__c, vSeg);
            String chaveMap = buildChave(vSeg);
            if(vSeg.GrupoContrato__r.ContratanteContrato__r.Contrato__r.Endosso__c != '0'){
                mEndosoContrato.put(chaveMap,vSeg);
            }else if(vSeg.GrupoContrato__r.ContratanteContrato__r.Contrato__r.Endosso__c == '0'){

                if(mEndosoContrato.containsKey(chaveMap)){
                
                    if(mEndosoContrato.get(chaveMap).VigenciaInicial__c >= caso.Dataocorrencia__c){
                        System.debug('Entrou mapSegurCtr endosso');
                        mapSegurCtr.put(vSeg.GrupoContrato__r.ContratanteContrato__r.Contrato__c, vSeg);
                    }
                
                }else if(vSeg.VigenciaFinal__c >= caso.Dataocorrencia__c){
                    System.debug('Entrou mapSegurCtr original'+vSeg.GrupoContrato__r.ContratanteContrato__r.Contrato__c);
                    mapSegurCtr.put(vSeg.GrupoContrato__r.ContratanteContrato__r.Contrato__c, vSeg); 
                }
                
                if(vSeg.VigenciaInicial__c > caso.Dataocorrencia__c){
                    NaoIniciados.add(vSeg.GrupoContrato__r.ContratanteContrato__r.Contrato__c);
                }else if(vSeg.VigenciaInicial__c <= caso.Dataocorrencia__c && vSeg.VigenciaFinal__c >= caso.Dataocorrencia__c){
                    System.debug('Entrou');
                    
                    if(mEndosoContrato.containsKey(chaveMap)){
                        System.debug('Entrou map endosso iniciado');
                        if(mEndosoContrato.get(chaveMap).VigenciaInicial__c >= caso.Dataocorrencia__c){
                            System.debug(vSeg.GrupoContrato__r.ContratanteContrato__r.Contrato__c);
                            Iniciados.add(vSeg.GrupoContrato__r.ContratanteContrato__r.Contrato__c);
                        }                
                    }else{
                        System.debug('Entrou iniciado contrato original');
                        Iniciados.add(vSeg.GrupoContrato__r.ContratanteContrato__r.Contrato__c); 
                    }
                
                }
            }
        }*/

        for(SeguradoContrato__c vSeg : lsSegurCtr){
            if(vSeg.GrupoContrato__r.ContratanteContrato__r.Contrato__r.Endosso__c != '0'){
            String chaveMap = buildChave(vSeg);
            mEndosoContrato.put(chaveMap,vSeg);
            //mEndosoContrato.put(vSeg.GrupoContrato__r.ContratanteContrato__r.Contrato__r.NumeroApolice__c,vSeg);
            }
        }

        System.debug('ENDOSSOS ENCONTRADOS:  '+ JSON.serialize(mEndosoContrato.values()));

        for(SeguradoContrato__c vSegCont : lsSegurCtr){
            contratoxSegurado.put(vSegCont.GrupoContrato__r.ContratanteContrato__r.Contrato__c, vSegCont);
            //if(vSegCont.GrupoContrato__r.ContratanteContrato__r.Contrato__r.Endosso__c == '0'){
                String vChaveSegurado = buildChave(vSegCont);                
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
            
            /*}else{

            }*/
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

        System.debug('mEndosoContrato'+mEndosoContrato);
        System.debug('NaoIniciados: '+NaoIniciados);
        System.debug('Iniciados: '+Iniciados);
        system.debug('mapSegurCtr'+mapSegurCtr.size());



        if(mapSegurCtr.isEmpty()){
            objToReturn.retorno = 'Sem vigência';
            return JSON.serialize(objToReturn);
        }


        Set<Id> setIdContrato = new Set<Id>();
        Set<Id> setIdContratoIniciado = new Set<Id>();
        Set<Id> setIdContratoNaoIniciado = new Set<Id>();
        
        for(SeguradoContrato__c vSegContrato : mapSegurCtr.values()){  
            if(Iniciados.contains(vSegContrato.GrupoContrato__r.ContratanteContrato__r.Contrato__c)){
                setIdContratoIniciado.add(vSegContrato.GrupoContrato__r.ContratanteContrato__r.Contrato__c);
            }else if (NaoIniciados.contains(vSegContrato.GrupoContrato__r.ContratanteContrato__r.Contrato__c)){
                setIdContratoNaoIniciado.add(vSegContrato.GrupoContrato__r.ContratanteContrato__r.Contrato__c);
            }
        }

        System.debug('setIdContratoIniciado: '+setIdContratoIniciado);
        System.debug('setIdContratoNaoIniciado: '+setIdContratoNaoIniciado);


        List<GarantiaSeguradoContrato__c> lstGaranCtr = new List<GarantiaSeguradoContrato__c>();

        System.debug('tipoEvento: '+tipoEvento);

        if(!setIdContratoNaoIniciado.isEmpty()){
            List<GarantiaSeguradoContrato__c> lstGaranCtrNiniciados = [SELECT Id
                                                              , Garantia__r.Sigla__c
                                                              , Garantia__r.Name
                                                              , GarantiaProduto__c
                                                              , Total_utilizado__c
                                                              , SeguradoContrato__r.GrupoContrato__r.ContratanteContrato__r.Contrato__c
                                                        FROM GarantiaSeguradoContrato__c
                                                        WHERE SeguradoContrato__r.GrupoContrato__r.ContratanteContrato__r.Contrato__c IN :setIdContratoNaoIniciado
                                                        AND GarantiaProduto__r.OrigemSinistroBeneficio__c INCLUDES(:tipoEvento)
                                                        AND GarantiaProduto__r.VigenciaGarantia__c IN ('Contratação até fim da apólice','Contratação até início da apólice')                                          
                                                        //GROUP BY Garantia__r.Sigla__c, Garantia__r.Name, Id
                                                        ORDER BY Garantia__r.Sigla__c ASC];

                                            
            if(!lstGaranCtrNiniciados.isEmpty())
                lstGaranCtr.addAll(lstGaranCtrNiniciados);
        }

        if(!setIdContratoIniciado.isEmpty()){
            List<GarantiaSeguradoContrato__c> lstGaranCtrIniciados = [SELECT Id
                                                            , Garantia__r.Sigla__c
                                                            , Garantia__r.Name
                                                            , GarantiaProduto__c
                                                            , Total_utilizado__c
                                                            , SeguradoContrato__r.GrupoContrato__r.ContratanteContrato__r.Contrato__c
                                                        FROM GarantiaSeguradoContrato__c
                                                        WHERE SeguradoContrato__r.GrupoContrato__r.ContratanteContrato__r.Contrato__c IN :setIdContratoIniciado
                                                        AND GarantiaProduto__r.OrigemSinistroBeneficio__c INCLUDES(:tipoEvento)
                                                        AND GarantiaProduto__r.VigenciaGarantia__c IN ('Contratação até fim da apólice','Mesma da apólice')
                                                        //GROUP BY Garantia__r.Sigla__c, Garantia__r.Name, Id
                                                        ORDER BY Garantia__r.Sigla__c ASC];
            if(!lstGaranCtrIniciados.isEmpty())
                lstGaranCtr.addAll(lstGaranCtrIniciados);
        } 
        

        Set<Id> setIdgarantiaSeguradoContrato = new Set<id>();
        
        for (GarantiaSeguradoContrato__c lstIds : lstGaranCtr){
            setIdgarantiaSeguradoContrato.add(lstIds.Id);
            setIdContrato.add(lstIds.SeguradoContrato__r.GrupoContrato__r.ContratanteContrato__r.Contrato__c);
        }

        List<GarantiaSeguradoContrato__c> lstTipoPagamentoGarantiaSeguradoContrato = [SELECT Id
                                                        , Name
                                                        , GarantiaProduto__c
                                                        , GarantiaProduto__r.LimiteMaximoUtilizacao__c
                                                        , GarantiaProduto__r.TipoPagamento__c
                                                        , Garantia__r.Sigla__c
                                                        , Garantia__r.Name
                                                        , Limite_de_Uso__c
                                                        , TipoCapitalProduto__c
                                                        , TipoCapital__c
                                                        , Tipo_de_limite_de_utilizacao__c
                                                        , Total_utilizado__c
                                                        , Valor__c
                                                        , ValorCotacao__c
                                                        , ValorDias__c
                                                        , Capital__c
                                                        , SeguradoContrato__r.GrupoContrato__r.ContratanteContrato__r.Contrato__c
                                                        FROM GarantiaSeguradoContrato__c
                                                        WHERE Id IN: setIdgarantiaSeguradoContrato                                                
                                                        ORDER BY Garantia__r.Sigla__c ASC];    
        Set<Id> setGarantiaProdutoId = new Set<Id>();
        for (GarantiaSeguradoContrato__c gsc : lstTipoPagamentoGarantiaSeguradoContrato) {
            setGarantiaProdutoId.add(gsc.GarantiaProduto__c);
        }    
        List<Contract> listContract = [SELECT id
                                            , Name
                                            , Segmento__c
                                            , StartDate
                                            , VigenciaFinal__c
                                            , TipoEndosso__c
                                            , Tipo__c
                                            , TipoContrato__c
                                            , (SELECT Id
                                                , Garantia__r.Sigla__c
                                                , FranquiaGarantia__c
                                                , FranquiaGarantia__r.Franquia__c
                                                , FranquiaGarantia__r.Franquia__r.CodigoFranquia__c
                                                , FranquiaGarantia__r.Franquia__r.Descricao__c
                                                , FranquiaGarantia__r.Franquia__r.Tipo__c
                                                , FranquiaGarantia__r.Franquia__r.LimiteMaximo__c
                                                , FranquiaGarantia__r.Franquia__r.LimiteMinimo__c
                                                , FranquiaGarantia__r.Franquia__r.Modelo__c
                                                FROM GarantiasContrato__r
                                            )
                                        FROM Contract
                                        WHERE Id IN :setIdContrato ];

        Map<String, GarantiaContrato__c> mapContratoGarantiaFranquia = new Map<String, GarantiaContrato__c>();

        for (Contract contrato : listContract) {
            if(contrato.GarantiasContrato__r!=null)
            for (GarantiaContrato__c gc : contrato.GarantiasContrato__r) {
                if(!mapContratoGarantiaFranquia.containsKey(contrato.id+'-'+gc.Garantia__r.Sigla__c))
                    mapContratoGarantiaFranquia.put(contrato.id+'-'+gc.Garantia__r.Sigla__c,gc);
            }
        }

        List<FranquiaGarantia__c> listFranquias = [SELECT Id
                                            , Name
                                            , Franquia__r.Descricao__c
                                            , GarantiaProduto__r.Garantia__r.Sigla__c
                                            , GarantiaProduto__c
                                            FROM FranquiaGarantia__c
                                            WHERE GarantiaProduto__c IN : setGarantiaProdutoId];




        if(lstGaranCtr.isEmpty()){
            objToReturn.retorno = 'Não foram encontradas garantias disponíveis.';
            return JSON.serialize(objToReturn);
        }else{
            List<garantiaTO> listGarantiasToReturn = new garantiaTO().dto(lstTipoPagamentoGarantiaSeguradoContrato);
            
            for(garantiaTO garantia : listGarantiasToReturn){
                if(mapContratoGarantiaFranquia.containskey(garantia.contratoId+'-'+garantia.sigla)){
                    garantia = new garantiaTO().dtoFranquia(garantia,mapContratoGarantiaFranquia.get(garantia.contratoId+'-'+garantia.sigla));
                }
            }
            
            List<contratoTO> listContratosToReturn = new contratoTO().dto(listContract);
            for(contratoTO contrato : listContratosToReturn){
                if(contratoxSegurado.containsKey(contrato.Id))
                contrato = new contratoTO().dtoSeguradoInfo(contrato,contratoxSegurado.get(contrato.Id));
            }

            System.debug('RETORNANDO COM SUCESSO PARA A TELA');
            objToReturn.retorno =null;
            objToReturn.garantias = listGarantiasToReturn;
            objToReturn.contratos = listContratosToReturn;
            objToReturn.franquias = new franquiaTO().dto(listFranquias);//NÃO VAI PRECISAR MOSTRAR TODAS AS POSSÍVEIS, MAS SE UM DIA PRECISAR JÁ ESTÁ INDO PARA O FRONT
            return JSON.serialize(objToReturn);
        }

    }

    public static Map<String,Object> setError(String mensagem){
        Map<String,Object> mapToReturn = new Map<String,Object>();
        mapToReturn.put('sucesso', false);
        mapToReturn.put('mensagem', mensagem);
        return mapToReturn;
    }

    public static Map<String,Object> criaCasoSinistroPlus(String pJSON) {
        if(String.isBlank(pJSON)) return setError('JSON NULO OU VAZIO');
        System.debug('pJSON: ' + pJSON);
        Map<String,Object> mapToReturn = new Map<String,Object>();
        Map<String,Object> mapParse = (Map<String,Object>) JSON.deserializeUntyped(pJSON);
        Map<String,List<garantiaTO>> contratoGarantiasSelecionadas = new Map<String,List<garantiaTO>>();
        Map<String,contratoTO> mapContratoTO = new Map<String,contratoTO>();
        //VARIAVEIS PARA INSERÇÃO
        List<Case> casosToCreate = new List<Case>();
        List<PagamentoGarantia__c> listGarantiaToInsert = new List<PagamentoGarantia__c>();

        System.debug('garantiasModificadas: ' + mapParse.get('garantiasModificadas'));
        System.debug('contratos: ' + mapParse.get('contratos'));
        //Map<String,garantiaTO> mpGarantia = (Map<String,garantiaTO>) JSON.deserialize(JSON.serialize(mapParse.get('garantiasModificadas')),Map<String,garantiaTO>.class);
        //Map<String,garantiaTO> mpGarantia = (Map<String,garantiaTO>) JSON.deserialize(JSON.serialize(mapParse.get('contratos')),Map<String,garantiaTO>.class);
        
        //System.debug('mpGarantia: ' + mpGarantia.values());


        try {
            System.debug('garantiasModificadas: ' + JSON.serialize(mapParse.get('garantiasModificadas')));
            //List<garantiaTO> listGarantiaTO = ((Map<String,garantiaTO>) JSON.deserialize(JSON.serialize(mapParse.get('garantiasModificadas')),Map<String,garantiaTO>.class)).values();
            List<garantiaTO> listGarantiaTO = (List<garantiaTO>) JSON.deserialize(JSON.serialize(mapParse.get('garantiasModificadas')),List<garantiaTO>.class);
            List<contratoTO> listContratoTO = (List<contratoTO>) JSON.deserialize(JSON.serialize(mapParse.get('contratos')),List<contratoTO>.class);
            System.debug('listGarantiaTO: ' + listGarantiaTO);
            System.debug('listContratoTO: ' + listContratoTO);

            String tipoEvento = (String) mapParse.get('tipoEvento');
            String recordId = (String) mapParse.get('recordId');
            String REC_ID_FILHO = '';
            System.debug('tipoEvento: ' + tipoEvento);
            System.debug('recordId: ' + recordId);
            
            for(contratoTO cont : listContratoTO){
                mapContratoTO.put(cont.id,cont);
            }

            Case caso = [SELECT Id , AccountId, Account.Name, Dataocorrencia__c, Vitima__c, Subject, Description, ContactId, Type, Origin, Parceiro__c
                        FROM Case
                        WHERE Id = :recordId];
            
            if(caso.Type == 'Sinistro') {
                REC_ID_FILHO = RecordTypeBO.buscarTipoRegistro('Case', 'Sinistro').Id;
            } else if(caso.Type == 'Benefício') {
                REC_ID_FILHO = RecordTypeBO.buscarTipoRegistro('Case', 'Beneficio').Id;
            }
            System.debug('REC_ID_FILHO: ' + REC_ID_FILHO);


            for(garantiaTO garantia : listGarantiaTO){
                if(garantia.selecionado==true){
                    if(!contratoGarantiasSelecionadas.containsKey(garantia.contratoId))
                    contratoGarantiasSelecionadas.put(garantia.contratoId, new List<garantiaTO>());

                    contratoGarantiasSelecionadas.get(garantia.contratoId).add(garantia);
                }
            }
            System.debug('contratoGarantiasSelecionadas: ' + contratoGarantiasSelecionadas);
            
            
            for(Id contratoId :contratoGarantiasSelecionadas.keySet()){
                Case casoFilho = new Case();
                
                casoFilho.RecordTypeId = REC_ID_FILHO;
                casoFilho.AccountId = caso.AccountId;
                casoFilho.ContactId = caso.ContactId;
                casoFilho.ParentId = caso.Id;
                casoFilho.Dataocorrencia__c = caso.Dataocorrencia__c;
                casoFilho.Vitima__c = caso.Vitima__c;
                casoFilho.Segurado_do_contrato__c = mapContratoTO.get(contratoId).seguradoId;
                casoFilho.Contrato__c = contratoId;
                casoFilho.Status = 'Avisar';
                casoFilho.Status_Dependente__c = 'Em Análise';
                casoFilho.Subject = caso.Subject;
                casoFilho.Description = caso.Description;
                casoFilho.Origin = String.isNotBlank(caso.Origin) ? caso.Origin : 'Atendimento';
                casoFilho.TipoEvento__c = tipoEvento;
                casoFilho.Type = caso.Type;
                casoFilho.Caso_Filho_Criado_Automaticamente__c = true;
                casoFilho.Parceiro__c = casoFilho.Origin == 'Prestadora' ? caso.Parceiro__c : null;

                casosToCreate.add(casoFilho);
            }
            try {
                insert casosToCreate;
            } catch (Exception e) {
                return setError('Erro ao inserir o caso: '+ e.getLineNumber()+' - '+e.getStackTraceString() +' - '+ e.getCause());
            }

            for(Case casoFilho :casosToCreate){
                for(garantiaTO garantia : contratoGarantiasSelecionadas.get(casoFilho.Contrato__c)){
                    //CRIAR LISTA DE PAGAMENTO GARANTIA A SER INSERIDOS
                    PagamentoGarantia__c garantiaSinistro = new PagamentoGarantia__c();
                    garantiaSinistro.Caso__c = casoFilho.Id;
                    garantiaSinistro.Garantia_do_segurado_do_contrato__c = garantia.Id;
                    garantiaSinistro.Fase__c = 'Aberto';
                    garantiaSinistro.Name = garantia.name;
                    garantiaSinistro.Capital__c = garantia.capital;

                    garantiaSinistro.Valor_indenizado__c = garantia.capital;
                    garantiaSinistro.ValorIndenizadoInicial__c = garantia.capital;
                    garantiaSinistro.QuantidadeDias__c = null;
                    garantiaSinistro.Franquias__c = null;
                    garantiaSinistro.FranquiaContrato__c = null;

                    if(garantia.liberardiasfranquia==true){
                        garantiaSinistro.Capital__c = calularCapitalDiasFranquia(garantia);
                        garantiaSinistro.QuantidadeDias__c = garantia.dias;
                        garantiaSinistro.Franquias__c = garantia.franquia;
                        garantiaSinistro.FranquiaContrato__c = garantia.descricaofranquia;
                    
                    }

                    listGarantiaToInsert.add(garantiaSinistro);
                }
            }
            try {
                insert listGarantiaToInsert;
            } catch (Exception e) {
                return setError('Erro ao inserir as garantias: '+ e.getLineNumber()+' - '+e.getStackTraceString() +' - '+ e.getCause());
            }
            

        } catch (Exception e) {
            return setError('Erro: '+ e.getLineNumber()+' - '+e.getStackTraceString() +' - '+ e.getCause() );
        }



        mapToReturn.put('sucesso',true);
        mapToReturn.put('mensagem','');
        mapToReturn.put('casos', casosToCreate);
        mapToReturn.put('garantias', listGarantiaToInsert);


        return mapToReturn;
    }



    public static Decimal calularCapitalDiasFranquia (garantiaTO garantia){
        Decimal valorToReturn = null;
        if(garantia.liberardiasfranquia){
            valorToReturn = (garantia.dias-garantia.franquia) > 0 ? (garantia.dias-garantia.franquia) * garantia.capital : 1;
        }
        return valorToReturn;
    }


    //INICIO REAPROVEITAMENTO DE FUNCIONALIDADE
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
        
        if(lstCaso[0].Dataocorrencia__c == null){
            retorno.add('Data de ocorrência não informada.');
        } 
        if(lstCaso[0].Type == null || lstCaso[0].Type == ''){
            retorno.add('Tipo de Caso não informado.');
        }
        if(lstCaso[0].Vitima__c == null || lstCaso[0].Vitima__c == ''){
            retorno.add('Vítima não informada');
        }
        if(lstCaso[0].Vitima__c != null && lstCaso[0].Type != null && lstCaso[0].Dataocorrencia__c != null ){
            retorno.add('Todos os campos foram preenchidos');
        }
        return retorno;
    }


    @AuraEnabled
    public static List<Case> validarSinistroDuplicado(String recordId, String tipoEvento){
        List<Case> listcasos = CasoDAO.getInstance().getCaseBySetId(new Set<Id>{recordId});
        Case caso = listcasos!=null && listcasos.size() > 0 ? listcasos[0] : new Case();
        
        List<SeguradoContrato__c> lstSeguradosContrato = [
            SELECT Id,GrupoContrato__r.ContratanteContrato__r.Contrato__c      
            FROM SeguradoContrato__c 
            WHERE Conta__c = :caso.AccountId
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
    //INICIO FIM DE FUNCIONALIDADE
}