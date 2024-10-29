/** Classe responsável por gerenciar a integração de regulação de sinistro x ODM
 * @author Guilherme Azevedo
 * @version 1.0
*/
public class RegulacaoSinistro {
    //PLV-4516 INICIO

    //++++++++++++++++++++++++
    // PUBLIC STATIC METHODS
    //++++++++++++++++++++++++

    @future(callout=true)
    public static void enviarSinistrosParaRegulacao(Set<Id> caseIds) {
        List<CriticaSinistro__c> criticasOdm = new List<CriticaSinistro__c>();

        List<Case> sinistros = getSinistroEGarantias(caseIds);
        Map<Id, List<BeneficiarioGarantia__c>> beneficiariosByGarantiaMap = getBeneficiariosByGarantiaMap(sinistros);

        for (Case sinistro : sinistros) {
            criticasOdm.addAll(getCriticasRegulacaoODM(sinistro, beneficiariosByGarantiaMap));
        }

        if (criticasOdm.size() > 0) {
            System.debug('RegulacaoSinistro :: enviarSinistrosParaRegulacao :: criticasOdm : ' + criticasOdm);
            insert criticasOdm;
        }

        // Obs: Inicialmente essa história previa gravação de críticas, alteração de status de garantias e proposta
        // porém por falta de detalhamento os últimos 2 itens foram direcionados para  uma história futura
    }

    //++++++++++++++++++++++++
    // PRIVATE STATIC METHODS
    //++++++++++++++++++++++++

    private static List<CriticaSinistro__c> getCriticasRegulacaoODM(Case sinistro, Map<Id, List<BeneficiarioGarantia__c>> beneficiariosMap) {
        List<CriticaSinistro__c> result = new List<CriticaSinistro__c>();
        RegulacaoRequest req = new RegulacaoRequest();
        
        try {
            Map<String, PagamentoGarantia__c> garantiasBySiglaMap = getGarantiasBySigla(sinistro);
            System.debug('RegulacaoSinistro :: getGarantiasBySigla :: garantiasBySiglaMap : ' + garantiasBySiglaMap);

            // serialize
            req.sinistro = new Sinistro(sinistro, beneficiariosMap);
            System.debug('RegulacaoSinistro :: getCriticasRegulacaoODM :: req : ' + JSON.serializePretty(req));

            // send request
            String retornoCiv = Test.isRunningTest() ? getMock() : 'CIVServices.getInstance().enviarSinistroEmRegulacao(JSON.serialize(req)'; //MGRC-1657 - INICIO/FIM
            System.debug('RegulacaoSinistro :: getCriticasRegulacaoODM :: retornoCiv : ' + retornoCiv);
            
            // parse response
            RegulacaoResponse res = (RegulacaoResponse) JSON.deserialize(retornoCiv, RegulacaoResponse.class);
            System.debug('RegulacaoSinistro :: getCriticasRegulacaoODM :: res : ' + res);

            if (res != null  && res.retornoAceitacao != null && res.retornoAceitacao.criticas != null && res.retornoAceitacao.criticas.size() > 0) {

                for (Critica critica : res.retornoAceitacao.criticas) {

                    if (garantiasBySiglaMap.containsKey(critica.siglaGarantia)) {
                        
                        CriticaSinistro__c criticaSinistro = new CriticaSinistro__c();

                        criticaSinistro.GarantiaSinistro__c = garantiasBySiglaMap.get(critica.siglaGarantia).Id;
                        criticaSinistro.Area__c  = critica.area;
                        criticaSinistro.Email__c  = critica.email;
                        criticaSinistro.DisparoAutomaticoEmail__c  = !String.isBlank(critica.envio) && critica.envio == 'Automático' ? true : false;
                        criticaSinistro.Status__c = critica.status;
                        criticaSinistro.Prioridade__c = critica.prioridade;
                        criticaSinistro.Observacao__c = critica.observacao;
                        criticaSinistro.DataInicioPendencia__c = Date.today();
                        criticaSinistro.Origem__c = 'ODM';
                        criticaSinistro.Tipo__c = 'Pendencia';
                        criticaSinistro.Sinistro__c = sinistro.Id;
                        criticaSinistro.TemplateEmail__c = critica.templateEmail; //PLV-4523 - FIX 2 - INICIO/FIM

                        result.add(criticaSinistro);
                    }
                    
                }
            }
        } catch (Exception ex) {
            System.debug('RegulacaoSinistro :: getCriticasRegulacaoODM :: Exception : ' + ex.getMessage() + ', ' + ex.getStackTraceString());
        }

        return result;
    }

    private static String getMock() {
        return '{"numeroSinistro":"12345","retornoAceitacao":{"criticas":[{"siglaGarantia":"RS","area":"Carta ao Produtor","email":"CartaaoProdutor@teste.com.br","envio":"Automático","status":"Pendente","observacao":"TESTE de OBSERVACAO","prioridade":"0","motivoRecusa":"60"}]}}';
    }

