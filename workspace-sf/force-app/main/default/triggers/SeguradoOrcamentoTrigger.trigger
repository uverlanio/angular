trigger SeguradoOrcamentoTrigger on SeguradoOrcamento__c (after insert, after update, before delete) {
    List<SeguradoOrcamento_Event__e> SeguradoOrcamentoEvents = New List<SeguradoOrcamento_Event__e>();
    String operation;
    if(Trigger.IsInsert || Trigger.IsUpdate){
        for(SeguradoOrcamento__c c:Trigger.new){        
            if(Trigger.IsInsert){operation = 'created';}        
            if(Trigger.IsUpdate){operation = 'updated';}
            SeguradoOrcamentoEvents.add(new SeguradoOrcamento_Event__e(
                Afastado__c                            = c.Afastado__c,
                CID__c                                 = c.CID__c,
                Conta__c                               = c.Conta__c,
                CPF__c                                 = c.CPF__c,
                DataNascimento__c                      = c.DataNascimento__c,
                DescontoAgravoMonetarioComercial__c    = c.DescontoAgravoMonetarioComercial__c,
                DescontoAgravoMonetarioInformado__c    = c.DescontoAgravoMonetarioInformado__c,
                DescontoAgravoMonetarioTecnico__c      = c.DescontoAgravoMonetarioTecnico__c,
                DescontoAgravoPercentualComercial__c   = c.DescontoAgravoPercentualComercial__c,
                DescontoAgravoPercentualInformado__c   = c.DescontoAgravoPercentualInformado__c,
                DescontoAgravoPercentualTecnico__c     = c.DescontoAgravoPercentualTecnico__c,
                EnderecoBoleto__c                      = c.EnderecoBoleto__c,
                GrupoOrcamento__c                      = c.GrupoOrcamento__c,
                Id__c                                  = c.Id,
                IOF__c                                 = c.IOF__c,
                IPCA__c                                = c.IPCA__c,
                Name__c                                = c.Name,
                Numero__c                              = c.Numero__c,
                PorcentagemParticipacaoSegurado__c     = c.PorcentagemParticipacaoSegurado__c,
                PorcentagemParticipacaoVida__c         = c.PorcentagemParticipacaoVida__c,
                PremioComercial__c                     = c.PremioComercial__c,
                PremioParcela__c                       = c.PremioParcela__c,
                PremioPuro__c                          = c.PremioPuro__c,
                PremioTotal__c                         = c.PremioTotal__c,
                QuantidadeParcelas__c                  = c.QuantidadeParcelas__c,
                Reenquadramento__c                     = c.Reenquadramento__c,
                TaxaComercial__c                       = c.TaxaComercial__c,
                TaxaPura__c                            = c.TaxaPura__c,
                TaxaTotal__c                           = c.TaxaTotal__c,
                TipoCusteio__c                         = c.TipoCusteio__c,
                TipoDescontoAgravo__c                  = c.TipoDescontoAgravo__c,
                TipoResponsavelPagamento__c            = c.TipoResponsavelPagamento__c,
                VencimentoPrimeiraParcela__c           = c.VencimentoPrimeiraParcela__c,
                Operation__c                           = operation
            ));
        }
    } else if(Trigger.IsDelete){
        for(SeguradoOrcamento__c c:Trigger.old){
            SeguradoOrcamentoEvents.add(new SeguradoOrcamento_Event__e(
                Afastado__c                            = c.Afastado__c,
                CID__c                                 = c.CID__c,
                Conta__c                               = c.Conta__c,
                CPF__c                                 = c.CPF__c,
                DataNascimento__c                      = c.DataNascimento__c,
                DescontoAgravoMonetarioComercial__c    = c.DescontoAgravoMonetarioComercial__c,
                DescontoAgravoMonetarioInformado__c    = c.DescontoAgravoMonetarioInformado__c,
                DescontoAgravoMonetarioTecnico__c      = c.DescontoAgravoMonetarioTecnico__c,
                DescontoAgravoPercentualComercial__c   = c.DescontoAgravoPercentualComercial__c,
                DescontoAgravoPercentualInformado__c   = c.DescontoAgravoPercentualInformado__c,
                DescontoAgravoPercentualTecnico__c     = c.DescontoAgravoPercentualTecnico__c,
                EnderecoBoleto__c                      = c.EnderecoBoleto__c,
                GrupoOrcamento__c                      = c.GrupoOrcamento__c,
                Id__c                                  = c.Id,
                IOF__c                                 = c.IOF__c,
                IPCA__c                                = c.IPCA__c,
                Name__c                                = c.Name,
                Numero__c                              = c.Numero__c,
                PorcentagemParticipacaoSegurado__c     = c.PorcentagemParticipacaoSegurado__c,
                PorcentagemParticipacaoVida__c         = c.PorcentagemParticipacaoVida__c,
                PremioComercial__c                     = c.PremioComercial__c,
                PremioParcela__c                       = c.PremioParcela__c,
                PremioPuro__c                          = c.PremioPuro__c,
                PremioTotal__c                         = c.PremioTotal__c,
                QuantidadeParcelas__c                  = c.QuantidadeParcelas__c,
                Reenquadramento__c                     = c.Reenquadramento__c,
                TaxaComercial__c                       = c.TaxaComercial__c,
                TaxaPura__c                            = c.TaxaPura__c,
                TaxaTotal__c                           = c.TaxaTotal__c,
                TipoCusteio__c                         = c.TipoCusteio__c,
                TipoDescontoAgravo__c                  = c.TipoDescontoAgravo__c,
                TipoResponsavelPagamento__c            = c.TipoResponsavelPagamento__c,
                VencimentoPrimeiraParcela__c           = c.VencimentoPrimeiraParcela__c,
                Operation__c                           = 'deleted'
            ));
    	}
    }
    if(SeguradoOrcamentoEvents.size() > 0 ) EventBus.publish(SeguradoOrcamentoEvents);
}