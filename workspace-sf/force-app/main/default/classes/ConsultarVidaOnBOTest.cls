// //ZSVEP-76-INICIO
@IsTest
public class ConsultarVidaOnBOTest {

    @isTest
    static void cpfSuccessTest() {  
        String payloadReturn = '{"servico":"/vidaon/consultar-cpf-vidaon","status":"PROCESSADO","codigoprocessamento":0,"dataexecucao":"2022-08-04T19:54:55.998Z","descricao":"O CPF pode contratar.","dados":[{"Cpf":[{"numeroCpf":"206.894.460-04"}],"podeContratar":true}]}';
        Test.setMock(HttpCalloutMock.class, new MockHttpResponse(payloadReturn, 200, 'OK'));        

        String jsonTransmissao = '{"propostas":[{"indice":1,"codigoEmpresa":1,"numeroOrcamento":"00072045","numeroPortal":0,"origem":18,"ramoSeguro":1391,"tipoSeguro":"Novo","entradaNegocio":"COR","dataProtocolo":"2022-08-04","meioComercializacao":"SFC","codigoProdutoVida":"VIDA_ON","contratantes":[{"tipo":"PRI","numero":1,"grupos":[{"numero":1,"segurados":[{"pessoa":{"tipo":"FIS","enderecos":[{"tipoEndereco":"RESIDENCIAL","logradouro":"das Boas Noites","numeroLogradouro":null,"bairro":"Vila Regina ( Zona Leste)","cidade":"São Paulo","uf":"SP","cep":"08225","complemento":"","complementoCep":"180"},{"tipoEndereco":"COMERCIAL","logradouro":"","numeroLogradouro":null,"bairro":"","cidade":"","uf":"","cep":"","complemento":""}],"nome":"EMILIA SIRLEI TUCHTENHAGEN DE OLIVEIRA GOMES","dadosPessoaFisica":{"grupoProfissao":"DIT-A","cicloVacinal":"0","temDependentes":false,"profissao":"2111-05","tipoContrato":"VOCE","tempoGarantiaRenda":"48","fumante":false,"dataNascimento":"1957-04-25T00:00:00.000Z","sexo":"FEMININO","regimeTrabalho":"","numeroCpf":"206894460","digitoCpf":"04","estadoCivil":"SOLTEIRO","nacionalidade":"BRASILEIRA","tipoDocIdentificacao":"rg","docIdentificacao":"02222","orgaoExpedidor":"SSP","dataExpedicao":"2013-04-01","idade":65,"paisResidente":"Brasil","DataUltimaVacina":null,"paisDeOrigem":"","resideBrasil":true},"email":"e@gmail.com","rendaMensal":"4000.00","telefones":[{"tipoTelefone":"CEL","numeroTelefone":"00000000","dddTelefone":"00"},{"tipoTelefone":"RES","numeroTelefone":"000000000","dddTelefone":"00"}],"melhorPeriodo":"I","pessoaExpostaPoliticamente":"Nao"},"numero":1,"coberturas":[{"franquia":null,"sigla":"BAS","moeda":"BRL","limitemaximo":150000,"caracteristica":"Principal","valor":30000,"tipoprotecao":null,"caracteristicaespecialvalor":null,"limiteminimo":30000,"caracteristicaespecialtipo":null},{"franquia":null,"sigla":"IPTA","moeda":"BRL","limitemaximo":150000,"caracteristica":"Adicional","valor":30000,"tipoprotecao":null,"caracteristicaespecialvalor":null,"limiteminimo":30000,"caracteristicaespecialtipo":null},{"franquia":null,"sigla":"AFI","moeda":"BRL","limitemaximo":5000,"caracteristica":"Adicional","valor":5000,"tipoprotecao":"Família","caracteristicaespecialvalor":null,"limiteminimo":5000,"caracteristicaespecialtipo":null}],"empresaQueTrabalha":"","ramoAtividade":"","ocupacaoProfissionalPrincipal":"2111-05","faixaRenda":"","formaTrabalho":"","beneficiarios":[{"nome":null,"cpf":null,"nascimento":null,"grauParentesco":null,"percentualIndenizacao":100,"sexoBeneficiario":null,"tipoBeneficiario":"Herdeiros legais, conforme artigo 792 do código civil."}],"responsavelFinanceiro":true,"questionario":{"idquestionario":null,"respostas":[]}}],"nome":"","qtdeVidas":1}],"pessoa":{"tipo":"FIS","enderecos":[{"tipoEndereco":"RESIDENCIAL","logradouro":"das Boas Noites","numeroLogradouro":null,"bairro":"Vila Regina ( Zona Leste)","cidade":"São Paulo","uf":"SP","cep":"08225","complemento":"","complementoCep":"180"},{"tipoEndereco":"COMERCIAL","logradouro":"","numeroLogradouro":null,"bairro":"","cidade":"","uf":"","cep":"","complemento":""}],"nome":"EMILIA SIRLEI TUCHTENHAGEN DE OLIVEIRA GOMES","dadosPessoaFisica":{"grupoProfissao":"DIT-A","cicloVacinal":"0","temDependentes":false,"profissao":"2111-05","tipoContrato":"VOCE","tempoGarantiaRenda":"48","fumante":false,"dataNascimento":"1957-04-25T00:00:00.000Z","sexo":"FEMININO","regimeTrabalho":"","numeroCpf":"206894460","digitoCpf":"04","estadoCivil":"SOLTEIRO","nacionalidade":"BRASILEIRA","tipoDocIdentificacao":"rg","docIdentificacao":"02222","orgaoExpedidor":"SSP","dataExpedicao":"2013-04-01","idade":65,"paisResidente":"Brasil","DataUltimaVacina":null,"paisDeOrigem":"","resideBrasil":true},"email":"e@gmail.com","rendaMensal":"4000.00","telefones":[{"tipoTelefone":"CEL","numeroTelefone":"00000000","dddTelefone":"00"},{"tipoTelefone":"RES","numeroTelefone":"000000000","dddTelefone":"00"}],"melhorPeriodo":"I","pessoaExpostaPoliticamente":"Nao"},"dadosPagamento":{"opcao":2,"codigoFormaPagamento":62,"quantidadeParcelas":1,"cartaoCredito":null,"dadosBancarios":null,"formaPagamento":{"codigo":62,"descricao":"Cartão de Crédito","idFormaPagamento":"a0aL0000007ApN6IAK","planoParcelamento":{"idPlanoParcelamento":"1","quantidadeParcelas":1}},"responsavelPagamento":null,"tipoResponsavelPagamento":"CON","vencimentoDemaisParcelas":"A cada 30 dias","vigenciaInicial":null,"dadosCartaoCredito":{"cartaoPorto":false,"cvv":"naoInformado","nome":"Francis Liu","numero":"5448280000000007","validade":"012028","bandeira":"mastercard"},"responsavelFinanceiro":true}}],"canalDistribuicao":"COR","remuneracoes":[{"percentual":5,"tipoRemuneracao":"COR","favorecidos":[{"papel":"COR","participacao":100,"corretorLider":true,"susep":"P5005J","pessoa":null,"antecipaComissao":false}]}],"segmento":"Individual","tempoRendaProtegida":"48","dependentesFinanceiros":false,"formaReceberApolice":"DIGITAL","termoGuarda":false,"termoResponsabilidade":true,"assinaturaEletronica":true}]}';
        String retornoLTM = '{"servico":"/vidaon/consultar-cpf-vidaon","status":"PROCESSADO","codigoprocessamento":0,"dataexecucao":"2022-08-04T19:54:55.998Z","descricao":"O CPF pode contratar.","dados":[{"Cpf":[{"numeroCpf":"206.894.460-04"}],"podeContratar":true}]}';
        ContractBO.RetornoCIVConsultaLTMObject retObject = new ContractBO.RetornoCIVConsultaLTMObject();
        retObject = (ContractBO.RetornoCIVConsultaLTMObject) JSON.deserialize(retornoLTM, ContractBO.RetornoCIVConsultaLTMObject.class);

        Test.startTest();   
        ConsultarVidaOnBO consultaVidaOnBO = new ConsultarVidaOnBO();                 
        consultaVidaOnBO.ConsultarVidaOnBO(jsonTransmissao);
        System.debug(retObject);
        Test.stopTest();  
    }    

