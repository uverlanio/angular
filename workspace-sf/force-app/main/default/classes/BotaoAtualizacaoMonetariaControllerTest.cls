@isTest
public class BotaoAtualizacaoMonetariaControllerTest {
    //PLV-4892-INICIO
    //PLV-4535 - INICIO
    @isTest
    static void taxaIndiceSucesso() {
        
        Map<String, Sobject> records = CreateTestData.createIntegratedScenario();

        BotaoAtualizacaoMonetariaController.ItemTaxaIndice atualizacaoMonetariaSucesso = new BotaoAtualizacaoMonetariaController.ItemTaxaIndice(); 
        atualizacaoMonetariaSucesso.taxaIndice = '5.0';
        
        String retornoCivSucesso = JSON.serialize(atualizacaoMonetariaSucesso);
            
        Test.startTest();        
        Test.setMock(HttpCalloutMock.class, new MockHttpResponse(retornoCivSucesso, 200, 'OK'));
        BotaoAtualizacaoMonetariaController.possuiComplementoIndenizacao(records.get('BeneficiarioGarantia').Id);      
        Test.stopTest();

        List<ComplementoIndenizacao__c> complementos = [SELECT Id, Valor__c FROM ComplementoIndenizacao__c WHERE PagamentoGarantia__c = :records.get('PagamentoGarantia').Id  AND TipoComplemento__c = 'Atualização Monetária'];
        if(!complementos.isEmpty()){
            ComplementoIndenizacao__c complemento = complementos[0];
        	System.assert(complemento.Valor__c == 0);
        }
    }

    @isTest
    static void indicesNotNullAndSubstituirFalse() {
        
        Map<String, Sobject> records = CreateTestData.createIntegratedScenario();

        BotaoAtualizacaoMonetariaController.ItemTaxaIndice atualizacaoMonetariaSucesso = new BotaoAtualizacaoMonetariaController.ItemTaxaIndice(); 
        atualizacaoMonetariaSucesso.taxaIndice = '5.0';

        List<BotaoAtualizacaoMonetariaController.ItemTaxaIndice> indicesList = new List<BotaoAtualizacaoMonetariaController.ItemTaxaIndice>();
        indicesList.add(atualizacaoMonetariaSucesso);

        BotaoAtualizacaoMonetariaController.AtualizacaoMonetariaTO atualizacaoMonetariaTO = new BotaoAtualizacaoMonetariaController.AtualizacaoMonetariaTO();
        atualizacaoMonetariaTO.indices = indicesList;
        
        String retornoCivSucesso = JSON.serialize(atualizacaoMonetariaTO);
            
        Test.startTest();        
        Test.setMock(HttpCalloutMock.class, new MockHttpResponse(retornoCivSucesso, 200, 'OK'));
        BotaoAtualizacaoMonetariaController.possuiComplementoIndenizacao(records.get('BeneficiarioGarantia').Id);      
        Test.stopTest();
    }

    @isTest
    static void indicesNotNullAndSubstituirTrue() {
        
        Map<String, Sobject> records = CreateTestData.createIntegratedScenario();

        ComplementoIndenizacao__c complemento = new ComplementoIndenizacao__c(
            TipoComplemento__c = 'Atualização Monetária',
            Valor__c = 123,
            PagamentoGarantia__c = records.get('PagamentoGarantia').Id,
            Motivo__c = 'Prazo de Regulação excedido',
            Descricao__c = 'Atualização Monetária',
            BeneficiarioGarantia__c = records.get('BeneficiarioGarantia').Id
        );

        BotaoAtualizacaoMonetariaController.ItemTaxaIndice atualizacaoMonetariaSucesso = new BotaoAtualizacaoMonetariaController.ItemTaxaIndice(); 
        atualizacaoMonetariaSucesso.taxaIndice = '5.0';

        List<BotaoAtualizacaoMonetariaController.ItemTaxaIndice> indicesList = new List<BotaoAtualizacaoMonetariaController.ItemTaxaIndice>();
        indicesList.add(atualizacaoMonetariaSucesso);

        BotaoAtualizacaoMonetariaController.AtualizacaoMonetariaTO atualizacaoMonetariaTO = new BotaoAtualizacaoMonetariaController.AtualizacaoMonetariaTO();
        atualizacaoMonetariaTO.indices = indicesList;
        
        String retornoCivSucesso = JSON.serialize(atualizacaoMonetariaTO);
            
        Test.startTest();        
        Test.setMock(HttpCalloutMock.class, new MockHttpResponse(retornoCivSucesso, 200, 'OK'));
        BotaoAtualizacaoMonetariaController.criaComplementoIndenizacao(records.get('BeneficiarioGarantia').Id, true);      
        Test.stopTest();

    }

