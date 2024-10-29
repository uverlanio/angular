/*********************************************************************************************************************************************************************
@description Classe de teste da batch responsavel por dar baixar nos casos de sinistro com Reserva 
@author Rogerio Souza de Menezes - Globant
@date 10/08/2023
**********************************************************************************************************************************************************************/
//II-59 INICIO
@isTest
private class BatchBaixaReservaTest {

    @TestSetup
    static void makeData() {
        Account conta = (Account) new AccountFactory.PessoaFisica().getRecord();
        insert conta;

        RamoAtividade__c ramoAtividade = (RamoAtividade__c) new RamoAtividadeFactory().createRecord();
        Account contaParceiro = (Account) new AccountFactory.PessoaJuridica(ramoAtividade).getRecord();
        insert contaParceiro;

        FormaPagamento__c formaPagamento = (FormaPagamento__c) new FormaPagamentoFactory().createRecord();
        Product2 produto = criarProduto();

        Parceiro__c parceiro = new Parceiro__c(
            Status__c = 'Ativo',
            Sucursal__c = '1',
            Ramo__c = '1391',
            Empresa__c = '1',
            Conta__c = conta.Id,
            FormaPagamento__c = formaPagamento.Id,
            DiaFaturamento__c = '15',
            DiaPreFaturamento__c = '20',
            PrazoVencimento__c = '10',
            FaturaProdutosSeparados__c = 'Sim',
            PossuiAnexoFatura__c = 'Nao',
            SiglaParceiro__c = 'PAR'
        );
        insert parceiro;

        Contract contrato = new Contract(
            Name = 'teste',
            AccountId = conta.Id,
            Produto__c = produto.Id,
            Parceria__c = parceiro.Id,
            CodigoRamo__c = '1369'
        );
        insert contrato;

        ContratanteContrato__c contratanteContrato = new ContratanteContrato__c(
            Contrato__c = contrato.Id,
            Conta__c = conta.Id,
            Tipo__c = 'Principal'
        );
        insert contratanteContrato;

        GrupoContrato__c grupoContrato = new GrupoContrato__c(
            ContratanteContrato__c = contratanteContrato.Id
        );
        insert grupoContrato;

        SeguradoContrato__c seguradoContrato = new SeguradoContrato__c(
            Conta__c = conta.Id,
            GrupoContrato__c = grupoContrato.Id,
            VigenciaInicial__c = system.today(),
            VigenciaFinal__c = system.today().addMonths(1)
        );
        insert seguradoContrato; 

        Garantia__c garantia = (Garantia__c) new GarantiaFactory().getRecord();
        garantia.Sigla__c = 'DMHO';
        insert garantia;

        GarantiaSeguradoContrato__c garantiaSeguradoContrato = new GarantiaSeguradoContrato__c(
            SeguradoContrato__c = seguradoContrato.Id,
            Garantia__c = garantia.Id
        );
        insert garantiaSeguradoContrato;

         // II-59-FIX02-INICIO
        List<PagamentoGarantia__c> garantias = new List<PagamentoGarantia__c>();
        Datetime dtSinAvisado = Date.today().addDays(-150);

        Case caso1 = gerarCenarioCaso(false, 'Atendimento', 1369, 'Sinistro', false, '', dtSinAvisado, 1, 'Liquidação', 'Em análise');
        insert caso1;

        //FNPVVEP-19 - INICIO
        insert new MovimentoSinistro__c(
            Caso__c = caso1.id,
            DataMovimento__c = System.now(),
            DescricaoMovimento__c = '1',
            TipoMovimento__c = 'Aviso',
            ValorMovimento__c = 500,
            SequenciaMovimento__c = '1'
        );
        //FNPVVEP-19 - FIM


        PagamentoGarantia__c garantia1 = gerarCenarioGarantia('Assistência Funeral Individual', caso1, garantiaSeguradoContrato, 'Fechado', 'Pago', 1);
        garantias.add(garantia1);

        Case caso2 = gerarCenarioCaso(false, 'Atendimento', 1369, 'Sinistro', false, '', dtSinAvisado, 1, 'Liquidação', 'Em análise');
        insert caso2;       
        PagamentoGarantia__c garantia2 = gerarCenarioGarantia('Assistência Funeral Individual', caso2, garantiaSeguradoContrato, 'Aberto', 'Em análise', 1);
        garantias.add(garantia2);

        Case caso3 = gerarCenarioCaso(false, 'Atendimento', 1369, 'Sinistro', false, '', dtSinAvisado, 1, 'Em Regulação', 'Com Pendências');
        insert caso3;             
        PagamentoGarantia__c garantia3 = gerarCenarioGarantia('Assistência Funeral Individual', caso3, garantiaSeguradoContrato, 'Aberto', 'Em análise', 1);
        garantias.add(garantia3);

        Case caso4 = gerarCenarioCaso(false, 'Atendimento', 1369, 'Sinistro', false, '', dtSinAvisado, 0, 'Em análise', 'Aberto');
        insert caso4;        
        PagamentoGarantia__c garantia4 = gerarCenarioGarantia('Morte', caso4, garantiaSeguradoContrato, 'Fechado', 'Pago', 1);
        garantias.add(garantia4);

        insert garantias;
        // II-59-FIX02-FIM
    }

