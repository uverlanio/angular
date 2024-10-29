/**
* GarantiaF acade
* @author Eric Tunú @ 18/09/2018
*
**/
public class GarantiaFacade 
{
    private static final GarantiaFacade classInstance;
    static { classInstance = new GarantiaFacade(); }
    private GarantiaFacade() {}
    public static GarantiaFacade getInstance() { return classInstance; }

    public List<garantiaSeguradoOrcamento__c> parceGarantiasSeguradoOrcamento(List<EmissaoTO.CoberturaTO> coberturas, Product2 produto, Id idSeguradoOrcamento, String chaveCoberturasCalculo, Map<String, EmissaoTO.CoberturaTO> mapCoberturasCalculo)
    {
        List<garantiaSeguradoOrcamento__c>      lstGarantias         = new List<garantiaSeguradoOrcamento__c>();
        Map<String, EmissaoTO.CoberturaTO>      mapCoberturas        = new Map<String, EmissaoTO.CoberturaTO>();
        Map<String, GarantiaOrcamento__c>       mapGaratiasOrcamento = new Map<String, GarantiaOrcamento__c>();

        for(EmissaoTO.CoberturaTO cobertura : coberturas)
            mapCoberturas.put(cobertura.sigla, cobertura);

        for(GarantiaProduto__c garantiaProduto : produto.GarantiasProduto__r)
        {
            String chave =  chaveCoberturasCalculo + garantiaProduto.Garantia__r.Sigla__c;

            EmissaoTO.CoberturaTO cobertura = mapCoberturas.get(garantiaProduto.Garantia__r.Sigla__c);

            if(cobertura == null)
                continue;

            GarantiaSeguradoOrcamento__c garantiaSeguradoOrc = new GarantiaSeguradoOrcamento__c();
            garantiaSeguradoOrc.SeguradoOrcamento__c    = idSeguradoOrcamento;
            garantiaSeguradoOrc.Garantia__c             = garantiaProduto.Garantia__c;
            garantiaSeguradoOrc.CurrencyIsoCode         = garantiaProduto.CurrencyIsoCode; //PLV-3884 - INICIO/FIM - Retornando o campo de moeda para referencia


            if(garantiaProduto.Obrigatoria__c == true)
            {
                if(garantiaProduto.TipoLimiteCapital__c == 'Monetário')
                {
                    if(cobertura.valor == null)
                    {
                        cobertura.importancia   = 0;
                        cobertura.valor         = 0;
                        cobertura.capital       = 0;
                    }

                    if(garantiaProduto.LimiteCapitalMinimo__c == garantiaProduto.LimiteCapitalMaximo__c)
                        garantiaSeguradoOrc.Capital__c = garantiaProduto.LimiteCapitalMinimo__c;
                    else
                    {
                        if(cobertura.valor > garantiaProduto.LimiteCapitalMaximo__c)
                            garantiaSeguradoOrc.Capital__c = garantiaProduto.LimiteCapitalMaximo__c;
                        else if(cobertura.valor < garantiaProduto.LimiteCapitalMinimo__c)
                            garantiaSeguradoOrc.Capital__c = garantiaProduto.LimiteCapitalMinimo__c;
                        else
                            garantiaSeguradoOrc.Capital__c = cobertura.valor;
                    }
                }
            }
            else
                garantiaSeguradoOrc.Capital__c = cobertura.valor;

            if(cobertura.valor != null)
                garantiaSeguradoOrc.Capital__c = cobertura.valor;

            if(cobertura.numeroSerie != null)
                garantiaSeguradoOrc.NumeroSerie__c = cobertura.numeroSerie;

            if(cobertura.numeroSorte != null)
                garantiaSeguradoOrc.NumeroSorte__c = StringHelper.FormatNumeroSorte(cobertura.numeroSorte); //Inicio/Fim - ST-2021-00012
            
            // Recupera a garantia do calculo
            EmissaoTO.CoberturaTO coberturaCalculoTO = mapCoberturasCalculo.get(chave);
            if(coberturaCalculoTO != null)
            {
                // pega os premios e taxas do calculo
                garantiaSeguradoOrc.PremioPuro__c       = coberturaCalculoTO.premio.puro;
                garantiaSeguradoOrc.PremioComercial__c  = coberturaCalculoTO.premio.comercial;
                garantiaSeguradoOrc.PremioTotal__c      = coberturaCalculoTO.premio.total;
                garantiaSeguradoOrc.TaxaPura__c         = coberturaCalculoTO.taxa.pura;
                garantiaSeguradoOrc.TaxaComercial__c    = coberturaCalculoTO.taxa.comercial;
                garantiaSeguradoOrc.TaxaTotal__c        = coberturaCalculoTO.taxa.total;
                garantiaSeguradoOrc.IOF__c              = coberturaCalculoTO.iof!=null ? coberturaCalculoTO.iof : 0;//PLV-4689 - INICIO/FIM - PEDRO AUGUSTO BRAZ - SYS4B

                if(coberturaCalculoTO.descontoAgravo != null)
                {
                  if(coberturaCalculoTO.descontoAgravo[0].tipo == 'TEC')
                  {
                    garantiaSeguradoOrc.DescontoAgravoPercentualTecnico__c = coberturaCalculoTO.descontoAgravo[0].percentual;
                    garantiaSeguradoOrc.DescontoAgravoMonetarioTecnico__c  = coberturaCalculoTO.descontoAgravo[0].monetario;
                  }
                  else if(coberturaCalculoTO.descontoAgravo[0].tipo == 'COM')
                  {
                    garantiaSeguradoOrc.DescontoAgravoPercentualComercial__c = coberturaCalculoTO.descontoAgravo[0].percentual;
                    garantiaSeguradoOrc.DescontoAgravoMonetarioComercial__c  = coberturaCalculoTO.descontoAgravo[0].monetario;
                  }
                  else if(coberturaCalculoTO.descontoAgravo[0].tipo == 'BAT')
                  {
                    garantiaSeguradoOrc.DescontoAgravoPercentualInformado__c = coberturaCalculoTO.descontoAgravo[0].percentual;
                    garantiaSeguradoOrc.DescontoAgravoMonetarioInformado__c  = coberturaCalculoTO.descontoAgravo[0].monetario;
                  }

                  // calculo de desconto agravo premio e taxa total
                  if(coberturaCalculoTO.descontoAgravo[0].monetario != null)
                    garantiaSeguradoOrc.PremioTotal__c = garantiaSeguradoOrc.PremioTotal__c + coberturaCalculoTO.descontoAgravo[0].monetario;
                  if(coberturaCalculoTO.descontoAgravo[0].percentual != null)
                    garantiaSeguradoOrc.TaxaTotal__c   = garantiaSeguradoOrc.TaxaTotal__c * (1 + coberturaCalculoTO.descontoAgravo[0].percentual / 100);
                }
            }

            garantiaSeguradoOrc.GarantiaProduto__c  = garantiaProduto.Id;
            garantiaSeguradoOrc.Valor__c            = garantiaSeguradoOrc.Capital__c;

            lstGarantias.Add(garantiaSeguradoOrc);
        }

        return lstGarantias;
    }

