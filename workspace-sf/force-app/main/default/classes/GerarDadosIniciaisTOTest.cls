//II-150 - INICIO
@isTest
private class GerarDadosIniciaisTOTest {

    @TestSetup
    static void makeData(){

        Account contaTeste = TestDataFactory.gerarConta();
        DadosCorretor__c dadosCorretor = TestDataFactory.gerarDadosCorretor(contaTeste);
        RamoSeguro__c ramoSegurado = TestDataFactory.gerarRamoSeguro(contaTeste);

        ContadorCodigo__c contCod = new ContadorCodigo__c(
            Name = 'ProdutoTecnico',
            Numero__c = 53
        );

        insert contCod;

        Product2 produtoTec = TestDataFactory.gerarProdutoTecnico();
        produtoTec.Status__c = 'Ativo';
        update produtoTec;

        Product2 produtoCom = TestDataFactory.gerarProdutoComericial(produtoTec);
        produtoCom.Status__c ='ativo';
        update produtoCom;

        CanalDistribuicao__c canalDistribuicao = TestDataFactory.gerarCanalDistribuicao();
        canalDistribuicao.Status__c = 'Ativo';
        update canalDistribuicao;

        Opportunity opp = TestDataFactory.gerarOrcamentoObjeto(contaTeste, produtoCom, canalDistribuicao);
        Modalidade__c modalidade = TestDataFactory.gerarModalidade(ramoSegurado);
        FormaPagamento__c formaPagamento = TestDataFactory.gerarFormaPagamento();
        formaPagamento.Codigo__c = '00866532';
        update formaPagamento;

        Quote cotacao = TestDataFactory.gerarPropostaObjeto(produtoCom, ramoSegurado, contaTeste, dadosCorretor, opp, modalidade);
        Contract contrato = TestDataFactory.gerarContratoObjeto(produtoCom, ramoSegurado, contaTeste, dadosCorretor, cotacao);
		contrato.Tipo__c = 'Novo';
		update contrato;

        PlanoParcelamento__c planoParcelamento = TestDataFactory.gerarPlanoParcelamento(formaPagamento.Id);

        InformacaoBancaria__c informacaoBancaria = TestDataFactory.gerarInformacaoBancaria(contaTeste);
        informacaoBancaria.Agencia__c = '2810-1';
        informacaoBancaria.Banco__c = '341';
        informacaoBancaria.NumeroConta__c = '1002766';
        informacaoBancaria.Digito__c = '7';
        informacaoBancaria.TipoPessoa__c = 'fisica';
        update informacaoBancaria;

        ContratanteContrato__c contratanteContrato = TestDataFactory.gerarContratanteContrato(contrato, contaTeste, contaTeste);
        contratanteContrato.CpfCnpj__c = '172.352.520-06';
        contratanteContrato.DiasPagamento__c = String.valueOf(System.today().addDays(20));
        contratanteContrato.TipoResponsavelPagamento__c = 'SEG';
        contratanteContrato.VencimentoPrimeiraParcela__c = System.today().addDays(30);
        contratanteContrato.VencimentoDemaisParcelas__c = 'A cada 30 dias';
        contratanteContrato.FormaPagamento__c = formaPagamento.Id;
        contratanteContrato.FormaPagamento__r = formaPagamento;
        contratanteContrato.PlanoParcelamento__c = planoParcelamento.Id;
        contratanteContrato.QuantidadeParcelas__c = 12;
        contratanteContrato.InformacaoBancaria__r = informacaoBancaria;
        contratanteContrato.InformacaoBancaria__c = informacaoBancaria.Id;
        
        update contratanteContrato;
    }

    @isTest
    static void gerarDIVersaoCalcTest() {
  
        GerarDadosIniciaisTO gdi = new GerarDadosIniciaisTO();
        gdi.versaoCalculo = new GerarDadosIniciaisTO.VersaoCalculoTO();
        gdi.versaoCalculo.descontoAgravo = -15.00;
        gdi.versaoCalculo.tipo = 'FPG';
        gdi.versaoCalculo.opcao = 1;

        ContratanteContrato__c cc =  new ContratanteContrato__c(
            Tipo__c = 'Principal',
            NomeContratante__c = 'Teste'
        );
        List<ContratanteContrato__c> lcc = new List<ContratanteContrato__c>();
        lcc.add(cc);

        gdi.versoesCalculo = new List<GerarDadosIniciaisTO.VersaoCalculoTO>();
        gdi.versaoCalculo.ListDescontoAgravo = lcc;

        gdi.versoesCalculo.add(gdi.versaoCalculo);
    }

