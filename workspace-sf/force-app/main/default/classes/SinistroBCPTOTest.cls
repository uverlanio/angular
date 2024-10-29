// PLV-2015 Criação da classe
@IsTest
public class SinistroBCPTOTest {
    
@IsTest
static void SinistroBCPTOTest() {
    SinistroBCPTO BCPTO = new SinistroBCPTO();
    BCPTO.sucursal = 'teste';
    BCPTO.ramo = 'teste';
    BCPTO.apolice = 'teste';
    BCPTO.origemproposta = 'teste';
    BCPTO.numeroproposta = 'teste';

    BCPTO.adicionarPessoaProdutoRequest = new SinistroBCPTO.AdicionarPessoaProdutoRequestTO();

    BCPTO.adicionarPessoaProdutoRequest.codigoOrigemMovimento = 'test';
    BCPTO.adicionarPessoaProdutoRequest.grupoXML = 'test';
    BCPTO.adicionarPessoaProdutoRequest.dataHoraMoviento = 'test';
    BCPTO.adicionarPessoaProdutoRequest.numeroSequenciaCarga = 'test';
    BCPTO.adicionarPessoaProdutoRequest.dadosRastreamento = new SinistroBCPTO.DadosRastreamentoTO();
    BCPTO.adicionarPessoaProdutoRequest.pessoaProdutoEBO = new SinistroBCPTO.PessoaProdutoEBOTO();

    BCPTO.adicionarPessoaProdutoRequest.dadosRastreamento.codigoAcessoCanal = 'test';
    BCPTO.adicionarPessoaProdutoRequest.dadosRastreamento.codigoOrigemMovimento = 'test';
    BCPTO.adicionarPessoaProdutoRequest.dadosRastreamento.codigoServico = 'test';
    BCPTO.adicionarPessoaProdutoRequest.dadosRastreamento.codigoTipoMeioAcessoCanal = 'test';
    BCPTO.adicionarPessoaProdutoRequest.dadosRastreamento.descricaoProtocoloInternet = 'test';
    BCPTO.adicionarPessoaProdutoRequest.dadosRastreamento.numeroSessaoServico = 'test';
    BCPTO.adicionarPessoaProdutoRequest.dadosRastreamento.textoMeioAcesso = 'test';
    BCPTO.adicionarPessoaProdutoRequest.dadosRastreamento.timeStampControleServico = 'test';

    SinistroBCPTO.PessoaProdutoEBOTO pesProd = BCPTO.adicionarPessoaProdutoRequest.pessoaProdutoEBO;

    pesProd.id = 'teste';
    pesProd.nome = 'teste';
    pesProd.fonetica = 'teste';
    pesProd.primeiroNome = 'teste';
    pesProd.rne = 'teste';
    pesProd.cpfCnpjRel = 'teste';
    pesProd.dtIniRelac = 'teste';
    pesProd.titularDoc = 'teste';
    pesProd.grauRelac = 'teste';
    pesProd.mae = 'teste';
    pesProd.pai = 'teste';
    pesProd.papel = 'teste';
    pesProd.origem = 'teste';
    pesProd.tipoPessoa = 'teste';
    pesProd.tipoPrestador = 'teste';
    pesProd.tipoEmpresa = 'teste';
    pesProd.sexo = 'teste';
    pesProd.dtAbertura = 'teste';
    pesProd.dtInicio = 'teste';
    pesProd.dtFinal = 'teste';
    pesProd.nascimento = 'teste';
    pesProd.estCivil = 'teste';
    pesProd.estrcargo = 'teste';
    pesProd.cargo = 'teste';
    pesProd.cbo = 'teste';
    pesProd.cnae = 'teste';
    pesProd.situacao = 'teste';
    pesProd.codEmpresa = 'teste';
    pesProd.fxRendaCod = 'teste';
    pesProd.tpComunic = 'teste';
    pesProd.twitter = 'teste';
    pesProd.pessMatr = 'teste';
    pesProd.codPrestOrigem = 'teste';
    pesProd.susepPrinc = 'teste';
    pesProd.deficTip = 'teste';
    pesProd.flagPep = 'teste';
    pesProd.cargoPep = 'teste';
    pesProd.cpfNumPep = 'teste';
    pesProd.cpfOrdemPep = 'teste';
    pesProd.cpfDigPep = 'teste';
    pesProd.relacTipPep = 'teste';
    pesProd.faturamentoPJ = 'teste';
    pesProd.patrimonioLiquidoPJ = 'teste';
    pesProd.tipClassif = 'teste';
    pesProd.dtClassif = 'teste';
    pesProd.dtInclusao = 'teste';
    pesProd.dtAlteracao = 'teste';
    pesProd.grphHold = 'teste';
    pesProd.dtgrphHold = 'teste';
    pesProd.dtFlgPortal = 'teste';
    pesProd.vincPrestCNPJ = 'teste';
    pesProd.vincPrestOrdem = 'teste';
    pesProd.grvincPrestDigupoXML = 'teste';
    pesProd.bucflag = 'teste';
    pesProd.nomeSocial = 'teste';
    pesProd.codigoRacaHumana = 'teste';
    pesProd.flgTrtmtoPrtrMedico = 'teste';
    pesProd.dadoBiometrico = 'teste';
    pesProd.tipoReligiao = 'teste';
    pesProd.tipoOrntcaoSexual = 'teste';
    pesProd.filiacaoPartidaria = 'teste';
    pesProd.filiacaoSindical = 'teste';
    pesProd.foneTip = 'teste';
    pesProd.foneDDD = 'teste';
    pesProd.foneNum = 'teste';
    pesProd.pescod = 'teste';
    
    pesProd.cpfCnpj = new SinistroBCPTO.CpfCnpjTO();
    pesProd.emailPessoa = new List<SinistroBCPTO.EmailPessoaTO>();
    pesProd.emailDocumento = new List<SinistroBCPTO.EmailDocumentoTO>();
    pesProd.enderecoPessoa = new List<SinistroBCPTO.EnderecoPessoaTO>();
    pesProd.contatoPessoa = new List<SinistroBCPTO.ContatoPessoaTO>();
    pesProd.deficFlag = new SinistroBCPTO.DeficFlagTO();
    pesProd.flgEstrang = new SinistroBCPTO.FlgEstrangTO();
    pesProd.flgportal = new SinistroBCPTO.FlgportalTO();
    pesProd.documento = new SinistroBCPTO.DocumentoTO();
    pesProd.banco = new List<SinistroBCPTO.BancoTO>();
    pesProd.sistemasOrigensPessoa = new List<SinistroBCPTO.SistemasOrigensPessoaTO>();
    pesProd.pessoasSociais = new SinistroBCPTO.PessoasSociaisTO();
    
    SinistroBCPTO.CpfCnpjTO cpfCnpj = new SinistroBCPTO.CpfCnpjTO();
    cpfCnpj.numeroCnpjCpf = 'teste';
    cpfCnpj.ordemCnpj = 'teste';
    cpfCnpj.digitoCnpjCpf = 'teste';
    
    SinistroBCPTO.EmailPessoaTO emailPessoa = new SinistroBCPTO.EmailPessoaTO();
    emailPessoa.emailTip = 'teste';
    emailPessoa.email = 'teste';
    emailPessoa.emailFlgOpt = 'teste';
    emailPessoa.emailDtFlgOpt = 'teste';

    SinistroBCPTO.EnderecoPessoaTO enderecoPessoa = new SinistroBCPTO.EnderecoPessoaTO();
    enderecoPessoa.siglPais = 'teste';
    enderecoPessoa.finalidLogr = 'teste';
    enderecoPessoa.latitude = 'teste';
    enderecoPessoa.longitude = 'teste';
    enderecoPessoa.enderFlgOpt = 'teste';
    enderecoPessoa.enderDtFlgOpt = 'teste';
    enderecoPessoa.enderecoCompleto = new SinistroBCPTO.EnderecoCompletoTO();
    
    SinistroBCPTO.EnderecoCompletoTO endereco = new SinistroBCPTO.EnderecoCompletoTO();
    endereco.tipoLogradouro = 'teste';
    endereco.logradouro = 'teste';
    endereco.numeroLogradouro = 'teste';
    endereco.complemento = 'teste';
    endereco.bairro = 'teste';
    endereco.cidade = 'teste';
    endereco.uf = 'teste';
    endereco.cep = 'teste';
    endereco.complementoCep = 'teste';
    endereco.numeroSequencia = 'teste';
    endereco.codigoFinalidadeLogradouro = 'teste';
    endereco.siglaTipoLogradouro = 'teste';
    endereco.descricaoPosicaoLogradouro = 'teste';
    endereco.numeroCepComplemento = 'teste';
    endereco.siglaPais = 'teste';
    endereco.numeroLatitude = 'teste';
    endereco.numeroLongitude = 'teste';
    endereco.flagAutorizacaoPropaganda = 'teste';
    endereco.dataAutorizacaoPropaganda = 'teste';
    endereco.codigoOrigemMovimento = 'teste';
    endereco.nomeOrigemMovimento = 'teste';
    endereco.dataAtualizacao = 'teste';
    endereco.flagNivelConfiancaEnderecoAtingido = 'teste';
    endereco.flagNivelConfiancaLocalizacaoAtingido = 'teste';
    
    SinistroBCPTO.ContatoPessoaTO contatoPessoa = new SinistroBCPTO.ContatoPessoaTO();
    contatoPessoa.foneTip = 'teste';
    contatoPessoa.foneDDI = 'teste';
    contatoPessoa.foneDDD = 'teste';
    contatoPessoa.foneNum = 'teste';
    contatoPessoa.foneFlgOpt = 'teste';
    contatoPessoa.foneDtFlgOpt = 'teste';
    
    SinistroBCPTO.DeficFlagTO deficFlag = new SinistroBCPTO.DeficFlagTO();
    deficFlag.flagOpcao = 'teste';
    
    SinistroBCPTO.FlgEstrangTO flgEstrang = new SinistroBCPTO.FlgEstrangTO();
    flgEstrang.flagOpcao = 'teste';
    
    SinistroBCPTO.FlgportalTO flgportal = new SinistroBCPTO.FlgportalTO();
    flgportal.flagOpcao = 'teste';
    
    SinistroBCPTO.DocumentoTO documento = new SinistroBCPTO.DocumentoTO();
    documento.empCod = 'teste';
    documento.status = 'teste';
    documento.dtAtuStatus = 'teste';
    documento.cnpjNumColet = 'teste';
    documento.cnpjOrdColet = 'teste';
    documento.cnpjDigColet = 'teste';
    documento.papel = 'teste';
    documento.cpfNumVinc = 'teste';
    documento.cpfDigVinc = 'teste';
    documento.prodCod = 'teste';
    documento.chave = 'teste';
    documento.contratoorigem = 'teste';
    documento.susep = 'teste';
    documento.iniVig = 'teste';
    documento.fnlVig = 'teste';
    documento.dtEmiss = 'teste';
    documento.origemPrp = 'teste';
    documento.numPrp = 'teste';
    documento.segCod = 'teste';
    documento.canalVend = 'teste';
    documento.bucflag = 'teste';
    documento.notaFiscalDocumento = 'teste';

    documento.item = new List<SinistroBCPTO.ItemTO>();
    documento.enderecoDocumento = new List<SinistroBCPTO.EnderecoDocumentoTO>();
    documento.contatoDocumento = new List<SinistroBCPTO.ContatoDocumentoTO>();
    documento.emailDocumento = new List<SinistroBCPTO.EmailDocumentoTO>();
    documento.sistemasOrigensDocumento = new List<SinistroBCPTO.SistemasOrigensDocumentoTO>();

    SinistroBCPTO.ItemTO item = new SinistroBCPTO.ItemTO();
    item.numero = 'teste';
    item.status = 'teste';
    item.alterTip = 'teste';
    item.edsTip = 'teste';
    item.alterNum = 'teste';
    item.dtAtuStatus = 'teste';
    item.tipVlrRecebto = 'teste';
    item.vlrRecebto = 'teste';
    item.iniVig = 'teste';
    item.fnlVig = 'teste';
    item.dtEmiss = 'teste';
    item.formaPagto = 'teste';
    item.vlrContratado = 'teste';
    item.vlrTotalContratado = 'teste';
    item.origemPrp = 'teste';
    item.numPrp = 'teste';
    item.ordemRS = 'teste';
    item.numRS = 'teste';
    item.sinistrTip = 'teste';
    item.numSinistro = 'teste';
    item.dtAvisoSinistro = 'teste';
    item.placa = 'teste';
    item.chassi = 'teste';
    item.anoFabr = 'teste';
    item.anoModel = 'teste';
    item.marca = 'teste';
    item.tipo = 'teste';
    item.modelo = 'teste';
    item.contrchave = 'teste';
    item.tipocontrchave = 'teste';
    item.renavam = 'teste';
    item.notaFiscalItem = 'teste';
    item.siglPais = 'teste';
    
    item.enderecoItem = new SinistroBCPTO.EnderecoItemTO();
    item.sistemasOrigensItem = new List<SinistroBCPTO.SistemasOrigensItemTO>();

    SinistroBCPTO.EnderecoItemTO enderecoItem = new SinistroBCPTO.EnderecoItemTO();
    enderecoItem.siglPais = 'teste';
    enderecoItem.finalidLogr = 'teste';
    enderecoItem.latitude = 'teste';
    enderecoItem.longitude = 'teste';
    enderecoItem.enderFlgOpt = 'teste';
    enderecoItem.enderDtFlgOpt = 'teste';
    enderecoItem.enderecoCompleto = new SinistroBCPTO.EnderecoCompletoTO();

    SinistroBCPTO.SistemasOrigensItemTO sisOrIt = new SinistroBCPTO.SistemasOrigensItemTO();
    sisOrIt.sistemaOrigemItem = 'teste';

    SinistroBCPTO.EnderecoDocumentoTO enderecoDocumento = new SinistroBCPTO.EnderecoDocumentoTO();
    enderecoDocumento.siglPais = 'teste';
    enderecoDocumento.finalidLogr = 'teste';
    enderecoDocumento.latitude = 'teste';
    enderecoDocumento.longitude = 'teste';
    enderecoDocumento.enderFlgOpt = 'teste';
    enderecoDocumento.enderDtFlgOpt = 'teste';
    enderecoDocumento.enderecoCompleto = new SinistroBCPTO.EnderecoCompletoTO();

    SinistroBCPTO.ContatoDocumentoTO contatoDocumento = new SinistroBCPTO.ContatoDocumentoTO();
    contatoDocumento.foneTip = 'teste';
    contatoDocumento.foneDDI = 'teste';
    contatoDocumento.foneDDD = 'teste';
    contatoDocumento.foneNum = 'teste';
    contatoDocumento.foneFlgOpt = 'teste';
    contatoDocumento.foneDtFlgOpt = 'teste';

    SinistroBCPTO.EmailDocumentoTO emailDocumento = new SinistroBCPTO.EmailDocumentoTO();
    emailDocumento.emailTip = 'teste';
    emailDocumento.email = 'teste';
    emailDocumento.emailFlgOpt = 'teste';
    emailDocumento.emailDtFlgOpt = 'teste';

    SinistroBCPTO.SistemasOrigensDocumentoTO sistemasOrigensDocumento = new SinistroBCPTO.SistemasOrigensDocumentoTO();
    sistemasOrigensDocumento.sistemaOrigemDocumento = 'teste';

    SinistroBCPTO.BancoTO banco = new SinistroBCPTO.BancoTO();
    banco.codigoBanco = 'codigoBanco';
    banco.agencia = new List<SinistroBCPTO.AgenciaTO>();

    SinistroBCPTO.AgenciaTO agencia = new SinistroBCPTO.AgenciaTO();
    agencia.agenciaBancaria = 'teste';
    agencia.conta = new List<SinistroBCPTO.ContaTO>();

    SinistroBCPTO.ContaTO conta = new SinistroBCPTO.ContaTO();
    conta.contaBancaria = 'teste';
    conta.digitoContaBancaria = 'teste';

    SinistroBCPTO.SistemasOrigensPessoaTO sistemasOrigensPessoa = new SinistroBCPTO.SistemasOrigensPessoaTO();
    sistemasOrigensPessoa.sistemaOrigemPessoa = 'teste';

    SinistroBCPTO.PessoasSociaisTO pessoasSociais = new SinistroBCPTO.PessoasSociaisTO();
    pessoasSociais.pessoaSocial = new List<SinistroBCPTO.PessoaSocialTO>();

    SinistroBCPTO.PessoaSocialTO pessoaSocial = new SinistroBCPTO.PessoaSocialTO();
    pessoaSocial.socialTip = 'teste';
    pessoaSocial.socialIdentificador = 'teste';
    pessoaSocial.socialNome = 'teste';
    pessoaSocial.socialEmail = 'teste';
    pessoaSocial.socialCelular = 'teste';
    pessoaSocial.socialNascimento = 'teste';
    pessoaSocial.socialFlag = 'teste';

    }

}