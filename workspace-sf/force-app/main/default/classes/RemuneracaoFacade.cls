public class RemuneracaoFacade 
{
	private final String                    PESSOA_FISICA                  = 'FIS';
    private final String                    PESSOA_JURIDICA                = 'JUR';
	private final String                    PAPEL_CORRETOR                 = 'COR';
    private final String                    PAPEL_AGENCIADOR               = 'AGE';
    private final String                    PAPEL_REPRESENTANTE            = 'REP';
    private final String                    PAPEL_ASSESSORIA               = 'ASS';
    private final String                    ORIGEM_CRITICA_ODM             = 'ODM';
    private final String                    ORIGEM_CRITICA_SINAPSE         = 'Sinapse';
    private final String                    STATUS_CRITICA_PENDENTE        = 'Pendente';

    private final Map<String, String> mapPapeis = new Map<String, String> { 'REP' => 'RepresentanteSeguros', 'COR' => 'Corretor', 'PRE'  => 'Prestador', 'AGE'  => 'Agenciador', 'PAR'  => 'Parceiro' };

	private static final RemuneracaoFacade classInstance;
    static { classInstance = new RemuneracaoFacade(); }
    private RemuneracaoFacade() {}
    public static RemuneracaoFacade getInstance() { return classInstance; }

    public List<RemuneracaoOrcamento__c> criaRemuneracaoOrcamento(String meioComercializacao, List<EmissaoTO.RemuneracaoTO> remuneracoes, Id idOrcamento, List<RemuneracaoProdutoParceiro__c> listaRemuneracaoParceiro, Map<String, Account> mapContas, Map<String, TipoRemuneracao__c> mapTiposRemuneracao)
    {
        List<RemuneracaoOrcamento__c> remuneracoesOrcamento = new List<RemuneracaoOrcamento__c>();

        for(RemuneracaoProdutoParceiro__c remPar : listaRemuneracaoParceiro)
        {
            system.debug('criaRemuneracaoOrcamento >> remPar' + remPar);
            RemuneracaoOrcamento__c  remuneracaoSF  = new RemuneracaoOrcamento__c();
            remuneracaoSF.Oportunidade__c           = idOrcamento;
            remuneracaoSF.TipoRemuneracao__c        = remPar.TipoRemuneracao__c;
            remuneracaoSF.Percentual__c             = remPar.Percentual__c;

            remuneracoesOrcamento.add(remuneracaoSF);
        }   
        
        return remuneracoesOrcamento;
    }


    // monta uma lista  de remunerações da proposta baseado no peyload recebido via integração
    public List<RemuneracaoProposta__c> criaRemuneracaoProposta(List<EmissaoTO.RemuneracaoTO> remuneracoes, Id idProposta, Map<String, TipoRemuneracao__c> mapTiposRemuneracao)
    {
        List<RemuneracaoProposta__c> remuneracoesProposta = new List<RemuneracaoProposta__c>();

        for(EmissaoTO.RemuneracaoTO remuneracao : remuneracoes)
        {
            TipoRemuneracao__c tipoRem = mapTiposRemuneracao.get(remuneracao.tipoRemuneracao);

            if(tipoRem == null)
                throw new PropostaException('Tipo remuneracao não encontrada: (' + remuneracao.tipoRemuneracao + ')');

            system.debug('criaRemuneracaoProposta >> tipoRemuneracao: ' + tipoRem);
            RemuneracaoProposta__c remuneracaoSF = new RemuneracaoProposta__c();
            remuneracaoSF.TipoRemuneracao__c     = tipoRem.Id;
            remuneracaoSF.Proposta__c            = idProposta;
            remuneracaoSF.Percentual__c          = remuneracao.percentual;

            remuneracao.ojSFProposta = remuneracaoSF;
            remuneracoesProposta.add(remuneracaoSF);
            
        }
        system.debug('criaRemuneracaoProposta >> remuneracoesProposta: ' + remuneracoesProposta);
        return remuneracoesProposta;
    } 

    // PLV-2352-29 INICIO
    // monta uma lista  de remunerações da proposta 
    // Ccria os favorecidos da remunerãçao da proposta de acordo com os favorecidos da remuneração baseado no peyload recebido via integração
    public List<FavorecidoRemuneracaoProposta__c> criaFavorecidosRemuneracaoProposta(List<EmissaoTO.RemuneracaoTO> remuneracoes, Map<String, Account> mapContas, Map<String, DadosCorretor__c> mapDadosCorretor, Map<String, Account> mapContasNaoAtualizar)
    {

        List<FavorecidoRemuneracaoProposta__c> favorecidosProposta = new List<FavorecidoRemuneracaoProposta__c>();

        for(EmissaoTO.RemuneracaoTO remuneracao : remuneracoes)
        {
            for(EmissaoTO.FavorecidoTO favorecido : remuneracao.favorecidos)
            {
                FavorecidoRemuneracaoProposta__c favorecidoSf = new FavorecidoRemuneracaoProposta__c();
                String idExternoRef;
                Account conta;
                DadosCorretor__c dadosCorretor;

                if(favorecido.pessoa.tipo == PESSOA_JURIDICA)
                    idExternoRef = favorecido.pessoa.dadosPessoaJuridica.numeroCnpj + favorecido.pessoa.dadosPessoaJuridica.ordemCnpj + favorecido.pessoa.dadosPessoaJuridica.digitoCnpj;
                else if(favorecido.pessoa.tipo == PESSOA_FISICA)
                    idExternoRef = favorecido.pessoa.dadosPessoaFisica.numeroCpf + favorecido.pessoa.dadosPessoaFisica.digitoCpf;

                conta = mapContas.get(idExternoRef);
                if(conta != null){
                    favorecidoSf.Conta__c  = conta.Id;
                    mapContasNaoAtualizar.put(conta.IdExterno__c, conta);

                }
                // PLV-2352-29 FIM

                dadosCorretor = mapDadosCorretor.get(favorecido.susep);
                //PLV-5235 - FIX01 - INICIO
                if(dadosCorretor != null) {
                    favorecidoSF.DadosCorretor__c = dadosCorretor.Id;
                    favorecidoSF.SusepOficialCorretor__c = dadosCorretor.SusepOficialCorretor__c; 
                }
                else {
                    favorecidoSF.SusepOficialCorretor__c = favorecido.susepOficialCorretor;
                }
                //PLV-5235 - FIX01 - FIM
                
                FavorecidoSf.RemuneracaoProposta__c = remuneracao.ojSFProposta.Id;
                favorecidoSF.Papel__c = mapPapeis.get(favorecido.papel);
                favorecidoSF.Participacao__c = favorecido.participacao;
                favorecidoSF.CorretorLider__c = favorecido.corretorLider == true ? true: false;
                favorecidoSF.Susep__c = favorecido.susep;
                favorecidoSF.SusepEmissao__c = favorecido.susepEmissao;
                //favorecidoSF.SusepOficialCorretor__c = favorecido.susepOficialCorretor; //PLV-5235 - INICIO/FIM
                //favorecidoSF.SusepOficialCorretor__c = dadosCorretor.SusepOficialCorretor__c; //PLV-5235 - INICIO/FIM   //PLV-5235 - FIX01 - INICIO/FIM
                favorecidoSF.SusepOrcamento__c = favorecido.susepOrcamento;
                favorecidosProposta.add(favorecidoSf);
            }
        }

        return favorecidosProposta;
    } 

	public class PropostaException extends Exception {}
}