    private static Product2 criarProduto(){
        Product2 produto = new Product2(
            Name = 'teste',
            NumeroSusep__c = '123',
            VersaoRenovacao__c = 'Versão atual',
            Status__c = 'Ativo',
            ProductCode = '32'
        );

        return produto;
    }

    // II-59-FIX02-INICIO
    private static Case gerarCenarioCaso(Boolean isSinJud, String origem, Integer ramo, String tipo, Boolean isInter, String invc, Datetime dtSinAv, Decimal SaldRes, String fase, String status){
        Case caso = new Case(
            Sinistro_Judicial__c = isSinJud,
            Origin = origem,
            RamoSplit__c = ramo,
            Type = tipo,
            Internacional__c = isInter,
            Invoice__c = invc,
            Data_sinistro_avisado__c = dtSinAv,
            Saldo_da_reserva__c = SaldRes,
            Status = fase,
            Status_Dependente__c = status
        );
        return caso;
    }

    private static PagamentoGarantia__c gerarCenarioGarantia(String garName, Case caso, GarantiaSeguradoContrato__c garSecContr, String fase, String statusPgto, Decimal SaldRes){
        PagamentoGarantia__c garantia = new PagamentoGarantia__c(
            Name = garName,
            Caso__c = caso.Id,
            Caso__r = caso,
            Garantia_do_segurado_do_contrato__c = garSecContr.Id,
            Fase__c = fase,
            Status_do_pagamento__c = statusPgto,
            Saldo_da_reserva__c = SaldRes
        );        
        return garantia;
    }

    @isTest static void testarAgendarBatch(){
        Test.startTest();
        Boolean isException = false;
        BatchBaixaReserva batch = new BatchBaixaReserva();
        try{
            batch.agendarBatch();
        }catch(Exception e){
            isException = true;
        }
        System.assert(!isException);

        Test.stopTest();        
    }
    // II-59-FIX02-FIM

    @isTest static void testarAgendamento(){
        Test.startTest();
        Boolean isException = false;
        BatchBaixaReserva batch = new BatchBaixaReserva();
        try{
            System.schedule('BatchBaixaReserva', '0 7 11 * * ?', batch);
        }catch(Exception e){
            isException = true;
        }
        System.assert(!isException);

        Test.stopTest();        
    }

    @isTest static void testarExecucaoBatch(){
        Test.startTest();
        Boolean isException = false;
        try{
            Database.executeBatch(new BatchBaixaReserva());
        }catch(Exception e){
            isException = true;
        }
        System.assert(!isException);
        Test.stopTest();        
    }
}
//II-59 FIM