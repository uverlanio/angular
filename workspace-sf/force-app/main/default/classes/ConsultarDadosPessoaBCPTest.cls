/*
    Class: Classe de teste
    Author: Uverlanio Mauricio
    Date: 09/09/2024
    Histrória origem: //ANNVI-208
*/
////ANNVI-208 - INICIO
@IsTest
public with sharing class ConsultarDadosPessoaBCPTest {
    
    @IsTest
    static void testParams(){
        
        Test.startTest();
        
        ConsultarDadosPessoaBCP cdp = ConsultarDadosPessoaBCP.getInstance();        
        cdp.setParams('123456789', false, '12345678912345');

        Test.stopTest();

        System.assertEquals(cdp.numDocumento, '123456789');
        System.assertEquals(cdp.obterVinculoCorretora, false);
        System.assertEquals(cdp.pesCod, '12345678912345');
        
    }

    @IsTest
    static void testResponseMock(){
        
        Test.startTest();
        
        ConsultarDadosPessoaBCP.ConsltDadPesBCPResponse response = responseMock();            
        
        Test.stopTest();

        response.codigoPapel = '12345';
        response.dataNascimento = '01-01-1990';

        System.assert(response.codigoPapel == '12345');
        System.assert(response.dataNascimento == '01-01-1990');

        System.assert(response.emails.size() == 1);
        ConsultarDadosPessoaBCP.Email email = response.emails[0];
        System.assert(email.dataAtualizacaoEmail == '01-01-2022');
        System.assert(email.email == 'exemplo@email.com');
        System.assert(email.numseq == 1);
        System.assert(email.tipoEmail == 'TRABALHO');

        System.assert(response.enderecos.size() == 1);
        ConsultarDadosPessoaBCP.Endereco endereco = response.enderecos[0];
        System.assert(endereco.bairro == 'Centro');
        System.assert(endereco.cep == '12345-678');
        System.assert(endereco.cidade == 'São Paulo');
        System.assert(endereco.codigoFinalidade == 1);
        System.assert(endereco.complemento == 'Bloco A, Apt 123');
        System.assert(endereco.cplcepnum == '123456789');
        System.assert(endereco.descricaoFinalidade == 'Residencial');
        System.assert(endereco.latitude == '123.456');
        System.assert(endereco.logradouro == 'Rua Exemplo');
        System.assert(endereco.longitude == '789.012');
        System.assert(endereco.numero == '123');
        System.assert(endereco.pais == 'Brasil');
        System.assert(endereco.tipoLogradouro == 'Rua');
        System.assert(endereco.uf == 'SP');

        System.assert(response.estadoCivil == 1);
        System.assert(response.nome == 'Fulano de Tal');
        System.assert(response.nomeMae == 'Maria Silva');
        System.assert(response.nomePai == 'João Silva');
        System.assert(response.nomePapel == 'Papel Exemplo');
        System.assert(response.nomeSocial == 'Fulano de Souza');
        System.assert(response.nomeTratamento == 'Sr. Fulano');
        System.assert(response.numDocumento == '12345678900');
        System.assert(response.pescod == 1);
        System.assert(response.sexo == 'M');

        System.assert(response.telefones.size() == 1);
        ConsultarDadosPessoaBCP.Telefone telefone = response.telefones[0];
        System.assert(telefone.codigo == 1);
        System.assert(telefone.ddd == 11);
        System.assert(telefone.ddi == 55);
        System.assert(telefone.numero == 987654321);
        System.assert(telefone.seqnum == 1);
        System.assert(telefone.tipo == 'CELULAR');

        System.assert(response.tipoDocumento == 'CPF');
        System.assert(response.tipoPessoa == 'Física');
        System.assert(response.titularidadeDocumento == 'Próprio');

        System.assert(response.vinculoCorretora.size() == 1);
        ConsultarDadosPessoaBCP.VinculoCorretora vinculoCorretora = response.vinculoCorretora[0];
        System.assert(vinculoCorretora.codigoSusep == '123456');
        System.assert(vinculoCorretora.fimRelacionamento == '01-01-2023');
        System.assert(vinculoCorretora.inicioRelacionamento == '01-01-2022');
        System.assert(vinculoCorretora.seqnum == 1);

    }

    public static ConsultarDadosPessoaBCP.ConsltDadPesBCPResponse responseMock(){

        ConsultarDadosPessoaBCP.ConsltDadPesBCPResponse cdpResponse = new ConsultarDadosPessoaBCP.ConsltDadPesBCPResponse();

        cdpResponse.codigoPapel = '12345';
        cdpResponse.dataNascimento = '01-01-1990';

        ConsultarDadosPessoaBCP.Email email = new ConsultarDadosPessoaBCP.Email();
        email.dataAtualizacaoEmail = '01-01-2022';
        email.email = 'exemplo@email.com';
        email.numseq = 1;
        email.tipoEmail = 'TRABALHO';

        cdpResponse.emails = new List<ConsultarDadosPessoaBCP.Email>{email};

        ConsultarDadosPessoaBCP.Endereco endereco = new ConsultarDadosPessoaBCP.Endereco();
        endereco.bairro = 'Centro';
        endereco.cep = '12345-678';
        endereco.cidade = 'São Paulo';
        endereco.codigoFinalidade = 1;
        endereco.complemento = 'Bloco A, Apt 123';
        endereco.cplcepnum = '123456789';
        endereco.descricaoFinalidade = 'Residencial';
        endereco.latitude = '123.456';
        endereco.logradouro = 'Rua Exemplo';
        endereco.longitude = '789.012';
        endereco.numero = '123';
        endereco.pais = 'Brasil';
        endereco.tipoLogradouro = 'Rua';
        endereco.uf = 'SP';

        cdpResponse.enderecos = new List<ConsultarDadosPessoaBCP.Endereco>{endereco};

        cdpResponse.estadoCivil = 1;
        cdpResponse.nome = 'Fulano de Tal';
        cdpResponse.nomeMae = 'Maria Silva';
        cdpResponse.nomePai = 'João Silva';
        cdpResponse.nomePapel = 'Papel Exemplo';
        cdpResponse.nomeSocial = 'Fulano de Souza';
        cdpResponse.nomeTratamento = 'Sr. Fulano';
        cdpResponse.numDocumento = '12345678900';
        cdpResponse.pescod = 1;
        cdpResponse.sexo = 'M';

        ConsultarDadosPessoaBCP.Telefone telefone = new ConsultarDadosPessoaBCP.Telefone();
        telefone.codigo = 1;
        telefone.ddd = 11;
        telefone.ddi = 55;
        telefone.numero = 987654321;
        telefone.seqnum = 1;
        telefone.tipo = 'CELULAR';

        cdpResponse.telefones = new List<ConsultarDadosPessoaBCP.Telefone>{telefone};

        cdpResponse.tipoDocumento = 'CPF';
        cdpResponse.tipoPessoa = 'Física';
        cdpResponse.titularidadeDocumento = 'Próprio';

        ConsultarDadosPessoaBCP.VinculoCorretora vinculoCorretora = new ConsultarDadosPessoaBCP.VinculoCorretora();
        vinculoCorretora.codigoSusep = '123456';
        vinculoCorretora.fimRelacionamento = '01-01-2023';
        vinculoCorretora.inicioRelacionamento = '01-01-2022';
        vinculoCorretora.seqnum = 1;

        cdpResponse.vinculoCorretora = new List<ConsultarDadosPessoaBCP.VinculoCorretora>{vinculoCorretora};

        return cdpResponse;
    }
}
////ANNVI-208 - FIM