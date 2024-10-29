//PLV-5320 - INICIO
/*
* IntegracaoOpinWrapper (Open Insurance)
* @author Squad_VidaDoSeuJeito
* @date 16/10/2021
* Classe Wrapper para a montagem do payload de envio ao OPIN
*/
public class IntegracaoOpinWrapper {

    //Dependências auxiliares
    private final IntegracaoOpinDeparaBO depara = IntegracaoOpinDeparaBO.getInstance();
    private final IntegracaoOpinConstants constantes = IntegracaoOpinConstants.getInstance();

    //Estruturas de dados injetadas
    private final Product2 produto { get; set; }
    private final List<GarantiaProduto__c> garantias { get; set; } 
    private final List<PremioMinimoProduto__c> formaPgtoPremioMin { get; set; }

    private final List<IntegracaoOpinTO.PersonProductsTO> personProducts { get; set; }

    //Implementa Factory
    private static IntegracaoOpinWrapper instance;
    public static IntegracaoOpinWrapper getInstance(Product2 produto, List<GarantiaProduto__c> garantias, List<PremioMinimoProduto__c> formaPgtoPremioMin) {
        instance = new IntegracaoOpinWrapper(produto, garantias, formaPgtoPremioMin);
		return instance;
	}
    public static IntegracaoOpinWrapper getInstance(Product2 produto, List<GarantiaProduto__c> garantias, List<PremioMinimoProduto__c> formaPgtoPremioMin, List<IntegracaoOpinTO.PersonProductsTO> personProducts) {
        instance = new IntegracaoOpinWrapper(produto, garantias, formaPgtoPremioMin, personProducts);
		return instance;
	}    

    //Construtor
    public IntegracaoOpinWrapper(Product2 produto, List<GarantiaProduto__c> garantias, List<PremioMinimoProduto__c> formaPgtoPremioMin) { 
        this.produto = produto;
        this.garantias = garantias;
        this.formaPgtoPremioMin = formaPgtoPremioMin;
    }

    //Construtor
    public IntegracaoOpinWrapper(Product2 produto, 
                List<GarantiaProduto__c> garantias, 
                List<PremioMinimoProduto__c> formaPgtoPremioMin, 
                List<IntegracaoOpinTO.PersonProductsTO> personProducts) { 
        this.produto = produto;
        this.garantias = garantias;
        this.formaPgtoPremioMin = formaPgtoPremioMin;
        this.personProducts = personProducts;
    }

    //Método que inicia a montagem da classe estrutural do payload 
    // Node "//"
    public IntegracaoOpinTO montarEstruturaTO() {
        
        IntegracaoOpinTO objTo = new IntegracaoOpinTO();
        objTo.properties = montarProperties();
        objTo.routing_key = constantes.ROUTING_KEY;
        objTo.payload_encoding = constantes.PAYLOAD_ENCODING;
        objTo.payload = montarPayload();

        return objTo;
    }

    // Node "//properties"
    private IntegracaoOpinTO.PersonPropertiesTO montarProperties() { 

        IntegracaoOpinTO.PersonPropertiesTO properties =  new IntegracaoOpinTO.PersonPropertiesTO();
        properties.content_type = constantes.CONTENT_TYPE;
        
        return properties;
    }

    // Node "//payload"
    private String montarPayload() { 

        IntegracaoOpinTO.PersonPayloadTO payload =  new IntegracaoOpinTO.PersonPayloadTO();
        payload.data = montarData();  //PLV-5230 - FIX01 - INICIO/FIM
        payload.version = '1.3.0'; //PLV-5854 INICIO/FIM

        return ajustarPayload(JSON.serialize(payload));
    }
    private String ajustarPayload(String payload) {
        return payload
                .replace('"currencyOpin"', '"currency"')
                .replace('\\', '\\\\')
                .replace('"', '\"');
    }

    //PLV-5230 - FIX01 - INICIO
    // Node "//payload/data"
    private IntegracaoOpinTO.PersonDataTO montarData() { 

        IntegracaoOpinTO.PersonDataTO data =  new IntegracaoOpinTO.PersonDataTO();
        data.brand = montarPersonBrand(); 
        
        return data;
    }
    //PLV-5230 - FIX01 - FIM

    // Node "//payload/data/brand"
    private IntegracaoOpinTO.PersonBrandTO montarPersonBrand() {

        IntegracaoOpinTO.PersonBrandTO brand = new IntegracaoOpinTO.PersonBrandTO();
        brand.name = produto.Empresa__r.Name;
        brand.companies = montarPersonCompany();

        return brand;
    }

