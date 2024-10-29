//PLV-3667 - inicio
@isTest
class AccountTest {
    
    @testSetup
    static void setup(){
        TestDataFactory.gerarDadosSetup();
        TestDataFactory.gerarContrato(true);
    }
    
    @isTest
    public static void testBuscarContaInfomacoesBancarias(){
        Account conta = [SELECT Id FROM Account Limit 1];
        
        test.startTest();
        AccountBO.getInstance().buscarContaInfomacoesBancarias(conta.Id);
        test.stopTest();
    }
    @isTest
    public static void testBuscarServicosPapel(){
        
        test.startTest();
        List<ServicoPapel__mdt> A  = AccountBO.getInstance().buscarServicosPapel();
        test.stopTest();
    }
    @isTest
    public static void testInserirAssociacaoPapeis(){
        Account conta = [SELECT Id FROM Account Limit 1];        
        List<InformacaoBancaria__c> lInfBancaria = [SELECT Id FROM InformacaoBancaria__c limit 2];
        test.startTest();
        AccountBO.getInstance().inserirAssociacaoPapeis(conta, lInfBancaria);
        
        test.stopTest();
    }
    @isTest
    public static void testexcluirAssociacaoPapel(){
        Account conta = [SELECT Id FROM Account Limit 1];        
        List<String> papel = new List<String>();
        papel.add('Corretor');
        papel.add('Prestador');
        papel.add('Parceiro');
        papel.add('Representante de Seguros');
        test.startTest();
        for(String a: papel){
            AccountBO.getInstance().excluirAssociacaoPapel(conta.Id, a);
        }
        test.stopTest();
        
    }
    
    @isTest
    public static void testGeraResponsavelPagamento(){
        
        EmissaoTO.ContratanteTO contratante = new EmissaoTO.ContratanteTO();
        EmissaoTO.DadosPagamentoTO dadosPagamento = new EmissaoTO.DadosPagamentoTO();
        EmissaoTO.PessoaTO pessoa = new EmissaoTO.PessoaTO();
        EmissaoTO.DadosPessoaFisicaTO dadosPessoaFisica = new EmissaoTO.DadosPessoaFisicaTO();
        
        EmissaoTO.SeguradoTO segurado = new EmissaoTO.SeguradoTO();
        
        
        pessoa.tipo = 'FIS';
        dadosPessoaFisica.tipoRelacionamentoPep = 'a';
        dadosPessoaFisica.pep = 'a';
        dadosPessoaFisica.cpfPep = '45030686878';
        dadosPessoaFisica.nomePessoaPep = 'Gustavo Pereira';
        dadosPessoaFisica.profissao = 'Desenvolvedor Salesforce';
        dadosPessoaFisica.numeroCpf = '450306868';
        dadosPessoaFisica.sexo = 'MASC';
        dadosPessoaFisica.dataNascimento = string.valueOf(system.today().addDays(-30));
        dadosPessoaFisica.estadoCivil = 'Solteiro';
        dadosPessoaFisica.digitoCpf = '78';
        dadosPessoaFisica.nacionalidade = 'BRA';
        pessoa.email = 'gustavo.silva@gmail.com';
        
        
        
        
        pessoa.dadosPessoaFisica = dadosPessoaFisica;
        dadosPagamento.responsavelPagamento = pessoa;
        contratante.dadosPagamento = dadosPagamento;
        contratante.pessoa = pessoa;
        segurado.dadosPagamento = dadosPagamento;
        segurado.pessoa = pessoa;
        
        test.startTest();
        
        AccountBO.getInstance().geraResponsavelPagamento(contratante, segurado);
        
        test.stopTest();
        
    }
    
