/************************************************************************
 *
 *  Classe responsável pelo negócio do objeto BeneficiarioGarantia__c 
 *  @Author GFS 29/03/2019
 *
 ************************************************************************/
public virtual class BeneficiarioGarantiaBO
{ 
    public BeneficiarioGarantiaBO() { } 
    
    private static final BeneficiarioGarantiaBO instancia = new BeneficiarioGarantiaBO();
   
    public static BeneficiarioGarantiaBO getInstance(){
        return instancia;
    }

    //  analisa o tipo de pagamento. Se for total, deve fechar o status da garantia.
    public void efetuaPagamento(List<BeneficiarioGarantia__c> plNew, Map<Id,BeneficiarioGarantia__c> pmOld) {

        // LECVPV-140-FIX06 INICIO
        Map<Id, List<BeneficiarioGarantia__c>> mapGarantiaBen = new Map<Id,List<BeneficiarioGarantia__c>>();
        Set<Id> setGarantia = new Set<Id>();
        Decimal valoraPagar = 0;

        for(BeneficiarioGarantia__c ben : [SELECT Id, 
                                                  Pagamento_de_garantia__c, 
                                                  Pagamento_de_garantia__r.Caso__c, 
                                                  Status__c,
                                                  ValorIndenizacao__c,//PLV-4818 - INICIO/FIM - PEDRO AUGUSTO BRAZ - SYS4B
                                                  ValorPago__c,//PLV-4818 - INICIO/FIM - PEDRO AUGUSTO BRAZ - SYS4B
                                                  ValorTotalIndenizado__c,//PLV-4818 - INICIO/FIM - PEDRO AUGUSTO BRAZ - SYS4B
                                                  Permitir_Alteracao__c, // LECVPV-200 INICIO/FIM
                                                  Pagamento_de_garantia__r.Caso__r.RecordTypeId,
                                                  Pagamento_de_garantia__r.Caso__r.GerarMovimentacaoContabil__c
                                                  FROM BeneficiarioGarantia__c
                                                  WHERE Id = :plNew]){
            

            BeneficiarioGarantia__c benOld = pmOld.get(ben.Id);

            Boolean isStatusPago = ( ben.Status__c == 'Pago' );
            Boolean isStatusChanged = ( ben.Status__c != benOld.Status__c );
            System.debug('Giordano -> ben permite alteração ? '+ ben.Permitir_Alteracao__c);

            if( isStatusPago && isStatusChanged && ben.Permitir_Alteracao__c){ // LECVPV-200 INICIO/FIM

                valoraPagar += ben.ValorTotalIndenizado__c;
                List<BeneficiarioGarantia__c> lstBene;
                if(mapGarantiaBen.containsKey(ben.Pagamento_de_garantia__c)){
                    system.debug('Entrou no if?');
                    lstBene = mapGarantiaBen.get(ben.Pagamento_de_garantia__c);
                } else{
                    System.debug('ENTROU NESSE ELSE?');
                    lstBene = new List<BeneficiarioGarantia__c>();
                }

                lstBene.add(ben);
                mapGarantiaBen.put(ben.Pagamento_de_garantia__c, lstBene);
                setGarantia.add(ben.Pagamento_de_garantia__c);
            }
        }

        if(mapGarantiaBen.isEmpty()) return;

        List<PagamentoGarantia__c> lGarantias = [
            SELECT
                Id,
                Saldo_da_reserva__c
            FROM
                PagamentoGarantia__c
            WHERE
                Id IN :setGarantia
        ];
 
        Map<Id, PagamentoGarantia__c> mapGarantias = new Map<Id, PagamentoGarantia__c>();


        for(PagamentoGarantia__c garantia : lGarantias) {
            mapGarantias.put(garantia.Id, garantia);
        }    

        Set<Id> setIdGarantiaBeneficiarioNaoPago = new Set<Id>();
        for(AggregateResult ar : [SELECT Pagamento_de_garantia__c garantiaId, COUNT(Id) total
                                   FROM BeneficiarioGarantia__c
                                   WHERE Pagamento_de_garantia__c IN :mapGarantiaBen.keyset()
                                   AND Status__c != 'Pago'
                                   GROUP BY Pagamento_de_garantia__c]){
            setIdGarantiaBeneficiarioNaoPago.add((Id)ar.get('garantiaId'));
        }
     
     
                // Set<Id> sPagamentoGarantiaId = new Set<Id>();

                // for(BeneficiarioGarantia__c bg : plNew)
                //     if(bg.Status__c != pmOld.get(bg.Id).Status__c && bg.Status__c == 'Pago')
                //         sPagamentoGarantiaId.add(bg.Pagamento_de_garantia__c);

                // if (sPagamentoGarantiaId.isEmpty()) return;

                // Map<Id,Set<String>> mPagGar = new Map<Id,Set<String>>();

                // for (AggregateResult ar : [SELECT Pagamento_de_garantia__c, Status__c, COUNT(Id) total
                //                            FROM BeneficiarioGarantia__c
                //                            WHERE Pagamento_de_garantia__c IN :sPagamentoGarantiaId
                //                            GROUP BY Pagamento_de_garantia__c, Status__c]) {

                //     Set<String> sStatus;
                //     System.debug('ar' + JSON.serializePretty(ar));
                //     Id pagGarId = (Id) ar.get('Pagamento_de_garantia__c');

                //     if (mPagGar.containsKey(pagGarId))
                //         sStatus = mPagGar.get(pagGarId);
                //     else sStatus = new Set<String>();

                //     sStatus.add((String) ar.get('Status__c'));
                //     mPagGar.put(pagGarId, sStatus);
                // }

                // List<PagamentoGarantia__c> lPagGar = new List<PagamentoGarantia__c>();

                // for (Id pagGarId : mPagGar.keyset()) {

                //     Set<String> sStatus = mPagGar.get(pagGarId);

                //     if (!sStatus.contains('Pago')) continue;

            //      PagamentoGarantia__c pagGar = new PagamentoGarantia__c(Id = pagGarId);

            // if (sStatus.size() == 1) {
            //     pagGar.Fase__c = 'Fechado';
            //     pagGar.Status_do_pagamento__c = 'Pago';
            // } else if (sStatus.size() > 1) {
            //     pagGar.Fase__c = 'Em Análise';
            //     pagGar.Status_do_pagamento__c = 'Pago Parcialmente';
            // }

        List< PagamentoGarantia__c> lPagGar = new List<PagamentoGarantia__c>();
        for (Id pagGarId : mapGarantias.keyset()) {
            PagamentoGarantia__c pagGar = mapGarantias.get(pagGarId);
            System.debug('Giordano - Saldo Reserva: '+pagGar.Saldo_da_reserva__c);
            System.debug('Giordano - Valor a Pagar: '+valoraPagar);
            if (pagGar.Saldo_da_reserva__c <= valoraPagar && !setIdGarantiaBeneficiarioNaoPago.contains(pagGarId)) {
            System.debug('Giordano -> Pagamento foi total.');
            pagGar.Fase__c = 'Fechado';
            pagGar.Status_do_pagamento__c = 'Pago';
            } else {
            System.debug('Giordano -> Pagamento foi parcial.');
            pagGar.Fase__c = 'Em Análise';
            pagGar.Status_do_pagamento__c = 'Pago Parcialmente';
            }

            lPagGar.add(pagGar);
        }
        // LECVPV-140-FIX06 FIM
        //PLV-4818 - INICIO - PEDRO BRAZ
        //LECVPV-216-FIX01 - INICIO
        PagamentoGarantiaTriggerHandler.gerarMovimento = false;
        update lPagGar;
        PagamentoGarantiaTriggerHandler.gerarMovimento = true;
        //LECVPV-216-FIX01 - FIM
        //PLV-4818 - FIM - PEDRO BRAZ
    }

    //AVX SP 27 - PLV 2180
    public void preencherIdExterno(List<BeneficiarioGarantia__c> beneficiarios){

        Set<Id> pagamentos = new Set<Id>(); 

        for(BeneficiarioGarantia__c bene: beneficiarios){
            pagamentos.add(bene.Pagamento_de_garantia__c);
        }

        List<AggregateResult> groupedResults = [SELECT Pagamento_de_garantia__c pagamento, COUNT(id) contador
                                                FROM BeneficiarioGarantia__c 
                                                WHERE Pagamento_de_garantia__c in: pagamentos
                                                GROUP BY Pagamento_de_garantia__c];
                                 

        Map<Id, Integer> mCont = new Map<Id, Integer>();

        for(AggregateResult ar: groupedResults){
            Id pag = (Id) ar.get('pagamento');
            Integer numeroBene = (Integer) ar.get('contador');
            mCont.put(pag, numeroBene);
        }

        for(BeneficiarioGarantia__c b : beneficiarios){

            if(mCont.containsKey(b.Pagamento_de_garantia__c)){
                Integer numeroIdExterno = mCont.get(b.Pagamento_de_garantia__c);
                mCont.put(b.Pagamento_de_garantia__c, numeroIdExterno + 1);

            }else{
                mCont.put(b.Pagamento_de_garantia__c, 1);
            }
            b.IdExterno__c = String.valueOf(mCont.get(b.Pagamento_de_garantia__c));

        }

    }

    public void criaMovimentoDeSinistro(List<BeneficiarioGarantia__c> beneficiarios, Map<Id,BeneficiarioGarantia__c> pmOld){

        //PLV-4037 - Início

        System.debug('parametros Henrique: ' +beneficiarios );
        
        Map<Id, List<BeneficiarioGarantia__c>> mapCasoBen = new Map<Id,List<BeneficiarioGarantia__c>>();
        Set<Id> setCase = new Set<Id>();
        //Início da lógica para a história PLV-2341. Regra de negócio adicionada ao código
        Recordtype REC_ID_SINISTRO = RecordTypeBO.buscarTipoRegistro('Case', 'Sinistro');
        Recordtype REC_ID_BENEFICIO = RecordTypeBO.buscarTipoRegistro('Case', 'Beneficio');

        for(BeneficiarioGarantia__c ben : [SELECT Id, 
                                                  Pagamento_de_garantia__c,
                                                  Pagamento_de_garantia__r.Caso__c, 
                                                  Pagamento_de_garantia__r.Caso__r.Sinistro_Judicial__c, // LECVPV-140-FIX06 INICIO/FIM
                                                  Pagamento_de_garantia__r.ValorIndenizado__c, // LECVPV-216 INICIO/FIM
                                                  Pagamento_de_garantia__r.ComplementoIndenizacao__c, // LECVPV-216 INICIO/FIM
                                                  Status__c,
                                                  ValorIndenizacao__c,//PLV-4818 - INICIO/FIM - PEDRO AUGUSTO BRAZ - SYS4B
                                                  ValorPago__c,//PLV-4818 - INICIO/FIM - PEDRO AUGUSTO BRAZ - SYS4B
                                                  ValorTotalIndenizado__c,//PLV-4818 - INICIO/FIM - PEDRO AUGUSTO BRAZ - SYS4B
                                                  Pagamento_de_garantia__r.Caso__r.RecordTypeId,
                                                  Pagamento_de_garantia__r.Caso__r.GerarMovimentacaoContabil__c
                                                  FROM BeneficiarioGarantia__c
                                                  WHERE Id = :beneficiarios]){
            

            System.debug('BEN HENRIQUE : ' + ben);
            BeneficiarioGarantia__c benOld = pmOld.get(ben.Id);

            Boolean isStatusPago = ( ben.Status__c == 'Pago' );
            Boolean isStatusChanged = ( ben.Status__c != benOld.Status__c );
            Boolean isCasoSinistro = ( ben.Pagamento_de_garantia__r.Caso__r.RecordTypeId == REC_ID_SINISTRO.Id );

            if( isStatusPago && isStatusChanged && isCasoSinistro ){
            
        //Fim da lógica para a história PLV-2341. Regra de negócio adicionada ao código
                List<BeneficiarioGarantia__c> lstBene;
                if(mapCasoBen.containsKey(ben.Pagamento_de_garantia__r.Caso__c)){
                    system.debug('Entrou no if?');
                    lstBene = mapCasoBen.get(ben.Pagamento_de_garantia__r.Caso__c);
                } else{
                    System.debug('ENTROU NESSE ELSE?');
                    lstBene = new List<BeneficiarioGarantia__c>();
                }

                lstBene.add(ben);
                mapCasoBen.put(ben.Pagamento_de_garantia__r.Caso__c, lstBene);
                setCase.add(ben.Pagamento_de_garantia__r.Caso__c);
            }
        }

        if(mapCasoBen.isEmpty()) return;

        Set<Id> setIdCasoBeneficiarioNaoPago = new Set<Id>();
        for(AggregateResult ar : [SELECT Pagamento_de_garantia__r.Caso__c casoId, COUNT(Id) total
                                   FROM BeneficiarioGarantia__c
                                   WHERE Pagamento_de_garantia__r.Caso__c IN :mapCasoBen.keyset()
                                   AND Status__c != 'Pago'
                                   GROUP BY Pagamento_de_garantia__r.Caso__c]){
            setIdCasoBeneficiarioNaoPago.add((Id)ar.get('casoId'));
        }

        Set<Id> setIdCasoPagamentoNaoFechado = new Set<Id>();
        for(AggregateResult ar : [SELECT Caso__c casoId, COUNT(Id) total
                                   FROM PagamentoGarantia__c
                                   WHERE Caso__c IN :mapCasoBen.keyset()
                                   AND Fase__c != 'Fechado'
                                   GROUP BY Caso__c]){
            setIdCasoPagamentoNaoFechado.add((Id)ar.get('casoId'));
        }

        System.debug('SetId Caso pagamento HENRIQUE: ' +setIdCasoPagamentoNaoFechado );
        System.debug('setIdCasoBeneficiarioNaoPago HENRIQUE:  ' +setIdCasoBeneficiarioNaoPago );
        
        Map<Id,Integer> mapSequencia = SequenciaMovimentoSinistroHelper.sequenciaMovimentos(setCase);

        List<MovimentoSinistro__c> lstMovSin = new List<MovimentoSinistro__c>();
        System.debug('map caso Henrique: ' + mapCasoBen.keySet());
        for(Id pagCasoId : mapCasoBen.keySet()){
            System.debug('pagCaso henrique : ' +pagCasoId);
            List<BeneficiarioGarantia__c> lstBen = mapCasoBen.get(pagCasoId);
            System.debug('lstBen HENRIQUE : ' + lstBen);

            for(Integer i=0;i < lstBen.size(); i++){
                System.debug('tamanhho da lista : ' + lstBen.size());
                BeneficiarioGarantia__c b = lstBen.get(i);
                System.debug('b HENRIQUE : ' + b);
                Integer sequencia;
                if(mapSequencia == null){
                    mapSequencia = new Map<Id,Integer>();
                    sequencia = 1;
                } else if(mapSequencia.containsKey(b.Pagamento_de_garantia__r.Caso__c)){
                    sequencia = mapSequencia.get(b.Pagamento_de_garantia__r.Caso__c) + 1;
                } else { sequencia = 1; }

                // LECVPV-174 INICIO
                Set<Id> setCasos = new Set<Id>{b.Pagamento_de_garantia__r.Caso__c};
                //Case caso = CaseDAO.getInstance().buscarCasoPorId(setCasos);   
                // LECVPV-140-FIX06 INICIO
                // Case casoJudicial = [
                //     SELECT
                //         Id,
                //         Sinistro_Judicial__c
                //     FROM
                //         Case
                //     WHERE
                //         Id = :b.Pagamento_de_garantia__r.Caso__c
                // ];
                // Boolean isJudicial = casoJudicial.Sinistro_Judicial__c;
                Boolean isJudicial = b.Pagamento_de_garantia__r.Caso__r.Sinistro_Judicial__c;
                // LECVPV-140-FIX06 FIM
                System.debug('Giordano -> isJuducial? '+ isJudicial);
                // LECVPV-174 FIM
                // LECVPV-216 INICIO

                Decimal totalJuros = 0;
                Decimal totalCorrecao = 0;
                Decimal fator = b.ValorTotalIndenizado__c/b.Pagamento_de_garantia__r.ValorIndenizado__c;

                if (b.Pagamento_de_garantia__r.ComplementoIndenizacao__c > 0) {
                    List<ComplementoIndenizacao__c> complementosGarantia = [SELECT Id, TipoComplemento__c, Valor__c, PagamentoGarantia__c FROM ComplementoIndenizacao__c WHERE PagamentoGarantia__c = :b.Pagamento_de_garantia__c];

                    if (!complementosGarantia.isEmpty()) {
                        for (ComplementoIndenizacao__c compl : complementosGarantia) {
                            if ('Juros'.equals(compl.TipoComplemento__c)) {
                                totalJuros += compl.Valor__c;
                            }
                            if ('Atualização Monetária'.equals(compl.TipoComplemento__c)) {
                                totalCorrecao += compl.Valor__c;
                            }
                        }
                    }                  
                    MovimentoSinistro__c movBaixaJuros = new MovimentoSinistro__c(); 
                    MovimentoSinistro__c movBaixaCorrecao = new MovimentoSinistro__c();   

                    if (totalJuros > 0) {
                        movBaixaJuros = MovimentoSinistroBO.getInstance().criarMovimentoEncerramentoJuridico(
                            b.Pagamento_de_garantia__r.Caso__c, MovimentoSinistroTO.ACERTO_JUROS_MENOS,
                            totalJuros*fator*-1, String.valueOf(sequencia++), b.Pagamento_de_garantia__c);
                        lstMovSin.add(movBaixaJuros);
                    }
                    if (totalCorrecao > 0) {
                        movBaixaCorrecao = MovimentoSinistroBO.getInstance().criarMovimentoEncerramentoJuridico(
                            b.Pagamento_de_garantia__r.Caso__c, MovimentoSinistroTO.ACERTO_CORRECAO_JUROS_MENOS,
                            totalCorrecao*fator*-1, String.valueOf(sequencia++), b.Pagamento_de_garantia__c);
                        lstMovSin.add(movBaixaCorrecao);
                    }
                }

                MovimentoSinistro__c movSinistro = new MovimentoSinistro__c();  
                // LECVPV-216 FIM


                if( setIdCasoBeneficiarioNaoPago.contains(pagCasoId) || setIdCasoPagamentoNaoFechado.contains(pagCasoId) || i < lstBen.size() - 1 ){    

                    System.debug('ENTROU NO IF HENRIQUE');
                    //crio movimento de sinistro parcial
                    movSinistro.Caso__c = b.Pagamento_de_garantia__r.Caso__c;
                    movSinistro.SinistroJudicial__c = isJudicial; // LECVPV-174 INICIO/FIM
                    movSinistro.PagamentoGarantia__c = b.Pagamento_de_garantia__c;
                    movSinistro.BeneficiarioGarantia__c = b.Id;
                    movSinistro.DataMovimento__c = system.now();
                    movSinistro.TipoMovimento__c = 'Pagamento';
                    movSinistro.DescricaoMovimento__c = '4';
                    movSinistro.SequenciaMovimento__c = String.valueOf(sequencia);                
                } 
                else {
                    System.debug('ENTROU NO ELSE HENRIQUE');
                    //crio movimento de sinistro final
                    movSinistro.Caso__c = b.Pagamento_de_garantia__r.Caso__c;
                    movSinistro.SinistroJudicial__c = isJudicial; // LECVPV-174 INICIO/FIM
                    movSinistro.PagamentoGarantia__c = b.Pagamento_de_garantia__c;
                    movSinistro.BeneficiarioGarantia__c = b.Id;
                    movSinistro.DataMovimento__c = system.now();
                    movSinistro.TipoMovimento__c = 'Pagamento';
                    movSinistro.DescricaoMovimento__c = '7';
                    movSinistro.SequenciaMovimento__c = String.valueOf(sequencia);
                }
                movSinistro.ValorMovimento__c = b.ValorTotalIndenizado__c - (totalJuros + totalCorrecao)*fator; // LECVPV-216 INICIO/FIM  //PLV-4818 - INICIO/FIM - PEDRO AUGUSTO BRAZ - SYS4B
             
                lstMovSin.add(movSinistro);
                system.DEBUG('LISTA MOV HENRIQUE : ' +lstMovSin.size() );
                mapSequencia.put(b.Pagamento_de_garantia__r.Caso__c, sequencia);
            }
        }

        if(!lstMovSin.isEmpty()) Database.insert(lstMovSin);
        //PLV-4037 - Fim
    }
    
     //PLV-2403 - AVX - Sprint 29 - Ajuste na % de indenização e Valor indenizado - Início
    public void atualizavalorindenizacao(List<BeneficiarioGarantia__c> beneficiarios, Map<Id,BeneficiarioGarantia__c> pmOld)
    {
        Set<Id> spagamentoGarantia = new set<Id>();
        for(BeneficiarioGarantia__c bng : beneficiarios){
            if(TriggerHelper.isChanged(bng, 'ValorIndenizacao__c')) //PLV-4382 - Operação Assistida - INICIO/FIM
                spagamentoGarantia.add(bng.Pagamento_de_garantia__c);
        }

        if(spagamentoGarantia.isEmpty()) return; //PLV-4382 - Operação Assistida - INICIO/FIM

        //PLV-4428 - CORRECAO - INICIO
        List<PagamentoGarantia__c> LstPagGaran = [
            /*SELECT ValorIndenizado__c, SomaValorBeneficiarios__c //PLV-4070 - INICIO/FIM
            FROM PagamentoGarantia__c
            WHERE id =: beneficiarios[0].Pagamento_de_garantia__c*/            
            SELECT Id, ValorIndenizado__c, SomaValorBeneficiarios__c //PLV-4070 - INICIO/FIM
            FROM PagamentoGarantia__c
            WHERE id in:(spagamentoGarantia)
        ];
        system.debug('LstPagGaran ' + LstPagGaran);
		//PLV-4428 - CORRECAO - FIM

        if(LstPagGaran.isempty()) return;
		//PLV-4428 - CORRECAO - INICIO
        Map<String, PagamentoGarantia__c> mPagamentoGarantia = new Map<String, PagamentoGarantia__c>();
        for(PagamentoGarantia__c lpag : LstPagGaran){
            mPagamentoGarantia.put(lpag.Id,lpag);
        }
        system.debug('mPagamentoGarantia'+mPagamentoGarantia);
       
        Decimal ValorPagamento;      
        //Decimal ValorPagamento = LstPagGaran[0].SomaValorBeneficiarios__c; 
        //if(ValorPagamento == 0) ValorPagamento = LstPagGaran[0].ValorIndenizado__c; //PLV-4070 - INICIO/FIM
        //PLV-4428 - CORRECAO - FIM
        
        //PLV-2403 - AVX - Sprint 29 - Ajuste na % de indenização e Valor indenizado - Final
        //PLV-2603 - Início - AVX - Melhoria Contínua - Correção pagamento de Sinistro.
        for(BeneficiarioGarantia__c ben : beneficiarios)
        {
            //PLV-4070 - INICIO
            if(ben.Status__c == 'Cancelado'){
                ben.Percentual_de_indenizacao__c = 0;
                continue;
            }
            //PLV-4070 - FIM

            //if(ValorPagamento != 0 && ValorPagamento != NULL){ //PLV-4448 - INICIO/FIM
                //PLV-4892 - INICIO
                //PLV-4070 - INICIO
                if(ben.InformarIndenizacao__c == '% de Indenização')
                {
                    if(ben.Percentual_de_indenizacao__c != NULL){
                        
                        Decimal somaBeneficiarios = mPagamentoGarantia.get(ben.Pagamento_de_garantia__c).SomaValorBeneficiarios__c;

                        if(ben.Percentual_de_indenizacao__c >= 100){
                            ben.ValorIndenizacao__c = mPagamentoGarantia.get(ben.Pagamento_de_garantia__c).ValorIndenizado__c; 
                        } else if(somaBeneficiarios == 0) {
                            ben.ValorIndenizacao__c = ((ben.Percentual_de_indenizacao__c)/100) * mPagamentoGarantia.get(ben.Pagamento_de_garantia__c).ValorIndenizado__c; 
                        } else {
                            ben.ValorIndenizacao__c = (ben.Percentual_de_indenizacao__c * somaBeneficiarios) / (100 - ben.Percentual_de_indenizacao__c);
                        }
               
                    } else
                        ben.Percentual_de_indenizacao__c.addError('Este campo é obrigatório, pois a opção "% de Indenização" foi selecionada no campo "Informar Indenização".');
                }
                else
                //PLV-4070 - FIM
                //PLV-4892 - FIM
                if(ben.InformarIndenizacao__c == 'Valor de Indenização') 
                {
                    if(ben.ValorIndenizacao__c != NULL && ben.ValorIndenizacao__c != 0){ //PLV-4448 - INICIO/FIM
                        //PLV-4428 - CORRECAO - INICIO
                        ValorPagamento = (mPagamentoGarantia.get(ben.Pagamento_de_garantia__c).SomaValorBeneficiarios__c == 0) ? mPagamentoGarantia.get(ben.Pagamento_de_garantia__c).ValorIndenizado__c : mPagamentoGarantia.get(ben.Pagamento_de_garantia__c).SomaValorBeneficiarios__c;
                        //PLV-4448 - INICIO
                        if(ValorPagamento == 0) ValorPagamento = ben.ValorIndenizacao__c; 
                        if(mPagamentoGarantia.get(ben.Pagamento_de_garantia__c).SomaValorBeneficiarios__c != 0) ValorPagamento = ValorPagamento + ben.ValorIndenizacao__c;                        
                        //PLV-4448 - FIM
                        ben.Percentual_de_indenizacao__c = (((ben.ValorIndenizacao__c * 100)/ValorPagamento)).setScale(3); //PLV-4070_FIX - INICIO/FIM
                        system.debug('Percentual de indenização:' + ben.Percentual_de_indenizacao__c); 
                        //PLV-4428 - CORRECAO - FIM
                    }else
                        ben.ValorIndenizacao__c.addError('Este campo é obrigatório, pois a opção "Valor de Indenização" foi selecionada no campo "Informar Indenização".');                    
                }
            //} //PLV-4448 - INICIO/FIM
            //PLV-4070 - INICIO
            // else{
            //     ben.addError('O campo "Valor Indenizado" no "Pagamento de Garantia" não pode ser igual a zero.');
            // }
            //PLV-4070 - FIM
        }
    }

    public void validaTotalIndenizacao(List<BeneficiarioGarantia__c> beneficiarios){
        if(beneficiarios.isEmpty()) return; 

        String message = '';
        
        for(BeneficiarioGarantia__c beneficiario : beneficiarios){
            message = beneficiario.ValorIndenizacao__c > beneficiario.Pagamento_de_garantia__r.Saldo_da_reserva__c ? 'O valor Indenizado é maior que o Saldo da reserva!' : 'Criar';
        }

        //return message;
    }
}
//PLV-2603 - Fim - AVX - Melhoria Contínua - Correção pagamento de Sinistro.