// PLV-2015 Criação da classe
public class SinistroBCPTO { 

    public AdicionarPessoaProdutoRequestTO adicionarPessoaProdutoRequest { get; set; }
    public String sucursal { get; set; }
    public String ramo { get; set; }
    public String apolice { get; set; }
    public String origemproposta { get; set; }
    public String numeroproposta { get; set; }
    
    public class AdicionarPessoaProdutoRequestTO
    {
        public String codigoOrigemMovimento { get; set; }
        public String grupoXML { get; set; }
        public String dataHoraMoviento { get; set; }
        public String numeroSequenciaCarga { get; set; }
        public DadosRastreamentoTO dadosRastreamento { get; set; }
        public PessoaProdutoEBOTO pessoaProdutoEBO { get; set; }
    } 

    public class DadosRastreamentoTO
    {
        public String codigoAcessoCanal { get; set; }
        public String codigoOrigemMovimento { get; set; }
        public String codigoServico { get; set; }
        public String codigoTipoMeioAcessoCanal { get; set; }
        public String descricaoProtocoloInternet { get; set; }
        public String numeroSessaoServico { get; set; }
        public String textoMeioAcesso { get; set; }
        public String timeStampControleServico { get; set; }
    }
    
    public class PessoaProdutoEBOTO
    {
        public String id { get; set; }
        public String nome { get; set; }
        public String fonetica { get; set; }
        public String primeiroNome { get; set; }

        public CpfCnpjTO cpfCnpj { get; set; }

        public String rne { get; set; }
        public String cpfCnpjRel { get; set; }
        public String dtIniRelac { get; set; }
        public String titularDoc { get; set; }
        public String grauRelac { get; set; }
        public String mae { get; set; }
        public String pai { get; set; }
        public String papel { get; set; }
        public String origem { get; set; }
        public String tipoPessoa { get; set; }
        public String tipoPrestador { get; set; }
        public String tipoEmpresa { get; set; }
        public String sexo { get; set; }
        public String dtAbertura { get; set; }
        public String dtInicio { get; set; }
        public String dtFinal { get; set; }
        public String nascimento { get; set; }
        public String estCivil { get; set; }
        public String estrcargo { get; set; }
        public String cargo { get; set; }
        public String cbo { get; set; }
        public String cnae { get; set; }
        public String situacao { get; set; }
        public String codEmpresa { get; set; }
        public String fxRendaCod { get; set; }

        public List<EmailPessoaTO> emailPessoa { get; set; }
        public  List<EmailDocumentoTO> emailDocumento  { get; set; } 
        public List<EnderecoPessoaTO> enderecoPessoa { get; set; }
        public List<ContatoPessoaTO> contatoPessoa { get; set; }

        public String tpComunic { get; set; }
        public String twitter { get; set; }
        public String pessMatr { get; set; }
        public String codPrestOrigem { get; set; }
        public String susepPrinc { get; set; }

        public DeficFlagTO deficFlag { get; set; }

        public String deficTip { get; set; }
        public String flagPep { get; set; }
        public String cargoPep { get; set; }
        public String cpfNumPep { get; set; }
        public String cpfOrdemPep { get; set; }
        public String cpfDigPep { get; set; }
        public String relacTipPep { get; set; }
        public String faturamentoPJ { get; set; }
        public String patrimonioLiquidoPJ { get; set; }

        public FlgEstrangTO flgEstrang { get; set; }

        public String tipClassif { get; set; }
        public String dtClassif { get; set; }
        public String dtInclusao { get; set; }
        public String dtAlteracao { get; set; }
        public String grphHold { get; set; }
        public String dtgrphHold { get; set; }

        public FlgportalTO flgportal { get; set; }

        public String dtFlgPortal { get; set; }
        public String vincPrestCNPJ { get; set; }
        public String vincPrestOrdem { get; set; }
        public String grvincPrestDigupoXML { get; set; }
        public String bucflag { get; set; }

        public DocumentoTO documento { get; set; } // List ?

        public String nomeSocial { get; set; }
        public String codigoRacaHumana { get; set; }
        public String flgTrtmtoPrtrMedico { get; set; }
        public String dadoBiometrico { get; set; }
        public String tipoReligiao { get; set; }
        public String tipoOrntcaoSexual { get; set; }
        public String filiacaoPartidaria { get; set; }
        public String filiacaoSindical { get; set; }

