public class BotaoAtualizacaoMonetariaController {
    
    //PLV-4892-INICIO-FIX07
    //PLV-4892-INICIO-FIX04
    //PLV-4892 - INICIO - REFACTOR DA FUNÇÃO - CÁLCULO MONETÁRIO/JUROS INCORRETO
    //PLV-4535 - INICIO
    @AuraEnabled
    public static string criaComplementoIndenizacao(String idBeneficiarioGarantia, Boolean substituir) {
        RetornoAcaoBotaoTO retorno = new RetornoAcaoBotaoTO();
        Decimal taxaJuros = 0.5 / 30;
        Decimal totalTaxa = 0;

        PagamentoGarantiaTriggerHandler.gerarMovimento = false;
        try {
            BeneficiarioGarantia__c beneficiario = [SELECT Id,ValorIndenizacao__c, valorComplementos__c, Pagamento_de_garantia__c, Data_programada_do_pagamento__c, Pagamento_de_garantia__r.Caso__c FROM BeneficiarioGarantia__c WHERE id =: idBeneficiarioGarantia ]; //PLV-4745 - INÍCIO/FIM
            PagamentoGarantia__c pg = [SELECT Id, Status_do_pagamento__c, Caso__c FROM PagamentoGarantia__c WHERE Id =: beneficiario.Pagamento_de_garantia__c ];
            List<CaseMilestone> prazoList = [SELECT Id, CaseId, StartDate, TargetDate, TimeRemainingInMins, TargetResponseInDays, MilestoneType.Name FROM CaseMilestone WHERE CaseId =: pg.Caso__c AND MilestoneType.Name = 'Prazo Susep' LIMIT 1];
            Case [] casoCalc = [SELECT Id, Dataocorrencia__c FROM Case WHERE Id =: pg.Caso__c];
            
            //PLV-4892-INICIO-FIX01
            if(beneficiario.ValorIndenizacao__c == null) {
                retorno.tipo = RetornoAcaoBotaoTO.ERROR;
                retorno.mensagens.add('O Campo Valor de Indenização não pode ser vazio!');
                return  JSON.serialize(retorno,true);
            } 
            //PLV-4892-FIM-FIX01
            //PLV-4892-INICIO-FIX05
            if(beneficiario.Data_programada_do_pagamento__c == null || beneficiario.Data_programada_do_pagamento__c < (Date.Today() + 2)){
                retorno.tipo = RetornoAcaoBotaoTO.ERROR;
                retorno.mensagens.add('A data programada deve ser maior ou igual dois dias da data atual.');
                return  JSON.serialize(retorno, true);
            }
            //PLV-4892-FIM-FIX05
            Datetime dataPagamento = beneficiario.Data_programada_do_pagamento__c;           
        
            if(pg.Status_do_pagamento__c == 'Pago'){
                retorno.tipo = RetornoAcaoBotaoTO.ERROR;
                retorno.mensagens.add('A garantia já foi paga.');
                return  JSON.serialize(retorno,true);
            } 
            
            CorrecaoMonetariaTO correcaoMonetaria = new CorrecaoMonetariaTO();
            Decimal diasAtrasoPrazo = 0;
            Decimal diasAtrasoRetroativo = 0;
                    
            if(!Test.isRunningTest()){
                
                if(prazoList.isEmpty()) {
                    retorno.tipo = RetornoAcaoBotaoTO.ERROR;
                    retorno.mensagens.add('O prazo Susep não existe.');
                    return  JSON.serialize(retorno,true);
                } 
    
                CaseMilestone prazoSusep = prazoList[0];
    
                if(prazoSusep.TimeRemainingInMins != '00:00'){
                    retorno.tipo = RetornoAcaoBotaoTO.ERROR;
                    retorno.mensagens.add('Prazo Susep ainda não completou 30 dias.');
                    return  JSON.serialize(retorno,true);
                }
  				
                //PLV-4892-INICIO-FIX05
                //PLV-4892-INICIO-FIX03     
                Case csDataOcorrencia = casoCalc[0];

                DateTime dataOcorrenciaInicio = csDataOcorrencia.Dataocorrencia__c.addDays(1);
                Datetime dataOcorrencia; 
                
                System.debug(prazoSusep.TargetDate.date());
                diasAtrasoPrazo = (prazoSusep.TargetDate.date()).daysBetween(Date.valueOf(dataPagamento));
                System.debug('diasAtrasoPrazo → ' + diasAtrasoPrazo);
                diasAtrasoRetroativo = diasAtrasoPrazo + prazoSusep.TargetResponseInDays;
                System.debug('diasAtrasoRetroativo → ' + diasAtrasoRetroativo);

                String dataOcorrenciaFormatada;
                System.debug('dataOcorrenciaFormatada → '+dataOcorrenciaFormatada);
                
                Integer d =  1; 
                Integer mo = dataOcorrenciaInicio.month();
                Integer yr = dataOcorrenciaInicio.year();
                DateTime dataOcorrenciaInicioNovaInstancia = DateTime.newInstance(yr, mo, d);

                dataOcorrencia = dataOcorrenciaInicioNovaInstancia;
                System.debug('dataOcorrencia → '+dataOcorrencia);
                
                //Data que inicia a Taxa IPCA
                dataOcorrenciaFormatada = String.valueOf(FormataData(dataOcorrencia.date()));
                correcaoMonetaria.dataInicioValidade = dataOcorrenciaFormatada;
                System.debug('correcaoMonetaria → ' + correcaoMonetaria);
                correcaoMonetaria.dataFinalValidade = String.valueOf(FormataData(dataPagamento.date())); 
                System.debug('correcaoMonetaria.dataFinalValidade' + correcaoMonetaria.dataFinalValidade);
                //PLV-4892-FIM-FIX03
                //PLV-4892-FIM-FIX05
            }    
           
            //PLV-4892-INICIO-FIX03
            correcaoMonetaria.indice = 'IPCA';
            System.debug('correcaoMonetaria 0 0 1  → ' + correcaoMonetaria);
            //Integração correcaoMonetaria

            //MGRC-1248 - INICIO
            // String retornoCiv = CIVServices.getInstance().GerarAtualizacaoMonetaria(JSON.serialize(correcaoMonetaria));
            String retornoSensedia = SensediaServices.getInstance().montagemServicoSensedia(SensediaServices.VERB.POST, SensediaServices.DOMAIN.AWS_EXTERNO, SensediaServices.ATUALIZACAO_MONETARIA, JSON.serialize(correcaoMonetaria));
            //MGRC-1248 - FIM
            
            boolean erroTO = retornoSensedia.contains('"portoSeguroFaultInfo":{');//MGRC-1248 - INICIO/FIM - FIX1

            if(erroTO){
                ErrorAtualizacaoMonetariaTO erroAtualizacaoMonetaria = (ErrorAtualizacaoMonetariaTO) System.JSON.deserialize(retornoSensedia, ErrorAtualizacaoMonetariaTO.class);
                if(erroAtualizacaoMonetaria.portoSeguroFaultInfo.codigo == '159'){
                    retorno.mensagens.add('Erro ao realizar atualização monetária. Código:    ' + erroAtualizacaoMonetaria.portoSeguroFaultInfo.codigo 
                                         +'. Mensagem: ' + erroAtualizacaoMonetaria.portoSeguroFaultInfo.mensagem);
                    retorno.tipo = RetornoAcaoBotaoTO.ERROR; 
                    return JSON.serialize(retorno);
                }
            }
            //PLV-4892-FIM-FIX03
            
            // ********** ATUALIZAÇÃO MONETÁRIA *********/
            //PLV-4892-INICIO-FIX03
            AtualizacaoMonetariaTO atualizacaoMonetariaTO = (AtualizacaoMonetariaTO) System.JSON.deserialize(retornoSensedia, AtualizacaoMonetariaTO.class);
            System.debug('BRUNO DEBUG:::');
            System.debug(atualizacaoMonetariaTO);
            
            if(atualizacaoMonetariaTO.indices != null){
            
                decimal valorComplemento = 0.0; //PLV-4745 - INÍCIO/FIM
                
                if(substituir){
                    
                    List<ComplementoIndenizacao__c> complemento = [SELECT Id, Valor__c, PagamentoGarantia__c, Motivo__c, Descricao__c, BeneficiarioGarantia__c FROM ComplementoIndenizacao__c WHERE BeneficiarioGarantia__c = :beneficiario.id  AND TipoComplemento__c = 'Atualização Monetária' ORDER BY createdDate DESC LIMIT 1];
                    
                    Decimal ContaTaxaInicio = 0;
                    Decimal ContaTaxaFim = 1;
                    Decimal ContaMult = 0;
                    Decimal taxaGeral = 0;                    
                    decimal vlrAtMonetaria = beneficiario.ValorIndenizacao__c;

                    for(Integer i=0; i<atualizacaoMonetariaTO.indices.size(); i++){
                        ContaTaxaInicio = decimal.valueOf(atualizacaoMonetariaTO.indices[i].taxaIndice);
                        ContaTaxaFim *= ContaTaxaInicio/100+1;
                        taxaGeral = ContaTaxaFim*vlrAtMonetaria-vlrAtMonetaria;
                        totalTaxa = taxaGeral;
                    } 

                    if(complemento.size() == 0){
                        ComplementoIndenizacao__c complementos = new ComplementoIndenizacao__c();
                        complementos.TipoComplemento__c = 'Atualização Monetária';
                        decimal taxaIndice = totalTaxa;
                        decimal vlr = beneficiario.ValorIndenizacao__c;
                        valorComplemento = taxaIndice;
                        complementos.Valor__c = valorComplemento;
                        complementos.PagamentoGarantia__c = pg.Id;
                        complementos.Motivo__c = 'Prazo de Regulação excedido';
                        complementos.Descricao__c = 'Atualização Monetária';
                        complementos.BeneficiarioGarantia__c = beneficiario.id;
                        insert complementos;
                    }
                    
                    complemento = complemento.size() > 0 ? complemento : [SELECT Id, Valor__c, PagamentoGarantia__c, Motivo__c, Descricao__c, BeneficiarioGarantia__c FROM ComplementoIndenizacao__c WHERE BeneficiarioGarantia__c = :beneficiario.id  AND TipoComplemento__c = 'Atualização Monetária' ORDER BY createdDate DESC LIMIT 1];
                    decimal taxaIndice = (totalTaxa);
                    decimal vlr = beneficiario.ValorIndenizacao__c;
                    valorComplemento = (taxaIndice);
                    complemento[0].Valor__c = valorComplemento;                   
                    MovimentoSinistro__c movimento = new MovimentoSinistro__c();
                    movimento.Caso__c = beneficiario.Pagamento_de_garantia__r.Caso__c;
                    movimento.PagamentoGarantia__c = pg.Id;
                    movimento.BeneficiarioGarantia__c = beneficiario.Id;
                    movimento.TipoMovimento__c = 'Aviso';
                    movimento.DescricaoMovimento__c= calculaDescricaoMovimentoMonetaria(complemento[0]);
                    update complemento[0];
                    movimento.DataMovimento__c= system.Today();
                    movimento.SequenciaMovimento__c = !Test.isRunningTest() ? String.valueOf(SequenciaMovimentoSinistroHelper.sequenciaMovimentos(new Set<id>{beneficiario.Pagamento_de_garantia__r.Caso__c}).get(beneficiario.Pagamento_de_garantia__r.Caso__c)) : '1'; //MGRC-1248 - INICIO/FIM - FIX1 //PLV-4818 - INICIO/FIM - PEDRO AUGUSTO BRAZ - SYS4B
                    movimento.ValorMovimento__c = valorComplemento; //PLV-4818 - INICIO/FIM - PEDRO AUGUSTO BRAZ - SYS4B
                    insert movimento;
                    beneficiario.valorComplementos__c = valorComplemento; //PLV-4745 - INÍCIO/FIM

                }else{
                    Decimal ContaTaxaInicio = 0;
                    Decimal ContaTaxaFim = 1;
                    Decimal ContaMult = 0;
                    Decimal taxaGeral = 0;                    
                    decimal vlrAtMonetaria = beneficiario.ValorIndenizacao__c;

                    for(Integer i=0; i<atualizacaoMonetariaTO.indices.size(); i++){       
                        ContaTaxaInicio = decimal.valueOf(atualizacaoMonetariaTO.indices[i].taxaIndice);
                        ContaTaxaFim *= ContaTaxaInicio/100+1;
                        taxaGeral = ContaTaxaFim*vlrAtMonetaria-vlrAtMonetaria;
                        totalTaxa = taxaGeral;
                    } 

                    ComplementoIndenizacao__c complemento = new ComplementoIndenizacao__c();
                    complemento.TipoComplemento__c = 'Atualização Monetária';
                    decimal taxaIndice = totalTaxa;
                    decimal vlr = beneficiario.ValorIndenizacao__c;
                    valorComplemento = (totalTaxa);
                    complemento.Valor__c = valorComplemento;
                    complemento.PagamentoGarantia__c = pg.Id;
                    complemento.Motivo__c = 'Prazo de Regulação excedido';
                    complemento.Descricao__c = 'Atualização Monetária';
                    complemento.BeneficiarioGarantia__c = beneficiario.id;
                    
                    MovimentoSinistro__c movimento = new MovimentoSinistro__c();
                    movimento.Caso__c = beneficiario.Pagamento_de_garantia__r.Caso__c;
                    movimento.PagamentoGarantia__c = pg.Id;
                    movimento.BeneficiarioGarantia__c = beneficiario.Id;
                    movimento.TipoMovimento__c = 'Aviso';
                    movimento.DescricaoMovimento__c= calculaDescricaoMovimentoMonetaria(complemento);
                    insert complemento;
                    movimento.DataMovimento__c= system.Today();
                    movimento.SequenciaMovimento__c = !Test.isRunningTest() ?  String.valueOf(SequenciaMovimentoSinistroHelper.sequenciaMovimentos(new Set<id>{beneficiario.Pagamento_de_garantia__r.Caso__c}).get(beneficiario.Pagamento_de_garantia__r.Caso__c)) : '1';//MGRC-1248 - INICIO/FIM - FIX1 //PLV-4818 - INICIO/FIM - PEDRO AUGUSTO BRAZ - SYS4B
                    movimento.ValorMovimento__c = valorComplemento; //PLV-4818 - INICIO/FIM - PEDRO AUGUSTO BRAZ - SYS4B
                    insert movimento;
                    beneficiario.valorComplementos__c = beneficiario.valorComplementos__c != null ? beneficiario.valorComplementos__c + valorComplemento : valorComplemento; //PLV-4745 - INÍCIO/FIM
                }
            }
            
            // ********** ATUALIZAÇÃO JUROS *********/  
            decimal valorComplemento = 0.0; //PLV-4745 - INÍCIO/FIM
            Integer prazoCalcSusep = 30;//PLV-4892-INICIO/FIM

            Decimal valorComplemento1 = 0;
            Decimal valorComplemento2 = 0; 
            Decimal valorComplemento3 = 0;
            Decimal valorComplemento4 = 0;
            Decimal vlrMtaxa = 0;

            if(substituir){
                
                ComplementoIndenizacao__c complemento = [SELECT Id, Valor__c, PagamentoGarantia__c, Motivo__c, Descricao__c, BeneficiarioGarantia__c FROM ComplementoIndenizacao__c WHERE BeneficiarioGarantia__c = :beneficiario.id AND TipoComplemento__c = 'Juros' ORDER BY createdDate DESC LIMIT 1];
                
                //PLV-4892-INICIO-FIX02
                decimal vlr = beneficiario.ValorIndenizacao__c;

                vlrMtaxa = vlr.setscale(2) + totalTaxa;
                valorComplemento1 = taxaJuros * diasAtrasoPrazo; 
                valorComplemento2 = valorComplemento1/100;  
                valorComplemento3 =  valorComplemento2 * vlrMtaxa;  
                valorComplemento4 = valorComplemento3 + vlrMtaxa;  
                valorComplemento = valorComplemento4 - vlrMtaxa;//PLV-4892-INICIO/FIM-FIX01
                complemento.Valor__c = valorComplemento;
             
                //PLV-4892-FIM-FIX02
                MovimentoSinistro__c movimento = new MovimentoSinistro__c();
                movimento.Caso__c = beneficiario.Pagamento_de_garantia__r.Caso__c;
                movimento.PagamentoGarantia__c = pg.Id;
                movimento.BeneficiarioGarantia__c = beneficiario.Id;
                movimento.TipoMovimento__c = 'Aviso';
                movimento.DescricaoMovimento__c= calculaDescricaoMovimentoJuros(complemento);
                update complemento;
                movimento.DataMovimento__c= system.Today();
                movimento.SequenciaMovimento__c = !Test.isRunningTest() ? String.valueOf(SequenciaMovimentoSinistroHelper.sequenciaMovimentos(new Set<id>{beneficiario.Pagamento_de_garantia__r.Caso__c}).get(beneficiario.Pagamento_de_garantia__r.Caso__c)) : '1';//MGRC-1248 - INICIO/FIM - FIX1 //PLV-4818 - INICIO/FIM - PEDRO AUGUSTO BRAZ - SYS4B
                movimento.ValorMovimento__c = valorComplemento; //PLV-4818 - INICIO/FIM - PEDRO AUGUSTO BRAZ - SYS4B
                insert movimento;
                beneficiario.valorComplementos__c = atualizacaoMonetariaTO.indices != null ? beneficiario.valorComplementos__c  + valorComplemento.setScale(2)  : valorComplemento.setScale(2); //PLV-4745 - INÍCIO/FIM
            
            }else{

                ComplementoIndenizacao__c complemento = new ComplementoIndenizacao__c();
                complemento.TipoComplemento__c = 'Juros';
                
                //PLV-4892-INICIO-FIX02
                decimal vlr = beneficiario.ValorIndenizacao__c;

                vlrMtaxa = vlr.setscale(2) + totalTaxa;
                valorComplemento1 = taxaJuros * diasAtrasoPrazo; 
                valorComplemento2 = valorComplemento1/100;  
                valorComplemento3 =  valorComplemento2 * vlrMtaxa;  
                valorComplemento4 = valorComplemento3 + vlrMtaxa;
                valorComplemento = valorComplemento4 - vlrMtaxa;
                
                // PLV-4892-FIM-FIX02
                complemento.Valor__c = valorComplemento;
                complemento.PagamentoGarantia__c = pg.Id;
                complemento.Motivo__c = 'Prazo de Regulação excedido';
                complemento.Descricao__c = 'Juros';
                complemento.BeneficiarioGarantia__c = beneficiario.id;
                
                MovimentoSinistro__c movimento = new MovimentoSinistro__c();
                movimento.Caso__c = beneficiario.Pagamento_de_garantia__r.Caso__c;
                movimento.PagamentoGarantia__c = pg.Id;
                movimento.BeneficiarioGarantia__c = beneficiario.Id;
                movimento.TipoMovimento__c = 'Aviso';
                movimento.DescricaoMovimento__c= calculaDescricaoMovimentoJuros(complemento);
                insert complemento;
                movimento.DataMovimento__c= system.Today();
                movimento.SequenciaMovimento__c = String.valueOf(SequenciaMovimentoSinistroHelper.sequenciaMovimentos(new Set<id>{beneficiario.Pagamento_de_garantia__r.Caso__c}).get(beneficiario.Pagamento_de_garantia__r.Caso__c));//PLV-4818 - INICIO/FIM - PEDRO AUGUSTO BRAZ - SYS4B
                movimento.ValorMovimento__c = valorComplemento; //PLV-4818 - INICIO/FIM - PEDRO AUGUSTO BRAZ - SYS4B
                insert movimento;  
                beneficiario.valorComplementos__c = beneficiario.valorComplementos__c != null ? beneficiario.valorComplementos__c + valorComplemento.setScale(2) : valorComplemento.setScale(2); //PLV-4745 - INÍCIO/FIM
            }
            
            BeneficiarioGarantiaTriggerHandler.criarMovimento = false;
            update beneficiario; //PLV-4745 - INÍCIO/FIM
            BeneficiarioGarantiaTriggerHandler.criarMovimento = true;
            retorno.tipo = RetornoAcaoBotaoTO.SUCCESS;
            retorno.linkRedirecionar = idBeneficiarioGarantia;
            retorno.mensagens.add('Atualização monetária realizada com sucesso!');
        // PLV-4892-INICIO-FIX01    
        } catch (Exception e) {
            retorno.tipo = RetornoAcaoBotaoTO.ERROR;
            retorno.linkRedirecionar = idBeneficiarioGarantia;
            retorno.mensagens.add(e.getMessage());
        } finally {
            PagamentoGarantiaTriggerHandler.gerarMovimento = true;
        }
        // PLV-4892-FIM-FIX01
        return JSON.serialize(retorno);
    }
    //PLV-4892-FIM-FIX03
    