    public List<GarantiaGrupoOrcamento__c> parceGarantiasGrupoOrcamento(List<garantiaSeguradoOrcamento__c> lstGarantiasSegurado, Product2 produto, Id idGrupoOrcamento, String chaveCoberturasCalculo, Map<String, EmissaoTO.CoberturaTO> mapCoberturasCalculo)
    {
        List<GarantiaGrupoOrcamento__c> lstGarantias     = new List<GarantiaGrupoOrcamento__c>();
        Map<String, GarantiaProduto__c> mapGarantiasProd = new Map<String, GarantiaProduto__c>();

        for(GarantiaProduto__c garantiaProduto : produto.GarantiasProduto__r)
        {
            if(!mapGarantiasProd.containsKey(garantiaProduto.Garantia__c))
                mapGarantiasProd.put(garantiaProduto.Garantia__c, garantiaProduto);
        }
        Set<Id> setDuplicadas = new Set<Id>();
        for(garantiaSeguradoOrcamento__c garantiaSeg : lstGarantiasSegurado)
        {
            if(!setDuplicadas.contains(garantiaSeg.Garantia__c))
            {
                GarantiaProduto__c garantiaProd = mapGarantiasProd.get(garantiaSeg.Garantia__c);
                String chave =  chaveCoberturasCalculo + garantiaProd.Garantia__r.Sigla__c;

                GarantiaGrupoOrcamento__c garantiaGrupoOrc = new GarantiaGrupoOrcamento__c();
                
                garantiaGrupoOrc.Garantia__c        = garantiaSeg.Garantia__c;
                garantiaGrupoOrc.GrupoOrcamento__c  = idGrupoOrcamento;
                garantiaGrupoOrc.Capital__c         = garantiaSeg.Capital__c;
                garantiaGrupoOrc.NumeroSerie__c     = garantiaSeg.NumeroSerie__c;
                //Inicio - ST-2021-00012
                if(garantiaSeg.NumeroSorte__c != null){
                  garantiaGrupoOrc.NumeroSorte__c     = StringHelper.FormatNumeroSorte(garantiaSeg.NumeroSorte__c);
                }else{
                  garantiaGrupoOrc.NumeroSorte__c     = garantiaSeg.NumeroSorte__c;
                }
                //Fim - ST-2021-00012
                garantiaGrupoOrc.GarantiaProduto__c = garantiaProd.Id;
                garantiaGrupoOrc.Valor__c           = garantiaSeg.Capital__c;
                garantiaGrupoOrc.CurrencyIsoCode    = garantiaProd.CurrencyIsoCode; //PLV-3884 - INICIO/FIM - Retornando o campo de moeda para referencia

                // Recupera a garantia do calculo
                EmissaoTO.CoberturaTO coberturaCalculoTO = mapCoberturasCalculo.get(chave);
                if(coberturaCalculoTO != null)
                {
                    // pega os premios e taxas do calculo
                    garantiaGrupoOrc.PremioPuro__c      = coberturaCalculoTO.premio.puro;
                    garantiaGrupoOrc.PremioComercial__c = coberturaCalculoTO.premio.comercial;
                    garantiaGrupoOrc.PremioTotal__c     = coberturaCalculoTO.premio.total;
                    garantiaGrupoOrc.TaxaPura__c        = coberturaCalculoTO.taxa.pura;
                    garantiaGrupoOrc.TaxaComercial__c   = coberturaCalculoTO.taxa.comercial;
                    garantiaGrupoOrc.TaxaTotal__c       = coberturaCalculoTO.taxa.total;
                    garantiaGrupoOrc.IOF__c             = coberturaCalculoTO.iof!=null ? coberturaCalculoTO.iof : 0;//PLV-4689 - INICIO/FIM - PEDRO AUGUSTO BRAZ - SYS4B

                    if(coberturaCalculoTO.descontoAgravo != null)
                    {
                      if(coberturaCalculoTO.descontoAgravo[0].tipo == 'TEC')
                      {
                        garantiaGrupoOrc.DescontoAgravoPercentualTecnico__c = coberturaCalculoTO.descontoAgravo[0].percentual;
                        garantiaGrupoOrc.DescontoAgravoMonetarioTecnico__c  = coberturaCalculoTO.descontoAgravo[0].monetario;
                      }
                      else if(coberturaCalculoTO.descontoAgravo[0].tipo == 'COM')
                      {
                        garantiaGrupoOrc.DescontoAgravoPercentualComercial__c = coberturaCalculoTO.descontoAgravo[0].percentual;
                        garantiaGrupoOrc.DescontoAgravoMonetarioComercial__c  = coberturaCalculoTO.descontoAgravo[0].monetario;
                      }
                      else if(coberturaCalculoTO.descontoAgravo[0].tipo == 'BAT')
                      {
                        garantiaGrupoOrc.DescontoAgravoPercentualInformado__c = coberturaCalculoTO.descontoAgravo[0].percentual;
                        garantiaGrupoOrc.DescontoAgravoMonetarioInformado__c  = coberturaCalculoTO.descontoAgravo[0].monetario;
                      }

                      // calculo de desconto agravo premio e taxa total
                      if(coberturaCalculoTO.descontoAgravo[0].monetario != null)
                        garantiaGrupoOrc.PremioTotal__c = garantiaGrupoOrc.PremioTotal__c + coberturaCalculoTO.descontoAgravo[0].monetario;
                      if(coberturaCalculoTO.descontoAgravo[0].percentual != null)
                        garantiaGrupoOrc.TaxaTotal__c   = garantiaGrupoOrc.TaxaTotal__c * (1 + coberturaCalculoTO.descontoAgravo[0].percentual / 100);
                    }
                }

                lstGarantias.Add(garantiaGrupoOrc);
                setDuplicadas.Add(garantiaSeg.Garantia__c);
            }
        }

        return lstGarantias;
    }

