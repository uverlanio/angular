/**
 * @description       : 
 * @author            : ChangeMeIn@UserSettingsUnder.SFDoc
 * @group             : 
 * @last modified on  : 02-09-2023
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
**/
//PLV-4772-INICIO
/*
*  @author Squad Avanxo 
*  @Descrição: Classe para gerar o payload e realizar transmissão do endosso
*/
public class PayloadTransmissao {

    public static void gerarEndossoPagamento(Id idCaso, EmissaoTO orcamento) {
        System.debug('gerarPayLoad######');
        Set<Id> sContrato = new Set<Id>();
        Set<Id> sCaso = new Set<Id>{idCaso};
        Set<Id> sAccount = new Set<Id>();
        String payload;
        Map<Id, FranquiaGarantia__c> mapFranquiaDaGarantia = new Map<Id, FranquiaGarantia__c>();
        OrgWideEmailAddress[] owea  = [select Id from OrgWideEmailAddress where Address = 'sinistro.vida@portoseguro.com.br'];
        Map<Id, Case> mCaso = new Map<Id, Case>();

        if(!sCaso.isEmpty() && owea.size() > 0){            
            for(Case c : [Select Id,Contrato__c,AccountId,IdPrestadora__c,Account.PersonEmail,Lista_de_pendencias__c From Case Where id In :sCaso] ){
                mCaso.put(c.Id, c);
                sContrato.add(c.Contrato__c);
                sAccount.add(c.AccountId);
            }
        }
        
        Map<Id, Endereco__c> mapAccountEndereco = new Map<Id, Endereco__c>();
        for(Endereco__c enderecoAcc : [SELECT Id, Name, Conta__c, TipoEndereco__c, Bairro__c, Cidade__c, Logradouro__c, Estado__c, Complemento__c, CEP__c,Numero__c FROM Endereco__c WHERE Conta__c IN :sAccount AND MaisAtual__c = True]){
            mapAccountEndereco.put(enderecoAcc.Conta__c, enderecoAcc);
        }

        List<PagamentoGarantia__c> listPagamentoGarantia = [select Id, Name, Caso__c, Caso__r.CaseNumber, Caso__r.Contact.Name,
                                    Caso__r.Contact.Id, Caso__r.AccountId, Caso__r.Account.Name, Caso__r.Account.EmpresaTrabalhaSocio__c,  
                                    Caso__r.Account.Ramo_de_atividade__c,  // PLV-4810  INICIO/FIM SYS4B ODEMIR
                                    Caso__r.Account.PersonBirthdate, Caso__r.Account.Sexo__c, Caso__r.Account.PEP__c, Caso__r.Account.Fumante__c, Caso__r.Account.Profissao__r.Name, 
                                    Caso__r.Account.Profissao__r.CodigoProfissao__c, Caso__r.Account.RamoAtividade__c, Caso__r.Account.RegimeTrabalho__c,
                                    Caso__r.Account.PersonHomePhone, Caso__r.Account.PersonMobilePhone, Caso__r.Account.Phone,
                                    Caso__r.Account.Renda__c,Caso__r.Account.Cpf__c, Caso__r.Contrato__c, Caso__r.Contrato__r.TermoGuarda__c, 
                                    Caso__r.Contrato__r.CodigoRamo__c, Caso__r.Contrato__r.PorQuantoTempoQuerGarantirRenda__c, Caso__r.Contrato__r.FormaReceberApolice__c, 
                                    Caso__r.Contrato__r.DependentesFinanceiros__c, Caso__r.Contrato__r.TermoResponsabilidade__c, Caso__r.Contrato__r.Origem__c, 
                                    Caso__r.Contrato__r.AssinaturaEletronica__c, Caso__r.Contrato__r.FormaPagamento__c, Caso__r.Contrato__r.FormaPagamento__r.Codigo__c, 
                                    Caso__r.Contrato__r.FormaPagamento__r.Name,
                                    Garantia_do_segurado_do_contrato__c, Garantia_do_segurado_do_contrato__r.GarantiaProduto__r.Name, 
                                    Garantia_do_segurado_do_contrato__r.GarantiaProduto__r.CancelaGarantia__c, Garantia_do_segurado_do_contrato__r.Garantia__r.Sigla__c, Fase__c, 
                                    Status_do_pagamento__c, Caso__r.Contrato__r.Empresa__c  from PagamentoGarantia__c where Caso__c in : sCaso];

        List<GrupoProfissoes__c> listGrupoProfissoes = [SELECT Id, GrupoRisco__r.Name, Profissao__r.Name FROM GrupoProfissoes__c];
        Map<String,GrupoProfissoes__c> mGrupoProfissoes = new Map<String,GrupoProfissoes__c>();
        for (GrupoProfissoes__c grupo: listGrupoProfissoes){
            mGrupoProfissoes.put(grupo.Profissao__r.Name, grupo);
        }
        Map<Id,Contract> mContract = new Map<Id,Contract>();
        List<Contract> listContract= [select Id, Name, Oportunidade__r.Numero__c, Oportunidade__r.NumeroOferta__c, Produto__r.ProductCode, Oportunidade__r.CanalDistribuicao__r.Sigla__c, Oportunidade__r.NumeroPortal__c, 
        Oportunidade__r.TipoVigencia__c, Oportunidade__r.VigenciaInicial__c, Oportunidade__r.VigenciaFinal__c, Produto__r.Segmento__c, Empresa__c, Sucursal__c, CodigoRamo__c, NumeroApolice__c, Endosso__c, 
        TipoContrato__c, VigenciaFinal__c, StartDate, AccountId from Contract where Id in : sContrato];
        for (Contract c: listContract){
            mContract.put(c.AccountId, c);
        }
        List<GarantiaContrato__c> listGarantias = [select Id, Name,Garantia__r.Name, Capital__c, Garantia__r.Sigla__c, MoedaGarantia__c, FranquiaGarantia__c, FranquiaGarantia__r.Name, FranquiaGarantia__r.CodigoFranquia__c, ValorCotacao__c, Contrato__c, GarantiaProduto__r.QuantidadeMaximaContratacao__c from GarantiaContrato__c where Contrato__c in : sContrato];
        List<String> lSigla = new List<String>();
        for (GarantiaContrato__c garantia: listGarantias){
            lSigla.add(garantia.Garantia__r.Sigla__c);
        }
        List<FranquiaGarantia__c> listFranquiaGarantia = [SELECT Id, Franquia__r.CodigoFranquia__c, Franquia_Padrao__c,  GarantiaProduto__r.Garantia__r.Sigla__c, GarantiaProduto__r.QuantidadeMaximaContratacao__c 
                                                FROM FranquiaGarantia__c 
                                                WHERE Franquia_Padrao__c = true 
                                                AND GarantiaProduto__r.Garantia__r.Sigla__c IN: lSigla];

        List<GrupoContrato__c> lstGrupoContrato = [SELECT  Id, Name, TipoCalculo__c, Numero__c, QuantidadeVidas__c, ContratanteContrato__r.Contrato__c
                            FROM    GrupoContrato__c
                            WHERE   ContratanteContrato__r.Contrato__c in : sContrato];
        Set<id> idsGarantias = new Set<id>();
        Set<id> idsGarantiaContrato = new Set<id>();
        for (PagamentoGarantia__c pagamento: listPagamentoGarantia){
            for(GarantiaContrato__c garantiaContrato: listGarantias){                  
                    idsGarantias.add(garantiaContrato.FranquiaGarantia__c);
                    idsGarantiaContrato.add(garantiaContrato.id);
            }
        }
        List<FranquiaGarantia__c> franquiatemp = new List<FranquiaGarantia__c>();
        if (idsGarantias!=null&&idsGarantiaContrato!=null) {
            franquiatemp = [SELECT Id, Name, (SELECT id, Name FROM Garantias_do_contrato__r where id in :idsGarantiaContrato  LIMIT 1) FROM FranquiaGarantia__c WHERE id IN :idsGarantias];
        }

        List<FavorecidoRemuneracaoContrato__c> listFavorecido = [SELECT Id, CorretorLider__c, Participacao__c, Papel__c, Susep__c, SusepEmissao__c, SusepOficialCorretor__c, SusepOrcamento__c, AntecipacaoComissao__c
                                , RemuneracaoContrato__c, RemuneracaoContrato__r.TipoRemuneracao__r.Name, RemuneracaoContrato__r.TipoRemuneracao__r.Codigo__c, RemuneracaoContrato__r.Percentual__c, RemuneracaoContrato__r.Porcentagem_de_Retencao__c,RemuneracaoContrato__r.Contrato__c
                                ,Conta__c , Conta__r.Cnpj__c, Conta__r.Cpf__c, Conta__r.C_digo_do_Agenciador__c, Conta__r.Name
                                FROM FavorecidoRemuneracaoContrato__c
                                WHERE RemuneracaoContrato__r.Contrato__c in:sContrato];
        
        Map<String,ContratanteContrato__c> mContratante = new Map<String,ContratanteContrato__c>();
        List<ContratanteContrato__c> listContratante = [SELECT Id, Name, Conta__c, Contrato__c, TipoResponsavelPagamento__c, QuantidadeParcelas__c,VencimentoDemaisParcelas__c 
                                    ,VigenciaInicial__c,VencimentoPrimeiraParcela__c, InformacaoBancaria__c, InformacaoBancaria__r.Agencia__c,InformacaoBancaria__r.Banco__c
                                    ,InformacaoBancaria__r.NumeroConta__c, InformacaoBancaria__r.Digito__c, InformacaoBancaria__r.TipoPessoa__c, CartaoCredito__c
                                    ,CartaoCredito__r.CartoPortoSeguro__c, CartaoCredito__r.Conta__r.Name, CartaoCredito__r.NomeTitular__c, CartaoCredito__r.NumeroCartao__c, CartaoCredito__r.Ticket__c
                                    ,CartaoCredito__r.Vencimento__c, PlanoParcelamento__r.NumeroParcela__c
                                    , CartaoCredito__r.VencimentoCriptografado__c // PLV-4803 - FIX - INICIO/FIM
                                    FROM ContratanteContrato__c WHERE Contrato__c in :sContrato];
        for (ContratanteContrato__c contratante: listContratante){
            mContratante.put(contratante.Conta__c, contratante);
        }
        Map<Id,List<RespostaDeclaracaoSaude__c>> mapRespostas = new Map<Id, List<RespostaDeclaracaoSaude__c>>();
        for(RespostaDeclaracaoSaude__c  resposta : [SELECT Id, Name, DeclaraoSaude__c,  DeclaraoSaude__r.QuestionarioRisco__c, DeclaraoSaude__r.Contrato__c, PerguntaQuestionarioRisco__c, Resposta__c FROM RespostaDeclaracaoSaude__c WHERE DeclaraoSaude__r.Contrato__c IN: sContrato]){
            if(!mapRespostas.containsKey(resposta.DeclaraoSaude__r.Contrato__c)){
                mapRespostas.put(resposta.DeclaraoSaude__r.Contrato__c, new List<RespostaDeclaracaoSaude__c>());
            }
            List<RespostaDeclaracaoSaude__c> lstResposta = mapRespostas.get(resposta.DeclaraoSaude__r.Contrato__c);
            lstResposta.add(resposta);
            mapRespostas.put(resposta.DeclaraoSaude__r.Contrato__c, lstResposta);
        }
        
        for (PagamentoGarantia__c pagamento: listPagamentoGarantia){
            if (pagamento.Garantia_do_segurado_do_contrato__r.GarantiaProduto__r.CancelaGarantia__c) {
                PropostaTO.Proposta request = new PropostaTO.Proposta();
                
                request.indice = 1;
                request.codigoEmpresa = pagamento.Caso__r.Contrato__r.Empresa__c!=null? Integer.valueOf(pagamento.Caso__r.Contrato__r.Empresa__c): 1;
                request.numeroOrcamento = orcamento.numeroOrcamento;
                request.numeroPortal = orcamento.numeroPortal;
                request.origem = Integer.valueOf(pagamento.Caso__r.Contrato__r.Origem__c);
                request.ramoSeguro = Integer.valueOf(pagamento.Caso__r.Contrato__r.CodigoRamo__c);
                request.tipoSeguro = 'EDS';
                request.entradaNegocio = orcamento.canalDistribuicao;
                request.dataProtocolo = orcamento.dataCalculo;
                request.meioComercializacao = orcamento.meioComercializacao;
                request.codigoProdutoVida = orcamento.codigoProdutoVida;
                request.canalDistribuicao = orcamento.canalDistribuicao;
                request.segmento = orcamento.segmento;
                request.tempoRendaProtegida = pagamento.Caso__r.Contrato__r.PorQuantoTempoQuerGarantirRenda__c;
                request.dependentesFinanceiros = pagamento.Caso__r.Contrato__r.DependentesFinanceiros__c;
                request.formaReceberApolice = pagamento.Caso__r.Contrato__r.FormaReceberApolice__c;
                request.termoGuarda = pagamento.Caso__r.Contrato__r.TermoGuarda__c;
                request.termoResponsabilidade = pagamento.Caso__r.Contrato__r.TermoResponsabilidade__c;
                request.assinaturaEletronica = pagamento.Caso__r.Contrato__r.AssinaturaEletronica__c;
                
                request.contratoOriginal = new PropostaTO.ContratoOriginal();
                request.contratoOriginal.empresa = mContract.get(pagamento.Caso__r.AccountId).Empresa__c;
                request.contratoOriginal.sucursal = mContract.get(pagamento.Caso__r.AccountId).Sucursal__c;
                request.contratoOriginal.ramo = mContract.get(pagamento.Caso__r.AccountId).CodigoRamo__c;
                request.contratoOriginal.numeroOrcamento = Integer.valueOf(orcamento.contratoOriginal.numeroOrcamento);
                request.contratoOriginal.codigoProdutoVida = orcamento.contratoOriginal.codigoProdutoVida;
                request.contratoOriginal.apolice = mContract.get(pagamento.Caso__r.AccountId).NumeroApolice__c;
                request.contratoOriginal.endosso = mContract.get(pagamento.Caso__r.AccountId).Endosso__c;
                request.contratoOriginal.vigenciaFinal = String.valueOf(mContract.get(pagamento.Caso__r.AccountId).VigenciaFinal__c);
                request.contratoOriginal.vigenciaInicial = String.valueOf(mContract.get(pagamento.Caso__r.AccountId).StartDate);
                                
                List<String> siglas = new List<String>();
                
                Map<String, FranquiaGarantia__c> mapFranquiaGarantia = new Map<String, FranquiaGarantia__c>();
                Map<String, GarantiaContrato__c> mapGarantiaContrato = new Map<String, GarantiaContrato__c>();
                List<PropostaTO.Cobertura> listCobertura = new List<PropostaTO.Cobertura>();
                   
                List<String> siglasFranquia = new List<String>();
                for(FranquiaGarantia__c fg : listFranquiaGarantia){
                    siglasFranquia.add(fg.GarantiaProduto__r.Garantia__r.Sigla__c);
                    mapFranquiaGarantia.put(fg.GarantiaProduto__r.Garantia__r.Sigla__c, fg);
                }
                
                
                for(FranquiaGarantia__c franquiatmp : franquiatemp){
                    if(franquiatmp.Garantias_do_contrato__r.isEmpty()) return;
                    for(GarantiaContrato__c fran : franquiatmp.Garantias_do_contrato__r){
                        if (fran.Id!=null && franquiatmp!=null) {
                            mapFranquiaDaGarantia.put(fran.Id, franquiatmp);                            
                        }
                    }
                }
                
                for(GarantiaContrato__c gc : listGarantias){
                    if(!mapGarantiaContrato.containsKey(gc.Garantia__r.Sigla__c)){
                        if (gc.Contrato__c == pagamento.Caso__r.Contrato__c) { 
                            PropostaTO.Cobertura cobertura = new PropostaTO.Cobertura();
                            cobertura.sigla = gc.Garantia__r.Sigla__c;
                            cobertura.valor = gc.Capital__c!=null? integer.valueOf(gc.Capital__c) : 0;
                            if (!mapFranquiaGarantia.containskey(cobertura.sigla) || mapFranquiaGarantia.get(cobertura.sigla).GarantiaProduto__r.QuantidadeMaximaContratacao__c==null) {
                                cobertura.quantidade = 0;
                            }
                            else {
                                cobertura.quantidade = integer.valueOf(mapFranquiaGarantia.get(cobertura.sigla).GarantiaProduto__r.QuantidadeMaximaContratacao__c);
                            }
                            cobertura.moeda = '';
                            FranquiaGarantia__c franquia = mapFranquiaDaGarantia.get(gc.id);
                            cobertura.franquia = '';
                            cobertura.cotacaoMoeda = '0';
                            cobertura.cobrado = '';
                            
                            listCobertura.add(cobertura);
                            mapGarantiaContrato.put(gc.Garantia__r.Sigla__c, gc);
                        }
                    }
                }
                request.contratoOriginal.versoesCalculos = new List<propostaTO.VersoesCalculo>();
                for (EmissaoTO.VersoesCalculo vc : orcamento.versoesCalculos) {
                    propostaTO.VersoesCalculo versaoCalculo = new propostaTO.VersoesCalculo();
                    versaoCalculo.tipo = vc.tipo;
                    versaoCalculo.opcao = vc.opcao;
                    versaoCalculo.descontoAgravo = Integer.valueOf(vc.descontoAgravo);
                    request.contratoOriginal.versoesCalculos.add(versaoCalculo);
                }
                request.contratoOriginal.remuneracoes = new List<propostaTO.Remuneracao>();
                for (EmissaoTO.RemuneracaoTO remuneracaoTemp : orcamento.contratoOriginal.remuneracoes) {
                    PropostaTo.Remuneracao remuneracao = new PropostaTo.Remuneracao();
                    remuneracao.tipoRemuneracao = remuneracaoTemp.tipoRemuneracao;
                    remuneracao.percentual = remuneracaoTemp.percentual;
                    remuneracao.favorecidos = new List<PropostaTO.Favorecido>();
                    for (EmissaoTO.FavorecidoTO favorecidoTemp : remuneracaoTemp.favorecidos) {
                        PropostaTO.Favorecido favorecido = new PropostaTO.Favorecido();
                        favorecido.susep = favorecidoTemp.susep;
                        favorecido.pessoa = new PropostaTO.Pessoa();
                        favorecido.pessoa.nome = favorecidoTemp.pessoa.nome;
                        favorecido.participacao = favorecidoTemp.participacao;
                        favorecido.papel = favorecidoTemp.papel;
                        favorecido.corretorLider = favorecidoTemp.corretorLider;
                        remuneracao.favorecidos.add(favorecido);
                    }
                    request.contratoOriginal.remuneracoes.add(remuneracao);
                }
                request.contratoOriginal.precificacao = new PropostaTO.Precificacao();
                request.contratoOriginal.precificacao.premio = new PropostaTO.Premio();
                request.contratoOriginal.precificacao.premio.total = orcamento.contratoOriginal.precificacao.premio.total!=null? orcamento.contratoOriginal.precificacao.premio.total:0;
                request.contratoOriginal.precificacao.premio.puro = orcamento.contratoOriginal.precificacao.premio.puro!=null?orcamento.contratoOriginal.precificacao.premio.puro:0;
                request.contratoOriginal.precificacao.premio.comercial = orcamento.contratoOriginal.precificacao.premio.comercial!=null?orcamento.contratoOriginal.precificacao.premio.comercial:0;
                request.contratoOriginal.precificacao.premio.premioPago = orcamento.contratoOriginal.precificacao.premio.total!=null? orcamento.contratoOriginal.precificacao.premio.total:0;
                request.contratoOriginal.precificacao.custoDeApolice = Integer.valueOf(orcamento.contratoOriginal.precificacao.custoDeApolice)!=null?Integer.valueOf(orcamento.contratoOriginal.precificacao.custoDeApolice):0;
                request.contratoOriginal.precificacao.juros = Integer.valueOf(orcamento.contratoOriginal.precificacao.juros)!=null?Integer.valueOf(orcamento.contratoOriginal.precificacao.juros):0;
                request.contratoOriginal.precificacao.iof = orcamento.contratoOriginal.precificacao.iof!=null?orcamento.contratoOriginal.precificacao.iof:0;
                request.contratoOriginal.precificacao.encargos = Integer.valueOf(orcamento.contratoOriginal.precificacao.encargos)!=null?Integer.valueOf(orcamento.contratoOriginal.precificacao.encargos):0;
                request.contratoOriginal.precificacao.descontoAgravo = new List<PropostaTO.DescontoAgravo>();
                for (EmissaoTO.DescontoagravoTO descontoAgravoTemp : orcamento.contratoOriginal.precificacao.descontoAgravo) {
                    PropostaTO.DescontoAgravo descontoAgravo = new PropostaTO.DescontoAgravo();
                    descontoAgravo.tipo = descontoAgravoTemp.tipo;
                    descontoAgravo.percentual = Integer.valueOf(descontoAgravoTemp.percentual);
                    descontoAgravo.monetario = Integer.valueOf(descontoAgravoTemp.monetario);
                    request.contratoOriginal.precificacao.descontoAgravo.add(descontoAgravo);
                }
                request.contratoOriginal.precificacao.contratantes = new List<PropostaTO.Contratante>();
                for (EmissaoTO.ContratanteTO contratanteTemp : orcamento.contratoOriginal.precificacao.contratantes) {
                    PropostaTO.Contratante contratante = new PropostaTO.Contratante();
                    contratante.premio = new PropostaTO.Premio();
                    contratante.premio.total = contratanteTemp.premio.total!=null?contratanteTemp.premio.total:0;
                    contratante.premio.puro = contratanteTemp.premio.puro!=null?contratanteTemp.premio.puro:0;
                    contratante.premio.comercial = contratanteTemp.premio.comercial!=null?contratanteTemp.premio.comercial:0;
                    contratante.numero = contratanteTemp.numero!=null?Integer.valueOf(contratanteTemp.numero):1;
                    contratante.iof = contratanteTemp.iof!=null?contratanteTemp.iof:0.01;
                    contratante.grupos = new List<PropostaTO.Grupos>();
                    for (EmissaoTO.GrupoTO grupotemp : contratanteTemp.grupos) {
                        PropostaTO.Grupos grupo =  new PropostaTO.Grupos();
                        grupo.segurados = new List<PropostaTO.Segurado>();
                        for (EmissaoTO.SeguradoTO seguradoTemp : grupotemp.segurados) {
                            PropostaTO.Segurado segurado = new PropostaTO.Segurado();
                            segurado.descontoAgravo = new List<PropostaTO.DescontoAgravo>();
                            segurado.coberturas = new List<PropostaTO.Cobertura>();
                            segurado.premio = new PropostaTO.Premio(); 
                            segurado.premio.total = seguradoTemp.premio.total!=null?seguradoTemp.premio.total: 0;
                            segurado.premio.puro = seguradoTemp.premio.puro!=null?seguradoTemp.premio.puro: 0;
                            segurado.premio.comercial = seguradoTemp.premio.comercial!=null?seguradoTemp.premio.comercial: 0;
                            segurado.numero = seguradoTemp.numero!=null?Integer.valueOf(seguradoTemp.numero): 1;
                            segurado.iof = seguradoTemp.iof!=null?seguradoTemp.iof: 0.01;
                            for (EmissaoTO.DescontoagravoTO descontoAgravoTemp : seguradoTemp.descontoAgravo) {
                                PropostaTO.DescontoAgravo descontoAgravo = new PropostaTO.DescontoAgravo();
                                descontoAgravo.tipo = descontoAgravoTemp.tipo!=null? descontoAgravoTemp.tipo: '';
                                descontoAgravo.percentual = descontoAgravoTemp.percentual!=null? Integer.valueOf(descontoAgravoTemp.percentual): 0;
                                descontoAgravo.monetario = descontoAgravoTemp.monetario!=null? Integer.valueOf(descontoAgravoTemp.monetario): 0;
                                segurado.descontoAgravo.add(descontoAgravo);
                            }
                            for (EmissaoTO.CoberturaTO coberturaTemp : seguradoTemp.coberturas) {
                                PropostaTO.Cobertura cobertura = new PropostaTO.Cobertura();
                                cobertura.descontoAgravo = new List<PropostaTO.DescontoAgravo>();
                                PropostaTO.Taxa taxa = new PropostaTO.Taxa();
                                cobertura.premio = new PropostaTO.Premio();
                                taxa.total = coberturaTemp.taxa.total!=null? Integer.valueOf(coberturaTemp.taxa.total): 0;
                                taxa.pura = coberturaTemp.taxa.pura!=null? Integer.valueOf(coberturaTemp.taxa.pura): 0;
                                taxa.comercial = coberturaTemp.taxa.comercial!=null? Integer.valueOf(coberturaTemp.taxa.comercial): 0;
                                cobertura.taxa = taxa;
                                cobertura.iof = coberturaTemp.iof!=null? coberturaTemp.iof: 0.01;
                                cobertura.sigla = coberturaTemp.sigla!=null? coberturaTemp.sigla: '';
                                
                                for (EmissaoTO.DescontoagravoTO descontoAgravoTemp : coberturaTemp.descontoAgravo) {
                                    PropostaTO.DescontoAgravo descontoAgravo = new PropostaTO.DescontoAgravo();
                                    descontoAgravo.tipo = descontoAgravoTemp.tipo!=null? descontoAgravoTemp.tipo: '';
                                    descontoAgravo.percentual = descontoAgravoTemp.percentual!=null? Integer.valueOf(descontoAgravoTemp.percentual): 0;
                                    descontoAgravo.monetario = descontoAgravoTemp.monetario!=null? Integer.valueOf(descontoAgravoTemp.monetario): 0;
                                    cobertura.descontoAgravo.add(descontoAgravo);
                                }
                                
                                cobertura.premio.total = coberturaTemp.premio.total!=null? coberturaTemp.premio.total: 0;
                                cobertura.premio.puro = coberturaTemp.premio.puro!=null? coberturaTemp.premio.puro: 0;
                                cobertura.premio.comercial = coberturaTemp.premio.comercial!=null? coberturaTemp.premio.comercial: 0;
                                cobertura.capitalContratacao = coberturaTemp.capitalContratacao!=null? coberturaTemp.capitalContratacao: 0.0;

                                segurado.coberturas.add(cobertura);
                            }
                            
                            grupo.segurados.add(segurado);
                        }
                        grupo.numero = Integer.valueOf(grupotemp.numero)!=null?Integer.valueOf(grupotemp.numero):1;
                        grupo.iof = grupotemp.iof!=null?grupotemp.iof:0.01;
                        PropostaTO.Premio premio = new PropostaTO.Premio();
                        premio.total = grupotemp.premio.total!=null? grupotemp.premio.total: 0;
                        premio.puro = grupotemp.premio.puro!=null? grupotemp.premio.puro: 0;
                        premio.comercial = grupotemp.premio.comercial!=null? grupotemp.premio.comercial: 0;
                        grupo.premio = premio;
                        grupo.descontoAgravo = new List<PropostaTO.DescontoAgravo>();
                        for (EmissaoTO.DescontoagravoTO descontoAgravoTemp : grupotemp.descontoAgravo) {
                            PropostaTO.DescontoAgravo descontoAgravo = new PropostaTO.DescontoAgravo();
                            descontoAgravo.tipo = descontoAgravoTemp.tipo!=null? descontoAgravoTemp.tipo: '';
                            descontoAgravo.percentual = descontoAgravoTemp.percentual!=null? Integer.valueOf(descontoAgravoTemp.percentual): 0;
                            descontoAgravo.monetario = descontoAgravoTemp.monetario!=null? Integer.valueOf(descontoAgravoTemp.monetario): 0;
                            grupo.descontoAgravo.add(descontoAgravo);
                        }
                        contratante.grupos.add(grupo);
                    }
                    contratante.descontoAgravo = new List<PropostaTO.DescontoAgravo>();
                    for (EmissaoTO.DescontoagravoTO descontoAgravoTemp : contratanteTemp.descontoAgravo) {
                        PropostaTO.DescontoAgravo descontoAgravo = new PropostaTO.DescontoAgravo();
                        descontoAgravo.tipo = descontoAgravoTemp.tipo!=null? descontoAgravoTemp.tipo: '';
                        descontoAgravo.percentual = descontoAgravoTemp.percentual!=null? Integer.valueOf(descontoAgravoTemp.percentual): 0;
                        descontoAgravo.monetario = descontoAgravoTemp.monetario!=null? Integer.valueOf(descontoAgravoTemp.monetario): 0;
                        contratante.descontoAgravo.add(descontoAgravo);
                    }
                    request.contratoOriginal.precificacao.contratantes.add(contratante);
                }
                request.contratoOriginal.precificacao.coberturas = new List<PropostaTO.Cobertura>();
                for (EmissaoTO.CoberturaTO coberturaTemp : orcamento.contratoOriginal.precificacao.coberturas) {
                    PropostaTO.Cobertura cobertura = new PropostaTO.Cobertura();
                    cobertura.iof = coberturaTemp.iof!=null? coberturaTemp.iof: 0.01;
                    cobertura.sigla = coberturaTemp.sigla!=null? coberturaTemp.sigla: '';                    
                    cobertura.descontoAgravo = new List<PropostaTO.DescontoAgravo>();

                    for (EmissaoTO.DescontoagravoTO descontoAgravoTemp : coberturaTemp.descontoAgravo) {
                        PropostaTO.DescontoAgravo descontoAgravo = new PropostaTO.DescontoAgravo();
                        descontoAgravo.tipo = descontoAgravoTemp.tipo!=null? descontoAgravoTemp.tipo: '';
                        descontoAgravo.percentual = descontoAgravoTemp.percentual!=null? Integer.valueOf(descontoAgravoTemp.percentual): 0;
                        descontoAgravo.monetario = descontoAgravoTemp.monetario!=null? Integer.valueOf(descontoAgravoTemp.monetario): 0;
                        cobertura.descontoAgravo.add(descontoAgravo);
                    }

                    cobertura.premio = new PropostaTO.Premio();
                    cobertura.premio.total = coberturaTemp.premio.total!=null? coberturaTemp.premio.total: 0;
                    cobertura.premio.puro = coberturaTemp.premio.puro!=null? coberturaTemp.premio.puro: 0;
                    cobertura.premio.comercial = coberturaTemp.premio.comercial!=null? coberturaTemp.premio.comercial: 0;
                    cobertura.capitalContratacao = coberturaTemp.capitalContratacao!=null? coberturaTemp.capitalContratacao: 0.0;
                    request.contratoOriginal.precificacao.coberturas.add(cobertura);
                }

                request.contratoOriginal.contratantes = new List<PropostaTO.Contratante>();
                PropostaTO.Contratante contratanteOriginal = new PropostaTO.Contratante();
                contratanteOriginal.tipo = 'PRI';
                contratanteOriginal.numero = 0;
                contratanteOriginal.grupos = new List<PropostaTO.Grupos>();
                PropostaTO.Grupos grupoOriginal = new PropostaTO.Grupos();
                grupoOriginal.segurados = new List<PropostaTO.Segurado>();
                PropostaTO.Segurado seguradoOriginal = new PropostaTO.Segurado();
                seguradoOriginal.pessoa = new PropostaTO.Pessoa();
                seguradoOriginal.pessoa.dadosPessoaFisica = new PropostaTO.DadosPessoaFisica();
                seguradoOriginal.beneficiarios = new List<PropostaTO.Beneficiario>();
                for( GrupoContrato__c grupoContrato : lstGrupoContrato ){
                    if (pagamento.Caso__r.Contrato__c == grupoContrato.ContratanteContrato__r.Contrato__c) {
                        grupoOriginal.tipoCalculo = grupoContrato.TipoCalculo__c;//!=null? grupoContrato.TipoCalculo__c : ''; //PLV-4803-FIX - INICIO/FIM
                        grupoOriginal.tarifa = '0';
                        grupoOriginal.qtdeVidas = Double.valueOf(grupoContrato.QuantidadeVidas__c)!=null? Double.valueOf(grupoContrato.QuantidadeVidas__c) : 0.0; //PLV-4803-FIX - INICIO/FIM
                        grupoOriginal.nome = grupoContrato.Name!=null? grupoContrato.Name : '';
                        grupoOriginal.numero = Integer.valueOf(grupoContrato.Numero__c)!=null?Integer.valueOf(grupoContrato.Numero__c) : 0;
                        seguradoOriginal.numero = 0;
                        seguradoOriginal.pessoa.nome = pagamento.Caso__r.Account.Name;
                        seguradoOriginal.pessoa.rendaMensal = String.valueOf(pagamento.Caso__r.Account.Renda__c)!=null? String.valueOf(pagamento.Caso__r.Account.Renda__c) : '';                    
                        integer index = seguradoOriginal.pessoa.rendaMensal.indexOf('.');
                        seguradoOriginal.pessoa.rendaMensal = seguradoOriginal.pessoa.rendaMensal.substring(0,index);
                        seguradoOriginal.pessoa.tipo = 'FIS';
                        seguradoOriginal.pessoa.pessoaExpostaPoliticamente = String.valueOf(pagamento.Caso__r.Account.PEP__c)!=null? String.valueOf(pagamento.Caso__r.Account.PEP__c) : ''; //PLV-4803-FIX - INICIO/FIM
                        seguradoOriginal.pessoa.dadosPessoaFisica.fumante = pagamento.Caso__r.Account.Fumante__c == 'Sim'? true: false;
                        seguradoOriginal.pessoa.dadosPessoaFisica.dataNascimento = pagamento.Caso__r.Account.PersonBirthdate!=null? string.valueOf(pagamento.Caso__r.Account.PersonBirthdate)+'T00:00:00.000Z' : '';
                        
                        seguradoOriginal.pessoa.dadosPessoaFisica.sexo = pagamento.Caso__r.Account.Sexo__c!=null? pagamento.Caso__r.Account.Sexo__c : '';
                        seguradoOriginal.pessoa.dadosPessoaFisica.profissao = pagamento.Caso__r.Account.Profissao__r.Name!=null? pagamento.Caso__r.Account.Profissao__r.CodigoProfissao__c : '';
                        seguradoOriginal.pessoa.dadosPessoaFisica.regimeTrabalho = pagamento.Caso__r.Account.RegimeTrabalho__c!=null? pagamento.Caso__r.Account.RegimeTrabalho__c : 'CLT';
                        String cpfTemp = orcamento.contratantes[0].grupos[0].segurados[0].pessoa.dadosPessoaFisica.numeroCpf!=null? orcamento.contratantes[0].grupos[0].segurados[0].pessoa.dadosPessoaFisica.numeroCpf.replace('.', ''):'';
                        List<String> cpf = cpfTemp.split('-');
                        seguradoOriginal.pessoa.dadosPessoaFisica.numeroCpf = cpf[0]!=null? cpf[0] : '';
                        seguradoOriginal.pessoa.dadosPessoaFisica.grupoProfissao = mGrupoProfissoes.get(pagamento.Caso__r.Account.Profissao__r.Name).GrupoRisco__r.Name!=null? mGrupoProfissoes.get(pagamento.Caso__r.Account.Profissao__r.Name).GrupoRisco__r.Name : '';
                        seguradoOriginal.pessoa.dadosPessoaFisica.digitoCpf = cpf[1]!=null? cpf[1] : '';
                        for (EmissaoTO.BeneficiarioTO benef : orcamento.contratoOriginal.contratantes[0].grupos[0].segurados[0].beneficiarios) {
                            PropostaTO.Beneficiario beneficiario = new PropostaTO.Beneficiario();
                            beneficiario.tipoBeneficiario = benef.tipoBeneficiario; 
                            beneficiario.percentualIndenizacao = Integer.valueOf(benef.percentualIndenizacao);
                            beneficiario.participacao = Integer.valueOf(benef.participacao);
                            beneficiario.imprimirCertificado = benef.imprimirCertificado;
                            seguradoOriginal.beneficiarios.add(beneficiario);
                        }
                        seguradoOriginal.coberturas = listCobertura;
                    }
                    grupoOriginal.segurados.add(seguradoOriginal);
                    contratanteOriginal.grupos.add(grupoOriginal);
                }
                request.contratoOriginal.contratantes.add(contratanteOriginal);

                request.remuneracoes = new List<PropostaTO.Remuneracao>();
                for(FavorecidoRemuneracaoContrato__c lf: listFavorecido){
                    if (lf.RemuneracaoContrato__r.Contrato__c==pagamento.Caso__r.Contrato__c) {                    
                        PropostaTO.Remuneracao remuneracao = new PropostaTO.Remuneracao();
                        remuneracao.percentual = lf.RemuneracaoContrato__r.Percentual__c;
                        remuneracao.tipoRemuneracao =  lf.RemuneracaoContrato__r.TipoRemuneracao__r.Codigo__c;
                        remuneracao.favorecidos = new List<PropostaTO.Favorecido>();
                        PropostaTO.Favorecido favorecido = new PropostaTO.Favorecido();
                        favorecido.papel = lf.RemuneracaoContrato__r.TipoRemuneracao__r.Codigo__c;
                        favorecido.participacao = lf.Participacao__c;
                        favorecido.corretorLider = lf.CorretorLider__c;
                        favorecido.susep = lf.Susep__c;
                        favorecido.antecipacaoComissao = lf.AntecipacaoComissao__c;

                        favorecido.pessoa = new PropostaTO.Pessoa();
                        favorecido.pessoa.nome = lf.Conta__r.Name;
                        remuneracao.favorecidos.add(favorecido);
                        request.remuneracoes.add(remuneracao);
                    }
                }

                request.contratantes = new List<PropostaTO.Contratante>();
                PropostaTO.Contratante contratante = new PropostaTO.Contratante();
                contratante.tipo = 'PRI'; 
                contratante.numero = 1;
            
                contratante.grupos = new List<PropostaTO.Grupos>();
                for( GrupoContrato__c grupoContrato : lstGrupoContrato ){
                    if (pagamento.Caso__r.Contrato__c == grupoContrato.ContratanteContrato__r.Contrato__c) {
                        
                        PropostaTO.Grupos grupo = new PropostaTO.Grupos();
                        grupo.tipoCalculo = grupoContrato.TipoCalculo__c;//!=null? grupoContrato.TipoCalculo__c : ''; //PLV-4803-FIX - INICIO/FIM
                        grupo.tarifa = '0';
                        grupo.numero = Integer.valueOf(grupoContrato.Numero__c)!=null?Integer.valueOf(grupoContrato.Numero__c) : 0;
                        grupo.nome = grupoContrato.Name!=null? grupoContrato.Name : '';                   
                        grupo.qtdeVidas = Double.valueOf(grupoContrato.QuantidadeVidas__c)!=null? Double.valueOf(grupoContrato.QuantidadeVidas__c) : 0.0; //PLV-4803-FIX - INICIO/FIM
                        grupo.segurados = new List<PropostaTO.Segurado>();
                        PropostaTO.Segurado segurado = new PropostaTO.Segurado();
                        segurado.numero = 1;
                        segurado.pessoa = new PropostaTO.Pessoa();
                        segurado.pessoa.nome = pagamento.Caso__r.Account.Name;
                        segurado.pessoa.dadosPessoaFisica = new PropostaTO.DadosPessoaFisica();
                        segurado.pessoa.dadosPessoaFisica.dataNascimento = pagamento.Caso__r.Account.PersonBirthdate!=null? string.valueOf(pagamento.Caso__r.Account.PersonBirthdate)+'T00:00:00.000Z' : '';
                        segurado.pessoa.dadosPessoaFisica.sexo = pagamento.Caso__r.Account.Sexo__c!=null? pagamento.Caso__r.Account.Sexo__c : '';
                        segurado.pessoa.dadosPessoaFisica.fumante = pagamento.Caso__r.Account.Fumante__c == 'Sim'? true: false;
                        String cpfTemp = orcamento.contratantes[0].grupos[0].segurados[0].pessoa.dadosPessoaFisica.numeroCpf!=null? orcamento.contratantes[0].grupos[0].segurados[0].pessoa.dadosPessoaFisica.numeroCpf.replace('.', ''):'';
                        List<String> cpf = cpfTemp.split('-');
                        segurado.pessoa.dadosPessoaFisica.numeroCpf = cpf[0]!=null? cpf[0]:'';                         
                        segurado.pessoa.dadosPessoaFisica.digitoCpf = cpf[1]!=null? cpf[1]:'';
                        segurado.pessoa.dadosPessoaFisica.profissao = pagamento.Caso__r.Account.Profissao__r.CodigoProfissao__c!=null? pagamento.Caso__r.Account.Profissao__r.CodigoProfissao__c: '';
                        List<PropostaTO.Endereco> listPessoaEnderecos = new List<PropostaTO.Endereco>();
                        if(mapAccountEndereco.containsKey(pagamento.Caso__r.AccountId)){
                            Endereco__c endereco = mapAccountEndereco.get(pagamento.Caso__r.AccountId);
                            PropostaTo.Endereco enderecoTO = new PropostaTO.Endereco();
                            enderecoTO.tipoEndereco = 'PES';
                            if(endereco.tipoEndereco__c != null && (endereco.tipoEndereco__c == 'Residencial' ||  endereco.tipoEndereco__c == 'RES')){
                                enderecoTO.tipoEndereco = 'RES';    
                            }
                            //(Select id, name, tipoendereco__c, Bairro__c, Cidade__c, logradouro__c, Estado__c, Complemento__c, CEP__c,Numero__c from Enderecos__r Where MaisAtual__c = true) 
                            enderecoTO.logradouro = endereco.logradouro__c!=null? endereco.logradouro__c:'';
                            enderecoTO.numeroLogradouro = endereco.Numero__c!=null? endereco.Numero__c:'';
                            enderecoTO.bairro = endereco.Bairro__c!=null? endereco.Bairro__c:'';
                            enderecoTO.cidade = endereco.Cidade__c!=null? endereco.Cidade__c:'';
                            enderecoTO.uf = endereco.Estado__c!=null? endereco.Estado__c:'';
                            enderecoTO.cep = endereco.CEP__c!=null? endereco.CEP__c:'';
                            enderecoTO.cep = (enderecoTO.cep != '') ? enderecoTO.cep.subString(0,5) : '';
                            
                            enderecoTO.complemento = endereco.Complemento__c!=null? endereco.Complemento__c:'';
                            enderecoTO.complementoCep = (enderecoTO.cep != '') ? enderecoTO.cep.subString(enderecoTO.cep.length()-3,enderecoTO.cep.length()) : '';
                            listPessoaEnderecos.add(enderecoTO);
                            //endereco.tipoEndereco = /*enderecoTemp.tipoEndereco!=null? enderecoTemp.tipoEndereco:*/'RES';
                            //endereco.logradouro = /*enderecoTemp.logradouro!=null? enderecoTemp.logradouro:*/'Rua dos navegantes';
                            //endereco.numeroLogradouro = /*enderecoTemp.numeroLogradouro !=null? enderecoTemp.numeroLogradouro:*/'1120';
                            //endereco.bairro = /*enderecoTemp.bairro!=null? enderecoTemp.bairro:*/'Boa viagem';
                            //endereco.cidade = /*enderecoTemp.cidade!=null? enderecoTemp.cidade:*/'Recife';
                            //endereco.uf = /*enderecoTemp.uf!=null? enderecoTemp.uf:*/'PE';
                            //endereco.cep = /*enderecoTemp.cep!=null? enderecoTemp.cep:*/'51020';
                            //endereco.complemento = /*enderecoTemp.complemento!=null? enderecoTemp.complemento:*/'Casa';
                            //endereco.complementoCep = /*enderecoTemp.complementoCep!=null? enderecoTemp.complementoCep:'010';
                            //endereco.complementoCep = '010';
                            
                        
                        }
                        segurado.pessoa.enderecos = listPessoaEnderecos;
                        
                        
                        segurado.pessoa.dadosPessoaFisica.grupoProfissao = mGrupoProfissoes.get(pagamento.Caso__r.Account.Profissao__r.Name).GrupoRisco__r.Name!=null? mGrupoProfissoes.get(pagamento.Caso__r.Account.Profissao__r.Name).GrupoRisco__r.Name:'';
                        segurado.pessoa.dadosPessoaFisica.regimeTrabalho = pagamento.Caso__r.Account.RegimeTrabalho__c!=null? segurado.pessoa.dadosPessoaFisica.regimeTrabalho = pagamento.Caso__r.Account.RegimeTrabalho__c:'CLT';
                        segurado.pessoa.rendaMensal = pagamento.Caso__r.Account.Renda__c!=null? String.valueOf(pagamento.Caso__r.Account.Renda__c):'';
                        segurado.pessoa.tipo = 'FIS';
                        segurado.pessoa.pessoaExpostaPoliticamente = String.valueOf(pagamento.Caso__r.Account.PEP__c)!=null? String.valueOf(pagamento.Caso__r.Account.PEP__c) : ''; //PLV-4803-FIX - INICIO/FIM
                        
                        segurado.empresaQueTrabalha = pagamento.Caso__r.Account.EmpresaTrabalhaSocio__c;
                        segurado.ramoAtividade = '';
                        if (pagamento.Caso__r.Account.RamoAtividade__c!=null) {
                            segurado.ramoAtividade = pagamento.Caso__r.Account.RamoAtividade__c;                            
                        }
                        segurado.ocupacaoProfissionalPrincipal = pagamento.Caso__r.Account.Profissao__r.CodigoProfissao__c;
                        segurado.faixaRenda = pagamento.Caso__r.Account.Renda__c!=null? String.valueOf(pagamento.Caso__r.Account.Renda__c):'';
                        segurado.formaTrabalho = pagamento.Caso__r.Account.RegimeTrabalho__c!=null? pagamento.Caso__r.Account.RegimeTrabalho__c:'CLT';
                        segurado.responsavelFinanceiro = true;

                        segurado.coberturas = new List<PropostaTO.Cobertura>();
                        
                        for( GarantiaContrato__c eCobertura : listGarantias ){
                            if (eCobertura.Contrato__c==pagamento.Caso__r.Contrato__c&&eCobertura.Garantia__r.Sigla__c!=pagamento.Garantia_do_segurado_do_contrato__r.Garantia__r.Sigla__c) {
                                
                                PropostaTO.Cobertura cobertura = new PropostaTO.Cobertura();
                                cobertura.valor = eCobertura.Capital__c!=null? Integer.valueOf(eCobertura.Capital__c) : 0;
                                cobertura.sigla = eCobertura.Garantia__r.Sigla__c;
                                cobertura.quantidade = eCobertura.GarantiaProduto__r.QuantidadeMaximaContratacao__c!=null?Integer.valueOf(eCobertura.GarantiaProduto__r.QuantidadeMaximaContratacao__c):0;
                                cobertura.moeda = eCobertura.MoedaGarantia__c!=null? eCobertura.MoedaGarantia__c:'';
                                cobertura.franquia = eCobertura.FranquiaGarantia__c!=null? eCobertura.FranquiaGarantia__r.CodigoFranquia__c:'';
                                cobertura.cotacaoMoeda = eCobertura.ValorCotacao__c!=null? String.valueOf(eCobertura.ValorCotacao__c): '0';
                                cobertura.cobrado = '';
                                
                                segurado.coberturas.add( cobertura );
                            }
                        }
                        segurado.beneficiarios = new List<PropostaTO.Beneficiario>();
                        List<PropostaTO.Beneficiario> beneficiarios = new List<PropostaTO.Beneficiario>();
                        for (EmissaoTO.BeneficiarioTO benef : orcamento.contratoOriginal.contratantes[0].grupos[0].segurados[0].beneficiarios) {
                            PropostaTO.Beneficiario beneficiario = new PropostaTO.Beneficiario();
                            beneficiario.tipoBeneficiario = benef.tipoBeneficiario; 
                            beneficiario.percentualIndenizacao = Integer.valueOf(benef.percentualIndenizacao);
                            beneficiario.participacao = Integer.valueOf(benef.participacao);
                            beneficiario.imprimirCertificado = benef.imprimirCertificado;
                            segurado.beneficiarios.add(beneficiario);
                        }
                        if(mapRespostas.containskey(pagamento.Caso__r.Contrato__c)){
                            List<PropostaTO.Resposta> respostas = new List<PropostaTO.Resposta>();
                            PropostaTO.Questionario questionario = new PropostaTO.Questionario();
                            questionario.respostas = new List<PropostaTO.Resposta>();
                            for(RespostaDeclaracaoSaude__c respostaSaude : mapRespostas.get(pagamento.Caso__r.Contrato__c)){
                                if(questionario.idquestionario == null){
                                    questionario.idquestionario = respostaSaude.DeclaraoSaude__r.QuestionarioRisco__c;
                                }
                                PropostaTO.Resposta resposta = new PropostaTO.Resposta();
                                resposta.questao = respostaSaude.PerguntaQuestionarioRisco__c;
                                resposta.resposta = respostaSaude.Resposta__c ;
                                questionario.respostas.add(resposta);
                            }
                            segurado.questionario = questionario;
                        }


                        grupo.segurados.add( segurado );
                        contratante.grupos.add( grupo );
                    }
                }
                PropostaTO.Pessoa pessoa = new PropostaTO.Pessoa();
                pessoa.tipo = orcamento.contratantes[0].grupos[0].segurados[0].pessoa.tipo!=null? orcamento.contratantes[0].grupos[0].segurados[0].pessoa.tipo:'';
                pessoa.pessoaExpostaPoliticamente = orcamento.contratantes[0].grupos[0].segurados[0].pessoa.pessoaExpostaPoliticamente!=null? String.valueOf(orcamento.contratantes[0].grupos[0].segurados[0].pessoa.pessoaExpostaPoliticamente):'';
                pessoa.rendaMensal = orcamento.contratantes[0].grupos[0].segurados[0].pessoa.rendaMensal!=null? String.valueOf(orcamento.contratantes[0].grupos[0].segurados[0].pessoa.rendaMensal):'';
                pessoa.nome = orcamento.contratantes[0].grupos[0].segurados[0].pessoa.nome!=null? orcamento.contratantes[0].grupos[0].segurados[0].pessoa.nome:'';
                pessoa.dadosPessoaFisica = new PropostaTO.DadosPessoaFisica();
                pessoa.dadosPessoaFisica.sexo = orcamento.contratantes[0].grupos[0].segurados[0].pessoa.dadosPessoaFisica.sexo!=null? orcamento.contratantes[0].grupos[0].segurados[0].pessoa.dadosPessoaFisica.sexo:'';
                pessoa.dadosPessoaFisica.regimeTrabalho = orcamento.contratantes[0].grupos[0].segurados[0].pessoa.dadosPessoaFisica.regimeTrabalho!=null? orcamento.contratantes[0].grupos[0].segurados[0].pessoa.dadosPessoaFisica.regimeTrabalho:'';
                pessoa.dadosPessoaFisica.profissao = orcamento.contratantes[0].grupos[0].segurados[0].pessoa.dadosPessoaFisica.profissao!=null? orcamento.contratantes[0].grupos[0].segurados[0].pessoa.dadosPessoaFisica.profissao:'';
                String cpfTemp = orcamento.contratantes[0].grupos[0].segurados[0].pessoa.dadosPessoaFisica.numeroCpf!=null? orcamento.contratantes[0].grupos[0].segurados[0].pessoa.dadosPessoaFisica.numeroCpf.replace('.', ''):'';
                List<String> cpf = cpfTemp.split('-');
                pessoa.dadosPessoaFisica.numeroCpf = cpf[0];
                pessoa.dadosPessoaFisica.fumante = orcamento.contratantes[0].grupos[0].segurados[0].pessoa.dadosPessoaFisica.fumante!=null? orcamento.contratantes[0].grupos[0].segurados[0].pessoa.dadosPessoaFisica.fumante: false;
                pessoa.dadosPessoaFisica.digitoCpf = cpf[1];
                pessoa.dadosPessoaFisica.dataNascimento = pagamento.Caso__r.Account.PersonBirthdate!=null? string.valueOf(pagamento.Caso__r.Account.PersonBirthdate)+'T00:00:00.000Z' : '';
                List<PropostaTO.Endereco> listEnderecos = new List<PropostaTO.Endereco>();
                if(mapAccountEndereco.containsKey(pagamento.Caso__r.AccountId)){
                    Endereco__c endereco = mapAccountEndereco.get(pagamento.Caso__r.AccountId);
                    PropostaTo.Endereco enderecoTO = new PropostaTO.Endereco();
                    enderecoTO.tipoEndereco = 'PES';
                    if(endereco.tipoEndereco__c != null && (endereco.tipoEndereco__c == 'Residencial' ||  endereco.tipoEndereco__c == 'RES')){
                        enderecoTO.tipoEndereco = 'RES';    
                    }
                    
                    enderecoTO.logradouro = endereco.logradouro__c!=null? endereco.logradouro__c:'';
                    enderecoTO.numeroLogradouro = endereco.Numero__c!=null? endereco.Numero__c:'';
                    enderecoTO.bairro = endereco.Bairro__c!=null? endereco.Bairro__c:'';
                    enderecoTO.cidade = endereco.Cidade__c!=null? endereco.Cidade__c:'';
                    enderecoTO.uf = endereco.Estado__c!=null? endereco.Estado__c:'';
                    enderecoTO.cep = endereco.CEP__c!=null? endereco.CEP__c:'';
                    enderecoTO.cep = (enderecoTO.cep != '') ? enderecoTO.cep.subString(0,5) : '';
                    enderecoTO.complemento = endereco.Complemento__c!=null? endereco.Complemento__c:'';
                    enderecoTO.complementoCep = (enderecoTO.cep != '') ? enderecoTO.cep.subString(enderecoTO.cep.length()-3,enderecoTO.cep.length()) : '';
                    
                    listEnderecos.add(enderecoTO);
                }
            
                //for (EmissaoTO.EnderecoTO enderecoTemp : orcamento.contratoOriginal.contratantes[0].grupos[0].segurados[0].pessoa.enderecos) {
                //    PropostaTo.Endereco endereco = new PropostaTO.Endereco();
                //    endereco.tipoEndereco = /*enderecoTemp.tipoEndereco!=null? enderecoTemp.tipoEndereco:*/'RES';
                //    endereco.logradouro = /*enderecoTemp.logradouro!=null? enderecoTemp.logradouro:*/'Rua dos navegantes';
                //    endereco.numeroLogradouro = /*enderecoTemp.numeroLogradouro !=null? enderecoTemp.numeroLogradouro:*/'1120';
                //    endereco.bairro = /*enderecoTemp.bairro!=null? enderecoTemp.bairro:*/'Boa viagem';
                //    endereco.cidade = /*enderecoTemp.cidade!=null? enderecoTemp.cidade:*/'Recife';
                //    endereco.uf = /*enderecoTemp.uf!=null? enderecoTemp.uf:*/'PE';
                //    endereco.cep = /*enderecoTemp.cep!=null? enderecoTemp.cep:*/'51020';
                //    endereco.complemento = /*enderecoTemp.complemento!=null? enderecoTemp.complemento:*/'Casa';
                    //endereco.complementoCep = /*enderecoTemp.complementoCep!=null? enderecoTemp.complementoCep:'010';
                //    endereco.complementoCep = '010';
                //    listEnderecos.add(endereco);
                //}
                pessoa.enderecos = listEnderecos;
                contratante.pessoa = pessoa;
                pessoa.telefones = new List<PropostaTO.Telefone>();
                //Caso__r.Account.PersonHomePhone, Caso__r.Account.PersonMobilePhone, Caso__r.Account.Phone
                //PropostaTO.Telefone telefone = new PropostaTO.Telefone();
                // telefone.tipoTelefone = 'RES';
                // telefone.numeroTelefone = '12344321';
                // telefone.dddTelefone = '15';
                // pessoa.telefones.add(telefone);
                if(pagamento.Caso__r.Account.PersonHomePhone != null){
                    PropostaTO.Telefone telefone = new PropostaTO.Telefone();
                    telefone.tipoTelefone = 'Residencial';
                    String numero = pagamento.Caso__r.Account.PersonHomePhone.replace('-','').replace('(','').replace(')','').replace(' ','');
                    telefone.numeroTelefone = numero.subString(2,numero.length());
                    telefone.dddTelefone = numero.subString(0,2);
                    pessoa.telefones.add(telefone);
                }
                if(pagamento.Caso__r.Account.PersonMobilePhone != null){
                    PropostaTO.Telefone telefone = new PropostaTO.Telefone();
                    telefone.tipoTelefone = 'Celular';
                    String numero = pagamento.Caso__r.Account.PersonMobilePhone.replace('-','').replace('(','').replace(')','').replace(' ','');
                    telefone.numeroTelefone = numero.subString(2,numero.length());
                    telefone.dddTelefone = numero.subString(0,2);
                    pessoa.telefones.add(telefone);
                }
                if(pagamento.Caso__r.Account.Phone != null){
                    PropostaTO.Telefone telefone = new PropostaTO.Telefone();
                    telefone.tipoTelefone = 'Comercial';
                    String numero = pagamento.Caso__r.Account.Phone.replace('-','').replace('(','').replace(')','').replace(' ','');
                    telefone.numeroTelefone = numero.subString(2,numero.length());
                    telefone.dddTelefone = numero.subString(0,2);
                    pessoa.telefones.add(telefone);
                }
                ContratanteContrato__c contratanteContrato = mContratante.get(pagamento.Caso__r.AccountId);
                PropostaTO.DadosPagamento pag = new PropostaTO.DadosPagamento();
                pag.opcao = 1;
                pag.codigoFormaPagamento = Integer.valueOf(pagamento.Caso__r.Contrato__r.FormaPagamento__r.Codigo__c);
                pag.quantidadeParcelas = Integer.valueOf(contratanteContrato.QuantidadeParcelas__c);
                pag.formaPagamento = new PropostaTO.FormaPagamento();
                pag.formaPagamento.codigo = Integer.valueOf(pagamento.Caso__r.Contrato__r.FormaPagamento__r.Codigo__c);
                pag.formaPagamento.descricao = pagamento.Caso__r.Contrato__r.FormaPagamento__r.Name;
                pag.formaPagamento.idFormaPagamento = pagamento.Caso__r.Contrato__r.FormaPagamento__c;
                pag.formaPagamento.planoParcelamento = new PropostaTO.PlanoParcelamento();
                pag.formaPagamento.planoParcelamento.idPlanoParcelamento = String.valueOf(contratanteContrato.PlanoParcelamento__r.NumeroParcela__c);
                pag.formaPagamento.planoParcelamento.quantidadeParcelas = Integer.valueOf(contratanteContrato.PlanoParcelamento__r.NumeroParcela__c);
                pag.tipoResponsavelPagamento = contratanteContrato.TipoResponsavelPagamento__c;
                pag.vencimentoDemaisParcelas = contratanteContrato.VencimentoDemaisParcelas__c;
                pag.vigenciaInicial = String.valueOf(contratanteContrato.VigenciaInicial__c);
                pag.vencimentoPrimeiraParcela = String.valueOf(contratanteContrato.VencimentoPrimeiraParcela__c);
                if (contratanteContrato.InformacaoBancaria__c!=null) {
                    pag.dadosBancarios = new PropostaTO.DadosBancarios();
                    pag.dadosBancarios.agencia = contratanteContrato.InformacaoBancaria__r.Agencia__c;     
                    pag.dadosBancarios.banco = contratanteContrato.InformacaoBancaria__r.Banco__c;     
                    pag.dadosBancarios.conta = contratanteContrato.InformacaoBancaria__r.NumeroConta__c;
                    pag.dadosBancarios.digitoConta = contratanteContrato.InformacaoBancaria__r.Digito__c;
                    pag.dadosBancarios.digitoAgencia = '0';
                    pag.dadosBancarios.tipoPessoa = contratanteContrato.InformacaoBancaria__r.TipoPessoa__c;
                    pag.dadosBancarios.cpf = Pagamento.Caso__r.Account.Cpf__c.replace('.', '').replace('-', '');
                }
                if (contratanteContrato.CartaoCredito__c!=null) {
                    pag.opcao = 2;
                    System.debug('cartao1> ' + JSON.serialize(contratanteContrato.CartaoCredito__c));
                    PropostaTO.DadosCartaoCredito cartaoCredito = new PropostaTO.DadosCartaoCredito();
                    cartaoCredito.ticket = contratanteContrato.CartaoCredito__r.Ticket__c;
                    cartaoCredito.validade = contratanteContrato.CartaoCredito__r.Vencimento__c; // PLV-4803 - FIX2 - INICIO/FIM
                    cartaoCredito.numero = contratanteContrato.CartaoCredito__r.NumeroCartao__c; // PLV-4803 - FIX3 - INICIO/FIM
                    pag.dadosCartaoCredito = cartaoCredito;                    
                    
                    System.debug('cartao2> ' + JSON.serialize(cartaoCredito));
                }
                contratante.dadosPagamento = pag;
                request.contratantes.add(contratante);
                PropostaTO.Root proposta = new PropostaTO.Root();
                proposta.propostas.add(request);
                payload = JSON.serialize(proposta, true);

                //MGRC-1571-INICIO TRANSMISSAO ENDOSSO
                Map<String, Object> calculosMap = (Map<String, Object>) JSON.deserializeUntyped(payload);
                String retornoSensedia;
                String codigoProdutoVida;
                String tipoSeguro;

                if (calculosMap.containsKey('propostas') && calculosMap.get('propostas') != null) {
                    List<Object> propostasList = (List<Object>) calculosMap.get('propostas');

                    if (!propostasList.isEmpty()) {
                        // Acessa o primeiro item da lista 'propostas'
                        Map<String, Object> propostaMap = (Map<String, Object>) propostasList[0];
                        tipoSeguro = (String) propostaMap.get('tipoSeguro');
                        System.debug('tipoSeguro preenchido: ' + tipoSeguro);

                        // Acessa o campo 'proposta'
                        if (propostaMap.containsKey('proposta') && propostaMap.get('proposta') != null) {
                            Map<String, Object> propostaInnerMap = (Map<String, Object>) propostaMap.get('proposta');
                            
                            // Acessa o campo 'contratoOriginal'
                            if (propostaInnerMap.containsKey('contratoOriginal') && propostaInnerMap.get('contratoOriginal') != null) {
                                Map<String, Object> contratoOriginalMap = (Map<String, Object>) propostaInnerMap.get('contratoOriginal');
                                
                                // Acessa o campo 'codigoProdutoVida'
                                if (contratoOriginalMap.containsKey('codigoProdutoVida')) {
                                    codigoProdutoVida = (String) contratoOriginalMap.get('codigoProdutoVida');
                                    System.debug('codigoProdutoVida preenchido => ' + codigoProdutoVida);
                                }
                            }
                        }
                    }

                    if (!Test.isRunningTest()) {
                        System.debug('payload: ====>>>' + payload);

                        switch on codigoProdutoVida {
                            //MGRC-1583-INICIO
                            when 'VIDA_ON' {
                                if (tipoSeguro == 'EDS') {
                                    retornoSensedia = SensediaServices.getInstance().montagemServicoSensedia(
                                        SensediaServices.VERB.POST, 
                                        SensediaServices.DOMAIN.AWS_EXTERNO_EMISSAO, 
                                        SensediaServices.TRANSMISSAO_CONTRATACAO_ENDOSSO_VIDA_ON, 
                                        payload
                                    );
                                } else {
                                    System.debug('Falha na transmissão - VIDA_ON');
                                }
                            }
                            //MGRC-1583-FIM
                            //MGRC-1581-INICIO
                            when 'VI-PESSOAS' {
                                if (tipoSeguro == 'EDS') {
                                    retornoSensedia = SensediaServices.getInstance().montagemServicoSensedia(
                                        SensediaServices.VERB.POST, 
                                        SensediaServices.DOMAIN.AWS_EXTERNO_EMISSAO, 
                                        SensediaServices.TRANSMISSAO_CONTRATACAO_ENDOSSO_VDSJ, 
                                        payload
                                    );
                                } else {
                                    System.debug('Falha na transmissão - VI-PESSOAS');
                                }
                            }
                            //MGRC-1581-FIM
                            //MGRC-1582-INICIO
                            when 'APTLMKT' {
                                if (tipoSeguro == 'EDS') {
                                    retornoSensedia = SensediaServices.getInstance().montagemServicoSensedia(
                                        SensediaServices.VERB.POST, 
                                        SensediaServices.DOMAIN.AWS_EXTERNO_EMISSAO, 
                                        SensediaServices.TRANSMISSAO_CONTRATACAO_ENDOSSO_APTLMKT, 
                                        payload
                                    );
                                } else {
                                    System.debug('Falha na transmissão - APTLMKT');
                                }
                            }
                            //MGRC-1582-FIM
                        }

                        System.debug('retorno: ====>>>' + retornoSensedia);
                        //MGRC-1571-BUGFIX-INICIO
                    } else {
                        // String retorno = CIVServices.getInstance().criacaoTransmissao(payload); 
                        // System.debug('retorno: ====>>>' + retorno);
                        //MGRC-1571-BUGFIX-FIM
                    }                 
                }
                //MGRC-1571-FIM TRANSMISSAO ENDOSSO
            }
        }
    }
}
//PLV-4772-FIM