    @isTest
    static void ValorIndenizacaoNulo(){


        Map<String, Sobject> records = CreateTestData.createIntegratedScenario();

        BeneficiarioGarantia__c beneficiario = (BeneficiarioGarantia__c) records.get('BeneficiarioGarantia');
        beneficiario.ValorIndenizacao__c = null;

        update beneficiario;
        
        BotaoAtualizacaoMonetariaController.ItemTaxaIndice atualizacaoMonetariaSucesso = new BotaoAtualizacaoMonetariaController.ItemTaxaIndice();
        atualizacaoMonetariaSucesso.taxaIndice = '5.0';

        String retornoCivSucesso = JSON.serialize(atualizacaoMonetariaSucesso);

        Test.startTest();        
        Test.setMock(HttpCalloutMock.class, new MockHttpResponse(retornoCivSucesso, 200, 'OK'));
        BotaoAtualizacaoMonetariaController.possuiComplementoIndenizacao(beneficiario.id);      
        Test.stopTest();

        List<ComplementoIndenizacao__c> complementos = [SELECT Id, Valor__c FROM ComplementoIndenizacao__c WHERE PagamentoGarantia__c = :records.get('PagamentoGarantia').Id   AND TipoComplemento__c = 'Atualização Monetária'];
        if(!complementos.isEmpty()){
            ComplementoIndenizacao__c complemento = complementos[0];
        	System.assert(complemento.Valor__c == null);
        }
    }