    // Node "//payload/data/brand/companies[]"
    private List<IntegracaoOpinTO.PersonCompanyTO> montarPersonCompany() {

        IntegracaoOpinTO.PersonCompanyTO company = new IntegracaoOpinTO.PersonCompanyTO();
        company.name = produto.Empresa__r.Name;
        company.cnpjNumber = produto.Empresa__r.CNPJ__c;
        if (this.personProducts == null) {
            company.products = montarPersonProducts();
        } 
        else {
            company.products = this.personProducts;
        }
        System.debug('Danilo log montarPersonCompany');
        return new List<IntegracaoOpinTO.PersonCompanyTO> { company };
    }   

    // Node "//payload/data/brand/companies[]/products[]"
    public List<IntegracaoOpinTO.PersonProductsTO> montarPersonProducts() {

        IntegracaoOpinTO.PersonProductsTO produto = new IntegracaoOpinTO.PersonProductsTO();
        produto.name = this.produto.name;
        produto.code = this.produto.ProductCode;
        System.debug('Danilo montarPersonProducts 0');
        List<String> listAssitance = new List<String>(); 
        listAssitance.add('NAO_SE_APLICA');
        produto.assistanceType = listAssitance; //PLV-5854 INICIO/FIM
        produto.assistanceTypeOthers = listAssitance; //PLV-5854 INICIO/FIM
        System.debug('Danilo montarPersonProducts 1');
        produto.insuranceModality = depara.consultar(constantes.DEPARA_MODALIDADE, this.produto.Segmento__c); 
        produto.coverages = montarPersonCoverage();
        produto.additional = montarPersonProducts_additional(); 
        produto.termsAndConditions = montarPersonTermsAndConditions();
        produto.pmbacRemuneration = montarPersonPmbacRemuneration();
        produto.benefitRecalculation = montarPersonBenefitRecalculation();
        produto.ageAdjustment = montarPersonAgeAdjustment();
        produto.contractType = constantes.CONTRACTTYPE_PADRAO;
        produto.reclaim = montarPersonReclaim();
        produto.otherGuaranteedValues = constantes.OTHERGUARANTEED_PADRAO;
        produto.portabilityGraceTime = constantes.CONST_ZERO_INT;
        produto.indemnityPaymentMethod = constantes.PAYMENTMETHOD_PADRAO;
        produto.premiumPayment = montarPersonPremiumPayment();
        produto.minimunRequirements = montarPersonMinimunRequirements();
        System.debug('Danilo montarPersonProducts 2');
        //PLV-5230 - FIX01 - INICIO
        produto.category = constantes.PRODUTCTCATEGORY_PADRAO;
        produto.validity = montarPersonProducts_validity();
        produto.indemnityPaymentIncome = constantes.INDEMNITYPAYMENTINCOME_PADRAO;
        produto.targetAudience = constantes.TARGETAUDIENCE_PADRAO;
        //PLV-5230 - FIX01 - FIM

        //PLV-5230 - FIX02 - INICIO
        produto.globalCapital = constantes.GLOBALCAPITAL_PADRAO;
        produto.allowPortability = constantes.ALLOWPORTABILITY_PADRAO;
        //PLV-5230 - FIX02 - FIM

        return new List<IntegracaoOpinTO.PersonProductsTO> { produto };
    }

    // Node "//payload/data/brand/companies[]/products[]/coverages[]"
    private List<IntegracaoOpinTO.PersonCoveragesTO> montarPersonCoverage() {

        List<IntegracaoOpinTO.PersonCoveragesTO> coverages = new List<IntegracaoOpinTO.PersonCoveragesTO>();
        for(GarantiaProduto__c garantia: garantias) {
            IntegracaoOpinTO.PersonCoveragesTO coverage = new IntegracaoOpinTO.PersonCoveragesTO();
            coverage.coverage = depara.consultar(constantes.DEPARA_GARANTIA, garantia.SiglaGarantia__c);
            //PLV-5230 - FIX05 - INICIO
            if (coverage.coverage == '') {
                coverage.coverage = constantes.PRODUCTCOVERAGE_PADRAO;
            }
            //PLV-5230 - FIX05 - FIM
            coverage.coverageAttributes = montarPersonCoverageAttributes(garantia);
            coverage.coverageOthers = new List<String>();
            coverages.add(coverage);
        }

        return coverages;
    }