    @isTest
    public static void testGerarParseConta(){
        
        Account conta = [SELECT Id FROM Account Limit 1];        
        
        
        EmissaoTO.ContratanteTO contratante = new EmissaoTO.ContratanteTO();
        EmissaoTO.DadosPagamentoTO dadosPagamento = new EmissaoTO.DadosPagamentoTO();
        EmissaoTO.PessoaTO pessoa = new EmissaoTO.PessoaTO();
        EmissaoTO.DadosPessoaFisicaTO dadosPessoaFisica = new EmissaoTO.DadosPessoaFisicaTO();
        
        EmissaoTO.SeguradoTO segurado = new EmissaoTO.SeguradoTO();
        
        
        pessoa.tipo = 'FIS';
        dadosPessoaFisica.tipoRelacionamentoPep = 'a';
        dadosPessoaFisica.pep = 'a';
        dadosPessoaFisica.cpfPep = '45030686878';
        dadosPessoaFisica.nomePessoaPep = 'Gustavo Pereira';
        dadosPessoaFisica.profissao = 'Desenvolvedor Salesforce';
        dadosPessoaFisica.numeroCpf = '450306868';
        dadosPessoaFisica.sexo = 'MASC';
        dadosPessoaFisica.dataNascimento = string.valueOf(system.today().addDays(-30));
        dadosPessoaFisica.estadoCivil = 'Solteiro';
        dadosPessoaFisica.digitoCpf = '78';
        dadosPessoaFisica.nacionalidade = 'BRA';
        pessoa.email = 'gustavo.silva@gmail.com';
        
        
        
        
        pessoa.dadosPessoaFisica = dadosPessoaFisica;
        dadosPagamento.responsavelPagamento = pessoa;
        contratante.dadosPagamento = dadosPagamento;
        contratante.pessoa = pessoa;
        segurado.dadosPagamento = dadosPagamento;
        segurado.pessoa = pessoa;
        
        test.startTest();
        
        AccountBO.getInstance().gerarParseConta(segurado, conta.Id, true);
        
        test.stopTest();
        
    }
    
    @isTest
    public static void testGerarParseContaContratante(){
        
        Account conta = [SELECT Id FROM Account Limit 1];        
        
        
        EmissaoTO.ContratanteTO contratante = new EmissaoTO.ContratanteTO();
        EmissaoTO.DadosPagamentoTO dadosPagamento = new EmissaoTO.DadosPagamentoTO();
        EmissaoTO.PessoaTO pessoa = new EmissaoTO.PessoaTO();
        EmissaoTO.DadosPessoaFisicaTO dadosPessoaFisica = new EmissaoTO.DadosPessoaFisicaTO();
        
        EmissaoTO.SeguradoTO segurado = new EmissaoTO.SeguradoTO();
        
        
        pessoa.tipo = 'FIS';
        dadosPessoaFisica.tipoRelacionamentoPep = 'a';
        dadosPessoaFisica.pep = 'a';
        dadosPessoaFisica.cpfPep = '45030686878';
        dadosPessoaFisica.nomePessoaPep = 'Gustavo Pereira';
        dadosPessoaFisica.profissao = 'Desenvolvedor Salesforce';
        dadosPessoaFisica.numeroCpf = '450306868';
        dadosPessoaFisica.sexo = 'MASC';
        dadosPessoaFisica.dataNascimento = string.valueOf(system.today().addDays(-30));
        dadosPessoaFisica.estadoCivil = 'Solteiro';
        dadosPessoaFisica.digitoCpf = '78';
        dadosPessoaFisica.nacionalidade = 'BRA';
        pessoa.email = 'gustavo.silva@gmail.com';
        
        
        
        
        pessoa.dadosPessoaFisica = dadosPessoaFisica;
        dadosPagamento.responsavelPagamento = pessoa;
        contratante.dadosPagamento = dadosPagamento;
        contratante.pessoa = pessoa;
        segurado.dadosPagamento = dadosPagamento;
        segurado.pessoa = pessoa;
        
        test.startTest();
        
        AccountBO.getInstance().gerarParseContaContratante(contratante, conta.Id, true);
        
        test.stopTest();
        
    }    
    