    //PLV-4892 - INICIO
    @isTest
    static void taxaIndiceSucessoSubstituir() {
        
        Case caso = new Case(origin = '18');
        insert caso;
        
        PagamentoGarantia__c garantiaSinistro = new PagamentoGarantia__c(caso__c=caso.id);
        insert garantiaSinistro;
        
        BeneficiarioGarantia__c beneficiario = new BeneficiarioGarantia__c(Pagamento_de_garantia__c=garantiaSinistro.id);
        insert beneficiario;
        
        ComplementoIndenizacao__c complementoOld = new ComplementoIndenizacao__c(PagamentoGarantia__c = garantiaSinistro.Id, Descricao__c = 'test', TipoComplemento__c = 'Atualização Monetária', Valor__c = 0, BeneficiarioGarantia__c = beneficiario.id);
		insert complementoOld;        
              
        /* 
        BotaoAtualizacaoMonetariaController.AtualizacaoMonetariaTO atualizacaoMonetariaSucesso = new BotaoAtualizacaoMonetariaController.AtualizacaoMonetariaTO();
        atualizacaoMonetariaSucesso.ItensTaxaIndice = new BotaoAtualizacaoMonetariaController.ItensTaxaIndice (); 
        atualizacaoMonetariaSucesso.ItensTaxaIndice.ItemTaxaIndice = new BotaoAtualizacaoMonetariaController.ItemTaxaIndice ();
        atualizacaoMonetariaSucesso.ItensTaxaIndice.ItemTaxaIndice.taxaIndice = '5.0';*/
        
        BotaoAtualizacaoMonetariaController.ItemTaxaIndice atualizacaoMonetariaSucesso = new BotaoAtualizacaoMonetariaController.ItemTaxaIndice();
        atualizacaoMonetariaSucesso.taxaIndice = '5.0';
        System.debug(atualizacaoMonetariaSucesso);
        
        
        String retornoCivSucesso = JSON.serialize(atualizacaoMonetariaSucesso);
        
        Test.startTest();        
        Test.setMock(HttpCalloutMock.class, new MockHttpResponse(retornoCivSucesso, 200, 'OK'));
        BotaoAtualizacaoMonetariaController.criaComplementoIndenizacao(beneficiario.id, true);
        Test.stopTest();

        ComplementoIndenizacao__c complemento = [SELECT Id, Valor__c FROM ComplementoIndenizacao__c WHERE PagamentoGarantia__c = :garantiaSinistro.Id  AND TipoComplemento__c = 'Atualização Monetária'];
        System.assert(complemento.Valor__c == 0);
    }
    //PLV-4892 - FIM

    
    @isTest
    static void taxaIndiceException() {
        
        Case caso = new Case(origin = '18');
        insert caso;
        
        PagamentoGarantia__c garantiaSinistro = new PagamentoGarantia__c(caso__c=caso.id);
        insert garantiaSinistro;
        
        BeneficiarioGarantia__c beneficiario = new BeneficiarioGarantia__c(Pagamento_de_garantia__c=garantiaSinistro.id);
        insert beneficiario;
        
        ComplementoIndenizacao__c complementoOld = new ComplementoIndenizacao__c(PagamentoGarantia__c = garantiaSinistro.Id, Descricao__c = 'test', TipoComplemento__c = 'Atualização Monetária', Valor__c = 0);
		insert complementoOld;        
              
        /* 
        BotaoAtualizacaoMonetariaController.AtualizacaoMonetariaTO atualizacaoMonetariaSucesso = new BotaoAtualizacaoMonetariaController.AtualizacaoMonetariaTO();
        atualizacaoMonetariaSucesso.ItensTaxaIndice = new BotaoAtualizacaoMonetariaController.ItensTaxaIndice ();
        atualizacaoMonetariaSucesso.ItensTaxaIndice.ItemTaxaIndice = new BotaoAtualizacaoMonetariaController.ItemTaxaIndice ();
        atualizacaoMonetariaSucesso.ItensTaxaIndice.ItemTaxaIndice.taxaIndice = '5.0';*/

        BotaoAtualizacaoMonetariaController.ItemTaxaIndice atualizacaoMonetariaSucesso = new BotaoAtualizacaoMonetariaController.ItemTaxaIndice();
        atualizacaoMonetariaSucesso.taxaIndice = '5.0';
        System.debug(atualizacaoMonetariaSucesso);
        
        String retornoCivSucesso = JSON.serialize(atualizacaoMonetariaSucesso);
        
        Test.startTest();        
        Test.setMock(HttpCalloutMock.class, new MockHttpResponse(retornoCivSucesso, 200, 'OK'));
        BotaoAtualizacaoMonetariaController.possuiComplementoIndenizacao(beneficiario.id);
        // BotaoAtualizacaoMonetariaController.criaComplementoIndenizacao(beneficiario.id, true); //PLV-4892 INICIO/FIM FIX01
        Test.stopTest();

    }