    private static Map<String, PagamentoGarantia__c> getGarantiasBySigla(Case sinistro) {
        Map<String, PagamentoGarantia__c> result = new Map<String, PagamentoGarantia__c>();
        
        for (PagamentoGarantia__c garantia : sinistro.Pagamentos_de_garantia__r) {
            
            if (garantia.Garantia_do_segurado_do_contrato__c != null 
                && garantia.Garantia_do_segurado_do_contrato__r.Garantia__c != null 
                && !String.isBlank(garantia.Garantia_do_segurado_do_contrato__r.Garantia__r.Sigla__c) 
                && !result.containsKey(garantia.Garantia_do_segurado_do_contrato__r.Garantia__r.Sigla__c)) {

                result.put(garantia.Garantia_do_segurado_do_contrato__r.Garantia__r.Sigla__c, garantia);
            }
        }

        return result;
    }

    private static List<Case> getSinistroEGarantias(Set<Id> caseIds) {
        return [
            SELECT Id
                ,NumeroSinistro__c
                ,Nome_Segurado__c
                ,CreatedDate
                ,Cpf_Segurado__c
                ,Contrato__c
                ,Contrato__r.NumeroApolice__c
                ,Contrato__r.Produto__r.ProductCode
                ,ContactId
                ,Contact.Account.Cpf__c
                ,Contact.Name
                ,Contact.Phone
                ,Contact.Email
                ,Data_sinistro_avisado__c
                ,DataOcorrencia__c
                ,Subject
                ,Description
                ,Origin
                ,Numero_titulo__c
                ,Vitima__c
                ,IdPrestadora__c
                ,Status
                ,DataEntradaDocumentos__c
                ,TipoEvento__c
                ,Type
                ,(
                    SELECT Id
                        ,Caso__c
                        ,Garantia_do_segurado_do_contrato__c
                        ,Garantia_do_segurado_do_contrato__r.Garantia__c
                        ,Garantia_do_segurado_do_contrato__r.Garantia__r.Name
                        ,Garantia_do_segurado_do_contrato__r.Garantia__r.Sigla__c
                    FROM Pagamentos_de_garantia__r
                )
            FROM Case
            WHERE Id IN: caseIds
        ];
    }

    private static Map<Id, List<BeneficiarioGarantia__c>> getBeneficiariosByGarantiaMap(List<Case> sinistros) {
        Map<Id, List<BeneficiarioGarantia__c>> result = new Map<Id, List<BeneficiarioGarantia__c>>();
        Set<Id> garantiasSet = new Set<Id>();

        for (Case sinistro : sinistros) {

            if (sinistro.Pagamentos_de_garantia__r.size() > 0) {
                for (PagamentoGarantia__c garantia : sinistro.Pagamentos_de_garantia__r) {
                    garantiasSet.add(garantia.Id);
                }
            }
        }

        List<BeneficiarioGarantia__c> beneficiarios =  [
            SELECT Id
                ,Pagamento_de_garantia__c
                ,Name
                ,Conta__r.Cpf__c
                ,Percentual_de_indenizacao__c           
                ,Tipo_de_Pagamento__c
                ,Informacao_bancaria__c
                ,Informacao_bancaria__r.Banco__c
                ,Informacao_bancaria__r.Agencia__c
                ,Informacao_bancaria__r.NumeroConta__c
                ,Informacao_bancaria__r.Digito__c
                ,Informacao_bancaria__r.Papel__c
            FROM BeneficiarioGarantia__c
            WHERE Pagamento_de_garantia__c IN : garantiasSet
        ];

        for (BeneficiarioGarantia__c beneficiario : beneficiarios) {

            if (result.containsKey(beneficiario.Pagamento_de_garantia__c)) {
                List<BeneficiarioGarantia__c> beneficiosGarantia = result.get(beneficiario.Pagamento_de_garantia__c);
                beneficiosGarantia.add(beneficiario);
                result.put(beneficiario.Pagamento_de_garantia__c, beneficiosGarantia);
            }
            else {
                result.put(beneficiario.Pagamento_de_garantia__c, new List<BeneficiarioGarantia__c>{beneficiario});
            }
        }

        return result;
    }

    //++++++++++++++++++++++++
    // ENTITY CLASSES
    //++++++++++++++++++++++++

    public class RegulacaoRequest {

        public Sinistro sinistro;
    }

    public class RegulacaoResponse {

        public String numeroSinistro;
        public RetornoAceitacao retornoAceitacao;
    }

    public class Garantia {

		public String nomeGarantia;
		public String sigla;
        public List<Beneficiario> beneficiarios;

        public Garantia(PagamentoGarantia__c garantia, List<BeneficiarioGarantia__c> beneficiarios) {

            this.nomeGarantia = garantia.Garantia_do_segurado_do_contrato__r.Garantia__r.Name;
            this.sigla = garantia.Garantia_do_segurado_do_contrato__r.Garantia__r.Sigla__c;

            this.beneficiarios = new List<Beneficiario>();

            for (BeneficiarioGarantia__c beneficiario : beneficiarios) {
                this.beneficiarios.add(new Beneficiario(beneficiario));
            }
        }
	}

