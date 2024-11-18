/*********************************************************************************************************************************************************************
@description  Classe para geração de dados iniciais no processo de contratação
@author KEVIN VOGADO - GLOBANT
@date 05/11/2024
@Classe criada por conta da história FNPVVEP-158
*******************************************************'*************************/

@isTest
public with sharing class BeneficiarioGarantiaBOTest {

    @IsTest
    static void testEfetuaPagamento() {
        Map<String, SObject> records = CreateTestData.createIntegratedScenario();

        BeneficiarioGarantia__c beneficiario = (BeneficiarioGarantia__c) records.get('BeneficiarioGarantia');
        PagamentoGarantia__c pagamentoGarantia = (PagamentoGarantia__c) records.get('PagamentoGarantia');

        ComplementoIndenizacao__c cmp = new ComplementoIndenizacao__c(
            TipoComplemento__c = 'Atualização Monetária',
            Valor__c = 20,
            PagamentoGarantia__c = pagamentoGarantia.Id,
            Descricao__c = 'Atualização Monetária'
        );

        insert cmp;

        pagamentoGarantia.Valor_indenizado__c  = 1;
        update pagamentoGarantia;


        beneficiario.Status__c = 'Pago';
        beneficiario.valorComplementos__c = 1;
        update beneficiario;

        beneficiario.Status__c = 'Pendente';
        Map<Id, BeneficiarioGarantia__c> pmOld = new Map<Id, BeneficiarioGarantia__c>{beneficiario.Id => beneficiario};

    }


    @IsTest
    static void testEfetuaPagamento2() {

        Map<String, SObject> records = new Map<String, SObject>();
        
        records.put('ContadorCodigoTec', CreateTestData.createContadorCodigoProdutoTecnico());
        records.put('AccountPessoaFisica', (Account) new AccountFactory.PessoaFisica().createRecord());
        records.put('DadosCorretor', CreateTestData.createDadosCorretor((Account) records.get('AccountPessoaFisica')));
        records.put('RamoSeguro', CreateTestData.createRamoSeguro((Account) records.get('AccountPessoaFisica')));
        records.put('RamoAtividade', CreateTestData.createRamoAtividade('Teste'));
        records.put('AccountPessoaJuridica', CreateTestData.createAccountWithRecordTypeAndRamoAtividade('PessoaJuridica', (RamoAtividade__c) records.get('RamoAtividade')));
        records.put('ProdutoTec', CreateTestData.createTechnicalProduct());
        records.put('ProdutoComercial', CreateTestData.createComercialProduct((Product2) records.get('ProdutoTec')));
        records.put('FormaPagamento', CreateTestData.createFormaPagamento());
        records.put('Parceiro', CreateTestData.createParceiro((Account) records.get('AccountPessoaJuridica'), (FormaPagamento__c) records.get('FormaPagamento')));
        records.put('Contrato', CreateTestData.createContract((Account) records.get('AccountPessoaFisica'), (Product2) records.get('ProdutoComercial'), (Parceiro__c) records.get('Parceiro'), (RamoSeguro__c) records.get('RamoSeguro'), (FormaPagamento__c) records.get('FormaPagamento'), (DadosCorretor__c) records.get('DadosCorretor')));//ANNVI-55 - INICIO/FIM
        records.put('TipoRemuneracao', CreateTestData.createTipoRemuneracaoByName('Corretagem'));
        records.put('RemuneracaoContrato', CreateTestData.createRemuneracaoContrato((Contract) records.get('Contrato'), (TipoRemuneracao__c) records.get('TipoRemuneracao')));
        records.put('FavorecidoRemuneracaoContrato', CreateTestData.createFavorecidoRemuneracaoContrato((Account) records.get('AccountPessoaFisica'), (RemuneracaoContrato__c) records.get('RemuneracaoContrato'), (DadosCorretor__c) records.get('DadosCorretor')));
        records.put('ContratanteContrato', CreateTestData.createContratanteContrato((Contract) records.get('Contrato'), (Account) records.get('AccountPessoaFisica'), (FormaPagamento__c) records.get('FormaPagamento')));
        records.put('GrupoContrato', CreateTestData.createGrupoContrato((ContratanteContrato__c) records.get('ContratanteContrato')));
        records.put('SeguradoContrato', CreateTestData.createSeguradoContrato((Account) records.get('AccountPessoaFisica'), (GrupoContrato__c) records.get('GrupoContrato')));
        records.put('Garantia', CreateTestData.createGarantia());
        records.put('GarantiaProdutoTec', CreateTestData.createGarantiaProdutoWithProdutoTecnico((Garantia__c) records.get('Garantia'), (Product2) records.get('ProdutoTec'), (RamoSeguro__c) records.get('RamoSeguro')));
        records.put('GarantiaProdutoComercial', CreateTestData.createGarantiaProdutoWithProdutoComercial((Garantia__c) records.get('Garantia'), (GarantiaProduto__c) records.get('GarantiaProdutoTec'), (Product2) records.get('ProdutoTec'), (RamoSeguro__c) records.get('RamoSeguro')));
        records.put('GarantiaSeguradoContrato', CreateTestData.createGarantiaSeguradoContrato((garantiaProduto__c) records.get('GarantiaProdutoComercial'),(SeguradoContrato__c) records.get('SeguradoContrato'), (Garantia__c) records.get('Garantia')));
        records.put('Carencia', CreateTestData.createCarencia());
        records.put('CarenciaContrato', CreateTestData.createCarenciaGarantia((GarantiaProduto__c) records.get('GarantiaProdutoTec'), (Carencia__c) records.get('Carencia')));
        records.put('CasoPadrao', CreateTestData.createCaso());
        records.put('CasoSinistro', CreateTestData.createCasoSinistro((Case) records.get('CasoPadrao'), (Contract) records.get('Contrato'), (GarantiaSeguradoContrato__c) records.get('GarantiaSeguradoContrato'), false));
        records.put('PagamentoGarantia', CreateTestData.createPagamentoGarantia((Case) records.get('CasoSinistro'), (GarantiaSeguradoContrato__c) records.get('GarantiaSeguradoContrato')));

        PagamentoGarantia__c pagamentoGarantia = (PagamentoGarantia__c) records.get('PagamentoGarantia');
        Account conta = (Account) records.get('AccountPessoaFisica');

        ComplementoIndenizacao__c cmp = new ComplementoIndenizacao__c(
            TipoComplemento__c = 'Atualização Monetária',
            Valor__c = 60,
            PagamentoGarantia__c = pagamentoGarantia.Id,
            Descricao__c = 'Atualização Monetária'
        );

        insert cmp;

        pagamentoGarantia.Valor_indenizado__c  = 1;
        update pagamentoGarantia;

        BeneficiarioGarantia__c beneficiarioGarantia = new BeneficiarioGarantia__c(
            Pagamento_de_garantia__c = pagamentoGarantia.Id,
            Conta__c = conta.Id,
            Status__c = 'Pendente',
            Tipo_de_Pagamento__c = 'Cheque',
            InformarIndenizacao__c = 'Valor de Indenização', 
            ValorIndenizacao__c = 20.00, 
            Sucursal_Destino_de_Cheque__c = 10,
            Permitir_Alteracao__c = true,
            Data_programada_do_pagamento__c = System.today() + 2,
            StatusSerasa__c = 'Atualizado',
            valorComplementos__c = 1
        );

        insert beneficiarioGarantia;
        beneficiarioGarantia.Status__c = 'Pago';


        Test.startTest();
            update beneficiarioGarantia;
        Test.stopTest();
        
    }
}