// POR062-1 - INICIO
public inherited sharing virtual class ComplementoIndenizacaoBO {
	private ComplementoIndenizacaoBO() {}

	private static final ComplementoIndenizacaoBO INSTANCIA = new ComplementoIndenizacaoBO();

	public static ComplementoIndenizacaoBO getInstance()
    {
		return INSTANCIA;
	}


	// LECVPV-200 INICIO
	// LECVPV-216 INICIO
	public ComplementoIndenizacao__c criarComplemento(
		SinistroJuridicoBO.Request sinistro, Decimal valorComplemento,
		Id pagamentoGarantiaId, String tipo
	) {
		MovimentoSinistroTO.Movimento movimentoTO = MovimentoSinistroTO.MAPA_MOV_POR_VALOR.get(sinistro.movimento);
        String descricao = String.isBlank(movimentoTO?.tipoComplemento) ? movimentoTO?.descricao : 'API - Jurídico Matricula: ' + sinistro.matricula;
        return criarComplemento(descricao,valorComplemento,pagamentoGarantiaId,tipo);
	}
	// LECVPV-216 FIM
	// LECVPV-200 FIM

	// LECVPV-216 INICIO
	public ComplementoIndenizacao__c criarComplemento(
		String descricao, Decimal valorComplemento,
		Id pagamentoGarantiaId, String tipo
	) {
		ComplementoIndenizacao__c cmp = new ComplementoIndenizacao__c();
		cmp.Valor__c = valorComplemento;
		cmp.CurrencyIsoCode = 'BRL';
		cmp.Motivo__c = 'Jurídico';
		cmp.Descricao__c = descricao;
		cmp.TipoComplemento__c = tipo;
		cmp.PagamentoGarantia__c = pagamentoGarantiaId;
		return cmp;
	}
	// LECVPV-216 FIM

    public Decimal calcularValorComplementoPorTipo(List<ComplementoIndenizacao__c> complementos, String tipo)
    {
        Decimal valorComplementoPorTipo = 0;
        if(
            String.isNotBlank(tipo) &&
            complementos != null && !complementos.isEmpty()
        ) {
            for(ComplementoIndenizacao__c complemento : complementos)
            {
                if(tipo.equals(complemento.TipoComplemento__c))
                {
                    valorComplementoPorTipo += complemento.Valor__c;
                }
            }
        }
        return valorComplementoPorTipo;
    }
	
	// LECVPV-216 INICIO
	// public ComplementoIndenizacao__c criarComplementoPorTipo(
	// 	SinistroJuridicoBO.Request sinistro, List<ComplementoIndenizacao__c> complementos,
	// 	String tipo, Id pagamentoGarantiaId,Decimal fator // LECVPV-200 INICIO/FIM
	// ) {
	// 	Decimal valorComplemento = ComplementoIndenizacaoBO.getInstance().calcularValorComplementoPorTipo(
	// 		complementos, tipo
	// 	);
	// 	ComplementoIndenizacao__c complementoFechamento = null;
	// 	if(valorComplemento > 0)
	// 	{
	// 		complementoFechamento = ComplementoIndenizacaoBO.getInstance().criarComplemento(
	// 			sinistro, -valorComplemento*fator, pagamentoGarantiaId, tipo  // LECVPV-200 INICIO/FIM
	// 		);
	// 	}
	// 	return complementoFechamento;
	// }
	// LECVPV-216 FIM

	// LECVPV-216 INICIO
	private ComplementoIndenizacao__c criarComplementoPorTipo(
		String descricao, List<ComplementoIndenizacao__c> complementos,
		String tipo, Id pagamentoGarantiaId, Decimal fator 
	) {
		Decimal valorComplemento = calcularValorComplementoPorTipo(
			complementos, tipo
		);
		ComplementoIndenizacao__c complementoFechamento = null;
		if(valorComplemento > 0)
		{
			complementoFechamento = criarComplemento(
				descricao, -valorComplemento*fator, pagamentoGarantiaId, tipo  
			);
		}
		return complementoFechamento;
	}
	// LECVPV-216 FIM


	// LECVPV-216 INICIO
	public List<ComplementoIndenizacao__c> criarComplementosDeFechamento(
		List<ComplementoIndenizacao__c> complementos, Id pagamentoGarantiaId
	) {
		List<ComplementoIndenizacao__c> complementosParaCriar = new List<ComplementoIndenizacao__c>();
		if(complementos != null && !complementos.isEmpty())
		{
			ComplementoIndenizacao__c complementoJuros = criarComplementoPorTipo(
				'Baixa por Encerramento sem indenização', complementos, MovimentoSinistroTO.ACERTO_JUROS_MAIS.tipoComplemento, pagamentoGarantiaId,1  // LECVPV-200 INICIO/FIM
			);
			if(complementoJuros != null)
			{
				complementosParaCriar.add(complementoJuros);
			}
			ComplementoIndenizacao__c complementoAtualizacaoMonetaria = criarComplementoPorTipo(
				'Baixa por Encerramento sem indenização', complementos, MovimentoSinistroTO.ACERTO_CORRECAO_JUROS_MAIS.tipoComplemento, pagamentoGarantiaId,1 // LECVPV-200 INICIO/FIM
			);
			if(complementoAtualizacaoMonetaria != null)
			{
				complementosParaCriar.add(complementoAtualizacaoMonetaria);
			}
		}
		return complementosParaCriar;
	}
	// LECVPV-216 FIM

		// LECVPV-200 - INICIO
		public List<ComplementoIndenizacao__c> criarComplementosBaixaPorPagamento(Decimal fator,Id pagamentoGarantiaId ) {
			List<ComplementoIndenizacao__c> complementos = [SELECT Id, PagamentoGarantia__c, Motivo__c, Descricao__c, TipoComplemento__c, Valor__c FROM ComplementoIndenizacao__c WHERE PagamentoGarantia__c=:pagamentoGarantiaId];
			List<ComplementoIndenizacao__c> complementosParaCriar = new List<ComplementoIndenizacao__c>();

			if(complementos != null && !complementos.isEmpty())
			{
				// LECVPV-216 INICIO
				ComplementoIndenizacao__c complementoJuros = ComplementoIndenizacaoBO.getInstance().criarComplementoPorTipo(
					'Baixa Por Pagamento', complementos, MovimentoSinistroTO.ACERTO_JUROS_MAIS.tipoComplemento, pagamentoGarantiaId,fator
				);
				if(complementoJuros != null)
				{
					complementosParaCriar.add(complementoJuros);
				}
				ComplementoIndenizacao__c complementoAtualizacaoMonetaria = ComplementoIndenizacaoBO.getInstance().criarComplementoPorTipo(
					'Baixa Por Pagamento', complementos, MovimentoSinistroTO.ACERTO_CORRECAO_JUROS_MAIS.tipoComplemento, pagamentoGarantiaId,fator
				);
				// LECVPV-216 FIM
				if(complementoAtualizacaoMonetaria != null)
				{
					complementosParaCriar.add(complementoAtualizacaoMonetaria);
				}
			}
			return complementosParaCriar;
		}
		// LECVPV-200 - FIM
}
// POR062-1 - FIM