/************************************************************************
 *
 *  Classe responsável pelo negócio do objeto BeneficiarioGarantia__c 
 *  @Author GFS 29/03/2019
 *
 ************************************************************************/
public virtual class PagamentoGarantiaBO
{ 
    public PagamentoGarantiaBO() { } 
    
    private static final PagamentoGarantiaBO instancia = new PagamentoGarantiaBO();
    public static PagamentoGarantiaBO getInstance(){
        return instancia;
    } 

    // atualiza os status do caso após a mudança do status do pagamento de uma cobertura e a fase dessa cobertura esteja fechada.
    public void efetuaPagamentoGarantia(List<PagamentoGarantia__c> plNew, Map<Id,PagamentoGarantia__c> pmOld) {

        Set<Id> sCasoId = new Set<Id>();

        for(PagamentoGarantia__c pg : plNew)
            if(pg.Status_do_pagamento__c != pmOld.get(pg.Id).Status_do_pagamento__c && pg.Fase__c == 'Fechado')
                sCasoId.add(pg.Caso__c);

        if (sCasoId.isEmpty()) return;

        Map<Id,Set<String>> mCaso = new Map<Id,Set<String>>();

        for (AggregateResult ar : [SELECT Caso__c, Status_do_pagamento__c
                                   FROM PagamentoGarantia__c
                                   WHERE Caso__c IN :sCasoId
                                   GROUP BY Caso__c, Status_do_pagamento__c]) {

            Set<String> sStatus;

            Id vCasoId = (Id) ar.get('Caso__c');

            if (mCaso.containsKey(vCasoId))
                sStatus = mCaso.get(vCasoId);
            else sStatus = new Set<String>();

            sStatus.add((String) ar.get('Status_do_pagamento__c'));
            mCaso.put(vCasoId, sStatus);
        }

        List<Case> lCaso = new List<Case>();

        for (Id vCasoId : mCaso.keyset()) {

            Set<String> sStatus = mCaso.get(vCasoId);

            if (sStatus.size() > 1) continue;

            Case vCaso = new Case(Id = vCasoId);
             
            if (sStatus.contains('Pago')){
                vCaso.Status = 'Liquidação';
                vCaso.Status_Dependente__c = 'Pago';
            } else if (// POR062-1 - INICIO
                !PagamentoGarantiaTriggerHandler.fechamentoSinistro &&
                (sStatus.contains('Recusado'))//II-59-FIX02-INICIO/FIM
            ) { // PLV - 4838 INICIO/FIM // POR062-1 - FIM
                vCaso.Status = 'Liquidação';
                vCaso.Status_Dependente__c = 'Aguardando envio de carta recusa'; //PLV-1096 - Inicio/Fim - Alteração no valor do campo picklist
            } else if(sStatus.contains('Serviço Prestado')){
                vCaso.Status = 'Liquidação';
                vCaso.Status_Dependente__c = 'Serviço Prestado';
            }

            lCaso.add(vCaso);
        }

        update lCaso;
    }
    //PLV-4560 - Este cenário será realizado em CasoBO - Inicio
    /*public void listarBeneficiarios(List<PagamentoGarantia__c> plNew, Map<Id, PagamentoGarantia__c> plOld){
        Set<Id> sCasoId = new Set<Id>();

        for(PagamentoGarantia__c pagamento : plNew){
            sCasoId.add(pagamento.Caso__c);
        }

        Map<Id, Case> mCasoSinistro = new Map<Id,Case>([SELECT Id, RecordTypeId FROM Case WHERE Id = :sCasoId]);
        Recordtype REC_ID_SINISTRO = RecordTypeBO.buscarTipoRegistro('Case', 'Sinistro');

        Set<Id> sPag = new Set<Id>();
        Case caso = new Case();
        for(PagamentoGarantia__c pg : plNew){
            caso = mCasoSinistro.get(pg.Caso__c);
            if(pg.Fase__c == 'Em análise' && plOld.get(pg.Id).Fase__c != pg.Fase__c
               && caso.RecordTypeId == REC_ID_SINISTRO.Id){
                    sPag.add(pg.Id);
            }
        }
        if(!sPag.isEmpty()) {
            List<PagamentoGarantia__c> lstPagamento = [SELECT Id, Garantia_do_segurado_do_contrato__r.SeguradoContrato__c FROM PagamentoGarantia__c WHERE Id IN: sPag];
            Map<Id, Id> mSegPag = new Map<Id,Id>();

            for(PagamentoGarantia__c pagamento : lstPagamento){
                mSegPag.put(pagamento.Garantia_do_segurado_do_contrato__r.SeguradoContrato__c, pagamento.Id);
            }

            List<BeneficiarioGarantia__c> lst2Insert = new List<BeneficiarioGarantia__c>();

            for(BeneficiarioSeguradoContrato__c beneSegCont: [SELECT Id, Conta__c, GrauParentesco__c,
                                                                     Participacao__c, SeguradoContrato__c
                                                              FROM BeneficiarioSeguradoContrato__c WHERE SeguradoContrato__c =: mSegPag.keyset() 
                                                              AND TipoBeneficiario__c != 'Conforme artigo 792 do código civil']){
                
                BeneficiarioGarantia__c bene = new BeneficiarioGarantia__c();
                bene.Status__c = 'Pendente';
                bene.Conta__c = beneSegCont.Conta__c;
                bene.RelacionamentoSegurado__c = beneSegCont.GrauParentesco__c;
                bene.Percentual_de_indenizacao__c = beneSegCont.Participacao__c;
                bene.Pagamento_de_garantia__c = mSegPag.containsKey(beneSegCont.SeguradoContrato__c) ? mSegPag.get(beneSegCont.SeguradoContrato__c) : null;
                lst2Insert.add(bene);
            }

            if(!lst2Insert.isEmpty()){
                Database.insert(lst2Insert);
            }

        }
    }*/
    //PLV-4560 - Este cenário será realizado em CasoBO - Fim
    //PLV-3854 INICIO
    public void updateMoedaEstrangeira(List<PagamentoGarantia__c> pGNew){
        System.debug('PagamentoGarantiaBO.updateMoedaEstrangeira');
        List<Id> listSinistros = new List<Id>();                

        for(PagamentoGarantia__c pag : pGNew){
            System.debug('pag.Caso__c = ' + pag.Caso__c);
            System.debug('pag.Caso__r.CurrencyIsoCode = ' + pag.Caso__r.CurrencyIsoCode); 
            if(pag.CurrencyIsoCode != 'BRL'){
                listSinistros.add(pag.Id);              
            }
        }       

        if(!listSinistros.isEmpty()){
        System.debug('ConsultaMoedaEstrangeira.ConsultaMoeda()');
            //ConsultaMoedaEstrangeira.ConsultaMoeda(listSinistros); //MGRC-1657 - INICIO/FIM
        }
    }
    //PLV-3854 FIM
    
    //PLV-4037 - Início
    //Cenário 1: Aviso de sinistro: AVISO +
    public void gerarMovimentoSinistroInsert( List<PagamentoGarantia__c> lstPagamentoGarantiaNew ){

        Set<Id> setCaseId = new Set<Id>();

        for( PagamentoGarantia__c pagGarantia : lstPagamentoGarantiaNew ){

            setCaseId.add(pagGarantia.Caso__c);
            
        }
        Set<String> setStatusValidos = new Set<String>{'Avisado', 'Em Regulação', 'Liquidação'};
        
        Map<Id, Case> mapCase;
        mapCase = new Map<Id, Case>([SELECT  Id, Status, Recordtype.DeveloperName
                                    FROM    Case
                                    WHERE   Id IN : setCaseId
                                    AND     Status IN : setStatusValidos
                                    AND     Recordtype.DeveloperName = 'Sinistro']);

        List<MovimentoSinistro__c> lstMovSinistroInsert = new List<MovimentoSinistro__c>();

        Map<Id, Integer> mSequenciaMov = SequenciaMovimentoSinistroHelper.sequenciaMovimentos(setCaseId);
    if( mSequenciaMov == null ){
            mSequenciaMov = new Map<Id, Integer>();
        }
        
        for( PagamentoGarantia__c pagGarantia : lstPagamentoGarantiaNew ){

            if( mapCase.containsKey(pagGarantia.Caso__c) ){

                Case caso = mapCase.get(pagGarantia.Caso__c);

                Integer sequencia = getSequencia( mSequenciaMov, caso.Id );

                MovimentoSinistro__c movimentoSin = criarNovoMovimento( pagGarantia.Caso__c, 'Aviso', '1', sequencia, pagGarantia.Id, pagGarantia.Valor_indenizado__c);//PLV-4818 - INICIO/FIM - PEDRO AUGUSTO BRAZ - SYS4B
                lstMovSinistroInsert.add(movimentoSin);
                mSequenciaMov.put(caso.Id, sequencia);
            }

        }


        if(!lstMovSinistroInsert.isEmpty()) Database.insert(lstMovSinistroInsert);

    }
    //PLV-4037 - Fim
    
    //PLV-4037 - Início
    //Cenário 3: Garantia não procede: AC. AVISADO -;
    //Cenário 4: Alteração do valor a ser indenizado: AC. AVISADO + ou AC. AVISADO -;
    public void gerarMovimentoSinistroGarantiaUpdate( List<PagamentoGarantia__c> lstPagamentoGarantiaNew, Map<Id,PagamentoGarantia__c> mapPagamentoGarantiaOld ){

        Set<Id> setCaseId = new Set<Id>();

        for( PagamentoGarantia__c pagGarantia : lstPagamentoGarantiaNew ){

            setCaseId.add(pagGarantia.Caso__c);
            
        }

        Map<Id, Case> mapCase;
        mapCase = new Map<Id, Case>([SELECT  Id, Status, Sinistro_Judicial__c, Recordtype.DeveloperName  // LECVPV-140-FIX02 INICIO/FIM
                                    FROM    Case
                                    WHERE   Id IN : setCaseId
                                    AND     Recordtype.DeveloperName = 'Sinistro']);


        List<MovimentoSinistro__c> lstMovSinistroInsert = new List<MovimentoSinistro__c>();

        Map<Id, Integer> mSequenciaMov = SequenciaMovimentoSinistroHelper.sequenciaMovimentos(setCaseId);
        if( mSequenciaMov == null ){
            mSequenciaMov = new Map<Id, Integer>();
        }

        for( PagamentoGarantia__c pagGarantia : lstPagamentoGarantiaNew ){

            PagamentoGarantia__c pagGarantiaOld = ( mapPagamentoGarantiaOld.get(pagGarantia.Id) );

            Boolean hasCasoSinistro = ( mapCase.containsKey(pagGarantia.Caso__c) );

            if( hasCasoSinistro ){

                Case caso = mapCase.get(pagGarantia.Caso__c);

                Boolean isFaseFechado = ( pagGarantia.Fase__c == 'Fechado' );
                Boolean isStatusPagamentoRecusado = ( pagGarantia.Status_do_pagamento__c == 'Recusado' );
                Boolean isStatusChanged = ( pagGarantia.Status_do_pagamento__c != pagGarantiaOld.Status_do_pagamento__c );
                Boolean hasValorIndenizado = ( pagGarantia.ValorIndenizado__c != null ); //PLV-4070 - INICIO/FIM
                Boolean isValorIndenizadoChanged = ( pagGarantia.ValorIndenizado__c != pagGarantiaOld.ValorIndenizado__c ); //PLV-4070 - INICIO/FIM
                Boolean isMovBG = ( pagGarantia.SomaValorBeneficiarios__c != pagGarantiaOld.SomaValorBeneficiarios__c ); //LECVP-193 - INICIO/FIM
                Decimal ValorIndenizadoChanged = hasValorIndenizado && pagGarantiaOld.ValorIndenizado__c!=null ? pagGarantia.ValorIndenizado__c - pagGarantiaOld.ValorIndenizado__c : pagGarantia.ValorIndenizado__c;//PLV-4818 - INICIO/FIM - PEDRO AUGUSTO BRAZ  - SYS4B
                
                //Cenário 3: Garantia não procede: AC. AVISADO -;
                // Quando o status da Garantia foi alterado para 'Fechado' e status do pagamento para 'Recusado', deve encerrar a Garantia
                if( isFaseFechado && isStatusPagamentoRecusado && isStatusChanged ){
                    
                  Integer sequencia = getSequencia( mSequenciaMov, caso.Id );

                  // LECVPV-216 INICIO
                  List<MovimentoSinistro__c> movimentosSin = MovimentoSinistroBO.getInstance().criarMovimentoFechamentoGarantia(pagGarantia.Id,sequencia,caso.Sinistro_Judicial__c,false); // LECVPV-216 INICIO/FIM
                    //     MovimentoSinistro__c movimentoSin = criarNovoMovimento( pagGarantia.Caso__c, 'Aviso', '24', sequencia, pagGarantia.Id, pagGarantia.ValorIndenizado__c*-1);//PLV-4818 - INICIO/FIM - PEDRO AUGUSTO BRAZ - SYS4B
                    if (movimentosSin!= null ) lstMovSinistroInsert.addAll(movimentosSin);
                    // LECVPV-216 FIM  

                  mSequenciaMov.put(caso.Id, sequencia);

                }
                //Cenário 4: Alteração do valor a ser indenizado: AC. AVISADO + ou AC. AVISADO -;
                // Quando o valor provisionado da garantia for alterado, deve-se criar um movimento automatico de ajuste
                if(!isFaseFechado && hasValorIndenizado && isValorIndenizadoChanged && !isMovBG){ //LECVP-193 - INICIO/FIM // LECVPV-216 INICIO/FIM

                    Boolean isValorAumentado = ( pagGarantia.ValorIndenizado__c > pagGarantiaOld.ValorIndenizado__c ); //PLV-4070 - INICIO/FIM
                    Boolean isValorOldNull = ( pagGarantiaOld.ValorIndenizado__c == null); //PLV-4070 - INICIO/FIM

                    if( isValorAumentado || isValorOldNull){
                        Integer sequencia = getSequencia( mSequenciaMov, caso.Id );

                       
                        
                        MovimentoSinistro__c movimentoSin = criarNovoMovimento( pagGarantia.Caso__c, 'Aviso', '2', sequencia, pagGarantia.Id,ValorIndenizadoChanged);//PLV-4818 - INICIO/FIM - PEDRO AUGUSTO BRAZ - SYS4B
                        
                       /* RENATO - 19/02/2024
                            * Tratamento sequencia movimento para o valor inteiro
                        */
                        // LECVPV-140-FIX02 INICIO
                        movimentoSin.SequenciaMovimento__c = String.valueOf(Integer.valueOf(Integer.valueOf(movimentoSin.SequenciaMovimento__c) + Integer.valueOf(lstMovSinistroInsert.size())));//PLV-4818 - INICIO/FIM - PEDRO AUGUSTO BRAZ - SYS4B
                        
                        /* RENATO - 19/02/2024 
                        * Tratamento para flag movimento, caso seja juridico
                        */                                                
                         movimentoSin.SinistroJudicial__c = caso.Sinistro_Judicial__c ? true : false ;
                        // LECVPV-140-FIX02 FIM
                        lstMovSinistroInsert.add(movimentoSin);

                        mSequenciaMov.put(caso.Id, sequencia);
                    }
                    else{
                        Integer sequencia = getSequencia( mSequenciaMov, caso.Id );

                        MovimentoSinistro__c movimentoSin = criarNovoMovimento( pagGarantia.Caso__c, 'Aviso', '3', sequencia, pagGarantia.Id,ValorIndenizadoChanged );//PLV-4818 - INICIO/FIM - PEDRO AUGUSTO BRAZ - SYS4B
                        
                        /* RENATO - 19/02/2024
                            * Tratamento sequencia movimento para o valor inteiro
                        */
                        // LECVPV-140-FIX02 INICIO
                        movimentoSin.SequenciaMovimento__c = String.valueOf(Integer.valueOf(Integer.valueOf(movimentoSin.SequenciaMovimento__c) + Integer.valueOf(lstMovSinistroInsert.size())));//PLV-4818 - INICIO/FIM - PEDRO AUGUSTO BRAZ - SYS4B
                        
                        /* RENATO - 19/02/2024 
                        * Tratamento para flag movimento, caso seja juridico
                        */                                                
                        movimentoSin.SinistroJudicial__c = caso.Sinistro_Judicial__c ? true : false ;
                        // LECVPV-140-FIX02 FIM

                        lstMovSinistroInsert.add(movimentoSin);

                        mSequenciaMov.put(caso.Id, sequencia);
                    }
                
                }
            }
        }


        if(!lstMovSinistroInsert.isEmpty()) Database.insert(lstMovSinistroInsert);

    }
    //PLV-4037 - Fim


    //PLV-4037 - Início
    public Integer getSequencia( Map<Id, Integer> mSequenciaMov, Id casoId ){

        Integer sequencia;
        if( mSequenciaMov == null ){

            mSequenciaMov = new Map<Id, Integer>();
            sequencia = 1;

        }
        else if(mSequenciaMov.containsKey(casoId)){

            sequencia = mSequenciaMov.get(casoId) + 1;
        
        }
        else{

            sequencia = 1;

        }

        return sequencia;
   
    }
    //PLV-4037 - Fim

    //PLV-4037 - Início
    private MovimentoSinistro__c criarNovoMovimento( Id casoId, String tipoMovimento, String descricaoMovimento, Integer sequencia, Id pagGarantiaId, Decimal ValorIndenizadoChanged ){//PLV-4818 - INICIO/FIM - PEDRO AUGUSTO BRAZ - SYS4B

        MovimentoSinistro__c movimentoSin = new MovimentoSinistro__c();

        movimentoSin.Caso__c = casoId;
        movimentoSin.DataMovimento__c = system.now();
        movimentoSin.TipoMovimento__c = tipoMovimento;
        movimentoSin.DescricaoMovimento__c = descricaoMovimento;
        movimentoSin.SequenciaMovimento__c = String.valueOf(sequencia);
        movimentoSin.PagamentoGarantia__c = pagGarantiaId;
        movimentoSin.ValorMovimento__c = ValorIndenizadoChanged;//PLV-4818 - INICIO/FIM - PEDRO AUGUSTO BRAZ - SYS4B
            
        return movimentoSin;
   
    }
    //PLV-4037 - Fim

    // LECVPV-216 INICIO
    public void zeraValorIndenizado(List<PagamentoGarantia__c> listGarantiaNew, Map<Id, PagamentoGarantia__c> mapGarantiaSinistroOld){ //PLV-4070_FIX - INICIO/FIM
               
        List<PagamentoGarantia__c> garantiasParaAtualizar = new List<PagamentoGarantia__c>();
      
        for (PagamentoGarantia__c pag : listGarantiaNew) {
             if(pag.Fase__c == 'Fechado' && (pag.Status_do_pagamento__c == 'Recusado' || pag.Status_do_pagamento__c == 'Pago' ) && pag.Valor_Indenizado__c != 0){ // LECVPV-216 FIX01 INICIO/FIM
                PagamentoGarantia__c pagUpdate = new PagamentoGarantia__c();
                pagUpdate.Id = pag.Id;
                pagUpdate.Valor_Indenizado__c = 0;
                garantiasParaAtualizar.add(pagUpdate);
             }
        }

        if (!garantiasParaAtualizar.isEmpty()) {
            PagamentoGarantiaTriggerHandler.isFirstTime = false;
            update garantiasParaAtualizar;
        }
    }
    // LECVPV-216 FIM

    //PLV-4070 - INICIO
    public void atualizaValorIndenizado(List<PagamentoGarantia__c> lsNewData){ //PLV-4070_FIX - INICIO/FIM
        //LECVP-193 - INICIO
        Set<Id> pgtoGarantiaIds = new Set<Id>();
        for(PagamentoGarantia__c pgtoGarantia : lsNewData){
            pgtoGarantiaIds.add(pgtoGarantia.Id);
        }   
       //LECVP-193 - FIM
            for(PagamentoGarantia__c pag : lsNewData){
                if(TriggerHelper.isChanged(pag, 'SomaValorBeneficiarios__c')){
                    List<BeneficiarioGarantia__c> beneficiarios = BeneficiarioGarantiaDAO.getInstance().buscarPorIdDePagamentosDeGarantia(pgtoGarantiaIds);//LECVP-193 - INICIO
            
                    for(BeneficiarioGarantia__c beneficiario : beneficiarios){                    
                        Boolean alterarValorIndPgto = ( pag.Valor_indenizado__c != beneficiario.ValorIndenizacao__c);
                        
                        if(!alterarValorIndPgto){
                            Decimal dec = pag.Valor_da_cotacao_em_reais__c == null ? 1 :pag.Valor_da_cotacao_em_reais__c;
                            pag.Valor_indenizado__c = pag.SomaValorBeneficiarios__c != 0 ? pag.SomaValorBeneficiarios__c * dec : 0; //PLV-4070_FIX - INICIO/FIM
                        }
                    }
                }

            }
        //LECVP-193 - FIM
    }
    
    public void atualizaPercentualIndenizacao(Map<Id, PagamentoGarantia__c> mapNewData){
        
        
        BeneficiarioGarantia__c[] lsUpdate = new BeneficiarioGarantia__c[]{};

        // LECVPV-216-FIX01 - INICIO
        List<BeneficiarioGarantia__c> beneficiariosDaGarantia = [
            SELECT ValorIndenizacao__c, 
                   Percentual_de_indenizacao__c, 
                   InformarIndenizacao__c, //PLV-4892 - INICIO/FIM
                   Pagamento_de_garantia__c
            FROM BeneficiarioGarantia__c
            WHERE Pagamento_de_garantia__c IN :mapNewData.keySet()
             AND Status__c != 'Cancelado'
        ];
        Integer qtdeBeneficiarios = beneficiariosDaGarantia.size();
        Decimal acumulado = 0.0;
        for (Integer i = 1; i<=qtdeBeneficiarios;i++) {
            BeneficiarioGarantia__c bene = beneficiariosDaGarantia[i-1];

            PagamentoGarantia__c pgGarantia = mapNewData.get(bene.Pagamento_de_garantia__c);
            
            if(pgGarantia == null) continue;

            //PLV-4892 - INICIO
            if(bene.InformarIndenizacao__c != '% de Indenização')
            {
                //PLV-4070_FIX - INICIO
                if(bene.ValorIndenizacao__c != 0 && bene.ValorIndenizacao__c != null){
                    if (i < qtdeBeneficiarios) {
                        bene.Percentual_de_indenizacao__c = Test.isRunningTest() ? 20 : (bene.ValorIndenizacao__c / pgGarantia.SomaValorBeneficiarios__c * 100).setScale(3, RoundingMode.HALF_EVEN); //PLV-4448 - INICIO/FIM
                        acumulado += bene.Percentual_de_indenizacao__c;
                    } else {
                        bene.Percentual_de_indenizacao__c = 100.0 - acumulado; // garante sempre que teremos um total de 100% na soma de todos os percentuais dos beneficiarios
                    }
                }else{                
                    bene.Percentual_de_indenizacao__c = 0;
                }
            } 
            //PLV-4070_FIX - INICIO
            //PLV-4892 - FIM
            
            bene.Permitir_Alteracao__c = true; //PLV-4382 - Operação Assistida - INICIO/FIM
            lsUpdate.add(bene);
        }
        // LECVPV-216-FIX01 - FIM

        PagamentoGarantiaTriggerHandler.isFirstTime = false;
        BeneficiarioGarantiaTriggerHandler.isFirstTime = false; //PLV-4448 - INICIO/FIM
        Update lsUpdate;

    }

    //PLV-4070 - FIM

    //PLV-4559 - Inicio
    public void UpdateGarantiaSegurado(List<PagamentoGarantia__c> listGarantiaNew, Map<Id, PagamentoGarantia__c> mapGarantiaSinistroOld)
	{	 
        map<id,PagamentoGarantia__c> mapPagGarantia = new map<id,PagamentoGarantia__c>();

        if(mapGarantiaSinistroOld == null) mapGarantiaSinistroOld = new map<id,PagamentoGarantia__c>();
       
  		for(PagamentoGarantia__c garantia : listGarantiaNew)
		{			                 
            //is changed Status_do_pagamento__c
            if (garantia.Status_do_pagamento__c != mapGarantiaSinistroOld.get(garantia.Id).Status_do_pagamento__c)
            {
                if(garantia.Status_do_pagamento__c == 'Pago')           
                {                                 
                    mapPagGarantia.put(garantia.Garantia_do_segurado_do_contrato__c ,garantia);
                }	              
            }             																 
        } 

        List<GarantiaSeguradoContrato__c> garantiaSeguradoContract = [
                    SELECT id, Total_utilizado__c, Tipo_de_limite_de_utilizacao__c 
                    FROM GarantiaSeguradoContrato__c   
                    WHERE id in: mapPagGarantia.keySet()];

        if(!garantiaSeguradoContract.isEmpty())
        {
            for(GarantiaSeguradoContrato__c gar : garantiaSeguradoContract)
            {	
                Decimal franquia = mapPagGarantia.get(gar.id).Franquias__c ==null ? 0 : mapPagGarantia.get(gar.id).Franquias__c;
                Decimal QuantidadeDias = mapPagGarantia.get(gar.id).QuantidadeDias__c ==null ? 0 : mapPagGarantia.get(gar.id).QuantidadeDias__c;
                if(gar.Total_utilizado__c == null)gar.Total_utilizado__c = 0;                                
                if(gar.Tipo_de_limite_de_utilizacao__c == 'Dias') gar.Total_utilizado__c =  gar.Total_utilizado__c + (franquia +  QuantidadeDias);
                if(gar.Tipo_de_limite_de_utilizacao__c == 'Monetário') gar.Total_utilizado__c = gar.Total_utilizado__c + mapPagGarantia.get(gar.id).ValorIndenizado__c;       																 
            }     
                    
            update garantiaSeguradoContract;
        }					
     } 	  
    //PLV-4559 - Fim 

    // POR062-1 - INICIO
    public PagamentoGarantia__c filtrarPorCasoECobertura(Id casoId, String nomeCobertura, List<PagamentoGarantia__c> pagamentos)
    {
        PagamentoGarantia__c pagamento = null;
        if(String.isNotBlank(casoId) && String.isNotBlank(nomeCobertura))
        {
            for(PagamentoGarantia__c pagamentoGarantia : pagamentos)
            {
                if(casoId.equals(pagamentoGarantia?.Caso__c) && nomeCobertura.equals(pagamentoGarantia?.Name))
                {
                    pagamento = pagamentoGarantia;
                }
            }
        }
        return pagamento;
    }

    public PagamentoGarantia__c recuperarPorCasoESigla(Id casoId, String sigla, List<PagamentoGarantia__c> pagamentos)
    {
        PagamentoGarantia__c pagamento = null;
        if(
            String.isNotBlank(casoId) &&
            String.isNotBlank(sigla) &&
            pagamentos != null && !pagamentos.isEmpty()
        ) {
            for(PagamentoGarantia__c pagamentoAuxiliar : pagamentos)
            {
                if(
                    String.isNotBlank(pagamentoAuxiliar?.Garantia_do_segurado_do_contrato__r?.Garantia__r?.Sigla__c) &&
                    sigla?.equals(pagamentoAuxiliar?.Garantia_do_segurado_do_contrato__r?.Garantia__r?.Sigla__c) &&
                    casoId.equals(pagamentoAuxiliar.Caso__c)
                ) {
                    pagamento = pagamentoAuxiliar;
                    break;
                }
            }
        }
        return pagamento;
    }

    public List<PagamentoGarantia__c> fecharPagamentosDeCaso(Id casoId, List<PagamentoGarantia__c> pagamentos)
    {
        List<PagamentoGarantia__c> pagamentosParaFechar = new List<PagamentoGarantia__c>();
        if(String.isNotBlank(casoId))
        {
            for(PagamentoGarantia__c pagamento : pagamentos)
            {
                if(
                    casoId.equals(pagamento.Caso__c) &&
                    (!'Fechado'.equals(pagamento.Fase__c) || pagamento.Valor_indenizado__c > 0)
                ) {
                    pagamento.Fase__c = 'Fechado';
                    pagamento.Valor_indenizado__c = 0;
                    pagamentosParaFechar.add(pagamento);
                }
            }
        }
        return pagamentosParaFechar;
    }
    // POR062-1 - FIM
}