    @isTest
    public static void testGerarContaEmissao(){
        
        Account conta = [SELECT Id FROM Account Limit 1];        
        
        
        EmissaoTO.ContratanteTO contratante = new EmissaoTO.ContratanteTO();
        EmissaoTO.DadosPagamentoTO dadosPagamento = new EmissaoTO.DadosPagamentoTO();
        EmissaoTO.PessoaTO pessoa = new EmissaoTO.PessoaTO();
        EmissaoTO.DocumentoTO doc = new EmissaoTO.DocumentoTO();
        EmissaoTO.TelefoneTO tel = new EmissaoTO.TelefoneTO(); 
        
        EmissaoTO.DadosPessoaFisicaTO dadosPessoaFisica = new EmissaoTO.DadosPessoaFisicaTO();
        
        EmissaoTO.SeguradoTO segurado = new EmissaoTO.SeguradoTO();
        List<EmissaoTO.TelefoneTO> telefones = new List<EmissaoTO.TelefoneTO>();
        List<EmissaoTO.DocumentoTO> documentos = new List<EmissaoTO.DocumentoTO>();
        
        pessoa.tipo = 'FIS';
        dadosPessoaFisica.tipoRelacionamentoPep = 'a';
        dadosPessoaFisica.pep = 'a';
        dadosPessoaFisica.cpfPep = '45030686878';
        dadosPessoaFisica.nomePessoaPep = 'Gustavo Pereira';
        dadosPessoaFisica.profissao = 'Desenvolvedor Salesforce';
        dadosPessoaFisica.numeroCpf = '450306868';
        dadosPessoaFisica.sexo = 'MASC';
        dadosPessoaFisica.dataNascimento = string.valueOf(system.today().addDays(-30));
        dadosPessoaFisica.estadoCivil = 'Solteiro';
        dadosPessoaFisica.digitoCpf = '78';
        dadosPessoaFisica.nacionalidade = 'BRA';
        pessoa.email = 'gustavo.silva@gmail.com';
        
        
        doc.orgaoExpedidorDocumento = '';
        doc.numeroDocumentoIdentidade = '';
        doc.dataExpedicaoDocumento = string.valueOf(system.today().addDays(-30));
        doc.tipoDocumentoIdentidade = '';
        documentos.add(doc);
        dadosPessoaFisica.documentos = documentos;
        system.debug('dadosPessoaFisica.documentos: '+dadosPessoaFisica.documentos);
        
        
        tel.tipotelefone = 'CEL';
        tel.dddTelefone = '';
        tel.numeroTelefone ='';
        telefones.add(tel);
        pessoa.telefones = telefones;
        
        
        pessoa.dadosPessoaFisica = dadosPessoaFisica;
        dadosPagamento.responsavelPagamento = pessoa;
        contratante.dadosPagamento = dadosPagamento;
        contratante.pessoa = pessoa;
        segurado.dadosPagamento = dadosPagamento;
        segurado.pessoa = pessoa;
        
        test.startTest();
        
        Account acc = AccountBO.getInstance().gerarContaEmissao(pessoa, conta);
        
        test.stopTest();
        
    } 
    
    @isTest
    public static void testGerarEnderecoContaEmissao(){
        
        Account conta = [SELECT Id FROM Account Limit 1];        
        
        List<EmissaoTO.EnderecoTO> endereco = new List<EmissaoTO.EnderecoTO>();
        EmissaoTO.EnderecoTO ende = new EmissaoTO.EnderecoTO();
        //Novo TEste Bruno

		ende.cep = '05835';
        ende.complementoCep = '906';

        ende.tipoLogradouro = '';
        ende.tipoEndereco = '';
        ende.logradouro = '';
        ende.numeroLogradouro = '';
        ende.complemento = '';
        ende.bairro = '';
        ende.cidade = '';
        ende.uf = '';
        ende.paisResidencia = '';
        
        endereco.add(ende);
        
        test.startTest();
        
        AccountBO.getInstance().gerarEnderecoContaEmissao(endereco);
        
        test.stopTest();
        
    }    
}
//PLV-3667 - fim