    @isTest
    static void gerarDIOfertaTest() {
  
        GerarDadosIniciaisTO.RetornoTO gdir = new GerarDadosIniciaisTO.RetornoTO();
        gdir.ofertas = new List<GerarDadosIniciaisTO.OfertaTO>();

        GerarDadosIniciaisTO.OfertaTO oferta = new GerarDadosIniciaisTO.OfertaTO();
        oferta.regra = new GerarDadosIniciaisTO.RegraTO();
        oferta.regra.versoesCalculo = new List<GerarDadosIniciaisTO.VersaoCalculoTO>();

        GerarDadosIniciaisTO gdi = new GerarDadosIniciaisTO();
        gdi.versaoCalculo = new GerarDadosIniciaisTO.VersaoCalculoTO();
        gdi.versaoCalculo.tipo = 'FPG';
        gdi.versaoCalculo.opcao = 3;
        gdi.versaoCalculo.descontoAgravo = -10.00;

        oferta.regra.versoesCalculo.add(gdi.versaoCalculo);

        oferta.precificacao = new GerarDadosIniciaisTO.PrecificacaoTO();
        GerarDadosIniciaisTO.PremioTO premio = new GerarDadosIniciaisTO.PremioTO();

        premio.minimo = 10.0;
        premio.comercial = 10.0;
        premio.total = 10.0;
        premio.puro = 10.0;
        premio.integral = 1;
        premio.premioPago = 1;
        premio.puroCarregado = 1;
        premio.descontoAgravo = new List<GerarDadosIniciaisTO.DescontoAgravoTO>();

        oferta.precificacao.premio = premio;

        oferta.precificacao.descontoAgravo = new List<GerarDadosIniciaisTO.DescontoAgravoTO>();
        GerarDadosIniciaisTO.DescontoAgravoTO descAgrav = new GerarDadosIniciaisTO.DescontoAgravoTO();
        descAgrav.monetario = 1;
        descAgrav.percentual = 10;
        descAgrav.tipo = 'FPG';

        oferta.precificacao.descontoAgravo.add(descAgrav);

        oferta.precificacao.coberturas = new List<GerarDadosIniciaisTO.CoberturaTO>();
        GerarDadosIniciaisTO.CoberturaTO cobertura = new GerarDadosIniciaisTO.CoberturaTO();
        cobertura.sigla = 'BLA';
        cobertura.capitalContratacao = 10;
        cobertura.descontoAgravo = new List<GerarDadosIniciaisTO.DescontoAgravoTO>();
        cobertura.franquia = 't';
        cobertura.iof = 1.5;
        cobertura.premio = premio;
        cobertura.quantidade = 1;
        cobertura.unidade = 't';
        cobertura.valor = 1;

        cobertura.taxa = new GerarDadosIniciaisTO.TaxaTO();
        cobertura.taxa.comercial = 1;
        cobertura.taxa.pura = 0;
        cobertura.taxa.total = 1;        

        oferta.precificacao.coberturas.add(cobertura);

        oferta.precificacao.contratantes = new List<GerarDadosIniciaisTO.ContratanteTO>();
        GerarDadosIniciaisTO.ContratanteTO ctt = new GerarDadosIniciaisTO.ContratanteTO();
        
        ctt.dadosPagamento = new GerarDadosIniciaisTO.DadosPagamentoTO();
        ctt.dadosPagamento.codigo = '1';
        ctt.dadosPagamento.codigoFormaPagamento = 1;
        ctt.dadosPagamento.codigoMeioRecebimento = '1';
        ctt.dadosPagamento.dadosBancarios = new EmissaoTO.DadosBancarioTO();

        ctt.dadosPagamento.dadosBancarios.agencia = '1235';
        ctt.dadosPagamento.dadosBancarios.banco = 'Banco do Brasil';
        ctt.dadosPagamento.dadosBancarios.conta = '222761';
        ctt.dadosPagamento.dadosBancarios.cpf = '172.352.520-06';
        ctt.dadosPagamento.dadosBancarios.digitoAgencia = '0';
        ctt.dadosPagamento.dadosBancarios.digitoConta = '4';
        ctt.dadosPagamento.dadosBancarios.tipoPessoa = 'PF';
        ctt.descontoAgravo = new List<GerarDadosIniciaisTO.DescontoAgravoTO>();
        ctt.premio = new GerarDadosIniciaisTO.PremioTO();
        
        ctt.grupos = new List<GerarDadosIniciaisTO.GrupoTO>();
        GerarDadosIniciaisTO.GrupoTO grupo = new GerarDadosIniciaisTO.GrupoTO();

        grupo.descontoAgravo = new List<GerarDadosIniciaisTO.DescontoAgravoTO>();
        grupo.iof = 1;
        grupo.nome = 'Pleura';
        grupo.numero = 1;
        grupo.qtdeVidas = 1;
        grupo.segurados = new List<GerarDadosIniciaisTO.SeguradoTO>();
        grupo.premio = new GerarDadosIniciaisTO.PremioTO();

        GerarDadosIniciaisTO.SeguradoTO seg = new GerarDadosIniciaisTO.SeguradoTO();
        seg.coberturas = new List<GerarDadosIniciaisTO.CoberturaTO>();
        seg.descontoAgravo = new List<GerarDadosIniciaisTO.DescontoAgravoTO>();
        seg.iof = 1;
        seg.numero = 1;

        GerarDadosIniciaisTO.PessoaTO pessoa = new GerarDadosIniciaisTO.PessoaTO();
        pessoa.dadosPessoaFisica = new GerarDadosIniciaisTO.DadosPessoaFisicaTO();
        pessoa.dadosPessoaFisica = new GerarDadosIniciaisTO.DadosPessoaFisicaTO(false);
        pessoa.dadosPessoaFisica.dataExpedicao = System.today().addDays(-20);
        pessoa.dadosPessoaFisica.dataNascimento = String.valueOf(System.today().addDays(-20));
        pessoa.dadosPessoaFisica.digitoCpf = '1';
        pessoa.dadosPessoaFisica.docIdentificacao = 'RG';
        pessoa.dadosPessoaFisica.estadoCivil = 'Casado';
        pessoa.dadosPessoaFisica.fumante = false;
        pessoa.dadosPessoaFisica.grupoProfissao = 't';
        pessoa.dadosPessoaFisica.nacionalidade = 'b';
        pessoa.dadosPessoaFisica.numeroCpf = '3256987258';
        pessoa.dadosPessoaFisica.orgaoExpedidor = 'SSP';
        pessoa.dadosPessoaFisica.paisDeOrigem = 'Brasil';
        pessoa.dadosPessoaFisica.paisResidente = 'Brasil';
        pessoa.dadosPessoaFisica.profissao = 't';
        pessoa.dadosPessoaFisica.regimeTrabalho = 'CLT';
        pessoa.dadosPessoaFisica.resideBrasil = true;
        pessoa.dadosPessoaFisica.sexo = 'Masc';
        pessoa.dadosPessoaFisica.tipoDocIdentificacao = 'R';
        pessoa.enderecos = new List<EmissaoTO.EnderecoTO>();


        ContratanteContrato__c cc1 =  new ContratanteContrato__c(
            Tipo__c = 'Principal',
            NomeContratante__c = 'Teste',
            CpfCnpj__c = '172.352.520-06'
        );

        ContratanteContrato__c cc2 =  new ContratanteContrato__c(
            Tipo__c = 'Principal',
            NomeContratante__c = 'Teste'
        );

        pessoa = new GerarDadosIniciaisTO.PessoaTO(cc1);

        pessoa = new GerarDadosIniciaisTO.PessoaTO(cc2);


        seg.pessoa = pessoa;
        seg.pessoa.email = 'teste@teste.com';
        seg.pessoa.melhorPeriodo = 'Manha';
        seg.pessoa.nome = 'Pleura';
        seg.pessoa.pessoaExpostaPoliticamente = 'P';
        seg.pessoa.rendaMensal = 20000;

        seg.pessoa.telefones = new List<EmissaoTO.TelefoneTO>();
        EmissaoTO.TelefoneTO telefone = new EmissaoTO.TelefoneTO();
        telefone.dddTelefone = '11';
        telefone.numeroTelefone = '3228-9126';
        telefone.tipoTelefone = 'Fixo';

        seg.pessoa.telefones.add(telefone);

        seg.pessoa.tipo = 'T';
        seg.premio = new GerarDadosIniciaisTO.PremioTO();
        seg.taxa = new GerarDadosIniciaisTO.TaxaTO();
        seg.beneficiarios = new List<GerarDadosIniciaisTO.BeneficiarioTO>();
        
        grupo.segurados.add(seg);

        grupo.taxa = new GerarDadosIniciaisTO.TaxaTO();

        ctt.grupos.add(grupo);

        ctt.iof = 1;
        ctt.numero = 1;
        ctt.pessoa = new GerarDadosIniciaisTO.PessoaTO();
        ctt.premio = premio;
        ctt.taxa = new GerarDadosIniciaisTO.TaxaTO();
        ctt.tipo = 'T';

        oferta.precificacao.contratantes.add(ctt);

        oferta.precificacao.custoDeApolice = 1;
        oferta.precificacao.descontoAgravo = new List<GerarDadosIniciaisTO.DescontoAgravoTO>();
        oferta.precificacao.encargos = 1;
        oferta.precificacao.iof = 1;
        oferta.precificacao.juros = 1;
        oferta.precificacao.premio = new GerarDadosIniciaisTO.PremioTO();
        
        oferta.moedasCotacao = new GerarDadosIniciaisTO.MoedasCotacaoTO();
        oferta.moedasCotacao.dataCalculo = System.today();
        oferta.moedasCotacao.dataInicio = System.today().addDays(1);
        oferta.moedasCotacao.moedasGarantias = new Set<String>();

        oferta.orcamento = new GerarDadosIniciaisTO.OrcamentoRetornoTO();
        oferta.orcamento.vigenciaInicial = System.today();
        oferta.orcamento.canalDistribuicao = 't';
        oferta.orcamento.contratantes = new LIst<GerarDadosIniciaisTO.ContratanteTO>();
        oferta.orcamento.contratoOriginal = new GerarDadosIniciaisTO.ContratoOriginalRetornoTO();

        oferta.orcamento.contratoOriginal.apolice = '00000';
        oferta.orcamento.contratoOriginal.beneficiarios = new List<GerarDadosIniciaisTO.BeneficiarioTO>();
        oferta.orcamento.contratoOriginal.sucursal = '1';
        oferta.orcamento.contratoOriginal.ramo = '1';
        oferta.orcamento.contratoOriginal.tipoSeguro = 't';
        oferta.orcamento.contratoOriginal.tarifa = '1';
        oferta.orcamento.contratoOriginal.vigenciaInicial = String.valueOf(System.today());
        oferta.orcamento.contratoOriginal.vigenciaFinal = String.valueOf(System.today().addDays(365));

        oferta.orcamento.contratoOriginal.remuneracoes = new List<GerarDadosIniciaisTO.RemuneracaoContratoTO>();
        GerarDadosIniciaisTO.RemuneracaoContratoTO rem = new GerarDadosIniciaisTO.RemuneracaoContratoTO();
        rem.favorecidos = new List<GerarDadosIniciaisTO.FavorecidosTO>();
        rem.percentual = 1;
        rem.tipoRemuneracao = 't';
        
        GerarDadosIniciaisTO.FavorecidosTO fav = new GerarDadosIniciaisTO.FavorecidosTO();
        fav.antecipacaoComissao = false;
        fav.corretorLider = true;
        fav.papel = 'n';
        fav.participacao = 1;
        fav.pessoa = new GerarDadosIniciaisTO.PessoaTO();
        fav.susep = 'COLJ';

        oferta.orcamento.contratoOriginal.segurados = new List<GerarDadosIniciaisTO.Segurado_NovoTO>();
        GerarDadosIniciaisTO.Segurado_NovoTO segNv = new GerarDadosIniciaisTO.Segurado_NovoTO();
        segNv.beneficiarios = new List<GerarDadosIniciaisTO.BeneficiarioTO>();
        segNv.dadosPessoaFisica = new GerarDadosIniciaisTO.DadosPessoaFisicaTO();
        segNv.email = 't@t.com';

        segNv.enderecos = new List<EmissaoTO.EnderecoTO>();
        EmissaoTO.EnderecoTO endereco = new EmissaoTO.EnderecoTO();
        endereco.bairro = 'b';
        endereco.cep = '004489-225';
        endereco.cidade = 's';
        endereco.complemento = 'n';
        endereco.complementoCep = 'n';
        endereco.logradouro = 'l';
        endereco.numeroLogradouro = '0';
        endereco.paisResidencia = 'Brasil';
        endereco.tipoEndereco = 'Residencial';
        endereco.tipoLogradouro = 'l';
        endereco.uf = 'SP';

        segNv.nome = 'Pleura';
        segNv.pessoaExpostaPoliticamente = 'n';
        segNv.rendaMensal = '100000';
        segNv.telefones = new List<EmissaoTO.TelefoneTO>();

        oferta.orcamento.contratoOriginal.versoesCalculos = new List<GerarDadosIniciaisTO.VersaoCalculoTO>();

        oferta.orcamento.contratoOriginal.retornosCalculoOriginal = new List<GerarDadosIniciaisTO.RetornosCalculoOriginalTO>();
        GerarDadosIniciaisTO.RetornosCalculoOriginalTO rco = new GerarDadosIniciaisTO.RetornosCalculoOriginalTO();
        rco.dlls = new List<String>();
        rco.opcao = 0;
        rco.precificacao = new GerarDadosIniciaisTO.PrecificacaoTO();
        rco.tarifa = '1';


        GerarDadosIniciaisTO.BeneficiarioTO ben = new GerarDadosIniciaisTO.BeneficiarioTO();
        ben.cpf = '172.352.520-06';
        ben.grauParentesco = 't';
        ben.grauParentescoOutros = 'n';
        ben.imprimirCertificado = false;
        ben.motivoSemCpfCnpj = 'n';
        ben.nascimento = System.today().addYears(-20);
        ben.nome = 'Pleura';
        ben.participacao = 1;
        ben.percentualIndenizacao = 10;
        ben.pessoa = new GerarDadosIniciaisTO.PessoaTO();
        ben.sexoBeneficiario = 'Masc';
        ben.tipoBeneficiario = 'T';

        oferta.orcamento.contratoOriginal.beneficiarios.add(ben);

        oferta.orcamento.contratoOriginal.coberturas = new List<GerarDadosIniciaisTO.CoberturaTO>();
        oferta.orcamento.contratoOriginal.codigoProdutoVida = 'VI';
        oferta.orcamento.contratoOriginal.contratantes = new List<GerarDadosIniciaisTO.ContratanteTO>();
        oferta.orcamento.contratoOriginal.dadosPagamento = new GerarDadosIniciaisTO.DadosPagamentoTO();

        ContratanteContrato__c cc = getContratanteContrato();

        oferta.orcamento.contratoOriginal.dadosPagamento = new GerarDadosIniciaisTO.DadosPagamentoTO(cc);

        oferta.orcamento.contratoOriginal.dataCalculo = System.today();
        oferta.orcamento.contratoOriginal.empresa = 'E';
        oferta.orcamento.contratoOriginal.endosso = '0';
        oferta.orcamento.contratoOriginal.numeroOrcamento = 164315;

        oferta.orcamento.contratoOriginal.precificacao = new GerarDadosIniciaisTO.PrecificacaoContratoOriginalTO();
        oferta.orcamento.contratoOriginal.precificacao.coberturas = new List<GerarDadosIniciaisTO.CoberturaTO>();
        oferta.orcamento.contratoOriginal.precificacao.contratantes = new List<GerarDadosIniciaisTO.ContratanteTO>();
        oferta.orcamento.contratoOriginal.precificacao.custoDeApolice = 1;
        oferta.orcamento.contratoOriginal.precificacao.descontoAgravo = new List<GerarDadosIniciaisTO.DescontoAgravoTO>();
        oferta.orcamento.contratoOriginal.precificacao.encargos = 1;
        oferta.orcamento.contratoOriginal.precificacao.iof = 1;
        oferta.orcamento.contratoOriginal.precificacao.juros = 1;
        oferta.orcamento.contratoOriginal.precificacao.premio = new GerarDadosIniciaisTO.PremioTO();

        oferta.orcamento.contratoOriginal.qtdDiasVigencia = 365;
        oferta.orcamento.dataEndosso = String.valueOf(System.today().addDays(3));
        oferta.orcamento.numeroOferta = '164564';
        oferta.orcamento.numeroOrcamento = '5465465';
        oferta.orcamento.ordemPortal = 1;
        oferta.orcamento.qtdDiasVigencia = 362;
        oferta.orcamento.ramoSeguro = '1';

        oferta.orcamento.tiposEndosso = new GerarDadosIniciaisTO.EndossoTO();
        oferta.orcamento.tiposEndosso.cad = false;

        oferta.orcamento.vigenciaFinal = System.today();
        oferta.orcamento.vigenciaFinal = System.today().addDays(365);
    }

