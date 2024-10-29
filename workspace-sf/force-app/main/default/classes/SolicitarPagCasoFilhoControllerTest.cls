@isTest
public class SolicitarPagCasoFilhoControllerTest {
    
    @isTest
    static void validarVerificafase(){
  
        //Criando Garantia
            Garantia__c garantia = (Garantia__c) new GarantiaFactory().createRecord();
        
        //Criando Conta Pessoal
            Account contaPessoal = (Account) new AccountFactory.PessoaFisica().createRecord();
      
        //Criando Caso Atendimento Sinistro
            Case casoAtendimento = (Case) new CasoFactory.AtendimentoSinistro().createRecord();

        //Criando contato
            Contact contato = (Contact) new ContactFactory().createRecord();

        //Criando Contador Codigo Produto Tecnico e Comercial
            ContadorCodigo__c contCodigoTec = (ContadorCodigo__c) new ContadorCodigoFactory.ProdutoTecnico().createRecord();
            ContadorCodigo__c contCodigoCom = (ContadorCodigo__c) new ContadorCodigoFactory.ProdutoComercial().createRecord();

        //Criando Forma de Pagamento
             FormaPagamento__c formaPagamento = (FormaPagamento__c) new FormaPagamentoFactory().createRecord();
        //Criando Parceiro e atualizando contrato
            Parceiro__c parceiro = (Parceiro__c) new ParceiroFactory(contaPessoal, formaPagamento).createRecord();
            
        //Criando Produto Tecnico
            Product2 produtoTecnico = (Product2) new ProdutoFactory.ProdutoTecnico().createRecord();
            produtoTecnico.Status__c = 'Em ativação';
            produtoTecnico.NumeroSusep__c = '123';
            produtoTecnico.VersaoRenovacao__c = 'Versão atual';
            update produtoTecnico;
            produtoTecnico.Status__c = 'Ativo';
            update produtoTecnico;
            
        //Criando Produto Comercial
            Product2 produtoComercial = (Product2) new ProdutoFactory.ProdutoComercial(produtoTecnico).createRecord();

        //Criando Contrato
            Contract contrato = (Contract) new ContratoFactory.ContratoFactoryComParam(contaPessoal, produtoComercial, parceiro).createRecord();

        //Criando Contratante
            ContratanteContrato__c contratante = (ContratanteContrato__c) new ContratanteFactory(contrato).createRecord();
        
        //Criando Grupo
            GrupoContrato__c grupo = (GrupoContrato__c) new GrupoFactory(contratante).createRecord();
        
        //Criando Segurado do Contrato
            SeguradoContrato__c segurado = (SeguradoContrato__c) new SeguradoContratoFactory(contaPessoal, grupo).createRecord();
        
        //Criando Garantia do Segurado do Contrato
            GarantiaSeguradoContrato__c garantiaSegurado = (GarantiaSeguradoContrato__c) new GarantiaSeguradoContratoFactory(segurado, garantia).createRecord();
        	//PLV-4559 - INICIO	
            garantiaSegurado.Tipo_de_limite_de_utilizacao__c = 'Dia(s)'; //PLV-5747 INICIO/FIM
            garantiaSegurado.Limite_de_Uso__c = 100;
            update garantiaSegurado;
        	//PLV-4559 -FIM
        //Criando Caso Sinistro
            Case casoSinistro = (Case) new CasoFactory.Sinistro(casoAtendimento, contaPessoal).createRecord();

        //Atualizando o status do caso para 'Avisado'
            casoSinistro.ContactId = contato.id;
            casoSinistro.Contrato__c = contrato.id;
            casoSinistro.Garantia_do_segurado_do_contrato__c = garantiaSegurado.id;
            casoSinistro.NumeroSinistro__c = '321';
            casoSinistro.Data_sinistro_avisado__c = System.today();
            casoSinistro.Status = 'Avisado';
            casoSinistro.Status_Dependente__c = 'Com Pendências';
            casoSinistro.Segurado_do_Contrato__c = segurado.id;
            //PLV-2433 - Inicio - Campo criado para reparar a classe de teste
            casoSinistro.ProcessaNumeroSinistro__c = true;
            //PLV-2433 - Fim
            update casoSinistro;

        
        //Criando Pagamento de Garantia
            PagamentoGarantia__c pag = (PagamentoGarantia__c) new PagamentoGarantiaFactory(casoSinistro, garantiaSegurado).createRecord();
            pag.Fase__c = 'Em Análise';
            pag.Status_do_pagamento__c = 'Em Análise';        	
            update pag;

        //Criando Informação Bancária
            InformacaoBancaria__c infoBan = (InformacaoBancaria__c) new InformacaoBancariaFactory.InfoPessoaFisica(contaPessoal).createRecord();
            
        //Criando Beneficiario da Garantia
            BeneficiarioGarantia__c bene2 = new BeneficiarioGarantia__c();
            bene2.Pagamento_de_garantia__c = pag.Id;
            bene2.Conta__c = contaPessoal.id;
            bene2.Status__c = 'Pendente';
            bene2.Tipo_de_Pagamento__c = 'Cheque';
            //PLV-2403 - Inicio - Inserção de campos para cobertura da classe de teste.
            //bene2.InformarIndenizacao__c = '% de Indenização'; //PLV-4070 - INICIO/FIM
            bene2.InformarIndenizacao__c = 'Valor de Indenização'; //PLV-4070 - INICIO/FIM
            //bene2.Percentual_de_indenizacao__c = 20.000;
            bene2.ValorIndenizacao__c = 20.00; //PLV-4070 - INICIO/FIM
            //PLV-2403 - Fim - Inserção de campos para cobertura da classe de teste.
            bene2.Sucursal_Destino_de_Cheque__c = 10;
        	bene2.Data_programada_do_pagamento__c = system.today() + 2;
        	bene2.StatusSerasa__c = 'Atualizado';
            insert bene2;
            
            String resVerificaFase1 = SolicitarPagamentoCasoFilhoController.verificafase(pag.Id);

            BeneficiarioGarantia__c bene1 = (BeneficiarioGarantia__c) new BeneficiarioGarantiaFactory.BenePessoaFisica(contaPessoal, infoBan, pag).createRecord();
            
            casoSinistro.Sinistro_Judicial__c = true;
            update casoSinistro;

        	bene1.Status__c = 'Liberado';
            bene1.Tipo_de_Pagamento__c = 'Transferencia Bancaria para Conta Poupanca';
            bene1.Data_programada_do_pagamento__c = null;
            bene1.StatusSerasa__c = 'Atualizado';
            bene1.Percentual_de_indenizacao__c = 1.00; //PLV-4428 - INICIO/FIM
            update bene1;
        
            //Nome da Classe irá ser trocado
            String resVerificaFase = SolicitarPagamentoCasoFilhoController.verificafase(pag.Id);
            List<PagamentoGarantia__c> lstPag = SolicitarPagamentoCasoFilhoController.consultainfo(pag.Id);
            
            Decimal valorPagamento = 10000;

            String mock = '[{"idconta": "0011F000009D3eOQAS", "cnpjcpf": null, "tipoconta": null,'+
        '"valorpagamento": "2000.00000", "status": "PENDENTE", "datapagamento": "2019-01-24T00:00:00.000Z",'+
        '"dataprogramadapagamento": "2019-01-25T00:00:00.000Z","tipopagamento": "SINISTRO",'+
        '"idobjeto": "5003F000004yoRmQAI","matricula": null,"codigoexcecao": null,"descricaoexcecao": null,'+
        '"valorbruto": null,"tributacao": null,"tiporemuneracao": null,"datacancelamento": null,'+
        '"motivo": "pagou atrasado","descricao": null,"susepcorretor": null,'+
        '"dataatualizacao": "2019-01-31T00:00:00.000Z"}]';

            Test.setMock(HttpCalloutMock.class, new MockHttpResponse(JSON.serialize(mock), 200, 'OK'));

            Test.startTest();
            String resGravapagamento = SolicitarPagamentoCasoFilhoController.gravapagamento(pag.Id, valorPagamento);
            Test.stopTest();



            String resAtualizaregistro = SolicitarPagamentoCasoFilhoController.atualizaregistro(pag.Id, valorPagamento);
        	SolicitarPagamentoCasoFilhoController.salvadataBenef(pag.Id, bene2.Id);
    }
    