        public List<BancoTO> banco { get; set; }
        public List<SistemasOrigensPessoaTO> sistemasOrigensPessoa { get; set; }
        public String pescod { get; set; }
        public PessoasSociaisTO pessoasSociais { get; set; }
        
        public String foneTip { get; set; }
        public String foneDDD { get; set; }
        public String foneNum { get; set; }
    }

    public class CpfCnpjTO
    {
        public String numeroCnpjCpf { get; set; }
        public String ordemCnpj { get; set; }
        public String digitoCnpjCpf { get; set; }
    }

    public class EmailPessoaTO
    {
        public String emailTip  { get; set; }
        public String email  { get; set; }
        public String emailFlgOpt  { get; set; }
        public String emailDtFlgOpt  { get; set; }
    }

    public class EnderecoPessoaTO
    {
        public EnderecoCompletoTO enderecoCompleto { get; set; }

        public String siglPais  { get; set; }
        public String finalidLogr  { get; set; }
        public String latitude  { get; set; }
        public String longitude  { get; set; }
        public String enderFlgOpt  { get; set; }
        public String enderDtFlgOpt  { get; set; }
    }

    public class EnderecoCompletoTO
    {
        public String tipoLogradouro  { get; set; }
        public String logradouro  { get; set; }
        public String numeroLogradouro  { get; set; }
        public String complemento  { get; set; }
        public String bairro  { get; set; }
        public String cidade  { get; set; }
        public String uf  { get; set; }
        public String cep  { get; set; }
        public String complementoCep  { get; set; }
        public String numeroSequencia  { get; set; }
        public String codigoFinalidadeLogradouro  { get; set; }
        public String siglaTipoLogradouro  { get; set; }
        public String descricaoPosicaoLogradouro  { get; set; }
        public String numeroCepComplemento  { get; set; }
        public String siglaPais  { get; set; }
        public String numeroLatitude  { get; set; }
        public String numeroLongitude  { get; set; }
        public String flagAutorizacaoPropaganda  { get; set; }
        public String dataAutorizacaoPropaganda  { get; set; }
        public String codigoOrigemMovimento  { get; set; }
        public String nomeOrigemMovimento  { get; set; }
        public String dataAtualizacao  { get; set; }
        public String flagNivelConfiancaEnderecoAtingido  { get; set; }
        public String flagNivelConfiancaLocalizacaoAtingido  { get; set; }
    }

    public class ContatoPessoaTO
    {
        public String foneTip  { get; set; }
        public String foneDDI  { get; set; }
        public String foneDDD  { get; set; }
        public String foneNum  { get; set; }
        public String foneFlgOpt  { get; set; }
        public String foneDtFlgOpt  { get; set; }
    }

    public class DeficFlagTO
    {
        public String flagOpcao  { get; set; }
    }

    public class FlgEstrangTO 
    {
        public String flagOpcao  { get; set; }
    }

    public class FlgportalTO  
    {
        public String flagOpcao  { get; set; }
    }

    public class DocumentoTO  
    {
        public List<ItemTO> item { get; set; }

        public String empCod  { get; set; }
        public String status  { get; set; }
        public String dtAtuStatus  { get; set; }
        public String cnpjNumColet  { get; set; }
        public String cnpjOrdColet  { get; set; }
        public String cnpjDigColet  { get; set; }
        public String papel  { get; set; }
        public String cpfNumVinc  { get; set; }
        public String cpfDigVinc  { get; set; }
        public String prodCod  { get; set; }
        public String chave  { get; set; }
        public String contratoorigem  { get; set; }

        public  List<EnderecoDocumentoTO> enderecoDocumento  { get; set; } 
        public  List<ContatoDocumentoTO> contatoDocumento  { get; set; }

        public String susep  { get; set; }
        // public List<CopartSusepTO> copartSusep  { get; set; }  // ?????
        public String iniVig  { get; set; }
        public String fnlVig  { get; set; }
        public String dtEmiss  { get; set; }

        public  List<EmailDocumentoTO> emailDocumento  { get; set; } 