    @isTest
    static void cpfFailTest() { 
        String payloadReturn = '{"servico":"/vidaon/consultar-cpf-vidaon","status":"PROCESSADO","codigoprocessamento":0,"dataexecucao":"2022-08-04T19:54:55.998Z","descricao":"O CPF pode contratar.","dados":[{"Cpf":[{"numeroCpf":"206.894.460-04"}],"podeContratar":"true"}]}';
        Test.setMock(HttpCalloutMock.class, new MockHttpResponse(payloadReturn, 200, 'OK'));        

        String jsonTransmissao = '{"propostas":[{"indice":1,"codigoEmpresa":1,"numeroOrcamento":"00072045","numeroPortal":0,"origem":18,"ramoSeguro":1391,"tipoSeguro":"Novo","entradaNegocio":"COR","dataProtocolo":"2022-08-04","meioComercializacao":"SFC","codigoProdutoVida":"VIDA_ON","contratantes":[{"tipo":"PRI","numero":1,"grupos":[{"numero":1,"segurados":[{"pessoa":{"tipo":"FIS","enderecos":[{"tipoEndereco":"RESIDENCIAL","logradouro":"das Boas Noites","numeroLogradouro":null,"bairro":"Vila Regina ( Zona Leste)","cidade":"São Paulo","uf":"SP","cep":"08225","complemento":"","complementoCep":"180"},{"tipoEndereco":"COMERCIAL","logradouro":"","numeroLogradouro":null,"bairro":"","cidade":"","uf":"","cep":"","complemento":""}],"nome":"EMILIA SIRLEI TUCHTENHAGEN DE OLIVEIRA GOMES","dadosPessoaFisica":{"grupoProfissao":"DIT-A","cicloVacinal":"0","temDependentes":false,"profissao":"2111-05","tipoContrato":"VOCE","tempoGarantiaRenda":"48","fumante":false,"dataNascimento":"1957-04-25T00:00:00.000Z","sexo":"FEMININO","regimeTrabalho":"","numeroCpf":"206894460","digitoCpf":"04","estadoCivil":"SOLTEIRO","nacionalidade":"BRASILEIRA","tipoDocIdentificacao":"rg","docIdentificacao":"02222","orgaoExpedidor":"SSP","dataExpedicao":"2013-04-01","idade":65,"paisResidente":"Brasil","DataUltimaVacina":null,"paisDeOrigem":"","resideBrasil":true},"email":"e@gmail.com","rendaMensal":"4000.00","telefones":[{"tipoTelefone":"CEL","numeroTelefone":"00000000","dddTelefone":"00"},{"tipoTelefone":"RES","numeroTelefone":"000000000","dddTelefone":"00"}],"melhorPeriodo":"I","pessoaExpostaPoliticamente":"Nao"},"numero":1,"coberturas":[{"franquia":null,"sigla":"BAS","moeda":"BRL","limitemaximo":150000,"caracteristica":"Principal","valor":30000,"tipoprotecao":null,"caracteristicaespecialvalor":null,"limiteminimo":30000,"caracteristicaespecialtipo":null},{"franquia":null,"sigla":"IPTA","moeda":"BRL","limitemaximo":150000,"caracteristica":"Adicional","valor":30000,"tipoprotecao":null,"caracteristicaespecialvalor":null,"limiteminimo":30000,"caracteristicaespecialtipo":null},{"franquia":null,"sigla":"AFI","moeda":"BRL","limitemaximo":5000,"caracteristica":"Adicional","valor":5000,"tipoprotecao":"Família","caracteristicaespecialvalor":null,"limiteminimo":5000,"caracteristicaespecialtipo":null}],"empresaQueTrabalha":"","ramoAtividade":"","ocupacaoProfissionalPrincipal":"2111-05","faixaRenda":"","formaTrabalho":"","beneficiarios":[{"nome":null,"cpf":null,"nascimento":null,"grauParentesco":null,"percentualIndenizacao":100,"sexoBeneficiario":null,"tipoBeneficiario":"Herdeiros legais, conforme artigo 792 do código civil."}],"responsavelFinanceiro":true,"questionario":{"idquestionario":null,"respostas":[]}}],"nome":"","qtdeVidas":1}],"pessoa":{"tipo":"FIS","enderecos":[{"tipoEndereco":"RESIDENCIAL","logradouro":"das Boas Noites","numeroLogradouro":null,"bairro":"Vila Regina ( Zona Leste)","cidade":"São Paulo","uf":"SP","cep":"08225","complemento":"","complementoCep":"180"},{"tipoEndereco":"COMERCIAL","logradouro":"","numeroLogradouro":null,"bairro":"","cidade":"","uf":"","cep":"","complemento":""}],"nome":"EMILIA SIRLEI TUCHTENHAGEN DE OLIVEIRA GOMES","dadosPessoaFisica":{"grupoProfissao":"DIT-A","cicloVacinal":"0","temDependentes":false,"profissao":"2111-05","tipoContrato":"VOCE","tempoGarantiaRenda":"48","fumante":false,"dataNascimento":"1957-04-25T00:00:00.000Z","sexo":"FEMININO","regimeTrabalho":"","numeroCpf":"206894460","digitoCpf":"04","estadoCivil":"SOLTEIRO","nacionalidade":"BRASILEIRA","tipoDocIdentificacao":"rg","docIdentificacao":"02222","orgaoExpedidor":"SSP","dataExpedicao":"2013-04-01","idade":65,"paisResidente":"Brasil","DataUltimaVacina":null,"paisDeOrigem":"","resideBrasil":true},"email":"e@gmail.com","rendaMensal":"4000.00","telefones":[{"tipoTelefone":"CEL","numeroTelefone":"00000000","dddTelefone":"00"},{"tipoTelefone":"RES","numeroTelefone":"000000000","dddTelefone":"00"}],"melhorPeriodo":"I","pessoaExpostaPoliticamente":"Nao"},"dadosPagamento":{"opcao":2,"codigoFormaPagamento":62,"quantidadeParcelas":3,"cartaoCredito":null,"dadosBancarios":null,"formaPagamento":{"codigo":62,"descricao":"Cartão de Crédito","idFormaPagamento":"a0aL0000007ApN6IAK","planoParcelamento":{"idPlanoParcelamento":"1","quantidadeParcelas":1}},"responsavelPagamento":null,"tipoResponsavelPagamento":"CON","vencimentoDemaisParcelas":"A cada 30 dias","vigenciaInicial":null,"dadosCartaoCredito":{"cartaoPorto":false,"cvv":"naoInformado","nome":"Francis Liu","numero":"5448280000000007","validade":"012028","bandeira":"mastercard"},"responsavelFinanceiro":true}}],"canalDistribuicao":"COR","remuneracoes":[{"percentual":5,"tipoRemuneracao":"COR","favorecidos":[{"papel":"COR","participacao":100,"corretorLider":true,"susep":"P5005J","pessoa":null,"antecipaComissao":false}]}],"segmento":"Individual","tempoRendaProtegida":"48","dependentesFinanceiros":false,"formaReceberApolice":"DIGITAL","termoGuarda":false,"termoResponsabilidade":true,"assinaturaEletronica":true}]}';       
        ContractBO.RetornoCIVConsultaLTMObject retObject = new ContractBO.RetornoCIVConsultaLTMObject();
        System.debug(retObject);

        Test.startTest();   
        ConsultarVidaOnBO consultaVidaOnBO = new ConsultarVidaOnBO();                 
        try {
            consultaVidaOnBO.ConsultarVidaOnBO(jsonTransmissao);

        } catch(Exception e) {            
            System.assert(e.getMessage().contains('Erro'));
        }                
        Test.stopTest();  
    }    