    // Node "//payload/data/brand/companies[]/products[]/additional[]"
    private List<String> montarPersonProducts_additional() {

        return new List<String> { constantes.ADDITIONAL_PADRAO };
    }

    //PLV-5230 - FIX01 - INICIO
    // Node "//payload/data/brand/companies[]/products[]/validity[]"
    private List<String> montarPersonProducts_validity() {

        return new List<String> { depara.consultar(constantes.DEPARA_VALIDADE, this.produto.Segmento__c) };
    }
    //PLV-5230 - FIX01 - FIM

    // Node "//payload/data/brand/companies[]/products[]/coverages[]/coverageAttributes"
    private IntegracaoOpinTO.PersonCoverageAttributesTO montarPersonCoverageAttributes(GarantiaProduto__c garantia) {

        IntegracaoOpinTO.PersonCoverageAttributesTO attributes = new IntegracaoOpinTO.PersonCoverageAttributesTO();
        attributes.indemnityPaymentMethod = montarPersonCoverageAttributes_paymentMethod(garantia); 
        attributes.indemnityPaymentFrequency = constantes.INDEMNITYPAYMENTFREQUENCY_PADRAO;
        attributes.minValue = montarPersonCoverageAttributesDetails(garantia, garantia.LimiteCapitalMinimo__c); //PLV-5854 INICIO/FIM
        attributes.maxValue = montarPersonCoverageAttributesDetails(garantia, garantia.LimiteCapitalMaximo__c); //PLV-5854 INICIO/FIM
        attributes.indemnifiablePeriod = constantes.INDEMNIFIABLEPERIOD_PADRAO; 
        attributes.maximumQtyIndemnifiableInstallments = constantes.MAXIMUMQTYINDEMNIFIABLEINSTALLMENTS_PADRAO;
        attributes.currencyOpin = garantia.CurrencyIsoCode;
        //PLV-5850 INICIO
        List<IntegracaoOpinTO.PersonGracePeriodUnitTO> ListGracePeriodUnit = new List<IntegracaoOpinTO.PersonGracePeriodUnitTO>();
        ListGracePeriodUnit.add(montarPersonGracePeriodUnit(garantia.CarenciasGarantia__r));
        attributes.gracePeriod = ListGracePeriodUnit; 
        //PLV-5850 FIM
        System.debug('Danilo attributes.gracePeriod ' + attributes.gracePeriod);
        attributes.deductibleDays = montarPersonCoverageAttributes_deductibleDays(garantia.FranquiasGarantia__r);
        System.debug('Danilo attributes.deductibleDays ' + attributes.deductibleDays);
        attributes.deductibleBRL = constantes.CONST_ZERO_INT;
        attributes.excludedRisks = montarPersonCoverageAttributes_excludedRisks(garantia);
        attributes.allowApartPurchase = montarPersonCoverageAttributes_allowApartPurchase(garantia);

        return attributes;
    }

    // Node "//payload/data/brand/companies[]/products[]/coverages[]/coverageAttributes/indemnityPaymentMethod[]"
    private List<String> montarPersonCoverageAttributes_paymentMethod(GarantiaProduto__c garantia) {
        
        List<String> paymentMethods = new List<String>();

        if (garantia.TipoPagamento__c == null || garantia.TipoPagamento__c == '') {
            return paymentMethods;
        }

        for(String pm: garantia.TipoPagamento__c.split(';')) {
            paymentMethods.add(depara.consultar(constantes.DEPARA_METODOPAGAMENTO, pm));
        }

        return paymentMethods;
    }

    // Node "//payload/data/brand/companies[]/products[]/coverages[]/coverageAttributes/minValue"
    // Node "//payload/data/brand/companies[]/products[]/coverages[]/coverageAttributes/maxValue"
    private List<IntegracaoOpinTO.PersonCoverageAttributesDetailsTO> montarPersonCoverageAttributesDetails(GarantiaProduto__c garantia, Decimal amount) { //PLV-5230 - FIX04 - INICIO/FIM
        //PLV-5854 INICIO
        List<IntegracaoOpinTO.PersonCoverageAttributesDetailsTO> valuesList = new List<IntegracaoOpinTO.PersonCoverageAttributesDetailsTO>();
        IntegracaoOpinTO.PersonCoverageAttributesDetailsTO details = new IntegracaoOpinTO.PersonCoverageAttributesDetailsTO();
        details.amount = amount;
        details.unit = montarPersonCoverageAttributesDetailsUnit(garantia);
        valuesList.add(details);
        return valuesList; //PLV-5230 - FIX04 - INICIO/FIM
        //PLV-5854 FIM
    } 