    public List<GarantiaContratanteOrcamento__c> parceGarantiasContratanteOrcamento(List<GarantiaGrupoOrcamento__c> lstGarantiasGrupo, Product2 produto, Id idContratanteOrcamento, String chaveCoberturasCalculo, Map<String, EmissaoTO.CoberturaTO> mapCoberturasCalculo)
    {
        List<GarantiaContratanteOrcamento__c>   lstGarantias     = new List<GarantiaContratanteOrcamento__c>();
        Map<String, GarantiaProduto__c>         mapGarantiasProd = new Map<String, GarantiaProduto__c>();

        for(GarantiaProduto__c garantiaProduto : produto.GarantiasProduto__r)
        {
            if(!mapGarantiasProd.containsKey(garantiaProduto.Garantia__c))
                mapGarantiasProd.put(garantiaProduto.Garantia__c, garantiaProduto);
        }

        Set<Id> setDuplicadas = new Set<Id>();
        for(GarantiaGrupoOrcamento__c garantiaGrupo : lstGarantiasGrupo)
        {
            if(!setDuplicadas.contains(garantiaGrupo.Garantia__c))
            {
                GarantiaProduto__c garantiaProd = mapGarantiasProd.get(garantiaGrupo.Garantia__c);
                String chave =  chaveCoberturasCalculo + garantiaProd.Garantia__r.Sigla__c;

                GarantiaContratanteOrcamento__c garantiaContratanteOrc = new GarantiaContratanteOrcamento__c();
            
                garantiaContratanteOrc.Garantia__c              = garantiaGrupo.Garantia__c;
                garantiaContratanteOrc.ContratanteOrcamento__c  = idContratanteOrcamento;
                garantiaContratanteOrc.Capital__c               = garantiaGrupo.Capital__c;
                garantiaContratanteOrc.NumeroSerie__c           = garantiaGrupo.NumeroSerie__c;
                //Inicio - ST-2021-00012
                if(garantiaGrupo.NumeroSorte__c != null){
                  garantiaContratanteOrc.NumeroSorte__c           = StringHelper.FormatNumeroSorte(garantiaGrupo.NumeroSorte__c);
                }else{
                  garantiaContratanteOrc.NumeroSorte__c           = garantiaGrupo.NumeroSorte__c;
                }
                //Fim - ST-2021-00012
                garantiaContratanteOrc.GarantiaProduto__c       = garantiaProd.Id;
                garantiaContratanteOrc.Valor__c                 = garantiaGrupo.Capital__c;
                garantiaContratanteOrc.CurrencyIsoCode          = garantiaProd.CurrencyIsoCode; //PLV-3884 - INICIO/FIM - Retornando o campo de moeda para referencia

                // Recupera a garantia do calculo
                EmissaoTO.CoberturaTO coberturaCalculoTO = mapCoberturasCalculo.get(chave);
                if(coberturaCalculoTO != null)
                {
                    // pega os premios e taxas do calculo
                    garantiaContratanteOrc.PremioPuro__c      = coberturaCalculoTO.premio.puro; 
                    garantiaContratanteOrc.PremioComercial__c = coberturaCalculoTO.premio.comercial;
                    garantiaContratanteOrc.PremioTotal__c     = coberturaCalculoTO.premio.total;
                    garantiaContratanteOrc.TaxaPura__c        = coberturaCalculoTO.taxa.pura;
                    garantiaContratanteOrc.TaxaComercial__c   = coberturaCalculoTO.taxa.comercial;
                    garantiaContratanteOrc.TaxaTotal__c       = coberturaCalculoTO.taxa.total;
                    garantiaContratanteOrc.IOF__c             = coberturaCalculoTO.iof!=null ? coberturaCalculoTO.iof : 0;//PLV-4689 - INICIO/FIM - PEDRO AUGUSTO BRAZ - SYS4B

                    if(coberturaCalculoTO.descontoAgravo != null)
                    {
                      if(coberturaCalculoTO.descontoAgravo[0].tipo == 'TEC')
                      {
                        garantiaContratanteOrc.DescontoAgravoPercentualTecnico__c = coberturaCalculoTO.descontoAgravo[0].percentual;
                        garantiaContratanteOrc.DescontoAgravoMonetarioTecnico__c  = coberturaCalculoTO.descontoAgravo[0].monetario;
                      }
                      else if(coberturaCalculoTO.descontoAgravo[0].tipo == 'COM')
                      {
                        garantiaContratanteOrc.DescontoAgravoPercentualComercial__c = coberturaCalculoTO.descontoAgravo[0].percentual;
                        garantiaContratanteOrc.DescontoAgravoMonetarioComercial__c  = coberturaCalculoTO.descontoAgravo[0].monetario;
                      }
                      else if(coberturaCalculoTO.descontoAgravo[0].tipo == 'BAT')
                      {
                        garantiaContratanteOrc.DescontoAgravoPercentualInformado__c = coberturaCalculoTO.descontoAgravo[0].percentual;
                        garantiaContratanteOrc.DescontoAgravoMonetarioInformado__c  = coberturaCalculoTO.descontoAgravo[0].monetario;
                      }

                      // calculo de desconto agravo premio e taxa total
                      if(coberturaCalculoTO.descontoAgravo[0].monetario != null)
                        garantiaContratanteOrc.PremioTotal__c = garantiaContratanteOrc.PremioTotal__c + coberturaCalculoTO.descontoAgravo[0].monetario;
                      if(coberturaCalculoTO.descontoAgravo[0].percentual != null)
                        garantiaContratanteOrc.TaxaTotal__c   = garantiaContratanteOrc.TaxaTotal__c * (1 + coberturaCalculoTO.descontoAgravo[0].percentual / 100);
                    }
                }

                lstGarantias.Add(garantiaContratanteOrc);
                setDuplicadas.Add(garantiaGrupo.Garantia__c);
            }
        }
        System.debug('Danilo GarantiaFacade' + lstGarantias);
        return lstGarantias;
    }