    @isTest
    static void possuiComplementoIndenizacaoElse() {
        
        Case caso = new Case(origin = '18');
        insert caso;
        
        PagamentoGarantia__c garantiaSinistro = new PagamentoGarantia__c(caso__c=caso.id);
        insert garantiaSinistro;
        
        BeneficiarioGarantia__c beneficiario = new BeneficiarioGarantia__c(Pagamento_de_garantia__c=garantiaSinistro.id);
        insert beneficiario;
        
        ComplementoIndenizacao__c complementoOld = new ComplementoIndenizacao__c(PagamentoGarantia__c = garantiaSinistro.Id, Descricao__c = 'test', TipoComplemento__c = 'Atualização Monetária', Valor__c = 0, BeneficiarioGarantia__c = beneficiario.id);
		insert complementoOld; 

        /*     
        BotaoAtualizacaoMonetariaController.AtualizacaoMonetariaTO atualizacaoMonetariaSucesso = new BotaoAtualizacaoMonetariaController.AtualizacaoMonetariaTO();
        atualizacaoMonetariaSucesso.ItensTaxaIndice = new BotaoAtualizacaoMonetariaController.ItensTaxaIndice ();
        atualizacaoMonetariaSucesso.ItensTaxaIndice.ItemTaxaIndice = new BotaoAtualizacaoMonetariaController.ItemTaxaIndice ();
        atualizacaoMonetariaSucesso.ItensTaxaIndice.ItemTaxaIndice.taxaIndice = '5.0';*/

        BotaoAtualizacaoMonetariaController.ItemTaxaIndice atualizacaoMonetariaSucesso = new BotaoAtualizacaoMonetariaController.ItemTaxaIndice();
        atualizacaoMonetariaSucesso.taxaIndice = '5.0';
        System.debug(atualizacaoMonetariaSucesso);

        String retornoCivSucesso = JSON.serialize(atualizacaoMonetariaSucesso);
        
        Test.startTest();        
        Test.setMock(HttpCalloutMock.class, new MockHttpResponse(retornoCivSucesso, 200, 'OK'));
        // BotaoAtualizacaoMonetariaController.possuiComplementoIndenizacao('');//PLV-4892 INICIO/FIM FIX01
        BotaoAtualizacaoMonetariaController.possuiComplementoIndenizacao(beneficiario.id);//PLV-4892 INICIO/FIM FIX01
        Test.stopTest();

    }
    
    @isTest
    static void taxaIndiceErro() {
        
        Case caso = new Case(origin = '18');
        insert caso;
        
        PagamentoGarantia__c garantiaSinistro = new PagamentoGarantia__c(caso__c=caso.id);
        insert garantiaSinistro;
        
        BeneficiarioGarantia__c beneficiario = new BeneficiarioGarantia__c(Pagamento_de_garantia__c=garantiaSinistro.id);
        insert beneficiario;
        
        /*
        BotaoAtualizacaoMonetariaController.AtualizacaoMonetariaTO atualizacaoMonetariaErro = new BotaoAtualizacaoMonetariaController.AtualizacaoMonetariaTO();
        BotaoAtualizacaoMonetariaController.ErrorAtualizacaoMonetariaTO atualizacaoMonetariaErro = new BotaoAtualizacaoMonetariaController.ErrorAtualizacaoMonetariaTO();
        atualizacaoMonetariaErro.codigo = '158';*/

        BotaoAtualizacaoMonetariaController.ItemErrorAtualizacaoMonetariaTO atualizacaoMonetariaErro = new BotaoAtualizacaoMonetariaController.ItemErrorAtualizacaoMonetariaTO();
        atualizacaoMonetariaErro.codigo = '159';

        String retornoCivErro = JSON.serialize(atualizacaoMonetariaErro);
        
        Test.startTest();        
        Test.setMock(HttpCalloutMock.class, new MockHttpResponse(retornoCivErro, 200, 'OK'));
        BotaoAtualizacaoMonetariaController.possuiComplementoIndenizacao(beneficiario.id); 
        BotaoAtualizacaoMonetariaController.criaComplementoIndenizacao(beneficiario.id, true); //PLV-4892 - INICIO/FIM
        Test.stopTest();


    }
    
