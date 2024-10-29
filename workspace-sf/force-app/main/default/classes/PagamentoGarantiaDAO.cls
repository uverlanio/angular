// POR062-1 - INICIO
public inherited sharing virtual class PagamentoGarantiaDAO {
    private static final PagamentoGarantiaDAO INSTANCIA = new PagamentoGarantiaDAO();
    private PagamentoGarantiaDAO() {}

	public static PagamentoGarantiaDAO getInstance()
    {
		return instancia;
	}
    
    public List<PagamentoGarantia__c> buscarPorCaso(Set<Id> idsCaso)
    {
        List<PagamentoGarantia__c> pagamentoGarantiaLista = [
            SELECT
                Id, Name, Fase__c, Status_do_pagamento__c, Caso__c, Garantia_do_segurado_do_contrato__c, Garantia_do_segurado_do_contrato__r.Garantia__r.Name,
				Garantia_do_segurado_do_contrato__r.Garantia__r.Sigla__c, Garantia_do_segurado_do_contrato__r.Garantia__r.Descricao__c,
				Valor_indenizado__c/* PLV-4624 */, ValorIndenizado__c /* PLV-4624 */, Capital__c, /*LECVP-216 - INICIO / FIM*/Saldo_da_reserva__c, Valor_Pago__c, /*LECVP-344 INICIO - FIM*/
                (SELECT Id, Motivo__c, Descricao__c, TipoComplemento__c, Valor__c FROM ComplementosIndenizacoes__r ORDER By ID)
			FROM PagamentoGarantia__c
			WHERE Caso__c IN :idsCaso
            ORDER By ID
        ];
        return pagamentoGarantiaLista;
    }
    
    public List<PagamentoGarantia__c> buscarPorIdDeCasoECobertura(Set<Id> idsCaso, Set<String> coberturas)
    {
        List<PagamentoGarantia__c> pagamentoGarantiaLista = [
            SELECT
                Id, Name, Fase__c, Status_do_pagamento__c, Caso__c, Garantia_do_segurado_do_contrato__c, Garantia_do_segurado_do_contrato__r.Garantia__r.Name,
                Garantia_do_segurado_do_contrato__r.Garantia__r.Sigla__c, Garantia_do_segurado_do_contrato__r.Garantia__r.Descricao__c,
                Valor_indenizado__c/* PLV-4624 */, ValorIndenizado__c /* PLV-4624 */, Capital__c, /*LECVP-216 - INICIO / FIM */
                (SELECT Id, Motivo__c, Descricao__c, TipoComplemento__c, Valor__c FROM ComplementosIndenizacoes__r ORDER By ID)
			FROM PagamentoGarantia__c
			WHERE
                Caso__c IN :idsCaso AND
                Garantia_do_segurado_do_contrato__r.Garantia__r.Sigla__c IN :coberturas
            ORDER By ID
        ];
        return pagamentoGarantiaLista;
    }

    //LECVP-318 - INICIO
    public List<PagamentoGarantia__c> buscarCasoParaAtualizarFaseStatus(Id casoId){ 
        List<PagamentoGarantia__c> pagamentoGarantiaLista = [
            SELECT 
                Id,
                Caso__c,
                Caso__r.Id,
                Caso__r.Saldo_da_reserva__c, //II-59 INICIO-FIM
                Caso__r.Contrato__r.CodigoRamo__c,
                Caso__r.Status, // II-59-FIX02-INICIO/FIM
                Caso__r.Status_Dependente__c, // II-59-FIX02-INICIO/FIM
                Caso__r.Motivos_de_recusa__c, // II-59-FIX02-INICIO/FIM
                Fase__c,
                Status_do_pagamento__c,
                Capital__c,
                ValorIndenizado__c, //LECVPV-238-INICIO/FIM
                CreatedDate, //II-59 INICIO-FIM
                Garantia_do_segurado_do_contrato__r.Garantia__r.Sigla__c,
                Saldo_da_reserva__c // II-59-FIX02-INICIO/FIM
            FROM
                PagamentoGarantia__c 
            WHERE
                Caso__c = :casoId   
        ];

        return pagamentoGarantiaLista;
    }
    //LECVP-318 - FIM

    //FNPVVEP-19 - INICIO
    public List<PagamentoGarantia__c> buscarCasosBySetId(Set<Id> casosId){ 
        List<PagamentoGarantia__c> pagamentosGarantia = [
            SELECT 
                Id,
                Caso__c,
                Caso__r.Id,
                Caso__r.Saldo_da_reserva__c,           
                Caso__r.Contrato__r.CodigoRamo__c,
                Caso__r.Status, 
                Caso__r.Status_Dependente__c, 
                Caso__r.Motivos_de_recusa__c, 
                Fase__c,
                Status_do_pagamento__c,
                Capital__c,
                CreatedDate,           
                Garantia_do_segurado_do_contrato__r.Garantia__r.Sigla__c,
                Saldo_da_reserva__c 
            FROM
                PagamentoGarantia__c 
            WHERE
                Caso__c IN :casosId   
        ];

        return pagamentosGarantia;
    }
    //FNPVVEP-19 - INICIO



    //LECVP-344 - INICIO
    public List<MovimentoSinistro__c> buscarTipoMovEGarantias(Set<Id> garantiasId, Set<String> tipoMovimento){
        List<MovimentoSinistro__c> movimentos = [
            SELECT 
                Id,
                ValorMovimento__c,
                TipoMovimento__c,  
                DescricaoMovimento__c,
                PagamentoGarantia__c
            FROM
                MovimentoSinistro__c 
            WHERE
                PagamentoGarantia__c IN :garantiasId
            AND 
                TipoMovimento__c LIKE :tipoMovimento
        ];

        return movimentos;
    }    
    //LECVP-344 - FIM
}
// POR062-1 - FIM