    @IsTest
    static void testConsultaSeguroAtivo() {
        // Simular a entrada para o método consultaSeguroAtivo
        String CPF = '30625824059';

        // Mock SensediaServices
        Test.setMock(HttpCalloutMock.class, new SensediaServicesMock());

        // Simular a chamada do serviço e a resposta
        Test.startTest();
        ConsultarVidaOnBO instance = ConsultarVidaOnBO.getInstance();
        String resultado = instance.consultaSeguroAtivo(CPF);
        ContractBO.RetornoCIVConsultaLTMList retObject = new ContractBO.RetornoCIVConsultaLTMList();
        Test.stopTest();

        // Asserções para verificar o comportamento esperado
        System.assertEquals('Seguro Ativo', resultado);
    }


    @IsTest
    static void testResponseHerokuConsultarCPFVidaOn() {
        // Testar a classe interna ResponseHerokuConsultarCPFVidaOn
        ConsultarVidaOnBO.ResponseHerokuConsultarCPFVidaOn response = new ConsultarVidaOnBO.ResponseHerokuConsultarCPFVidaOn();
        response.servico = 'mockService';
        response.status = 'mockStatus';
        response.codigoprocessamento = 123;
        response.dataexecucao = '2024-01-01';
        response.descricao = 'Mock Description';
        response.dados = new List<ConsultarVidaOnBO.infoGravaCPF>();

        ConsultarVidaOnBO.infoGravaCPF info = new ConsultarVidaOnBO.infoGravaCPF();
        info.podeContratar = true;
        info.Cpf = new List<ConsultarVidaOnBO.listCPF>();

        ConsultarVidaOnBO.listCPF cpf = new ConsultarVidaOnBO.listCPF();
        cpf.numeroCpf = '30625824059';
        info.Cpf.add(cpf);

        response.dados.add(info);

        // Asserções para verificar o comportamento esperado
        System.assertEquals('mockService', response.servico);
        System.assertEquals('mockStatus', response.status);
        System.assertEquals(123, response.codigoprocessamento);
        System.assertEquals('2024-01-01', response.dataexecucao);
        System.assertEquals('Mock Description', response.descricao);
        System.assertEquals(1, response.dados.size());
        System.assertEquals(true, response.dados[0].podeContratar);
        System.assertEquals(1, response.dados[0].Cpf.size());
        System.assertEquals('30625824059', response.dados[0].Cpf[0].numeroCpf);
    }

    // Implementação de mocks para HerokuService e SensediaServices
    private class HerokuServiceMock implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            HttpResponse res = new HttpResponse();
            res.setStatusCode(200);
            res.setBody('{"servico":"mockService","status":"mockStatus","codigoprocessamento":123,"dataexecucao":"2024-01-01","descricao":"Mock Description","dados":[{"Cpf":[{"numeroCpf":"30625824059"}],"podeContratar":true}]}');
            return res;
        }
    }

    private class SensediaServicesMock implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            HttpResponse res = new HttpResponse();
            res.setStatusCode(200);
            res.setBody('{"seguroVidaOnAtivo":"Seguro Ativo"}');
            return res;
        }
    }
}
//ZSVEP-76-FIM