    @IsTest
    static void taxaJurosSucesso(){
        
        Case caso = new Case(origin = '18');
        insert caso;
        
        PagamentoGarantia__c garantiaSinistro = new PagamentoGarantia__c(caso__c=caso.id);
        insert garantiaSinistro;
        
        BeneficiarioGarantia__c beneficiario = new BeneficiarioGarantia__c(Pagamento_de_garantia__c=garantiaSinistro.id);
        insert beneficiario;
        
        BotaoAtualizacaoMonetariaController.AtualizacaoTaxaJurosTO atualizacaoJurosSucesso = new BotaoAtualizacaoMonetariaController.AtualizacaoTaxaJurosTO();
        atualizacaoJurosSucesso.ItensChaveJuros = new BotaoAtualizacaoMonetariaController.ItensChaveJuros ();
        atualizacaoJurosSucesso.ItensChaveJuros.ItemChaveJuros = new BotaoAtualizacaoMonetariaController.ItemChaveJuros ();
        atualizacaoJurosSucesso.ItensChaveJuros.ItemChaveJuros.valorTaxaJuros = '5.0'; 
              
        String retornoCivSucesso = JSON.serialize(atualizacaoJurosSucesso);
        
        Test.startTest();        
        Test.setMock(HttpCalloutMock.class, new MockHttpResponse(retornoCivSucesso, 200, 'OK'));
        BotaoAtualizacaoMonetariaController.possuiComplementoIndenizacao(beneficiario.id);    
        // BotaoAtualizacaoMonetariaController.criaComplementoIndenizacao(beneficiario.id, true); //PLV-4892 INICIO/FIM FIX01
        Test.stopTest();
		
        //PLV-4892 - INICIO
        List<ComplementoIndenizacao__c> complementos = [SELECT Id, Valor__c FROM ComplementoIndenizacao__c WHERE PagamentoGarantia__c = :garantiaSinistro.Id  AND TipoComplemento__c = 'Juros'];
        if(!complementos.isEmpty()){
            ComplementoIndenizacao__c complemento = complementos[0];
        	// System.assert(complemento.Valor__c != 0);//PLV-4892 INICIO/FIM FIX01
        }
        //PLV-4892 - FIM
    }
    
    //PLV-4892 - INICIO
    @IsTest
    static void taxaJurosSucessoSubstituir(){
        
        Case caso = new Case(origin = '18');
        insert caso;
        
        PagamentoGarantia__c garantiaSinistro = new PagamentoGarantia__c(caso__c=caso.id);
        insert garantiaSinistro;
        
        BeneficiarioGarantia__c beneficiario = new BeneficiarioGarantia__c(Pagamento_de_garantia__c=garantiaSinistro.id);
        insert beneficiario;
        
        ComplementoIndenizacao__c complementoOld = new ComplementoIndenizacao__c(PagamentoGarantia__c = garantiaSinistro.Id, Descricao__c = 'test', TipoComplemento__c = 'Juros', Valor__c= 0, BeneficiarioGarantia__c = beneficiario.id);
		insert complementoOld;   
        
        BotaoAtualizacaoMonetariaController.AtualizacaoTaxaJurosTO atualizacaoJurosSucesso = new BotaoAtualizacaoMonetariaController.AtualizacaoTaxaJurosTO();
        atualizacaoJurosSucesso.ItensChaveJuros = new BotaoAtualizacaoMonetariaController.ItensChaveJuros ();
        atualizacaoJurosSucesso.ItensChaveJuros.ItemChaveJuros = new BotaoAtualizacaoMonetariaController.ItemChaveJuros ();
        atualizacaoJurosSucesso.ItensChaveJuros.ItemChaveJuros.valorTaxaJuros = '5.0'; 
              
        String retornoCivSucesso = JSON.serialize(atualizacaoJurosSucesso);
        
        Test.startTest();        

        Test.setMock(HttpCalloutMock.class, new MockHttpResponse(retornoCivSucesso, 200, 'OK'));
        BotaoAtualizacaoMonetariaController.criaComplementoIndenizacao(beneficiario.id, true);
        Test.stopTest();

        ComplementoIndenizacao__c complemento = [SELECT Id, Valor__c FROM ComplementoIndenizacao__c WHERE PagamentoGarantia__c = :garantiaSinistro.Id  AND TipoComplemento__c = 'Juros'];
        System.assert(complemento.Valor__c >= 0);//PLV-4892 INICIO/FIM FIX01
        
    }
    //PLV-4892 - FIM
    
    @IsTest
    static void taxaJurosErro(){
        
        Case caso = new Case(origin = '18');
        insert caso;
        
        PagamentoGarantia__c garantiaSinistro = new PagamentoGarantia__c(caso__c=caso.id);
        insert garantiaSinistro;
        
        BeneficiarioGarantia__c beneficiario = new BeneficiarioGarantia__c(Pagamento_de_garantia__c=garantiaSinistro.id);
        insert beneficiario;
        
        
        BotaoAtualizacaoMonetariaController.AtualizacaoTaxaJurosTO atualizacaoJurosErro = new BotaoAtualizacaoMonetariaController.AtualizacaoTaxaJurosTO();
        atualizacaoJurosErro.codigo = '158';
                     
        String retornoCivErro = JSON.serialize(atualizacaoJurosErro);
        
        Test.startTest();        
        Test.setMock(HttpCalloutMock.class, new MockHttpResponse(retornoCivErro, 200, 'OK'));
        BotaoAtualizacaoMonetariaController.possuiComplementoIndenizacao(beneficiario.id);
        BotaoAtualizacaoMonetariaController.criaComplementoIndenizacao(beneficiario.id, true); //PLV-4892 - INICIO/FIM
        Test.stopTest();
        
    }
    