	public class DadosBancarios {

		public String banco;
		public String agencia;
		public String numeroContaBancaria;
		public String digito;
		public String papel;
	}

	public class Beneficiario {

		public String nomeBeneficiario;
		public String cpfBeneficiario;
		public Double porcentagemBeneficiario;
		public String tipoDePagamento;
        public DadosBancarios dadosBancarios;

        public Beneficiario(BeneficiarioGarantia__c beneficiario) {

            this.porcentagemBeneficiario = beneficiario.Percentual_de_indenizacao__c;
            this.nomeBeneficiario = beneficiario.Name;
            this.cpfBeneficiario = beneficiario.Conta__c != null ? beneficiario.Conta__r.Cpf__c : null;
            this.tipoDePagamento = beneficiario.Tipo_de_Pagamento__c;

            if (beneficiario.Informacao_bancaria__c != null) {

                this.dadosBancarios = new DadosBancarios();
                this.dadosBancarios.banco = beneficiario.Informacao_bancaria__r.Banco__c;
                this.dadosBancarios.agencia = beneficiario.Informacao_bancaria__r.Agencia__c;
                this.dadosBancarios.numeroContaBancaria = beneficiario.Informacao_bancaria__r.NumeroConta__c;
                this.dadosBancarios.digito = beneficiario.Informacao_bancaria__r.Digito__c;
                this.dadosBancarios.papel = beneficiario.Informacao_bancaria__r.Papel__c;
            }
        }
	}

	public class Sinistro {

		public String numeroSinistro;
		public String nomeSegurado;
		public String cpfSegurado;
		public String cpfContato;
		public String nomeContato;
		public String telefoneContato;
		public String emailContato;
		public Datetime dataAviso;
		public Datetime dataOcorrencia;
		public String assunto;
		public String descricao;
		public String origem;
		public String nomePrestadora;
		public String codigoProdutoVida;
		public String tipo;
		public String vitima;
		public String idAtendimentoPrestadora;
		public String status;
		public Date dataEntradaDocumentos;
		public Datetime dataSinistro;
		public Integer numeroApolice;
        public String tipoEvento;

        public List<Garantia> garantias;

        public Sinistro(Case sinistro, Map<Id, List<BeneficiarioGarantia__c>> beneficiariosMap) {

            this.tipo = sinistro.Type;
            this.numeroSinistro = sinistro.NumeroSinistro__c;
            this.nomeSegurado = sinistro.Nome_Segurado__c;
            this.cpfSegurado = sinistro.Cpf_Segurado__c;
            this.dataSinistro = sinistro.CreatedDate;
            this.dataAviso = sinistro.Data_sinistro_avisado__c;
            this.dataOcorrencia = sinistro.DataOcorrencia__c;
            this.assunto = sinistro.Subject;
            this.descricao = sinistro.Description;
            this.origem = sinistro.Origin;
            this.nomePrestadora = sinistro.Numero_titulo__c;
            this.vitima = sinistro.Vitima__c;
            this.idAtendimentoPrestadora = sinistro.IdPrestadora__c;
            this.status = sinistro.Status;
            this.dataEntradaDocumentos = sinistro.DataEntradaDocumentos__c;
            this.tipoEvento = sinistro.TipoEvento__c;

            if (sinistro.Contrato__c != null) {
                this.numeroApolice = sinistro.Contrato__r.NumeroApolice__c != null ? Integer.valueOf(sinistro.Contrato__r.NumeroApolice__c) : null;
                this.codigoProdutoVida = sinistro.Contrato__r.Produto__r != null ? sinistro.Contrato__r.Produto__r.ProductCode : null;
            }

            if (sinistro.ContactId != null) {
                this.nomeContato = sinistro.Contact.Name;
                this.telefoneContato = sinistro.Contact.Phone;
                this.emailContato = sinistro.Contact.Email;
                this.cpfContato = sinistro.Contact.Account != null ? sinistro.Contact.Account.Cpf__c : null;
            }

            this.garantias = new List<Garantia>();

            for (PagamentoGarantia__c garantia : sinistro.Pagamentos_de_garantia__r) {
                if (garantia.Garantia_do_segurado_do_contrato__c != null && garantia.Garantia_do_segurado_do_contrato__r.Garantia__c != null) {
                    List<BeneficiarioGarantia__c> beneficiarios = beneficiariosMap.containsKey(garantia.Id) ? beneficiariosMap.get(garantia.Id) : new List<BeneficiarioGarantia__c>();
                    this.garantias.add(new Garantia(garantia, beneficiarios));
                }
            }
        }
    }

    public class Critica {

		public String siglaGarantia;
		public String area;
		public String email;
		public String envio;
		public String status;
		public String observacao;
		public String prioridade;
        public String motivoRecusa;
        public String templateEmail; //PLV-4523 - FIX 2 - INICIO/FIM
	}

	public class RetornoAceitacao {

		public List<Critica> criticas;
    }

    //PLV-4516 FIM
}