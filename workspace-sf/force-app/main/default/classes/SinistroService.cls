/*******************************************************************************************************************************
* 
* @author Leonardo - Globant
* @date 16/06/2020
* @modifiedAt 
* Classe criada por conta da história PLV-3875
* Serviço para criar sinistro (Caso)
******************************************************************************************************************************/
public with sharing class SinistroService {

    private CivSinistroTO.Request   ParametroEntrada; //PLV-4094 - INICIO/FIM    
    private Map<String, RecordType> mapRecordTypeCaso;

    //PLV-4094 - LINHA DE CÓDIGO REMOVIDA -

    public SinistroService(CivSinistroTO.Request dadosEntrada) { //PLV-4094 - INICIO/FIM
        this.ParametroEntrada  = dadosEntrada;
        this.mapRecordTypeCaso = RecordTypeBO.buscarTipoRegistro('Case');           
    }

    //PLV-4166 - INICIO
    public CivSinistroTO.DataTO AtualizaCasoSinistro(){ 
        String CaseNumero = this.ParametroEntrada.numeroSinistro;  
        Set<Id> garantiaInsertIds = new Set<Id>(); 
        Map<String, PagamentoGarantia__c> mapGarantiaSigla = new Map<String, PagamentoGarantia__c>();               
        List<CivSinistroTO.GarantiaSinistroTO> ListGarantias = this.parametroEntrada.garantias;          
        List<PagamentoGarantia__c> listInsertGarantia = new  List<PagamentoGarantia__c>();          
        List<PagamentoGarantia__c> listUpdateGaratia = new  List<PagamentoGarantia__c>();      
             
        //List Case
        List<Case> relatedCases = [
            SELECT ID,Status,DataReabertura__c,TipoContagem__c, MotivosReabertura__c,
            Status_Dependente__c, NumeroSinistro__c, IdPrestadora__c, Contrato__c 
            from case
            where NumeroSinistro__c = :CaseNumero limit 1
        ];

        if(relatedCases[0].Status == 'Fechado'){    
            //PLV-4166 INICIO - CORREÇÃO BENEFICIARIOS
            // relatedCases[0].DataReabertura__c = System.Datetime.now();
            // relatedCases[0].MotivosReabertura__c = 'Nova solicitação de indenização';
            // update  relatedCases;
            //PLV-4166 FIM - CORREÇÃO BENEFICIARIOS
           
            //Metodo reabrir case
            Map<String,Object> caseReabrir = BotaoReabrirSinistroController.reabrirSinistro(
                relatedCases[0].Id,
                'Nova solicitação de indenização',
                'Iniciar do Zero', 
                'Caso Reaberto');

            //PLV-4166 INICIO/FIM - CORREÇÃO BENEFICIARIOS
            relatedCases[0].Status = 'Liquidação';
            relatedCases[0].Status_Dependente__c = 'Aguardando Pagamento';
            update relatedCases[0];
            //PLV-4166 INICIO/FIM - CORREÇÃO BENEFICIARIOS
        }        
         
        //List Garantia
        List<PagamentoGarantia__c> Listgarantia = [
            SELECT ID, Caso__c, MoedaGarantia__c, Garantia_do_segurado_do_contrato__r.Garantia__r.Sigla__c, 
            Garantia_do_segurado_do_contrato__c, Name,  Fase__c, Caso__r.NumeroSinistro__c, CurrencyIsoCode, 
            Valor_indenizado__c, Capital__c, Status_do_pagamento__c                                           
            FROM PagamentoGarantia__c 
            WHERE  Caso__r.NumeroSinistro__c =: CaseNumero  
            AND Garantia_do_segurado_do_contrato__r.Garantia__r.Sigla__c IN: this.parametroEntrada.mapGarantia.keySet()
            AND Fase__c != 'Fechado'
            AND Status_do_pagamento__c != 'Recusado'
            AND Status_do_pagamento__c != 'Cancelado'              
        ]; //PLV-4166 INICIO/FIM - CORREÇÃO BENEFICIARIOS
       
        
        if(!Listgarantia.isEmpty()) //PLV-4166 INICIO/FIM - CORREÇÃO BENEFICIARIOS
        {                         
            for(PagamentoGarantia__c a : Listgarantia)
            { 
                mapGarantiaSigla.put(a.Garantia_do_segurado_do_contrato__r.Garantia__r.Sigla__c,a);                
            }
        }

                       
        PagamentoGarantia__c[] lsPagamentoGarantia = new PagamentoGarantia__c[]{};
        for(CivSinistroTO.GarantiaSinistroTO a : this.parametroEntrada.garantias)
        {      
            //Validação garatia existe 
            if(mapGarantiaSigla.containsKey(a.sigla)){    
                if(mapGarantiaSigla.get(a.sigla).Status_do_pagamento__c != 'Aguardando Pagamento' 
                    && mapGarantiaSigla.get(a.sigla).Status_do_pagamento__c != 'Pago' 
                    && mapGarantiaSigla.get(a.sigla).Status_do_pagamento__c != 'Pago Parcialmente') //PLV-4166 INICIO/FIM - CORREÇÃO BENEFICIARIOS
                {
                    if(a.tipoValor == 'SOM')
                    {
                        PagamentoGarantia__c garatiateste = mapGarantiaSigla.get(a.sigla);
                        garatiateste.Valor_indenizado__c= a.valorIndenizado + mapGarantiaSigla.get(a.sigla).Valor_indenizado__c;
                        garatiateste.CurrencyIsoCode= a.moedaIndenizacao;            
                        listUpdateGaratia.add(garatiateste); 

                    } else if (a.tipoValor == 'SUB')
                    {
                        PagamentoGarantia__c garatiateste = mapGarantiaSigla.get(a.sigla);
                        garatiateste.Valor_indenizado__c= a.valorIndenizado;
                        garatiateste.CurrencyIsoCode= a.moedaIndenizacao;            
                        listUpdateGaratia.add(garatiateste);

                    }else{                    
                        PagamentoGarantia__c garatiateste = mapGarantiaSigla.get(a.sigla);
                        garatiateste.Valor_indenizado__c= mapGarantiaSigla.get(a.sigla).Valor_indenizado__c;
                        garatiateste.CurrencyIsoCode= a.moedaIndenizacao;            
                        listUpdateGaratia.add(garatiateste); 
                    }                
                }
            }

            //Validação garantia não existe
            if(!mapGarantiaSigla.containsKey(a.sigla))
            {   
                List<GarantiaSeguradoContrato__c> lstGarantia = [SELECT Id, Garantia__r.Name, Capital__c from GarantiaSeguradoContrato__c Where Garantia__r.Sigla__c =:a.sigla AND SeguradoContrato__r.GrupoContrato__r.ContratanteContrato__r.Contrato__c = :relatedCases[0].Contrato__c];     
                
                //if(lstGarantia.isEmpty()) return; //retorno com mensagem de erro, garantia não existe no Contrato

                PagamentoGarantia__c pag = getPagamentoCriaGarantia(relatedCases[0].Id,  lstGarantia[0]);
                pag.Valor_indenizado__c = a.valorIndenizado;
                pag.CurrencyIsoCode = a.moedaIndenizacao;        
                lsPagamentoGarantia.add(pag);
                
            }else if(mapGarantiaSigla.get(a.sigla).Status_do_pagamento__c == 'Aguardando Pagamento' || mapGarantiaSigla.get(a.sigla).Status_do_pagamento__c == 'Pago' || mapGarantiaSigla.get(a.sigla).Status_do_pagamento__c == 'Pago Parcialmente') //PLV-4166 INICIO/FIM - CORREÇÃO BENEFICIARIOS
            {               
                lsPagamentoGarantia.add(getPagamentoAtualizaGarantia(relatedCases[0].Id,  mapGarantiaSigla.get(a.sigla) , a.valorIndenizado)); // PLV-4364
            }                 
        }

        //update garantia;
        Database.SaveResult[] saveResultList = Database.update(listUpdateGaratia, false);
        for (Database.SaveResult sr : saveResultList) {
            if (!sr.isSuccess()) {
                // Operation was successful, so get the ID of the record that was processed
                System.debug('Successfully update garatia. garantia ID: ' + sr.getId());
            }
            else {
                // Operation failed, so get all errors                
                for(Database.Error err : sr.getErrors()) {
                    System.debug('The following error has occurred.');                    
                    System.debug(err.getStatusCode() + ': ' + err.getMessage());
                    System.debug('Garantia fields that affected this error: ' + err.getFields());
                }
            }
        }

        //PLV-4166 - INICIO - CORREÇÃO BENEFICIARIOS
        if(!listUpdateGaratia.IsEmpty()){
            
            Map<String, PagamentoGarantia__c> mapPagamentoGarantia = new Map<String, PagamentoGarantia__c>();
            List<BeneficiarioGarantia__c> listaBeneficiariosUpdate = new List<BeneficiarioGarantia__c>();

            for(PagamentoGarantia__c pagamentoGarantia : listUpdateGaratia){
                mapPagamentoGarantia.put(pagamentoGarantia.Id, pagamentoGarantia);
            }

            List<BeneficiarioGarantia__c> listaBeneficiariosGarantias = [
                SELECT Id, ValorIndenizacao__c, CurrencyIsoCode, Pagamento_de_garantia__c
                FROM BeneficiarioGarantia__c
                WHERE Pagamento_de_garantia__c = :mapPagamentoGarantia.keySet()
            ];
            
            if(!listaBeneficiariosGarantias.IsEmpty()){
                for(BeneficiarioGarantia__c beneficiarioGarantia : listaBeneficiariosGarantias){
                    beneficiarioGarantia.InformarIndenizacao__c       = 'Valor de Indenização';
                    beneficiarioGarantia.ValorIndenizacao__c          = mapPagamentoGarantia.get(beneficiarioGarantia.Pagamento_de_garantia__c).Valor_indenizado__c;
                    beneficiarioGarantia.CurrencyIsoCode              = mapPagamentoGarantia.get(beneficiarioGarantia.Pagamento_de_garantia__c).CurrencyIsoCode;
                    listaBeneficiariosUpdate.add(beneficiarioGarantia);
                }
                
                update listaBeneficiariosUpdate;
            }
        }
        //PLV-4166 - FIM - CORREÇÃO BENEFICIARIOS
        
        //insert garantia
        Database.SaveResult[] srList = Database.insert(lsPagamentoGarantia, false);
        // Iterate through each returned result
        for (Database.SaveResult sr : srList) {
            if (sr.isSuccess()) {
                // Operation was successful, so get the ID of the record that was processed
                garantiaInsertIds.add(sr.id);
                
            }else {
                // Operation failed, so get all errors                
                for(Database.Error err : sr.getErrors()) {
                    System.debug('The following error has occurred.');                    
                    System.debug(err.getStatusCode() + ': ' + err.getMessage());
                    System.debug('Garantia fields that affected this error: ' + err.getFields());
                }
            }
        }
        
        //PLV-4509 - Inicio
        if(!garantiaInsertIds.isEmpty())
        {
            listInsertGarantia = [SELECT Id, Valor_indenizado__c, CurrencyIsoCode, Garantia_do_segurado_do_contrato__r.Garantia__r.Sigla__c  FROM PagamentoGarantia__c WHERE Id IN: garantiaInsertIds];
            
        }              
        
        criarBeneficiario(listInsertGarantia);
        //PLV-4509 - Fim
           
        //PLV-4509 - Remover esta parte - Inicio  
        //Beneficiário
        /*BeneficiarioGarantia__c[] listaBeneficiario = new BeneficiarioGarantia__c[]{};
        for(PagamentoGarantia__c aGarantia : listInsertGarantia){              
            //Douglas mock Inicio
            for(CivSinistroTO.BeneficiarioSinistroTO beneficiario : this.parametroEntrada.mapBeneficiarios.get(aGarantia.Garantia_do_segurado_do_contrato__r.Garantia__r.Sigla__c))
            {      
            listaBeneficiario.add( new BeneficiarioGarantia__c(
                Conta__c                     = this.parametroEntrada.ContaPrestadora.conta__c, 
                Pagamento_de_garantia__c     = aGarantia.Id,
                Status__c                    = 'Pendente',
                InformarIndenizacao__c       = 'Valor de Indenização',              
                //ValorIndenizacao__c          = aGarantia.Valor_indenizado__c,
                //CurrencyIsoCode              = aGarantia.CurrencyIsoCode
                ValorIndenizacao__c          = decimal.valueOf(beneficiario.valorIndenizacaoBeneficiario),
                CurrencyIsoCode              = beneficiario.moeda
            ));
            }*/
             //Douglas mock FIM
       // }

        //insert listaBeneficiario;
        //PLV-4509 - Remover esta parte - Fim  
        
        //objeto de retorno
        CivSinistroTO.DataTO retorno = new CivSinistroTO.DataTO(); 
        retorno.caseId                           = relatedCases[0].id; 
        retorno.sinistro.ano                     = system.today().year();
        retorno.sinistro.empresa                 = this.ParametroEntrada.empresa;
        retorno.sinistro.ramo                    = this.ParametroEntrada.ramo;
        retorno.sinistro.numeroSinistro          = relatedCases[0].NumeroSinistro__c;
        retorno.sinistro.status                  = relatedCases[0].status;
        retorno.sinistro.idAtendimentoPrestadora = this.ParametroEntrada.idAtendimentoPrestadora;
        retorno.sinistro.edsTip                  = '1'; 
      
        return retorno;
    
    }

    //Objeto atualiza garantia
     // PLV-4364 - INICIO
    public PagamentoGarantia__c getPagamentoAtualizaGarantia(Id caseId, PagamentoGarantia__c garantia, Double valorInd ){
        return new PagamentoGarantia__c(
            Caso__c                             = caseId,
            name                                = garantia.name,
            Fase__c                             = 'Em análise',
            Status_do_pagamento__c              = 'Em análise',
            Garantia_do_segurado_do_contrato__c = garantia.Garantia_do_segurado_do_contrato__c,                    
            CurrencyIsoCode                     = garantia.MoedaGarantia__c,
            Valor_indenizado__c                 = valorInd ,
            Capital__c                          = garantia.Capital__c,
            IsPagAdc__c                         = true
        );
    }
    // PLV-4364 - FIM 

    //Objeto cria garantia
    public PagamentoGarantia__c getPagamentoCriaGarantia(Id caseId, GarantiaSeguradoContrato__c garantia ){
        return new PagamentoGarantia__c(
            Caso__c                             = caseId,
            name                                = garantia.Garantia__r.Name,
            Fase__c                             = 'Em análise',
            Status_do_pagamento__c              = 'Em análise',
            Garantia_do_segurado_do_contrato__c = garantia.Id,
            Capital__c                          = garantia.Capital__c,
            IsPagAdc__c                         = true
        );
    }

    //PLV-4166 - FIM

    public CivSinistroTO.DataTO criarCasoSinistro(){ //PLV-4094 - INICIO/FIM
 
        //busca o caso de de atendimento
        Case caseAtendimento = this.getCaseAtendimento();
        Case caseSinistro    = null;

        system.debug('testeSinistro1 '+caseAtendimento);
        if(caseAtendimento != null) caseSinistro = this.criarCasoSinistro(caseAtendimento);
        system.debug('testeSinistro2 '+caseSinistro);
        if(caseAtendimento == null) { 
            caseAtendimento = this.criarCasoAtendimento();
            caseSinistro = this.criarCasoSinistro(caseAtendimento);
            system.debug('testeSinistro3 '+ caseAtendimento);
            system.debug('testeSinistro4 '+ caseSinistro);
        }

        system.debug('testeSinistro5');
        CivSinistroTO.DataTO retorno = new CivSinistroTO.DataTO(); //PLV-4094 - INICIO/FIM

        retorno.caseId                           = caseSinistro.id; //PLV-4094 - INICIO/FIM
        retorno.sinistro.ano                     = system.today().year();
        retorno.sinistro.empresa                 = this.ParametroEntrada.empresa;
        retorno.sinistro.ramo                    = this.ParametroEntrada.ramo;
        retorno.sinistro.numeroSinistro          = caseSinistro.NumeroSinistro__c;
        retorno.sinistro.status                  = caseSinistro.status;
        retorno.sinistro.idAtendimentoPrestadora = this.ParametroEntrada.idAtendimentoPrestadora;
        retorno.sinistro.edsTip                  = '1'; //PLV-4094 - INICIO/FIM
        system.debug('passou 33 '+this.getCaseAtendimento());
        system.debug('passou 33 '+caseAtendimento);
        system.debug('passou 33 '+retorno);
        return retorno;
    }

    private Case getCaseAtendimento(){

        List<Case> listCasoAtendimento = [
            SELECT id, AccountId, ContactId, Contrato__c
            FROM Case 
            WHERE status                  = 'Aberto' 
              AND Account.cpf__c          = :this.ParametroEntrada.getCPF()
              AND NumeroApoliceFormula__c = :this.ParametroEntrada.apolice.substring(0,9)
              AND Dataocorrencia__c       = :this.ParametroEntrada.getDateOcorrencia()
              AND Numero_titulo__c        = :this.ParametroEntrada.prestadoraName //PLV-4509 - Inicio/Fim
              AND recordTypeId            = :this.mapRecordTypeCaso.get('Case' + '|' + 'Atendimento').id
            LIMIT 1
        ];

        system.debug('teste '+listCasoAtendimento);        
        return listCasoAtendimento.isEmpty() ? null : listCasoAtendimento.get(0);
    }

    private Case criarCasoSinistro(Case caseAtendimento){
        Case caseSinistro                        = this.ParametroEntrada.getCase();
        caseSinistro.RecordTypeId                = mapRecordTypeCaso.get('Case' + '|' + 'Sinistro').id;
        caseSinistro.ParentId                    = caseAtendimento.Id;
        caseSinistro.status                      = 'Avisado'; //fase
        caseSinistro.Status_Dependente__c        = 'Em Análise';
        caseSinistro.NumeroSinistro__c           = this.ParametroEntrada.numeroSinistro;
        //PLV-3918 - João Luiz
        caseSinistro.Parceiro__c                 = this.ParametroEntrada.contaPrestadora.Id;
        //PLV-3997 - INICO - PEDRO AUGUSTO - SYS4B
        caseSinistro.SinistroBeneficioAvisado__c = true; //Hardcode conforme alinhado com Antonio na História PLV- 3997 (Será resolvido na proxima sprint)
        //PLV-3997 - FIM - PEDRO AUGUSTO - SYS4B
        caseSinistro.Criado_por_Servico__c       = true; //PLV-4870 - Inicio/Fim
        //system.debug('passou 15'+this.parametroEntrada.mapBeneficiarios.get('MAP')[0]);
        insert caseSinistro;

        this.criarGarantia(caseSinistro);

        return caseSinistro;
    }

    private Case criarCasoAtendimento(){

        Case casoAtendimento                 = this.parametroEntrada.getCase();
        casoAtendimento.RecordTypeId         = mapRecordTypeCaso.get('Case' + '|' + 'Atendimento').id;
        casoAtendimento.status               = 'Aberto';
        casoAtendimento.Status_Dependente__c = 'Aberto';
        casoAtendimento.IdPrestadora__c      = null;
        casoAtendimento.Parceiro__c          = this.ParametroEntrada.contaPrestadora.Id; //PLV-4166 - INICIO/FIM
        
        insert casoAtendimento;        
        return casoAtendimento;           
    }

    //PLV-4509 - Inicio  
    private void criarBeneficiario(List<PagamentoGarantia__c> lstBeneficiarios)
    {
        system.debug('4870 - SinistroService.criarBeneficiario - Entrou ');

        List<PagamentoGarantia__c> listInsertGarantia = new  List<PagamentoGarantia__c>();      
        BeneficiarioGarantia__c[] listaBeneficiario = new BeneficiarioGarantia__c[]{};
        Set<String> setNumDocCPF = new  Set<String>();  
        Set<String> setNumDocCNPJ = new  Set<String>();
        Set<String> setNumDocEstrangeiro = new  Set<String>(); 
        Map<String, Account> mapAcct = new Map<String, Account>();  
        
        listInsertGarantia = [SELECT Id, Valor_indenizado__c, CurrencyIsoCode, 
                                     Garantia_do_segurado_do_contrato__r.Garantia__r.Sigla__c 
                                 FROM PagamentoGarantia__c 
                                 WHERE Id IN: lstBeneficiarios];

        system.debug('4870 - SinistroService - listBeneficiariosTO = ' + this.parametroEntrada.listBeneficiariosTO);

        //for para obter account informada no json
        for(CivSinistroTO.BeneficiarioSinistroTO beneficiario : this.parametroEntrada.listBeneficiariosTO)
        {
            system.debug('4870 - SinistroService - beneficiario = ' + beneficiario);

            //validação pessoa fisica
            if(beneficiario.dadosPessoaFisica != null) setNumDocCPF.add(formatarDocumento(beneficiario.dadosPessoaFisica.numeroDocumentoBeneficiario)); //PLV-4870 - Inicio/Fim
          
            //Validação pessoa juridica e estrangeira
            if(beneficiario.dadosPessoaJuridica != null)
            {                 
                if(beneficiario.dadosPessoaJuridica.documentoEstrangeiro == true)
                {
                    setNumDocEstrangeiro.add(beneficiario.dadosPessoaJuridica.numeroDocumentoBeneficiario);
                }else{
                    system.debug('4870 - Tamanho da string Jur = ' + beneficiario.dadosPessoaJuridica.numeroDocumentoBeneficiario.length());
                    setNumDocCNPJ.add(formatarDocumento(beneficiario.dadosPessoaJuridica.numeroDocumentoBeneficiario)); //PLV-4870 - Inicio/Fim

                }
            }                     
        }

        //for para popular map de account
        for(Account acct : [SELECT Id, Cnpj__c, Num_Doc_Estrangeiro__c, empresa_estrangeira__c, Cpf__c, isPersonAccount 
                            FROM account 
                            WHERE Cpf__c IN: setNumDocCPF 
                                OR Cnpj__c IN: setNumDocCNPJ 
                                OR Num_Doc_Estrangeiro__c IN: setNumDocEstrangeiro])
        { 
            system.debug('4870 - Entrou');
            if(acct.Cpf__c !=null) mapAcct.put(acct.Cpf__c, acct);                     
            if(acct.Cnpj__c !=null) mapAcct.put(acct.Cnpj__c, acct);            
            if(acct.Num_Doc_Estrangeiro__c !=null) mapAcct.put(acct.Num_Doc_Estrangeiro__c, acct);       
        } 

        //for para criar beneficiario para garantias
        for(PagamentoGarantia__c garantia : listInsertGarantia)
        {      
            system.debug('4870 - mapBeneficiarios = ' + this.parametroEntrada.mapBeneficiarios);
            for(CivSinistroTO.BeneficiarioSinistroTO beneficiario : this.parametroEntrada.mapBeneficiarios.get(garantia.Garantia_do_segurado_do_contrato__r.Garantia__r.Sigla__c))
           {     
                id idAcct;
                system.debug('4870 - mapAcct = ' + mapAcct);
                //Validação beneficiarios
                //PLV-4826 - Inicio
                //PLV-4870 - Inicio
                if(beneficiario.dadosPessoaFisica != null)  idAcct = mapAcct.get(formatarDocumento(beneficiario.dadosPessoaFisica.numeroDocumentoBeneficiario)) != null? mapAcct.get(formatarDocumento(beneficiario.dadosPessoaFisica.numeroDocumentoBeneficiario)).id : null;   
                if(beneficiario.dadosPessoaJuridica != null) idAcct = mapAcct.get(formatarDocumento(beneficiario.dadosPessoaJuridica.numeroDocumentoBeneficiario)) != null? mapAcct.get(formatarDocumento(beneficiario.dadosPessoaJuridica.numeroDocumentoBeneficiario)).id : null;
                //PLV-4870 - Fim
                //PLV-4826 - Fim
                //Validação account
                if(idAcct !=null)
                {         
                    system.debug('4870 - idAcct = ' + idAcct);
                    listaBeneficiario.add( new BeneficiarioGarantia__c(
                            Conta__c                     =  idAcct,
                            Pagamento_de_garantia__c     =  garantia.Id,
                            Status__c                    = 'Pendente',
                            InformarIndenizacao__c       = 'Valor de Indenização',                        
                            ValorIndenizacao__c          =  decimal.valueOf(beneficiario.valorIndenizacaoBeneficiario),
                            CurrencyIsoCode              =  beneficiario.moeda
                    ));
                }
           }           
        }
        if(listaBeneficiario != null)  {
            system.debug('4870 - SinistroService - Lista Bene = ' + listaBeneficiario);
            insert listaBeneficiario;                

        }
    }

    //PLV-4509 - Fim  

    private void criarGarantia(Case caseSinistro){
        system.debug('4870 - SinistroService.criarGarantia - Entrou ');
        PagamentoGarantia__c[] lsPagamentoGarantia = new PagamentoGarantia__c[]{};
        for(CivSinistroTO.GarantiaSinistroTO garantia : this.parametroEntrada.garantias){ //PLV-4094 - INICIO/FIM
            lsPagamentoGarantia.add(garantia.getPagamentoGarantia(caseSinistro.Id));
        }
        system.debug('4870 - SinistroService.criarGarantia - lsPagamentoGarantia ' + lsPagamentoGarantia);

        insert lsPagamentoGarantia;
        //PLV-4509 - inicio  
        criarBeneficiario(lsPagamentoGarantia);    
        //PLV-4509 - Fim  

        //PLV-4509 - Remover esta parte do codigo - Inicio  
        /*BeneficiarioGarantia__c[] listaBeneficiario = new BeneficiarioGarantia__c[]{};
        for(PagamentoGarantia__c garantia : lsPagamentoGarantia){        
            listaBeneficiario.add( new BeneficiarioGarantia__c(
                Conta__c                     = this.parametroEntrada.ContaPrestadora.conta__c, //PLV-4094 - INICIO/FIM
                Pagamento_de_garantia__c     = garantia.Id,
                Status__c                    = 'Pendente',
                InformarIndenizacao__c       = 'Valor de Indenização', //PLV-4070 - INICIO/FIM
                //Percentual_de_indenizacao__c = garantia.Valor_indenizado__c / garantia.Capital__c * 100, //PLV-4070 - INICIO/FIM
                ValorIndenizacao__c          = garantia.Valor_indenizado__c,
                CurrencyIsoCode              = garantia.CurrencyIsoCode, //PLV-4070 - INICIO/FIM
                Tipo_de_Pagamento__c         = 'Transferencia Bancaria para Conta Corrente' //PLV-4070_FIX - INICIO/FIM
            ));
        }

        insert listaBeneficiario;*/
        //PLV-4509 - Remover esta parte do codigo - Fim  
        
    }
	
    //PLV-4037 - INÍCIO   
    @future
    public static void movimentoSinistro(Id caseId){
        CasoBO bo = CasoBO.getInstance();

        Recordtype REC_ID_SINISTRO = RecordTypeBO.buscarTipoRegistro('Case', 'Sinistro');

        bo.atualizaAvisadoMovimentoSinistro(
            new Case[]{
                new Case( Id = caseId, Status = 'Avisado', RecordTypeId = REC_ID_SINISTRO.Id)
            },
            new Map<Id, Case> {
                caseId => new Case( Id = caseId, Status = 'Avisar')
            }
        );
    }
    //PLV-4870 - Inicio
    public static string formatarDocumento (string itemFormatar){
        String retorno;
        if(itemFormatar != '' && itemFormatar != null){
            if(itemFormatar.length() == 11){
                retorno = itemFormatar.substring(0, 3) + '.' + itemFormatar.substring(3, 6) + '.' + itemFormatar.substring(6, 9) + '-' + itemFormatar.substring(9, 11); 
    
            }else if(itemFormatar.length() == 14){
                retorno = itemFormatar.substring(0, 2) + '.' + itemFormatar.substring(2, 5) + '.' + itemFormatar.substring(5, 8) + '/' + itemFormatar.substring(8, 12) + '-' + itemFormatar.substring(12, 14); 
    
            }else{
                retorno = itemFormatar;
            }
        }

        return retorno;
    }
    //PLV-4870 - Fim
    //PLV-4037 - FIM   
    //PLV-4094 - TRECHO DE CÓDIGO REMOVIDO -    
}