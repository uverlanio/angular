public class CriticasFacade 
{
	private final String                    ORIGEM_CRITICA_ODM             = 'ODM';
    private final String                    ORIGEM_CRITICA_SINAPSE         = 'Sinapse';
    private final String                    ORIGEM_CRITICA_SAP             = 'SAP';
    private final String                    ORIGEM_CRITICA_PROTOCOLO_WEB   = 'Protocolo Web';
    private final String                    STATUS_CRITICA_PENDENTE        = 'Pendente';
    private final String                    TIPO_CRITICA_AVISOS            = 'Aviso';
    private final String                    TIPO_CRITICA_PENDENCIAS        = 'Pendencia';
    private final String                    TIPO_CRITICA_ANALISES          = 'Analise';
    private final String                    TIPO_CRITICA_RECUSAS           = 'Recusa';
    private final String                    TIPO_CRITICA_SAP               = 'CriticaSAP';
	private final Map<String, String>       mapRecordTypeRef               = new Map<String, String> { 'VG'  => 'VidaGrupo',       'VI'   => 'VidaIndividual' };
	private final Map<String, RecordType>   mapRecordType                  = new Map<String, RecordType>();


	private static final CriticasFacade classInstance;
    static { classInstance = new CriticasFacade(); }
    private CriticasFacade() {}
    public static CriticasFacade getInstance() { return classInstance; }

	
    //mapeia to p/ objeto de critica passando a proposta como chave pai
    public List<CriticaProposta__c> parseCriticasRetornoAceitacaoTO(EmissaoTO.RetornoaceitacaoTO retornoAceitacao, Id propostaId, String origem)
    {
        List<CriticaProposta__c> lstRetorno = new List<CriticaProposta__c>();

        //obtem os tipos de registro do objeto
        for(RecordType tipo: RecordTypeDAO.getInstance().getListRecordTypeBySobject('CriticaProposta__c'))
            mapRecordType.put(tipo.DeveloperName, tipo);

        //Analises
        lstRetorno.addAll(parseCriticasRetornoAceitacaoAnaliseTO(retornoAceitacao.analises, propostaId, origem, 'Pendente'));

        //Avisos
        lstRetorno.addAll(parseCriticasRetornoAceitacaoAvisoTO(retornoAceitacao.avisos, propostaId, origem, 'Liberado'));

        //Recusas
        lstRetorno.addAll(parseCriticasRetornoAceitacaoRecusaTO(retornoAceitacao.recusas, propostaId, origem, 'Recusado'));

        //Pendencias
        lstRetorno.addAll(parseCriticasRetornoAceitacaoPendeciaTO(retornoAceitacao.pendencias, propostaId, origem, 'Em aprovação'));

        //Criticas SAP... A definir

        return lstRetorno;
    }

    public List<CriticaProposta__c> parseCriticasRetornoAceitacaoAnaliseTO(List<EmissaoTO.AnaliseTO> analises, Id propostaId, String origem, String status)
    {
        List<CriticaProposta__c> lstRetorno = new List<CriticaProposta__c>();

        if(analises != null)
        {
            for(EmissaoTO.AnaliseTO analise : analises)
            {
                CriticaProposta__c critcaProposta = new CriticaProposta__c();

                critcaProposta.Proposta__c              = String.valueOf(propostaId);
                critcaProposta.Tipo__c                  = TIPO_CRITICA_ANALISES;
                critcaProposta.Status__c                = status;
                critcaProposta.Origem__c                = Origem;
                critcaProposta.Codigo__c                = String.valueOf(analise.codigo);
                critcaProposta.Area__c                  = analise.area;
                critcaProposta.Procedimento__c          = analise.procedimento; //INICIO/FIM | PLV-4647-VI-Guilherme Brito
                // INICIO | PLV-2402-30
                critcaProposta.Descricao__c             = analise.descricao;
                // FIM | PLV-2402-30
                critcaProposta.Severidade__c            = analise.severidade;

                // Mensagens...
                if(analise.mensagens != null)
                {

                    // INICIO | PLV-4647-VI-Guilherme Brito
                    critcaProposta.MensagemRepresentante__c = analise.mensagens.representante;
                    critcaProposta.MensagemInterna__c       = analise.mensagens.interna;
                    critcaProposta.MensagemCliente__c       = analise.mensagens.cliente;
                    //FIM| PLV-4647-VI-Guilherme Brito */
                    //PLV-4854-FIX6 - inicio
                    DateTime now = System.now();                    
                    if(critcaProposta.ErrosRecalculo__c != null){
						critcaProposta.ErrosRecalculo__c 	     = now.format( 'dd/MM/yyyy HH:mm:ss' ) + ': ' + analise.mensagens.interna + '\n' +  critcaProposta.ErrosRecalculo__c; //PLV-4854-FIX1 - inicio/fim                                                    
                    }else{
						critcaProposta.ErrosRecalculo__c 	     = now.format( 'dd/MM/yyyy HH:mm:ss' ) + ': ' + analise.mensagens.interna + '\n'; //PLV-4854-FIX1 - inicio/fim                                                    
                    }
                    //PLV-4854-FIX6 - fim
                    
                }
                // critcaProposta.DataConclusao__c      = lstRetorno.add(critcaProposta);

                lstRetorno.add(critcaProposta);
            }
        }
        return lstRetorno;
    }

    public List<CriticaProposta__c> parseCriticasRetornoAceitacaoAvisoTO(List<EmissaoTO.AvisoTO> avisos, Id propostaId, String origem, String status)
    {
        List<CriticaProposta__c> lstRetorno = new List<CriticaProposta__c>();

        if(avisos != null)
        {
            for(EmissaoTO.AvisoTO aviso : avisos)
            {
                CriticaProposta__c critcaProposta = new CriticaProposta__c();

                critcaProposta.Proposta__c              = String.valueOf(propostaId);
                critcaProposta.Tipo__c                  = TIPO_CRITICA_AVISOS;
                critcaProposta.Status__c                = status;
                critcaProposta.Origem__c                = Origem;
                critcaProposta.Codigo__c                = String.valueOf(aviso.codigo);
                critcaProposta.Area__c                  = aviso.area;
                critcaProposta.Procedimento__c          = aviso.procedimento; //INICIO/FIM | PLV-4647-VI-Guilherme Brito
                // INICIO | PLV-2402-30
                critcaProposta.Descricao__c             = aviso.descricao;
                // FIM | PLV-2402-30
                critcaProposta.Severidade__c            = aviso.severidade;

                // Mensagens...
                if(aviso.mensagens != null)
                {

                    // INICIO | PLV-4647-VI-Guilherme Brito
                    critcaProposta.MensagemRepresentante__c = aviso.mensagens.representante;
                    critcaProposta.MensagemInterna__c       = aviso.mensagens.interna;
                    critcaProposta.MensagemCliente__c       = aviso.mensagens.cliente;
                    //FIM| PLV-4647-VI-Guilherme Brito */
                    DateTime now = System.now();//PLV-4854-FIX1 - inicio/fim
                    critcaProposta.ErrosRecalculo__c = now.format( 'dd/MM/yyyy HH:mm:ss' ) + ': ' + aviso.mensagens.interna + '\n'; //PLV-4854-FIX1 - inicio/fim                                                        
                    

                }
                // critcaProposta.DataConclusao__c      =

                lstRetorno.add(critcaProposta);
            }
        }

        return lstRetorno;
    }

    public List<CriticaProposta__c> parseCriticasRetornoAceitacaoRecusaTO(List<EmissaoTO.RecusaTO> recusas, Id propostaId, String origem, String status)
    {
        List<CriticaProposta__c> lstRetorno = new List<CriticaProposta__c>();
        if(recusas != null)
        {
            for(EmissaoTO.RecusaTO recusa : recusas)
            {
                CriticaProposta__c critcaProposta = new CriticaProposta__c();

                critcaProposta.Proposta__c              = String.valueOf(propostaId);
                critcaProposta.Tipo__c                  = TIPO_CRITICA_RECUSAS;
                critcaProposta.Status__c                = status;
                critcaProposta.Origem__c                = Origem;
                critcaProposta.Codigo__c                = String.valueOf(recusa.codigo);
                critcaProposta.Area__c                  = recusa.area;
                critcaProposta.Procedimento__c          = recusa.procedimento; //INICIO/FIM | PLV-4647-VI-Guilherme Brito
                critcaProposta.Descricao__c             = recusa.descricao;
                critcaProposta.Severidade__c            = recusa.severidade;
                critcaProposta.DataConclusao__c         = Date.today();

                // Mensagens...
                if(recusa.mensagens != null)
                {

                    // INICIO | PLV-4647-VI-Guilherme Brito
                    critcaProposta.MensagemRepresentante__c = recusa.mensagens.representante;
                    critcaProposta.MensagemInterna__c       = recusa.mensagens.interna;
                    critcaProposta.MensagemCliente__c       = recusa.mensagens.cliente;
                    //FIM| PLV-4647-VI-Guilherme Brito
                    DateTime now = System.now();//PLV-4854-FIX1 - inicio/fim
                    critcaProposta.ErrosRecalculo__c = now.format( 'dd/MM/yyyy HH:mm:ss' ) + ': ' + recusa.mensagens.interna + '\n'; //PLV-4854-FIX1 - inicio/fim                                                        

                }
                // critcaProposta.DataConclusao__c      =


                lstRetorno.add(critcaProposta);
            }
        }

        return lstRetorno;
    }

    public List<CriticaProposta__c> parseCriticasRetornoAceitacaoPendeciaTO(List<EmissaoTO.PendenciaTO> pendencias, Id propostaId, String origem, String status)
    {
        List<CriticaProposta__c> lstRetorno = new List<CriticaProposta__c>();
        if(pendencias != null)
        {
            for(EmissaoTO.PendenciaTO pendencia : pendencias)
            {
                CriticaProposta__c critcaProposta = new CriticaProposta__c();

                critcaProposta.Proposta__c              = String.valueOf(propostaId);
                critcaProposta.Tipo__c                  = TIPO_CRITICA_PENDENCIAS;
                critcaProposta.Status__c                = status;
                critcaProposta.Origem__c                = Origem;
                critcaProposta.Codigo__c                = String.valueOf(pendencia.codigo);
                critcaProposta.Area__c                  = pendencia.area;
                critcaProposta.Procedimento__c          = pendencia.procedimento; //INICIO/FIM | PLV-4647-VI-Guilherme Brito
                critcaProposta.Descricao__c             = pendencia.descricao;
                critcaProposta.Severidade__c            = pendencia.severidade;

                // Mensagens...
                if(pendencia.mensagens != null)
                {

                    //INICIO | PLV-4647-VI-Guilherme Brito
                    critcaProposta.MensagemRepresentante__c = pendencia.mensagens.representante;
                    critcaProposta.MensagemInterna__c       = pendencia.mensagens.interna;
                    critcaProposta.MensagemCliente__c       = pendencia.mensagens.cliente;
                    //FIM| PLV-4647-VI-Guilherme Brito
                    DateTime now = System.now();//PLV-4854-FIX1 - inicio/fim
                    critcaProposta.ErrosRecalculo__c = now.format( 'dd/MM/yyyy HH:mm:ss' ) + ': ' + pendencia.mensagens.interna + '\n'; //PLV-4854-FIX1 - inicio/fim                                                        
                }

                lstRetorno.add(critcaProposta);
            }
        }

        return lstRetorno;
    }

    public List<CriticaProposta__c> criaPendenciasProposta(List<EmissaoTO.PendenciaTO> pendencias, Id chaveProposta)
    {
        List<CriticaProposta__c> pendenciasProposta = new List<CriticaProposta__c>();

        if(pendencias != null)
        {
            for(EmissaoTO.PendenciaTO pendenciaTO : pendencias)
            {
                try
                {
                    pendenciasProposta.add(
                        new CriticaProposta__c (
                                                    Proposta__c     = chaveProposta,
                                                    Codigo__c       = String.valueOf(pendenciaTO.identificacao), 
                                                    Descricao__c    = pendenciaTO.descricao 
                                                )
                    );
                }
                catch(Exception e)
                {
                    System.debug('Erro CriticasRetornoAceitacao proposta: ' + e.getCause() + ' - ' +  e.getLineNumber() + ': ' + e.getMessage());
                    throw new PropostaException('Erro CriticasRetornoAceitacao proposta: ' + e.getCause() + ' - ' +  e.getLineNumber() + ': ' + e.getMessage());
                }
            }
        }

        return pendenciasProposta;
    }
    
    public class PropostaException extends Exception {}
}