    public List<GarantiaOrcamento__c> parceGarantiasOrcamento(List<GarantiaContratanteOrcamento__c> lstGarantiaContratante, Product2 produto, Id idOrcamento, String chaveCoberturasCalculo, Map<String, EmissaoTO.CoberturaTO> mapCoberturasCalculo)
    {
        List<GarantiaOrcamento__c>      lstGarantias     = new List<GarantiaOrcamento__c>();
        Map<String, GarantiaProduto__c> mapGarantiasProd = new Map<String, GarantiaProduto__c>();

        for(GarantiaProduto__c garantiaProduto : produto.GarantiasProduto__r)
        {
            if(!mapGarantiasProd.containsKey(garantiaProduto.Garantia__c))
                mapGarantiasProd.put(garantiaProduto.Garantia__c, garantiaProduto);
        }

        Set<Id> setDuplicadas = new Set<Id>();
        for(GarantiaContratanteOrcamento__c garantiaContratante : lstGarantiaContratante){
            if(!setDuplicadas.contains(garantiaContratante.Garantia__c)){
                GarantiaProduto__c garantiaProd = mapGarantiasProd.get(garantiaContratante.Garantia__c);
                String chave =  chaveCoberturasCalculo + garantiaProd.Garantia__r.Sigla__c;

                GarantiaOrcamento__c garantiaOrc = new GarantiaOrcamento__c();

                garantiaOrc.Garantia__c         = garantiaContratante.Garantia__c;
                garantiaOrc.Orcamento__c        = idOrcamento;
                garantiaOrc.Capital__c          = garantiaContratante.Capital__c;
                garantiaOrc.NumeroSerie__c      = garantiaContratante.NumeroSerie__c;
                 //Inicio - ST-2021-00012
                if(garantiaContratante.NumeroSorte__c != null){
                  garantiaOrc.NumeroSorte__c      = StringHelper.FormatNumeroSorte(garantiaContratante.NumeroSorte__c);
                }else{
                  garantiaOrc.NumeroSorte__c      = garantiaContratante.NumeroSorte__c;
                }
                //Fim - ST-2021-00012
                garantiaOrc.GarantiaProduto__c  = garantiaProd.Id;
                garantiaOrc.CurrencyIsoCode     = garantiaProd.CurrencyIsoCode; //PLV-3884 - INICIO/FIM - Retornando o campo de moeda para referencia

                // Recupera a garantia do calculo
                EmissaoTO.CoberturaTO coberturaCalculoTO = mapCoberturasCalculo.get(chave);
                if(coberturaCalculoTO != null){
                    // pega os premios e taxas do calculo
                    garantiaOrc.PremioPuro__c      = coberturaCalculoTO.premio.puro;
                    garantiaOrc.PremioComercial__c = coberturaCalculoTO.premio.comercial;
                    garantiaOrc.PremioTotal__c     = coberturaCalculoTO.premio.total;
                    garantiaOrc.TaxaPura__c        = coberturaCalculoTO.taxa.pura;
                    garantiaOrc.TaxaComercial__c   = coberturaCalculoTO.taxa.comercial;
                    garantiaOrc.TaxaTotal__c       = coberturaCalculoTO.taxa.total;
                    garantiaOrc.IOF__c             = coberturaCalculoTO.iof!=null ? coberturaCalculoTO.iof : 0;//PLV-4689 - INICIO/FIM - PEDRO AUGUSTO BRAZ - SYS4B

                    if(coberturaCalculoTO.descontoAgravo != null)
                    {
                      if(coberturaCalculoTO.descontoAgravo[0].tipo == 'TEC')
                      {
                        garantiaOrc.DescontoAgravoPercentualTecnico__c = coberturaCalculoTO.descontoAgravo[0].percentual;
                        garantiaOrc.DescontoAgravoMonetarioTecnico__c  = coberturaCalculoTO.descontoAgravo[0].monetario;
                      }
                      else if(coberturaCalculoTO.descontoAgravo[0].tipo == 'COM')
                      {
                        garantiaOrc.DescontoAgravoPercentualComercial__c = coberturaCalculoTO.descontoAgravo[0].percentual;
                        garantiaOrc.DescontoAgravoMonetarioComercial__c  = coberturaCalculoTO.descontoAgravo[0].monetario;
                      }
                      else if(coberturaCalculoTO.descontoAgravo[0].tipo == 'BAT')
                      {
                        garantiaOrc.DescontoAgravoPercentualInformado__c = coberturaCalculoTO.descontoAgravo[0].percentual;
                        garantiaOrc.DescontoAgravoMonetarioInformado__c  = coberturaCalculoTO.descontoAgravo[0].monetario;
                      }

                      // calculo de desconto agravo premio e taxa total
                      if(coberturaCalculoTO.descontoAgravo[0].monetario != null)
                        garantiaOrc.PremioTotal__c = garantiaOrc.PremioTotal__c + coberturaCalculoTO.descontoAgravo[0].monetario;
                      if(coberturaCalculoTO.descontoAgravo[0].percentual != null)
                        garantiaOrc.TaxaTotal__c   = garantiaOrc.TaxaTotal__c * (1 + coberturaCalculoTO.descontoAgravo[0].percentual / 100);
                    }
                }

                lstGarantias.Add(garantiaOrc);
                setDuplicadas.Add(garantiaContratante.Garantia__c);
            }
        }

        return lstGarantias;
    }