        public String origemPrp  { get; set; }
        public String numPrp  { get; set; }
        public String segCod  { get; set; }
        public String canalVend  { get; set; }
        public String bucflag  { get; set; }
        public String notaFiscalDocumento  { get; set; }
        public List<SistemasOrigensDocumentoTO> sistemasOrigensDocumento  { get; set; }

    }

    public class ItemTO  
    {
        public String numero  { get; set; }
        public String status  { get; set; }
        public String alterTip  { get; set; }
        public String edsTip  { get; set; }
        public String alterNum  { get; set; }
        public String dtAtuStatus  { get; set; }
        public String tipVlrRecebto  { get; set; }
        public String vlrRecebto  { get; set; }
        public String iniVig  { get; set; }
        public String fnlVig  { get; set; }
        public String dtEmiss  { get; set; }
        public String formaPagto  { get; set; }
        public String vlrContratado  { get; set; }
        public String vlrTotalContratado  { get; set; }
        public String origemPrp  { get; set; }
        public String numPrp  { get; set; }
        public String ordemRS  { get; set; }
        public String numRS  { get; set; }
        public String sinistrTip  { get; set; }
        public String numSinistro  { get; set; }
        public String dtAvisoSinistro  { get; set; }
        public String placa  { get; set; }
        public String chassi  { get; set; }
        public String anoFabr  { get; set; }
        public String anoModel  { get; set; }
        public String marca  { get; set; }
        public String tipo  { get; set; }
        public String modelo  { get; set; }

        public EnderecoItemTO enderecoItem  { get; set; }

        public String contrchave  { get; set; }
        public String tipocontrchave  { get; set; }
        public String renavam  { get; set; }
        public String notaFiscalItem  { get; set; }
        public  List<SistemasOrigensItemTO> sistemasOrigensItem  { get; set; }
        
        public String siglPais  { get; set; }
    }

    public class EnderecoItemTO  
    {
        public EnderecoCompletoTO enderecoCompleto  { get; set; }

        public String siglPais  { get; set; }
        public String finalidLogr  { get; set; }
        public String latitude  { get; set; }
        public String longitude  { get; set; }
        public String enderFlgOpt  { get; set; }
        public String enderDtFlgOpt  { get; set; }

    }

    public class SistemasOrigensItemTO  
    {
        public String sistemaOrigemItem  { get; set; }
    }

    public class EnderecoDocumentoTO  
    {
        public EnderecoCompletoTO enderecoCompleto  { get; set; }
        public String siglPais  { get; set; }
        public String finalidLogr  { get; set; }
        public String latitude  { get; set; }
        public String longitude  { get; set; }
        public String enderFlgOpt  { get; set; }
        public String enderDtFlgOpt  { get; set; }
    }

    public class ContatoDocumentoTO  
    {
        public String foneTip  { get; set; }
        public String foneDDI  { get; set; }
        public String foneDDD  { get; set; }
        public String foneNum  { get; set; }
        public String foneFlgOpt  { get; set; }
        public String foneDtFlgOpt  { get; set; }
    }

    // public class CopartSusepTO               // ????
    // {
    // }

    public class EmailDocumentoTO  
    {
        public String emailTip  { get; set; }
        public String email  { get; set; }
        public String emailFlgOpt  { get; set; }
        public String emailDtFlgOpt  { get; set; }
    }

    public class SistemasOrigensDocumentoTO  
    {
        public String sistemaOrigemDocumento  { get; set; }
    }

    public class BancoTO  
    {
        public String codigoBanco  { get; set; }
        public List<AgenciaTO> agencia  { get; set; }
    }

    public class AgenciaTO  
    {
        public String agenciaBancaria  { get; set; }
        public List<ContaTO> conta  { get; set; }
    }

    public class ContaTO  
    {
        public String contaBancaria  { get; set; }
        public String digitoContaBancaria  { get; set; }
    }

    public class SistemasOrigensPessoaTO  
    {
        public String sistemaOrigemPessoa  { get; set; }
    }

    public class PessoasSociaisTO  
    {
        public List<PessoaSocialTO> pessoaSocial  { get; set; }
    }

    public class PessoaSocialTO  
    {
        public String socialTip  { get; set; }
        public String socialIdentificador  { get; set; }
        public String socialNome  { get; set; }
        public String socialEmail  { get; set; }
        public String socialCelular  { get; set; }
        public String socialNascimento  { get; set; }
        public String socialFlag  { get; set; }
    }
    
}