/*********************************************************************************************************************************************************************


@description  Classe de teste.
@author Renan Martins e Alexandre Ferreira - Avanxo
@date 26/09/2019
@Classe criada por conta da história PLV-2681
        
**********************************************************************************************************************************************************************/


@isTest
public class ValidaFavorecidosTest {
        
    @isTest
    public static void validaFavorecidos(){
        Account contaPessoal = (Account) new AccountFactory.PessoaFisica().createRecord();
        contaPessoal.Cpf__c = '427.709.828-26';
        contaPessoal.Pis__c = '123456789'; // PLV-4445
        contaPessoal.Cnpj__c = '61.038.592/0001-25';
        contaPessoal.Inscricao_Municipal__c = '123456789'; // PLV-4445
        update contaPessoal;
        DadosCorretor__c dadosCorretor = (DadosCorretor__c) new DadosCorretorFactory(contaPessoal).createRecord();
        dadosCorretor.Name = 'P5005J';
        update dadosCorretor;

        
        
        
        StaticResource staticResource = [SELECT Id, Body FROM StaticResource WHERE Name = 'PayloadPropostaValidaFavorecido' LIMIT 1];
        String payload = staticResource.Body.toString();
        EmissaoTO.PayloadTO payloadTO = (EmissaoTO.PayloadTO) JSON.deserialize(payload, EmissaoTO.PayloadTO.class);
      
        ValidaFavorecidos.validarExistenciaOrcamento(payloadTO);
    }    
    @isTest
    public static void validaFavorecidosNaoEncontrado(){
        Account contaPessoal = (Account) new AccountFactory.PessoaFisica().createRecord();
        DadosCorretor__c dadosCorretor = (DadosCorretor__c) new DadosCorretorFactory(contaPessoal).createRecord();
        dadosCorretor.Name = 'naoencontrado';
        update dadosCorretor;
        
        ContadorCodigo__c contCodigoTec = (ContadorCodigo__c) new ContadorCodigoFactory.ProdutoTecnico().createRecord();
        ContadorCodigo__c contCodigoCom = (ContadorCodigo__c) new ContadorCodigoFactory.ProdutoComercial().createRecord();
        Product2 produtoTecnico = (Product2) new ProdutoFactory.ProdutoTecnico().createRecord();
        produtoTecnico.Status__c = 'Em ativação';
        produtoTecnico.NumeroSusep__c = 'P5005J';
        produtoTecnico.VersaoRenovacao__c = 'Versão atual';
        update produtoTecnico;
        produtoTecnico.Status__c = 'Ativo';
        update produtoTecnico;
        Product2 produtoComercial = (Product2) new ProdutoFactory.ProdutoComercial(produtoTecnico).createRecord();
        
        Opportunity orcamento = (Opportunity) new OrcamentoFactory.VidaIndividual(produtoComercial, contaPessoal).createRecord();
        orcamento.CodigoCorretor__c = dadosCorretor.Id;
        update orcamento;


        StaticResource staticResource = [SELECT Id, Body FROM StaticResource WHERE Name = 'PayloadPropostaValidaFavorecido' LIMIT 1];
        String payload = staticResource.Body.toString();
        EmissaoTO.PayloadTO payloadTO = (EmissaoTO.PayloadTO) JSON.deserialize(payload, EmissaoTO.PayloadTO.class);
        ValidaFavorecidos.validarExistenciaOrcamento(payloadTO);
    }
        
