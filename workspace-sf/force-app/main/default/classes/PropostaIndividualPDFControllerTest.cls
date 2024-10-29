/********************************************************************************************************************
* @author Gabriel Loch - Globant
* @date 17/09/2020
* Classe criada por conta da história PLV-4331
*********************************************************************************************************************/
@isTest
global with sharing class PropostaIndividualPDFControllerTest {    
    
    //FNPVVEP-69 - INICIO
    @testSetup static void setup(){

        Map<String, Sobject> records = CreateTestData.createIntegratedScenario(); 

        Account conta = (Account) records.get('AccountPessoaFisica');
        conta.TipoDocidentificacao__c = 'rg';
        conta.NomeSocial__c = 'Teste TI';
        update conta;

        Endereco__c enderecoResidencial = (Endereco__c) TestDataFactory.gerarEndereco(conta);
        enderecoResidencial.TipoEndereco__c = 'Residencial';
        update enderecoResidencial;
        
        Endereco__c enderecoComercial = (Endereco__c) TestDataFactory.gerarEndereco(conta);
        enderecoComercial.TipoEndereco__c = 'Comercial';
        update enderecoComercial;

        Opportunity orcamento = (Opportunity) new OrcamentoFactory.VidaIndividual((Product2) records.get('ProdutoComercial'), conta).createRecord();
        Modalidade__c modalidade = (Modalidade__c) new ModalidadeFactory((RamoSeguro__c) records.get('RamoSeguro')).createRecord();    
        
        Quote proposta = (Quote) new PropostaFactory((Product2) records.get('ProdutoComercial'), (RamoSeguro__c) records.get('RamoSeguro'), conta, (DadosCorretor__c) records.get('DadosCorretor'), orcamento, modalidade).createRecord();
        RemuneracaoProposta__c remuneracao = new RemuneracaoProposta__c (Proposta__c = proposta.Id);
        insert remuneracao;
        FavorecidoRemuneracaoProposta__c favRem = new FavorecidoRemuneracaoProposta__c();
        favRem.RemuneracaoProposta__c = remuneracao.Id;
        favRem.Conta__c = conta.Id;
        insert favRem;
        //PLV-4425 - INICIO
        ContratanteProposta__c contratante = new ContratanteProposta__c(
            Proposta__c = proposta.Id
        );
        insert contratante;

        GrupoProposta__c grupo = new GrupoProposta__c(
            Name = 'Paulo',
            ContratanteProposta__c = contratante.Id
        );
        insert grupo;

        SeguradoProposta__c seguradoP = new SeguradoProposta__c(
            GrupoProposta__c = grupo.Id
        );
        insert seguradoP;

        BeneficiarioSeguradoProposta__c beneficiario = new BeneficiarioSeguradoProposta__c(
            TipoBeneficiario__c = 'Nome do beneficiário',
            Nome__c = 'FRANCIS LIU',
            NomeSocial__c = 'Teste TI',//LECVPV 189 - INICIO/FIM
            CpfCnpj__c = '518.179.180-87',
            Data_de_nascimento__c = system.today(),
            GrauParentesco__c = 'Amigo (a)',
            Participacao__c = 100,
            SeguradoProposta__c = seguradoP.Id
        );
        insert beneficiario;

        
        List<String> lstGarantiaSigla = new List<String>{'DG', 'DIT', 'BAS', 'MAP', 'IPA'};
        List<Garantia__c> lstGarantias = new List<Garantia__c>();
        List<GarantiaProposta__c> lstGarantiasQuote = new List<GarantiaProposta__c>();
        
        for(String garantiaSigla : lstGarantiaSigla){
            Garantia__c garantia = new Garantia__c(
                Name        = 'garantia' + garantiaSigla,
                Sigla__c    = garantiaSigla
            );
            lstGarantias.add(garantia);
        }
        
        insert lstGarantias;
        
        for(Garantia__c garantia : lstGarantias){
            GarantiaProposta__c garantiaProposta = new GarantiaProposta__c(
                Proposta__c = proposta.id,
                Garantia__c = garantia.id,
                Capital__c = 100000
            );

            lstGarantiasQuote.add(garantiaProposta);
        }

        CriticaProposta__c criticaProposta = new CriticaProposta__c(
            Proposta__c = proposta.Id,        
            Status__c = 'Pendente',
            Tipo__c = 'Analise'     
        );
        insert criticaProposta;
        //PLV-4425 - FIM
        
        insert lstGarantiasQuote;
        
    }
    //FNPVVEP-69 - FIM


    //FNPVVEP-69 - INICIO
    /*@isTest //ANNVI-55 - INICIO
    static void testAll(){

        Quote quote = [SELECT Id, Name FROM Quote limit 1];
        Product2 product = [SELECT Id FROM Product2 WHERE Name = 'VIAGEM_VIDA_ON' LIMIT 1];
        product.CodigoPrecificaProduto__c = 'APTLMKT';
        update product;

        Test.StartTest();
            PageReference pageRef = Page.PropostaSeguroViagem;
            pageRef.getParameters().put('numProposta', String.valueOf(quote.Name));
            pageRef.getParameters().put('idProposta', quote.Id);
            Test.setCurrentPage(pageRef);
            new PropostaIndividualPDFController();
        Test.stopTest();
    }*/ //ANNVI-55 - FIM
    //FNPVVEP-69 - FIM

}