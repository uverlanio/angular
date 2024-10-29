/********************************************************************************************************************************
* Consulta dados de Proposta
* @author Carlos - Meta
* @date 30/07/2020
* Classe criada por conta da história PLV-4205
******************************************************************************************************************************/
public with sharing class ConsultaPropostaService {

    private ConsultaPropostaADMREST.ConsultaParam param;

    public ConsultaPropostaService(ConsultaPropostaADMREST.ConsultaParam param) {
        this.param = param;
    }

    public ConsultaPropostaADMREST.DataTO consultar(){
        ConsultaPropostaADMREST.DataTO resposta =  new ConsultaPropostaADMREST.DataTO();
        //PLV-4304 - INICIO - Ajuste na query
        //PLV-4352 - YURI - INÍCIO
        //PLV-4197 Inicio
        System.debug('Entrou consultar' + JSON.serialize(this.param));
        
        //PLV-4928 - INICIO (Refactor do codigo anterior - Haviam 3 query repetidas)
        //PLV-5436 - INCIO
        String SOQL = 'SELECT Id, NumeroProposta__c, Origem__c, Segmento__c, Account.Name, Account.NomeSocial__c, Account.Cpf__c, Status, Produto__r.Name, Produto__c,' //II-124 FIX01 INICIO-FIM & LECVPV-177 - INICIO/FIM
            + 'Produto__r.CodigoPrecificaProduto__c, VigenciaInicial__c, VigenciaFinal__c, FormaPagamento__r.Name, VoucherPdfDownloadUrl__c, '
            + 'DataStatusAguardandoAnalise__c,DataStatusEmAnalise__c,DataStatusDisponivelContratacao__c,DataStatusContratada__c,  '
            + 'Link_expirado__c, Link_Questionario_Samplemed__c, Id_do_Proponente__c, Hora_Expiracao_Link__c, ' //FNPVVEP-98 - INICIO/FIM - FIX
            + 'DataStatusDevolvida__c,DataStatusRecusada__c,DataFaseStatus__c,FaseStatus__c, CodigoMotivoDevolucao__c, ' //II-48 INICIO-FIM
            + '(SELECT Id,Area__c,Codigo__c,Descricao__c, MensagemCliente__c,MensagemInterna__c,MensagemRepresentante__c, '
            + 'Origem__c,Status__c,Tipo__c FROM CriticasProposta__r), CreatedDate, '
            + 'Account.PersonEmail, Account.PersonHomePhone, Account.Phone, Account.PersonMobilePhone '
            + 'FROM Quote WHERE NumeroProposta__c != null ';
        //PLV-5436 - FIM

        String SOQLOrderLimit = 'Order by CreatedDate DESC '
            + 'LIMIT 1000';
        
        if(String.isNotBlank(param.idCanal)){
            String idCanal = param.idCanal;
            SOQL += 'AND CodigoCorretor__r.Name =: idCanal ';
        }

        if(String.isNotBlank(param.canal)){
            String canal = param.canal;
            SOQL += 'AND CanalDistribuicao__r.Name =: canal ';
        }

        //II-124 FIX01 INICIO
        if(String.isNotBlank(param.codigoOferta)){
            String oferta = param.codigoOferta.toUpperCase();
            Set<String> ofertas = new Set<String>{oferta};
            List<Constante__mdt> produto = MetadataDAO.getInstance().buscarConstantes(ofertas);
            if (produto != null && !produto.isEmpty()) {
                String idProduto = produto[0].Valor__c;
                Set<String> idProdutoSet = new Set<String>(idProduto.split(','));
                SOQL += 'AND Produto__c IN : idProdutoSet ';
            }
        }   
        //II-124 FIX01 FIM

        if(String.isNotBlank(param.origem) || String.isNotBlank(param.proposta)){
            String nomeProposta = this.param.origem + '-' + this.param.proposta;
            SOQL += 'AND Name =: nomeProposta ';
        }

        if(String.isNotBlank(this.param.quantidadeDeMeses)){
            Date dataCalculada = Date.valueOf(System.today().addMonths(- Integer.valueOf(this.param.quantidadeDeMeses)));
            SOQL += 'AND DataEmissao__c >=: dataCalculada ';
        }

        if(String.isNotBlank(this.param.cpfContratante)){ 
            String cpfTratado = this.param.cpfContratante.contains('.') ? this.param.cpfContratante : Util.imprimeCPF(this.param.cpfContratante);
            SOQL += 'AND Account.Cpf__c =: cpfTratado ';
        }

        if(String.isNotBlank(this.param.nomeSegurado)){
            String nomeSegurado = '%' + this.param.nomeSegurado + '%';
            SOQL += 'AND Account.Name LIKE :nomeSegurado ';
        }
        
        if(String.isNotBlank(this.param.numeroProposta)){
            String numeroProposta = this.param.numeroProposta;
            SOQL += 'AND Name =: numeroProposta ';
        }
        
        if(String.isNotBlank(this.param.dataProposta)) {
            Date dataProposta = Date.parse(this.param.dataProposta);
            SOQL += 'AND DAY_ONLY(CreatedDate) =: dataProposta ';
        }

        SOQL += SOQLOrderLimit;
        System.debug('Antes de montar o model');
        resposta.propostas = this.atribuirModel(new List<Quote>((Quote[]) Database.query(SOQL))); 
        //PLV-4928 - FIM  

		//PLV-4352 - FIM
        //PLV-4304 - FIM
		//PLV-4197 Fim

        resposta.statusChamada = 200;
        System.debug('resposta.propostas '+resposta.propostas);
        System.debug('resposta ><>'+resposta);
        return resposta;
    }

    private List<ConsultaPropostaADMREST.ConsultaPropostaTO> atribuirModel(List<Quote> propostas){
        System.debug('Entrou model');
        List<ConsultaPropostaADMREST.ConsultaPropostaTO> retorno = new List<ConsultaPropostaADMREST.ConsultaPropostaTO>();
        Map<String, Decimal> mapContratanteProposta = new Map<String, Decimal>();
        for(ContratanteProposta__c contratante : [SELECT Id, QuantidadeParcelas__c, Proposta__c FROM ContratanteProposta__c where Proposta__c IN: propostas]){
            mapContratanteProposta.put(contratante.Proposta__c, contratante.QuantidadeParcelas__c);
        }

        //PLV-5024 - INICIO
        String [] tipoRemuneracaoArray = new List<String>();
		tipoRemuneracaoArray.add('CORRETAGEM');
        Map<String, String> mapFavorecidoRemuneracao = new Map<String, String>();
        Map<String, Map<FavorecidoRemuneracaoProposta__c, String>> mapFavorecidoRemuneracao2 = new Map<String, Map<FavorecidoRemuneracaoProposta__c, String>>();
        Map<Id, FavorecidoRemuneracaoProposta__c> favorecidoRemuneracaoIndexByQuoteId = new Map<Id, FavorecidoRemuneracaoProposta__c>();
        
        //PLV-5493 - INICIO
        for(FavorecidoRemuneracaoProposta__c favorecido : [
            SELECT Id, Susep__c, Conta__r.Email__c, RemuneracaoProposta__r.Proposta__c,CorretorLider__c,CelularCorretor__c 
            FROM FavorecidoRemuneracaoProposta__c 
            WHERE RemuneracaoProposta__r.TipoRemuneracao__r.Name IN: tipoRemuneracaoArray 
            AND RemuneracaoProposta__r.Proposta__c IN: propostas])
        {
            //II-208 FIX01 INICIO 
            if(favorecido.CorretorLider__c){
                String dadosCorretor = favorecido.Susep__c + '@@' + favorecido.Conta__r.Email__c + '@@' + favorecido.CelularCorretor__c; //II-208 INICIO/FIM

                mapFavorecidoRemuneracao.put(favorecido.RemuneracaoProposta__r.Proposta__c, dadosCorretor);
            }
            //II-208 FIX01 FIM 

            System.debug('XXX - mapFavorecidoRemuneracao2: ' + JSON.serialize(mapFavorecidoRemuneracao));
        }

        System.debug('HENRIQUE - MAP FAVORECIDO: ' + mapFavorecidoRemuneracao);

        System.debug('XXX - mapFavorecidoRemuneracao3: ' + JSON.serialize(mapFavorecidoRemuneracao));
        //PLV-5493 - FIM
        //PLV-5024 - FIM

        //II-12 INCIO
        System.debug('Antes do quoteHistory');
        Set<Id> quoteIds = new Set<Id>();
        for(Quote qt: propostas){
            quoteIds.add(qt.Id);
        }

        List<CriticaProposta__History> subStatusHistory = [SELECT Id, Parent.Proposta__r.id, Parent.Status__c,Parent.Name, 
                                                Parent.MomentoAnalise__c,  
                                                CreatedDate, OldValue, NewValue, Field 
                                                FROM CriticaProposta__History 
                                                WHERE Parent.Proposta__r.id IN : quoteIds
                                                AND Field = 'Status__c'
                                                ORDER BY CreatedDate ASC];

        System.debug('subStatusHistory = ' + subStatusHistory);
        //II-12 FIX03 INCIO
        Map<Id, List<String>> subStatusHistoryByQuoteNew = new Map<Id, List<String>>(); 
        
        for(CriticaProposta__History qtHistory : subStatusHistory){
            if(!subStatusHistoryByQuoteNew.containsKey(qtHistory.Parent.Proposta__r.id)){
                System.debug('Entrou if new');
                subStatusHistoryByQuoteNew.put(
                    qtHistory.Parent.Proposta__r.id,
                    new List<String>()
                );
            }
 
            if(qtHistory.NewValue != null){
                System.debug('qtHistory.NewValue = ' + qtHistory.NewValue);
                String valorNewQuote = qtHistory.Parent.MomentoAnalise__c + ' - ' + String.valueOf(qtHistory.NewValue) + ' - ' + String.valueOf(qtHistory.CreatedDate);
                valorNewQuote = valorNewQuote.replace('(', '').replace(')', '');
                subStatusHistoryByQuoteNew.get(qtHistory.Parent.Proposta__r.id).add(valorNewQuote);
            }
            else {
                continue;
            }               
        }
        //II-12 FIX03 FIM
        //II-12 - FIM

        //FNPVVEP-22 INICIO
        Set<String> numerosPropostaContratadas = new Set<String>();

        for(Quote proposta : propostas){
            if (proposta.Status == 'Contratada') {
                numerosPropostaContratadas.add(proposta.NumeroProposta__c);
            }
        }

        List<Contract> contratos = [
            SELECT Id, ApolicePdfDownloadUrl__c, EndossoPdfDownloadUrl__c, NumeroProposta__c
            FROM Contract
            WHERE NumeroProposta__c IN :numerosPropostaContratadas
            AND Origem__c = '18'
        ];

        for(Quote proposta : propostas){
            ConsultaPropostaADMREST.ConsultaPropostaTO propostaModel = new ConsultaPropostaADMREST.ConsultaPropostaTO();

            for (Contract contrato : contratos) {
                if (contrato.NumeroProposta__c == proposta.NumeroProposta__c) {
                    propostaModel.apolicePdfDownloadUrl = contrato.ApolicePdfDownloadUrl__c;
                    propostaModel.endossoPdfDownloadUrl = contrato.EndossoPdfDownloadUrl__c;
                    break;
                }
            }
            //FNPVVEP-22 FIM
            propostaModel.numeroProposta = Integer.valueOf(proposta.NumeroProposta__c);
            propostaModel.origemProposta = Integer.valueOf(proposta.Origem__c); 
            propostaModel.nomeCliente = proposta.Account.Name;
            propostaModel.nomeSocial = proposta.Account.NomeSocial__c; //LECVPV-177 - INICIO/FIM
            propostaModel.cpfCliente = proposta.Account.Cpf__c;
            propostaModel.status = proposta.Status;
            propostaModel.produto = proposta.Produto__r.Name;
            propostaModel.inicioVigencia = String.valueOf(proposta.VigenciaInicial__c);
            propostaModel.fimVigencia = String.valueOf(proposta.VigenciaFinal__c);
            propostaModel.formaPagamento = proposta.FormaPagamento__r.Name;
            propostaModel.quantidadeParcelas = mapContratanteProposta.get(proposta.Id) != null ? Integer.valueOf(mapContratanteProposta.get(proposta.Id)) : null;
            //PLV-4605 - inicio
            propostaModel.email 				= proposta.Account.PersonEmail;
            propostaModel.telefoneresidencial 	= proposta.Account.PersonHomePhone;
            propostaModel.telefonecomercial 	= proposta.Account.Phone;
            propostaModel.telefonecelular 		= proposta.Account.PersonMobilePhone; 
            //PLV-4605 - fim        

            //FNPVVEP-98 INICIO
            propostaModel.idDoProponente = proposta.Id_do_Proponente__c != null ? proposta.Id_do_Proponente__c : null;
            propostaModel.linkExpirado = proposta.Link_expirado__c;
            propostaModel.linkQuestionarioSamplemed = proposta.Link_Questionario_Samplemed__c != null ? proposta.Link_Questionario_Samplemed__c : null;
            propostaModel.horaExpiracaoLink = proposta.Hora_Expiracao_Link__c != null ? proposta.Hora_Expiracao_Link__c : null;//FNPVVEP-98 - INICIO/FIM - FIX
            //FNPVVEP-98 FIM
            //PLV-5024 - INICIO  
            //PLV-5058 INICIO  
            propostaModel.susepCorretor = mapFavorecidoRemuneracao.get(proposta.Id) != null ? (mapFavorecidoRemuneracao.get(proposta.Id)).split('@@')[0] : null;
            propostaModel.emailCorretor = mapFavorecidoRemuneracao.get(proposta.Id) != null ? (mapFavorecidoRemuneracao.get(proposta.Id)).split('@@')[1] : null;
            propostaModel.corretorCelular = mapFavorecidoRemuneracao.get(proposta.Id) != null ? (mapFavorecidoRemuneracao.get(proposta.Id)).split('@@')[2] : null; //PLV-5493 - INICIO/FIM

            //PLV-5058 FIM             
            //PLV-5024 - FIM
            
            //PLV-5528 - INCIO
            propostaModel.segmento              = String.valueOf(proposta.Segmento__c);
            propostaModel.codigoPrecificacao    = String.valueOf(proposta.Produto__r.CodigoPrecificaProduto__c);
            propostaModel.motivoRecusa          = proposta.CodigoMotivoDevolucao__c != null ? Integer.valueOf(proposta.CodigoMotivoDevolucao__c) : null; //II-48 INICIO-FIM
            //PLV-5528 - FIM

            //PLV-5436 - INCIO
            propostaModel.statusCriacao = String.valueOf(proposta.CreatedDate);
            propostaModel.statusAguardaAnalise = proposta.DataStatusAguardandoAnalise__c != null ? String.valueOf(proposta.DataStatusAguardandoAnalise__c) : null;
            propostaModel.statusAnalise = proposta.DataStatusEmAnalise__c !=null ? String.valueOf(proposta.DataStatusEmAnalise__c) : null;
            propostaModel.statusDispContratacao = proposta.DataStatusDisponivelContratacao__c != null ? String.valueOf(proposta.DataStatusDisponivelContratacao__c) : null;
            propostaModel.statusContratada = proposta.DataStatusContratada__c != null ? String.valueOf(proposta.DataStatusContratada__c) : null;
            propostaModel.statusDevolvida = proposta.DataStatusDevolvida__c != null ? String.valueOf(proposta.DataStatusDevolvida__c) : null;
            propostaModel.statusRecusada = proposta.DataStatusRecusada__c != null ? String.valueOf(proposta.DataStatusRecusada__c) : null;
            System.debug('statusRecusada' + propostaModel.statusRecusada);

            propostaModel.faseStatusAnaliseNew = subStatusHistoryByQuoteNew.get(proposta.Id) != null ? subStatusHistoryByQuoteNew.get(proposta.Id) : null; //II-12 INICIO-FIM FIX03
            
            
            if(proposta.Status == 'Contratada')
                propostaModel.contratacaoPDF = String.isNotBlank(proposta.VoucherPdfDownloadUrl__c)? System.Label.hostSensediaAWS + +'/vida/crm/acessorios/v1/documentos/'+proposta.VoucherPdfDownloadUrl__c.subStringAfter('doGet/') : null; // MGRC-691 INICIO-FIM
            //PLV-4304 - INICIO - Ajuste no retorno do servico
            if(!proposta.CriticasProposta__r.isEmpty()){
                List<ConsultaPropostaADMREST.CriticasPropostaTO> lstCriticas = new List<ConsultaPropostaADMREST.CriticasPropostaTO>();
                for(CriticaProposta__c critica : proposta.CriticasProposta__r){
                    ConsultaPropostaADMREST.CriticasPropostaTO criticasProposta = new ConsultaPropostaADMREST.CriticasPropostaTO();
                    criticasProposta.area = critica.Area__c;
                    criticasProposta.codigo = critica.Codigo__c;
                    criticasProposta.descricao = critica.Descricao__c;

                    // INICIO | PLV-4647-VI-Guilherme Brito
                    criticasProposta.mensagemCliente = critica.MensagemCliente__c;
                    criticasProposta.mensagemInterna = critica.MensagemInterna__c;
                    criticasProposta.mensagemRepresentante = critica.MensagemRepresentante__c;
                    //FIM| PLV-4647-VI-Guilherme Brito 
                    
                    criticasProposta.origem = critica.Origem__c;
                    criticasProposta.status = critica.Status__c;
                    criticasProposta.tipo = critica.Tipo__c;

                    lstCriticas.add(criticasProposta);
                }

                propostaModel.criticas = lstCriticas;
            }                       
            
            //PLV-4304 - FIM
            retorno.add(propostaModel);
            System.debug('propostaModel >  ' + propostaModel);
        }
        System.debug('retorno >  ' + retorno);
        return retorno;
    }

    //II-32 INICIO
    public ConsultaPropostaADMREST.DataTO consultaPendencia(){
        ConsultaPropostaADMREST.DataTO resposta =  new ConsultaPropostaADMREST.DataTO();
        String status = 'Pendenciado';
        String statusProposta = 'Em análise';

        String SOQL = 'SELECT ID, Proposta__r.Name, Proposta__r.NumeroProposta__c, Proposta__r.Origem__c, Proposta__r.Produto__c, Parecer__c, Status__c, MotivoPendencia__c, Proposta__r.VigenciaInicial__c FROM CriticaProposta__c WHERE Status__c =: status AND Proposta__r.Status =: statusProposta '; //II-124 FIX01 INICIO-FIM //FNPVVEP-134 FIX01 INICIO-FIM
        
        if(String.isNotBlank(param.idCanal)){
            String idCanal = param.idCanal;
            SOQL += ' AND Proposta__r.CodigoCorretor__r.Name =: idCanal ';

        }

        //II-124 FIX01 INICIO
        if(String.isNotBlank(param.codigoOferta)){
            String oferta = param.codigoOferta.toUpperCase();
            Set<String> ofertas = new Set<String>{oferta};
            List<Constante__mdt> produto = MetadataDAO.getInstance().buscarConstantes(ofertas);
            if (produto != null && !produto.isEmpty()) {
                String idProduto = produto[0].Valor__c;
                Set<String> idProdutoSet = new Set<String>(idProduto.split(','));
                SOQL += 'AND Proposta__r.Produto__c IN : idProdutoSet ';
            }
        }
        //II-124 FIX01 FIM

        if(String.isNotBlank(this.param.cpfContratante)){ 
            String cpfTratado = this.param.cpfContratante.contains('.') ? this.param.cpfContratante : Util.imprimeCPF(this.param.cpfContratante);
            SOQL += 'AND Proposta__r.Account.Cpf__c =: cpfTratado ';
        }

        if(String.isNotBlank(this.param.numeroProposta)){
            String numeroProposta = this.param.numeroProposta;
            SOQL += 'AND Proposta__r.Name =: numeroProposta ';
        }

        System.debug('PARAM 301: ' + JSON.serialize(this.param));

        if(String.isNotBlank(this.param.dataInicio) && String.isNotBlank(this.param.dataFinal)) {
            Date dataInicio = Date.valueOf(this.param.dataInicio);
            Date dataFinal = Date.valueOf(this.param.dataFinal);
            SOQL += 'AND Proposta__r.VigenciaInicial__c >= :dataInicio AND Proposta__r.VigenciaInicial__c <= :dataFinal';
        }

        resposta.propostas = this.atribuirPendencias(new List<CriticaProposta__c>((CriticaProposta__c[]) Database.query(SOQL))); 

        resposta.statusChamada = 200;
        return resposta;

    }

    private List<ConsultaPropostaADMREST.ConsultaPropostaTO> atribuirPendencias(List<CriticaProposta__c> consultaPendencias){
        List<ConsultaPropostaADMREST.ConsultaPropostaTO> retorno = new List<ConsultaPropostaADMREST.ConsultaPropostaTO>();

            for(CriticaProposta__c critica : consultaPendencias) {
                ConsultaPropostaADMREST.ConsultaPropostaTO propostaTO = new ConsultaPropostaADMREST.ConsultaPropostaTO();
                propostaTO.numeroProposta = Integer.valueOf(critica.Proposta__r.NumeroProposta__c);
                propostaTO.origemProposta = Integer.valueOf(critica.Proposta__r.Origem__c);
                propostaTO.motivoPendencia = critica.MotivoPendencia__c;
                propostaTO.inicioVigencia = String.valueOf(critica.Proposta__r.VigenciaInicial__c); //FNPVVEP-134 FIX01 INICIO-FIM
                retorno.add(propostaTO);
            }
        return retorno;
    }
    //II-32 FIM
}