    @AuraEnabled
    public static String possuiComplementoIndenizacao (String idBeneficiarioGarantia){
        
        String retorno;

        List<ComplementoIndenizacao__c> cmpl = [SELECT Id FROM ComplementoIndenizacao__c WHERE BeneficiarioGarantia__c = :idBeneficiarioGarantia LIMIT 1];
        
        if(cmpl.isEmpty()){ 
            retorno = criaComplementoIndenizacao(idBeneficiarioGarantia, false);
        }else{
            RetornoAcaoBotaoTO retornoTemp = new RetornoAcaoBotaoTO();
            retornoTemp.tipo = RetornoAcaoBotaoTO.ERROR;
            retornoTemp.mensagens.add('Possui complemento.');
            retorno = JSON.serialize(retornoTemp);      
        }
        return retorno;
    }
    
    //PLV-4892 - INICIO
    public static string FormataData (Date data ){
        DateTime dt = DateTime.newInstance(data.year(), data.month(), data.day());
        return dt.format('ddMMyyyy');
    }
    //PLV-4892 - FIM
    
    public static string calculaDescricaoMovimentoJuros(ComplementoIndenizacao__c newComplemento){
        List<ComplementoIndenizacao__c> oldComplemento = new List<ComplementoIndenizacao__c>();
        oldComplemento = [SELECT Id, Valor__c FROM ComplementoIndenizacao__c WHERE id = :newComplemento.id];
        
        if(oldComplemento.size() == 0){
            return '52';
        }
        
        return newComplemento.Valor__c > oldcomplemento[0].Valor__c ? '52' : '53';
    }
    