    public List<garantiaSeguradoProposta__c> parceGarantiasSeguradoProposta(List<EmissaoTO.CoberturaTO> coberturas, Product2 produto, Id idSeguradoProposta, String chaveCoberturasCalculo, Map<String, EmissaoTO.CoberturaTO> mapCoberturasCalculo)
    {
        List<garantiaSeguradoProposta__c>      lstGarantias         = new List<garantiaSeguradoProposta__c>();
        Map<String, EmissaoTO.CoberturaTO>   mapCoberturas        = new Map<String, EmissaoTO.CoberturaTO>();
        Map<String, GarantiaProposta__c>       mapGaratiasProposta  = new Map<String, GarantiaProposta__c>();

        for(EmissaoTO.CoberturaTO cobertura : coberturas)
            mapCoberturas.put(cobertura.sigla, cobertura);

        for(GarantiaProduto__c garantiaProduto : produto.GarantiasProduto__r)
        {
            String chave =  chaveCoberturasCalculo + garantiaProduto.Garantia__r.Sigla__c;

            EmissaoTO.CoberturaTO cobertura = mapCoberturas.get(garantiaProduto.Garantia__r.Sigla__c);

            if(cobertura == null)
                continue;

            GarantiaSeguradoProposta__c garantiaSeguradoProp = new GarantiaSeguradoProposta__c();
            garantiaSeguradoProp.SeguradoProposta__c         = idSeguradoProposta;
            garantiaSeguradoProp.Garantia__c                 = garantiaProduto.Garantia__c;
            garantiaSeguradoProp.CurrencyIsoCode             = garantiaProduto.CurrencyIsoCode; //PLV-3884 - INICIO/FIM - Retornando o campo de moeda para referencia
            

            if(garantiaProduto.Obrigatoria__c == true)
            {
                if(garantiaProduto.TipoLimiteCapital__c == 'Monetário')
                {
                    if(cobertura.valor == null)
                    {
                        cobertura.importancia   = 0;
                        cobertura.valor         = 0;
                        cobertura.capital       = 0;
                    }

                    if(garantiaProduto.LimiteCapitalMinimo__c == garantiaProduto.LimiteCapitalMaximo__c)
                        garantiaSeguradoProp.Capital__c = garantiaProduto.LimiteCapitalMinimo__c;
                    else
                    {
                        if(cobertura.valor > garantiaProduto.LimiteCapitalMaximo__c)
                            garantiaSeguradoProp.Capital__c = garantiaProduto.LimiteCapitalMaximo__c;
                        else if(cobertura.valor < garantiaProduto.LimiteCapitalMinimo__c)
                            garantiaSeguradoProp.Capital__c = garantiaProduto.LimiteCapitalMinimo__c;
                        else
                            garantiaSeguradoProp.Capital__c = cobertura.valor;
                    }
                }
            }
            else
                garantiaSeguradoProp.Capital__c = cobertura.valor;

            if(cobertura.valor != null)
                garantiaSeguradoProp.Capital__c = cobertura.valor;

            if(cobertura.numeroSerie != null)
                garantiaSeguradoProp.NumeroSerie__c = cobertura.numeroSerie;
    
            //PLV-4620 FIX 2 INICIO
            //PLV-4620 FIX3 INICIO
            System.debug('cobertura.caracteristicaespecialvalor: ' + cobertura.caracteristicaespecialvalor);
            if(cobertura.caracteristicaespecialvalor != null){
                garantiaSeguradoProp.Limite_de_Uso__c         			= cobertura.caracteristicaespecialvalor;
                //PLV-4830 INICIO
                garantiaSeguradoProp.ValorDias__c         			= cobertura.caracteristicaespecialvalor;
                //PLV-4830 FIM
                System.debug('garantiaSeguradoProp.ValorDias__c: ' + garantiaSeguradoProp.ValorDias__c);
            }else{
                garantiaSeguradoProp.Limite_de_Uso__c = cobertura.valor;
            }
            System.debug('cobertura.caracteristicaespecialtipo: '+ cobertura.caracteristicaespecialtipo);
            if(cobertura.caracteristicaespecialtipo != null){
                String tipoCaracteristica = cobertura.caracteristicaespecialtipo == 'Dia(s)' ? 'Dias' : 'Anos';
                tipoCaracteristica = cobertura.caracteristicaespecialtipo != 'Dia(s)' && cobertura.caracteristicaespecialtipo != 'Ano(s)' ? 'Monetário' : tipoCaracteristica; //PLV 4620 FIX 4
                
                garantiaSeguradoProp.Tipo_de_limite_de_utilizacao__c = tipoCaracteristica;
                
                if(tipoCaracteristica == 'Monetário'){
                    garantiaSeguradoProp.Limite_de_Uso__c = cobertura.valor;
                }
                
            }else{
                garantiaSeguradoProp.Tipo_de_limite_de_utilizacao__c = 'Monetário';
            }
            
            //garantiaSeguradoProp.Tipo_de_limite_de_utilizacao__c = 'Dias';*/
            //PLV-4620 FIX3 FIM
            //PLV-4620 FIX 2 FIM

            if(cobertura.numeroSorte != null)
                garantiaSeguradoProp.NumeroSorte__c = StringHelper.FormatNumeroSorte(cobertura.numeroSorte); //Inicio/Fim - ST-2021-00012
            
            // Recupera a garantia do calculo
            EmissaoTO.CoberturaTO coberturaCalculoTO = mapCoberturasCalculo.get(chave);
            if(coberturaCalculoTO != null)
            {
                // pega os premios e taxas do calculo
                garantiaSeguradoProp.PremioPuro__c       = coberturaCalculoTO.premio.puro;
                garantiaSeguradoProp.PremioComercial__c  = coberturaCalculoTO.premio.comercial;
                garantiaSeguradoProp.PremioTotal__c      = coberturaCalculoTO.premio.total;
                garantiaSeguradoProp.TaxaPura__c         = coberturaCalculoTO.taxa.pura;
                garantiaSeguradoProp.TaxaComercial__c    = coberturaCalculoTO.taxa.comercial;
                garantiaSeguradoProp.TaxaTotal__c        = coberturaCalculoTO.taxa.total;
                garantiaSeguradoProp.IOF__c              = coberturaCalculoTO.iof!=null ? coberturaCalculoTO.iof : 0;//PLV-4689 - INICIO/FIM - PEDRO AUGUSTO BRAZ - SYS4B

                if(coberturaCalculoTO.descontoAgravo != null)
                {
                  if(coberturaCalculoTO.descontoAgravo[0].tipo == 'TEC')
                  {
                    garantiaSeguradoProp.DescontoAgravoPercentualTecnico__c = coberturaCalculoTO.descontoAgravo[0].percentual;
                    garantiaSeguradoProp.DescontoAgravoMonetarioTecnico__c  = coberturaCalculoTO.descontoAgravo[0].monetario;
                  }
                  else if(coberturaCalculoTO.descontoAgravo[0].tipo == 'COM')
                  {
                    garantiaSeguradoProp.DescontoAgravoPercentualComercial__c = coberturaCalculoTO.descontoAgravo[0].percentual;
                    garantiaSeguradoProp.DescontoAgravoMonetarioComercial__c  = coberturaCalculoTO.descontoAgravo[0].monetario;
                  }
                  else if(coberturaCalculoTO.descontoAgravo[0].tipo == 'BAT')
                  {
                    garantiaSeguradoProp.DescontoAgravoPercentualInformado__c = coberturaCalculoTO.descontoAgravo[0].percentual;
                    garantiaSeguradoProp.DescontoAgravoMonetarioInformado__c  = coberturaCalculoTO.descontoAgravo[0].monetario;
                  }

                  // calculo de desconto agravo premio e taxa total
                  if(coberturaCalculoTO.descontoAgravo[0].monetario != null)
                    garantiaSeguradoProp.PremioTotal__c = garantiaSeguradoProp.PremioTotal__c + coberturaCalculoTO.descontoAgravo[0].monetario;
                  if(coberturaCalculoTO.descontoAgravo[0].percentual != null)
                    garantiaSeguradoProp.TaxaTotal__c   = garantiaSeguradoProp.TaxaTotal__c * (1 + coberturaCalculoTO.descontoAgravo[0].percentual / 100);
                }
            }

            garantiaSeguradoProp.GarantiaProduto__c  = garantiaProduto.Id;
            garantiaSeguradoProp.Valor__c            = garantiaSeguradoProp.Capital__c;

            lstGarantias.Add(garantiaSeguradoProp);
        }

        return lstGarantias;
    }