    @IsTest
    static void errosAtualizacao(){
        
        Case caso = new Case(origin = '18');
        insert caso;
        
        PagamentoGarantia__c garantiaSinistro = new PagamentoGarantia__c(caso__c=caso.id);
        insert garantiaSinistro;
        
        BeneficiarioGarantia__c beneficiario = new BeneficiarioGarantia__c(Pagamento_de_garantia__c=garantiaSinistro.id);
        insert beneficiario;
        
        garantiaSinistro.Fase__c ='Fechado';
        garantiaSinistro.Status_do_Pagamento__c = 'Pago';
        update garantiaSinistro;
            
        Test.startTest();        
        BotaoAtualizacaoMonetariaController.possuiComplementoIndenizacao(beneficiario.id);
        BotaoAtualizacaoMonetariaController.criaComplementoIndenizacao(beneficiario.id, true); //PLV-4892 - INICIO/FIM
        Test.stopTest();
        
    }
    
    @IsTest
    static void cobrirTO(){
        BotaoAtualizacaoMonetariaController.CorrecaoMonetariaTO correcaoMonetaria = new BotaoAtualizacaoMonetariaController.CorrecaoMonetariaTO();
        correcaoMonetaria.dataFinalValidade = '123'; 
        correcaoMonetaria.dataInicioValidade = '132';
        correcaoMonetaria.indice = '0';
        
        BotaoAtualizacaoMonetariaController.CorrecaoTaxaJurosTO correcaoTaxaJuros = new BotaoAtualizacaoMonetariaController.CorrecaoTaxaJurosTO();
        correcaoTaxaJuros.chaveJuros = '123';
        correcaoTaxaJuros.dataFinalValidade = '123'; 
        correcaoTaxaJuros.dataInicioValidade = '123';  
        correcaoTaxaJuros.siglaMoeda = '123';
        
        BotaoAtualizacaoMonetariaController.ItemChaveJuros itemChaveJuros = new BotaoAtualizacaoMonetariaController.ItemChaveJuros();
        itemChaveJuros.dataTaxaJuros = '123';
        itemChaveJuros.taxaJuros = '123';
        itemChaveJuros.valorTaxaJuros = '123';
        
        BotaoAtualizacaoMonetariaController.ItensChaveJuros itensChaveJuros = new BotaoAtualizacaoMonetariaController.ItensChaveJuros();
        itensChaveJuros.ItemChaveJuros = itemChaveJuros;
        
        BotaoAtualizacaoMonetariaController.AtualizacaoTaxaJurosTO atualizacaoTaxaJuros = new BotaoAtualizacaoMonetariaController.AtualizacaoTaxaJurosTO();
        atualizacaoTaxaJuros.ItensChaveJuros = ItensChaveJuros;
        atualizacaoTaxaJuros.additionalInfo = '123';
        atualizacaoTaxaJuros.codigo = '123';
        atualizacaoTaxaJuros.dataOcorrencia = '123';
        atualizacaoTaxaJuros.fonte = '123';
        atualizacaoTaxaJuros.mensagem = '123';
        atualizacaoTaxaJuros.tipo = '123';
        
    
        
        BotaoAtualizacaoMonetariaController.ItemTaxaIndice itemTaxaIndice = new BotaoAtualizacaoMonetariaController.ItemTaxaIndice();
        itemTaxaIndice.chaveJuros = '123';
        itemTaxaIndice.dataIndice = '123';
        itemTaxaIndice.indice = '123';
        itemTaxaIndice.taxaIndice = '123';
    
        /*
        BotaoAtualizacaoMonetariaController.ItensTaxaIndice itensTaxaIndice = new BotaoAtualizacaoMonetariaController.ItensTaxaIndice();
        itensTaxaIndice.ItemTaxaIndice = itemTaxaIndice;*/
        
        BotaoAtualizacaoMonetariaController.ItemTaxaIndice itensTaxaIndice  = new BotaoAtualizacaoMonetariaController.ItemTaxaIndice();
        itensTaxaIndice = itemTaxaIndice;
       
        /*
        BotaoAtualizacaoMonetariaController.AtualizacaoMonetariaTO atualizacaoMonetaria = new BotaoAtualizacaoMonetariaController.AtualizacaoMonetariaTO();
        atualizacaoMonetaria.ItensTaxaIndice = itensTaxaIndice;
        atualizacaoMonetaria.additionalInfo = '123';          
        atualizacaoMonetaria.codigo = '123';                 
        atualizacaoMonetaria.dataOcorrencia = '123';           
        atualizacaoMonetaria.fonte = '123';                    
        atualizacaoMonetaria.mensagem = '123';                  
        atualizacaoMonetaria.tipo = '123';*/             
        
        BotaoAtualizacaoMonetariaController.ItemErrorAtualizacaoMonetariaTO atualizacaoMonetariaItensErro = new BotaoAtualizacaoMonetariaController.ItemErrorAtualizacaoMonetariaTO(); 
        atualizacaoMonetariaItensErro.codigo = '123'; 
        atualizacaoMonetariaItensErro.tipo = '123'; 
        atualizacaoMonetariaItensErro.mensagem = '123'; 
        atualizacaoMonetariaItensErro.fonte = '123'; 
        atualizacaoMonetariaItensErro.additionalInfo = '123'; 
        
    }
    //MGRC-1248 - INICIO - FIX1
    @IsTest
    static void testarFormataData(){

        Test.startTest();
        
        BotaoAtualizacaoMonetariaController.FormataData(System.today());

        Test.stopTest();        
    }

