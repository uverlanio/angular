/****
@description Classe TO do componente de recalculo da proposta
@author Isabela Fin - Globant / Pedro Braz - Sys4b
@date 30/10/2020
@Classe referente a historia PLV-4544      
*****/
public with sharing class RecalculoPropostaTO {
    public RecalculoPropostaTO() {
        List<CalculosTO> calculos = new List<CalculosTO>();
    }
    public List<CalculosTO> calculos;

    public class DadosPessoaFisica {
		//PLV - 4694 INICIO
        public String cboProfissao {get;set;}
		public String dependentes; 
		//public String tipoContrato;
		public String tempoGarantiaRenda;
		public String dataNascimento;
		public String sexo;
		public Boolean fumante;
        public String regimeTrabalho;
        public String nacionalidade;
        public String paisDeOrigem; //PLV-5231 INICIO/FIM
        public String estadoCivil;
        public String grupoProfissao;
        //public String renda;
        //public String nome;
        public String faixaRendaInicial {get;set;}
        public String faixaRendaFinal {get;set;}
        public List<DocumentoTO> documentos {get;set;}
		//PLV - 4694 FIM
	}

	public class VersoesCalculos {
		public Integer opcao;
		public String tipo;
		public Double descontoAgravo;
	}

	public class IndiceMonetario {
        public ValidacaoZeroDolarTO validacaoZeroDolar { get; set; }
		public List<ItensCotacao> ItensCotacao;
    }
    public class ValidacaoZeroDolarTO {
        public Integer codigo { get; set; }
        public String mensagem { get; set; }
        public Integer codigoGateway { get; set; }
        public String mensagemGateway { get; set; }        
    }

    //PLV-4851 - INICIO - PEDRO AUGUSTO BRAZ - SYS4B
	public class Remuneracoes {
        @AuraEnabled public String id {get;set;}
        @AuraEnabled public String codigo {get;set;} 
		@AuraEnabled public String tipoRemuneracao {get;set;}
        @AuraEnabled public String name {get;set;} 
        @AuraEnabled public String simbolo {get;set;} 
		@AuraEnabled public Integer percentual {get;set;}
        @AuraEnabled public Decimal limiteMaximo {get;set;} 
        @AuraEnabled public Decimal limiteMinimo {get;set;} 
        @AuraEnabled public Boolean obrigatorio {get;set;} 
        @AuraEnabled public List<Integer> opcoes {get;set;} 
    }
    //PLV-4851 - FIM - PEDRO AUGUSTO BRAZ - SYS4B
	//PLV - 4694 INICIO
    public class TelefoneTO{
        public String tipoTelefone;
        public String numeroTelefone;
        public String dddTelefone;
    }
	//PLV - 4694 FIM

	public class PessoaTO {
		public String tipo;
		public List<EnderecosTO> enderecos;
		public String nome;
        public String email;
        public DadosPessoaFisica dadosPessoaFisica { get; set; }
        public List<TelefoneTO> telefones; //PLV - 4694 INICIO/FIM



        public PessoaTO preencherDadosContaPessoaFisica(SeguradoProposta__c segurado) {
        	//PLV - 4694 INICIO
            //this.nome = segurado.Conta__r.name;
            this.email = segurado.Conta__r.Email__c != null ? segurado.Conta__r.Email__c : '';
            this.tipo = '';
            this.dadosPessoaFisica = new DadosPessoaFisica();
            this.dadosPessoaFisica.dataNascimento = String.valueOf(segurado.Conta__r.PersonBirthdate);
            this.dadosPessoaFisica.fumante = segurado.Conta__r.Fumante__c=='Sim' ? true:false;
            this.dadosPessoaFisica.cboprofissao = segurado.Conta__r.Profissao__r.Codigo__c;
            this.dadosPessoaFisica.regimeTrabalho = segurado.Conta__r.RegimeTrabalho__c;
            //this.dadosPessoaFisica.renda = String.valueOf(segurado.Conta__r.Renda__c);
            this.dadosPessoaFisica.sexo = segurado.Conta__r.Sexo__c;
            this.dadosPessoaFisica.fumante = false;
            this.enderecos = new List<EnderecosTO>();
            List<Endereco__c> enderecos = [SELECT Id, Cidade__c, TipoEndereco__c, Complemento__c, Logradouro__c, Bairro__c,
            CEP__c, Pais__C, Numero__C, Estado__c FROM Endereco__c WHERE Conta__r.Id =:segurado.conta__c];

            system.debug('ende: '+enderecos);
            for(Endereco__c ende : enderecos){                
                this.enderecos.add(new RecalculoPropostaTO.EnderecosTO().dtoEndereco(ende));
            }
            
            //DOCUMENTOS DOS DADOS DA PESSOA FISICA DO SEGURADO
            this.dadosPessoaFisica.documentos = new List<DocumentoTO>();
             DocumentoTO documentoItem = new DocumentoTO();
            documentoItem.tipoDocumentoIdentidade = '';
            documentoItem.orgaoExpedidorDocumento = '';
            documentoItem.numeroDocumento = '';
            documentoItem.dataExpedicaoDocumento = '';
            this.dadosPessoaFisica.documentos.add(documentoItem);
            this.telefones = new List<TelefoneTO>();
            TelefoneTO t = new TelefoneTO();
            t.tipoTelefone = '';
            t.numeroTelefone = '';
            t.dddTelefone = '';
            this.telefones.add(t);
            this.dadosPessoaFisica.nacionalidade = '';
            this.dadosPessoaFisica.paisDeOrigem = ''; //PLV-5231 INICIO/FIM
            this.dadosPessoaFisica.estadoCivil = '';
            // PLV-5185 INCIO
            // this.dadosPessoaFisica.grupoProfissao= segurado.GrupoRisco__c; //PLV-5161 INICIO/FIM
            this.dadosPessoaFisica.grupoProfissao = segurado.GrupoRisco__c != null ? segurado.GrupoRisco__c : '';
            // PLV-5185 FIM
            this.dadosPessoaFisica.dependentes = segurado.TemDependentes__c == true?'sim':'não' ;


            //PLV-4694 - FIM


            return this;
        }
	}

	public class CoberturasTO {
		public String franquia;
		public String sigla;
		public String moeda;
		public Integer limitemaximo;
		public String caracteristica;
		public Integer valor;
		public String tipoprotecao;
		public Integer caracteristicaespecialvalor;
		public Integer limiteminimo;
        public String caracteristicaespecialtipo;
        public List<DescontoAgravoTO> descontoAgravo { get; set; }
        public Decimal  quantidade; //PLV-5103 INICIO/FIM

        public CoberturasTO dtoCobertura(Garantias pGarantia){
            this.franquia                       =   null;
            this.sigla                          =   pGarantia.cobertura;
            this.moeda                          =   pGarantia.isoCode;
            this.limitemaximo                   =   Integer.valueOf(pGarantia.limiteCapitalMaximo);
            this.valor                          =   Integer.valueOf(pGarantia.capital);
            this.tipoprotecao                   =   null;
            this.caracteristicaespecialvalor    =   null;
            this.limiteminimo                   =   null;
            this.caracteristicaespecialtipo     =   null;
            this.caracteristica                 =   pGarantia.caracteristica;
            //this.obrigatorio                    =   pGarantia.caracteristica;    
            this.quantidade                      =   null; //PLV-5103 INICIO/FIM
            return this;
        }
		//PLV - 4694 INICIO
        public CoberturasTO dtoCoberturaPrecificacao(Garantias pGarantia){

            this.franquia                       =   null;
            this.sigla                          =   pGarantia.cobertura;
            this.moeda                          =   null;
            this.limitemaximo                   =   null;
            this.valor                          =   null;
            this.tipoprotecao                   =   null;
            this.caracteristicaespecialvalor    =   null;
            this.limiteminimo                   =   null;
            this.caracteristicaespecialtipo     =   null;
            this.caracteristica                 =   null;
            this.quantidade                      =   null; //PLV-5103 INICIO/FIM
            //DESCONTO AGRAVO DA COBERTURA
            List<DescontoAgravoTO> descontosAgravosList = new List<DescontoAgravoTO>();
            DescontoAgravoTO descontoAgravoItem = new DescontoAgravoTO();
            descontoAgravoItem.tipo =  'TEC';
            //pra concluir essa parte, é necessário revisar retorno do valor do desconto agravo preenchido na tela do componente
            if (pGarantia.tipoDescontoAgravo == 'Monetário') {
                descontoAgravoItem.monetario = pGarantia.descontoAgravo;
                //descontoAgravoItem.percentual = 0.0;
            } else if (pGarantia.tipoDescontoAgravo == 'Porcentagem') {
                //descontoAgravoItem.monetario = 0.0;
                descontoAgravoItem.percentual = pGarantia.descontoAgravo;

            }
    
            descontosAgravosList.add(descontoAgravoItem);        
            this.descontoAgravo = descontosAgravosList; 
            return this;              
            
        }
		//PLV - 4694 FIM
    }
    
    public class DescontoagravoTO
    {
        public Decimal percentual { get; set; }
        public String tipo { get; set; }
        public Decimal monetario { get; set; }
    }
	//PLV - 4694 INICIO
    public class PremioTO {
        public Decimal minimo { get; set; }
        public DescontoagravoTO descontoAgravoPremio { get; set; }
    }

    public class PrecificacaoTO {
        public PremioTO premio { get; set; }
        public List<CoberturasTO> coberturas {get; set;}
        public List<DescontoagravoTO> descontoAgravo {get; set;}
    }

    //ESSES CONSTRUTORES SÃO PRA OBTER RETORNO DO DOCUMENTO ATRIBUIDO A OPORTUNIDADE
    public class OrcamentoTO {
        public String numeroOrcamento {get; set;}
        public List<VersoesCalculos> versoesCalculos {get; set;}
    }
    public class OfertasTO {
        public OrcamentoTO orcamento {get; set;}
    }
    public class JSONResponseCalculoTO {
        public List<OfertasTO> ofertas {get; set;}
    }
    public class DocumentReturn {
        public JSONResponseCalculoTO JSONResponseCalculo {get; set;}
    }

	//PLV - 4694 FIM

	public class CalculosTO {
		public String tipoVigencia;
		public Boolean termoGuarda;
		public String tipoSeguro;
		public String vigenciaFinal;
		public String numeroOrcamento;
		public Integer numeroPortal;
		public String codigoProdutoVida;
		public Boolean customizavel;
		public List<ContratantesTO> contratantes;
		public String canalDistribuicao;
		public String meioComercializacao;
		public Boolean varConsultivo;
		public String segmento;
		public List<VersoesCalculos> versoesCalculos; // vem da gerar dados iniciais
		public Integer numeroOferta;
		public String orcnum;
		public Integer ordemPortal;
		public String rotulo;
		public String susepOrcamento;
		public Boolean gerarDocumento;
		public ResultadoIntegracoesTO resultadoIntegracoes;
		public List<Remuneracoes> remuneracoes;
		public String vigenciaInicial;
        public String dataCalculo;  
        public Decimal LimiteTotalCarregamento;//PLV-4851 - INICIO/FIM
        public Integer cicloVacinal; //PLV-5185 INICIO/FIM
		//PLV - 4694 INICIO
		public Integer qtdDiasVigencia;
        public PrecificacaoTO precificacao;   
        public Integer tempoGarantiaRenda; 
		//PLV - 4694 FIM

		//PLV - 4694 INICIO
        public CalculosTO dtoCalculo(Quote pQuote, List<SeguradoProposta__c> pSeguradosProposta, Proposta pProposta){
            //PLV-5801 - INICIO
            List<String> tipoProposta = new List<String> {'Renovacao'};
            String sufixoPadrao = '_localStorage';
            String sufixoRenovacao = '_entradaServico'; 
            //PLV-5801 - FIM

            this.tipoVigencia               = pQuote.TipoVigencia__c;
            this.tipoSeguro                 = 'Novo';
            this.vigenciaInicial            = String.valueOf(pQuote.VigenciaInicial__c);
            this.vigenciaFinal              = String.valueOf(pQuote.VigenciaFinal__c);
            this.numeroOrcamento            = pQuote.Opportunity.Numero__c;
            this.numeroPortal               = 0;
            this.codigoProdutoVida          = pQuote.Produto__r.ProductCode;
            //this.customizavel               = false;
            this.canalDistribuicao          = pQuote.CanalDistribuicao__r.Sigla__c;
            this.meioComercializacao        = pQuote.MeioComercializacao__c;
            //this.varConsultivo              = true;
            this.segmento                   = pQuote.Produto__r.Segmento__c;
            this.numeroOferta               = Integer.valueOf(pQuote.Opportunity.NumeroOferta__c);
            //this.orcnum                     = pQuote.Opportunity.Numero__c;
            this.ordemPortal                = 1;
            this.rotulo                     = pQuote.Produto__r.Name;
            this.susepOrcamento             = pQuote.CodigoCorretor__r.NomeCorretor__r.CodigoSusepCorretor__c;
            //this.gerarDocumento             = false;
            this.dataCalculo                = String.valueOf(System.today());

            this.qtdDiasVigencia            = pQuote.VigenciaInicial__c.daysBetween(pQuote.VigenciaFinal__c) + 1; //PLV-5161 - INICIO/FIM ADICIONADO +1
            //this.LimiteTotalCarregamento    = pQuote.Produto__r.LimiteTotalCarregamento__c;//PLV-4851 - INICIO/FIM

            

            this.tempoGarantiaRenda = Integer.valueOf(pQuote.PorQuantoTempoQuerGarantirRenda__c); //TEMPO GARANTIA RENDA DO CÁLCULO

            this.termoGuarda                =  pQuote.TermoGuarda__c; //ADICIONA TERMO GUARDA DO CÁLCULO            
            
            //itera remunerações da quote
            List<Remuneracoes> remuneracaoList = new List<Remuneracoes>();
            //PLV-4851 - INICIO - PEDRO AUGUSTO BRAZ - SYS4B
            System.debug('>>>>'+pProposta.remuneracoes);
            for (Remuneracoes remuneracaoItem : pProposta.remuneracoes) {
                Remuneracoes newRemuneracao = new Remuneracoes();
                newRemuneracao.percentual = Integer.valueOf(remuneracaoItem.percentual);
                // PLV-5185 INCIO
                // newRemuneracao.tipoRemuneracao = remuneracaoItem.tipoRemuneracao;
                newRemuneracao.tipoRemuneracao = remuneracaoItem.tipoRemuneracao.substring(0,3);
                // PLV-5185 FIM
                remuneracaoList.add(newRemuneracao);
            }
            //PLV-4851 - FIM - PEDRO AUGUSTO BRAZ - SYS4B
            
            this.remuneracoes               = remuneracaoList; //ADICIONA REMUNERAÇÕES DO CÁLCULO                                                
                        
            //ITENS DE COTAÇÃO DO ÍNDICE MONETÁRIO
            List<ItensCotacao> itensCotacaoList = new List<ItensCotacao>();
            ItensCotacao itensCotacaoItem = new ItensCotacao();
            itensCotacaoItem.moedaDestino = 'BRL';
            Date currentDate = System.today();
            Integer day = currentDate.day();
            Integer month = currentDate.month();
            Integer year = currentDate.year();
            String unformatDate = String.valueOf(day)+String.valueOf(month)+String.valueOf(year);            
            itensCotacaoItem.dataCotacao = Integer.valueOf(unformatDate);
            itensCotacaoItem.moedaOrigem = 'BRL';
            itensCotacaoItem.cotacao = '1.0';
            itensCotacaoList.add(itensCotacaoItem);
            
            
            //ÍNDICE MONETÁRIO DO RESULTADO DAS INTEGRAÇÕES
            IndiceMonetario indiceMonetarioItem = new IndiceMonetario();
            //indiceMonetarioItem.validacaoZeroDolar = validacaoZeroDolarItem;
            indiceMonetarioItem.ItensCotacao = itensCotacaoList; //adiciona itens de cotação do índice monetário
                        
            //RESULTADO DAS INTEGRAÇÕES
            ResultadoIntegracoesTO resultadoIntegracoesItem = new ResultadoIntegracoesTO();
            resultadoIntegracoesItem.IndiceMonetario = indiceMonetarioItem; //adiciona índice monetário do resultado das integrações                        

            this.resultadoIntegracoes     = resultadoIntegracoesItem; //ADICIONA RESULTADO DE INTEGRAÇÕES DO CÁLCULO

            //BUSCA ID DO DOCUMENTO RELACIONADO AO ORÇAMENTO DO QUOTE
            List<ContentDocumentLink> docuLinkList = [Select Id, ContentDocumentId From ContentDocumentLink Where LinkedEntityId = :pQuote.OpportunityId];

            //PEGA NUMERO DO ORÇAMENTO PRA COMPARAR DEPOIS
            String orcamentoNumber = pQuote.Opportunity.Numero__c; 

            //PEGA IDS E COLOCA EM UMA LISTA DE STRING
            List<String> docuLinkIds = new List<String>();
            for (ContentDocumentLink docuLinkLoop : docuLinkList) {
                docuLinkIds.add(docuLinkLoop.ContentDocumentId);
                
            }

            DocumentReturn docReturn = new DocumentReturn();
            //BUSCA CONTEÚDO DO DOCUMENTO EM LOOP USANDO LISTA DE STRING DE IDS

            //PLV-5801 INICIO
            String searchString = '%' + (tipoProposta.contains(pQuote.Tipo__c)? sufixoRenovacao : sufixoPadrao);
            List<ContentVersion> lstContentVersion = [SELECT Id, ContentDocumentId, VersionData, Title 
                                                      FROM ContentVersion Where Title LIKE : searchString 
                                                      AND ContentDocumentId IN :docuLinkIds];
            

            for(ContentVersion CVTesteItem : lstContentVersion) {
            //PLV-5801 FIM
                //cria objeto de contentVersion  e faz tratamento pra pegar conteúdo do documento
                ContentVersion ContentVersionItem = new ContentVersion();
                Blob ContentVersionBody = CVTesteItem.VersionData;
                String ContentVersionString = ContentVersionBody.toString();
                ContentVersionString.remove('\\');                
                
                docReturn = (DocumentReturn) JSON.deserialize(ContentVersionString, DocumentReturn.class);
            }

            List<VersoesCalculos> versoesCalculosList = new List<VersoesCalculos>();
            VersoesCalculos versaoCalculoRenova = new VersoesCalculos();
            if(!Test.isRunningTest()){
                //ITERA DENTRO DO ORCAMENTO RETORNADO DO DOCUMENTO PRA OBTER VERSOES DO CALCULO
                //PLV-5801 INICIO
                System.debug('Danilo DocReturn: ' + JSON.serialize(docReturn));
                if(docReturn.JSONResponseCalculo != null){
                    for (OfertasTO ofertaItem : docReturn.JSONResponseCalculo.ofertas) {
                        if (ofertaItem.orcamento.numeroOrcamento == orcamentoNumber) {
                            for (VersoesCalculos versoesCalculoItem : ofertaItem.orcamento.versoesCalculos) {
                                if (versoesCalculoItem.opcao == Integer.valueOf(pQuote.Opcao__c)) {
                                    versoesCalculosList.add(versoesCalculoItem);
                                }
                            }
                        }
                    }
                }
                else{
                    
                    System.debug('pQuote Danilo: ' + pQuote.DescontoAgravoPercentualFormaPagto__c);
                    System.debug('Danilo versaoCalculoRenova ' + JSON.serialize(versaoCalculoRenova));
                    versaoCalculoRenova.descontoAgravo = pQuote.DescontoAgravoPercentualFormaPagto__c;
                    versaoCalculoRenova.tipo =  'FPG';
                    versaoCalculoRenova.opcao = integer.valueOf(pQuote.Opcao__c);
                    versoesCalculosList.add(versaoCalculoRenova);
                }
                //PLV-5801 FIM
            }
            
            this.versoesCalculos          = versoesCalculosList; //ADICIONA VERSÕES DOS CÁLCULOS   

            
            Map<String,List<SeguradoProposta__c>> mapGrupo = new Map<String,List<SeguradoProposta__c>>();
            Map<String,List<SeguradosTO>> mapGrupoSegurado = new Map<String,List<SeguradosTO>>();
            Integer quantidade = 1;

            List<CoberturasTO> coberturas = new List<CoberturasTO>();
            List<CoberturasTO> coberturasPrecificacao = new List<CoberturasTO>();
            List<String> garantiaProdutoId = new List<String>(); //lista usada pra pegar descrições da franquia                 
            for(Garantias garantia : pProposta.garantias){
                if(garantia.contratado==true){
                    coberturas.add(new RecalculoPropostaTO.CoberturasTO().dtoCobertura(garantia));
                    if(garantia.descontoAgravo != 0)
                        coberturasPrecificacao.add(new RecalculoPropostaTO.CoberturasTO().dtoCoberturaPrecificacao(garantia));
                    garantiaProdutoId.add(garantia.Id); //adiciona na lista pra pegar descrições da franquia
                }
            }
            Map<String, String> franquiaMap = new Map<String, String>();
            //PLV-5103 INICIO
            Map<String, Decimal> mapLimiteUso = new Map<String, Decimal>();
            Decimal limiteUso;
            //PLV-5103 FIM
            //itera no objeto de franquia pra pegar as descrições com sigla identificando
            for(GarantiaProposta__c garantiaItem: pQuote.GarantiasProposta__r){
                franquiaMap.put(garantiaItem.franquiaGarantia__r.GarantiaProduto__r.Garantia__r.Sigla__c, garantiaItem.franquiaGarantia__r.Franquia__r.CodigoFranquia__c);
                //PLV-5103 INICIO 
                limiteUso = garantiaItem.Limite_de_Uso__c != null ? garantiaItem.Limite_de_Uso__c :  0.0;
                mapLimiteUso.put(garantiaItem.Garantia__r.Sigla__c, limiteUso);
                //PLV-5103 FIM
            }
            system.debug('MAP LIMITE USO>>>> '+ JSON.serialize(mapLimiteUso));
            //cria uma nova lista de coberturas com respectivas descrições das franquias
            List<CoberturasTO> coberturasNewList = new List<CoberturasTO>();    
            for (CoberturasTO coberturaNewItem : coberturas) {
                CoberturasTO newCobertura = new CoberturasTO();  
                newCobertura.sigla = coberturaNewItem.sigla;
                newCobertura.valor = coberturaNewItem.valor;
                newCobertura.quantidade = mapLimiteUso.get(coberturaNewItem.sigla); //PLV-5103 INICIO/FIM

                //PLV-4812 - INÍCIO
                if(newCobertura.sigla == 'DMHO'){
                    List<DescontoAgravoTO> descontoAgravo = new List<DescontoAgravoTO>();
                    DescontoAgravoTO descontoAgravoTemp = new DescontoAgravoTO();
                    descontoAgravoTemp.tipo = '';
                    descontoAgravoTemp.percentual = 0;
                    descontoAgravoTemp.monetario = 0;
                    descontoAgravo.add(descontoAgravoTemp);
                    newcobertura.descontoAgravo = descontoAgravo;
                }
                else{
                    newcobertura.descontoAgravo = coberturaNewItem.descontoAgravo; 
                    if (franquiaMap.get(coberturaNewItem.sigla) != null) {
                        newCobertura.franquia = franquiaMap.get(coberturaNewItem.sigla);
                    } else {
                        newCobertura.franquia = '';
                    }
                }
                //PLV-4812 - FIM
                coberturasNewList.add(newCobertura);
            }

            for(SeguradoProposta__c sp : pSeguradosProposta){
                if(!mapGrupo.containsKey(sp.GrupoProposta__c)) mapGrupo.put(sp.GrupoProposta__c,new List<SeguradoProposta__c>());
                mapGrupo.get(sp.GrupoProposta__c).add(sp);
                if(!mapGrupoSegurado.containsKey(sp.GrupoProposta__c)) mapGrupoSegurado.put(sp.GrupoProposta__c,new List<SeguradosTO>());
                
                //SEGURADO DO GRUPO DE CONTRATANTES
                SeguradosTO segurado = new SeguradosTO();
                //egurado.pessoa = new RecalculoPropostaTO.PessoaTO().preencherDadosContaPessoaFisica(sp);
                segurado.nome = pSeguradosProposta[0].Conta__r.Name;
                segurado.numero = Integer.valueOf(pSeguradosProposta[0].Numero__c);
                segurado.coberturas = coberturasNewList;

                //DADOS DA PESSOA FISICA DO SEGURADO
                DadosPessoaFisicaTO dadosPessoaFisicaItem = new DadosPessoaFisicaTO();
                dadosPessoaFisicaItem.sexo = pSeguradosProposta[0].Conta__r.sexo__c;
                dadosPessoaFisicaItem.dataNascimento = String.ValueOf(pSeguradosProposta[0].Conta__r.personBirthdate);
                dadosPessoaFisicaItem.nacionalidade = pSeguradosProposta[0].Conta__r.Nacionalidade__c;
                dadosPessoaFisicaItem.estadocivil = pSeguradosProposta[0].Conta__r.EstadoCivil__c;
                // PLV-5185 INCIO
                // dadosPessoaFisicaItem.grupoProfissao = pSeguradosProposta[0].GrupoRisco__c; //PLV-5161 INICIO/FIM
                dadosPessoaFisicaItem.grupoProfissao = pSeguradosProposta[0].GrupoRisco__c != null ? pSeguradosProposta[0].GrupoRisco__c : '';
                // PLV-5185 FIM
                dadosPessoaFisicaItem.cboProfissao = pSeguradosProposta[0].Conta__r.Profissao__r.Codigo__c;
                // PLV-5185 INCIO
                // dadosPessoaFisicaItem.regimeTrabalho = pSeguradosProposta[0].Conta__r.EstadoCivil__c;
                dadosPessoaFisicaItem.regimeTrabalho = pSeguradosProposta[0].RegimeTrabalho__c;
                // PLV-5185 FIM
                dadosPessoaFisicaItem.fumante = pSeguradosProposta[0].Fumante__c;
                dadosPessoaFisicaItem.faixaRendaFinal = String.ValueOf(pSeguradosProposta[0].Conta__r.Renda__c);
                dadosPessoaFisicaItem.faixaRendaInicial = '';
                dadosPessoaFisicaItem.dependentes = pSeguradosProposta[0].TemDependentes__c == true?'sim':'não';

                //DOCUMENTOS DOS DADOS DA PESSOA FISICA DO SEGURADO
                List<DocumentoTO> documentosList = new List<DocumentoTO>();
                DocumentoTO documentoItem = new DocumentoTO();
                documentoItem.tipoDocumentoIdentidade = '';
                documentoItem.orgaoExpedidorDocumento = '';
                documentoItem.numeroDocumento = '';
                documentoItem.dataExpedicaoDocumento = '';

                documentosList.add(documentoItem);
                dadosPessoaFisicaItem.documentos = documentosList;

                segurado.dadosPessoaFisica = dadosPessoaFisicaItem;

                // PLV-5185 INCIO
                // segurado.dadosPessoaFisica.CicloVacinal = sp.CicloVacinal__c; // PLV-5157 
                this.cicloVacinal = Integer.valueOf(sp.CicloVacinal__c);
                // PLV-5185 FIM
                
                mapGrupoSegurado.get(sp.GrupoProposta__c).add(segurado);
                
                quantidade = quantidade + 1;
            }

            quantidade = 1;            
            for(String key : mapGrupoSegurado.keySet()){

                //PESSOA DO CONTRATANTE
                PessoaTO newPessoa = new RecalculoPropostaTO.PessoaTO().preencherDadosContaPessoaFisica(pSeguradosProposta[0]); //isso é uma PessoaTO     

                this.contratantes = new List<ContratantesTO>();
                this.contratantes.add(new ContratantesTO()); //ADICIONA CONTRATANTE

                //ADICIONA VALORES DO CONTRATANTE
                this.contratantes[0].tipo =  pSeguradosProposta[0].GrupoProposta__r.ContratanteProposta__r.Tipo__c == 'Principal'?'PRI':'';//pSeguradosProposta[0].GrupoProposta__r.ContratanteProposta__r.Tipo__c != null ? pSeguradosProposta[0].GrupoProposta__r.ContratanteProposta__r.Tipo__c : '';
                this.contratantes[0].numero = pSeguradosProposta[0].GrupoProposta__r.ContratanteProposta__r.Numero__c != null ? Integer.valueOf(pSeguradosProposta[0].GrupoProposta__r.ContratanteProposta__r.Numero__c) : 0;
                this.contratantes[0].pessoa = newPessoa;
                //ADICIONA GRUPO AO CONTRATANTE
                this.contratantes[0].grupos = new List<GruposTO>();
                this.contratantes[0].grupos.add(new GruposTO());
               
                //ADICIONA VALORES DO GRUPO AO CONTRATANTE
                this.contratantes[0].grupos[0].nome = pSeguradosProposta[0].GrupoProposta__r.Name; 
                this.contratantes[0].grupos[0].segurados = mapGrupoSegurado.get(key);
                this.contratantes[0].grupos[0].qtdeVidas = Integer.valueOf(pSeguradosProposta[0].GrupoProposta__r.QuantidadeVidas__c);                        
                this.contratantes[0].grupos[0].numero = Integer.valueOf(pSeguradosProposta[0].GrupoProposta__r.Numero__c);
                this.contratantes[0].grupos[0].tipoSegurado = '';
                //this.contratantes.add(cont);
                quantidade = quantidade + 1;
            }    

            //DESCONTOAGRAVO DA PRECIFICAÇÃO
            List<DescontoAgravoTO> descontosAgravosItens = new List<DescontoAgravoTO>();
            DescontoAgravoTO descontoAgravoItem = new DescontoAgravoTO();            

            descontoAgravoItem.tipo = 'TEC';
            //PLV-4851 - INICIO - PEDRO AUGUSTO BRAZ
            if(pProposta.tipoDescontoAgravo == 'Monetário'){
                descontoAgravoItem.monetario = pProposta.descontoAgravo!=null ? pProposta.descontoAgravo : 0;
            }else if(pProposta.tipoDescontoAgravo == 'Porcentagem'){
                descontoAgravoItem.percentual = pProposta.descontoAgravo!=null ? pProposta.descontoAgravo : 0;
            }
            //PLV-4851 - FIM - PEDRO AUGUSTO BRAZ
            descontosAgravosItens.add(descontoAgravoItem);

            //PREMIO DA PRECIFICAÇÃO
            PremioTO premioItem = new PremioTO();
            premioItem.minimo =  pQuote.Produto__r.PremioMinimo__c != null ? pQuote.Produto__r.PremioMinimo__c : 0.0;
            //premioItem.descontoAgravoPremio = descontoAgravoItem; //adiciona descontos agravos do premio
            

            
            //PRECIFICAÇÃO
            PrecificacaoTO precificacaoItem = new PrecificacaoTO();            
            //precificacaoItem.premio = premioItem; //adiciona premio da precificação
            precificacaoItem.descontoAgravo = descontosAgravosItens;
            
            precificacaoItem.coberturas = coberturasPrecificacao; //adiciona coberturas da precificação

            this.precificacao               = precificacaoItem; //ADICIONA PRECIFICAÇÃO DO CÁLCULO

            //PLV-4694 - FIM
                      
            System.debug(JSON.serialize(this));

            return this;
        }
	}

	public class ItensCotacao {
		public String moedaDestino;
		public Integer dataCotacao;
		public String moedaOrigem;
		public String cotacao;
	}
	//PLV - 4694 INICIO
	public class ContratantesTO {
		public String tipo;
		public Integer numero;
        public List<GruposTO> grupos;   
        public PessoaTO pessoa;     
    }

    public class GruposTO {
		public Integer numero;
		public List<SeguradosTO> segurados;
		public String nome;
        public Integer qtdeVidas;
        public String tipoSegurado;
	}

	public class SeguradosTO {
        public String nome;
		public PessoaTO pessoa;
		public Integer numero;
        public List<CoberturasTO> coberturas;
        public DadosPessoaFisicaTO dadosPessoaFisica;
	}
	//PLV - 4694 FIM

	public class EnderecosTO {
		public String uf;
		public String cidade;
		public String complemento;
		public String logradouro;
		public String bairro;
		public String complementoCep;
		public String paisResidencia;
		public String tipoEndereco;
		public String numeroLogradouro;
        public String cep;
        
        public EnderecosTO dtoEndereco(Endereco__c pEndereco){
            this.cep = pEndereco.CEP__c;
            this.logradouro = pEndereco.Logradouro__c;
            this.tipoEndereco = pEndereco.TipoEndereco__c;
            this.numeroLogradouro = pEndereco.Numero__c;
            this.complemento = pEndereco.Complemento__c;
            this.bairro = pEndereco.Bairro__c;
            this.cidade = pEndereco.Cidade__c;
            this.uf = pEndereco.Estado__c;
            this.paisResidencia = pEndereco.Pais__c;
            return this;
        }
    }
    //PLV - 4694 INICIO
    public class DadosPessoaFisicaTO{
        public String sexo { get; set; }
        public String dataNascimento { get; set; }
        public String nacionalidade { get; set; }
        public String estadoCivil { get; set; }
        public String grupoProfissao {get;set;}
        public String cboProfissao {get;set;}
        public String regimeTrabalho  { get; set; }
        public Boolean fumante { get; set; }
        public String faixaRendaInicial {get;set;}
        public String faixaRendaFinal {get;set;}
        public String dependentes  { get; set; }
        public List<DocumentoTO> documentos { get; set; }
        // public String CicloVacinal {get; set;} // PLV-5157 INICIO/FIM //PLV-5185 INICIO/FIM
    }
        /*
        public String tipoRelacionamentoPep { get; set; }
        public String pep { get; set; }
        public String cpfPep { get; set; }
        public String nomePessoaPep { get; set; }
        public String profissao { get; set; }
        public String numeroCpf { get; set; }
        public String sexo { get; set; }
        public String dataNascimento { get; set; }
        public List<DocumentoTO> documentos { get; set; }
        public String estadoCivil { get; set; }
        public String digitoCpf { get; set; }
        public String nacionalidade { get; set; }
        public PessoaTO pessoaRelacionamentoPep { get; set; }
        public Boolean fumante { get; set; }
        public Boolean temDependentes  { get; set; }
        public String renda  { get; set; }
        public String regimeTrabalho  { get; set; }
        public String tempoGarantiaRenda { get; set; }
        public String  ocupacaoProfissionalPrincipal { get;set; } 
        public String  formaTrabalho { get;set; }      // RegimeTrabalho__c
        public String  faixaRenda { get;set ;}         // faixaRenda__c
        public Boolean resideBrasil { get;set;}        //ResideBrasil__c
        public String  paisResidente { get;set;}       //PaisResidencia__c
        public String tipoDocIdentificacao { get;set;}   // TipoDocidentificacao__c
        public String docIdentificacao { get;set;}   // DocIndentificacao__c
        public String orgaoExpedidor { get;set;}   // OrgaoExpedidor__c
        public Date dataExpedicao { get;set;}   // DataExpedicao__c
        public String grauParentesco { get;set;}   // GrauParentesco__c
    }

    public class DadosPessoaJuridica{
        public String numeroCnpj { get; set; }
        public String ordemCnpj { get; set; }
        public String digitoCnpj { get; set; }
        public String cnpj { get; set; }
        public String codigoCNAE { get; set; }
        public String descricaoCNAE { get; set; }
    }*/
    public class DocumentoTO{
        public String orgaoExpedidorDocumento { get; set; }
        public String numeroDocumento { get; set; }
        public String dataExpedicaoDocumento { get; set; }
        public String tipoDocumentoIdentidade { get; set; }
    }
    public class ResultadoIntegracoesTO {
		public IndiceMonetario IndiceMonetario;
    }
	//PLV - 4694 FIM
    

    //PARSE DO RETORNO

   // public List<RetornoCalculoTO> retornosCalculo  { get; set; }

    //FRONT DO COMPONENTE
    public class Proposta{
        @AuraEnabled public String id {get;set;}
        @AuraEnabled public String numero {get;set;}
        @AuraEnabled public Decimal premioTotal {get;set;}
        @AuraEnabled public String tipoDescontoAgravo {get;set;} //percentual ou monetario
        @AuraEnabled public List<String> tipoOpcoes {get;set;} //percentual ou monetario
        @AuraEnabled public Double descontoAgravo {get;set;} 
        @AuraEnabled public List<Garantias> garantias {get;set;}
        @AuraEnabled public String isoCode {get;set;}
        //PLV-4851 INICIO - PEDRO AUGUSTO BRAZ - SYS4B
        @AuraEnabled public List<Remuneracoes> remuneracoes {get;set;}
        @AuraEnabled public Decimal LimiteTotalCarregamento {get;set;}
        @AuraEnabled public Date VigenciaInicial {get;set;}
        @AuraEnabled public Date VigenciaFinal {get;set;}
        //PLV-4851 FIM - PEDRO AUGUSTO BRAZ - SYS4B
    }
    public class Garantias{
        @AuraEnabled public String id {get;set;}
        @AuraEnabled public Boolean contratado {get;set;} 
        @AuraEnabled public Boolean obrigatorio {get;set;} 
        @AuraEnabled public String name {get;set;} 
        @AuraEnabled public String caracteristica {get;set;} 
        @AuraEnabled public String cobertura {get;set;} 
        @AuraEnabled public Decimal capital {get;set;} 
        @AuraEnabled public Double premioAtual {get;set;} 
        @AuraEnabled public String tipoDescontoAgravo {get;set;} //percentual ou monetario
        @AuraEnabled public List<String> tipoOpcoes {get;set;} //percentual ou monetario
        @AuraEnabled public String isoCode {get;set;}
        @AuraEnabled public Double descontoAgravo {get;set;} 
        @AuraEnabled public Double limiteCapitalMinimo {get;set;} 
        @AuraEnabled public Double limiteCapitalMaximo {get;set;} 
        @AuraEnabled public Double percentualCapitalMinimo {get;set;} 
        @AuraEnabled public Double percentualCapitalMaximo {get;set;} 
        @AuraEnabled public Double percentualAgravoMaximo {get;set;} 
        @AuraEnabled public Double percentualAgravoMinimo {get;set;} 
        @AuraEnabled public Double percentualDescontoMinimo {get;set;} 
        @AuraEnabled public Double percentualDescontoMaximo {get;set;} 
    }
    //II-206 INICIO
    public class ResponsavelFinWrapper {
        public String responsavel;
        public String cpfResponsavel;
        public String vinculoSegurado;
        public String sexo;
        public Date nascimento;
        public String estadoCivil;
        public String email;
        public String confirmarEmail;
        public String cep;
        public String tipoEndereco;
        public String logradouro;
        public String bairro;
        public String cidade;
        public String estado;
        public String complemento;
        public String semNumero;
        public String numero;
        public String telefone1;
        public String telefone2;
    }
    //II-206 FIM
}