public class EnderecoFacade 
{
	private final Map<String, String>	mapTipoEndereco		= new Map<String, String> {'RES' => 'Residencial', 'COM' => 'Comercial', 'REC' => 'Recado', 'VER' => 'Veraneio'};
    private final Map<String, String>	mapTipoLogradouro	= new Map<String, String> {'AL' => 'Alameda','AV' => 'Avenida', 'R'=> 'Rua'};

	private static final EnderecoFacade classInstance;
    static { classInstance = new EnderecoFacade(); }
    private EnderecoFacade() {}
    public static EnderecoFacade getInstance() { return classInstance; }

	private static AccountBO contaBo = AccountBO.getInstance();

	 //Gera os endereços das contas criadas
    public void gerarEnderecosContas(List<Account> contas, Map<String, List<EmissaoTO.EnderecoTO>> mapEnderecos)
    {
        Id tipoRegistroPessoaFisica = RecordTypeBO.buscarTipoRegistro('Account', 'PessoaFisica').Id;
        List<Endereco__c> enderecosConta = new List<Endereco__c>();
        Set<String> setContas = new Set<String>();
        Map<String, Endereco__c> mapEnderecosConta = new Map<String, Endereco__c>();

        for(Account conta : contas)
            setContas.add(conta.IdExterno__c);

        for(Account conta : AccountDAO.getInstance().buscarContasPorIdExterno(setContas))
        {
            for(Endereco__c endereco : conta.Enderecos__r)
                mapEnderecosConta.put(conta.Id + endereco.Logradouro__c + endereco.numero__c + endereco.Cidade__c + endereco.Estado__c, endereco);
        }

        for(Account conta : contas)
        {
            String cpfCnpj = '';

            if(conta.RecordTypeId == tipoRegistroPessoaFisica)
                cpfCnpj = conta.Cpf__c;
            else
                cpfCnpj = conta.CNPJ__c;

           enderecosConta.addAll(this.gerarParseEndereco(conta.Id, mapEnderecos.get(cpfCnpj), mapEnderecosConta));
        }

        //Salva os endereços das contas
        contaBo.salvarEnderecosContas(enderecosConta);
    }

	//Gera parse de endereços
    public List<Endereco__c> gerarParseEndereco(Id contaId, List<EmissaoTO.EnderecoTO> enderecos, Map<String, Endereco__c> mapEnderecosConta)
    {
        List<Endereco__c> 	enderecosConta 		= new List<Endereco__c>();
        Map<String, String> mapTipoEndereco 	= new Map<String, String>{'COM' => 'Comercial', 'REC' => 'Recado', 'RES' => 'Residencial', 'VER' => 'Veraneio'};
        Map<String, String> mapTipoLogradouro 	= new Map<String, String>{'A' => 'Alameda', 'AV' => 'Avenida', 'R' => 'Rua'};

        for(EmissaoTO.EnderecoTO endereco : enderecos)
        {
            Id enderecoId = null;
            Endereco__c enderecoExistente = mapEnderecosConta.get(contaId + endereco.logradouro + endereco.numeroLogradouro + endereco.cidade + endereco.uf);

            if(enderecoExistente != null)
                enderecoId = enderecoExistente.Id;
            

            enderecosConta.add
            (
                new Endereco__c(
                    Id = enderecoId,
                    Conta__c = contaId,
                    TipoEndereco__c = mapTipoEndereco.get(endereco.tipoEndereco),
                    TipoLogradouro__c = mapTipoLogradouro.get(endereco.tipoLogradouro),
                    Logradouro__c = endereco.logradouro,
                    Numero__c = endereco.numeroLogradouro,
                    Complemento__c = endereco.complemento,
                    CEP__c = endereco.cep + endereco.complementoCep,
                    Cidade__c = endereco.cidade,
                    Estado__c = endereco.uf,
                    Pais__c = endereco.paisResidencia,
                    Bairro__c = endereco.bairro,
                    MaisAtual__c = true
                )
            );
        }

        return enderecosConta;
    }

	public List<Endereco__c> parseEndereco(Id contaId, List<EmissaoTO.EnderecoTO> enderecosTO, Map<String, Endereco__c> mapEnderecosConta, String tipoConta)
    {
        List<Endereco__c> lstEnderecos = new List<Endereco__c>();

        for(EmissaoTO.EnderecoTO endereco : enderecosTO)
        {
            String chave = endereco.logradouro + endereco.numeroLogradouro + endereco.cidade + endereco.uf;
            Endereco__c enderecobase = mapEnderecosConta.get(chave);

            system.debug('Conta:  ' + contaId);

            if(enderecobase == null)
            {
                enderecobase              = new Endereco__c();
                enderecoBase.Conta__c     = contaId;
                enderecoBase.MaisAtual__c = true;
            }

            enderecoBase.CEP__c             = endereco.cep + endereco.complementoCep;
            enderecoBase.Cidade__c          = endereco.cidade;
            enderecoBase.Complemento__c     = endereco.complemento;
            enderecoBase.Estado__c          = endereco.uf;
            enderecoBase.Logradouro__c      = endereco.logradouro;
            enderecoBase.Numero__c          = endereco.numeroLogradouro;
            enderecoBase.Pais__c            = endereco.paisResidencia;
            enderecoBase.TipoEndereco__c    = mapTipoEndereco.get(endereco.tipoEndereco);
            enderecoBase.TipoLogradouro__c  = mapTipoLogradouro.get(endereco.tipoLogradouro);
            enderecoBase.Bairro__c          = endereco.bairro;

            lstEnderecos.add(enderecobase);
        }

        return lstEnderecos;
    }
}