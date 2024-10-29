/***
* Created: Jeferson Santana (Sys4b)
* Date: 2024-08
* Description: class responsible for testing: BatchCreateFileReportMegaDayTest 
* task-History : LECVPV-218
***/ 
public with sharing class PepTO {
    public class MandatoPEPs {
		public String dataCarga{get;set;}
		public String dataExoneracao{get;set;}
		public CargoPEPWS cargoPEPWS{get;set;}
		public String dataAtualizacao{get;set;}
		public String descricaoMotivoExoneracao{get;set;}
		public OrgaoPEPWS orgaoPEPWS{get;set;}
	}

	public class ListaRelacionada {
		public String siglaUF{get;set;}
		public String descricaoEmail{get;set;}
		public String flagExclusao{get;set;}
		public String nomeLogradouro{get;set;}
		public Integer tipoPessoa{get;set;}
		public String complementoLogradouro{get;set;}
		public String nomeBairro{get;set;}
		public String nomeCidade{get;set;}
		public Integer numeroTelefone{get;set;}
		public Integer numeroCepInicial{get;set;}
		public Integer siglaSexo{get;set;}
		public Integer numeroCepComplemento{get;set;}
		public Integer codigoPessoaRelacionada{get;set;}
		public List<PessoaRelacaoPEPs> pessoaRelacaoPEPs{get;set;}
		public String dataAtualizacao{get;set;}
		public String nomePessoaRelacionada{get;set;}
		public Long numeroCPF{get;set;}
		public String dataNascimento{get;set;}
		public Integer numeroRamal{get;set;}
		public Integer codigoDDD{get;set;}
		public Integer codigoSituacao{get;set;}
		public Integer numeroLogradouro{get;set;}
	}

	public class PessoaRelacionadaPEPWS {
		public String siglaUF{get;set;}
		public String descricaoEmail{get;set;}
		public String flagExclusao{get;set;}
		public String nomeLogradouro{get;set;}
		public Integer tipoPessoa{get;set;}
		public String complementoLogradouro{get;set;}
		public String nomeBairro{get;set;}
		public String nomeCidade{get;set;}
		public Integer numeroTelefone{get;set;}
		public Integer numeroCepInicial{get;set;}
		public Integer siglaSexo{get;set;}
		public String numeroCepComplemento{get;set;}
		public Integer codigoPessoaRelacionada{get;set;}
		public String dataAtualizacao{get;set;}
		public String nomePessoaRelacionada{get;set;}
		public Long numeroCPF{get;set;}
		public String dataNascimento{get;set;}
		public Integer numeroRamal{get;set;}
		public Integer codigoDDD{get;set;}
		public Integer codigoSituacao{get;set;}
		public Integer numeroLogradouro{get;set;}
	}

	public String mensagemRetorno{get;set;}
	public ListaRelacionada listaRelacionada{get;set;}
	public ListaPessoa listaPessoa{get;set;}
	public Integer codigoRetorno{get;set;}
	public DataObjects dadosObjeto{get;set;}

	public class PessoaRelacionadaPEPWS_Z {
		public String siglaUF{get;set;}
		public String descricaoEmail{get;set;}
		public String flagExclusao{get;set;}
		public String nomeLogradouro{get;set;}
		public Integer tipoPessoa{get;set;}
		public String complementoLogradouro{get;set;}
		public String nomeBairro{get;set;}
		public String nomeCidade{get;set;}
		public Integer numeroTelefone{get;set;}
		public Integer numeroCepInicial{get;set;}
		public String numeroCepComplemento{get;set;}
		public Integer codigoPessoaRelacionada{get;set;}
		public String dataAtualizacao{get;set;}
		public String nomePessoaRelacionada{get;set;}
		public Long numeroCPF{get;set;}
		public String dataNascimento{get;set;}
		public Integer numeroRamal{get;set;}
		public Integer codigoDDD{get;set;}
		public Integer codigoSituacao{get;set;}
		public Integer numeroLogradouro{get;set;}
	}

	public class PessoaPEPWS {
		public String siglaUF{get;set;}
		public String descricaoEmail{get;set;}
		public String flagExclusao{get;set;}
		public String nomeLogradouro{get;set;}
		public String complementoLogradouro{get;set;}
		public String nomePEP{get;set;}
		public String nomeBairro{get;set;}
		public String nomeCidade{get;set;}
		public Integer numeroTelefone{get;set;}
		public Long cpfPEP{get;set;}
		public Integer numeroCepInicial{get;set;}
		public Integer siglaSexo{get;set;}
		public Integer numeroCepComplemento{get;set;}
		public String dataAtualizacao{get;set;}
		public Integer codigoPEP{get;set;}
		public Integer codigoStatus{get;set;}
		public String tipoPEP{get;set;}
		public String dataNascimento{get;set;}
		public Integer numeroRamal{get;set;}
		public Integer codigoDDD{get;set;}
		public Integer codigoSituacao{get;set;}
		public Integer numeroLogradouro{get;set;}
	}

	public class PessoaRelacionadaPEPWS_X {
		public String flagExclusao{get;set;}
		public String dataAtualizacao{get;set;}
		public String nomePessoaRelacionada{get;set;}
		public Integer numeroCPF{get;set;}
		public Integer numeroTelefone{get;set;}
		public Integer numeroRamal{get;set;}
		public Integer codigoDDD{get;set;}
		public Integer codigoPessoaRelacionada{get;set;}
		public Integer codigoSituacao{get;set;}
		public Integer numeroLogradouro{get;set;}
	}

	public class PessoaRelacionadaPEPWS_Y {
		public String siglaUF{get;set;}
		public String descricaoEmail{get;set;}
		public String flagExclusao{get;set;}
		public String nomeLogradouro{get;set;}
		public Integer tipoPessoa{get;set;}
		public String complementoLogradouro{get;set;}
		public String nomeBairro{get;set;}
		public String nomeCidade{get;set;}
		public Integer numeroTelefone{get;set;}
		public Integer numeroCepInicial{get;set;}
		public Integer siglaSexo{get;set;}
		public Integer numeroCepComplemento{get;set;}
		public Integer codigoPessoaRelacionada{get;set;}
		public String dataAtualizacao{get;set;}
		public String nomePessoaRelacionada{get;set;}
		public Long numeroCPF{get;set;}
		public String dataNascimento{get;set;}
		public Integer numeroRamal{get;set;}
		public Integer codigoDDD{get;set;}
		public Integer codigoSituacao{get;set;}
		public Integer numeroLogradouro{get;set;}
	}

	public class PessoaRelacaoPEPs {
		public String dataAtualizacao{get;set;}
		public String descricaoRelacionamento{get;set;}
		public PessoaPEPWS pessoaPEPWS{get;set;}
	}

	public class PessoaRelacaoPEPs_Z {
		public String dataAtualizacao{get;set;}
		public String descricaoRelacionamento{get;set;}
		public PessoaRelacionadaPEPWS pessoaRelacionadaPEPWS{get;set;}
	}

	public class PessoaRelacionadaPEPWS_W {
		public String flagExclusao{get;set;}
		public String dataAtualizacao{get;set;}
		public String nomePessoaRelacionada{get;set;}
		public Long numeroCPF{get;set;}
		public Integer numeroTelefone{get;set;}
		public Integer numeroRamal{get;set;}
		public Integer codigoDDD{get;set;}
		public Integer codigoPessoaRelacionada{get;set;}
		public Integer codigoSituacao{get;set;}
		public Integer numeroLogradouro{get;set;}
	}

	public class OrgaoPEPWS {
		public String nomeOrgao{get;set;}
		public String siglaUF{get;set;}
		public String descricaoEmail{get;set;}
		public String nomeLogradouro{get;set;}
		public Integer codigoOrgao{get;set;}
		public String complementoLogradouro{get;set;}
		public String nomeBairro{get;set;}
		public String nomeCidade{get;set;}
		public Integer numeroTelefone{get;set;}
		public Integer numeroCepInicial{get;set;}
		public Integer numeroCepComplemento{get;set;}
		public Integer numeroCNPJ{get;set;}
		public String dataAtualizacao{get;set;}
		public String siglaOrgaoSuperior{get;set;}
		public Integer numeroRamal{get;set;}
		public Integer codigoDDD{get;set;}
		public Integer numeroLogradouro{get;set;}
	}

	public class ListaPessoa {
		public String siglaUF{get;set;}
		public String descricaoEmail{get;set;}
		public String flagExclusao{get;set;}
		public String nomeLogradouro{get;set;}
		public String complementoLogradouro{get;set;}
		public String nomePEP{get;set;}
		public String nomeBairro{get;set;}
		public String nomeCidade{get;set;}
		public Integer numeroTelefone{get;set;}
		public Long cpfPEP{get;set;}
		//public MandatoPEPs mandatoPEPs{get;set;}
		public Integer numeroCepInicial{get;set;}
		public Integer siglaSexo{get;set;}
		public Integer numeroCepComplemento{get;set;}
		public List<PessoaRelacaoPEPs_Z> pessoaRelacaoPEPs{get;set;}
		public String dataAtualizacao{get;set;}
		public Integer codigoPEP{get;set;}
		public Integer codigoStatus{get;set;}
		public String tipoPEP{get;set;}
		public String dataNascimento{get;set;}
		public Integer numeroRamal{get;set;}
		public Integer codigoDDD{get;set;}
		public Integer codigoSituacao{get;set;}
		public Integer numeroLogradouro{get;set;}
	}

	public class CargoPEPWS {
		public String dataAtualizacao{get;set;}
		public String descricaoTratamentoFeminino{get;set;}
		public Integer codigoCargo{get;set;}
		public String descricaoTratamentoMasculino{get;set;}
		public String nomeCargo{get;set;}
	}

	public class DataObjects{
		public String nomeObject{get;set;}
		public String nomeAccount{get;set;}
		public String cpf{get;set;}
		public Id id{get;set;}
		public String accountId{get;set;}
	}

}