    @isTest
    static void gerarDIOrcamentoTest(){

        GerarDadosIniciaisTO.PayloadTO payload = new GerarDadosIniciaisTO.PayloadTO();
        payload.orcamentos = new List<GerarDadosIniciaisTO.OrcamentoTO>();

        GerarDadosIniciaisTO.OrcamentoTO orcamento = new GerarDadosIniciaisTO.OrcamentoTO();
        orcamento.canalDistribuicao = 't';
        orcamento.cicloVacinal = 't';
        orcamento.codigoProdutoVida = 't';

        orcamento.contratantes = new List<GerarDadosIniciaisTO.ContratanteTO>();
        orcamento.contratoOriginal = new GerarDadosIniciaisTO.ContratoOriginalEntradaTO();
        orcamento.contratoOriginal.apolice = '12345';
        orcamento.contratoOriginal.empresa = '1';
        orcamento.contratoOriginal.endosso = '0';
        orcamento.contratoOriginal.premioPago = 0;
        orcamento.contratoOriginal.ramo = '1';
        orcamento.contratoOriginal.sucursal = '1';

        orcamento.Cupom = 'c';
        orcamento.dataCalculo = System.today();
        orcamento.dataEndosso = String.valueOf(System.today().addDays(1));
        orcamento.idContratoRenovado = 'x';
        orcamento.idProdutoSf = 'x';
        orcamento.meioComercializacao = 't';
        orcamento.numeroOferta = '12345';
        orcamento.ordemPortal = 1;
        orcamento.premioPago = 0;
        orcamento.tipoSeguro = 't';
        orcamento.vigenciaFinal = System.today().addDays(365);
        orcamento.vigenciaInicial = System.today();        
    }