    @isTest
    public static void validaFavorecidosSusepDuplicada(){
        Account contaPessoal = (Account) new AccountFactory.PessoaFisica().createRecord();
        DadosCorretor__c dadosCorretor = (DadosCorretor__c) new DadosCorretorFactory(contaPessoal).createRecord();
        dadosCorretor.Name = 'P5005J';
        dadosCorretor.Produtos_Bloqueados__c ='BRASIL-OURO;VI-PESSOASSSSS2;651561';
        update dadosCorretor;
        dadosCorretor.Id = null;
        insert dadosCorretor;
        
        StaticResource staticResource = [SELECT Id, Body FROM StaticResource WHERE Name = 'PayloadPropostaValidaFavorecidoSusepDuplicada' LIMIT 1];
        String payload = staticResource.Body.toString();
        EmissaoTO.PayloadTO payloadTO = (EmissaoTO.PayloadTO) JSON.deserialize(payload, EmissaoTO.PayloadTO.class);
        ValidaFavorecidos.validarExistenciaOrcamento(payloadTO);
    }        
    @isTest
    public static void validaFavorecidosDocumentoInvalido(){
        Account contaPessoal = (Account) new AccountFactory.PessoaFisica().createRecord();
        contaPessoal.Cpf__c = '427.709.828-26';
        contaPessoal.Pis__c = '123456789'; // PLV-4445
        contaPessoal.Cnpj__c = '61.038.592/0001-25';
        contaPessoal.Inscricao_Municipal__c = '123456789'; // PLV-4445
        update contaPessoal;
        DadosCorretor__c dadosCorretor = (DadosCorretor__c) new DadosCorretorFactory(contaPessoal).createRecord();
        dadosCorretor.Name = 'P5005J';
        update dadosCorretor;

        StaticResource staticResource = [SELECT Id, Body FROM StaticResource WHERE Name = 'PayloadPropostaValidaFavorecidoCNPJInvalido' LIMIT 1];
        String payload = staticResource.Body.toString();
        EmissaoTO.PayloadTO payloadTO = (EmissaoTO.PayloadTO) JSON.deserialize(payload, EmissaoTO.PayloadTO.class);
        ValidaFavorecidos.validarExistenciaOrcamento(payloadTO);

        StaticResource staticResource2 = [SELECT Id, Body FROM StaticResource WHERE Name = 'PayloadPropostaValidaFavorecidoCPFInvalido' LIMIT 1];
        String payload2 = staticResource2.Body.toString();
        EmissaoTO.PayloadTO payloadTO2 = (EmissaoTO.PayloadTO) JSON.deserialize(payload2, EmissaoTO.PayloadTO.class);
        ValidaFavorecidos.validarExistenciaOrcamento(payloadTO2);
    }        
    @isTest
    public static void validaFavorecidosDocumentoNaoEncontrado(){
        Account contaPessoal = (Account) new AccountFactory.PessoaFisica().createRecord();
        contaPessoal.Cpf__c = '151.635.800-78';
        contaPessoal.Pis__c = '123456789'; // PLV-4445
        contaPessoal.Cnpj__c = '61.038.592/0001-25';
        contaPessoal.Inscricao_Municipal__c = '123456789'; // PLV-4445
        update contaPessoal;
        DadosCorretor__c dadosCorretor = (DadosCorretor__c) new DadosCorretorFactory(contaPessoal).createRecord();
        dadosCorretor.Name = 'P5005J';
        update dadosCorretor;

        StaticResource staticResource = [SELECT Id, Body FROM StaticResource WHERE Name = 'PayloadPropostaValidaFavorecido' LIMIT 1];
        String payload = staticResource.Body.toString();
        EmissaoTO.PayloadTO payloadTO = (EmissaoTO.PayloadTO) JSON.deserialize(payload, EmissaoTO.PayloadTO.class);
        ValidaFavorecidos.validarExistenciaOrcamento(payloadTO);
        
        contaPessoal.Cpf__c = '427.709.828-26';
        contaPessoal.Pis__c = '123456789'; // PLV-4445
        contaPessoal.Cnpj__c = '20.427.632/0001-43';
        contaPessoal.Inscricao_Municipal__c = '123456789'; // PLV-4445
        update contaPessoal;

        StaticResource staticResource2 = [SELECT Id, Body FROM StaticResource WHERE Name = 'PayloadPropostaValidaFavorecido' LIMIT 1];
        String payload2 = staticResource2.Body.toString();
        EmissaoTO.PayloadTO payloadTO2 = (EmissaoTO.PayloadTO) JSON.deserialize(payload2, EmissaoTO.PayloadTO.class);
        ValidaFavorecidos.validarExistenciaOrcamento(payloadTO2);
    }
}