    public List<GarantiasGrupoProposta__c> parceGarantiasGrupoProposta(List<garantiaSeguradoProposta__c> lstGarantiasSegurado, Product2 produto, Id idGrupoProposta, String chaveCoberturasCalculo, Map<String, EmissaoTO.CoberturaTO> mapCoberturasCalculo)
    {
        List<GarantiasGrupoProposta__c> lstGarantias     = new List<GarantiasGrupoProposta__c>();
        Map<String, GarantiaProduto__c> mapGarantiasProd = new Map<String, GarantiaProduto__c>();

        for(GarantiaProduto__c garantiaProduto : produto.GarantiasProduto__r)
        {
            if(!mapGarantiasProd.containsKey(garantiaProduto.Garantia__c))
                mapGarantiasProd.put(garantiaProduto.Garantia__c, garantiaProduto);
        }
        Set<Id> setDuplicadas = new Set<Id>();
        for(garantiaSeguradoProposta__c garantiaSeg : lstGarantiasSegurado)
        {
            if(!setDuplicadas.contains(garantiaSeg.Garantia__c))
            {
                GarantiaProduto__c garantiaProd = mapGarantiasProd.get(garantiaSeg.Garantia__c);
                String chave =  chaveCoberturasCalculo + garantiaProd.Garantia__r.Sigla__c;

                GarantiasGrupoProposta__c garantiaGrupoOrc = new GarantiasGrupoProposta__c();
                
                garantiaGrupoOrc.Garantia__c        = garantiaSeg.Garantia__c;
                garantiaGrupoOrc.GrupoProposta__c  = idGrupoProposta;
                garantiaGrupoOrc.Capital__c         = garantiaSeg.Capital__c;
                garantiaGrupoOrc.NumeroSerie__c     = garantiaSeg.NumeroSerie__c;
               //Inicio - ST-2021-00012
                if(garantiaSeg.NumeroSorte__c != null){
                  garantiaGrupoOrc.NumeroSorte__c     = StringHelper.FormatNumeroSorte(garantiaSeg.NumeroSorte__c);
                }else{
                  garantiaGrupoOrc.NumeroSorte__c      = garantiaSeg.NumeroSorte__c;
                }
                //Fim - ST-2021-00012
                garantiaGrupoOrc.GarantiaProduto__c = garantiaProd.Id;
                garantiaGrupoOrc.Valor__c           = garantiaSeg.Capital__c;
                garantiaGrupoOrc.CurrencyIsoCode    = garantiaProd.CurrencyIsoCode; //PLV-3884 - INICIO/FIM - Retornando o campo de moeda para referencia

                // Recupera a garantia do calculo
                EmissaoTO.CoberturaTO coberturaCalculoTO = mapCoberturasCalculo.get(chave);
                if(coberturaCalculoTO != null)
                {
                    // pega os premios e taxas do calculo
                    garantiaGrupoOrc.IOF__c             = coberturaCalculoTO.iof!=null ? coberturaCalculoTO.iof : 0;//PLV-4689 - INICIO/FIM - PEDRO AUGUSTO BRAZ - SYS4B
                    garantiaGrupoOrc.PremioPuro__c      = coberturaCalculoTO.premio.puro;
                    garantiaGrupoOrc.PremioComercial__c = coberturaCalculoTO.premio.comercial;
                    garantiaGrupoOrc.PremioTotal__c     = coberturaCalculoTO.premio.total;
                    garantiaGrupoOrc.TaxaPura__c        = coberturaCalculoTO.taxa.pura;
                    garantiaGrupoOrc.TaxaComercial__c   = coberturaCalculoTO.taxa.comercial;
                    garantiaGrupoOrc.TaxaTotal__c       = coberturaCalculoTO.taxa.total;

                    if(coberturaCalculoTO.descontoAgravo != null)
                    {
                      if(coberturaCalculoTO.descontoAgravo[0].tipo == 'TEC')
                      {
                        garantiaGrupoOrc.DescontoAgravoPercentualTecnico__c = coberturaCalculoTO.descontoAgravo[0].percentual;
                        garantiaGrupoOrc.DescontoAgravoMonetarioTecnico__c  = coberturaCalculoTO.descontoAgravo[0].monetario;
                      }
                      else if(coberturaCalculoTO.descontoAgravo[0].tipo == 'COM')
                      {
                        garantiaGrupoOrc.DescontoAgravoPercentualComercial__c = coberturaCalculoTO.descontoAgravo[0].percentual;
                        garantiaGrupoOrc.DescontoAgravoMonetarioComercial__c  = coberturaCalculoTO.descontoAgravo[0].monetario;
                      }
                      else if(coberturaCalculoTO.descontoAgravo[0].tipo == 'BAT')
                      {
                        garantiaGrupoOrc.DescontoAgravoPercentualInformado__c = coberturaCalculoTO.descontoAgravo[0].percentual;
                        garantiaGrupoOrc.DescontoAgravoMonetarioInformado__c  = coberturaCalculoTO.descontoAgravo[0].monetario;
                      }

                      // calculo de desconto agravo premio e taxa total
                      if(coberturaCalculoTO.descontoAgravo[0].monetario != null)
                        garantiaGrupoOrc.PremioTotal__c = garantiaGrupoOrc.PremioTotal__c + coberturaCalculoTO.descontoAgravo[0].monetario;
                      if(coberturaCalculoTO.descontoAgravo[0].percentual != null)
                        garantiaGrupoOrc.TaxaTotal__c   = garantiaGrupoOrc.TaxaTotal__c * (1 + coberturaCalculoTO.descontoAgravo[0].percentual / 100);
                    }
                }

                lstGarantias.Add(garantiaGrupoOrc);
                setDuplicadas.Add(garantiaSeg.Garantia__c);
            }
        }

        return lstGarantias;
    }