    private static ContratanteContrato__c getContratanteContrato(){
        return [
            SELECT 
                Id,
                CpfCnpj__c,
                FormaPagamento__r.Codigo__c,
                FormaPagamento__r.Name,
                DiasPagamento__c,
                TipoResponsavelPagamento__c,
                VencimentoPrimeiraParcela__c,
                PlanoParcelamento__c,
                VigenciaInicial__c,
                VencimentoDemaisParcelas__c,
                PlanoParcelamento__r.CodigoMeioRecebimento__c,
                QuantidadeParcelas__c,
                ResponsavelPagamento__c,
                Conta__c,
                InformacaoBancaria__c,
                InformacaoBancaria__r.Banco__c,
                InformacaoBancaria__r.Agencia__c,
                InformacaoBancaria__r.NumeroConta__c,
                InformacaoBancaria__r.Digito__c,
                InformacaoBancaria__r.TipoPessoa__c,
                CartaoCredito__c
            FROM 
                ContratanteContrato__c
            LIMIT 1
        ]; 
    }

    @isTest 
    static void validarAgenciaSemDig(){

        ContratanteContrato__c cc = getContratanteContrato();
        cc.InformacaoBancaria__r.Agencia__c = '2810';
        update cc;

        GerarDadosIniciaisTO.DadosPagamentoTO dadosPgto = new GerarDadosIniciaisTO.DadosPagamentoTO(cc);

        String agencia = dadosPgto.dadosBancarios.agencia;
        String digito = dadosPgto.dadosBancarios.digitoAgencia;
        String agenciaComDigito = agencia + digito;

        System.assertEquals(5, agenciaComDigito.length(), 'Success');
    }
}
//II-150 - FIM