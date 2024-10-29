//PLV-5230 - INICIO
public class IntegracaoOpinTO {
    
    public PersonPropertiesTO properties                                    { get; set; }
    public String routing_key                                               { get; set; }
    public String payload_encoding                                          { get; set; }
    public String payload                                                   { get; set; }              

    public class PersonPropertiesTO {        
        public String content_type                                          { get; set; }
    }

    public class PersonPayloadTO {        
        public PersonDataTO data                                          { get; set; } ////PLV-5230 - FIX01 - INICIO/FIM
        public String version                                               { get; set; } //PLV-5854 INICIO/FIM
    }
//PLV-5230 - FIX01 - INICIO
    public class PersonDataTO {        
        public PersonBrandTO brand                                          { get; set; }
    }
//PLV-5230 - FIX01 - FIM
    public class PersonBrandTO {
        public String name                                                  { get; set; }
        public List<PersonCompanyTO> companies                              { get; set; } 
    }

    public class PersonCompanyTO {
        public String name                                                  { get; set; }
        public String cnpjNumber                                            { get; set; }
        public List<PersonProductsTO> products                              { get; set; }
    }

    public class PersonProductsTO {
        public String name                                                  { get; set; }
        public String code                                                  { get; set; } 
        public String category                                              { get; set; }                        
        public String insuranceModality                                     { get; set; }
        public List<PersonCoveragesTO> coverages                            { get; set; }
        public List<String> assistanceType                                  { get; set; }        
        public List<String> additional                                      { get; set; }
        public List<String> assistanceTypeOthers                            { get; set; }        
        public List<PersonTermsAndConditionsTO> termsAndConditions          { get; set; }
        public Boolean globalCapital                                        { get; set; } 
        public List<String> validity                                        { get; set; }        
        public PersonPmbacRemunerationTO pmbacRemuneration                  { get; set; }
        public PersonBenefitRecalculationTO benefitRecalculation            { get; set; }
        public PersonAgeAdjustmentTO ageAdjustment                          { get; set; }
        public String contractType                                          { get; set; }
        public PersonReclaimTO reclaim                                      { get; set; }
        public String otherGuaranteedValues                                 { get; set; }
        public Boolean allowPortability                                     { get; set; } //PLV-5230 - FIX02 - INICIO/FIM
        public Integer portabilityGraceTime                                 { get; set; } 
        public List<String> indemnityPaymentMethod                          { get; set; }
        public List<String> indemnityPaymentIncome                          { get; set; }
        public PersonPremiumPaymentTO premiumPayment                        { get; set; }
        public PersonMinimunRequirementsTO minimunRequirements              { get; set; }        
        public String targetAudience                                        { get; set; }
    }

    public class PersonCoveragesTO {
        public String coverage                                              { get; set; }
        public List<String> coverageOthers                                  { get; set; }
        public PersonCoverageAttributesTO coverageAttributes                { get; set; }
    }

    public class PersonCoverageAttributesTO {
        public List<String> indemnityPaymentMethod                          { get; set; }
        public List<String> indemnityPaymentFrequency                       { get; set; }
        public List<PersonCoverageAttributesDetailsTO> minValue             { get; set; } //PLV-5230 - FIX04 - INICIO/FIM //PLV-5854 INICIO/FIM
        public List<PersonCoverageAttributesDetailsTO> maxValue             { get; set; } //PLV-5230 - FIX04 - INICIO/FIM //PLV-5854 INICIO/FIM
        public List<String> indemnifiablePeriod                             { get; set; }
        public Integer maximumQtyIndemnifiableInstallments                  { get; set; }
        public String currencyOpin                                          { get; set; }
        public List<PersonGracePeriodUnitTO> gracePeriod                    { get; set; } //PLV-5850 INICIO/FIM
        //public PersonGracePeriodUnitTO differentiatedGracePeriod            { get; set; } //PLV-5230 - FIX05 - INICIO/FIM
        public Integer deductibleDays                                       { get; set; }
        //public Decimal differentiatedDeductibleDays                         { get; set; } //PLV-5230 - FIX05 - INICIO/FIM
        public Decimal deductibleBRL                                        { get; set; }
        //public String differentiatedDeductibleBRL                           { get; set; } //PLV-5230 - FIX05 - INICIO/FIM
        public List<String> excludedRisks                                   { get; set; }
        //public String excludedRisksURL                                      { get; set; } //PLV-5230 - FIX05 - INICIO/FIM
        public Boolean allowApartPurchase                                   { get; set; }
    }    

    public class PersonGracePeriodUnitTO {
        public Decimal amount                                               { get; set; }        
        public String unit                                                  { get; set; }
    }

    public class PersonCoverageAttributesDetailsTO {
        public Decimal amount                                               { get; set; }        
        public PersonCoverageAttributesDetailsUnitTO unit                   { get; set; }
    }

    public class PersonCoverageAttributesDetailsUnitTO {
        public String code                                                  { get; set; }        
        public String description                                           { get; set; }
    }

    public class PersonTermsAndConditionsTO {
        public String susepProcessNumber                                    { get; set; }
        public String definition                                            { get; set; }
    }

    public class PersonPmbacRemunerationTO {
        public Decimal interestRate                                         { get; set; }
        public String pmbacUpdateIndex                                      { get; set; }
    }

    public class PersonBenefitRecalculationTO {        
        public String benefitRecalculationCriteria                          { get; set; }
        public String benefitUpdateIndex                                    { get; set; }
    }

    public class PersonAgeAdjustmentTO {        
        public String criterion                                             { get; set; }
        public Integer frequency                                            { get; set; }
    }

    public class PersonReclaimTO {
        public List<PersonReclaimTableTO> reclaimTable                      { get; set; }
        //public String differentiatedPercentage                              { get; set; } //PLV-5230 - FIX05 - INICIO/FIM
        public PersonGracePeriodUnitTO gracePeriod                          { get; set; } //PLV-5230 - FIX03 - INICIO/FIM
    }

    public class PersonReclaimTableTO {
        public Integer initialMonthRange                                    { get; set; }
        public Integer finalMonthRange                                      { get; set; }
        public Decimal percentage                                           { get; set; }
    }

    public class PersonPremiumPaymentTO {
        public List<String> paymentMethod                                   { get; set; }
        public List<String> frequency                                       { get; set; }
        //public String premiumTax                                            { get; set; } //PLV-5230 - FIX05 - INICIO/FIM
    }

    public class PersonMinimunRequirementsTO {
        public String contractingType                                       { get; set; }
        public String contractingMinRequirement                             { get; set; }
    }
}
//PLV-5230 - FIM