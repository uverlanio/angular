/**************************************************************************************************************************************************************************
 *
 *  Classe responsável pelo negócio do objeto de Account
 *
 **************************************************************************************************************************************************************************/
public virtual without sharing class AccountBO //FNPVVEP-126 INICIO-FIM
{
    private final String    SEXO_FEM                = 'FEM';
    private final String    SEXO_MASC               = 'MASC';
    private final String    ESTADO_CIVIL_CASADO         = 'CAS';
    private final String    ESTADO_CIVIL_SOLTEIRO       = 'SOL';
    private final String    ESTADO_CIVIL_DIVORCIADO     = 'DIV';
    private final String    ESTADO_CIVIL_UNIAO_ESTAVEL  = 'UNI';
    private final String    ESTADO_CIVIL_VIUVO          = 'VIU';
    private final String    ESTADO_CIVIL_DESQUITADO     = 'DSQ';
    private final String    ESTADO_CIVIL_NAO_INFORMADO  = 'IGN';
    private final String    ESTADO_CIVIL_MARITALMENTE   = 'MRT';
    private final String    NACIONALIDADE_BRASILEIRA    = 'BRA';
    private final String    CANAL_CORRETOR              = 'COR';
    private final String    PESSOA_FISICA               = 'FIS';
    private final String    PESSOA_JURIDICA             = 'JUR';
    private final String    PRINCIPAL                   = 'PRI';
    Map<String, String> mapEstadoCivil = new Map<String, String>
    {
            ESTADO_CIVIL_CASADO => 'Casado (a)',
            ESTADO_CIVIL_DIVORCIADO => 'Divorciado(a)',
            ESTADO_CIVIL_SOLTEIRO => 'Solteiro (a)',
            ESTADO_CIVIL_UNIAO_ESTAVEL => 'União estável',
            ESTADO_CIVIL_VIUVO => 'Viúvo(a)',
            ESTADO_CIVIL_DESQUITADO => 'Desquitado(a)',
            ESTADO_CIVIL_NAO_INFORMADO => 'Não informado',
            ESTADO_CIVIL_MARITALMENTE => 'Vive maritalmente'

    };

    //PLV2365: INICIO
    //PLV2365: INICIO
    Map<String, String> mapEstadoCivilSaida = new Map<String, String>
    {
             'Casado (a)' => ESTADO_CIVIL_CASADO,
             'Divorciado(a)' => ESTADO_CIVIL_DIVORCIADO,
             'Solteiro (a)' => ESTADO_CIVIL_SOLTEIRO,
             'União estável' => ESTADO_CIVIL_UNIAO_ESTAVEL,
             'Viúvo(a)' => ESTADO_CIVIL_VIUVO,
             'Desquitado(a)' => ESTADO_CIVIL_DESQUITADO,
             'Não informado' => ESTADO_CIVIL_NAO_INFORMADO,
             'Vive maritalmente' => ESTADO_CIVIL_MARITALMENTE
    };
    //PLV2365: FIM
    //PLV2365: FIM

    // PLV-2327 - INICIO
    Map<String, String> mapTipoEndereco = new Map<String, String>
    {'COM' => 'Comercial', 'REC' => 'Recado', 'RES' => 'Residencial', 'VER' => 'Veraneio'};
    Map<String, String> mapTipoLogradouro = new Map<String, String>
    {'A' => 'Alameda', 'AV' => 'Avenida', 'R' => 'Rua'};
    // PLV-2327 - INICIO

    private static final AccountBO instancia = new AccountBO();
    private AccountDAO dao = AccountDAO.getInstance();

    public AccountBO() { }

    public static AccountBO getInstance(){
        return instancia;
    }

    /**
     * Busca uma conta e suas informações bancarias
     *
     * @param   contaId - Id da conta as ser buscada
     */
    public Account buscarContaInfomacoesBancarias(Id contaId){
        Account conta;

        try {
            conta = dao.buscarContasComFilhos(new Set<Id>{contaId}).get(0);
        } catch(Exception ex) {
            throw new AccountException('Conta não encontrada ' + ex.getMessage());
        }

        return conta;
    }

    //Busca contas e seus filhos através das ids das contas
    public List<Account> buscarContasComFilhos(Set<Id> contaIds){
        List<Account> contas;

        try {
            contas = dao.buscarContasComFilhos(contaIds);
        } catch(Exception ex) {
            throw new AccountException('Conta não encontrada ' + ex.getMessage());
        }

        return contas;
    }

    /**
     * Busca metadados de servicos papel
     *
     */
    public List<ServicoPapel__mdt> buscarServicosPapel(){
        return MetadataDAO.getInstance().buscarServicosPapel();
    }

    /**
   * Realiza insert/update das informações geradas pelo componente de Associação de papéis
   *
   * @param   conta - conta as ter os dados atualizados
   * @param   infoBancariosPapeis  - lista contendo as informações bancarias de acordo com os papeis escolhidos
   */
    public void inserirAssociacaoPapeis(Account conta, List<InformacaoBancaria__c> infoBancariosPapeis){
        update conta;

        if(!infoBancariosPapeis.isEmpty()){
            upsert infoBancariosPapeis;
        }
    }

    /**
   * Realiza exclusão de um papel e suas dependencias associadas a conta
   *
   * @param   contaId - id da conta a ter os dados atualizados
   * @param   papel  - nome do papel a ser removido
   */
    public void excluirAssociacaoPapel(Id contaId, String papel){
        Account conta = this.buscarContaInfomacoesBancarias(contaId);
        List<InformacaoBancaria__c> dadosBancariosExcluir = new List<InformacaoBancaria__c>();
		
        //Verifca se o papel a ser excluido existe na conta
        if(String.isNotBlank(conta.Papel__c) && conta.Papel__c.containsIgnoreCase(papel)){
            //Encontra dados bancarios (se houver) de acordo com o papel
            dadosBancariosExcluir.addAll(this.encontrarInfoBancariasPapel(conta.InformacoesBancarias__r, papel));

            //O papel de Agenciador apenas possui dados bancarios, logo não entra na cadeia de if/else
            // PLV-4473 - INICIO
            Account tempAccount = new Account(Id = conta.Id, Papel__c = conta.Papel__c);
            if(papel == 'Corretor'){
                tempAccount.CodigoSusepCorretor__c = '';
                tempAccount.Sucursal__c ='';
                tempAccount.CodigoSusepCia__c = '';
            }
            else if(papel == 'Prestador'){
                tempAccount.NumeroContratoPrestador__c = '';
                tempAccount.ServicosPrestador__c = '';
            }
            else if(papel == 'Parceiro'){
                tempAccount.NumeroContratoParceiro__c = '';
                tempAccount.ServicosParceiro__c = '';
            }
            else if(papel == 'Representante de Seguros'){
                tempAccount.NumeroContratoRespresentante__c = '';
            }

            //Remove o papel
            tempAccount.Papel__c = conta.Papel__c.replace(papel + ';', '');
            
            update tempAccount;
            // PLV-4473 - FIM
            
            if(!dadosBancariosExcluir.isEmpty()){
                Database.delete(dadosBancariosExcluir, false);
            }
        }
    }

    //Encontra as informações bancarias referente a um papel
    private List<InformacaoBancaria__c> encontrarInfoBancariasPapel(List<InformacaoBancaria__c> infoBancarias, String papel){
        List<InformacaoBancaria__c> dadosBancarios = new List<InformacaoBancaria__c>();

        for(InformacaoBancaria__c infoBancaria : infoBancarias){
            if(infoBancaria.Papel__c == papel){
                dadosBancarios.add(infoBancaria);
            }
        }

        return dadosBancarios;
    }

    //Verifica se um papel deve ter informações bancarias
    public void analisarPapeisInformacoesBancarias(List<Account> contas) {
        Set<Id> contasIds = new Set<Id>();
        List<InformacaoBancaria__c> infoBancarias = new List<InformacaoBancaria__c>();
        Map<Id, Account> contasUpdate = new Map<Id, Account>();
        Map<String, Boolean> manterDadosBancarios = new Map<String, Boolean>();

        for(Account conta : contas){
            if(String.isNotBlank(conta.Papel__c)){
                contasIds.add(conta.Id);
                manterDadosBancarios.put(conta.Id + 'Parceiro', conta.Papel__c.contains('Parceiro'));
                manterDadosBancarios.put(conta.Id + 'Prestador', conta.Papel__c.contains('Prestador'));
                manterDadosBancarios.put(conta.Id + 'Agenciador', conta.Papel__c.contains('Agenciador'));
                manterDadosBancarios.put(conta.Id + 'Corretor', conta.Papel__c.contains('Corretor'));
                manterDadosBancarios.put(conta.Id + 'Representante de Seguros', conta.Papel__c.contains('Representante de Seguros'));
            }
        }


        if(!contasIds.isEmpty()){
            for(Account conta : dao.buscarContasComFilhos1(contasIds)){
                Boolean manterDadosPrestador = manterDadosBancarios.get(conta.Id + 'Prestador');
                Boolean manterDadosParceiro = manterDadosBancarios.get(conta.Id + 'Parceiro');
                Boolean manterDadosAgenciador = manterDadosBancarios.get(conta.Id + 'Agenciador');
                Boolean manterDadosCorretor = manterDadosBancarios.get(conta.Id + 'Corretor');
                Boolean manterDadosRepresentante = manterDadosBancarios.get(conta.Id + 'Representante de Seguros');

                if(!manterDadosCorretor){
                    conta.CodigoSusepCorretor__c = '';
                    conta.Sucursal__c ='';
                    conta.CodigoSusepCia__c = '';
                    contasUpdate.put(conta.Id, conta);
                }

                if(!manterDadosRepresentante){
                    conta.NumeroContratoRespresentante__c = '';
                    contasUpdate.put(conta.Id, conta);
                }

                for(InformacaoBancaria__c info : conta.InformacoesBancarias__r){
                    if(info.Papel__c == 'Prestador' && manterDadosPrestador == false){
                        conta.ServicosPrestador__c = '';
                        conta.NumeroContratoPrestador__c = '';
                        infoBancarias.add(info);
                        contasUpdate.put(conta.Id, conta);
                    }
                    else if(info.Papel__c == 'Parceiro' && manterDadosParceiro == false){
                        conta.ServicosParceiro__c = '';
                        conta.NumeroContratoParceiro__c = '';
                        infoBancarias.add(info);
                        contasUpdate.put(conta.Id, conta);
                    }
                    else if(info.Papel__c == 'Agenciador' && manterDadosAgenciador == false){
                        infoBancarias.add(info);
                    }
                }
            }

            if(!infoBancarias.isEmpty()){
                Database.delete(infoBancarias, false);
            }

            if(!contasUpdate.isEmpty()){
                TriggerHandler.bypass('AccountTriggerHandler');
                update contasUpdate.values();
            }
        }
    }

    public void sincronizarDadosEmpresaSeguro() {
        List<Account> contasParaSincronizar = new List<Account>();

        Id tipoPessoaJuridica = RecordTypeBO.buscarTipoRegistro('Account', 'PessoaJuridica').Id;

        for(ServiceTO.EmpresaSeguroTO empresaSeguro : F5Service.getInstance().buscarEmpresasSeguro()) {
            //System.debug('::: empresaSeguro: ' + empresaSeguro);
            if (empresaSeguro.numeroCpfCnpj != null && empresaSeguro.ordem != null && empresaSeguro.digitoCpfCnpj != null) {
                String raiz = empresaSeguro.numeroCpfCnpj;//.leftPad(8, '0');
                String ordem = empresaSeguro.ordem.leftPad(4, '0');
                String digito = empresaSeguro.digitoCpfCnpj.leftPad(2, '0');

                String cnpj = raiz + ordem + digito;

                contasParaSincronizar.add(
                        new Account(
                                Name = empresaSeguro.nomeEmpresa,
                                CodigoEmpresa__c = empresaSeguro.codigoEmpresa,
                                Cnpj__c = cnpj,
                                NumeroInscricao__c = empresaSeguro.numeroInscricaoEstadual,
                                RecordTypeId = tipoPessoaJuridica,
                                Type = 'Empresa do grupo'
                        )
                );
            }
        }

        /*
        System.debug('::: contasParaSincronizar: ' + contasParaSincronizar);

        System.debug('##################################################');
        Integer contador = 1;
        for (Account a : contasParaSincronizar) {
            System.debug('::: contador: ' + contador++);
            System.debug('::: a.Name: ' + a.Name);
            System.debug('::: a.CodigoEmpresa__c: ' + a.CodigoEmpresa__c);
            System.debug('::: a.Cnpj__c: ' + a.Cnpj__c);
            System.debug('##################################################');
        }
        */

        if(!contasParaSincronizar.isEmpty()) {
            List<Database.UpsertResult> resultados = Database.upsert(contasParaSincronizar, Account.CodigoEmpresa__c, false);

            Boolean flag = false;
            for(Database.UpsertResult resultado : resultados) {
                if(!resultado.isSuccess()) {
                    System.debug('::: resultado: ' + resultado);
                }
                else {
                    flag = true;
                }
            }

            if (flag) {
                IntegracaoBO.getInstance().atualizarUltimaExecucao('Account');
            }
        }
    }
    //PLV-2720 - Inicio - Adição de parâmetro
    public Account preencherDadosContaPessoaFisica(Id contaPai, String nome, String email, String cpf, String rg, Date dataExpedicao, String orgaoExpedidor, Date dataNascimento, String estadoCivil, String nacionalidade, String profissao, String sexo, Boolean fumante, String paisDeOrigem) {  //PLV-5231 INICIO/FIM
    //PLV-2720 - Fim - Adição de parâmetro 
        Id tipoRegistroPessoaFisica = RecordTypeBO.buscarTipoRegistro('Account', 'PessoaFisica').Id;

        //PLV-3054 - Inicio - Codigo removido

        // if(objProfissao == null){
        //  throw new AccountException('Profissão ' + profissao + ' não encontrada ou não ativada.');
        // }
        //List<String> arrNome = nome.split(' ');
        //String primeiroNome = nome;
        //String ultimoNome = nome;

        ////if(arrNome.size() > 1){
        ////    primeiroNome = arrNome.get(0);
        ////    ultimoNome = arrNome.get(1);
        ////}
        ////else{
        ////    primeiroNome = arrNome.get(0);
        ////    ultimoNome = arrNome.get(0);
        ////}
        

        //INICIO | PLV-2381-28
        email = this.validaEmail(email);
        //FIM | PLV-2381-28

        System.debug('CPF INSERIDO '+ cpf);

        return new Account(
                //FirstName = primeiroNome,
                LastName = nome,
                PersonEmail = email,
                Cpf__c = cpf,
                IdExterno__c = cpf.replace('.', '').replace('-', ''),
                Rg__c = rg,
                DataExpedicao__c = dataExpedicao,
                OrgaoExpedidor__c = orgaoExpedidor,
                PersonBirthDate = dataNascimento,
                EstadoCivil__c = estadoCivil,
                Nacionalidade__c = nacionalidade,                
                //PLV-3054 - Inicio - Inclusão da profissao na conta
                Profissao__pr = profissao != null ? new Profissao__c(CodigoProfissao__c = profissao) : null,
                Profissao__r = profissao != null ? new Profissao__c(CodigoProfissao__c = profissao) : null,
                //PLV-3054 - Fim - Inclusão da profissao na conta
                Sexo__c = sexo,
                // PLV-2930 Obrigatoriedade Fumante - INICIO
                Fumante__c = fumante == null ? 'Não' : fumante ? 'Sim': 'Não',
                // PLV-2930 Obrigatoriedade Fumante - FIM
                ParentId = contaPai,
                RecordTypeId = tipoRegistroPessoaFisica,
                PaisDeOrigem__c = paisDeOrigem != null ? paisDeOrigem : null //PLV-5231 INICIO/FIM
        );
    }

    public Account preencherDadosContaPessoaJuridica(Id contaPai, String nome, String cnpj) {
        Id tipoRegistroPessoaJuridica = RecordTypeBO.buscarTipoRegistro('Account', 'PessoaJuridica').Id;

        return new Account(
                Name = nome,
                Cnpj__c = cnpj,
                IdExterno__c = cnpj.replace('.', '').replace('-', '').replace('/', ''),
                ParentId = contaPai,
                RecordTypeId = tipoRegistroPessoaJuridica
        );
    }

    //Salva as contas geradas pelo processo de oferta
    public void salvarContasOferta(List<Account> contas)
    {
        List<Account> contasPJ = new List<Account>();
        List<Account> contasPF = new List<Account>();
        Set<String> idsExternos = new Set<String>();

        //Verifica se as contas já não existem
        for(Account conta : contas){
            idsExternos.add(conta.IdExterno__c);
        }
        
        
        System.debug('===> iD externo -> ' + idsExternos);
        System.debug('===> conta -> ' + [SELECT Id, IdExterno__c FROM Account]);

        List<Account> contasExistentes = dao.buscarContasPorIdExterno(idsExternos);
        System.debug('>>> contasExistentes : ' + contasExistentes);

        for(Account conta : contas)
        {
            if(String.isBlank(conta.Cnpj__c))
                contasPF.add(conta);
            else
                contasPJ.add(conta);
        }

        System.debug('::: contasPJ: ' + JSON.serialize(contasPJ));
		System.debug('CONTAS PF: ' + contasPF); 

        if(contasPJ != null)
        {
            if (contasPJ.size() > 0)
            {
                List<Database.UpsertResult> upsertContasPJ = Database.upsert(contasPJ, Account.IdExterno__c, false);

                for(Database.UpsertResult resultado : upsertContasPJ)
                {
                    if (!resultado.isSuccess()) {
                        String erros = '';

                        for(Database.Error  erro : resultado.getErrors()){
                            erros = erro.getMessage() + '; ';
                        }

                        System.debug('ERRO CONTA PJ ' + erros);

                        if(contas.size() == contasExistentes.size()){
                            contas = contasExistentes;   
                        }
                        else{
                            throw new AccountException('Erro ao inserir/atualizar conta pessoa jurídica. ' + erros);
                        }
                    }
                }
            }
        }
        if(contasPF != null)
        {
            if (contasPF.size() > 0)
            {
                List<Database.UpsertResult> upsertContasPF = Database.upsert(contasPF, Account.IdExterno__c, false);

                for(Database.UpsertResult resultado : upsertContasPF)
                {
                    if (!resultado.isSuccess())
                    {
                        String erros = '';

                        for(Database.Error  erro : resultado.getErrors()){
                            erros = erro.getMessage() + '; ';
                        }

                        System.debug('ERRO CONTA PF ' + erros);                            

                        if(contas.size() == contasExistentes.size()){
                            contas = contasExistentes;   
                        }
                        else{
                            throw new AccountException('Erro ao inserir/atualizar conta pessoa física. ' + erros);
                        }    
                    }
                }
            }
        }
    }

    //Salva os endereços das conta 
    public void salvarEnderecosContas(List<Endereco__c> enderecosContas) {

        System.debug('salvarEnderecosContas ->enderecosContas: ' + enderecosContas);

        if (enderecosContas.size() > 0) {

            try {
                //PLV-2727 - Inicio
                List<Endereco__c> lEnderecoIdExterno = new List<Endereco__c>();
                List<Endereco__c> lEndereco = new List<Endereco__c>();
                for (Endereco__c endereco : enderecosContas) {
                    if(endereco.IdExterno__c != null) {
                        lEnderecoIdExterno.add(endereco);
                    }else {
                        lEndereco.add(endereco);
                    }
                }
            
                if (lEnderecoIdExterno.size() > 0) {
                    upsert lEnderecoIdExterno IdExterno__c;
                }

                if(lEndereco.size() > 0){
                    upsert lEndereco;
                }
            //PLV-2727 - Fim
            } catch(Exception e) {
                System.debug(e.getMessage());
                throw new AccountException('Erro ao inserir/atualizar os endereços das contas. ' + e.getMessage());
            }

            //List<Database.UpsertResult> upsertEnderecos = Database.upsert(enderecosContas, Endereco__c.Id, false);

            //for(Database.UpsertResult resultado : upsertEnderecos) {
            //    if (!resultado.isSuccess()) {
            //        System.debug('::: Erros' + resultado.getErrors());
            //        throw new AccountException('Erro ao inserir/atualizar os endereços das contas.');
            //    }
            //}
        }
    }

    public List<Account> buscarEmpresasGrupoPorto() {
        return dao.buscarEmpresasGrupoPorto();
    }

    public List<Account> buscarContasPorPapel(String papel) {
        return dao.buscarContasPorPapel(papel);
    }

    //Gera conta através de PessoaTO
    public Account geraResponsavelPagamento(EmissaoTO.ContratanteTO contratante, EmissaoTO.SeguradoTO segurado)
    {
        Account conta;

        // 2666 - INICIO
        //EmissaoTO.ResponsavelpagamentoTO dadosResponsavelPGTO;
        // 2666 - FIM
        EmissaoTO.DadosPessoaFisicaTO dadosPessoaFisica;
        EmissaoTO.DadosPessoaJuridicaTO dadosPessoaJuridica;


//        Map<String, String> mapEstadoCivil = new Map<String, String>
//        {
//            ESTADO_CIVIL_CASADO => 'Casado (a)',
//            ESTADO_CIVIL_DIVORCIADO => 'Divorciado(a)',
//            ESTADO_CIVIL_SOLTEIRO => 'Solteiro (a)',
//            ESTADO_CIVIL_UNIAO_ESTAVEL => 'União estável',
//            ESTADO_CIVIL_VIUVO => 'Viúvo(a)',
//          ESTADO_CIVIL_DESQUITADO => 'Desquitado(a)',
//          ESTADO_CIVIL_IGNORADO => 'Ignorado(a)',
//          ESTADO_CIVIL_MARITALMENTE => 'Vive maritalmente'
//
//        };

		system.debug('contratante: '+contratante);
        system.debug('contratante.pessoa: '+contratante.pessoa.tipo);

        if (contratante != null && contratante.pessoa.tipo == PESSOA_FISICA)
        {
            dadosPessoaFisica               = contratante.dadosPagamento.responsavelPagamento.dadosPessoaFisica;
            String sexoConta                = dadosPessoaFisica.sexo == SEXO_MASC ? 'MASC' : 'FEM';
            System.debug('Alexandre Nacionalidade 1 >>> ' + dadosPessoaFisica.nacionalidade);
            dadosPessoaFisica.nacionalidade = String.isBlank(dadosPessoaFisica.nacionalidade) ? NACIONALIDADE_BRASILEIRA : dadosPessoaFisica.nacionalidade;
            dadosPessoaFisica.paisDeOrigem  = String.isBlank(dadosPessoaFisica.paisDeOrigem) ? '' : dadosPessoaFisica.paisDeOrigem; //PLV-5231 INICIO/FIM
            String nacionalidadeConta       = dadosPessoaFisica.nacionalidade == NACIONALIDADE_BRASILEIRA ? 'Brasileira' : 'Estrangeira';
            System.debug('Alexandre NacionalidadeConta 2 >>> ' + nacionalidadeConta);
            System.debug('Alexandre dadosPessoaFisica.paisDeOrigem >>> ' + dadosPessoaFisica.paisDeOrigem);
            //INICIO | PLV-2381-28
            contratante.pessoa.email = this.validaEmail(contratante.pessoa.email);
            //FIM | PLV-2381-28

            conta = this.preencherDadosContaPessoaFisica
                    (
                            null,//contaPaiId,
                            contratante.dadosPagamento.responsavelPagamento.nome,
                            '',//contratante.pessoa.email,
                            dadosPessoaFisica.numeroCpf + dadosPessoaFisica.digitoCpf,
                            '',//dadosPessoaFisica.documentos[0].numeroDocumentoIdentidade,
                            null,//Date.valueOf(dadosPessoaFisica.documentos[0].dataExpedicaoDocumento),
                            '',//dadosPessoaFisica.documentos[0].orgaoExpedidorDocumento,
                            null,//Date.valueOf(dadosPessoaFisica.dataNascimento),
                            mapEstadoCivil.get(dadosPessoaFisica.estadoCivil),
                            nacionalidadeConta,                            
                            dadosPessoaFisica.profissao,
                            sexoConta,
                            //PLV-2720 - Inicio - Adição de parâmetro
                            //PLV-5231 INICIO
                            false,
                            dadosPessoaFisica.paisDeOrigem 
                            //PLV-5231 FIM
                            //PLV-2720 - Fim - Adição de parâmetro
                    );


        }
        else if (contratante != null && contratante.pessoa.tipo == PESSOA_JURIDICA)
        {
            dadosPessoaJuridica = contratante.dadosPagamento.responsavelPagamento.dadosPessoaJuridica;
            conta = this.preencherDadosContaPessoaJuridica(null, contratante.dadosPagamento.responsavelPagamento.nome, dadosPessoaJuridica.cnpj);
        }


        if (segurado != null && segurado.pessoa.tipo == PESSOA_FISICA)
        {
            dadosPessoaFisica               = segurado.dadosPagamento.responsavelPagamento.dadosPessoaFisica;
            String sexoConta                = dadosPessoaFisica.sexo == SEXO_MASC ? 'MASC' : 'FEM';
            System.debug('Alexandre Nacionalidade 3 >>> ' + dadosPessoaFisica.nacionalidade);
            dadosPessoaFisica.nacionalidade = String.isBlank(dadosPessoaFisica.nacionalidade) ? NACIONALIDADE_BRASILEIRA : dadosPessoaFisica.nacionalidade;
            dadosPessoaFisica.paisDeOrigem  = String.isBlank(dadosPessoaFisica.paisDeOrigem) ? '' : dadosPessoaFisica.paisDeOrigem; //PLV-5231 INICIO/FIM
            String nacionalidadeConta       = dadosPessoaFisica.nacionalidade == NACIONALIDADE_BRASILEIRA ? 'Brasileira' : 'Estrangeira';
            System.debug('Alexandre NacionalidadeConta 4 >>> ' + nacionalidadeConta);
            //INICIO | PLV-2381-28
            segurado.pessoa.email = this.validaEmail(segurado.pessoa.email);
            //FIM | PLV-2381-28
            conta = this.preencherDadosContaPessoaFisica
                    (
                            null,//contaPaiId,
                            segurado.dadosPagamento.responsavelPagamento.nome,
                            '',//segurado.pessoa.email,
                            dadosPessoaFisica.numeroCpf + dadosPessoaFisica.digitoCpf,
                            '',//dadosPessoaFisica.documentos[0].numeroDocumentoIdentidade,
                            null,//Date.valueOf(dadosPessoaFisica.documentos[0].dataExpedicaoDocumento),
                            '',//dadosPessoaFisica.documentos[0].orgaoExpedidorDocumento,
                            null,//Date.valueOf(dadosPessoaFisica.dataNascimento),
                            mapEstadoCivil.get(dadosPessoaFisica.estadoCivil),
                            nacionalidadeConta,                            
                            dadosPessoaFisica.profissao,
                            sexoConta,
                            //PLV-5231 INICIO
                            false,
                            dadosPessoaFisica.paisDeOrigem 
                            //PLV-5231 FIM
                    );
        }
        else if (segurado != null && segurado.pessoa.tipo == PESSOA_JURIDICA)
        {
            dadosPessoaJuridica = segurado.dadosPagamento.responsavelPagamento.dadosPessoaJuridica;
            conta = this.preencherDadosContaPessoaJuridica(null, segurado.dadosPagamento.responsavelPagamento.nome, dadosPessoaJuridica.cnpj);
        }

        conta.Renda__c = contratante.pessoa.rendaMensal;

        return conta;
    }

    //Gera conta através de PessoaTO
    public Account gerarParseConta(EmissaoTO.SeguradoTO segurado, Id contaPaiId, Boolean contaPrincipal)
    {
        System.debug('::: gerarParseConta, nome: ' + segurado.pessoa.nome);

        Account conta;
        EmissaoTO.DadosPessoaJuridicaTO dadosPessoaJuridica;
        EmissaoTO.DadosPessoaFisicaTO dadosPessoaFisica;

        if (segurado.pessoa.tipo == PESSOA_FISICA)
        {
            dadosPessoaFisica           = segurado.pessoa.dadosPessoaFisica;
            String sexoConta            = dadosPessoaFisica.sexo == SEXO_MASC ? 'MASC' : 'FEM';
            System.debug('Alexandre Nacionalidade 5 >>> ' + dadosPessoaFisica.nacionalidade);
            dadosPessoaFisica.nacionalidade = String.isBlank(dadosPessoaFisica.nacionalidade) ? NACIONALIDADE_BRASILEIRA : dadosPessoaFisica.nacionalidade;
            dadosPessoaFisica.paisDeOrigem  = String.isBlank(dadosPessoaFisica.paisDeOrigem) ? '' : dadosPessoaFisica.paisDeOrigem; //PLV-5231 INICIO/FIM
            String nacionalidadeConta   = dadosPessoaFisica.nacionalidade == NACIONALIDADE_BRASILEIRA ? 'Brasileira' : 'Estrangeira';
            System.debug('Alexandre NacionalidadeConta 6 >>> ' + nacionalidadeConta);

            //INICIO | PLV-2381-28
            segurado.pessoa.email = this.validaEmail(segurado.pessoa.email);
            //FIM | PLV-2381-28

            conta = this.preencherDadosContaPessoaFisica(
                    null,
                    segurado.pessoa.nome,
                    segurado.pessoa.email,
                    dadosPessoaFisica.numeroCpf + dadosPessoaFisica.digitoCpf,
                    '',
                    null,
                    '',
                    Date.valueOf(dadosPessoaFisica.dataNascimento),
                    mapEstadoCivil.get(dadosPessoaFisica.estadoCivil),
                    nacionalidadeConta,                    
                    dadosPessoaFisica.profissao,
                    sexoConta,
                    //PLV-2720 - Inicio - Adição de parâmetro
                    //PLV-5231 INICIO
                    false,
                    dadosPessoaFisica.paisDeOrigem 
                    //PLV-5231 FIM
                    //PLV-2720 - Fim - Adição de parâmetro
            );
        }
        else if (segurado.pessoa.tipo == PESSOA_JURIDICA)
        {
            dadosPessoaJuridica = segurado.pessoa.dadosPessoaJuridica;
            conta = this.preencherDadosContaPessoaJuridica(contaPaiId, segurado.pessoa.nome, dadosPessoaJuridica.cnpj);
        }


        conta.Renda__c = segurado.pessoa.rendaMensal;

        return conta;
    }

    public Map<String, Account> gerarContasOferta(EmissaoTO orcamento, Account contaResponsavelOferta, Map<String, List<EmissaoTO.EnderecoTO>> mapEnderecos)
    {
        Map<String, Account> mapRetorno = new Map<String, Account>();
        //Salva conta principal para que seja possível gerar as contas filhas
        
        this.salvarContasOferta(new List<Account>{contaResponsavelOferta});

        // processa os restantes dos contratantes contratante(s)
        List<Account> contas = new List<Account>();
        for(EmissaoTO.ContratanteTO contratante : orcamento.contratantes)
        {
            Account conta = this.gerarParseContaContratante(contratante, contaResponsavelOferta.Id, false);
            mapRetorno.put(contratante.numero, conta);
            if(conta != null)
                contas.add(conta);
        }

        //Salva as outras contas
        this.salvarContasOferta(contas);

        //Realiza criação dos endereços das contas
        contas.add(contaResponsavelOferta);
        EnderecoFacade.getInstance().gerarEnderecosContas(contas, mapEnderecos);

        return mapRetorno;
        //return contaResponsavelOferta.Id;
    }

    //Gera conta através de PessoaTO
    public Account gerarParseContaContratante(EmissaoTO.ContratanteTO contratante, Id contaPaiId, Boolean contaPrincipal)
    {
        System.debug('::: gerarParseConta, nome: ' + contratante.pessoa.nome);
        if(!contaPrincipal && contratante.tipo == PRINCIPAL)
        {
            return null;
        }

        Account conta;
        EmissaoTO.DadosPessoaJuridicaTO dadosPessoaJuridica;
        EmissaoTO.DadosPessoaFisicaTO dadosPessoaFisica;

        if (contratante.pessoa.tipo == PESSOA_FISICA)
        {
            dadosPessoaFisica = contratante.pessoa.dadosPessoaFisica;
            String sexoConta = dadosPessoaFisica.sexo == SEXO_MASC ? 'MASC' : 'FEM';
            System.debug('Alexandre Nacionalidade 7 >>> ' + dadosPessoaFisica.nacionalidade);
            dadosPessoaFisica.nacionalidade = String.isBlank(dadosPessoaFisica.nacionalidade) ? NACIONALIDADE_BRASILEIRA : dadosPessoaFisica.nacionalidade;
            dadosPessoaFisica.paisDeOrigem  = String.isBlank(dadosPessoaFisica.paisDeOrigem) ? '' : dadosPessoaFisica.paisDeOrigem; //PLV-5231 INICIO/FIM
            String nacionalidadeConta = dadosPessoaFisica.nacionalidade == NACIONALIDADE_BRASILEIRA ? 'Brasileira' : 'Estrangeira';
            System.debug('Alexandre NacionalidadeConta 8 >>> ' + nacionalidadeConta);
            // if(dadosPessoaFisica.documentos == null || dadosPessoaFisica.documentos.isEmpty())
            // {
            //     throw new AccountException('CONTA_SEM_DOCUMENTO - Conta não possui documentos');
            // }

            //INICIO | PLV-2381-28
            contratante.pessoa.email = this.validaEmail(contratante.pessoa.email);
            //FIM | PLV-2381-28

            conta = this.preencherDadosContaPessoaFisica
                    (
                            contaPaiId,
                            contratante.pessoa.nome,
                            contratante.pessoa.email,
                            dadosPessoaFisica.numeroCpf + dadosPessoaFisica.digitoCpf,
                            '',//dadosPessoaFisica.documentos[0].numeroDocumentoIdentidade,
                            null,//Date.valueOf(dadosPessoaFisica.documentos[0].dataExpedicaoDocumento),
                            '',//dadosPessoaFisica.documentos[0].orgaoExpedidorDocumento,
                            Date.valueOf(dadosPessoaFisica.dataNascimento),
                            mapEstadoCivil.get(dadosPessoaFisica.estadoCivil),
                            nacionalidadeConta,                            
                            dadosPessoaFisica.profissao,
                            sexoConta,
                            //PLV-5231 INICIO
                            false,
                            dadosPessoaFisica.paisDeOrigem 
                            //PLV-5231 FIM
                    );
        }
        else if (contratante.pessoa.tipo == PESSOA_JURIDICA)
        {
            dadosPessoaJuridica = contratante.pessoa.dadosPessoaJuridica;
            conta = this.preencherDadosContaPessoaJuridica(contaPaiId, contratante.pessoa.nome, dadosPessoaJuridica.cnpj);
        }


        conta.Renda__c = contratante.pessoa.rendaMensal;

        return conta;
    }

    //Gera objeto de conta a partir de um objeto Pessoa: NAO EXCLUIR, SERA USADO
    public Account gerarContaEmissao(EmissaoTO.PessoaTO pessoa, Account contaPai){
        Account conta;
        EmissaoTO.DadosPessoaJuridicaTO dadosPessoaJuridica;
        EmissaoTO.DadosPessoaFisicaTO dadosPessoaFisica;

        Id contaPaiId;

        if(contaPai != null){
            contaPaiId = contaPai.Id;
        }

        if (pessoa.tipo == 'FIS') {
            dadosPessoaFisica = pessoa.dadosPessoaFisica;
            System.debug('Alexandre Nacionalidade 9 >>> ' + dadosPessoaFisica.nacionalidade);
            dadosPessoaFisica.nacionalidade = String.isBlank(dadosPessoaFisica.nacionalidade) ? 'BRA' : dadosPessoaFisica.nacionalidade;
            dadosPessoaFisica.paisDeOrigem  = String.isBlank(dadosPessoaFisica.paisDeOrigem) ? '' : dadosPessoaFisica.paisDeOrigem; //PLV-5231 INICIO/FIM

            if (dadosPessoaFisica.documentos == null || dadosPessoaFisica.documentos.isEmpty())
                throw new AccountException('CONTA_SEM_DOCUMENTO - Conta não possui documentos');
            
            //INICIO | PLV-2381-28
            pessoa.email = this.validaEmail(pessoa.email);
            //FIM | PLV-2381-28

            conta = AccountBO.getInstance().preencherDadosContaPessoaFisica(
                    contaPaiId,
                    pessoa.nome,
                    pessoa.email,
                    dadosPessoaFisica.numeroCpf + dadosPessoaFisica.digitoCpf,
                    dadosPessoaFisica.documentos[0].numeroDocumentoIdentidade,
                    DAte.valueOf(dadosPessoaFisica.documentos[0].dataExpedicaoDocumento),
                    dadosPessoaFisica.documentos[0].orgaoExpedidorDocumento,
                    Date.valueOf(dadosPessoaFisica.dataNascimento),
                    dadosPessoaFisica.estadoCivil,
                    dadosPessoaFisica.nacionalidade,                    
                    dadosPessoaFisica.profissao,
                    dadosPessoaFisica.sexo,
                    //PLV-2720 - Inicio - Adição de parâmetro
                    //PLV-5231 INICIO
                    false,
                    dadosPessoaFisica.paisDeOrigem 
                    //PLV-5231 FIM
                    //PLV-2720 - Fim - Adição de parâmetro
            );
        }
        else if (pessoa.tipo == 'JUR') {
            dadosPessoaJuridica = pessoa.dadosPessoaJuridica;
            conta = this.preencherDadosContaPessoaJuridica(contaPai.Id, pessoa.nome, dadosPessoaJuridica.cnpj);
        }

        // insere os telefones
        for (EmissaoTO.TelefoneTO telefone : pessoa.telefones)
        {
            if(telefone.tipoTelefone == 'RES')
                conta.PersonHomePhone = telefone.dddTelefone + telefone.numeroTelefone;
            else if(telefone.tipoTelefone == 'CEL')
                conta.Phone = telefone.dddTelefone + telefone.numeroTelefone;
            else if(telefone.tipoTelefone == 'COM')
                conta.PersonOtherPhone = telefone.dddTelefone + telefone.numeroTelefone;
            else if(telefone.tipoTelefone == 'FAX')
                conta.Fax = telefone.dddTelefone + telefone.numeroTelefone;
        }

        return conta;
    }

    //Gera lista de endereço de acordo com os endereços: NAO EXCLUIR, SERA USADO
    public List<Endereco__c> gerarEnderecoContaEmissao(List<EmissaoTO.EnderecoTO> enderecos){
        List<Endereco__c> enderecosConta = new List<Endereco__c>();
        //PLV- 2727 - Inicio
        if(enderecos.isEmpty()) return enderecosConta; //PLV-4151

        for(EmissaoTO.EnderecoTO endereco : enderecos){
            if((endereco.cep == null || endereco.cep.trim() == '') || (endereco.complementoCep == null || endereco.complementoCep.trim() == '' )) continue;
        //PLV- 2727 - Fim
            enderecosConta.add(
                    new Endereco__c(
                            //Id = enderecoId,
                            //Conta__c = contaId,
                            TipoEndereco__c = endereco.tipoEndereco,
                            TipoLogradouro__c = endereco.tipoLogradouro,
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

    // Valida o CPF / CNPJ na Inclusão/Alteração da Conta
    public void validarCPFCNPJ(List<Account> contas) {
        //PLV_2826 - INICIO - Criar oportunidade sem conta
      	
        for(Account conta : contas){

                if(String.isNotEmpty(conta.Cpf__c)){
                        
                                if(!Util.isCPF(conta.Cpf__c)){
                                            conta.addError('CPF Inválido');
                                }                                   
                       
                	}              
        //PLV_2826 - FIM - Criar oportunidade sem conta

            if (conta.Cnpj__c != null){
                if (conta.Cnpj__c != ''){
                    if(!Util.isCNPJ(conta.Cnpj__c)){
                        conta.addError('CNPJ Inválido');
                    }
                }
            }
        }
    }

 
    // PLV-2327 - INICIO

    //PLV2365: INICIO

    public String buscarEstadoCivil(String codigo)
    {
        return mapEstadoCivil.get(codigo);
    }
    public String buscarEstadoCivilSaida(String codigo)
    {
        return mapEstadoCivilSaida.get(codigo);
    }
    //PLV2365: FIM


    public String buscarTipoEndereco(String codigo)
    {
        return mapTipoEndereco.get(codigo);
    } 

    public String buscarTipoLogradouro(String codigo)
    {
        return mapTipoLogradouro.get(codigo);
    } 
    // PLV-2327 - INICIO

    //INICIO | PLV-2381-28
    public String validaEmail(String email)
    {
        if(!string.Isblank(email)){
            // expressão regular 
            String emailRegex  =  '^[a-zA-Z0-9._|\\\\%#~`=?&/$^*!}{+-]+@[a-zA-Z0-9.-]+\\.[a-zA-Z]{2,4}$';

            Pattern MyPattern = Pattern.compile(emailRegex);
            Matcher MyMatcher = MyPattern.matcher(email);

            if(!MyMatcher.matches()){
                email = '';
                system.debug('Erro email: '+ email);
            }
        }
          return email;
    }
     //FIM | PLV-2381-28

     //PLV-3748 - INICIO - Novo metodo para ajustar o caso quando for excluir a conta
     public void alteraContatoDoCaso(List<Account> lstAcc){
        
        Set<Id> setAcc = new Set<Id>();
        for(Account acc : lstAcc){
            setAcc.add(acc.Id);
         }

         List<Case> lstCase = [SELECT Id, AccountId FROM Case WHERE Contact.AccountId IN :setAcc];

         if(lstCase.isEmpty()) return;

         Set<Id> setAccIdCase = new Set<Id>();

         for(Case vCaso : lstCase){
             setAccIdCase.add(vCaso.AccountId);
         }

         if(setAccIdCase.isEmpty()) return;

         Map<Id,Account> mapAccCase = new Map<Id,Account>([SELECT Id, (SELECT Id FROM Contacts LIMIT 1) FROM Account WHERE Id IN :setAccIdCase]);
         List<Case> lstCaseUp = new List<Case>();
         for(Case caso : lstCase){
            Account acc = new Account(); 
            if(mapAccCase.containsKey(caso.AccountId)){
                acc = mapAccCase.get(caso.AccountId);
            }
            if(acc.Contacts.isEmpty()){
                Case c = new Case();
                c.Id = caso.Id;
                c.ContactId = null;

                lstCaseUp.add(c);

            } else {
                Case c = new Case();
                c.Id = caso.Id;
                c.ContactId = acc.Contacts.get(0).Id;

                lstCaseUp.add(c);
            }
        }

        Database.update(lstCaseUp);
    }
     //PLV-3748 - FIM

     // ANNVI-55 - INICIO
    /**
     * @param  accountLst  List<Account> -> Trigger.New
     */
    public void validaFormatoTelefone (List<Account> accountLst) {
        /*
            PersonMobilePhone
            PersonOtherPhone
            Phone
            PersonAssistantPhone
            PersonHomePhone
        */
        for (Account tAcc: accountLst) {
            String errorMsg= 'Formato de telefone inválido';

            System.debug('account list '+accountLst);

            if (!testaTelefone(tAcc.PersonMobilePhone)) {
                tAcc.PersonMobilePhone.addError(errorMsg);
            }
            if (!testaTelefone(tAcc.PersonOtherPhone)) {
                tAcc.PersonOtherPhone.addError(errorMsg);
            }
            if (!testaTelefone(tAcc.Phone)) {
                tAcc.Phone.addError(errorMsg);
            }
            if (!testaTelefone(tAcc.PersonAssistantPhone)) {
                tAcc.PersonAssistantPhone.addError(errorMsg);
            }
            if (!testaTelefone(tAcc.PersonHomePhone)) {
                tAcc.PersonHomePhone.addError(errorMsg);
            }
        }
    }

    /**
     * @param   phoneNumber String
     * @return  Boolean
     */
    public Boolean testaTelefone (String phoneNumber) {
        if (phoneNumber == '' || phoneNumber == null) return true;

        String ddd = Util.getPhoneDDD(phoneNumber);
        String phone = Util.getPhoneNumber(phoneNumber);

        phoneNumber = Util.sanitizePhoneNumber(phoneNumber);

        if (!phoneNumber.containsOnly('0123456789')
            || (phoneNumber.length() > 11 || phoneNumber.length() < 10)) {
            return false;
        }

        System.debug('phone: '+ddd+' '+phone+' - '+phoneNumber);

        return true; //  em desenvolvimento
    }
     // ANNVI-55 - FIM

    public class AccountException extends Exception {}
}