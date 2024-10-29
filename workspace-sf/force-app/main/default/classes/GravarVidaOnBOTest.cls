/*
@description  Classe de teste para a classe GravarVidaOnBO.cls e ConsultarVidaOnBO.cls
@author - Globant
@date 27/07/2022
@Classe criada para cobrir a história AV-530
*/
@isTest
public with sharing class GravarVidaOnBOTest {
    @TestSetup
    static void makeData(){
        Account contaTeste = TestDataFactory.gerarConta();
        DadosCorretor__c dadosCorretor = TestDataFactory.gerarDadosCorretor(contaTeste);
        RamoSeguro__c ramoSegurado = TestDataFactory.gerarRamoSeguro(contaTeste);
        Garantia__c garantia1 = TestDataFactory.gerarGarantia();
        RamoGarantia__c ramoGarantia = TestDataFactory.gerarRamoGarantia(garantia1, ramoSegurado);
        
        ContadorCodigo__c contCodigoTec = (ContadorCodigo__c) new ContadorCodigoFactory.ProdutoTecnico().createRecord();
	    ContadorCodigo__c contCodigoCom = (ContadorCodigo__c) new ContadorCodigoFactory.ProdutoComercial().createRecord();
        
        Product2 produtoTec = TestDataFactory.gerarProdutoTecnico();
        produtoTec.Status__c = 'Ativo';
        produtoTec.Segmento__c = 'Individual';
        produtoTec.ProductCode = 'VIDA_ON';
        update produtoTec;
        
        Product2 produtoCom = TestDataFactory.gerarProdutoComericial(produtoTec);
        produtoCom.Status__c ='ativo';
        produtoCom.Segmento__c = 'Individual';
        produtoCom.ProductCode = 'VIDA_ON';
        update produtoCom;

        GarantiaProduto__c garantiaTecnica = TestDataFactory.gerarGarantiaProdutoTecnico(produtoTec, garantia1, ramoSegurado);

        GarantiaProduto__c garantiaComercial = TestDataFactory.gerarGarantiaProdutoComercial(produtoCom, garantia1, garantiaTecnica, ramoSegurado);

        CanalDistribuicao__c canalDistribuicao = TestDataFactory.gerarCanalDistribuicao();
        
        Opportunity orcamentoContratado = TestDataFactory.gerarOrcamentoObjeto(contaTeste, produtoCom, canalDistribuicao);
         //RVI-247 - INICIO
        //RVI-160 - INICIO
        //Opportunity orcamentoRenovado = TestDataFactory.gerarOrcamentoObjeto(contaTeste, produtoCom, canalDistribuicao);
        Opportunity orcamentoRenovado = [SELECT Id FROM Opportunity];
        orcamentoRenovado.Name = 'ARQ-00006780';
        orcamentoRenovado.Numero__c = '00006780';
        update orcamentoRenovado;
        System.debug('orcamentoRenovado=====' + orcamentoRenovado);
        //RVI-160 - FIM
         //RVI-247 - FIM
        
        Modalidade__c modalidade = TestDataFactory.gerarModalidade(ramoSegurado);

        ParametroVigencia__c paramVigencia = TestDataFactory.gerarParametroVigenciaProdutoComercial(produtoCom);
        paramVigencia.VigenciaMinimaRenovacao__c = 90;
        paramVigencia.Tipo__c = 'Periódico';
        update paramVigencia;

        Quote cot = TestDataFactory.gerarPropostaObjeto(produtoCom, ramoSegurado, contaTeste, dadosCorretor, orcamentoContratado, modalidade);
        cot.NumeroProposta__c = '00001910';
        cot.email__c = 'abcd@qualqueremail.com';
        update cot;
        
        FormaPagamento__c formPag = TestDataFactory.gerarFormaPagamento(ramoSegurado, modalidade, 'CARTAO DE CREDITO (TODAS PARC.EM CARTAO)', '62');

        Contract contrato = TestDataFactory.gerarContratoObjeto(produtoCom, ramoSegurado, contaTeste, dadosCorretor, cot);
        contrato.Oportunidade__c = orcamentoContratado.Id;
        contrato.NumeroPropostaUnico__c = '18-00001910';
        contrato.NumeroApolice__c = '000014419';
        contrato.Tipo__c = 'Novo';   //RVI-160 - INICIO/FIM
        contrato.Status = 'Emitido'; //RVI-160 - INICIO/FIM
        contrato.Endosso__c = '0';
        contrato.VigenciaFinal__c = System.today().addDays(30);		       		    		    
        contrato.StatusRenovacao__c = 'Não Renovado'; //RVI-160 - INICIO/FIM
        contrato.CodigoRamo__c = '1391';
        contrato.ApolicePdfDownloadUrl__c = 'https://MestreChico.com';    
        contrato.AlteraFormaPagto__c = false; // RVI-186 - FIX02 - INICIO/FIM
        update contrato;

        //RVI-189-INICIO
        ContentVersion content=new ContentVersion(); 
        content.Title='Header_Picture1_localStorage'; 
        content.PathOnClient='/' + content.Title + '.jpg'; 
        Blob bodyBlob=Blob.valueOf('Unit Test ContentVersion Body'); 
        content.VersionData=bodyBlob; 
        //content.LinkedEntityId=sub.id;
        content.origin = 'H';
        insert content;
                
        ContentDocumentLink contentlink=new ContentDocumentLink();
        contentlink.LinkedEntityId=contrato.id;
        contentlink.contentdocumentid=[select contentdocumentid from contentversion where id =: content.id].contentdocumentid;
        contentlink.ShareType = 'I';
        contentlink.Visibility = 'AllUsers'; 
        contentlink.LinkedEntityId = orcamentoContratado.id;
        insert contentlink;
        //RVI-189-FIM

        // RVI-186-FIX02 - INICIO 
        //RVI-160 - INICIO
        // Contract contratoRenovado = TestDataFactory.gerarContratoObjeto(produtoCom, ramoSegurado, contaTeste, dadosCorretor, cot);
        // contratoRenovado.Oportunidade__c = orcamentoRenovado.Id;
        // contratoRenovado.Name = contrato.Empresa__c + '-' + contrato.Sucursal__c  + '-' + contrato.CodigoRamo__c + '-' + contrato.NumeroApolice__c + '-1';       
        // contratoRenovado.PrimeiroContratoRenovacao__c = contrato.Id;		
        // contratoRenovado.NumeroPropostaUnico__c = '18-00001911';
        // contratoRenovado.NumeroApolice__c = '000014419';
        // contratoRenovado.ContratoRenovado__c = contrato.Id; //RVI-160 - INICIO/FIM
        // contratoRenovado.Tipo__c = 'Renovacao'; //RVI-160 - INICIO/FIM
        // contratoRenovado.Status = 'Emitido';    //RVI-160 - INICIO/FIM
        // contratoRenovado.Endosso__c = '1';
        // contratoRenovado.VigenciaFinal__c = System.today().addDays(366);		       		    		    
        // contratoRenovado.StatusRenovacao__c = 'Não Renovado'; //RVI-160 - INICIO/FIM
        // contratoRenovado.CodigoRamo__c = '1391';   
        // contratoRenovado.ApolicePdfDownloadUrl__c = 'https://MestreChico.com';  //RVI-57 - INICIO/FIM 
        // update contratoRenovado;
        //RVI-160 - FIM

        Contract contratoRenovado = new Contract();
        contratoRenovado.Oportunidade__c = orcamentoRenovado.Id;
        contratoRenovado.Produto__c = produtoCom.Id;        
        contratoRenovado.RamoSeguro__c = ramoSegurado.Id;
        contratoRenovado.Status = 'Em elaboração' ;
        contratoRenovado.Empresa__c = '22';
        contratoRenovado.CodigoCorretor__c = dadosCorretor.Id;
        contratoRenovado.Proposta__c = cot.Id;
        contratoRenovado.AccountId = contaTeste.Id;
        contratoRenovado.AlteraFormaPagto__c = false;
        contratoRenovado.Name = contrato.Empresa__c + '-' + contrato.Sucursal__c  + '-' + contrato.CodigoRamo__c + '-' + contrato.NumeroApolice__c + '-1';       
        contratoRenovado.PrimeiroContratoRenovacao__c = contrato.Id;		
        contratoRenovado.NumeroPropostaUnico__c = '18-00001911';
        contratoRenovado.NumeroApolice__c = '000014419';
        contratoRenovado.Tipo__c = 'Renovacao'; //RVI-160 - INICIO/FIM
        contratoRenovado.Endosso__c = '1';
        contratoRenovado.VigenciaFinal__c = System.today().addDays(366);		       		    		    
        contratoRenovado.StatusRenovacao__c = 'Não Renovado'; //RVI-160 - INICIO/FIM
        contratoRenovado.CodigoRamo__c = '1391';   
        contratoRenovado.ApolicePdfDownloadUrl__c = 'https://MestreChico.com';  //RVI-57 - INICIO/FIM 
        insert contratoRenovado;
        // RVI-186-FIX02 - FIM 

        TipoRemuneracao__c tipoRemuneracao = TestDataFactory.gerarTipoRemuneracao('Contrato', 15, 1000, 'Integral');

        RemuneracaoContrato__c remCon = TestDataFactory.gerarRemuneracaoContrato(contrato, tipoRemuneracao);
        remCon.CurrencyIsoCode = 'BRL';
        remCon.Percentual__c = 10;
        remCon.Porcentagem_de_Retencao__c = 0;
        update remCon;

        //RVI-160 - INICIO
        RemuneracaoContrato__c remConRen = TestDataFactory.gerarRemuneracaoContrato(contratoRenovado, tipoRemuneracao);
        remConRen.CurrencyIsoCode = 'BRL';
        remConRen.Percentual__c = 10;
        remConRen.Porcentagem_de_Retencao__c = 0;
        update remConRen;
        //RVI-160 - FIM

        FavorecidoRemuneracaoContrato__c favRemCon = new FavorecidoRemuneracaoContrato__c();
        favRemCon.Conta__c = contaTeste.Id;
        favRemCon.CorretorLider__c = true;
        favRemCon.AntecipacaoComissao__c = true;
        favRemCon.RemuneracaoContrato__c = remCon.Id;
        favRemCon.Papel__c = 'Corretor';
        insert favRemCon;	

        //RVI-160 - INICIO
        FavorecidoRemuneracaoContrato__c favRemConRen = new FavorecidoRemuneracaoContrato__c();
        favRemConRen.Conta__c = contaTeste.Id;
        favRemConRen.CorretorLider__c = true;
        favRemConRen.AntecipacaoComissao__c = true;
        favRemConRen.RemuneracaoContrato__c = remConRen.Id;
        favRemConRen.Papel__c = 'Corretor';
        insert favRemConRen;
        //RVI-160 - FIM

        GarantiaContrato__c garCtr = TestDataFactory.gerarGarantiaContrato(contrato, garantiaComercial);
        //RVI-160 - INICIO
        GarantiaContrato__c garCtrRen = TestDataFactory.gerarGarantiaContrato(contratoRenovado, garantiaComercial);
        //RVI-160 - FIM
    }

    @isTest
    static void testSaveCPFSuccess() {  

        String payloadReturn = '{"servico":"/vidaon/gravar-cpf-vidaon","status":"PROCESSADO","codigoprocessamento":0,"dataexecucao":"2022-08-01T19:11:40.641Z","descricao":"Item não modificado!","dados":[{"numeroCpf":"518.179.180-87","numeroApolice":"1-1-1391-000019437-0","statusApolice":"Emitido","numeroProposta":"18-00038023","statusProposta":"Contratada"}]}';
        Test.setMock(HttpCalloutMock.class, new MockHttpResponse(payloadReturn, 200, 'OK'));

        String dadosContrato = '{'
        +    '"contratos": ['
        +      '{'
        +        '"numeroCpf": "518.179.180-87",'
        +        '"numeroApolice": "1-1-1391-000019437-0"'
        +        '"statusApolice": "Emitido",'
        +        '"tipoContrato": "Novo",'
        +      '}'
        +    ']'
        +  '}';

        String jsonList = JSON.serialize(dadosContrato);
        GravarVidaOnBO.ResponseHerokuGravarCPFVidaOn respGravarVdOn = HerokuService.getInstance().gravarCPFVidaOn(jsonList);        
        GravarVidaOnBO.ResponseHerokuGravarCPFVidaOn objetoGravarVdOn = (GravarVidaOnBO.ResponseHerokuGravarCPFVidaOn) System.JSON.deserialize(payloadReturn, GravarVidaOnBO.ResponseHerokuGravarCPFVidaOn.class);	

        Test.startTest();                     
        GravarVidaOnBO.gravarCPFVidaOn();
        Test.stopTest();            
    }    

    @isTest
    static void testConsultarCPFSuccess() {  

        String payloadReturn = '{"servico":"/vidaon/consultar-cpf-vidaon","status":"PROCESSADO","codigoprocessamento":0,"dataexecucao":"2022-08-04T19:54:55.998Z","descricao":"O CPF pode contratar.","dados":[{"Cpf":[{"numeroCpf":"206.894.460-04"}],"podeContratar":true}]}';
        Test.setMock(HttpCalloutMock.class, new MockHttpResponse(payloadReturn, 200, 'OK'));        

        String jsonTransmissao = '{"propostas":[{"indice":1,"codigoEmpresa":1,"numeroOrcamento":"00072045","numeroPortal":0,"origem":18,"ramoSeguro":1391,"tipoSeguro":"Novo","entradaNegocio":"COR","dataProtocolo":"2022-08-04","meioComercializacao":"SFC","codigoProdutoVida":"VIDA_ON","contratantes":[{"tipo":"PRI","numero":1,"grupos":[{"numero":1,"segurados":[{"pessoa":{"tipo":"FIS","enderecos":[{"tipoEndereco":"RESIDENCIAL","logradouro":"das Boas Noites","numeroLogradouro":null,"bairro":"Vila Regina ( Zona Leste)","cidade":"São Paulo","uf":"SP","cep":"08225","complemento":"","complementoCep":"180"},{"tipoEndereco":"COMERCIAL","logradouro":"","numeroLogradouro":null,"bairro":"","cidade":"","uf":"","cep":"","complemento":""}],"nome":"EMILIA SIRLEI TUCHTENHAGEN DE OLIVEIRA GOMES","dadosPessoaFisica":{"grupoProfissao":"DIT-A","cicloVacinal":"0","temDependentes":false,"profissao":"2111-05","tipoContrato":"VOCE","tempoGarantiaRenda":"48","fumante":false,"dataNascimento":"1957-04-25T00:00:00.000Z","sexo":"FEMININO","regimeTrabalho":"","numeroCpf":"206894460","digitoCpf":"04","estadoCivil":"SOLTEIRO","nacionalidade":"BRASILEIRA","tipoDocIdentificacao":"rg","docIdentificacao":"02222","orgaoExpedidor":"SSP","dataExpedicao":"2013-04-01","idade":65,"paisResidente":"Brasil","DataUltimaVacina":null,"paisDeOrigem":"","resideBrasil":true},"email":"e@gmail.com","rendaMensal":"4000.00","telefones":[{"tipoTelefone":"CEL","numeroTelefone":"00000000","dddTelefone":"00"},{"tipoTelefone":"RES","numeroTelefone":"000000000","dddTelefone":"00"}],"melhorPeriodo":"I","pessoaExpostaPoliticamente":"Nao"},"numero":1,"coberturas":[{"franquia":null,"sigla":"BAS","moeda":"BRL","limitemaximo":150000,"caracteristica":"Principal","valor":30000,"tipoprotecao":null,"caracteristicaespecialvalor":null,"limiteminimo":30000,"caracteristicaespecialtipo":null},{"franquia":null,"sigla":"IPTA","moeda":"BRL","limitemaximo":150000,"caracteristica":"Adicional","valor":30000,"tipoprotecao":null,"caracteristicaespecialvalor":null,"limiteminimo":30000,"caracteristicaespecialtipo":null},{"franquia":null,"sigla":"AFI","moeda":"BRL","limitemaximo":5000,"caracteristica":"Adicional","valor":5000,"tipoprotecao":"Família","caracteristicaespecialvalor":null,"limiteminimo":5000,"caracteristicaespecialtipo":null}],"empresaQueTrabalha":"","ramoAtividade":"","ocupacaoProfissionalPrincipal":"2111-05","faixaRenda":"","formaTrabalho":"","beneficiarios":[{"nome":null,"cpf":null,"nascimento":null,"grauParentesco":null,"percentualIndenizacao":100,"sexoBeneficiario":null,"tipoBeneficiario":"Herdeiros legais, conforme artigo 792 do código civil."}],"responsavelFinanceiro":true,"questionario":{"idquestionario":null,"respostas":[]}}],"nome":"","qtdeVidas":1}],"pessoa":{"tipo":"FIS","enderecos":[{"tipoEndereco":"RESIDENCIAL","logradouro":"das Boas Noites","numeroLogradouro":null,"bairro":"Vila Regina ( Zona Leste)","cidade":"São Paulo","uf":"SP","cep":"08225","complemento":"","complementoCep":"180"},{"tipoEndereco":"COMERCIAL","logradouro":"","numeroLogradouro":null,"bairro":"","cidade":"","uf":"","cep":"","complemento":""}],"nome":"EMILIA SIRLEI TUCHTENHAGEN DE OLIVEIRA GOMES","dadosPessoaFisica":{"grupoProfissao":"DIT-A","cicloVacinal":"0","temDependentes":false,"profissao":"2111-05","tipoContrato":"VOCE","tempoGarantiaRenda":"48","fumante":false,"dataNascimento":"1957-04-25T00:00:00.000Z","sexo":"FEMININO","regimeTrabalho":"","numeroCpf":"206894460","digitoCpf":"04","estadoCivil":"SOLTEIRO","nacionalidade":"BRASILEIRA","tipoDocIdentificacao":"rg","docIdentificacao":"02222","orgaoExpedidor":"SSP","dataExpedicao":"2013-04-01","idade":65,"paisResidente":"Brasil","DataUltimaVacina":null,"paisDeOrigem":"","resideBrasil":true},"email":"e@gmail.com","rendaMensal":"4000.00","telefones":[{"tipoTelefone":"CEL","numeroTelefone":"00000000","dddTelefone":"00"},{"tipoTelefone":"RES","numeroTelefone":"000000000","dddTelefone":"00"}],"melhorPeriodo":"I","pessoaExpostaPoliticamente":"Nao"},"dadosPagamento":{"opcao":2,"codigoFormaPagamento":62,"quantidadeParcelas":1,"cartaoCredito":null,"dadosBancarios":null,"formaPagamento":{"codigo":62,"descricao":"Cartão de Crédito","idFormaPagamento":"a0aL0000007ApN6IAK","planoParcelamento":{"idPlanoParcelamento":"1","quantidadeParcelas":1}},"responsavelPagamento":null,"tipoResponsavelPagamento":"CON","vencimentoDemaisParcelas":"A cada 30 dias","vigenciaInicial":null,"dadosCartaoCredito":{"cartaoPorto":false,"cvv":"naoInformado","nome":"Francis Liu","numero":"5448280000000007","validade":"012028","bandeira":"mastercard"},"responsavelFinanceiro":true}}],"canalDistribuicao":"COR","remuneracoes":[{"percentual":5,"tipoRemuneracao":"COR","favorecidos":[{"papel":"COR","participacao":100,"corretorLider":true,"susep":"P5005J","pessoa":null,"antecipaComissao":false}]}],"segmento":"Individual","tempoRendaProtegida":"48","dependentesFinanceiros":false,"formaReceberApolice":"DIGITAL","termoGuarda":false,"termoResponsabilidade":true,"assinaturaEletronica":true}]}';
        
        Test.startTest();   
        ConsultarVidaOnBO consultaVidaOnBO = new ConsultarVidaOnBO();                 
        consultaVidaOnBO.ConsultarVidaOnBO(jsonTransmissao);
        Test.stopTest();  
    }    

    @isTest
    static void testConsultarCPFFail() {  

        String payloadReturn = '{"servico":"/vidaon/consultar-cpf-vidaon","status":"PROCESSADO","codigoprocessamento":0,"dataexecucao":"2022-08-04T19:54:55.998Z","descricao":"O CPF pode contratar.","dados":[{"Cpf":[{"numeroCpf":"206.894.460-04"}],"podeContratar":"true"}]}';
        Test.setMock(HttpCalloutMock.class, new MockHttpResponse(payloadReturn, 200, 'OK'));        

        String jsonTransmissao = '{"propostas":[{"indice":1,"codigoEmpresa":1,"numeroOrcamento":"00072045","numeroPortal":0,"origem":18,"ramoSeguro":1391,"tipoSeguro":"Novo","entradaNegocio":"COR","dataProtocolo":"2022-08-04","meioComercializacao":"SFC","codigoProdutoVida":"VIDA_ON","contratantes":[{"tipo":"PRI","numero":1,"grupos":[{"numero":1,"segurados":[{"pessoa":{"tipo":"FIS","enderecos":[{"tipoEndereco":"RESIDENCIAL","logradouro":"das Boas Noites","numeroLogradouro":null,"bairro":"Vila Regina ( Zona Leste)","cidade":"São Paulo","uf":"SP","cep":"08225","complemento":"","complementoCep":"180"},{"tipoEndereco":"COMERCIAL","logradouro":"","numeroLogradouro":null,"bairro":"","cidade":"","uf":"","cep":"","complemento":""}],"nome":"EMILIA SIRLEI TUCHTENHAGEN DE OLIVEIRA GOMES","dadosPessoaFisica":{"grupoProfissao":"DIT-A","cicloVacinal":"0","temDependentes":false,"profissao":"2111-05","tipoContrato":"VOCE","tempoGarantiaRenda":"48","fumante":false,"dataNascimento":"1957-04-25T00:00:00.000Z","sexo":"FEMININO","regimeTrabalho":"","numeroCpf":"206894460","digitoCpf":"04","estadoCivil":"SOLTEIRO","nacionalidade":"BRASILEIRA","tipoDocIdentificacao":"rg","docIdentificacao":"02222","orgaoExpedidor":"SSP","dataExpedicao":"2013-04-01","idade":65,"paisResidente":"Brasil","DataUltimaVacina":null,"paisDeOrigem":"","resideBrasil":true},"email":"e@gmail.com","rendaMensal":"4000.00","telefones":[{"tipoTelefone":"CEL","numeroTelefone":"00000000","dddTelefone":"00"},{"tipoTelefone":"RES","numeroTelefone":"000000000","dddTelefone":"00"}],"melhorPeriodo":"I","pessoaExpostaPoliticamente":"Nao"},"numero":1,"coberturas":[{"franquia":null,"sigla":"BAS","moeda":"BRL","limitemaximo":150000,"caracteristica":"Principal","valor":30000,"tipoprotecao":null,"caracteristicaespecialvalor":null,"limiteminimo":30000,"caracteristicaespecialtipo":null},{"franquia":null,"sigla":"IPTA","moeda":"BRL","limitemaximo":150000,"caracteristica":"Adicional","valor":30000,"tipoprotecao":null,"caracteristicaespecialvalor":null,"limiteminimo":30000,"caracteristicaespecialtipo":null},{"franquia":null,"sigla":"AFI","moeda":"BRL","limitemaximo":5000,"caracteristica":"Adicional","valor":5000,"tipoprotecao":"Família","caracteristicaespecialvalor":null,"limiteminimo":5000,"caracteristicaespecialtipo":null}],"empresaQueTrabalha":"","ramoAtividade":"","ocupacaoProfissionalPrincipal":"2111-05","faixaRenda":"","formaTrabalho":"","beneficiarios":[{"nome":null,"cpf":null,"nascimento":null,"grauParentesco":null,"percentualIndenizacao":100,"sexoBeneficiario":null,"tipoBeneficiario":"Herdeiros legais, conforme artigo 792 do código civil."}],"responsavelFinanceiro":true,"questionario":{"idquestionario":null,"respostas":[]}}],"nome":"","qtdeVidas":1}],"pessoa":{"tipo":"FIS","enderecos":[{"tipoEndereco":"RESIDENCIAL","logradouro":"das Boas Noites","numeroLogradouro":null,"bairro":"Vila Regina ( Zona Leste)","cidade":"São Paulo","uf":"SP","cep":"08225","complemento":"","complementoCep":"180"},{"tipoEndereco":"COMERCIAL","logradouro":"","numeroLogradouro":null,"bairro":"","cidade":"","uf":"","cep":"","complemento":""}],"nome":"EMILIA SIRLEI TUCHTENHAGEN DE OLIVEIRA GOMES","dadosPessoaFisica":{"grupoProfissao":"DIT-A","cicloVacinal":"0","temDependentes":false,"profissao":"2111-05","tipoContrato":"VOCE","tempoGarantiaRenda":"48","fumante":false,"dataNascimento":"1957-04-25T00:00:00.000Z","sexo":"FEMININO","regimeTrabalho":"","numeroCpf":"206894460","digitoCpf":"04","estadoCivil":"SOLTEIRO","nacionalidade":"BRASILEIRA","tipoDocIdentificacao":"rg","docIdentificacao":"02222","orgaoExpedidor":"SSP","dataExpedicao":"2013-04-01","idade":65,"paisResidente":"Brasil","DataUltimaVacina":null,"paisDeOrigem":"","resideBrasil":true},"email":"e@gmail.com","rendaMensal":"4000.00","telefones":[{"tipoTelefone":"CEL","numeroTelefone":"00000000","dddTelefone":"00"},{"tipoTelefone":"RES","numeroTelefone":"000000000","dddTelefone":"00"}],"melhorPeriodo":"I","pessoaExpostaPoliticamente":"Nao"},"dadosPagamento":{"opcao":2,"codigoFormaPagamento":62,"quantidadeParcelas":1,"cartaoCredito":null,"dadosBancarios":null,"formaPagamento":{"codigo":62,"descricao":"Cartão de Crédito","idFormaPagamento":"a0aL0000007ApN6IAK","planoParcelamento":{"idPlanoParcelamento":"1","quantidadeParcelas":1}},"responsavelPagamento":null,"tipoResponsavelPagamento":"CON","vencimentoDemaisParcelas":"A cada 30 dias","vigenciaInicial":null,"dadosCartaoCredito":{"cartaoPorto":false,"cvv":"naoInformado","nome":"Francis Liu","numero":"5448280000000007","validade":"012028","bandeira":"mastercard"},"responsavelFinanceiro":true}}],"canalDistribuicao":"COR","remuneracoes":[{"percentual":5,"tipoRemuneracao":"COR","favorecidos":[{"papel":"COR","participacao":100,"corretorLider":true,"susep":"P5005J","pessoa":null,"antecipaComissao":false}]}],"segmento":"Individual","tempoRendaProtegida":"48","dependentesFinanceiros":false,"formaReceberApolice":"DIGITAL","termoGuarda":false,"termoResponsabilidade":true,"assinaturaEletronica":true}]}';       

        Test.startTest();   
        ConsultarVidaOnBO consultaVidaOnBO = new ConsultarVidaOnBO();                 
        try {
            consultaVidaOnBO.ConsultarVidaOnBO(jsonTransmissao);
        } catch(Exception e) {            
            System.assert(e.getMessage().contains('Erro'));
        }                
        Test.stopTest();  
    }    

    @istest 
    static void testSchedule(){
        
        String payloadReturn = '{"servico":"/vidaon/gravar-cpf-vidaon","status":"PROCESSADO","codigoprocessamento":0,"dataexecucao":"2022-08-01T19:11:40.641Z","descricao":"Item não modificado!","dados":[{"numeroCpf":"518.179.180-87","numeroApolice":"1-1-1391-000019437-0","statusApolice":"Emitido","numeroProposta":"18-00038023","statusProposta":"Contratada"}]}';
        Test.setMock(HttpCalloutMock.class, new MockHttpResponse(payloadReturn, 200, 'OK'));

        String dadosContrato = '{'
        +    '"contratos": ['
        +      '{'
        +        '"numeroCpf": "518.179.180-87",'
        +        '"numeroApolice": "1-1-1391-000019437-0"'
        +        '"statusApolice": "Emitido",'
        +        '"tipoContrato": "Novo",'
        +      '}'
        +    ']'
        +  '}';

        String jsonList = JSON.serialize(dadosContrato);

        Test.StartTest();
        GravarVidaOnSchedule schd = new GravarVidaOnSchedule();
        String scheduleTest = '0 0 23 * * ?';
        System.schedule('Teste de Job', scheduleTest, schd);
        Test.stopTest();
    }
}