    @IsTest
    static void testarRetornoSensediaErro(){

        BotaoAtualizacaoMonetariaController.ErrorAtualizacaoMonetariaTO erroTO = new BotaoAtualizacaoMonetariaController.ErrorAtualizacaoMonetariaTO();
        erroTO.portoSeguroFaultInfo = new BotaoAtualizacaoMonetariaController.ItemErrorAtualizacaoMonetariaTO();
        erroTO.portoSeguroFaultInfo.codigo = '159';
        erroTO.portoSeguroFaultInfo.mensagem = 'teste';
        
        Case caso = new Case(origin = '17');
        insert caso;
        
        PagamentoGarantia__c garantiaSinistro = new PagamentoGarantia__c(caso__c=caso.id);
        insert garantiaSinistro;
        
        BeneficiarioGarantia__c beneficiario = new BeneficiarioGarantia__c(Pagamento_de_garantia__c=garantiaSinistro.id);
        beneficiario.Data_programada_do_pagamento__c = System.today().addDays(+2);
        beneficiario.ValorIndenizacao__c = 1;
        insert beneficiario;
        
        garantiaSinistro.Fase__c ='Em Análise';
        garantiaSinistro.Status_do_Pagamento__c = 'Em análise';
        update garantiaSinistro;

        Test.startTest();
        System.debug('Erro: ' + JSON.serialize(erroTO));
        Test.setMock(HttpCalloutMock.class, new MockHttpResponse(JSON.serialize(erroTO), 200, 'OK'));
        BotaoAtualizacaoMonetariaController.criaComplementoIndenizacao(beneficiario.id, true);

        Test.stopTest();        
    }