    public List<GarantiaContratanteProposta__c> parceGarantiasContratanteProposta(List<GarantiasGrupoProposta__c> lstGarantiasGrupo, Product2 produto, Id idContratanteProposta, String chaveCoberturasCalculo, Map<String, EmissaoTO.CoberturaTO> mapCoberturasCalculo)
    {
        List<GarantiaContratanteProposta__c>   lstGarantias     = new List<GarantiaContratanteProposta__c>();
        Map<String, GarantiaProduto__c>         mapGarantiasProd = new Map<String, GarantiaProduto__c>();

        for(GarantiaProduto__c garantiaProduto : produto.GarantiasProduto__r)
        {
            if(!mapGarantiasProd.containsKey(garantiaProduto.Garantia__c))
                mapGarantiasProd.put(garantiaProduto.Garantia__c, garantiaProduto);
        }

        Set<Id> setDuplicadas = new Set<Id>();
        for(GarantiasGrupoProposta__c garantiaGrupo : lstGarantiasGrupo)
        {
            if(!setDuplicadas.contains(garantiaGrupo.Garantia__c))
            {
                GarantiaProduto__c garantiaProd = mapGarantiasProd.get(garantiaGrupo.Garantia__c);
                String chave =  chaveCoberturasCalculo + garantiaProd.Garantia__r.Sigla__c;

                GarantiaContratanteProposta__c garantiaContratanteProp = new GarantiaContratanteProposta__c();
            
                garantiaContratanteProp.Garantia__c              = garantiaGrupo.Garantia__c;
                garantiaContratanteProp.ContratanteProposta__c   = idContratanteProposta;
                garantiaContratanteProp.Capital__c               = garantiaGrupo.Capital__c;
                garantiaContratanteProp.NumeroSerie__c           = garantiaGrupo.NumeroSerie__c;
				//Inicio - ST-2021-00012
                if(garantiaGrupo.NumeroSorte__c != null){
                  garantiaContratanteProp.NumeroSorte__c           = StringHelper.FormatNumeroSorte(garantiaGrupo.NumeroSorte__c);
                }else{
                  garantiaContratanteProp.NumeroSorte__c       = garantiaGrupo.NumeroSorte__c;
                }
                //Fim - ST-2021-00012 
                garantiaContratanteProp.GarantiaProduto__c       = garantiaProd.Id;
                garantiaContratanteProp.Valor__c                 = garantiaGrupo.Capital__c;
                garantiaContratanteProp.CurrencyIsoCode          = garantiaProd.CurrencyIsoCode; //PLV-3884 - INICIO/FIM - Retornando o campo de moeda para referencia

                // Recupera a garantia do calculo
                EmissaoTO.CoberturaTO coberturaCalculoTO = mapCoberturasCalculo.get(chave);
                if(coberturaCalculoTO != null)
                {
                    // pega os premios e taxas do calculo
                    garantiaContratanteProp.IOF__c             = coberturaCalculoTO.iof!=null ? coberturaCalculoTO.iof : 0;//PLV-4689 - INICIO/FIM - PEDRO AUGUSTO BRAZ - SYS4B
                    garantiaContratanteProp.PremioPuro__c      = coberturaCalculoTO.premio.puro;
                    garantiaContratanteProp.PremioComercial__c = coberturaCalculoTO.premio.comercial;
                    garantiaContratanteProp.PremioTotal__c     = coberturaCalculoTO.premio.total;
                    garantiaContratanteProp.TaxaPura__c        = coberturaCalculoTO.taxa.pura;
                    garantiaContratanteProp.TaxaComercial__c   = coberturaCalculoTO.taxa.comercial;
                    garantiaContratanteProp.TaxaTotal__c       = coberturaCalculoTO.taxa.total;

                    if(coberturaCalculoTO.descontoAgravo != null)
                    {
                      if(coberturaCalculoTO.descontoAgravo[0].tipo == 'TEC')
                      {
                        garantiaContratanteProp.DescontoAgravoPercentualTecnico__c = coberturaCalculoTO.descontoAgravo[0].percentual;
                        garantiaContratanteProp.DescontoAgravoMonetarioTecnico__c  = coberturaCalculoTO.descontoAgravo[0].monetario;
                      }
                      else if(coberturaCalculoTO.descontoAgravo[0].tipo == 'COM')
                      {
                        garantiaContratanteProp.DescontoAgravoPercentualComercial__c = coberturaCalculoTO.descontoAgravo[0].percentual;
                        garantiaContratanteProp.DescontoAgravoMonetarioComercial__c  = coberturaCalculoTO.descontoAgravo[0].monetario;
                      }
                      else if(coberturaCalculoTO.descontoAgravo[0].tipo == 'BAT')
                      {
                        garantiaContratanteProp.DescontoAgravoPercentualInformado__c = coberturaCalculoTO.descontoAgravo[0].percentual;
                        garantiaContratanteProp.DescontoAgravoMonetarioInformado__c  = coberturaCalculoTO.descontoAgravo[0].monetario;
                      }

                      // calculo de desconto agravo premio e taxa total
                      if(coberturaCalculoTO.descontoAgravo[0].monetario != null)
                        garantiaContratanteProp.PremioTotal__c = garantiaContratanteProp.PremioTotal__c + coberturaCalculoTO.descontoAgravo[0].monetario;
                      if(coberturaCalculoTO.descontoAgravo[0].percentual != null)
                        garantiaContratanteProp.TaxaTotal__c   = garantiaContratanteProp.TaxaTotal__c * (1 + coberturaCalculoTO.descontoAgravo[0].percentual / 100);
                    }
                }

                lstGarantias.Add(garantiaContratanteProp);
                setDuplicadas.Add(garantiaGrupo.Garantia__c);
            }
        }

        return lstGarantias;
    }