    @isTest
    static void validarVerificafase2(){
        //Criando Garantia
            Garantia__c garantia = (Garantia__c) new GarantiaFactory().createRecord();
        
        //Criando Conta Pessoal
            Account contaPessoal = (Account) new AccountFactory.PessoaFisica().createRecord();
      
        //Criando Caso Atendimento Sinistro
            Case casoAtendimento = (Case) new CasoFactory.AtendimentoSinistro().createRecord();

        //Criando contato
            Contact contato = (Contact) new ContactFactory().createRecord();

        //Criando Contador Codigo Produto Tecnico e Comercial
            ContadorCodigo__c contCodigoTec = (ContadorCodigo__c) new ContadorCodigoFactory.ProdutoTecnico().createRecord();
            ContadorCodigo__c contCodigoCom = (ContadorCodigo__c) new ContadorCodigoFactory.ProdutoComercial().createRecord();

        //Criando Forma de Pagamento
             FormaPagamento__c formaPagamento = (FormaPagamento__c) new FormaPagamentoFactory().createRecord();
        //Criando Parceiro e atualizando contrato
            Parceiro__c parceiro = (Parceiro__c) new ParceiroFactory(contaPessoal, formaPagamento).createRecord();
            
        //Criando Produto Tecnico
            Product2 produtoTecnico = (Product2) new ProdutoFactory.ProdutoTecnico().createRecord();
            produtoTecnico.Status__c = 'Em ativação';
            produtoTecnico.NumeroSusep__c = '123';
            produtoTecnico.VersaoRenovacao__c = 'Versão atual';
            update produtoTecnico;
            produtoTecnico.Status__c = 'Ativo';
            update produtoTecnico;
            
        //Criando Produto Comercial
            Product2 produtoComercial = (Product2) new ProdutoFactory.ProdutoComercial(produtoTecnico).createRecord();

        //Criando Contrato
            Contract contrato = (Contract) new ContratoFactory.ContratoFactoryComParam(contaPessoal, produtoComercial, parceiro).createRecord();

        //Criando Contratante
            ContratanteContrato__c contratante = (ContratanteContrato__c) new ContratanteFactory(contrato).createRecord();
        
        //Criando Grupo
            GrupoContrato__c grupo = (GrupoContrato__c) new GrupoFactory(contratante).createRecord();
        
        //Criando Segurado do Contrato
            SeguradoContrato__c segurado = (SeguradoContrato__c) new SeguradoContratoFactory(contaPessoal, grupo).createRecord();
        
        //Criando Garantia do Segurado do Contrato
            GarantiaSeguradoContrato__c garantiaSegurado = (GarantiaSeguradoContrato__c) new GarantiaSeguradoContratoFactory(segurado, garantia).createRecord();    		
        	//PLV-4559 - INICIO
            garantiaSegurado.Tipo_de_limite_de_utilizacao__c = 'Dia(s)'; //PLV-5747 INICIO/FIM
            garantiaSegurado.Limite_de_Uso__c = 900;
            update garantiaSegurado;
        	//PLV-4559 -FIM
        //Criando Caso Sinistro
            Case casoSinistro = (Case) new CasoFactory.Sinistro(casoAtendimento, contaPessoal).createRecord();

        //Atualizando o status do caso para 'Avisado'
            casoSinistro.ContactId = contato.id;
            casoSinistro.Contrato__c = contrato.id;
            casoSinistro.Garantia_do_segurado_do_contrato__c = garantiaSegurado.id;
            casoSinistro.NumeroSinistro__c = '321';
            casoSinistro.Data_sinistro_avisado__c = System.today();
            casoSinistro.Status = 'Avisado';
            casoSinistro.Status_Dependente__c = 'Com Pendências';
            casoSinistro.Segurado_do_Contrato__c = segurado.id;
            //PLV-2433 - Inicio - Campo criado para reparar a classe de teste
            casoSinistro.ProcessaNumeroSinistro__c = true;
            //PLV-2433 - Inicio - Campo criado para reparar a classe de teste
            update casoSinistro;

        
        //Criando Pagamento de Garantia
            PagamentoGarantia__c pag = (PagamentoGarantia__c) new PagamentoGarantiaFactory(casoSinistro, garantiaSegurado).createRecord();
            pag.Fase__c = 'Em Análise';
            pag.Status_do_pagamento__c = 'Em Análise';        	
            update pag;

            Decimal valorPagamento = 10000;

            String mock = '[{"idconta": "0011F000009D3eOQAS", "cnpjcpf": null, "tipoconta": null,'+
        '"valorpagamento": "2000.00000", "status": "PENDENTE", "datapagamento": "2019-01-24T00:00:00.000Z",'+
        '"dataprogramadapagamento": "2019-01-25T00:00:00.000Z","tipopagamento": "SINISTRO",'+
        '"idobjeto": "5003F000004yoRmQAI","matricula": null,"codigoexcecao": null,"descricaoexcecao": null,'+
        '"valorbruto": null,"tributacao": null,"tiporemuneracao": null,"datacancelamento": null,'+
        '"motivo": "pagou atrasado","descricao": null,"susepcorretor": null,'+
        '"dataatualizacao": "2019-01-31T00:00:00.000Z"}]';

            Test.setMock(HttpCalloutMock.class, new MockHttpResponse(JSON.serialize(mock), 400, 'OK'));

            Test.startTest();
            String resGravapagamento = SolicitarPagamentoCasoFilhoController.gravapagamento(pag.Id, valorPagamento);
            Test.stopTest();

    }

}