    public static string calculaDescricaoMovimentoMonetaria(ComplementoIndenizacao__c newComplemento){
        List<ComplementoIndenizacao__c> oldComplemento = new List<ComplementoIndenizacao__c>();
        oldComplemento = [SELECT Id, Valor__c FROM ComplementoIndenizacao__c WHERE id = :newComplemento.id];
        
        if(oldComplemento.size() == 0){
            return '62';
        }
        
        return newComplemento.Valor__c > oldcomplemento[0].Valor__c ? '62' : '63';
    }

    //PLV-4892-INICIO-FIX03
    public class CorrecaoMonetariaTO {
        public string indice                                        {get; set;}
        public string dataInicioValidade                            {get; set;} //PLV-4892 - INICIO/FIM
        public string dataFinalValidade                             {get; set;}  //PLV-4892 - INICIO/FIM
    }
    
    public class CorrecaoTaxaJurosTO{
        public string chaveJuros                                    {get; set;}
        public string siglaMoeda                                    {get; set;}
        public string dataInicioValidade                            {get; set;}
        public string dataFinalValidade                             {get; set;}
    }
    
    public class AtualizacaoTaxaJurosTO {
        public ItensChaveJuros ItensChaveJuros                      {get; set;}
        
        public string codigo                                        {get; set;}
        public string mensagem                                      {get; set;}
        public string dataOcorrencia                                {get; set;}
        public string fonte                                         {get; set;}
        public string tipo                                          {get; set;}
        public string additionalInfo                                {get; set;}
    }
    public class ItensChaveJuros {
        public ItemChaveJuros  ItemChaveJuros                       {get; set;}
    }
    
    public class ItemChaveJuros {
        public string taxaJuros                                     {get; set;}
        public string dataTaxaJuros                                 {get; set;}
        public string valorTaxaJuros                                {get; set;}
    }
    //PLV-4535 - FIM

    public class AtualizacaoMonetariaTO {
        public List<ItemTaxaIndice> indices                         {get; set;}
    }

    public class ItemTaxaIndice {
	    public string indice                                        {get; set;}
	    public string dataIndice                                    {get; set;}
	    public string taxaIndice                                    {get; set;}
	    public string chaveJuros                                    {get; set;}
    }
    
    public class ErrorAtualizacaoMonetariaTO {
      public ItemErrorAtualizacaoMonetariaTO portoSeguroFaultInfo   {get; set;}
    }

    public class ItemErrorAtualizacaoMonetariaTO {
        public string codigo                                        {get; set;}
        public string tipo                                          {get; set;}
        public string mensagem                                      {get; set;}
        public string fonte                                         {get; set;}
        public string additionalInfo                                {get; set;}
    }
    //PLV-4892-FIM-FIX03
    //PLV-4892-FIM-FIX04
    //PLV-4892-FIM-FIX07
}