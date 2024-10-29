/**************************************************************************************************************************************************************************
 *
 *  Classe responsável pela busca de dados de Caso
 *
 **************************************************************************************************************************************************************************/
public virtual class CasoDAO {
    
    private static final CasoDAO instancia = new CasoDAO();

  private CasoDAO() { }

  public static CasoDAO getInstance(){
    return instancia;
  }
  
    
    /*public List<Case> buscarSinistroPorId(Set<Id> Ids) {
    return [SELECT Id, AccountId, Dataocorrencia__c, Data_sinistro_avisado__c, Status,
                   Status_Dependente__c, NumeroSinistro__c,
                   Contrato__r.Parceria__c, Contrato__r.Parceria__r.Codigo__c,
                   Contrato__r.Produto__c, Contrato__r.Proposta__r.Origem__c,
                   Contrato__r.Proposta__r.QuoteNumber, Contrato__r.NumeroApolice__c,
                   Account.Cpf__c, Account.Name, CreatedDate, CaseNumber, Contrato__r.Parceiro__c,
                   (SELECT Id, Conta__r.Cpf__c, Conta__r.Name
                   FROM Beneficiarios_do_sinistro__r)
                   FROM Case
           WHERE Id IN :Ids ORDER BY Contrato__r.Parceria__c 
        ];  
  }*/
    //PLV-4938 - INICIO - PEDRO AUGUSTO BRAZ
    public List<Case> getCaseBySetId(Set<Id> Ids) {
      return [SELECT Id
                    , AccountId
                    , Dataocorrencia__c
                    , Data_sinistro_avisado__c
                    , Status
                    , Account.Cpf__c
                    , Account.Name
                    , CreatedDate
                    , CaseNumber
                    , Contrato__r.Parceiro__c
                    , Vitima__c
                    , Subject
                    , Description
                    , ContactId
                    , Type
                    , Data_pagamento__c // LECVP-317 - INICIO
                    , Invoice__c                   
                    , Contrato__r.TipoViagem__c
                    , Contrato__r.CodigoRamo__c  // LECVP-317 - FIM
                    , Valor_Pago__c // LECVP-344 - INICIO
                    , Saldo_da_reserva__c // LECVP-344 - FIM
                    FROM Case
            WHERE Id IN :Ids
          ];  
    }
    //PLV-4938 - FIM - PEDRO AUGUSTO BRAZ
     
    //contrato > remuneração >
   
    public Map<Id,FavorecidoRemuneracaoContrato__c> buscarCorretores(Set<Id> psContratoId) {

        Map<Id, FavorecidoRemuneracaoContrato__c> mFavRemunCont = new Map<Id, FavorecidoRemuneracaoContrato__c>();

        /* retirado por solicitação de mudança
         * for (RemuneracaoContrato__c remCont : [SELECT Id, Contrato__c, Conta__r.Email__c, DadosCorretor__r.Name, DadosCorretor__r.NomeCorretor__r.Name
                                                 FROM RemuneracaoContrato__c
                                                WHERE Lider__c = true
                                                  AND Contrato__c IN :psContratoId
                                                  AND TipoRemuneracao__r.Name = 'Corretagem']) {*/

        List<FavorecidoRemuneracaoContrato__c> favorecidos = [SELECT Id, RemuneracaoContrato__r.Contrato__c, DadosCorretor__r.Name, DadosCorretor__r.NomeCorretor__r.Email__c, DadosCorretor__r.NomeCorretor__r.PersonEmail, DadosCorretor__r.NomeCorretor__r.Name 
                                                              FROM FavorecidoRemuneracaoContrato__c 
                                                              // WHERE RemuneracaoContrato__r.TipoRemuneracao__r.Name = 'Corretagem' 
                                                              // AND CorretorLider__c = true 
                                                              // AND RemuneracaoContrato__r.Contrato__c IN :psContratoId
                                                              ];

        System.debug('XXX - FAVORECIDO: ' + JSON.serialize(favorecidos));
                                                  
    for (FavorecidoRemuneracaoContrato__c favRemCont : [SELECT Id, RemuneracaoContrato__r.Contrato__c, DadosCorretor__r.Name, DadosCorretor__r.NomeCorretor__r.Email__c, DadosCorretor__r.NomeCorretor__r.PersonEmail, DadosCorretor__r.NomeCorretor__r.Name 
                                          FROM FavorecidoRemuneracaoContrato__c 
                                          WHERE RemuneracaoContrato__r.TipoRemuneracao__r.Name = 'Corretagem' 
                                          AND CorretorLider__c = true 
                                          AND RemuneracaoContrato__r.Contrato__c IN :psContratoId]) {
                                                      
            mFavRemunCont.put(favRemCont.RemuneracaoContrato__r.Contrato__c, favRemCont);
        }

        return mFavRemunCont;
    }

    public Map<Id,Case> buscarCasosDaConta(Set<Id> psContaId){

      Map<Id,Case> mCases = new Map<Id,Case>();

      for(Case casosConta : [SELECT Id, CaseNumber, AccountId, Vitima__c, Dataocorrencia__c, RecordTypeId 
                            FROM Case 
                            WHERE AccountId IN :psContaId
                            AND Vitima__c != 'Filhos']){

        mCases.put(casosConta.Id, casosConta);
      }

      return mCases;
    }

    //Método alterado para a história PLV-1722
    public Map<Id, GarantiaSeguradoContrato__c> buscarContratos(Set<Id> psCasoId)
    {
        Map<Id, GarantiaSeguradoContrato__c> mSeguradoContrato = new Map<Id, GarantiaSeguradoContrato__c>(
            [SELECT SeguradoContrato__r.GrupoContrato__r.ContratanteContrato__r.Contrato__c, Garantia__c,SeguradoContrato__c, SeguradoContrato__r.Conta__r.Name
               FROM GarantiaSeguradoContrato__c
              WHERE Id IN :psCasoId]
        );
       
        return mSeguradoContrato;
    }

    //LECVP-317 - INICIO
    public List<PagamentoGarantia__c> buscarPgtoGarCasoSinCobCodRamo(Set<Id> casosId, String cobertura, String codigoRamo){
      List<PagamentoGarantia__c> pgtoGarantia = [
              SELECT 
                Id,
                Garantia_do_segurado_do_contrato__r.Garantia__r.Sigla__c,
                Caso__c,
                Caso__r.Type,
                Caso__r.Contrato__r.CodigoRamo__c,
                Caso__r.Contrato__r.TipoViagem__c 
              FROM
                PagamentoGarantia__c 
              WHERE
                Garantia_do_segurado_do_contrato__r.Garantia__r.Sigla__c = :cobertura 
              AND
                Caso__r.Contrato__r.CodigoRamo__c = :codigoRamo 
              AND
                Caso__c IN :casosId
              AND
                Caso__r.Type ='Sinistro'
            ];

            return pgtoGarantia;
    }
    //LECVP-317 - FIM  
}