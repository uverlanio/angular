/****************************************************************************************************************************
 * Classe implementada para o serviço de consulta de contratos para parceiros                                               *
 * @author : Globant                                                                                                        *
 * @date 21/08/2023                                                                                                         *
 * Classe implementada tendo como origem a história VIAG-17                                                                 *
 * **************************************************************************************************************************/

@RestResource(urlMapping='/consultaPropostasEmitidasParceiro/*') //VIAG-17 FIX-03 INICIO/FIM
global with sharing class ConsultaParceriaService extends ServicoRestBase{
    //VIAG-17 FIX-01 INICIO
    public virtual class BaseException extends Exception {}
    public class CustomException extends BaseException {}
    //VIAG-17 FIX-01 FIM
    private static final ConsultaParceriaService instance = new ConsultaParceriaService();

    public ConsultaParceriaService() {
        super.setServicoRestBase('consultaPropostasEmitidasParceiro');   //VIAG-17 FIX-03 INICIO/FIM
    }

    @HttpPost
    global static void processarPost() 
	{
    	instance.processarServico('POST');
    }

    public override void processarServico(String metodo){
        try{
            if(metodo == 'POST'){
                //VIAG-17 FIX-01 INICIO
                RetornoAilusTO.RequestTO requestBody = (RetornoAilusTO.RequestTO) JSON.deserialize(RestContext.request.requestBody.toString(), RetornoAilusTO.RequestTO.class);
                String susep = requestBody.susep;
                Date dataInicio = Date.parse(requestBody.dataInicio);
                Date dataFim = Date.parse(requestBody.dataFim);
                
                Integer diasEntreDatas = dataInicio.daysBetween(dataFim);
                if (diasEntreDatas > 7) throw new CustomException ('Consulta excede 7 dias');
                //VIAG-17 FIX-01 FIM
                List<FavorecidoRemuneracaoContrato__c> remuneracoes = [SELECT RemuneracaoContrato__r.Contrato__r.id 
                                                                        FROM FavorecidoRemuneracaoContrato__c WHERE Susep__c =: susep
                                                                        AND RemuneracaoContrato__r.Contrato__r.DataEmissao__c >=:dataInicio //VIAG-307 - INICIO
                                                                        AND RemuneracaoContrato__r.Contrato__r.DataEmissao__c <=:dataFim]; //VIAG-307 - FIM
    
                Set<Id> idsContrato = new Set<Id>();
                for(FavorecidoRemuneracaoContrato__c remuneracao : remuneracoes){
                    idsContrato.add(remuneracao.RemuneracaoContrato__r.Contrato__r.id);
                }
    
                List<Contract> contratos = [SELECT id, Proposta__c, Proposta__r.PremioComercial__c, Proposta__r.IOF__c, Proposta__r.PremioTotal__c,Oportunidade__c, 
                                            Segmento__c, Origem__c, NumeroProposta__c, Proposta__r.Status, Proposta__r.MeioComercializacao__c, 
                                            DataEmissao__c, CodigoRamo__c, Endosso__c, Status,
                                            Sucursal__c, NumeroApolice__c, StartDate, VigenciaFinal__c, FormaPagamento__r.Codigo__c, 
                                            FormaPagamento__r.Name, ValorPremio__c, Tipo__c, TipoContrato__c, Produto__r.id, 
                                            Produto__r.ProductCode, Produto__r.Name, Oportunidade__r.CodigoCorretor__r.Name, 
                                            Oportunidade__r.CodigoCorretor__r.NomeCorretor__r.Name
                                            FROM Contract WHERE id IN: idsContrato];
    
                Set<Id> propostas = new Set<Id>();
                for(Contract contratoBuscados : contratos){
                    propostas.add(contratoBuscados.Proposta__c);
                }
    
                List<RemuneracaoProposta__c> remunceracoesOrcamentoCOR = [SELECT Id, Percentual__c, Proposta__c FROM RemuneracaoProposta__c
                                                                        WHERE Proposta__c  IN: propostas AND TipoRemuneracao__r.Codigo__c = 'COR'];
                List<RemuneracaoProposta__c> remunceracoesOrcamentoAGE = [SELECT Id, Percentual__c, Proposta__c FROM RemuneracaoProposta__c
                                                                        WHERE Proposta__c  IN: propostas AND TipoRemuneracao__r.Codigo__c = 'AGE'];
                
                Set<Id> idsRemuneracoesCOR = new Set<Id>();
                Map<Id, Id> mapRemunceracoesOrcamentoCOR = new Map<Id, Id>();
                Map<Id, Decimal> mapRemunceracoesPercentualOrcamentoCOR = new Map<Id, Decimal>();
                for(RemuneracaoProposta__c remuneracaoCOR :remunceracoesOrcamentoCOR){
                    System.debug('Danilo Id cor: ' + remuneracaoCOR.id);
                    idsRemuneracoesCOR.add(remuneracaoCOR.id);
                    mapRemunceracoesPercentualOrcamentoCOR.put(remuneracaoCOR.Proposta__c, remuneracaoCOR.Percentual__c);
                    mapRemunceracoesOrcamentoCOR.put(remuneracaoCOR.Proposta__c, remuneracaoCOR.Id);
                }

                List<FavorecidoRemuneracaoProposta__c> beneficiariosRemuneracaoCOR = [SELECT RemuneracaoProposta__c, Participacao__c, Susep__c, CorretorLider__c, Conta__r.Name 
                                                                                      FROM FavorecidoRemuneracaoProposta__c 
                                                                                      WHERE RemuneracaoProposta__c IN: idsRemuneracoesCOR];

                Set<Id> idsRemuneracoesAGE = new Set<Id>();
                Map<Id, Id> mapRemunceracoesOrcamentoAGE = new Map<Id, Id>();
                Map<Id, Decimal> mapRemunceracoesPercentualOrcamentoAGE = new Map<Id, Decimal>();
                for(RemuneracaoProposta__c remuneracaoAGE :remunceracoesOrcamentoAGE){
                    idsRemuneracoesAGE.add(remuneracaoAGE.id);
                    mapRemunceracoesPercentualOrcamentoAGE.put(remuneracaoAGE.Proposta__c, remuneracaoAGE.Percentual__c);
                    mapRemunceracoesOrcamentoAGE.put(remuneracaoAGE.Proposta__c, remuneracaoAGE.Id);
                }

                List<FavorecidoRemuneracaoProposta__c> beneficiariosRemuneracaoAGE = [SELECT RemuneracaoProposta__c, Participacao__c, Susep__c, CorretorLider__c, Conta__r.Name 
                                                                                      FROM FavorecidoRemuneracaoProposta__c 
                                                                                      WHERE RemuneracaoProposta__c IN: idsRemuneracoesAGE];

                List<SeguradoContrato__c> seguradoContratos = [SELECT GrupoContrato__r.ContratanteContrato__r.Contrato__c, GrupoContrato__r.ContratanteContrato__r.QuantidadeParcelas__c, GrupoContrato__r.ContratanteContrato__r.CpfCnpj__c, 
                                                            GrupoContrato__r.ContratanteContrato__r.Nome__c,
                                                            conta__r.Cpf__c, conta__r.Cnpj__c, conta__r.IsPersonAccount, Nome__c //VIAG-293 INICIO/FIM
                                                            FROM SeguradoContrato__c WHERE GrupoContrato__r.ContratanteContrato__r.Contrato__c IN:idsContrato];
                
                Map<Id, Decimal> mapQuantidadeParcela = new Map<Id, Decimal>();
                Map<Id, String> mapQuantidadeCpf = new Map<Id, String>();
                Map<Id, String> mapQuantidadeCnpj = new Map<Id, String>();
                Map<Id, String> mapQuantidadeNome = new Map<Id, String>();
                Map<Id, Boolean> mapQuantidadeTipoPessoa = new Map<Id, Boolean>();                
    
                for(SeguradoContrato__c segurado: seguradoContratos){
                    mapQuantidadeTipoPessoa.put(segurado.GrupoContrato__r.ContratanteContrato__r.Contrato__c, segurado.conta__r.IsPersonAccount);
                    mapQuantidadeCpf.put(segurado.GrupoContrato__r.ContratanteContrato__r.Contrato__c,segurado.conta__r.Cpf__c);
                    mapQuantidadeCnpj.put(segurado.GrupoContrato__r.ContratanteContrato__r.Contrato__c,segurado.conta__r.Cnpj__c);
                    mapQuantidadeParcela.put(segurado.GrupoContrato__r.ContratanteContrato__r.Contrato__c,segurado.GrupoContrato__r.ContratanteContrato__r.QuantidadeParcelas__c);
                    mapQuantidadeNome.put(segurado.GrupoContrato__r.ContratanteContrato__r.Contrato__c,segurado.Nome__c); //VIAG-293 INICIO/FIM
                }
                                    
                RetornoAilusTO.PayloadTO retorno = new RetornoAilusTO.PayloadTO();
                List<RetornoAilusTO.InformacoespropostaTO> retornoPropostas = new List<RetornoAilusTO.InformacoespropostaTO>();
                retorno.propostas = retornoPropostas;
                
                for(Contract contrato : contratos){
                    RetornoAilusTO.InformacoesContratoTO contratoPayload = new RetornoAilusTO.InformacoesContratoTO();
                    contratoPayload.NumeroApolice = contrato.NumeroApolice__c;
                    contratoPayload.Tipo = contrato.Tipo__c;
                    contratoPayload.VigenciaInicial = String.valueOf(contrato.StartDate);
                    contratoPayload.VigenciaFinal = String.valueOf(contrato.VigenciaFinal__c);
                    contratoPayload.DataEmissao = String.valueOf(contrato.DataEmissao__c);
                    contratoPayload.CodigoSucursal = contrato.Sucursal__c;
                    contratoPayload.CodigoRamo = contrato.CodigoRamo__c;
                    contratoPayload.NumeroEndosso = contrato.Endosso__c;
                    contratoPayload.Status = contrato.Status;

                    RetornoAilusTO.InformacoesContratanteTO contratantePayload = new RetornoAilusTO.InformacoesContratanteTO();
                    if(mapQuantidadeCpf.get(contrato.id) != null) contratantePayload.NumeroDocumento = mapQuantidadeCpf.get(contrato.id);
                    if(mapQuantidadeCnpj.get(contrato.id) != null) contratantePayload.NumeroDocumento = mapQuantidadeCnpj.get(contrato.id);
                    contratantePayload.TipoPessoa = mapQuantidadeTipoPessoa.get(contrato.id) ?  'Fisica' : 'Juridica'; 
                    contratantePayload.Nome = mapQuantidadeNome.get(contrato.id);

                    RetornoAilusTO.InformacoesProdutoTO produtoPayload = new RetornoAilusTO.InformacoesProdutoTO();
                    produtoPayload.Segmento = contrato.Segmento__c;
                    produtoPayload.Nome = contrato.Produto__r.Name;

                    RetornoAilusTO.InformacoesRemuneracaoDetalhesTO payloadAgencimento = new RetornoAilusTO.InformacoesRemuneracaoDetalhesTO();
                    List<RetornoAilusTO.InformacoesFavorecidoRemuneracaoDetalhesTO> payloadFavorecidosAGE = new List<RetornoAilusTO.InformacoesFavorecidoRemuneracaoDetalhesTO>();
                    payloadAgencimento.Percentual = String.ValueOf(mapRemunceracoesPercentualOrcamentoAGE.get(contrato.Proposta__c));
                    payloadAgencimento.Favorecidos = payloadFavorecidosAGE;
                    for(FavorecidoRemuneracaoProposta__c favorecido : beneficiariosRemuneracaoAGE){
                        if(favorecido.RemuneracaoProposta__c == mapRemunceracoesOrcamentoAGE.get(contrato.Proposta__c)){
                            RetornoAilusTO.InformacoesFavorecidoRemuneracaoDetalhesTO favorecidoAGEPayload = new RetornoAilusTO.InformacoesFavorecidoRemuneracaoDetalhesTO();
                            favorecidoAGEPayload.Nome = favorecido.conta__r.Name;
                            favorecidoAGEPayload.Participacao = String.ValueOf(favorecido.Participacao__c);
                            favorecidoAGEPayload.CodigoCorretor = favorecido.Susep__c;
                            favorecidoAGEPayload.CorretorLider = String.ValueOf(favorecido.CorretorLider__c);

                            payloadAgencimento.Favorecidos.add(favorecidoAGEPayload);
                        }
                    }

                    RetornoAilusTO.InformacoesRemuneracaoDetalhesTO payloadCorretagem = new RetornoAilusTO.InformacoesRemuneracaoDetalhesTO();
                    List<RetornoAilusTO.InformacoesFavorecidoRemuneracaoDetalhesTO> payloadFavorecidosCOR = new List<RetornoAilusTO.InformacoesFavorecidoRemuneracaoDetalhesTO>();
                    payloadCorretagem.Percentual = String.ValueOf(mapRemunceracoesPercentualOrcamentoCOR.get(contrato.Proposta__c));
                    payloadCorretagem.Favorecidos = payloadFavorecidosCOR;
                    for(FavorecidoRemuneracaoProposta__c favorecido : beneficiariosRemuneracaoCOR){
                        if(favorecido.RemuneracaoProposta__c == mapRemunceracoesOrcamentoCOR.get(contrato.Proposta__c)){
                            RetornoAilusTO.InformacoesFavorecidoRemuneracaoDetalhesTO favorecidoCORPayload = new RetornoAilusTO.InformacoesFavorecidoRemuneracaoDetalhesTO();
                            favorecidoCORPayload.Nome = favorecido.conta__r.Name;
                            favorecidoCORPayload.Participacao = String.ValueOf(favorecido.Participacao__c);
                            favorecidoCORPayload.CodigoCorretor = favorecido.Susep__c;
                            favorecidoCORPayload.CorretorLider = String.ValueOf(favorecido.CorretorLider__c);

                            payloadCorretagem.Favorecidos.add(favorecidoCORPayload);
                        }
                    }

                    RetornoAilusTO.InformacoesRemuneracaoTO payloadRemuneracao = new RetornoAilusTO.InformacoesRemuneracaoTO();
                    payloadRemuneracao.Agenciamento = payloadAgencimento;
                    payloadRemuneracao.Corretagem = payloadCorretagem;

                    RetornoAilusTO.InformacoespropostaTO propostaPayload = new RetornoAilusTO.InformacoespropostaTO();
                    
                    propostaPayload.Status = contrato.Proposta__r.Status;
                    propostaPayload.Origem = contrato.Origem__c;
                    propostaPayload.Numero = contrato.NumeroProposta__c;
                    propostaPayload.MeioComercializacao = contrato.Proposta__r.MeioComercializacao__c;
                    propostaPayload.FormaDePagamento = contrato.FormaPagamento__r.Name;
                    propostaPayload.PremioLiquido = String.valueOf(contrato.Proposta__r.PremioComercial__c);
                    propostaPayload.ValorIoF = String.valueOf(contrato.Proposta__r.IOF__c);
                    propostaPayload.PremioTotal = String.valueOf(contrato.Proposta__r.PremioTotal__c);
                    propostaPayload.NumeroParcelas = String.valueOf(mapQuantidadeParcela.get(contrato.id));
                    propostaPayload.Contrato = contratoPayload;
                    propostaPayload.Remuneracao = payloadRemuneracao;
                    propostaPayload.Contratante = contratantePayload;
                    propostaPayload.Produto = produtoPayload;
                    
                    retorno.propostas.add(propostaPayload);
                }
                this.retonarSucesso(JSON.serialize(retorno), 200);
            }
        }catch(Exception e){
            this.retornarErro(e.getMessage());
        }   
    }
}