//PLV-5230 - INICIO
/*
/*  @author: Squad Globant 
/*  @description: Classe contendo as definições das contantes usadas pela Integração OPIN
/*  @modifiedAt: 14/11/2021
/*/
public class IntegracaoOpinConstants {

    //Implementa Factory
    private static final IntegracaoOpinConstants instance = new IntegracaoOpinConstants();
    public static IntegracaoOpinConstants getInstance() {
		return instance;
	}

    public IntegracaoOpinConstants() {  }

    //Constantes
    public final String ROUTING_KEY = ((ConfiguracoesOPIN__c)ConfiguracoesOPIN__c.getValues('routing_key')).Conteudo__c;
    public final String PAYLOAD_ENCODING = ((ConfiguracoesOPIN__c)ConfiguracoesOPIN__c.getValues('payload_encoding')).Conteudo__c;
    public final String CONTENT_TYPE = ((ConfiguracoesOPIN__c)ConfiguracoesOPIN__c.getValues('content_type')).Conteudo__c;
    
    public final String DEPARA_MODALIDADE = 'MODALIDADE';
    public final String DEPARA_GARANTIA = 'GARANTIAS'; //PLV-5230 - FIX04 - INICIO/FIM
    public final String DEPARA_PAGAMENTOS = 'PAGAMENTOS';
    public final String DEPARA_TERMOSCONDICOES = 'TERMOSCONDICOES';
    public final String DEPARA_CARENCIA = 'CARENCIA';
    public final String DEPARA_MOEDA = 'MOEDA';    
    public final String DEPARA_TIPOCONTRATACAO = 'TIPOCONTRATACAO';
    public final String DEPARA_METODOPAGAMENTO = 'METODOPAGAMENTO';
    public final String DEPARA_RISCOSEXCLUIDOS = 'RISCOSEXCLUIDOS';
    public final String DEPARA_VALIDADE = 'VALIDADE'; //PLV-5230 - FIX01 - INICIO/FIM

    public final String CONTRACTTYPE_PADRAO = 'REPARTICAO_SIMPLES';
    public final String OTHERGUARANTEED_PADRAO = 'NAO_SE_APLICA';
    public final List<String> PAYMENTMETHOD_PADRAO = new List<String> { 'UNICO' };
    public final Integer CONST_ZERO_INT = 0;
    public final String RECLAIMGRACEPERIODUNIT_PADRAO = 'NAO_SE_APLICA'; //PLV-5230 - FIX03 - INICIO/FIM
    public final String AGEADJUSTMENT_PADRAO = 'POR_MUDANCA_DE_FAIXA_ETARIA';
    public final String BENEFITRECALCULATIONCRITERIA_PADRAO = 'INDICE';
    public final String UPDATEINDEX_PADRAO = 'IPCA';
    public final List<String> INDEMNITYPAYMENTFREQUENCY_PADRAO = new List<String> { 'INDENIZACAO_UNICA' };
    public final Integer MAXIMUMQTYINDEMNIFIABLEINSTALLMENTS_PADRAO = 1;
    public final String CARACTERISTICAGARANTIA_PRINCIPAL = 'Principal';
    public final String ADDITIONAL_PADRAO = 'SERVICOS_ASSISTENCIA_COMPLEMENTARES_GRATUITO'; //PLV-5230 - FIX04 - INICIO/FIM
    public final List<String> INDEMNIFIABLEPERIOD_PADRAO = new List<String> { 'PRAZO' };
    //PLV-5230 - FIX01 - INICIO
    public final String PRODUTCTCATEGORY_PADRAO = 'TRADICIONAL'; 
    public final List<String> INDEMNITYPAYMENTINCOME_PADRAO = new List<String>{ 'CERTA' }; //PLV-5230 - FIX04 - INICIO/FIM
    public final String TARGETAUDIENCE_PADRAO = 'PESSOA_NATURAL';
    //PLV-5230 - FIX01 - FIM

    //PLV-5230 - FIX02 - INICIO
    public final Boolean ALLOWPORTABILITY_PADRAO = false; 
    public final Boolean GLOBALCAPITAL_PADRAO = false; 
    //PLV-5230 - FIX02 - FIM

    public final String PRODUCTCOVERAGE_PADRAO = 'OUTRAS'; //PLV-5230 - FIX05 - INICIO/FIM
   
    public final String MINREQUIREMENT_TEMPLATE = Label.OPIN_Template_ReqMin;
    public final String MINREQUIREMENT_TEMPLATEGARANTIA = Label.OPIN_Template_ReqMinGarantia;
    public final String MINREQUIREMENT_TEMPLATEFORMAPAGTO = Label.OPIN_Template_ReqMinFormaPagto;

    public final String SISTEMA_ORIGEM = 'SALESFORCE';
}
//PLV-5230 - FIM