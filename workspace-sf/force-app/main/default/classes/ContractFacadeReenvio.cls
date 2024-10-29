//LECVP-72 - INICIO
public with sharing class ContractFacadeReenvio  extends ServiceBase{
   
    private static final ContractFacadeReenvio instancia = new ContractFacadeReenvio();
    public static ContractBO bo = ContractBO.getInstance();
    
    public static ContractFacadeReenvio getInstance(){
        return instancia; 
    }

    private static Map<String, String> mapEstadoCivil = new Map<String, String>
    {
        'Casado (a)' => 'CAS',
        'Divorciado(a)' => 'DIV',
        'Solteiro (a)' => 'SOL',
        'Viúvo(a)' => 'VIU', 
        'Separado(a)' => 'SEP', 
        'União estável' => 'UNI'
    };

    private Map<Id, String> mapRenda {get;set;}  
    private Map<Id, String> mapExposta {get;set;}

    public ReenvioContratoTO.PayloadTO mapeiaReenvioPayload(Quote cotacao, Map<String, String> mapPropostaApolice){

        try {
            Map<String, RecordType> mapRecordType = new Map<String, RecordType>(
                RecordTypeDAO.getInstance().getListRecordTypeBySobject('Account')
            );

            ReenvioContratoTO.PayloadTO reenvioPayload  = new ReenvioContratoTO.PayloadTO();
            reenvioPayload.contrato                              = new ReenvioContratoTO();
            reenvioPayload.contrato.remuneracoes                 = new List<ReenvioContratoTO.RemuneracoesTO>();
            reenvioPayload.contrato.contratantes                 = new List<ReenvioContratoTO.ContratantesTO>();

            List<RemuneracaoProposta__c> lstRemuneracaoProposta  = QuoteDAO.getInstance().buscarRemuneracaoProposta(new Set<Id>{cotacao.Id});

            reenvioPayload.contrato.codigoEmpresa  = cotacao.Produto__r.Empresa__r.CodigoEmpresa__c;

            for(RemuneracaoProposta__c  remProp : lstRemuneracaoProposta){
                for(FavorecidoRemuneracaoProposta__c  remfav : remProp.FavorecidosRemuneracaodaProposta__r)
                {
                    if(remfav.CorretorLider__c)
                    reenvioPayload.contrato.codigoSucursal = remfav.DadosCorretor__r.CodigoSucursalVinculo__c;
                }
            }

            List<Contract> contratoOriginal = new List<Contract>();
            List<Contract> contrato = [select Id, Name from Contract where NumeroProposta__c = :cotacao.NumeroProposta__c];

            contratoOriginal = [ 
                    SELECT ID, Name, ContratoOriginal__r.Name, ContratoOriginal__r.StartDate, ContratoOriginal__r.VigenciaFinal__c FROM Contract where name = :contrato[0].Name
                ];

            if(cotacao.Tipo__c == 'Cancelamento'){

                ContractBO.RetornoDadosEndossoTO retornoDadosEndossoTO = ContractBO.getInstance().buscarUltimoEndossoApolice(
                    reenvioPayload.contrato.codigoEmpresa,
                    cotacao.Contract.Sucursal__c,
                    cotacao.RamoSeguro__r.Codigo__c,
                    cotacao.Contract.NumeroApolice__c
                );

                reenvioPayload.contrato.numeroApolice = Integer.valueOf(cotacao.Contract.NumeroApolice__c);
                reenvioPayload.contrato.numeroEndosso = retornoDadosEndossoTO.numeroEndosso;                
                reenvioPayload.contrato.vigenciaInicial = String.valueOf(retornoDadosEndossoTO.objContrato.StartDate); 	
                reenvioPayload.contrato.vigenciaFinal = String.valueOf(retornoDadosEndossoTO.objContrato.VigenciaFinal__c);

                if(!contratoOriginal.isEmpty()){                               
                    reenvioPayload.contrato.vigenciaInicialContratoOriginal = String.valueOf(contratoOriginal[0].ContratoOriginal__r.StartDate);
                    reenvioPayload.contrato.vigenciaFinalContratoOriginal = String.valueOf(contratoOriginal[0].ContratoOriginal__r.VigenciaFinal__c);	
                }
            } else if(cotacao.Tipo__c == 'Endosso' && !contratoOriginal.isEmpty()) { 

                ContractBO.RetornoDadosEndossoTO retornoDadosEndossoTO = ContractBO.getInstance().buscarUltimoEndossoApolice(
                    reenvioPayload.contrato.codigoEmpresa,
                    cotacao.Contract.Sucursal__c,
                    cotacao.RamoSeguro__r.Codigo__c, 
                    cotacao.Contract.NumeroApolice__c
                );
                reenvioPayload.contrato.vigenciaInicial = String.valueOf(cotacao.VigenciaInicial__c);
                reenvioPayload.contrato.vigenciaFinal   = String.valueOf(cotacao.VigenciaFinal__c);
                reenvioPayload.contrato.vigenciaInicialContratoOriginal = String.valueOf(contratoOriginal[0].ContratoOriginal__r.StartDate);
                reenvioPayload.contrato.vigenciaFinalContratoOriginal = String.valueOf(contratoOriginal[0].ContratoOriginal__r.VigenciaFinal__c);	
                reenvioPayload.contrato.numeroEndosso = retornoDadosEndossoTO.numeroEndosso;
                reenvioPayload.contrato.numeroApolice = Integer.valueOf(cotacao.Contract.NumeroApolice__c);

            } else {   
                reenvioPayload.contrato.vigenciaInicial = String.valueOf(cotacao.VigenciaInicial__c);
                reenvioPayload.contrato.vigenciaFinal   = String.valueOf(cotacao.VigenciaFinal__c);
                reenvioPayload.contrato.numeroApolice   = Integer.valueOf(mapPropostaApolice.get(cotacao.NumeroProposta__c));
                reenvioPayload.contrato.numeroEndosso   = retornarNumeroEndosso( [SELECT id, Endosso__c FROM Contract WHERE Proposta__c =: cotacao.Id] );
            }   

            reenvioPayload.contrato.ramoSeguro                         = cotacao.RamoSeguro__r.Codigo__c;
            reenvioPayload.contrato.codigoOrigemDoMovimentoBCP         = cotacao.RamoSeguro__r.CodigoOrigemDoMovimentoBCP__c;
            
            if(cotacao.Origem__c != null){
                reenvioPayload.contrato.origem = Integer.valueOf(cotacao.Origem__c);
            } else{
                reenvioPayload.contrato.origem = 0;
            }

            reenvioPayload.contrato.numero        = String.valueOf(cotacao.NumeroProposta__c);
            reenvioPayload.contrato.tipoSeguro    = (cotacao.Tipo__c == null ? '' : cotacao.Tipo__c);
            reenvioPayload.contrato.dataInclusao  = (cotacao.Tipo__c == 'Novo' || cotacao.Tipo__c == 'Renovacao') ? Datetime.now().format('dd/MM/yyyy') : cotacao.Contract.DataEmissao__c.format(); 
            reenvioPayload.contrato.dataAlteracao = Datetime.now().format('dd/MM/yyyy');
            reenvioPayload.contrato.remuneracoes  = parseDadosRemuneracaoReenvio(cotacao.Opportunity.CanalDistribuicao__r.Sigla__c, cotacao.Produto__r.NumeroSusep__c, cotacao.Empresa__r.Sucursal__c, lstRemuneracaoProposta, mapRecordType );

            List<ContratanteProposta__c> lstContratanteProposta = QuoteDAO.getInstance().buscarContratantesPropostaPorIdProposta(new Set<Id>{cotacao.Id});
            
            reenvioPayload.contrato.contratantes = parseDadosContratantesReenvio(lstContratanteProposta, cotacao.RamoSeguro__c, mapRecordType);
            reenvioPayload.contrato.alteracoesEndosso = parseDadosAlteracoesEndossoReenvio(cotacao);

            return reenvioPayload;
        }
        catch(Exception e)
        {
            throw new ContractException(e.getLineNumber() + ': ' + e.getMessage()  + '(Erro mapeamento de reenvio do contrato)');
        }
    }

    public List<ReenvioContratoTO.RemuneracoesTO> parseDadosRemuneracaoReenvio(String canal, String numeroSusep, String sucursal, List<RemuneracaoProposta__c> lstRemuneracao, Map<String, RecordType> mapRecordType)
    {
        try
        {
            List<ReenvioContratoTO.RemuneracoesTO> remuneracoes = new List<ReenvioContratoTO.RemuneracoesTO>();

            for(RemuneracaoProposta__c rem : lstRemuneracao)
            {
                ReenvioContratoTO.RemuneracoesTO remuneracao   = new ReenvioContratoTO.RemuneracoesTO();
                remuneracao.favorecidos                 = new List<ReenvioContratoTO.FavorecidosTO>();

                remuneracao.tipoRemuneracao             = rem.TipoRemuneracao__r.Name;
                remuneracao.percentual                  = Integer.valueOf(rem.Percentual__c);
                
                for(FavorecidoRemuneracaoProposta__c item : rem.FavorecidosRemuneracaodaProposta__r)
                {
                    ReenvioContratoTO.FavorecidosTO favorecido     = new ReenvioContratoTO.FavorecidosTO();
                    
                    favorecido.papel                        = item.Papel__c;
                    favorecido.participacao                 = item.Participacao__c;
                    favorecido.pessoa                       = new ReenvioContratoTO.PessoaTO();
                    favorecido.pessoa.nome                  = item.Conta__r.Name;
                    favorecido.corretorLider                = item.CorretorLider__c;
                    favorecido.susepOficialCorretor         = item.SusepOficialCorretor__c;
                    favorecido.susepEmissao                 = item.SusepEmissao__c;
                    favorecido.susepOrcamento               = item.SusepOrcamento__c;
                    favorecido.susep                        = item.susep__c;

                    if(mapRecordType.get(String.valueOf(item.Conta__r.RecordTypeId)).Name == 'Pessoa física')
                    {
                        favorecido.pessoa.tipo = 'FIS';
                        favorecido.pessoa.dadosPessoaFisica = new ReenvioContratoTO.DadosPessoaFisicaTO();

                        String cpf = item.Conta__r.Cpf__c.replace('.','').replace('-','');

                        favorecido.pessoa.dadosPessoaFisica.numeroCpf               = cpf.substring(0, 9);
                        favorecido.pessoa.dadosPessoaFisica.digitoCpf               = cpf.substring(9, 11);

                        if( !String.isBlank(item.Conta__r.Sexo__c))  favorecido.pessoa.dadosPessoaFisica.sexo    =   item.Conta__r.Sexo__c.substring(0,1); // PLV-3723

                        favorecido.pessoa.dadosPessoaFisica.estadoCivil             = mapEstadoCivil.get(item.Conta__r.EstadoCivil__c);
                    }
                    else if(mapRecordType.get(String.valueOf(item.Conta__r.RecordTypeId)).Name == 'Pessoa jurídica')
                    {
                        favorecido.pessoa.tipo = 'JUR';
                        favorecido.pessoa.dadosPessoaJuridica              = new ReenvioContratoTO.DadosPessoaJuridicaTO();
                        String cnpj = item.Conta__r.Cnpj__c.replace('.','').replace('/','').replace('-','');
                        favorecido.pessoa.dadosPessoaJuridica.ordemCnpj    = cnpj.substring(0,8);
                        favorecido.pessoa.dadosPessoaJuridica.numeroCnpj   = cnpj.substring(8,12);
                        favorecido.pessoa.dadosPessoaJuridica.digitoCnpj   = cnpj.substring(12,14);
                    }

                    remuneracao.favorecidos.add(favorecido);
                }
                remuneracoes.add(remuneracao);
            }

            return remuneracoes;
        }
        catch(Exception e)
        {
            system.debug(e.getLineNumber() + ': ' + e.getMessage());
            throw new ContractException(e.getLineNumber() + ': ' + e.getMessage()  + '(Erro mapeamento dados remuneração)');
        }
    }

    public List<ReenvioContratoTO.ContratantesTO> parseDadosContratantesReenvio(List<ContratanteProposta__c> lstContratanteProposta, Id idRamo, Map<String, RecordType> mapRecordType)
    {
        try
        {
            List<ReenvioContratoTO.ContratantesTO> lstContratantes = new List<ReenvioContratoTO.ContratantesTO>();
            Map<Id,Endereco__c>          mapEnderecos = new Map<Id, Endereco__c>();
            Set<Id>                      setIdContas  = new Set<Id>();

            for(ContratanteProposta__c segurado: lstContratanteProposta){
                setIdContas.add(segurado.Conta__c);
            }

            for(Endereco__c endereco: EnderecoDAO.getInstance().buscarEnderecoContas(setIdContas)){
                mapEnderecos.put(endereco.Conta__c, endereco);
            }
            
            mapRenda = new Map<Id,String>();
            mapExposta = new Map<Id,String>();
             
            for(ContratanteProposta__c contratante : lstContratanteProposta)
            {
                ReenvioContratoTO.ContratantesTO contratanteTO   = new ReenvioContratoTO.ContratantesTO();
                contratanteTO.pessoa                   = new ReenvioContratoTO.PessoaTO();

                contratanteTO.tipo         = contratante.Tipo__c;
                contratanteTO.numero       = Integer.valueOf(contratante.Numero__c);
                contratanteTO.pessoa.nome  = contratante.Conta__r.Name;
                contratanteTO.pessoa.email = contratante.Conta__r.Email__c;

                if(mapRecordType.get(String.valueOf(contratante.Conta__r.RecordTypeId)).Name == 'Pessoa física')
                {
                    contratanteTO.pessoa.tipo = 'FIS';
                    contratanteTO.pessoa.dadosPessoaFisica                         = new ReenvioContratoTO.DadosPessoaFisicaTO();

                    String cpf = contratante.Conta__r.Cpf__c.replace('.','').replace('-','');

                    contratanteTO.pessoa.dadosPessoaFisica.numeroCpf               = cpf.substring(0, 9);
                    contratanteTO.pessoa.dadosPessoaFisica.digitoCpf               = cpf.substring(9, 11);

                    if( !String.isBlank(contratante.Conta__r.Sexo__c))  contratanteTO.pessoa.dadosPessoaFisica.sexo  = contratante.Conta__r.Sexo__c.substring(0,1); // PLV-3723

                    contratanteTO.pessoa.dadosPessoaFisica.estadoCivil             = mapEstadoCivil.get(contratante.Conta__r.EstadoCivil__c);
                    contratanteTO.pessoa.dadosPessoaFisica.dataNascimento          = String.valueOf(contratante.Conta__r.PersonBirthdate);

                }
                else if(mapRecordType.get(String.valueOf(contratante.Conta__r.RecordTypeId)).Name == 'Pessoa jurídica')
                {
                    contratanteTO.pessoa.tipo = 'JUR';
                    contratanteTO.pessoa.dadosPessoaJuridica              = new ReenvioContratoTO.DadosPessoaJuridicaTO();
                    String cnpj = contratante.Conta__r.Cnpj__c.replace('.','').replace('/','').replace('-','');
                    contratanteTO.pessoa.dadosPessoaJuridica.ordemCnpj    = cnpj.substring(0,8);
                    contratanteTO.pessoa.dadosPessoaJuridica.numeroCnpj   = cnpj.substring(8,12);
                    contratanteTO.pessoa.dadosPessoaJuridica.digitoCnpj   = cnpj.substring(12,14);
                }

                contratanteTO.pessoa.enderecos = this.parseDadosEnderecosReenvio(mapEnderecos.values(), contratante.Conta__c);
                contratanteTO.pessoa.telefones = this.parseDadosTelefoneReenvio(contratante.Conta__r);

                if(contratante.ResponsavelPagamento__c != null)
                    contratanteTO.dadosPagamento = this.parseDadosPagamentoReenvio('Contratante', contratante, null, mapRecordType);

                contratanteTO.grupos = this.parseDadosGrupoReenvio(GrupoPropostaDAO.getInstance().buscarGruposPropostaPorIds(new Set<Id>{contratante.Id}), contratante.Proposta__c, idRamo, mapRecordType);
                
                contratanteTO.pessoa.faixaRenda = 6;
                if(mapRenda.containsKey(contratante.Conta__c)){
                    String faixaRenda = mapRenda.get(contratante.Conta__c);
                    if(faixaRenda == '2500'){
                        contratanteTO.pessoa.faixaRenda = 2;
                    }
                    else if(faixaRenda == '4000'){
                        contratanteTO.pessoa.faixaRenda = 3;
                    }
                    else if(faixaRenda == '8000'){
                        contratanteTO.pessoa.faixaRenda = 4;
                    }
                    else{
                        contratanteTO.pessoa.faixaRenda = 5;
                    }
                }
                if(mapExposta.containsKey(contratante.Conta__c)){
                    String exposta = mapExposta.get(contratante.Conta__c);
                    if(exposta == 'Sim'){
                        contratanteTO.pessoa.pessoaExpostaPoliticamente = 1;
                    }
                    else if(exposta == 'Não'){
                        contratanteTO.pessoa.pessoaExpostaPoliticamente = 2;
                    }
                    else if(exposta == 'RelacionamentoProximo'){
                        contratanteTO.pessoa.pessoaExpostaPoliticamente = 3;
                    }
                }                
                lstContratantes.add(contratanteTO);
            }

            return lstContratantes;
        }
        catch(Exception e)
        {
            system.debug(e.getLineNumber() + ': ' + e.getMessage());
            throw new ContractException(e.getLineNumber() + ': ' + e.getMessage()  + '(Erro mapeamento Contratantes)');
        }
    }

    public List<ReenvioContratoTO.EnderecosTO> parseDadosEnderecosReenvio(List<Endereco__c> lstEnderecos, Id idConta)
    {
        List<ReenvioContratoTO.EnderecosTO> enderecos;

        try
        {
            for(Endereco__c endSeg : lstEnderecos)
            {
                system.debug('endSeg: '+ endSeg);
                if(endSeg.Conta__c == idConta)
                {
                    ReenvioContratoTO.EnderecosTO endSegurado = new ReenvioContratoTO.EnderecosTO();

                    endSegurado.tipoLogradouro      = endSeg.TipoLogradouro__c;
                    endSegurado.cidade              = endSeg.Cidade__c;
                    endSegurado.tipoEndereco        = endSeg.TipoEndereco__c;
                    endSegurado.logradouro          = endSeg.Logradouro__c;
                    endSegurado.bairro              = endSeg.Bairro__c;
                    endSegurado.cep                 = endSeg.CEP__c.substring(0, 5);
                    endSegurado.uf                  = endSeg.Estado__c;
                    endSegurado.numeroLogradouro    = endSeg.Numero__c;
                    endSegurado.paisResidencia      = 'BRA';//endSeg.Pais__c; - PLV 4362 alterado para hardcode por enquanto pois é necessário enviar a sigla
                    endSegurado.complementoCep      = endSeg.CEP__c.substring(5, 8);
                    //PLV-5033 - INICIO
                    endSegurado.complemento =  (String.isBlank(endSeg.Complemento__c)) ? '' : endSeg.Complemento__c;
                    //PLV-5033 - FIM
                    if(enderecos == null)
                        enderecos = new List<ReenvioContratoTO.EnderecosTO>();

                    enderecos.add(endSegurado);
                }
            }

            return enderecos;
        }
        catch(Exception e)
        {
            system.debug(e.getLineNumber() + ': ' + e.getMessage());
            throw new ContractException(e.getLineNumber() + ': ' + e.getMessage()  + '(Erro mapeamento endereço)');
        }
    }

    public List<ReenvioContratoTO.TelefonesTO> parseDadosTelefoneReenvio (Account conta)
    {
        try
        {
            List<ReenvioContratoTO.TelefonesTO> telefones = new List<ReenvioContratoTO.TelefonesTO>();

            if(conta.Phone != null)
            {
                ReenvioContratoTO.TelefonesTO t = new ReenvioContratoTO.TelefonesTO();
                String telefone = conta.Phone.replace(' ', '').replace('(', '').replace(')', '').replace('-', '');

                t.tipoTelefone = 'CEL';
                t.dddTelefone = telefone.substring(0, 2);
                t.numeroTelefone = telefone.substring(2, telefone.length());

                telefones.add(t);
            }

            if(conta.PersonHomePhone != null)
            {
                String telefoneP = conta.PersonHomePhone.replace(' ', '').replace('(', '').replace(')', '').replace('-', '');

                ReenvioContratoTO.TelefonesTO t = new ReenvioContratoTO.TelefonesTO();
                t.tipoTelefone = 'RES';
       
                t.dddTelefone = telefoneP.substring(0, 2);
                t.numeroTelefone = telefoneP.substring(2, telefoneP.length());

                telefones.add(t);
            }

            if(conta.PersonOtherPhone != null)
            {
                String telefoneP = conta.PersonOtherPhone.replace(' ', '').replace('(', '').replace(')', '').replace('-', '');

                ReenvioContratoTO.TelefonesTO t = new ReenvioContratoTO.TelefonesTO();
                t.tipoTelefone = 'COM';
                t.dddTelefone = telefoneP.substring(0, 2);
                t.numeroTelefone = telefoneP.substring(2, telefoneP.length());

                telefones.add(t);
            }

            if(conta.Fax != null)
            {
                String telefoneP = conta.Fax.replace(' ', '').replace('(', '').replace(')', '').replace('-', '');

                ReenvioContratoTO.TelefonesTO t = new ReenvioContratoTO.TelefonesTO();
                t.tipoTelefone = 'Fax';
                t.dddTelefone = telefoneP.substring(0, 2);
                t.numeroTelefone = telefoneP.substring(2, telefoneP.length());

                telefones.add(t);
            }

            if(conta.PersonMobilePhone != null)
            {
                String telefoneP = conta.PersonMobilePhone.replace(' ', '').replace('(', '').replace(')', '').replace('-', '');

                ReenvioContratoTO.TelefonesTO t = new ReenvioContratoTO.TelefonesTO();
                t.tipoTelefone = 'CEL';
                t.dddTelefone = telefoneP.substring(0, 2);
                t.numeroTelefone = telefoneP.substring(2, telefoneP.length());

                telefones.add(t);
            }

            return telefones;

        }
        catch(Exception e)
        {
            system.debug(e.getLineNumber() + ': ' + e.getMessage());
            throw new ContractException(e.getLineNumber() + ': ' + e.getMessage()  + '(Erro mapeamento telefone)');
        }
    }

    public ReenvioContratoTO.DadospagamentoTO parseDadosPagamentoReenvio(String objeto, ContratanteProposta__c contratante, SeguradoProposta__c segurado, Map<String, RecordType> mapRecordType)
    {
        Account responsavelPGTO;
        String tipoResponsavelPagamento;
        Integer quantidadeParcelas;
        Integer codigo;        

        if(objeto == 'Contratante')
        {
            tipoResponsavelPagamento = contratante.TipoResponsavelPagamento__c;
            quantidadeParcelas      = Integer.valueOf(contratante.QuantidadeParcelas__c);
            responsavelPGTO         = contratante.ResponsavelPagamento__r;

            if(contratante.FormaPagamento__r != null){
            	codigo                  = Integer.valueOf(contratante.formaPagamento__r.codigo__c); 
            }    
        }
        else if(objeto == 'Segurado')
        {
            tipoResponsavelPagamento    = segurado.TipoResponsavelPagamento__c;
            quantidadeParcelas          = Integer.valueOf(segurado.QuantidadeParcelas__c);
            responsavelPGTO             = segurado.ResponsavelPagamento__r;
        }

        try
        {
            ReenvioContratoTO.DadosPagamentoTO  dadosPGTO    = new ReenvioContratoTO.DadosPagamentoTO();
            Map<Id,Endereco__c>          mapEnderecos = new Map<Id, Endereco__c>();
            Set<Id>                      setIdContas  = new Set<Id>();

            setIdContas.add(responsavelPGTO.id);

            for(Endereco__c endereco: EnderecoDAO.getInstance().buscarEnderecoContas(setIdContas))
                mapEnderecos.put(endereco.Conta__c, endereco);

            dadosPGTO.tipoResponsavelPagamento      = tipoResponsavelPagamento;
            dadosPGTO.quantidadeParcelas            = quantidadeParcelas;
            dadosPGTO.responsavelPagamento          = new ReenvioContratoTO.ResponsavelPagamentoTO();
            dadosPGTO.responsavelPagamento.nome     = responsavelPGTO.Name;

            if(objeto == 'Contratante'){
                dadosPGTO.formaPagamento = new ReenvioContratoTO.FormaPagamentoTO();
                dadosPGTO.formaPagamento.codigo  = codigo;             
            }    

            if(mapRecordType.get(String.valueOf(responsavelPGTO.RecordTypeId)).Name  == 'Pessoa jurídica')
            {
                dadosPGTO.responsavelPagamento.tipo = 'JUR';
                dadosPGTO.responsavelPagamento.dadosPessoaJuridica = new ReenvioContratoTO.DadosPessoaJuridicaTO();
                String cnpj = responsavelPGTO.Cnpj__c.replace('.','').replace('/','').replace('-','');
                dadosPGTO.responsavelPagamento.dadosPessoaJuridica.ordemCnpj    = cnpj.substring(0,8);
                dadosPGTO.responsavelPagamento.dadosPessoaJuridica.numeroCnpj   = cnpj.substring(8,12);
                dadosPGTO.responsavelPagamento.dadosPessoaJuridica.digitoCnpj   = cnpj.substring(12,14);
            }

            dadosPGTO.responsavelPagamento.enderecos = this.parseDadosEnderecosReenvio(mapEnderecos.values(), responsavelPGTO.Id);
            dadosPGTO.responsavelPagamento.telefones = this.parseDadosTelefoneReenvio(responsavelPGTO);

            if(objeto == 'Contratante')
            {
                dadosPGTO.parcelas = this.parseDadosParcelasReenvio(
                        Integer.valueOf(contratante.QuantidadeParcelas__c),
                        contratante.IOF__c,
                        contratante.PremioComercial__c,
                        contratante.FormaPagamento__r.Codigo__c,
                        contratante.VencimentoPrimeiraParcela__c
                );
            }
            else if(objeto == 'Segurado')
            {
                dadosPGTO.parcelas = this.parseDadosParcelasReenvio(
                        Integer.valueOf(segurado.QuantidadeParcelas__c),
                        segurado.IOF__c,
                        segurado.PremioComercial__c,
                        segurado.FormaPagamento__r.Codigo__c,
                        segurado.VencimentoPrimeiraParcela__c
                );
            }

            return dadosPGTO;

        }
        catch(Exception e)
        {
            system.debug(e.getLineNumber() + ': ' + e.getMessage());
            throw new ContractException(e.getLineNumber() + ': ' + e.getMessage()  + '(Erro mapeamento Dados pagamento)');
        }
    }

    public List<ReenvioContratoTO.ParcelasTO> parseDadosParcelasReenvio(Integer quantidadeParcelas, Decimal iof, Decimal valor, String codFormaPgto, Date vencPrimeiraParc)
    {
        try
        {
            ContractBO bo = ContractBO.getInstance();

            List<ReenvioContratoTO.ParcelasTO> parcelas = new List<ReenvioContratoTO.ParcelasTO>();
            for(Integer i = 0; i < quantidadeParcelas; i++)
            {
                ReenvioContratoTO.ParcelasTO parcela = new ReenvioContratoTO.ParcelasTO();

                parcela.meioPagamento           = codFormaPgto;
                parcela.numeroParcela           = i;
                parcela.valorIOF                = bo.calcularValor(quantidadeParcelas, 0, iof);
                parcela.valorParcela            = bo.calcularValor(quantidadeParcelas, 0, valor);
                parcela.dataVencimentoParcela   = String.valueOf(vencPrimeiraParc.addMonths(i));

                parcelas.add(parcela);
            }
            return parcelas;

        }
        catch(Exception e)
        {
            system.debug(e.getLineNumber() + ': ' + e.getMessage());
            throw new ContractException(e.getLineNumber() + ': ' + e.getMessage()  + '(Erro mapeamento parcelas)');
        }
    }

    public List<ReenvioContratoTO.GruposTO> parseDadosGrupoReenvio(List<GrupoProposta__c> gruposProp, Id idProposta, Id idRamo, Map<String, RecordType> mapRecordType)
    {
        try
        {
            List<ReenvioContratoTO.GruposTO> grupos = new List<ReenvioContratoTO.GruposTO>();

            for(GrupoProposta__c grupoP : gruposProp)
            {
                ReenvioContratoTO.GruposTO grupo = new ReenvioContratoTO.GruposTO();

                grupo.numero = 1;

                grupo.nome 		= grupoP.Name;
                if(grupoP.Descricao__c != null)
                    grupo.numero 	= Integer.valueOf(grupoP.Descricao__c);
                if(grupoP.QuantidadeVidas__c != null)
                    grupo.qtdeVidas = Integer.valueOf(grupoP.QuantidadeVidas__c);

                grupo.segurados = this.parseSeguradosGrupoReenvio(SeguradoPropostaDAO.getInstance().buscarGruposPropostaPorIds(new Set<Id>{grupoP.Id}), idProposta, idRamo, mapRecordType);

                grupos.add(grupo);
            }

            return grupos;

        }
        catch(Exception e)
        {
            system.debug(e.getLineNumber() + ': ' + e.getMessage());
            throw new ContractException(e.getLineNumber() + ': ' + e.getMessage()  + '(Erro mapeamento dados grupo)');
        }
    }

    public List<ReenvioContratoTO.SeguradosTO> parseSeguradosGrupoReenvio(List<SeguradoProposta__c> seguradosGrupo, Id idProposta, Id idRamo, Map<String, RecordType> mapRecordType)
    {
        try
        {
            List<ReenvioContratoTO.SeguradosTO> segurados = new List<ReenvioContratoTO.SeguradosTO>();
            for(SeguradoProposta__c seguradoGP : seguradosGrupo)
            {
                ReenvioContratoTO.SeguradosTO segurado = new ReenvioContratoTO.SeguradosTO();
                segurado.numero 			= Integer.valueOf(seguradoGP.Numero__c);
                
                segurado.pessoa 			= new ReenvioContratoTO.PessoaTO();

                segurado.pessoa.nome        = seguradoGP.Conta__r.Name;
                segurado.pessoa.email        = seguradoGP.Conta__r.Email__c;

                if(mapRecordType.get(String.valueOf(seguradoGP.Conta__r.RecordTypeId)).Name == 'Pessoa física')
                {
                    segurado.pessoa.tipo = 'FIS';
                    segurado.pessoa.dadosPessoaFisica               = new ReenvioContratoTO.DadospessoafisicaTO();
                    String cpf = seguradoGP.Conta__r.Cpf__c.replace('.','').replace('-','');
                    segurado.pessoa.dadosPessoaFisica.numeroCpf     = cpf.substring(0, 9);
                    segurado.pessoa.dadosPessoaFisica.digitoCpf     = cpf.substring(9, 11);

                    if(!String.isBlank(seguradoGP.Conta__r.Sexo__c)){
                        segurado.pessoa.dadosPessoaFisica.sexo   = seguradoGP.Conta__r.Sexo__c.substring(0,1);
                    }

                    segurado.pessoa.dadosPessoaFisica.estadoCivil             = mapEstadoCivil.get(seguradoGP.Conta__r.EstadoCivil__c);
                    segurado.pessoa.dadosPessoaFisica.dataNascimento          = String.valueOf(seguradoGP.Conta__r.PersonBirthdate);
                    segurado.pessoa.dadosPessoaFisica.email                   = seguradoGP.conta__r.PersonEmail;
                }
                
                if(mapRecordType.get(String.valueOf(seguradoGP.Conta__r.RecordTypeId)).Name == 'Pessoa jurídica')
                {
                    segurado.pessoa.tipo = 'JUR';
                    segurado.pessoa.dadosPessoaJuridica              = new ReenvioContratoTO.DadospessoajuridicaTO();
                    String cnpj = seguradoGP.Conta__r.Cnpj__c.replace('.','').replace('/','').replace('-','');
                    segurado.pessoa.dadosPessoaJuridica.ordemCnpj    = cnpj.substring(0,8);
                    segurado.pessoa.dadosPessoaJuridica.numeroCnpj   = cnpj.substring(8,12);
                    segurado.pessoa.dadosPessoaJuridica.digitoCnpj   = cnpj.substring(12,14);
                }

                if(seguradoGP.ResponsavelPagamento__c != null){
                    segurado.dadosPagamento   = this.parseDadosPagamentoReenvio('Segurado', null, seguradoGP, mapRecordType);
                }   
                
                segurado.beneficiarios     = this.parseDadosBeneficiarioSeguradoReenvio(BeneficiarioSeguradoPropostaDAO.getInstance().buscarBeneficiariosSeguradoProposta(new Set<String>{String.valueOf(seguradoGP.Id)}));               
                segurado.coberturas	    = this.parseDadosCoberturasReenvio(GarantiaPropostaDAO.getInstance().buscarGruposPropostaPorIds(new Set<Id>{idProposta}), idRamo);                
                segurado.pessoa.telefones = this.parseDadosTelefoneReenvio(seguradoGP.Conta__r);

                segurados.add(segurado);

                if(!Test.isRunningTest()){
                    mapRenda.put(seguradoGP.Conta__c, seguradoGP.FaixaRenda__c);
                    mapExposta.put(seguradoGP.Conta__c, seguradoGP.PEP__c);
                }
            }

            return segurados;
        }
        catch(Exception e)
        {
            system.debug(e.getLineNumber() + ': ' + e.getMessage());
            throw new ContractException(e.getLineNumber() + ': ' + e.getMessage()  + '(Erro mapeamento segurados grupo)');
        }
    }

    public List<ReenvioContratoTO.CoberturasTO> parseDadosCoberturasReenvio(List<GarantiaProposta__c> garantias, Id idRamoSeguro)
    {
        try
        {
            List<ReenvioContratoTO.CoberturasTO> coberturas;

            Set<Id> idsGarantiaProduto = new Set<Id>();

            for(GarantiaProposta__c garantia : garantias)
            {
                idsGarantiaProduto.add(garantia.GarantiaProduto__c);
            } 

            Map<String, List<CarenciaGarantia__c>> mapCarenciasGarantia = CarenciaGarantiaDAO.getInstance().buscarMapCarenciasGarantia(idsGarantiaProduto);
            Map<String, List<FranquiaGarantia__c>> mapFranquiasGarantia = FranquiaGarantiaDAO.getInstance().buscarMapFranquiasGarantia(idsGarantiaProduto);            

            for(GarantiaProposta__c garantia : garantias)
            {
                ReenvioContratoTO.CoberturasTO cobertura = new ReenvioContratoTO.CoberturasTO();
             
                cobertura.sigla                             = garantia.Garantia__r.Sigla__c;
                cobertura.clausulaReducaoFranquiaAcidente   = 'SIM';
                cobertura.valor                             = garantia.Capital__c;
                cobertura.descricaoGarantia                 = garantia.Garantia__r.Name;
                cobertura.numeroSorte                       = garantia.NumeroSorte__c;
                cobertura.numeroSerie                       = garantia.NumeroSerie__c;
                
                if(mapCarenciasGarantia.get(garantia.GarantiaProduto__c) != null){
                    for(CarenciaGarantia__c carenciaGar :  mapCarenciasGarantia.get(garantia.GarantiaProduto__c))
                    {
                        ReenvioContratoTO.CarenciasTO carencia = new ReenvioContratoTO.CarenciasTO();
                    carencia.descricao = carenciaGar.Carencia__r.Descricao__c;

                    if(cobertura.carencias == null) cobertura.carencias = new List<ReenvioContratoTO.CarenciasTO>();

                    cobertura.carencias.add(carencia);
                    }
                }
                
                if(mapFranquiasGarantia.get(garantia.GarantiaProduto__c) != null){
                    for(FranquiaGarantia__c franquiaGar :  mapFranquiasGarantia.get(garantia.GarantiaProduto__c))
                    {
                        ReenvioContratoTO.FranquiasTO franquia = new ReenvioContratoTO.FranquiasTO();
                    franquia.descricao = franquiaGar.Franquia__r.Descricao__c;

                    if(cobertura.franquias == null) cobertura.franquias = new List<ReenvioContratoTO.FranquiasTO>();

                    cobertura.franquias.add(franquia);
                    }                
                }

                if(coberturas == null) coberturas = new List<ReenvioContratoTO.CoberturasTO>();

                coberturas.add(cobertura);
            }

            return coberturas;
        }
        catch(Exception e)
        {
            system.debug(e.getLineNumber() + ': ' + e.getMessage());
            throw new ContractException(e.getLineNumber() + ': ' + e.getMessage()  + '(Erro mapeamento coberturas)');
        }
    }

    public List<ReenvioContratoTO.BeneficiariosTO> parseDadosBeneficiarioSeguradoReenvio(List<BeneficiarioSeguradoProposta__c> beneficiariosVida)
    {
        try
        {
            List<ReenvioContratoTO.BeneficiariosTO> beneficiarios;

            for(BeneficiarioSeguradoProposta__c beneficiarioVP : beneficiariosVida)
            {
                ReenvioContratoTO.BeneficiariosTO beneficiario = new ReenvioContratoTO.BeneficiariosTO();
                beneficiario.nome                       = beneficiarioVP.Nome__c;
                beneficiario.cpfCnpj                    = beneficiarioVP.CpfCnpj__c;
                beneficiario.participacao               = beneficiarioVP.Participacao__c;
                beneficiario.Pep                        = beneficiarioVP.Pep__c;
                beneficiario.grauParentesco             = beneficiarioVP.GrauParentesco__c;
                beneficiario.tipoBeneficiario           = beneficiarioVP.TipoBeneficiario__c;

                if(beneficiarios == null)
                    beneficiarios = new List<ReenvioContratoTO.BeneficiariosTO>();
                beneficiarios.add(beneficiario);
            }

            return beneficiarios;
        }
        catch(Exception e)
        {
            system.debug(e.getLineNumber() + ': ' + e.getMessage());
            throw new ContractException(e.getLineNumber() + ': ' + e.getMessage()  + '(Erro mapeamento beneficiarios segurado)');
        }
    }

    public Integer retornarNumeroEndosso(List<Contract> listContractNew) {
                
        if (listContractNew.size() == 0 ) {
            return 0;
        }

        String sEndosso = listContractNew[0].Endosso__c;
        System.debug('==> no. endosso: ' + sEndosso);

        if (sEndosso == null) {
            return 0;
        }

        if (Integer.valueOf(sEndosso) <= 0) {
            return 0;
        }

        return Integer.valueOf(sEndosso);
    }

    @TestVisible public Decimal calculaPremioLiquido(Decimal premioTotal, Decimal valorIof){
            
        if(premioTotal != null && valorIof != null){
        
        try {
                   
                if(premioTotal == 0){
                    return 0;
                }
                
                    Decimal result  = (premioTotal - valorIof);
                    return result.setscale(2);
                }catch(exception e){
                    return 0;
                }
        }else{
            return 0;
        }
    } 
        
    public List<ReenvioContratoTO.AlteracoesEndossoTO> parseDadosAlteracoesEndossoReenvio(Quote cotacao){
            
        List<ReenvioContratoTO.AlteracoesEndossoTO> lstEndosso = new List<ReenvioContratoTO.AlteracoesEndossoTO>();

        try {   
                String listSigla = '';

                listSigla = [SELECT Id, SiglaTipoEndosso__c FROM Quote WHERE Id =: cotacao.Id].SiglaTipoEndosso__c;
                
                if(listSigla != null){
    
                    Set<String> endossoList = new Set<String>();
                    endossoList.addAll(listSigla.split(';'));                    
                    
                    for(TipoDeEndosso__mdt tipoEndossoMetadata : [SELECT Id, Prioridade__c, SiglaSalesforce__c, TipoEndossoBCP__c FROM TipoDeEndosso__mdt ORDER BY Prioridade__c ASC]){
                        if(tipoEndossoMetadata.TipoEndossoBCP__c != null && endossoList.contains(tipoEndossoMetadata.SiglaSalesforce__c)){
                            ReenvioContratoTO.AlteracoesEndossoTO endosso = new ReenvioContratoTO.AlteracoesEndossoTO();
                            endosso.sigla = tipoEndossoMetadata.SiglaSalesforce__c;
                            endosso.codigoBCP = Integer.valueOf(tipoEndossoMetadata.TipoEndossoBCP__c);
                            endosso.ordem = Integer.valueOf(tipoEndossoMetadata.Prioridade__c);
                            
                            lstEndosso.add(endosso);
                        } 
                    }
                    return lstEndosso;
                }else{
                    return lstEndosso;
                }
    
            } catch(Exception e) {
                throw new ContractException(e.getLineNumber() + ': ' + e.getMessage()  + '(Ocorreu um erro:\nClasse: ContractFacade \nMétodo: parseDadosAlteracoesEndosso)');
            }
        }
        
    public class ContractException extends Exception {}
}



//LECVP-72 - FIM