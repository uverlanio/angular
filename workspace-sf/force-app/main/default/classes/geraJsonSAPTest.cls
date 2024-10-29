@isTest
private class geraJsonSAPTest {
    @isTest
    static void testGeraJsonSAP() {
       
        GeraJsonSAP.Requisitante requisitante = new GeraJsonSAP.Requisitante();
        requisitante.tipoUsuario = 'Tipo de Usuário';
        requisitante.codigoEmpresaMatricula = 'Código Empresa/Matrícula';
        requisitante.matriculaResponsavel = 'Matrícula Responsável';

        GeraJsonSAP.Endereco endereco = new GeraJsonSAP.Endereco();
        endereco.endereco = 'Endereço';
        endereco.complemento = 'Complemento';
        endereco.cidade = 'Cidade';
        endereco.numero = 'Número';
        endereco.bairro = 'Bairro';
        endereco.uf = 'UF';
        endereco.cep = 'CEP';
        endereco.pais = 'País';
        endereco.prefixoTelefone = 'Prefixo';
        endereco.telefone = 'Telefone';

        GeraJsonSAP.DadosBancarios dadosBancarios = new GeraJsonSAP.DadosBancarios();
        dadosBancarios.paisBanco = 'País do Banco';
        dadosBancarios.banco = 'Banco';
        dadosBancarios.agencia = 'Agência';
        dadosBancarios.digitoAgencia = 'Dígito Agência';
        dadosBancarios.contaCorrente = 'Conta Corrente';
        dadosBancarios.digitoContaCorrente = 'Dígito Conta Corrente';

        GeraJsonSAP.Fatura fatura = new GeraJsonSAP.Fatura();
        fatura.codigoSucursal = 'Código Sucursal';
        fatura.dataFatura = 'Data Fatura';
        fatura.montanteBruto = 'Montante Bruto';
        fatura.dataBaseCalculoVenc = 'Data Base Cálculo Vencimento';
        fatura.condicaoPagamento = 'Condição de Pagamento';
        fatura.categoriaNotaFiscal = 'Categoria Nota Fiscal';
        fatura.dadosBancarios = dadosBancarios;
        fatura.aliquotaISS = 'Aliquota ISS';
        fatura.numeroDocCompras = 'Número Documento Compras';

        GeraJsonSAP.Fornecedor fornecedor = new GeraJsonSAP.Fornecedor();
        fornecedor.origemDados = 'Origem Dados';
        fornecedor.nome = 'Nome Fornecedor';
        fornecedor.complementoNome = 'Complemento Nome';
        fornecedor.termoPequisa = 'Termo de Pesquisa';
        fornecedor.tipoPessoa = 'Tipo Pessoa';
        fornecedor.cpfCnpj = 'CPF/CNPJ';
        fornecedor.ordemCnpj = 'Ordem CNPJ';
        fornecedor.digitoCpfCnpj = 'Dígito CPF/CNPJ';
        fornecedor.email = 'Email';
        fornecedor.tipoParceiroNegocio = 'Tipo Parceiro de Negócio';
        fornecedor.endereco = endereco;
        fornecedor.tipoCategoriaCtaContrato = 'Tipo Categoria Cta Contrato';
        fornecedor.grupoPrevisaoTesouraria = 'Grupo Previsão Tesouraria';
        fornecedor.visaoCtaExterna = 'Visão Cta Externa';
        fornecedor.requisitante = requisitante;

        GeraJsonSAP.Itens item = new GeraJsonSAP.Itens();
        item.numeroParcela = 'Número Parcela';
        item.valorParcela = 'Valor Parcela';
        item.dataVencimento = 'Data Vencimento';
        item.formaPagamento = 'Forma de Pagamento';
        item.codigoSucursal = 'Código Sucursal';
        item.codigoMunicipio = 'Código Município';
        item.codigoRamoModalidade = 'Código Ramo Modalidade';
        item.centroCusto = 'Centro de Custo';
        item.codigoDespesa = 'Código Despesa';
        item.criterioOperacaoSub = 'Criterio Operação Sub';
        item.grupoPrevTesouraria = 'Grupo Previsão Tesouraria';
        item.bloqueioDocumento = 'Bloqueio Documento';
        item.descricaoOrdemPagamento = 'Descrição Ordem Pagamento';

        List<GeraJsonSAP.Itens> itens = new List<GeraJsonSAP.Itens>();
        itens.add(item);

        GeraJsonSAP.Ordempagamento ordempagamento = new GeraJsonSAP.Ordempagamento();
        ordempagamento.codigoOrigem = 'Código Origem';
        ordempagamento.empresa = 'Empresa';
        ordempagamento.moeda = 'Moeda';
        ordempagamento.numeroDocumento = 'Número Documento';
        ordempagamento.numeroSinistroAno = 'Número Sinistro/Ano';
        ordempagamento.localRiscoUF = 'Local Risco UF';
        ordempagamento.tipoUsuAprov = 'Tipo Usu Aprov';
        ordempagamento.codigoEmpMatAprov = 'Código Emp/Mat Aprov';
        ordempagamento.matriculaRespAprov = 'Matrícula Resp Aprov';
        ordempagamento.tipoUsuarioRequisitante = 'Tipo Usu Requisitante';
        ordempagamento.codigoEmpMatRequisitante = 'Código Emp/Mat Requisitante';
        ordempagamento.matriculaRespRequisitante = 'Matrícula Resp Requisitante';
        ordempagamento.dataAprovLegado = 'Data Aprov Legado';
        ordempagamento.dataContabil = 'Data Contábil';
        ordempagamento.indTributavel = 'Indicador Tributável';
        ordempagamento.categoriaContaContrato = 'Categoria Conta Contrato';
        ordempagamento.grupoPrevTesouraria = 'Grupo Previsão Tesouraria';
        ordempagamento.visaoContaExterna = 'Visão Conta Externa';
        ordempagamento.categoriaObjetoSeguro = 'Categoria Objeto Seguro';
        ordempagamento.numeroApolice = 'Número Apólice';
        ordempagamento.numeroProposta = 'Número Proposta';
        ordempagamento.numeroEndosso = 'Número Endosso';
        ordempagamento.dataVigenciaInicio = 'Data Vigência Início';
        ordempagamento.dataVigenciaFinal = 'Data Vigência Final';
        ordempagamento.susepCorretor = 'SUSEP Corretor';
        ordempagamento.dataCobertura = 'Data Cobertura';
        ordempagamento.dataEmissao = 'Data Emissão';
        ordempagamento.fornecedor = fornecedor;
        ordempagamento.fatura = fatura;
        ordempagamento.itens = itens;

        GeraJsonSAP geraJson = new GeraJsonSAP();
        geraJson.ordempagamento = ordempagamento;

        System.assertEquals('Código Origem', geraJson.ordempagamento.codigoOrigem);
        System.assertEquals('Empresa', geraJson.ordempagamento.empresa);
        System.assertEquals('Moeda', geraJson.ordempagamento.moeda);
        System.assertEquals('Número Documento', geraJson.ordempagamento.numeroDocumento);
        System.assertEquals('Número Sinistro/Ano', geraJson.ordempagamento.numeroSinistroAno);
        System.assertEquals('Local Risco UF', geraJson.ordempagamento.localRiscoUF);
        System.assertEquals('Tipo Usu Aprov', geraJson.ordempagamento.tipoUsuAprov);
        System.assertEquals('Código Emp/Mat Aprov', geraJson.ordempagamento.codigoEmpMatAprov);
        System.assertEquals('Matrícula Resp Aprov', geraJson.ordempagamento.matriculaRespAprov);
        System.assertEquals('Tipo Usu Requisitante', geraJson.ordempagamento.tipoUsuarioRequisitante);
        System.assertEquals('Código Emp/Mat Requisitante', geraJson.ordempagamento.codigoEmpMatRequisitante);
        System.assertEquals('Matrícula Resp Requisitante', geraJson.ordempagamento.matriculaRespRequisitante);
        System.assertEquals('Data Aprov Legado', geraJson.ordempagamento.dataAprovLegado);
        System.assertEquals('Data Contábil', geraJson.ordempagamento.dataContabil);
        System.assertEquals('Indicador Tributável', geraJson.ordempagamento.indTributavel);
        System.assertEquals('Categoria Conta Contrato', geraJson.ordempagamento.categoriaContaContrato);
        System.assertEquals('Grupo Previsão Tesouraria', geraJson.ordempagamento.grupoPrevTesouraria);
        System.assertEquals('Visão Conta Externa', geraJson.ordempagamento.visaoContaExterna);
        System.assertEquals('Categoria Objeto Seguro', geraJson.ordempagamento.categoriaObjetoSeguro);
        System.assertEquals('Número Apólice', geraJson.ordempagamento.numeroApolice);
        System.assertEquals('Número Proposta', geraJson.ordempagamento.numeroProposta);
        System.assertEquals('Número Endosso', geraJson.ordempagamento.numeroEndosso);
        System.assertEquals('Data Vigência Início', geraJson.ordempagamento.dataVigenciaInicio);
        System.assertEquals('Data Vigência Final', geraJson.ordempagamento.dataVigenciaFinal);
        System.assertEquals('SUSEP Corretor', geraJson.ordempagamento.susepCorretor);
        System.assertEquals('Data Cobertura', geraJson.ordempagamento.dataCobertura);
        System.assertEquals('Data Emissão', geraJson.ordempagamento.dataEmissao);
        System.assertEquals(fornecedor, geraJson.ordempagamento.fornecedor);
        System.assertEquals(fatura, geraJson.ordempagamento.fatura);
        System.assertEquals(itens, geraJson.ordempagamento.itens);
    }

}