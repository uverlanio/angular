/************************************************************************
 *
 *  Classe responsável pelo negocío do objeto MovimentoSinistro__c 
 *  @Author DaZTL 29/05/2019
 *
 ************************************************************************/
public virtual class MovimentoSinistroBO {
	private MovimentoSinistroBO() {}

	private static final MovimentoSinistroBO INSTANCIA = new MovimentoSinistroBO();

	public static MovimentoSinistroBO getInstance()
    {
		return INSTANCIA;
	}

	public void insereControleIntegracao(List<MovimentoSinistro__c> lMovSin)
    {
		Set<String> sIdObjeto = new Set<String>();
		for(MovimentoSinistro__c mov : lMovSin){
		  sIdObjeto.add(mov.Id);
		}

		Set<String> sControle = new Set<String>();
        if(
            Schema.ControleIntegracao__c.getSObjectType().getDescribe().isAccessible() &&
            Schema.SObjectType.ControleIntegracao__c.fields.IdObjeto__c.isAccessible()
        ) {
            for(
                ControleIntegracao__c controle : [
                    SELECT Id, IdObjeto__c
                    FROM ControleIntegracao__c
                    WHERE
                        CodigoIntegracao__c = '13' AND
                        Status__c = 'Pendente' AND
                        DataCriacaoRegistro__c = :system.today() AND
                        IdObjeto__c IN :sIdObjeto
                ]
            ) {
                sControle.add(controle.IdObjeto__c);
            }
        }

        List<ControleIntegracao__c> lControle2Insert = new List<ControleIntegracao__c>();

        for(MovimentoSinistro__c movSin : lMovSin)
        {
        	String idObjeto = movSin.Id;
        	if(sControle.contains(idObjeto))
            {
                continue;
            }
        	ControleIntegracao__c controleIntegracao = new ControleIntegracao__c();
            controleIntegracao.CodigoIntegracao__c = '13';
            controleIntegracao.Status__c = 'Pendente';
            controleIntegracao.DataCriacaoRegistro__c = system.today();
            controleIntegracao.IdObjeto__c = idObjeto;
            lControle2Insert.add(controleIntegracao);
        }

        if(!lControle2Insert.isEmpty())
        {
            Database.insert(lControle2Insert);
        }
	}

    // POR062-1 - INICIO
	public Map<Id, List<MovimentoSinistro__c>> mapearListaMovimentosPorIdCaso(List<MovimentoSinistro__c> movimentos)
    {
		Map<Id, List<MovimentoSinistro__c>> movimentosPorIdCaso = new Map<Id, List<MovimentoSinistro__c>>();
		for(MovimentoSinistro__c movimento : movimentos)
        {
			if(String.isNotBlank(movimento.Caso__c))
            {
				if(movimentosPorIdCaso.get(movimento.Caso__c) == null)
                {
					movimentosPorIdCaso.put(movimento.Caso__c, new List<MovimentoSinistro__c>());
				}
				movimentosPorIdCaso.get(movimento.Caso__c).add(movimento);
			}
		}
		return movimentosPorIdCaso;
	}

    public Integer recuperarSequenciaMovimento(List<MovimentoSinistro__c> movimentos)
    {
        Integer sequenciaMovimento = 0;
        for(MovimentoSinistro__c movimento : movimentos)
        {
            if(Util.contemApenasNumeros(movimento.SequenciaMovimento__c)) {
                Integer sequenciaTemporaria = Integer.valueof(movimento.SequenciaMovimento__c);
                if(sequenciaTemporaria > sequenciaMovimento)
                {
                    sequenciaMovimento = sequenciaTemporaria;
                }
            }
        }
        return sequenciaMovimento;
    }

    public Decimal calcularValorFechamentoMovimentos(MovimentoSinistro__c movimento, Boolean isJuridico) //LECVPV-140-FIX02 INICIO/FIM
    {
        // LECVPV-216 INICIO
        Set<Integer> movFechamAdmin = MovimentoSinistroTO.getInstance().recuperarConjuntoMovimentoValor(MovimentoSinistroTO.CONJ_MOV_FECHAMENTO_ADMINISTRATIVO);
        Set<Integer> movFechamPagtos = MovimentoSinistroTO.getInstance().recuperarConjuntoMovimentoValor(MovimentoSinistroTO.CONJ_MOV_PAGAMENTOS_INDENIZACAO);
        set<Integer> movFechamIncluir = new Set<Integer>();
        movFechamIncluir.addAll(movFechamAdmin);
        movFechamIncluir.addAll(movFechamPagtos);
        Decimal valorFechamAdmin = 0;

        if(
            movimento.SinistroJudicial__c == isJuridico &&  //LECVPV-140-FIX02 INICIO/FIM
            String.isNotBlank(movimento.DescricaoMovimento__c) &&
            movFechamIncluir.contains(Integer.valueOf(movimento.DescricaoMovimento__c))
        ) {
            valorFechamAdmin =  movFechamAdmin.contains(Integer.valueOf(movimento.DescricaoMovimento__c)) 
            ? movimento.ValorMovimento__c 
            : movimento.ValorMovimento__c*(-1);
        }
        // LECVPV-216 FIM
        return valorFechamAdmin;
    }

    // LECVPV-148 INICIO
    // public Decimal calcularValorFechamento(List<MovimentoSinistro__c> movimentos, Id pagamentoGarantiaId) // LECVPV-142 INICIO/FIM
    // {
    //     Set<Integer> movFechamJur = MovimentoSinistroTO.getInstance().recuperarConjuntoMovimentoValor(MovimentoSinistroTO.CONJ_MOV_FECHAMENTO_JURIDICO);
    //     Decimal valorFechamento = 0;
    //     for(MovimentoSinistro__c movimento : movimentos)
    //     {
    //         if(movimento.SinistroJudicial__c == true && pagamentoGarantiaId != null) // LECVPV-142 INICIO/FIM
    //         {
    //             if(MovimentoSinistroTO.ENCERRAMENTO_SEM_INDENIZACAO.descricaoValor.equals(movimento?.DescricaoMovimento__c))
    //             {
    //                 valorFechamento = 0;
    //             }
    //             else if(movFechamJur.contains(Integer.valueOf(movimento.DescricaoMovimento__c)))
    //             {
    //                 valorFechamento += movimento.ValorMovimento__c;
    //             }
    //         }
    //     }
    //     return valorFechamento;
    // }
     // LECVPV-148 FIM

    public Decimal calcularValorReabertura(List<MovimentoSinistro__c> movimentos)
    {
        Boolean jaSomouReativacao = false;
        Set<Integer> conjMovReajuste = MovimentoSinistroTO.getInstance().recuperarConjuntoMovimentoValor(MovimentoSinistroTO.CONJ_MOV_VALOR_CAPITAL);
        Decimal valorReabertura = 0;
        if(movimentos != null && !movimentos.isEmpty())
        {
            for(MovimentoSinistro__c movimento : movimentos)
            {
                if(
                    movimento.SinistroJudicial__c &&
                    conjMovReajuste.contains(Integer.valueOf(movimento.DescricaoMovimento__c))
                ) {
                    if(movimento.DescricaoMovimento__c.equals(MovimentoSinistroTO.REATIVACAO.descricaoValor))
                    {
                        if(!jaSomouReativacao)
                        {
                            valorReabertura += movimento.ValorMovimento__c;
                            jaSomouReativacao = true;
                        }
                    }
                    else
                    {
                        valorReabertura += movimento.ValorMovimento__c;
                    }
                }
            }
        }
        return valorReabertura;
    }

    public Decimal calcularValorIndenizado(List<MovimentoSinistro__c> movimentos)
    {
        Set<Integer> conjMovGeraValorCalculado = MovimentoSinistroTO.getInstance().recuperarConjuntoMovimentoValor(MovimentoSinistroTO.CONJ_MOV_GERA_VALOR_CALCULADO);
        Decimal valorIndenizado = 0;
        for(MovimentoSinistro__c movimento : movimentos)
        {
            if(movimento.SinistroJudicial__c)
            {
                if(MovimentoSinistroTO.REATIVACAO.descricaoValor.equals(movimento.DescricaoMovimento__c))
                {
                    valorIndenizado = movimento.ValorMovimento__c;
                }
                else if(conjMovGeraValorCalculado.contains(Integer.valueOf(movimento.DescricaoMovimento__c)))
                {
                    valorIndenizado += movimento.ValorMovimento__c;
                }
            }
        }
        return valorIndenizado;
    }

    public Decimal calcularValorJuros(List<MovimentoSinistro__c> movimentos, Boolean casoJudicial)
    {
        Set<Integer> conjMovJuros = MovimentoSinistroTO.getInstance().recuperarConjuntoMovimentoValor(MovimentoSinistroTO.CONJ_MOV_JUROS);
        Decimal valorJuros = 0;
        for(MovimentoSinistro__c movimento : movimentos)
        {
            if(movimento.SinistroJudicial__c == casoJudicial) {
                if(MovimentoSinistroTO.REATIVACAO.descricaoValor.equals(movimento?.DescricaoMovimento__c))
                {
                    valorJuros = 0;
                }
                else if(conjMovJuros.contains(Integer.valueOf(movimento.DescricaoMovimento__c)))
                {
                    valorJuros += movimento.ValorMovimento__c;
                }
            }
        }
        return valorJuros;
    }

    public Decimal calcularValorCorrecao(List<MovimentoSinistro__c> movimentos, Boolean casoJudicial)
    {
        Set<Integer> conjMovCorrecao = MovimentoSinistroTO.getInstance().recuperarConjuntoMovimentoValor(MovimentoSinistroTO.CONJ_MOV_CORRECAO_MONETARIA);
        Decimal valorCorrecao = 0;
        for(MovimentoSinistro__c movimento : movimentos)
        {
             if(movimento.SinistroJudicial__c == casoJudicial)
             {
                if(MovimentoSinistroTO.REATIVACAO.descricaoValor.equals(movimento?.DescricaoMovimento__c))
                {
                    valorCorrecao = 0;
                }
                else if(conjMovCorrecao.contains(Integer.valueOf(movimento.DescricaoMovimento__c)))
                {
                    valorCorrecao += movimento.ValorMovimento__c;
                }
             }
        }
        return valorCorrecao;
    }

	public MovimentoSinistro__c criarMovimentoEncerramentoAdministrativo(  //LECVPV-140-FIX02 INICIO/FIM
		Id idCaso, MovimentoSinistroTO.Movimento movimentoTO, Decimal valorMovimento,
		String sequenciaMovimento, Id pagamentoGarantiaId
	) {
		return this.criarMovimento(idCaso, movimentoTO.descricaoValor, movimentoTO.tipo, valorMovimento, sequenciaMovimento, pagamentoGarantiaId, false);
	}

	public MovimentoSinistro__c criarMovimentoEncerramentoAdministrativo(  //LECVPV-140-FIX02 INICIO/FIM
		Id idCaso, String descricaoMovimento, String tipoMovimento, Decimal valorMovimento,
		String sequenciaMovimento, Id pagamentoGarantiaId
	) {
		return this.criarMovimento(idCaso, descricaoMovimento, tipoMovimento, valorMovimento, sequenciaMovimento, pagamentoGarantiaId, false);
	}

	public MovimentoSinistro__c criarMovimentoEncerramentoJuridico(   //LECVPV-140-FIX02 INICIO/FIM
		Id idCaso, MovimentoSinistroTO.Movimento movimentoTO, Decimal valorMovimento,
		String sequenciaMovimento, Id pagamentoGarantiaId
	) {
		return this.criarMovimento(
            idCaso, movimentoTO.descricaoValor, movimentoTO.tipo, valorMovimento, sequenciaMovimento, pagamentoGarantiaId, true
        );
	}

	public MovimentoSinistro__c criarMovimentoEncerramentoJuridico(   //LECVPV-140-FIX02 INICIO/FIM
		Id idCaso, String descricaoMovimento, String tipoMovimento, Decimal valorMovimento,
		String sequenciaMovimento, Id pagamentoGarantiaId
	) {
		return this.criarMovimento(
            idCaso, descricaoMovimento, tipoMovimento, valorMovimento, sequenciaMovimento, pagamentoGarantiaId, true
        );
	}

    // LECVPV-140-FIX02 INICIO
    public MovimentoSinistro__c criarMovimento(
		Id idCaso, MovimentoSinistroTO.Movimento movimento, Decimal valorMovimento,
		String sequenciaMovimento, Id pagamentoGarantiaId, Boolean sinistroJudicial
	) {
       return this.criarMovimento(idCaso, movimento.descricaoValor, movimento.tipo,valorMovimento,
       sequenciaMovimento,pagamentoGarantiaId,sinistroJudicial);
    }
    // LECVPV-140-FIX02 FIM

	public MovimentoSinistro__c criarMovimento(
		Id idCaso, String descricaoMovimento, String tipoMovimento, Decimal valorMovimento,
		String sequenciaMovimento, Id pagamentoGarantiaId, Boolean sinistroJudicial
	) {
        MovimentoSinistro__c movimento = new MovimentoSinistro__c (
            Caso__c = idCaso,
            DataMovimento__c = System.now(),
            DescricaoMovimento__c = descricaoMovimento,
            TipoMovimento__c = tipoMovimento,
            ValorMovimento__c = valorMovimento,
            SinistroJudicial__c = sinistroJudicial,
            PagamentoGarantia__c = pagamentoGarantiaId
        );
        if(Util.contemApenasNumeros(sequenciaMovimento))
        {
            movimento.SequenciaMovimento__c = sequenciaMovimento;
        }
		return movimento;
	}
    
    public List<MovimentoSinistro__c> criarMovimentosReativacaoJuridico(Id idCaso, List<MovimentoSinistro__c> movimentos) //LECVPV-140-FIX02 INICIO/FIM
    {
        List<MovimentoSinistro__c> movimentosReativacaoParaCriar = new List<MovimentoSinistro__c>();
        System.debug('Giordano - Criar Movimentos Reativação');
        for(MovimentoSinistro__c movimento : movimentos)
        {
            if(
                movimento.SinistroJudicial__c && //LECVP-216 - INICIO / FIM
                MovimentoSinistroTO.AVISO_MAIS.descricaoValor.equals(movimento.DescricaoMovimento__c)
            ) {
                MovimentoSinistro__c reativacaoJuridico = this.criarMovimentoEncerramentoJuridico(  //LECVPV-140-FIX02 INICIO/FIM
                    idCaso, MovimentoSinistroTO.REATIVACAO, movimento.ValorMovimento__c, null, movimento.PagamentoGarantia__c
                );
                System.debug('Giordano - '+ reativacaoJuridico);
                movimentosReativacaoParaCriar.add(reativacaoJuridico);
            }
        }
        return movimentosReativacaoParaCriar;
    }


    // LECVPV-216 INICIO
    // LECVPV-215 INICIO
    public List<MovimentoSinistro__c> criarMovimentoFechamentoGarantia(
        Id idGarantia, Integer sequencia, Boolean isJuridico, Boolean criareativacao
    ) {
        List<MovimentoSinistro__c> novosMovimentos = new List<MovimentoSinistro__c>();

        PagamentoGarantia__c garantia = [SELECT Id, Fase__c, Caso__c FROM PagamentoGarantia__c WHERE Id = :idGarantia];

        List<MovimentoSinistro__c> listaMovtos = MovimentoSinistroDAO.getInstance().buscarMovimentosPorGarantia(new Set<Id>{idGarantia});
       // Integer sequenciaMovimento = this.recuperarSequenciaMovimento(listaMovtos);
        Decimal valorFechamento = 0;

        Decimal totalPrincipal = 0;
        Decimal totalJuros = 0;
        Decimal totalCorrecao = 0;
        Set<Integer> movsJuros = MovimentoSinistroTO.getInstance().recuperarConjuntoMovimentoValor(MovimentoSinistroTO.CONJ_MOV_JUROS);
        Set<Integer> movsCorrecao = MovimentoSinistroTO.getInstance().recuperarConjuntoMovimentoValor(MovimentoSinistroTO.CONJ_MOV_CORRECAO_MONETARIA);

        for(MovimentoSinistro__c mov : listaMovtos){

          //  boolean isPagamento = (mov.DescricaoMovimento__c == MovimentoSinistroTO.PAGAMENTO_PARCIAL_MAIS.descricaoValor ||
          //  mov.DescricaoMovimento__c == MovimentoSinistroTO.PAGAMENTO_FINAL_MAIS.descricaoValor ||
          //  mov.DescricaoMovimento__c == MovimentoSinistroTO.ACERTO_PAGAMENTO_FINAL_MAIS.descricaoValor) ? true : false;
            valorFechamento = this.calcularValorFechamentoMovimentos(mov, isJuridico)*(-1);

            if(movsJuros.contains(Integer.valueOf(mov.DescricaoMovimento__c))) {
               totalJuros += valorFechamento;
            }  else if (movsCorrecao.contains(Integer.valueOf(mov.DescricaoMovimento__c))) {
                totalCorrecao += valorFechamento;
            } else {
                totalPrincipal += valorFechamento; 
            }
        }

        MovimentoSinistro__c movimentoFechamentoPrincipal = null;
        MovimentoSinistro__c movimentoFechamentoJuros = null;
        MovimentoSinistro__c movimentoFechamentoCorrecao = null;

        if (totalJuros <0) {
            movimentoFechamentoJuros = isJuridico ? 
                this.criarMovimentoEncerramentoJuridico(
                    garantia.Caso__c, MovimentoSinistroTO.ACERTO_JUROS_MENOS,
                    totalJuros, String.valueOf(sequencia++), idGarantia) :
                this.criarMovimentoEncerramentoAdministrativo(
                    garantia.Caso__c, MovimentoSinistroTO.ACERTO_JUROS_MENOS,
                    totalJuros, String.valueOf(sequencia++), idGarantia);    
        }
        if (totalCorrecao <0) {
            movimentoFechamentoCorrecao = isJuridico ? 
            this.criarMovimentoEncerramentoJuridico(
                garantia.Caso__c, MovimentoSinistroTO.ACERTO_CORRECAO_JUROS_MENOS,
                totalCorrecao, String.valueOf(sequencia++), idGarantia) :
            this.criarMovimentoEncerramentoAdministrativo(
                garantia.Caso__c, MovimentoSinistroTO.ACERTO_CORRECAO_JUROS_MENOS,
                totalCorrecao, String.valueOf(sequencia++), idGarantia);  
        }
        if (totalPrincipal <0) {
            movimentoFechamentoPrincipal = isJuridico ? 
            this.criarMovimentoEncerramentoJuridico(
                garantia.Caso__c, MovimentoSinistroTO.ENCERRAMENTO_SEM_INDENIZACAO,
                totalPrincipal, String.valueOf(sequencia++), idGarantia) :
            this.criarMovimentoEncerramentoAdministrativo(
                garantia.Caso__c, MovimentoSinistroTO.ENCERRAMENTO_SEM_INDENIZACAO,
                totalPrincipal, String.valueOf(sequencia++), idGarantia);  
        }
        if (movimentoFechamentoJuros != null) novosMovimentos.add(movimentoFechamentoJuros);
        if (movimentoFechamentoCorrecao != null) novosMovimentos.add(movimentoFechamentoCorrecao);      
        if (movimentoFechamentoPrincipal != null) novosMovimentos.add(movimentoFechamentoPrincipal);

        if (!isJuridico && criareativacao) {
            List<MovimentoSinistro__c> movimentosReativacao = this.criarMovimentosReativacaoJuridico(garantia.Caso__c, listaMovtos);
            novosMovimentos.addAll(movimentosReativacao);
        }
        return novosMovimentos;
    }
    // LECVPV-215 FIM
    // LECVPV-216 FIM
    
    //LECVPV-140-FIX02 INICIO
    //LECVP-216 - INICIO
    public List<MovimentoSinistro__c> criarMovimentoFechamento(
        Id idCaso, List<MovimentoSinistro__c> movimentos, Boolean isJuridico, Boolean criareativacao
    )
    //LECVPV-140-FIX02 FIM
     {
        List<MovimentoSinistro__c> novosMovimentos = new List<MovimentoSinistro__c>();
        Decimal valorFechamento = 0; // LECVPV-140-FIX02 - INICIO/FIM
        Integer sequenciaMovimento = this.recuperarSequenciaMovimento(movimentos);

		Set<Id> casoId = new Set<Id>{idCaso};
		List<PagamentoGarantia__c> pagtoGarantia = PagamentoGarantiaDAO.getInstance().buscarPorCaso(casoId);
        Map<Id, PagamentoGarantia__c> mapGarantiaId = new Map<Id, PagamentoGarantia__c>(); //LECVPV-140-FIX02 INICIO/FIM
        System.debug('Henrique pagtoGarantia: ' + pagtoGarantia);
        /*List<Garantia__c> garantia = GarantiaDAO.getInstance().buscarGarantiasPorSigla(new Set<String>{pagtoGarantia[0].Garantia_do_segurado_do_contrato__r.Garantia__r.Sigla__c});
		Set<String> cobertura = new Set<String>{garantia[0].Sigla__c};
		List<PagamentoGarantia__c> pgtoGarantiaValorIndenizado = PagamentoGarantiaDAO.getInstance().buscarPorIdDeCasoECobertura(casoId, cobertura);*/
		Set<Id> garantiasId = new Set<Id>{};
				
		for(PagamentoGarantia__c pg : pagtoGarantia){
            // LECVPV-216 INICIO
            if (!'Fechado'.equals(pg.Fase__c)) {
                garantiasId.add(pg.Id);
                mapGarantiaId.put(pg.Id,pg); //LECVPV-140-FIX02 INICIO/FIM
            }
             // LECVPV-216 FIM
		}
        System.debug('DOUGLAS garantiasId: ' + garantiasId);
        // LECVPV-140-FIX06 INICIO
        // Map<Id, decimal> mapGarantiaSinistroDecimal = new Map<Id, decimal>();
        Map<Id, decimal> mapGarantiaSinistroPrincipal = new Map<Id, decimal>();
        Map<Id, decimal> mapGarantiaSinistroJuros = new Map<Id, decimal>();
        Map<Id, decimal> mapGarantiaSinistroCorrecao = new Map<Id, decimal>();
        // LECVPV-140-FIX06 FIM
		List<MovimentoSinistro__c> listaMovtos = MovimentoSinistroDAO.getInstance().buscarMovimentosPorGarantia(garantiasId);
     //   Decimal valorFechGarantia = 0; // LECVPV-140-FIX02 - INICIO/FIM
        for(MovimentoSinistro__c mov : listaMovtos){
            // LECVPV-216 INICIO
            // LECVPV-140-FIX04 INICIO
			// if(mov.DescricaoMovimento__c != MovimentoSinistroTO.PAGAMENTO_PARCIAL_MAIS.descricaoValor &&
			// 	mov.DescricaoMovimento__c != MovimentoSinistroTO.PAGAMENTO_FINAL_MAIS.descricaoValor &&
			// 	mov.DescricaoMovimento__c != MovimentoSinistroTO.ACERTO_PAGAMENTO_FINAL_MAIS.descricaoValor) 
			// //	mov.DescricaoMovimento__c != MovimentoSinistroTO.ENCERRAMENTO_SEM_INDENIZACAO.descricaoValor)
            // // LECVPV-140-FIX04 FIM
            // {     
            //LECVPV-140-FIX02 INICIO
             //   Set<Integer> movsPagamento = MovimentoSinistroTO.getInstance().recuperarConjuntoMovimentoValor(MovimentoSinistroTO.CONJ_MOV_PAGAMENTOS_INDENIZACAO);
             //   boolean isPagamento = movsPagamento.contains(Integer.valueOf(mov.DescricaoMovimento__c)) ? true : false;
              //  valorFechamento = this.calcularValorFechamentoMovimentos(mov, isJuridico);
              //  System.debug ('HENRIQUE DEBUG: ' + valorFechamento);
                valorFechamento = this.calcularValorFechamentoMovimentos(mov, isJuridico)*(-1);
                // LECVPV-140-FIX06 INICIO
                Map<Id, decimal> mapGarantiaSinistroDecimal = new Map<Id, decimal>();      
                Set<Integer> movsJuros = MovimentoSinistroTO.getInstance().recuperarConjuntoMovimentoValor(MovimentoSinistroTO.CONJ_MOV_JUROS);
                Set<Integer> movsCorrecao = MovimentoSinistroTO.getInstance().recuperarConjuntoMovimentoValor(MovimentoSinistroTO.CONJ_MOV_CORRECAO_MONETARIA);
                if(movsJuros.contains(Integer.valueOf(mov.DescricaoMovimento__c))) {
                    mapGarantiaSinistroDecimal = mapGarantiaSinistroJuros;
                } else if (movsCorrecao.contains(Integer.valueOf(mov.DescricaoMovimento__c))) {
                    mapGarantiaSinistroDecimal = mapGarantiaSinistroCorrecao; 
                } else {
                    mapGarantiaSinistroDecimal = mapGarantiaSinistroPrincipal; 
                }
                // LECVPV-140-FIX06 FIM
                if(mapGarantiaSinistroDecimal.containsKey(mov.PagamentoGarantia__c)){
                    Decimal valorGarantia = mapGarantiaSinistroDecimal.get(mov.PagamentoGarantia__c);
                    mapGarantiaSinistroDecimal.put(mov.PagamentoGarantia__c,valorGarantia + valorFechamento);
                    System.debug('ENTROU AQUI HENRIQUE: ' +mapGarantiaSinistroDecimal );
                }else{
                    mapGarantiaSinistroDecimal.put(mov.PagamentoGarantia__c,valorFechamento);
                    System.debug('ENTROU AQUI NO ELSE: ' + mapGarantiaSinistroDecimal);
                } 
            //LECVPV-140-FIX02 FIM             
        //    }  
        // LECVPV-216 FIM
		}

        //LECVPV-140-FIX02 INICIO   
        for(Id idPagGarantia : mapGarantiaId.keySet()){
        // LECVPV-140-FIX06 INICIO
            MovimentoSinistro__c movimentoFechamentoPrincipal = null;
            MovimentoSinistro__c movimentoFechamentoJuros = null;
            MovimentoSinistro__c movimentoFechamentoCorrecao = null;
            //  MovimentoSinistro__c movimentoFechamento = null;
            // if (isJuridico && !'Fechado'.equals(mapGarantiaId.get(idPagGarantia).Fase__c)) {
            //     movimentoFechamento = this.criarMovimentoEncerramentoJuridico(
            //     idCaso, MovimentoSinistroTO.ENCERRAMENTO_SEM_INDENIZACAO,
            //     mapGarantiaSinistroDecimal.get(idPagGarantia), String.valueOf(++sequenciaMovimento), idPagGarantia);
            // }
            if (isJuridico && !'Fechado'.equals(mapGarantiaId.get(idPagGarantia).Fase__c)) {
                if (mapGarantiaSinistroJuros.size()>0 && 
                    mapGarantiaSinistroJuros.get(idPagGarantia)!=null) {
                        movimentoFechamentoJuros = this.criarMovimentoEncerramentoJuridico(
                            idCaso, MovimentoSinistroTO.ACERTO_JUROS_MENOS,
                            mapGarantiaSinistroJuros.get(idPagGarantia), String.valueOf(++sequenciaMovimento), idPagGarantia);
                }
                if (mapGarantiaSinistroCorrecao.size()>0 && 
                    mapGarantiaSinistroCorrecao.get(idPagGarantia)!=null) {
                        movimentoFechamentoCorrecao = this.criarMovimentoEncerramentoJuridico(
                            idCaso, MovimentoSinistroTO.ACERTO_CORRECAO_JUROS_MENOS,
                            mapGarantiaSinistroCorrecao.get(idPagGarantia), String.valueOf(++sequenciaMovimento), idPagGarantia);
                }
                if (mapGarantiaSinistroPrincipal.size()>0 && 
                mapGarantiaSinistroPrincipal.get(idPagGarantia)!=null) {
                    movimentoFechamentoPrincipal = this.criarMovimentoEncerramentoJuridico(
                        idCaso, MovimentoSinistroTO.ENCERRAMENTO_SEM_INDENIZACAO,
                        mapGarantiaSinistroPrincipal.get(idPagGarantia), String.valueOf(++sequenciaMovimento), idPagGarantia);
                }
            } 
            if (!isJuridico) {
            //     movimentoFechamento =  this.criarMovimentoEncerramentoAdministrativo(
            //         idCaso, MovimentoSinistroTO.ENCERRAMENTO_SEM_INDENIZACAO,
            //         mapGarantiaSinistroDecimal.get(idPagGarantia), String.valueOf(++sequenciaMovimento), idPagGarantia);
            // }                    
            // if (movimentoFechamento != null) novosMovimentos.add(movimentoFechamento);   
                if (mapGarantiaSinistroJuros.size()>0 && 
                    mapGarantiaSinistroJuros.get(idPagGarantia)!=null) {
                        movimentoFechamentoJuros = this.criarMovimentoEncerramentoAdministrativo(
                            idCaso, MovimentoSinistroTO.ACERTO_JUROS_MENOS,
                            mapGarantiaSinistroJuros.get(idPagGarantia), String.valueOf(++sequenciaMovimento), idPagGarantia);
                }
                if (mapGarantiaSinistroCorrecao.size()>0 && 
                        mapGarantiaSinistroCorrecao.get(idPagGarantia)!=null) {
                            movimentoFechamentoCorrecao = this.criarMovimentoEncerramentoAdministrativo(
                                idCaso, MovimentoSinistroTO.ACERTO_CORRECAO_JUROS_MENOS,
                                mapGarantiaSinistroCorrecao.get(idPagGarantia), String.valueOf(++sequenciaMovimento), idPagGarantia);
                } 
                if (mapGarantiaSinistroPrincipal.size()>0 && 
                mapGarantiaSinistroPrincipal.get(idPagGarantia)!=null) {
                    movimentoFechamentoPrincipal =  this.criarMovimentoEncerramentoAdministrativo(
                        idCaso, MovimentoSinistroTO.ENCERRAMENTO_SEM_INDENIZACAO,
                        mapGarantiaSinistroPrincipal.get(idPagGarantia), String.valueOf(++sequenciaMovimento), idPagGarantia);
                }
            }                   
            if (movimentoFechamentoJuros != null) novosMovimentos.add(movimentoFechamentoJuros);
            if (movimentoFechamentoCorrecao != null) novosMovimentos.add(movimentoFechamentoCorrecao);      
            if (movimentoFechamentoPrincipal != null) novosMovimentos.add(movimentoFechamentoPrincipal);
        // LECVPV-140-FIX06 FIM
        }
        System.debug('NOVOS MOVIMENTOS: ' + novosMovimentos);
        if (!isJuridico && criareativacao) {
            List<MovimentoSinistro__c> movimentosReativacao = this.criarMovimentosReativacaoJuridico(idCaso, movimentos);
            novosMovimentos.addAll(movimentosReativacao);
        }
        return novosMovimentos;
        //LECVPV-140-FIX02 FIM   
    }
    //LECVP-216 - FIM

    // LECVPV-216 INICIO
    public void criarComplementosEncerramento(List<MovimentoSinistro__c> movimentoSin) {
        
        List<ComplementoIndenizacao__c> complementosCriar = new List<ComplementoIndenizacao__c>();
        Set<Id> garantiasComplIds = new Set<Id>();

        for (MovimentoSinistro__c ms : movimentoSin) {
            if (MovimentoSinistroTO.ENCERRAMENTO_SEM_INDENIZACAO.descricaoValor.equals(ms.DescricaoMovimento__c)) {
                garantiasComplIds.add(ms.PagamentoGarantia__c);
            }
        }
        if (garantiasComplIds.isEmpty()) return;

        Map<Id,List<ComplementoIndenizacao__c>> mapComplementosGarantia = new  Map<Id,List<ComplementoIndenizacao__c>>();

        Map<Id, PagamentoGarantia__c> mapGarantias = new Map<Id, PagamentoGarantia__c>(
            [SELECT Id, Fase__c, (SELECT Id, TipoComplemento__c, Valor__c, PagamentoGarantia__c FROM ComplementosIndenizacoes__r) 
            FROM PagamentoGarantia__c WHERE Id IN :garantiasComplIds]
        );

        List<ComplementoIndenizacao__c> complementosGarantias = [SELECT Id, TipoComplemento__c, Valor__c, PagamentoGarantia__c FROM ComplementoIndenizacao__c
                                                                 WHERE PagamentoGarantia__c IN :garantiasComplIds];

        for (ComplementoIndenizacao__c compl : complementosGarantias) {
          if (!mapComplementosGarantia.containsKey(compl.PagamentoGarantia__c)) {
                mapComplementosGarantia.put(compl.PagamentoGarantia__c,new List<ComplementoIndenizacao__c>());
          }
          mapComplementosGarantia.get(compl.PagamentoGarantia__c).add(compl);
        }

        for (Id garId : garantiasComplIds) {
            PagamentoGarantia__c pagG = mapGarantias.get(garId);
            complementosCriar.addAll(
                ComplementoIndenizacaoBO.getInstance().criarComplementosDeFechamento(
                    pagG.ComplementosIndenizacoes__r, pagG.Id
                )
            );
        }
        if (!complementosCriar.isEmpty())
        insert complementosCriar;
    }
    // LECVPV-216 FIM


     //LECVPV-140-FIX02 INICIO   
        // public List<MovimentoSinistro__c> criarMovFechaAdmEReabJur(
        //     List<Case> casosAdministrativos,
        //     Map<Id, List<MovimentoSinistro__c>> movimentosPorIdCaso
        // ) {
        //     List<MovimentoSinistro__c> novosMovimentos = new List<MovimentoSinistro__c>();
        //     for(Case caso : casosAdministrativos)
        //     {
        //         if(
        //             caso.Sinistro_Judicial__c ||
        //             !movimentosPorIdCaso.keySet().contains(caso.Id) ||
        //             movimentosPorIdCaso.get(caso.Id).isEmpty()
        //         ) {
        //             continue;
        //         }
        //         List<MovimentoSinistro__c> movimentosCriados = this.criarMovimentoFechamentoAdministrativoEReaberturaJuridico(
        //             caso.Id, movimentosPorIdCaso.get(caso.Id)
        //         );
        //         novosMovimentos.addAll(movimentosCriados);
        //  }
        //  return novosMovimentos;
        //  }
   //LECVPV-140-FIX02 FIM  
    
    public Boolean verificarSeExistePagamentosIndenizacao(List<MovimentoSinistro__c> movimentos)
    {
        Set<Integer> conjMovValor = MovimentoSinistroTO.getInstance().recuperarConjuntoMovimentoValor(
            MovimentoSinistroTO.CONJ_MOV_PAGAMENTOS_INDENIZACAO
        );
        Boolean existe = false;
        for(MovimentoSinistro__c movimento : movimentos)
        {
            existe = conjMovValor.contains(Integer.valueOf(movimento.DescricaoMovimento__c));
            if(existe)
            {
                break;
            }
        }
        return existe;
    }

    public MovimentoSinistro__c recuperarUltimoMovFechamento(List<MovimentoSinistro__c> movimentos) {
        MovimentoSinistro__c movFechamento = null;
        for(Integer index=movimentos.size()-1; index>=0; index--)
        {
            MovimentoSinistro__c movimentoAuxiliar = movimentos.get(index);
            if(MovimentoSinistroTO.ENCERRAMENTO_SEM_INDENIZACAO.descricaoValor.equals(movimentoAuxiliar?.DescricaoMovimento__c))
            {
                movFechamento = movimentoAuxiliar;
                break;
            }
        }
        return movFechamento;
    }

    public List<MovimentoSinistro__c> filtrarCobertura(List<MovimentoSinistro__c> movimentos, Id pagamentoGarantiaId, Boolean igual)
    {
        List<MovimentoSinistro__c> movimentosDaCobertura = new List<MovimentoSinistro__c>();
        if(String.isNotBlank(pagamentoGarantiaId))
        {
            for(MovimentoSinistro__c movimento : movimentos)
            {
                if(
                    (igual && pagamentoGarantiaId.equals(movimento?.PagamentoGarantia__c)) ||
                    (!igual && !pagamentoGarantiaId.equals(movimento?.PagamentoGarantia__c))
                )
                {
                    movimentosDaCobertura.add(movimento);
                }
            }
        }
        return movimentosDaCobertura;
    }
    // POR062-1 - FIM
}