    // Node "//payload/data/brand/companies[]/products[]/coverages[]/coverageAttributes/gracePeriod"
    // Node "//payload/data/brand/companies[]/products[]/reclaim/gracePeriod"
    private IntegracaoOpinTO.PersonGracePeriodUnitTO montarPersonGracePeriodUnit(List<CarenciaGarantia__c> carenciasGarantia) {
        IntegracaoOpinTO.PersonGracePeriodUnitTO gracePeriodUnit = new IntegracaoOpinTO.PersonGracePeriodUnitTO();
        if (carenciasGarantia.size() == 0) {
            gracePeriodUnit.amount = constantes.CONST_ZERO_INT;
            gracePeriodUnit.unit = constantes.RECLAIMGRACEPERIODUNIT_PADRAO;     
            return gracePeriodUnit;
        }
        //Considera apenas a 1a carência. O Produto só tem uma cadastrada, no fututo qdo houver 
        //  mais deverá ser definida uma regra.
        
        gracePeriodUnit.amount = carenciasGarantia[0].Carencia__r.PeriodoMaximoCarencia__c;
        gracePeriodUnit.unit = depara.consultar(constantes.DEPARA_CARENCIA, carenciasGarantia[0].Carencia__r.TipoPeriodo__c);  
        return gracePeriodUnit;
    }

    // Node "//payload/data/brand/companies[]/products[]/coverages[]/coverageAttributes/deductibleDays
    private Integer montarPersonCoverageAttributes_deductibleDays(List<FranquiaGarantia__c> franquiasGarantia) {

        Set<Integer> listaDias = new Set<Integer>();
        for(FranquiaGarantia__c franquiaGarantia: franquiasGarantia) {
            if (franquiaGarantia.Franquia__r.LimiteMinimo__c <> null && franquiaGarantia.Franquia__r.LimiteMinimo__c <> '0') {
                listaDias.add(Integer.valueOf(franquiaGarantia.Franquia__r.LimiteMinimo__c));
            }
            if (franquiaGarantia.Franquia__r.LimiteMaximo__c <> null && franquiaGarantia.Franquia__r.LimiteMaximo__c <> '0') {
                listaDias.add(Integer.valueOf(franquiaGarantia.Franquia__r.LimiteMaximo__c));
            }
        }
        if (listaDias.size() > 0) {
            return (new List<Integer>(listaDias))[0];
        }
        else {
            return 0; //PLV-5854 INICIO/FIM
        }
    }

    // Node "//payload/data/brand/companies[]/products[]/coverages[]/coverageAttributes/excludedRisks[]
    private List<String> montarPersonCoverageAttributes_excludedRisks(GarantiaProduto__c garantia) {

        List<String> riscosExcluidos = depara.consultarLista(constantes.DEPARA_RISCOSEXCLUIDOS, this.produto.Segmento__c);
        return riscosExcluidos;
    }

    // Node "//payload/data/brand/companies[]/products[]/coverages[]/coverageAttributes/allowApartPurchase
    private Boolean montarPersonCoverageAttributes_allowApartPurchase(GarantiaProduto__c garantia) {

        return (garantia.CaracteristicaGarantia__c == constantes.CARACTERISTICAGARANTIA_PRINCIPAL);
    }

    // Node "//payload/data/brand/companies[]/products[]/termAndConditions[]"
    private List<IntegracaoOpinTO.PersonTermsAndConditionsTO> montarPersonTermsAndConditions() {
        
        IntegracaoOpinTO.PersonTermsAndConditionsTO termsAndConditions = new IntegracaoOpinTO.PersonTermsAndConditionsTO();
        termsAndConditions.susepProcessNumber = this.produto.NumeroSusep__c;
        termsAndConditions.definition = depara.consultar(constantes.DEPARA_TERMOSCONDICOES, this.produto.Segmento__c);
  
        return new List<IntegracaoOpinTO.PersonTermsAndConditionsTO> { termsAndConditions };
    }

