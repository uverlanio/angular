/****
@description Classe contendo logica para atualizacao do orcamento
@author Diego Zampieri - Globant
@date 22/07/2020
-Classe criada por conta da historia PLV-3926    
*****/
public with sharing class EndossoAtualizaOrcamentoService {
    
    private EndossoAtualizaOrcamentoREST.Request req;

    public EndossoAtualizaOrcamentoService(EndossoAtualizaOrcamentoREST.Request req){
        this.req = req;
    }

    public EndossoOrcamentoResponse.ValidacaoOrcamentoTO atualizaEndosso(){
        EndossoOrcamentoResponse.ValidacaoOrcamentoTO retorno;

        EmissaoTO.PayloadTO payload = new EmissaoTO.PayloadTO();
        payload.ofertas = req.ofertas;
        
        system.debug('payload.ofertas: '+payload.ofertas);

        Map<String, EmissaoTO.RetornoCalculoTO> mapRetornoCalculo = new Map<String, EmissaoTO.RetornoCalculoTO>();
        Map<String, EmissaoTO.CoberturaTO> mapCoberturasGarantiaOrcamento = new Map<String, EmissaoTO.CoberturaTO>();
        Map<String, EmissaoTO.CoberturaTO> mapCoberturasGarantiaContratanteOrcamento = new Map<String, EmissaoTO.CoberturaTO>();
        Map<String, EmissaoTO.CoberturaTO> mapCoberturasGarantiaGrupoOrcamento = new Map<String, EmissaoTO.CoberturaTO>();
        Map<String, EmissaoTO.CoberturaTO> mapCoberturasGarantiaSeguradoOrcamento = new Map<String, EmissaoTO.CoberturaTO>();
        Map<String, Opportunity> mapOrcamento = new Map<String, Opportunity>();
        Map<String, ContratanteOrcamento__c> mapContratantes = new Map<String, ContratanteOrcamento__c>();
        Map<String, GrupoOrcamento__c> mapGrupo = new Map<String, GrupoOrcamento__c>();
        Map<String, SeguradoOrcamento__c> mapSegurado = new Map<String, SeguradoOrcamento__c>();

        for(EmissaoTO.OfertasTO ofertaEnt : payload.ofertas){
            for(EmissaoTO.RetornoCalculoTO rc : ofertaEnt.retornosCalculo){
                mapRetornoCalculo.put(rc.numeroOrcamento, rc);

                for(EmissaoTO.CoberturaTO coberturaOrc : rc.precificacao.coberturas){
                    mapCoberturasGarantiaOrcamento.put(coberturaOrc.sigla, coberturaOrc);
                }

                for(EmissaoTO.CoberturaTO coberturaContraOrc : rc.precificacao.contratantes[0].coberturas){
                    mapCoberturasGarantiaContratanteOrcamento.put(coberturaContraOrc.sigla, coberturaContraOrc);
                }

                for(EmissaoTO.CoberturaTO coberturaGrupoOrc : rc.precificacao.contratantes[0].grupos[0].coberturas){
                    mapCoberturasGarantiaGrupoOrcamento.put(coberturaGrupoOrc.sigla, coberturaGrupoOrc);
                }

                for(EmissaoTO.CoberturaTO coberturaSeguradoOrc : rc.precificacao.contratantes[0].grupos[0].segurados[0].coberturas){
                    mapCoberturasGarantiaSeguradoOrcamento.put(coberturaSeguradoOrc.sigla, coberturaSeguradoOrc);
                }
            }
        }

        List<Opportunity> lstOpp = [SELECT Id, Numero__c FROM Opportunity WHERE Numero__c = :mapRetornoCalculo.keySet()];
        
        String orcNum;
        for(Opportunity opp : lstOpp){
            mapOrcamento.put(opp.Numero__c, opp);
            orcNum = opp.Numero__c;
            Integer ordemContratante = 1;

            for(ContratanteOrcamento__c contOrc : [SELECT Id, Orcamento__c FROM ContratanteOrcamento__c WHERE Orcamento__c = :opp.Id]){
                
                mapContratantes.put(String.valueOf(ordemContratante),contOrc);
                
                Integer ordemGrupo = 1;
                
                for(GrupoOrcamento__c grupoOrc : [SELECT Id, ContratanteOrcamento__c FROM GrupoOrcamento__c WHERE ContratanteOrcamento__c = :contOrc.Id]){
                    
                    mapGrupo.put(String.valueOf(ordemGrupo),grupoOrc);

                    Integer ordemSegurado = 1;

                    for(SeguradoOrcamento__c seguradoOrc : [SELECT Id, GrupoOrcamento__c FROM SeguradoOrcamento__c WHERE GrupoOrcamento__c = :grupoOrc.Id]){

                        mapSegurado.put(String.valueOf(ordemSegurado),seguradoOrc);

                        ordemSegurado++;
                    }

                    ordemGrupo++;
                }

                ordemContratante++;
            }
        }

        System.debug('mapSegurado '+ JSON.serialize(mapSegurado));

        Map<Id,Opportunity> mapOppUp = new Map<Id,Opportunity>();
        Map<Id,ContratanteOrcamento__c> mapContUp = new Map<Id,ContratanteOrcamento__c>();
        Map<Id,GrupoOrcamento__c> mapGrupUp = new Map<Id,GrupoOrcamento__c>();
        Map<Id,SeguradoOrcamento__c> mapSegUp = new Map<Id,SeguradoOrcamento__c>();

        for(EmissaoTO.RetornoCalculoTO retornoCalculo : mapRetornoCalculo.values()){

            if(!mapOrcamento.containsKey(retornoCalculo.numeroOrcamento)) continue;
            if(retornoCalculo.precificacao == null) continue;

            Opportunity opp = new Opportunity();

            opp.Id = mapOrcamento.get(retornoCalculo.numeroOrcamento).Id;
            opp.StageName = 'Disponível para contratação';
            opp.Juros__c = retornoCalculo.precificacao.juros;
            opp.Iof__c = retornoCalculo.precificacao.iof;
            opp.Encargos__c = retornoCalculo.precificacao.encargos;
            opp.CustoApolice__c = retornoCalculo.precificacao.custoApolice;
            if(retornoCalculo.precificacao.premio != null){
                opp.PremioIntegral__c = retornoCalculo.precificacao.premio.integral; //PLV-5351 INICIO/FIM
                opp.PremioComercial__c = retornoCalculo.precificacao.premio.comercial;
                opp.PremioPuro__c = retornoCalculo.precificacao.premio.puro;
                opp.PremioTotal__c = retornoCalculo.precificacao.premio.total;
            }
            System.debug('opp.PremioIntegral__c ' + opp.PremioIntegral__c);
            if(retornoCalculo.precificacao.descontoAgravo != null) {
                for(EmissaoTO.DescontoAgravoTO descontoAgravo : retornoCalculo.precificacao.descontoAgravo) {
                    if(descontoAgravo.tipo == 'TEC') {
                        opp.DescontoAgravoPercentualTecnico__c = descontoAgravo.percentual;
                        opp.DescontoAgravoMonetarioTecnico__c  = descontoAgravo.monetario;
                    }
                    else if(descontoAgravo.tipo == 'COM') {
                        opp.DescontoAgravoPercentualComercial__c = descontoAgravo.percentual;
                        opp.DescontoAgravoMonetarioComercial__c  = descontoAgravo.monetario;
                    }
                    else if(descontoAgravo.tipo == 'BAT') {
                        opp.DescontoAgravoPercentualInformado__c = descontoAgravo.percentual;
                        opp.DescontoAgravoMonetarioInformado__c  = descontoAgravo.monetario;
                    }
                }
            }

            mapOppUp.put(opp.Id, opp);

            if(retornoCalculo.precificacao.contratantes.isEmpty()) continue;

            for(EmissaoTO.ContratanteTO contratante : retornoCalculo.precificacao.contratantes){

                if(!mapContratantes.containsKey(contratante.numero)) continue;

                ContratanteOrcamento__c contraOpp = new ContratanteOrcamento__c();

                contraOpp.Id = mapContratantes.get(contratante.numero).Id;
                contraOpp.IOF__c = contratante.iof;
                if(contratante.premio != null){
                    contraOpp.PremioIntegral__c = contratante.premio.integral; //PLV-5351 INICIO/FIM
                    contraOpp.PremioComercial__c = contratante.premio.comercial;
                    contraOpp.PremioPuro__c = contratante.premio.puro;
                    contraOpp.PremioTotal__c = contratante.premio.total;
                }
                System.debug('contraOpp.PremioIntegral__c ' + contraOpp.PremioIntegral__c);
                if(contratante.descontoAgravo != null) {
                    for(EmissaoTO.DescontoAgravoTO descontoAgravoCont : contratante.descontoAgravo) {
                        if(descontoAgravoCont.tipo == 'TEC') {
                            contraOpp.DescontoAgravoPercentualTecnico__c = descontoAgravoCont.percentual;
                            contraOpp.DescontoAgravoMonetarioTecnico__c  = descontoAgravoCont.monetario;
                        }
                        else if(descontoAgravoCont.tipo == 'COM') {
                            contraOpp.DescontoAgravoPercentualComercial__c = descontoAgravoCont.percentual;
                            contraOpp.DescontoAgravoMonetarioComercial__c  = descontoAgravoCont.monetario;
                        }
                        else if(descontoAgravoCont.tipo == 'BAT') {
                            contraOpp.DescontoAgravoPercentualInformado__c = descontoAgravoCont.percentual;
                            contraOpp.DescontoAgravoMonetarioInformado__c  = descontoAgravoCont.monetario;
                        }
                    }
                }

                mapContUp.put(contraOpp.Id, contraOpp);

                for(EmissaoTO.GrupoTO grupo : contratante.grupos){

                    if(!mapGrupo.containsKey(grupo.numero)) continue;

                    GrupoOrcamento__c grupOrc = new GrupoOrcamento__c();

                    grupOrc.Id = mapGrupo.get(grupo.numero).Id;
                    grupOrc.IOF__c = grupo.iof;
                    if(grupo.premio != null){
                        grupOrc.PremioIntegral__c = grupo.premio.integral; //PLV-5351 INICIO/FIM
                        grupOrc.PremioComercial__c = grupo.premio.comercial;
                        grupOrc.PremioPuro__c = grupo.premio.puro;
                        grupOrc.PremioTotal__c = grupo.premio.total;
                    }
                    System.debug('grupOrc.PremioIntegral__c' + grupOrc.PremioIntegral__c);
                    if(grupo.descontoAgravo != null) {
                        for(EmissaoTO.DescontoAgravoTO descontoAgravoGruop : grupo.descontoAgravo) {
                            if(descontoAgravoGruop.tipo == 'TEC') {
                                grupOrc.DescontoAgravoPercentualTecnico__c = descontoAgravoGruop.percentual;
                                grupOrc.DescontoAgravoMonetarioTecnico__c  = descontoAgravoGruop.monetario;
                            }
                            else if(descontoAgravoGruop.tipo == 'COM') {
                                grupOrc.DescontoAgravoPercentualComercial__c = descontoAgravoGruop.percentual;
                                grupOrc.DescontoAgravoMonetarioComercial__c  = descontoAgravoGruop.monetario;
                            }
                            else if(descontoAgravoGruop.tipo == 'BAT') {
                                grupOrc.DescontoAgravoPercentualInformado__c = descontoAgravoGruop.percentual;
                                grupOrc.DescontoAgravoMonetarioInformado__c  = descontoAgravoGruop.monetario;
                            }
                        }
                    }

                    mapGrupUp.put(grupOrc.Id, grupOrc);

                    for(EmissaoTO.SeguradoTO segurado : grupo.segurados){

                        if(!mapSegurado.containsKey(segurado.numero)) continue;

                        SeguradoOrcamento__c segOrc = new SeguradoOrcamento__c();

                        segOrc.Id = mapSegurado.get(segurado.numero).Id;
                        segOrc.IOF__c = segurado.iof;
                        if(segurado.premio != null){
                            segOrc.PremioIntegral__c = segurado.premio.Integral; //PLV-5351 INICIO/FIM
                            segOrc.PremioComercial__c = segurado.premio.comercial; 
                            segOrc.PremioPuro__c = segurado.premio.puro;
                            segOrc.PremioTotal__c = segurado.premio.total;
                        }
                        System.debug('segOrc.PremioIntegral__c' + segOrc.PremioIntegral__c);
                        if(segurado.descontoAgravo != null) {
                            for(EmissaoTO.DescontoAgravoTO descontoAgravoSeg : segurado.descontoAgravo) {
                                if(descontoAgravoSeg.tipo == 'TEC') {
                                    segOrc.DescontoAgravoPercentualTecnico__c = descontoAgravoSeg.percentual;
                                    segOrc.DescontoAgravoMonetarioTecnico__c  = descontoAgravoSeg.monetario;
                                }
                                else if(descontoAgravoSeg.tipo == 'COM') {
                                    segOrc.DescontoAgravoPercentualComercial__c = descontoAgravoSeg.percentual;
                                    segOrc.DescontoAgravoMonetarioComercial__c  = descontoAgravoSeg.monetario;
                                }
                                else if(descontoAgravoSeg.tipo == 'BAT') {
                                    segOrc.DescontoAgravoPercentualInformado__c = descontoAgravoSeg.percentual;
                                    segOrc.DescontoAgravoMonetarioInformado__c  = descontoAgravoSeg.monetario;
                                }
                            }
                        }

                        mapSegUp.put(segOrc.Id,segOrc);
                    }
                }
            }
        }

        List<GarantiaOrcamento__c> lstGaranOrcUp = new List<GarantiaOrcamento__c>();
        List<GarantiaContratanteOrcamento__c> lstGaranOrcConUp = new List<GarantiaContratanteOrcamento__c>();
        List<GarantiaGrupoOrcamento__c> lstGaranOrcGrupoUp = new List<GarantiaGrupoOrcamento__c>();
        List<GarantiaSeguradoOrcamento__c> lstGaranOrcSegUp = new List<GarantiaSeguradoOrcamento__c>();

        for(GarantiaOrcamento__c garanOrc : [SELECT Id, Garantia__r.Sigla__c FROM GarantiaOrcamento__c WHERE Orcamento__c = :mapOppUp.keySet()]){
            
            if(!mapCoberturasGarantiaOrcamento.containsKey(garanOrc.Garantia__r.Sigla__c)) continue;

            GarantiaOrcamento__c garan = new GarantiaOrcamento__c();
            
            garan.Id = garanOrc.Id;

            EmissaoTO.CoberturaTO cobertura = mapCoberturasGarantiaOrcamento.get(garanOrc.Garantia__r.Sigla__c);
            garan.IOF__c = cobertura.iof!=null ? cobertura.iof : 0;//PLV-4689 - INICIO/FIM - PEDRO AUGUSTO BRAZ - SYS4B
            if(cobertura.premio != null){
                garan.PremioIntegral__c  = cobertura.premio.integral; //PLV-5351 INICIO/FIM
                garan.PremioComercial__c = cobertura.premio.comercial;
                garan.PremioPuro__c      = cobertura.premio.puro;
                garan.PremioTotal__c     = cobertura.premio.total;
            }
            System.debug('garan.PremioIntegral__c 1' + garan.PremioIntegral__c);
            if(cobertura.taxa != null){
                garan.TaxaComercial__c   = cobertura.taxa.comercial;
                garan.TaxaPura__c        = cobertura.taxa.pura;
                garan.TaxaTotal__c       = cobertura.taxa.total;
            }

            if(cobertura.descontoAgravo != null) {
                for(EmissaoTO.DescontoAgravoTO descontoAgravo : cobertura.descontoAgravo) {
                    if(descontoAgravo.tipo == 'TEC') {
                        garan.DescontoAgravoPercentualTecnico__c = descontoAgravo.percentual;
                        garan.DescontoAgravoMonetarioTecnico__c  = descontoAgravo.monetario;
                    }
                    else if(descontoAgravo.tipo == 'COM') {
                        garan.DescontoAgravoPercentualComercial__c = descontoAgravo.percentual;
                        garan.DescontoAgravoMonetarioComercial__c  = descontoAgravo.monetario;
                    }
                    else if(descontoAgravo.tipo == 'BAT') {
                        garan.DescontoAgravoPercentualInformado__c = descontoAgravo.percentual;
                        garan.DescontoAgravoMonetarioInformado__c  = descontoAgravo.monetario;
                    }
                }
            }

            lstGaranOrcUp.add(garan);
        }

        for(GarantiaContratanteOrcamento__c garanConOrc : [SELECT Id, Garantia__r.Sigla__c FROM GarantiaContratanteOrcamento__c WHERE ContratanteOrcamento__c = :mapContUp.keySet()]){
            
            if(!mapCoberturasGarantiaContratanteOrcamento.containsKey(garanConOrc.Garantia__r.Sigla__c)) continue;

            GarantiaContratanteOrcamento__c garan = new GarantiaContratanteOrcamento__c();

            garan.Id = garanConOrc.Id;

            EmissaoTO.CoberturaTO cobertura = mapCoberturasGarantiaContratanteOrcamento.get(garanConOrc.Garantia__r.Sigla__c);
            garan.IOF__c = cobertura.iof!=null ? cobertura.iof : 0;//PLV-4689 - INICIO/FIM - PEDRO AUGUSTO BRAZ - SYS4B
            if(cobertura.premio != null){
                garan.PremioIntegral__c  = cobertura.premio.integral; //PLV-5351 INICIO/FIM
                garan.PremioComercial__c = cobertura.premio.comercial;
                garan.PremioPuro__c      = cobertura.premio.puro;
                garan.PremioTotal__c     = cobertura.premio.total;
            }
            System.debug('garan.PremioIntegral__c 2' + garan.PremioIntegral__c);
            if(cobertura.taxa != null){
                garan.TaxaComercial__c   = cobertura.taxa.comercial;
                garan.TaxaPura__c        = cobertura.taxa.pura;
                garan.TaxaTotal__c       = cobertura.taxa.total;
            }

            if(cobertura.descontoAgravo != null) {
                for(EmissaoTO.DescontoAgravoTO descontoAgravo : cobertura.descontoAgravo) {
                    if(descontoAgravo.tipo == 'TEC') {
                        garan.DescontoAgravoPercentualTecnico__c = descontoAgravo.percentual;
                        garan.DescontoAgravoMonetarioTecnico__c  = descontoAgravo.monetario;
                    }
                    else if(descontoAgravo.tipo == 'COM') {
                        garan.DescontoAgravoPercentualComercial__c = descontoAgravo.percentual;
                        garan.DescontoAgravoMonetarioComercial__c  = descontoAgravo.monetario;
                    }
                    else if(descontoAgravo.tipo == 'BAT') {
                        garan.DescontoAgravoPercentualInformado__c = descontoAgravo.percentual;
                        garan.DescontoAgravoMonetarioInformado__c  = descontoAgravo.monetario;
                    }
                }
            }

            lstGaranOrcConUp.add(garan);
        }

        for(GarantiaGrupoOrcamento__c garanGruOrc : [SELECT Id, Garantia__r.Sigla__c FROM GarantiaGrupoOrcamento__c WHERE GrupoOrcamento__c = :mapGrupUp.keySet()]){
            
            if(!mapCoberturasGarantiaGrupoOrcamento.containsKey(garanGruOrc.Garantia__r.Sigla__c)) continue;

            GarantiaGrupoOrcamento__c garan = new GarantiaGrupoOrcamento__c();

            garan.Id = garanGruOrc.Id;

            EmissaoTO.CoberturaTO cobertura = mapCoberturasGarantiaGrupoOrcamento.get(garanGruOrc.Garantia__r.Sigla__c);
            garan.IOF__c = cobertura.iof!=null ? cobertura.iof : 0;//PLV-4689 - INICIO/FIM - PEDRO AUGUSTO BRAZ - SYS4B
            if(cobertura.premio != null){
                garan.PremioIntegral__c  = cobertura.premio.integral; //PLV-5351 INICIO/FIM
                garan.PremioComercial__c = cobertura.premio.comercial;
                garan.PremioPuro__c      = cobertura.premio.puro;
                garan.PremioTotal__c     = cobertura.premio.total;
            }
            System.debug('garan.PremioIntegral__c 3' + garan.PremioIntegral__c);
            if(cobertura.taxa != null){
                garan.TaxaComercial__c   = cobertura.taxa.comercial;
                garan.TaxaPura__c        = cobertura.taxa.pura;
                garan.TaxaTotal__c       = cobertura.taxa.total;
            }

            if(cobertura.descontoAgravo != null) {
                for(EmissaoTO.DescontoAgravoTO descontoAgravo : cobertura.descontoAgravo) {
                    if(descontoAgravo.tipo == 'TEC') {
                        garan.DescontoAgravoPercentualTecnico__c = descontoAgravo.percentual;
                        garan.DescontoAgravoMonetarioTecnico__c  = descontoAgravo.monetario;
                    }
                    else if(descontoAgravo.tipo == 'COM') {
                        garan.DescontoAgravoPercentualComercial__c = descontoAgravo.percentual;
                        garan.DescontoAgravoMonetarioComercial__c  = descontoAgravo.monetario;
                    }
                    else if(descontoAgravo.tipo == 'BAT') {
                        garan.DescontoAgravoPercentualInformado__c = descontoAgravo.percentual;
                        garan.DescontoAgravoMonetarioInformado__c  = descontoAgravo.monetario;
                    }
                }
            }

            lstGaranOrcGrupoUp.add(garan);
        }

        for(GarantiaSeguradoOrcamento__c garanSegOrc : [SELECT Id, Garantia__r.Sigla__c FROM GarantiaSeguradoOrcamento__c WHERE SeguradoOrcamento__c = :mapSegUp.keySet()]){
            
            if(!mapCoberturasGarantiaSeguradoOrcamento.containsKey(garanSegOrc.Garantia__r.Sigla__c)) continue;

            GarantiaSeguradoOrcamento__c garan = new GarantiaSeguradoOrcamento__c();

            garan.Id = garanSegOrc.Id;

            EmissaoTO.CoberturaTO cobertura = mapCoberturasGarantiaSeguradoOrcamento.get(garanSegOrc.Garantia__r.Sigla__c);
            garan.IOF__c = cobertura.iof!=null ? cobertura.iof : 0;//PLV-4689 - INICIO/FIM - PEDRO AUGUSTO BRAZ - SYS4B

            if(cobertura.premio != null){
                garan.PremioIntegral__c  = cobertura.premio.integral;  //PLV-5351 INICIO/FIM
                garan.PremioComercial__c = cobertura.premio.comercial; 
                garan.PremioPuro__c      = cobertura.premio.puro;
                garan.PremioTotal__c     = cobertura.premio.total;
            }
            System.debug('garan.PremioIntegral__c 4' + garan.PremioIntegral__c);
            if(cobertura.taxa != null){
                garan.TaxaComercial__c   = cobertura.taxa.comercial;
                garan.TaxaPura__c        = cobertura.taxa.pura;
                garan.TaxaTotal__c       = cobertura.taxa.total;
            }

            if(cobertura.descontoAgravo != null) {
                for(EmissaoTO.DescontoAgravoTO descontoAgravo : cobertura.descontoAgravo) {
                    if(descontoAgravo.tipo == 'TEC') {
                        garan.DescontoAgravoPercentualTecnico__c = descontoAgravo.percentual;
                        garan.DescontoAgravoMonetarioTecnico__c  = descontoAgravo.monetario;
                    }
                    else if(descontoAgravo.tipo == 'COM') {
                        garan.DescontoAgravoPercentualComercial__c = descontoAgravo.percentual;
                        garan.DescontoAgravoMonetarioComercial__c  = descontoAgravo.monetario;
                    }
                    else if(descontoAgravo.tipo == 'BAT') {
                        garan.DescontoAgravoPercentualInformado__c = descontoAgravo.percentual;
                        garan.DescontoAgravoMonetarioInformado__c  = descontoAgravo.monetario;
                    }
                }
            }

            lstGaranOrcSegUp.add(garan);
        }

        if(!lstGaranOrcSegUp.isEmpty()) update lstGaranOrcSegUp;
        if(!mapSegUp.isEmpty()) update mapSegUp.values();
        if(!lstGaranOrcGrupoUp.isEmpty()) update lstGaranOrcGrupoUp;
        if(!mapGrupUp.isEmpty()) update mapGrupUp.values();
        if(!lstGaranOrcConUp.isEmpty()) update lstGaranOrcConUp;
        if(!mapContUp.isEmpty()) update mapContUp.values();
        if(!lstGaranOrcUp.isEmpty()) update lstGaranOrcUp;
        if(!mapOppUp.isEmpty()) update mapOppUp.values();

        retorno = this.montarRetorno(orcNum);

        return retorno;
    }

    public EndossoOrcamentoResponse.ValidacaoOrcamentoTO montarRetorno(String orcNum){
        EndossoOrcamentoResponse.ValidacaoOrcamentoTO retornoVal = new EndossoOrcamentoResponse.ValidacaoOrcamentoTO();
        retornoVal.devolutivas = new List<EndossoOrcamentoResponse.DevolutivasTO>();
        retornoVal.ofertas = new List<EndossoOrcamentoResponse.OfertasTO>();

        EndossoOrcamentoResponse.DevolutivasTO devolutiva = new EndossoOrcamentoResponse.DevolutivasTO();

        EndossoOrcamentoResponse.OfertasTO oferta = new EndossoOrcamentoResponse.OfertasTO();
        oferta.orcamento = new EndossoOrcamentoResponse.OrcamentoAtualizadoTO();

        Opportunity orc = [SELECT Id, StageName, Contract.NumeroApolice__c, Contract.RamoSeguro__r.Codigo__c, Type, TipoEndosso__c, VigenciaInicial__c, VigenciaFinal__c, DataCalculo__c, Numero__c, MeioComercializacao__c, Contract.Empresa__c, Contract.Sucursal__c FROM Opportunity WHERE Numero__c = :orcNum LIMIT 1];
		
        system.debug('orc: '+orc);
        
        devolutiva.codigo = 0;
        devolutiva.origem = 'INT';
        devolutiva.tipoRegistro = 1;
        devolutiva.numeroCampo = 0;
        devolutiva.descricao = 'EMISSÃO: - registro inserido/atualizado com sucesso.';

        retornoVal.devolutivas.add(devolutiva);

        oferta.orcamento.status = orc.StageName;
        oferta.orcamento.apolice = Integer.valueOf(orc.Contract.NumeroApolice__c);
        oferta.orcamento.ramo = Integer.valueOf(orc.Contract.RamoSeguro__r.Codigo__c);
        oferta.orcamento.tipoSeguro = orc.Type;
        oferta.orcamento.tipoAdesao = orc.TipoEndosso__c;
        oferta.orcamento.vigenciaFinal = String.valueOf(orc.VigenciaFinal__c);
        oferta.orcamento.empresa = Integer.valueOf(orc.Contract.Empresa__c);
        oferta.orcamento.dataCalculo = String.valueOf(orc.DataCalculo__c);
        oferta.orcamento.sucursal = Integer.valueOf(orc.Contract.Sucursal__c);
        oferta.orcamento.vigenciaInicial = String.valueOf(orc.VigenciaInicial__c);
        oferta.orcamento.numeroOrcamento = Integer.valueOf(orc.Numero__c);
        oferta.orcamento.meioComercializacao = orc.MeioComercializacao__c;
        oferta.orcamento.qtdDiasVigencia = orc.VigenciaInicial__c.daysBetween(orc.VigenciaFinal__c);

        retornoVal.ofertas.add(oferta);

        return retornoVal;
    }
}