    public List<GarantiaProposta__c> parceGarantiasProposta(List<GarantiaContratanteProposta__c> lstGarantiaContratante, Product2 produto, Id idProposta, String chaveCoberturasCalculo, Map<String, EmissaoTO.CoberturaTO> mapCoberturasCalculo)
    {
        List<GarantiaProposta__c>      lstGarantias     = new List<GarantiaProposta__c>();
        Map<String, GarantiaProduto__c> mapGarantiasProd = new Map<String, GarantiaProduto__c>();

        for(GarantiaProduto__c garantiaProduto : produto.GarantiasProduto__r)
        {
            if(!mapGarantiasProd.containsKey(garantiaProduto.Garantia__c))
                mapGarantiasProd.put(garantiaProduto.Garantia__c, garantiaProduto);
        }

        Set<Id> setDuplicadas = new Set<Id>();
        for(GarantiaContratanteProposta__c garantiaContratante : lstGarantiaContratante)
        {
            if(!setDuplicadas.contains(garantiaContratante.Garantia__c))
            {
                GarantiaProduto__c garantiaProd = mapGarantiasProd.get(garantiaContratante.Garantia__c);
                String chave =  chaveCoberturasCalculo + garantiaProd.Garantia__r.Sigla__c;

                GarantiaProposta__c garantiaOrc = new GarantiaProposta__c();

                garantiaOrc.Proposta__c         = idProposta;
                garantiaOrc.Garantia__c         = garantiaContratante.Garantia__c;
                garantiaOrc.Capital__c          = garantiaContratante.Capital__c;
                garantiaOrc.GarantiaProduto__c  = garantiaProd.Id;

                // Recupera a garantia do calculo
                EmissaoTO.CoberturaTO coberturaCalculoTO = mapCoberturasCalculo.get(chave);
                if(coberturaCalculoTO != null)
                {
                    if(!String.isBlank(coberturaCalculoTO.dataSorteio))
                        garantiaOrc.DataSorteio__c = Date.valueOf(coberturaCalculoTO.dataSorteio);

                    if(!String.isBlank(coberturaCalculoTO.dataSolicitacao))
                        garantiaOrc.DataSolicitacaoCapitalizacao__c = Date.valueOf(coberturaCalculoTO.dataSolicitacao);

                    // pega os premios e taxas do calculo
                    garantiaOrc.IOF__c             = coberturaCalculoTO.iof!=null ? coberturaCalculoTO.iof : 0;//PLV-4689 - INICIO/FIM - PEDRO AUGUSTO BRAZ - SYS4B
                    garantiaOrc.PremioPuro__c      = coberturaCalculoTO.premio.puro;
                    garantiaOrc.PremioComercial__c = coberturaCalculoTO.premio.comercial;
                    garantiaOrc.PremioTotal__c     = coberturaCalculoTO.premio.total;
                    garantiaOrc.CurrencyIsoCode        = garantiaProd.CurrencyIsoCode; //PLV-3884 - INICIO/FIM - Retornando o campo de moeda para referencia
                    garantiaOrc.TaxaPura__c        = coberturaCalculoTO.taxa.pura;
                    garantiaOrc.TaxaComercial__c   = coberturaCalculoTO.taxa.comercial;
                    garantiaOrc.TaxaTotal__c       = coberturaCalculoTO.taxa.total;
                    garantiaOrc.LoteCapitalizacao__c = coberturaCalculoTO.loteCapitalizacao;
                    garantiaOrc.VersaoTitulo__c = coberturaCalculoTO.versaoCapitalizacao;
                    garantiaOrc.StatusCapitalizacao__c = coberturaCalculoTO.statusCapitalizacao;
                    garantiaOrc.NumeroTitulo__c  = coberturaCalculoTO.tituloCapitalizacao;
                    garantiaOrc.NumeroSerie__c = coberturaCalculoTO.numeroSerie;
                    //Inicio - ST-2021-00012
                    if(coberturaCalculoTO.numeroSorte != null){
                      garantiaOrc.NumeroSorte__c = StringHelper.FormatNumeroSorte(coberturaCalculoTO.numeroSorte);
                    }else{
                      garantiaOrc.NumeroSorte__c        = coberturaCalculoTO.numeroSorte;
                    }
                    //Fim - ST-2021-00012
                    
                    //PLV-4620 FIX 2 INICIO
                    String tipoCaracteristica = coberturaCalculoTO.caracteristicaespecialtipo == 'Dia(s)' ? 'Dias' : 'Anos';
                    tipoCaracteristica = coberturaCalculoTO.caracteristicaespecialtipo != 'Dia(s)' && coberturaCalculoTO.caracteristicaespecialtipo != 'Ano(s)' ? 'Monetário' : tipoCaracteristica; //PLV-4620 FIX4 INICIO/FIM
                
                    //PLV-4620 FIX3 INICIO
                    if(tipoCaracteristica == 'Monetário'){
                        garantiaOrc.Limite_de_Uso__c = coberturaCalculoTO.valor;
                    }else{
                    	garantiaOrc.Limite_de_Uso__c = coberturaCalculoTO.caracteristicaespecialvalor; 
                      //garantiaOrc.Tipo_de_limite_de_utilizacao__c    = 'Dias';   
                    }
                    //PLV-4620 FIX3 FIM

                    garantiaOrc.Tipo_de_limite_de_utilizacao__c    = tipoCaracteristica;
                    
                    //PLV-4620 FIX 2 FIM

                    if(coberturaCalculoTO.descontoAgravo != null)
                    {
                      if(coberturaCalculoTO.descontoAgravo[0].tipo == 'TEC')
                      {
                        garantiaOrc.DescontoAgravoPercentualTecnico__c = coberturaCalculoTO.descontoAgravo[0].percentual;
                        garantiaOrc.DescontoAgravoMonetarioTecnico__c  = coberturaCalculoTO.descontoAgravo[0].monetario;
                      }
                      else if(coberturaCalculoTO.descontoAgravo[0].tipo == 'COM')
                      {
                        garantiaOrc.DescontoAgravoPercentualComercial__c = coberturaCalculoTO.descontoAgravo[0].percentual;
                        garantiaOrc.DescontoAgravoMonetarioComercial__c  = coberturaCalculoTO.descontoAgravo[0].monetario;
                      }
                      else if(coberturaCalculoTO.descontoAgravo[0].tipo == 'BAT')
                      {
                        garantiaOrc.DescontoAgravoPercentualInformado__c = coberturaCalculoTO.descontoAgravo[0].percentual;
                        garantiaOrc.DescontoAgravoMonetarioInformado__c  = coberturaCalculoTO.descontoAgravo[0].monetario;
                      }

                      // calculo de desconto agravo premio e taxa total
                      if(coberturaCalculoTO.descontoAgravo[0].monetario != null)
                        garantiaOrc.PremioTotal__c = garantiaOrc.PremioTotal__c + coberturaCalculoTO.descontoAgravo[0].monetario;
                      if(coberturaCalculoTO.descontoAgravo[0].percentual != null)
                        garantiaOrc.TaxaTotal__c   = garantiaOrc.TaxaTotal__c * (1 + coberturaCalculoTO.descontoAgravo[0].percentual / 100);
                    }

                }

                lstGarantias.Add(garantiaOrc);
                setDuplicadas.Add(garantiaContratante.Garantia__c);
            }
        }

        return lstGarantias;
    }

    public class PropostaException extends Exception {}
}