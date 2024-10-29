//II-166 - INICIO
@isTest
private class AltFormPgtoBOTest {

    @TestSetup
    static void makeData(){

        ContadorCodigo__c contCodigoTec = (ContadorCodigo__c) new ContadorCodigoFactory.ProdutoTecnico().createRecord();

        Product2 produtoTec = TestDataFactory.gerarProdutoTecnico();
        produtoTec.Status__c = 'Ativo';
        update produtoTec;

        FormaPagamento__c formaPagamento = new FormaPagamento__c(
            Codigo__c = '41',
            Name = 'X'
        );

        insert formaPagamento;

        CondicaoCobranca__c cc = new CondicaoCobranca__c();
		cc.Produto__c = produtoTec.Id;
		cc.FormaPagamento__c = formaPagamento.Id;
		cc.QuantidadeParcelas__c = '1;2;3;4';
		insert cc;
    }

    @isTest
    static void montarParcelasSemAgencTest() {
        
        CondicaoCobranca__c cc1 = getCondicaoCobranca();
        CondicaoCobranca__c cc2 = getCondicaoCobranca();
        CondicaoCobranca__c cc3 = getCondicaoCobranca();
        CondicaoCobranca__c cc4 = getCondicaoCobranca();
        CondicaoCobranca__c cc5 = getCondicaoCobranca();
        CondicaoCobranca__c cc6 = getCondicaoCobranca();

        AltFormPgtoBO bo = new AltFormPgtoBO();

        Test.startTest();

        FormaPagamento__c formPgto = [SELECT Id, Codigo__c FROM FormaPagamento__c LIMIT 1];

        formPgto.Codigo__c = '52';
        cc1.FormaPagamento__r = formPgto;
        cc1.QuantidadeParcelas__c = '1;2;3;4';
        update cc1;       
        
        CondicaoCobranca__c condCob = bo.montarParcelas(cc1, 0);

        Assert.areEqual('1;2;3;4;5;6;7;8;9;10;11;12', condCob.QuantidadeParcelas__c);

        formPgto.Codigo__c = '41';
        update formPgto;

        cc2.FormaPagamento__r = formPgto;
        cc2.QuantidadeParcelas__c = '5;6;7;8;9;10;11;12';    
        update cc2;      

        condCob = bo.montarParcelas(cc2, 0);

        Assert.areEqual('1;2;3;4;5;6;7;8;9;10;11;12', condCob.QuantidadeParcelas__c);

        formPgto.Codigo__c = '62';
        update formPgto;

        cc3.FormaPagamento__r = formPgto;
        cc3.QuantidadeParcelas__c = '1;2;3;4';    
        update cc3;       

        condCob = bo.montarParcelas(cc3, 0);

        Assert.areEqual('1;2;3;4;5;6;7;8;9;10;11', condCob.QuantidadeParcelas__c);

        formPgto.Codigo__c = '97';
        update formPgto;

        cc4.FormaPagamento__r = formPgto;
        cc4.QuantidadeParcelas__c = '1;2;3;4';    
        update cc4;        

        condCob = bo.montarParcelas(cc4, 0);

        Assert.areEqual('1;2;3;4;5;6;7;8;9;10;11', condCob.QuantidadeParcelas__c);

        formPgto.Codigo__c = '70';
        update formPgto;

        cc5.FormaPagamento__r = formPgto;
        cc5.QuantidadeParcelas__c = '1;2;3;4';    
        update cc5;        

        condCob = bo.montarParcelas(cc5, 0);

        Assert.areEqual('1;2;3;4;5;6;7;8;9;10;11', condCob.QuantidadeParcelas__c);

        formPgto.Codigo__c = '98';
        update formPgto;

        cc6.FormaPagamento__r = formPgto;
        cc6.QuantidadeParcelas__c = '5;6;7;8;9;10;11';    
        update cc6;        

        condCob = bo.montarParcelas(cc6, 0);

        Assert.areEqual('1;2;3;4;5;6;7;8;9;10;11', condCob.QuantidadeParcelas__c);

        Test.stopTest();

    }

