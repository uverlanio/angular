/*
@author Kevin Vogado - Globant
@date 27/06/2024
@Classe criada para cobrir a CreateTestData (FNPVVEP-46)
*/
@isTest
public with sharing class CreateTestDataTest {

    @isTest static void testCreateIntegratedScenario() {
        Test.startTest();
        Map<String, SObject> records = CreateTestData.createIntegratedScenario();
        Test.stopTest();
        
        System.assertEquals(35, records.size(), 'Expected 35 records to be created');//ANNVI-55 - INICIO/FIM
        
        System.assert(records.containsKey('ContadorCodigoTec'), 'Expected ContadorCodigoTec to be created');
        System.assert(records.get('ContadorCodigoTec') instanceof ContadorCodigo__c, 'Expected ContadorCodigoTec to be of type ContadorCodigo__c');
        
        System.assert(records.containsKey('AccountPessoaFisica'), 'Expected AccountPessoaFisica to be created');
        System.assert(records.get('AccountPessoaFisica') instanceof Account, 'Expected AccountPessoaFisica to be of type Account');
        
        System.assert(records.containsKey('DadosCorretor'), 'Expected DadosCorretor to be created');
        System.assert(records.get('DadosCorretor') instanceof DadosCorretor__c, 'Expected DadosCorretor to be of type DadosCorretor__c');
        
        System.assert(records.containsKey('RamoSeguro'), 'Expected RamoSeguro to be created');
        System.assert(records.get('RamoSeguro') instanceof RamoSeguro__c, 'Expected RamoSeguro to be of type RamoSeguro__c');
        
        System.assert(records.containsKey('RamoAtividade'), 'Expected RamoAtividade to be created');
        System.assert(records.get('RamoAtividade') instanceof RamoAtividade__c, 'Expected RamoAtividade to be of type RamoAtividade__c');
        
        System.assert(records.containsKey('AccountPessoaJuridica'), 'Expected AccountPessoaJuridica to be created');
        System.assert(records.get('AccountPessoaJuridica') instanceof Account, 'Expected AccountPessoaJuridica to be of type Account');
        
        System.assert(records.containsKey('ProdutoTec'), 'Expected ProdutoTec to be created');
        System.assert(records.get('ProdutoTec') instanceof Product2, 'Expected ProdutoTec to be of type Product2');
        
        System.assert(records.containsKey('ProdutoComercial'), 'Expected ProdutoComercial to be created');
        System.assert(records.get('ProdutoComercial') instanceof Product2, 'Expected ProdutoComercial to be of type Product2');
        
        System.assert(records.containsKey('FormaPagamento'), 'Expected FormaPagamento to be created');
        System.assert(records.get('FormaPagamento') instanceof FormaPagamento__c, 'Expected FormaPagamento to be of type FormaPagamento__c');
        
        System.assert(records.containsKey('Parceiro'), 'Expected Parceiro to be created');
        System.assert(records.get('Parceiro') instanceof Parceiro__c, 'Expected Parceiro to be of type Parceiro__c');
        
        System.assert(records.containsKey('Contrato'), 'Expected Contrato to be created');
        System.assert(records.get('Contrato') instanceof Contract, 'Expected Contrato to be of type Contract');
        
        System.assert(records.containsKey('TipoRemuneracao'), 'Expected TipoRemuneracao to be created');
        System.assert(records.get('TipoRemuneracao') instanceof TipoRemuneracao__c, 'Expected TipoRemuneracao to be of type TipoRemuneracao__c');
        
        System.assert(records.containsKey('RemuneracaoContrato'), 'Expected RemuneracaoContrato to be created');
        System.assert(records.get('RemuneracaoContrato') instanceof RemuneracaoContrato__c, 'Expected RemuneracaoContrato to be of type RemuneracaoContrato__c');
        
        System.assert(records.containsKey('FavorecidoRemuneracaoContrato'), 'Expected FavorecidoRemuneracaoContrato to be created');
        System.assert(records.get('FavorecidoRemuneracaoContrato') instanceof FavorecidoRemuneracaoContrato__c, 'Expected FavorecidoRemuneracaoContrato to be of type FavorecidoRemuneracaoContrato__c');
        
        System.assert(records.containsKey('ContratanteContrato'), 'Expected ContratanteContrato to be created');
        System.assert(records.get('ContratanteContrato') instanceof ContratanteContrato__c, 'Expected ContratanteContrato to be of type ContratanteContrato__c');
        
        System.assert(records.containsKey('GrupoContrato'), 'Expected GrupoContrato to be created');
        System.assert(records.get('GrupoContrato') instanceof GrupoContrato__c, 'Expected GrupoContrato to be of type GrupoContrato__c');
        
        System.assert(records.containsKey('SeguradoContrato'), 'Expected SeguradoContrato to be created');
        System.assert(records.get('SeguradoContrato') instanceof SeguradoContrato__c, 'Expected SeguradoContrato to be of type SeguradoContrato__c');
        
        System.assert(records.containsKey('Garantia'), 'Expected Garantia to be created');
        System.assert(records.get('Garantia') instanceof Garantia__c, 'Expected Garantia to be of type Garantia__c');
        
        System.assert(records.containsKey('GarantiaProdutoTec'), 'Expected GarantiaProdutoTec to be created');
        System.assert(records.get('GarantiaProdutoTec') instanceof GarantiaProduto__c, 'Expected GarantiaProdutoTec to be of type GarantiaProduto__c');
        
        System.assert(records.containsKey('GarantiaProdutoComercial'), 'Expected GarantiaProdutoComercial to be created');
        System.assert(records.get('GarantiaProdutoComercial') instanceof GarantiaProduto__c, 'Expected GarantiaProdutoComercial to be of type GarantiaProduto__c');
        
        System.assert(records.containsKey('GarantiaSeguradoContrato'), 'Expected GarantiaSeguradoContrato to be created');
        System.assert(records.get('GarantiaSeguradoContrato') instanceof GarantiaSeguradoContrato__c, 'Expected GarantiaSeguradoContrato to be of type GarantiaSeguradoContrato__c');
        
        System.assert(records.containsKey('Carencia'), 'Expected Carencia to be created');
        System.assert(records.get('Carencia') instanceof Carencia__c, 'Expected Carencia to be of type Carencia__c');
        
        System.assert(records.containsKey('CarenciaContrato'), 'Expected CarenciaContrato to be created');
        System.assert(records.get('CarenciaContrato') instanceof CarenciaGarantia__c, 'Expected CarenciaContrato to be of type CarenciaGarantia__c');
        
        System.assert(records.containsKey('CasoPadrao'), 'Expected CasoPadrao to be created');
        System.assert(records.get('CasoPadrao') instanceof Case, 'Expected CasoPadrao to be of type Case');
        
        System.assert(records.containsKey('CasoSinistro'), 'Expected CasoSinistro to be created');
        System.assert(records.get('CasoSinistro') instanceof Case, 'Expected CasoSinistro to be of type Case');
        
        System.assert(records.containsKey('PagamentoGarantia'), 'Expected PagamentoGarantia to be created');
        System.assert(records.get('PagamentoGarantia') instanceof PagamentoGarantia__c, 'Expected PagamentoGarantia to be of type PagamentoGarantia__c');
        
        System.assert(records.containsKey('BeneficiarioGarantia'), 'Expected BeneficiarioGarantia to be created');
        System.assert(records.get('BeneficiarioGarantia') instanceof BeneficiarioGarantia__c, 'Expected BeneficiarioGarantia to be of type BeneficiarioGarantia__c');
        
        System.assert(records.containsKey('Banco'), 'Expected Banco to be created');
        System.assert(records.get('Banco') instanceof Banco__c, 'Expected Banco to be of type Banco__c');
        
        System.assert(records.containsKey('InformacaoBancaria'), 'Expected InformacaoBancaria to be created');
        System.assert(records.get('InformacaoBancaria') instanceof InformacaoBancaria__c, 'Expected InformacaoBancaria to be of type InformacaoBancaria__c');
        
        System.assert(records.containsKey('PagamentoDeSinistro'), 'Expected PagamentoDeSinistro to be created');
        System.assert(records.get('PagamentoDeSinistro') instanceof Pagamento_de_Sinistro__c, 'Expected PagamentoDeSinistro to be of type Pagamento_de_Sinistro__c');
    }

}