    // Node "//payload/data/brand/companies[]/products[]/pmbacRemuneration"
    private IntegracaoOpinTO.PersonPmbacRemunerationTO montarPersonPmbacRemuneration() {

        IntegracaoOpinTO.PersonPmbacRemunerationTO pmbacRemuneration = new IntegracaoOpinTO.PersonPmbacRemunerationTO();
        pmbacRemuneration.interestRate = constantes.CONST_ZERO_INT;
        pmbacRemuneration.pmbacUpdateIndex = constantes.UPDATEINDEX_PADRAO; 

        return pmbacRemuneration;
    }

    // Node "//payload/data/brand/companies[]/products[]/benefitRecalculation"
    private IntegracaoOpinTO.PersonBenefitRecalculationTO montarPersonBenefitRecalculation() {

        IntegracaoOpinTO.PersonBenefitRecalculationTO benefitRecalculation = new IntegracaoOpinTO.PersonBenefitRecalculationTO();
        benefitRecalculation.benefitRecalculationCriteria = constantes.BENEFITRECALCULATIONCRITERIA_PADRAO;
        benefitRecalculation.benefitUpdateIndex = constantes.UPDATEINDEX_PADRAO;

        return benefitRecalculation;
    }

    // Node "//payload/data/brand/companies[]/products[]/ageAdjustment"
    private IntegracaoOpinTO.PersonAgeAdjustmentTO montarPersonAgeAdjustment() {

        IntegracaoOpinTO.PersonAgeAdjustmentTO ageAdjustment = new IntegracaoOpinTO.PersonAgeAdjustmentTO();
        ageAdjustment.criterion = constantes.AGEADJUSTMENT_PADRAO;
        ageAdjustment.frequency = constantes.CONST_ZERO_INT;

        return ageAdjustment;
    }

    // Node "//payload/data/brand/companies[]/products[]/reclaim"
    private IntegracaoOpinTO.PersonReclaimTO montarPersonReclaim() {

        IntegracaoOpinTO.PersonReclaimTO reclaim = new IntegracaoOpinTO.PersonReclaimTO();
        reclaim.reclaimTable = montarPersonReclaimTable();
        reclaim.gracePeriod =  montarPersonGracePeriodUnit(new List<CarenciaGarantia__c>());

        return reclaim;
    }
    
    // Node "//payload/data/brand/companies[]/products[]/reclaim/reclaimTable"
    private List<IntegracaoOpinTO.PersonReclaimTableTO> montarPersonReclaimTable() {

        IntegracaoOpinTO.PersonReclaimTableTO reclaimTable = new IntegracaoOpinTO.PersonReclaimTableTO();
        reclaimTable.initialMonthRange = constantes.CONST_ZERO_INT;
        reclaimTable.finalMonthRange = constantes.CONST_ZERO_INT;
        reclaimTable.percentage = constantes.CONST_ZERO_INT;

        return new List<IntegracaoOpinTO.PersonReclaimTableTO> { reclaimTable };
    }     

    // Node "//payload/data/brand/companies[]/products[]/coverages[]/coverageAttributes/minValue[]/unit"
    // Node "//payload/data/brand/companies[]/products[]/coverages[]/coverageAttributes/maxValue[]/unit"
    private IntegracaoOpinTO.PersonCoverageAttributesDetailsUnitTO montarPersonCoverageAttributesDetailsUnit(GarantiaProduto__c garantia) {

        IntegracaoOpinTO.PersonCoverageAttributesDetailsUnitTO unit = new IntegracaoOpinTO.PersonCoverageAttributesDetailsUnitTO();
        unit.code = depara.consultar(constantes.DEPARA_MOEDA, garantia.CurrencyIsoCode);
        unit.description = unit.code; 

        return unit;
    }   

    // Node "//payload/data/brand/companies[]/products[]/premiumPayment"
    private IntegracaoOpinTO.PersonPremiumPaymentTO montarPersonPremiumPayment() {

        IntegracaoOpinTO.PersonPremiumPaymentTO premiumPayment = new IntegracaoOpinTO.PersonPremiumPaymentTO();
        premiumPayment.paymentMethod = montarPersonPremiumPayment_PaymentMethod();
        premiumPayment.frequency = montarPersonPremiumPayment_Frequency();
        
        return premiumPayment;
    }

    // Node "//payload/data/brand/companies[]/products[]/premiumPayment/paymentMethod[]"
    private List<String> montarPersonPremiumPayment_PaymentMethod() {

        Set<String> paymentsMethod = new Set<String>();
        for(PremioMinimoProduto__c formaPagto : this.formaPgtoPremioMin) {
            if (formaPagto.FormaPagamento__r <> null) {
                paymentsMethod.add(depara.consultar(constantes.DEPARA_PAGAMENTOS, formaPagto.FormaPagamento__r.Codigo__c));
            }
        }
        
        return new List<String>(paymentsMethod);
    }