    @isTest
    static void montarParcelasComAgencTest() {
        
        CondicaoCobranca__c cc1 = getCondicaoCobranca();
        CondicaoCobranca__c cc2 = getCondicaoCobranca();
        CondicaoCobranca__c cc3 = getCondicaoCobranca();
        CondicaoCobranca__c cc4 = getCondicaoCobranca();
        CondicaoCobranca__c cc5 = getCondicaoCobranca();
        CondicaoCobranca__c cc6 = getCondicaoCobranca();

        AltFormPgtoBO bo = new AltFormPgtoBO();

        Test.startTest();

        FormaPagamento__c formPgto = [SELECT Id, Codigo__c FROM FormaPagamento__c LIMIT 1];

        formPgto.Codigo__c = '52';
        cc1.FormaPagamento__r = formPgto;
        cc2.QuantidadeParcelas__c = '1;2;3;4';
        update cc1;       
        
        CondicaoCobranca__c condCob = bo.montarParcelas(cc1, 1);

        Assert.areEqual('12', condCob.QuantidadeParcelas__c);

        formPgto.Codigo__c = '41';
        update formPgto;

        cc2.FormaPagamento__r = formPgto;
        cc2.QuantidadeParcelas__c = '5;6;7;8;9;10;11;12';    
        update cc2;      

        condCob = bo.montarParcelas(cc2, 1);

        Assert.areEqual('12', condCob.QuantidadeParcelas__c);

        formPgto.Codigo__c = '62';
        update formPgto;

        cc3.FormaPagamento__r = formPgto;
        cc3.QuantidadeParcelas__c = '1;2;3;4';    
        update cc3;       

        condCob = bo.montarParcelas(cc3, 1);

        Assert.areEqual('11', condCob.QuantidadeParcelas__c);

        formPgto.Codigo__c = '97';
        update formPgto;

        cc4.FormaPagamento__r = formPgto;
        cc4.QuantidadeParcelas__c = '1;2;3;4';    
        update cc4;        

        condCob = bo.montarParcelas(cc4, 1);

        Assert.areEqual('11', condCob.QuantidadeParcelas__c);

        formPgto.Codigo__c = '70';
        update formPgto;

        cc5.FormaPagamento__r = formPgto;
        cc5.QuantidadeParcelas__c = '1;2;3;4';    
        update cc5;        

        condCob = bo.montarParcelas(cc5, 1);

        Assert.areEqual('11', condCob.QuantidadeParcelas__c);

        formPgto.Codigo__c = '98';
        update formPgto;

        cc6.FormaPagamento__r = formPgto;
        cc6.QuantidadeParcelas__c = '5;6;7;8;9;10;11';    
        update cc6;        

        condCob = bo.montarParcelas(cc6, 1);

        Assert.areEqual('11', condCob.QuantidadeParcelas__c);

        Test.stopTest();
    }

    private static CondicaoCobranca__c getCondicaoCobranca(){
        return [
            SELECT
                Id,
                NomeFormaPagamento__c,
                QuantidadeParcelas__c
            FROM
                CondicaoCobranca__c
        ];
    }

    //II-172 - INICIO
    @IsTest
    static void getEnderecosTest(){

        AltFormPgtoBO bo = new AltFormPgtoBO();
        List<AltFormPgtoTO.EnderecoTO> enderecos = new List<AltFormPgtoTO.EnderecoTO>();

        String retorno = JSON.serialize(mockLogradouros());
        
        enderecos = bo.getEnderecos('12345', '678', retorno);

        Assert.areEqual(true, enderecos.size() > 0);
    }

    private static F5Service.ObjLogradouros mockLogradouros() {
        F5Service.ObjLogradouros response = new F5Service.ObjLogradouros();
        response.logradouros = new List<F5Service.Logradouros>();
    
        F5Service.Logradouros logradouro1 = new F5Service.Logradouros();
        logradouro1.nomeLogradouro = 'Rua A';
        logradouro1.bairro = new F5Service.Bairro();
        logradouro1.bairro.nomeBairro = 'Bairro A';
        logradouro1.localidade = new F5Service.Localidade();
        logradouro1.localidade.nomeLocalidade = 'Cidade A';
        logradouro1.localidade.estado = new F5Service.Estado();
        logradouro1.localidade.estado.nomeEstado = 'Estado A';
        logradouro1.localidade.estado.siglaEstado = 'EA';
    
        F5Service.Logradouros logradouro2 = new F5Service.Logradouros();
        logradouro2.nomeLogradouro = 'Rua B';
        logradouro2.bairro = new F5Service.Bairro();
        logradouro2.bairro.nomeBairro = 'Bairro B';
        logradouro2.localidade = new F5Service.Localidade();
        logradouro2.localidade.nomeLocalidade = 'Cidade B';
        logradouro2.localidade.estado = new F5Service.Estado();
        logradouro2.localidade.estado.nomeEstado = 'Estado B';
        logradouro2.localidade.estado.siglaEstado = 'EB';
    
        response.logradouros.add(logradouro1);
        response.logradouros.add(logradouro2);

        return response;
    }
    //II-172 - FIM
}
//II-166 - FIM