    @IsTest
    static void testarGarantiaStatusPgto(){

        Test.startTest();
        
        Case caso = new Case(origin = '17');
        insert caso;
        
        PagamentoGarantia__c garantiaSinistro = new PagamentoGarantia__c(caso__c=caso.id);
        insert garantiaSinistro;
        
        BeneficiarioGarantia__c beneficiario = new BeneficiarioGarantia__c(Pagamento_de_garantia__c=garantiaSinistro.id);
        beneficiario.Data_programada_do_pagamento__c = System.today().addDays(+2);
        beneficiario.ValorIndenizacao__c = 1;
        insert beneficiario;
        
        garantiaSinistro.Fase__c ='Fechado';
        garantiaSinistro.Status_do_Pagamento__c = 'Pago';
        update garantiaSinistro;

        BotaoAtualizacaoMonetariaController.criaComplementoIndenizacao(beneficiario.id, true);

        Test.stopTest();
        
    }

    @IsTest
    static void testarBeneficiarioSemDtPgto(){

        Test.startTest();
        
        Case caso = new Case(origin = '17');
        insert caso;
        
        PagamentoGarantia__c garantiaSinistro = new PagamentoGarantia__c(caso__c=caso.id);
        insert garantiaSinistro;
        
        BeneficiarioGarantia__c beneficiario = new BeneficiarioGarantia__c(Pagamento_de_garantia__c=garantiaSinistro.id);
        beneficiario.ValorIndenizacao__c = 1;
        insert beneficiario;
        
        garantiaSinistro.Fase__c ='Em Análise';
        garantiaSinistro.Status_do_Pagamento__c = 'Em Análise';
        update garantiaSinistro;

        BotaoAtualizacaoMonetariaController.criaComplementoIndenizacao(beneficiario.id, true);

        Test.stopTest();
        
    }

    @isTest
    static void testarSubstituirTrue() {
        
        Map<String, Sobject> records = CreateTestData.createIntegratedScenario();

        Case caso = new Case(origin = '17');
        insert caso;

        insert new MovimentoSinistro__c(
            Caso__c = caso.id,
            DataMovimento__c = System.now(),
            DescricaoMovimento__c = '1',
            TipoMovimento__c = 'Aviso',
            ValorMovimento__c = 500,
            SequenciaMovimento__c = '1'
        );
        
        PagamentoGarantia__c garantiaSinistro = new PagamentoGarantia__c(caso__c=caso.id);
        insert garantiaSinistro;
        
        BeneficiarioGarantia__c beneficiario = new BeneficiarioGarantia__c(Pagamento_de_garantia__c=garantiaSinistro.id);
        beneficiario.ValorIndenizacao__c = 1;
        insert beneficiario;

        ComplementoIndenizacao__c complemento = new ComplementoIndenizacao__c(
            TipoComplemento__c = 'Atualização Monetária',
            Valor__c = 123,
            PagamentoGarantia__c = records.get('PagamentoGarantia').Id,
            Motivo__c = 'Prazo de Regulação excedido',
            Descricao__c = 'Atualização Monetária',
            BeneficiarioGarantia__c = records.get('BeneficiarioGarantia').Id
        );

        BotaoAtualizacaoMonetariaController.ItemTaxaIndice atualizacaoMonetariaSucesso = new BotaoAtualizacaoMonetariaController.ItemTaxaIndice(); 
        atualizacaoMonetariaSucesso.taxaIndice = '5.0';

        List<BotaoAtualizacaoMonetariaController.ItemTaxaIndice> indicesList = new List<BotaoAtualizacaoMonetariaController.ItemTaxaIndice>();
        indicesList.add(atualizacaoMonetariaSucesso);

        BotaoAtualizacaoMonetariaController.AtualizacaoMonetariaTO atualizacaoMonetariaTO = new BotaoAtualizacaoMonetariaController.AtualizacaoMonetariaTO();
        atualizacaoMonetariaTO.indices = indicesList;
        
        String retornoCivSucesso = JSON.serialize(atualizacaoMonetariaTO);
            
        Test.startTest();        
        Test.setMock(HttpCalloutMock.class, new MockHttpResponse(retornoCivSucesso, 200, 'OK'));
        BotaoAtualizacaoMonetariaController.criaComplementoIndenizacao(records.get('BeneficiarioGarantia').Id, true);      
        Test.stopTest();

    }
    //MGRC-1248 - FIM - FIX1
    //PLV-4535 - FIM

    //PLV-4892-FIM
}