    // Node "//payload/data/brand/companies[]/products[]/premiumPayment/frequency[]"
    private List<String> montarPersonPremiumPayment_Frequency() {

        Set<String> frequency = new Set<String>();
        for(PremioMinimoProduto__c formaPagto : this.formaPgtoPremioMin) {
            if (formaPagto.PeriodicidadePagamento__c != null) {  //PLV-5230 - FIX04 - INICIO/FIM
                frequency.add(formaPagto.PeriodicidadePagamento__c.toUpperCase());
            } //PLV-5230 - FIX04 - INICIO/FIM
        }
        
        return new List<String>(frequency);
    }

    // Node "//payload/data/brand/companies[]/products[]/minimunRequirements"
    private IntegracaoOpinTO.PersonMinimunRequirementsTO montarPersonMinimunRequirements() {

        IntegracaoOpinTO.PersonMinimunRequirementsTO minumunRequirements = new IntegracaoOpinTO.PersonMinimunRequirementsTO();

        minumunRequirements.contractingType = depara.consultar(constantes.DEPARA_TIPOCONTRATACAO,  this.produto.Segmento__c); 
        minumunRequirements.contractingMinRequirement = montarPersonMinimunRequirements_contractingMinRequirement(this.produto, this.garantias);

        return minumunRequirements;
    }

    // Node "//payload/data/brand/companies[]/products[]/minimunRequirements/contractingMinRequirement"
    private String montarPersonMinimunRequirements_contractingMinRequirement(Product2 produto, List<GarantiaProduto__c> garantias) {

        String body = constantes.MINREQUIREMENT_TEMPLATE;
        String textoGarantias = montarTextoGarantias(garantias);
        String textoFormasPagamento = montarTextoFormasPagamento(produto);

        return body.replace('{produto}', produto.Name)
                    .replace('{garantias}', textoGarantias)
                    .replace('{formaspagamento}', textoFormasPagamento);  
    }

    private String montarTextoGarantias(List<GarantiaProduto__c> garantias) {
        //{garantia}, capital mínimo {capitalminimo}, capital máximo {capitalmaximo}
        String texto = '';
        for (GarantiaProduto__c garantia: garantias) {
            texto += constantes.MINREQUIREMENT_TEMPLATEGARANTIA
                        .replace('{garantia}', garantia.Garantia__r.Name)
                        .replace('{capitalminimo}', garantia.LimiteCapitalMinimo__c <> null ? garantia.LimiteCapitalMinimo__c.format(): '' )
                        .replace('{capitalmaximo}', garantia.LimiteCapitalMaximo__c <> null ? garantia.LimiteCapitalMaximo__c.format(): '' );
        }
        return texto;
    }

    private String montarTextoFormasPagamento(Product2 produto) {
        //{formapagamento} {premiominimo} , quantidade de parcelas permitida: {parcelamento}. Desconto pela forma de pagamento {descontosformapagamento}
        
        Map<Id, PremioMinimoProduto__c> formaPagtoPremio = new Map<Id, PremioMinimoProduto__c>();
        for (PremioMinimoProduto__c pmp: produto.PremiosMinimoProduto__r) {
            if (formaPagtoPremio.get(pmp.FormaPagamento__r.Id) == null) {
                formaPagtoPremio.put(pmp.FormaPagamento__r.Id, pmp);
            }
        }

        String texto = '';
        for (CondicaoCobranca__c cc: produto.CondicoesCobranca__r) {

            PremioMinimoProduto__c pmp = formaPagtoPremio.get(cc.FormaPagamento__c);
            if (pmp == null) {
                continue;
            }

            String[] arrParcelas = cc.QuantidadeParcelas__c.split(';');
            String qtdeParcelas = arrParcelas[arrParcelas.size()-1];

            texto += constantes.MINREQUIREMENT_TEMPLATEFORMAPAGTO
                            .replace('{formapagamento}', pmp.FormaPagamento__r.Name)
                            .replace('{premiominimo}', pmp.PremioMinimoParcela__c.format())
                            .replace('{parcelamento}', qtdeParcelas)
                            .replace('{descontosformapagamento}', cc.PercentualDescontoAgravo__c.format());
        }

        return texto;
    }

}
//PLV-5320 - FIM