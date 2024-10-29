// PLV-2015 Criação da classe
// PLV-4095 - INICIO
public class EnvioSinistroBCP {

    SinistroBCPTO       bcpPayload;
    case                caseSinistro    = new  case();
    contract            contrato        = new contract();
    account contaSin     = new account();
    Map<String,FavorecidoRemuneracaoContrato__c> contrfavMap      = new Map<String,FavorecidoRemuneracaoContrato__c>(); // Map relacionando Id do contrato como chave e favorecido do contrato como valor 
    Map<String,ContratanteContrato__c> conContratanteMap      = new Map<String,ContratanteContrato__c>();
    
    public SinistroBCPTO envioSinistroBCP(Id caseId, String isNewSin){     
        
        buscaRegistros(caseId);
        if( caseSinistro == null ) return null;

        bcpPayload      = new SinistroBCPTO();

        Account     acc = contaSin;
        Endereco__c endereco = new Endereco__c();
        FavorecidoRemuneracaoContrato__c favorecido = contrfavMap.get(caseSinistro.contrato__c);
        ContratanteContrato__c contratante = conContratanteMap.get(caseSinistro.contrato__c);
        
        if ( !acc.Enderecos__r.isEmpty() )   endereco = acc.Enderecos__r[0];

        bcpPayload.sucursal = contrato.Sucursal__c ; 
        bcpPayload.ramo = contrato.CodigoRamo__c ; 
        bcpPayload.apolice = contrato.NumeroApolice__c ; 
        bcpPayload.origemproposta = contrato.Origem__c ; 
        bcpPayload.numeroproposta = contrato.NumeroProposta__c ; 

        bcpPayload.adicionarPessoaProdutoRequest = new SinistroBCPTO.AdicionarPessoaProdutoRequestTO();
        SinistroBCPTO.AdicionarPessoaProdutoRequestTO addPesProd = bcpPayload.adicionarPessoaProdutoRequest;

        addPesProd.codigoOrigemMovimento = '64';  // CodigoOrigemDoMovimentoBCP
        addPesProd.grupoXML = '2';
        addPesProd.dataHoraMoviento = '';

        addPesProd.pessoaProdutoEBO         = new SinistroBCPTO.PessoaProdutoEBOTO();
        SinistroBCPTO.PessoaProdutoEBOTO    pesProdEBO = addPesProd.pessoaProdutoEBO;

        pesProdEBO.nome = acc.Name;

        pesProdEBO.cpfCnpj = new SinistroBCPTO.CpfCnpjTO();
        if(acc.RecordType.DeveloperName == 'PessoaFisica'){
            if (acc.Cpf__c != null) pesProdEBO.cpfCnpj.numeroCnpjCpf = acc.Cpf__c.replace('.','').replace('-','').left(9);
            if (acc.Cpf__c != null) pesProdEBO.cpfCnpj.digitoCnpjCpf =  acc.Cpf__c.right(2);
        }
        if(acc.RecordType.DeveloperName == 'PessoaJuridica'){
            if (acc.Cpf__c != null) pesProdEBO.cpfCnpj.numeroCnpjCpf = acc.Cpf__c.replace('.','').replace('-','').replace('/','').left(12);
            if (acc.Cpf__c != null) pesProdEBO.cpfCnpj.digitoCnpjCpf =  acc.Cpf__c.right(2);
        }
        
        pesProdEBO.papel = '1';
        if(!String.isBlank(acc.Sexo__c))    pesProdEBO.sexo = acc.Sexo__c.substring(0,1);
        pesProdEBO.origem = '64'; //  CodigoOrigemDoMovimentoBCP 
        pesProdEBO.tipoPessoa = (acc.RecordType.DeveloperName == 'PessoaFisica') ? 'F' : 'J' ;
        if (acc.PersonBirthdate != null)  pesProdEBO.nascimento = String.valueOf(acc.PersonBirthdate.format());
        if( acc.EstadoCivil__c == 'Casado (a)')  pesProdEBO.estCivil = '2'; 
        if( acc.EstadoCivil__c == 'Divorciado(a)')  pesProdEBO.estCivil = '4'; 
        if( acc.EstadoCivil__c == 'Solteiro (a)')  pesProdEBO.estCivil = '1'; 
        if( acc.EstadoCivil__c == 'União estável')  pesProdEBO.estCivil = '6'; 
        if( acc.EstadoCivil__c == 'Viúvo(a)')  pesProdEBO.estCivil = '5'; 
        if( acc.EstadoCivil__c == 'Separado(a)')  pesProdEBO.estCivil = '3'; 
        if( acc.EstadoCivil__c == 'Desquitado(a)')  pesProdEBO.estCivil = ''; 
        if( acc.EstadoCivil__c == 'Não informado')  pesProdEBO.estCivil = '0'; 
        if( acc.EstadoCivil__c == 'Vive maritalmente')  pesProdEBO.estCivil = ''; 
        pesProdEBO.situacao = '1';

        pesProdEBO.emailDocumento = new List<SinistroBCPTO.EmailDocumentoTO>();     // mapeamento chama emailDocumento X
        SinistroBCPTO.EmailDocumentoTO emailpes = new SinistroBCPTO.EmailDocumentoTO();
        
        emailpes.emailTip = '1';
        emailpes.email = acc.PersonEmail;
        emailpes.emailFlgOpt = '';
        emailpes.emailDtFlgOpt = '';

        pesProdEBO.emailDocumento.add(emailpes);

        if(!String.isBlank(acc.PersonMobilePhone)){
            
            String cel = acc.PersonMobilePhone.replace(' ', '').replace('(', '').replace(')', '').replace('-', '');
            pesProdEBO.foneTip = '3'; // 1 -RES / 2-COM ou FAX / 3-CEL / 4-REC 
            pesProdEBO.foneDDD = cel.substring(0, 2);
            pesProdEBO.foneNum = cel.substring(2, cel.length());
        }

        if(endereco != null){
            pesProdEBO.enderecoPessoa = new List<SinistroBCPTO.EnderecoPessoaTO>();
            SinistroBCPTO.EnderecoPessoaTO endPes = new SinistroBCPTO.EnderecoPessoaTO();
            endPes.siglPais = endereco.Pais__c;
            endPes.finalidLogr = '1';
            endPes.enderecoCompleto = new SinistroBCPTO.EnderecoCompletoTO();
            endPes.enderecoCompleto.logradouro = endereco.Logradouro__c;
            endPes.enderecoCompleto.numeroLogradouro = endereco.Numero__c;
            endPes.enderecoCompleto.complemento = endereco.Complemento__c;
            endPes.enderecoCompleto.bairro = endereco.Bairro__c;
            endPes.enderecoCompleto.cidade = endereco.Cidade__c;
            endPes.enderecoCompleto.uf = endereco.Estado__c;
            if( !String.isBlank(endereco.CEP__c) )  endPes.enderecoCompleto.cep = endereco.CEP__c.substringBefore('-');
            if( !String.isBlank(endereco.CEP__c) )  endPes.enderecoCompleto.complementoCep = endereco.CEP__c.substringAfter('-');

            pesProdEBO.enderecoPessoa.add(endPes);
        }



        pesProdEBO.deficFlag = new SinistroBCPTO.DeficFlagTO();
        pesProdEBO.deficFlag.flagOpcao = 'N';

        pesProdEBO.documento = new SinistroBCPTO.DocumentoTO();
        SinistroBCPTO.DocumentoTO doc = pesProdEBO.documento;

        doc.empCod = '1';
        if(caseSinistro.Status == 'Aberto' || caseSinistro.Status == 'Avisar' || caseSinistro.Status == 'Avisado' || caseSinistro.Status == 'Em Regulação') doc.status = '1';
        if(caseSinistro.Status == 'Liquidação') doc.status = '3';
        if(caseSinistro.Status == 'Fechado') doc.status = '5';
        doc.dtAtuStatus = ''; //data CIV
        doc.papel = '1';
        doc.prodCod = '64';
        doc.chave = contrato.Sucursal__c + '|' + '64' + '|' + contrato.NumeroApolice__c;
        if(favorecido != null)   doc.susep = favorecido.Susep__c;
        if(contrato.StartDate != null)  doc.iniVig = String.valueOf(contrato.StartDate.format()) ;
        if(contrato.VigenciaFinal__c != null)  doc.fnlVig = String.valueOf(contrato.VigenciaFinal__c.format());
        doc.dtEmiss = ''; // data CIV
        doc.origemPrp = contrato.Origem__c;
        doc.numPrp = contrato.ContractNumber;
        doc.canalVend = '3';
        
        if(endereco != null){
            doc.enderecoDocumento = new List<SinistroBCPTO.EnderecoDocumentoTO>();
            SinistroBCPTO.EnderecoDocumentoTO endDoc = new SinistroBCPTO.EnderecoDocumentoTO();
            endDoc.siglPais = endereco.Pais__c;
            endDoc.finalidLogr = '1';
            endDoc.enderecoCompleto = new SinistroBCPTO.EnderecoCompletoTO();
            endDoc.enderecoCompleto.logradouro = endereco.Logradouro__c;
            endDoc.enderecoCompleto.numeroLogradouro = endereco.Numero__c;
            endDoc.enderecoCompleto.complemento = endereco.Complemento__c;
            endDoc.enderecoCompleto.bairro = endereco.Bairro__c;
            endDoc.enderecoCompleto.cidade = endereco.Cidade__c;
            endDoc.enderecoCompleto.uf = endereco.Estado__c;
            if( !String.isBlank(endereco.CEP__c) )  endDoc.enderecoCompleto.cep = endereco.CEP__c.substringBefore('-');
            if( !String.isBlank(endereco.CEP__c) )  endDoc.enderecoCompleto.complementoCep = endereco.CEP__c.substringAfter('-'); 
            doc.enderecoDocumento.add(endDoc); // mesmo endereco pessoa
        }

        doc.item = new List<SinistroBCPTO.ItemTO>();
        SinistroBCPTO.ItemTO item = new SinistroBCPTO.ItemTO();
        item.numero = '1';
        if(caseSinistro.Status == 'Aberto' || caseSinistro.Status == 'Avisar' || caseSinistro.Status == 'Avisado' || caseSinistro.Status == 'Em Regulação') item.status = '1';
        if(caseSinistro.Status == 'Liquidação') item.status = '3';
        if(caseSinistro.Status == 'Fechado') item.status = '5';
        item.tipVlrRecebto = '1';
        if(contrato.StartDate != null)    item.iniVig =  String.valueOf(contrato.StartDate.format()) ;
        if(contrato.VigenciaFinal__c != null)    item.fnlVig = String.valueOf(contrato.VigenciaFinal__c.format());
        item.dtEmiss = ''; // data CIV
        item.vlrContratado = '0.0';
        item.vlrTotalContratado = '0.0';
        item.origemPrp = contrato.Origem__c;
        item.numPrp = contrato.ContractNumber;
        // item.sinistrTip = ''; 
        item.edsTip = isNewSin; // ? '1' : '2';   // 1 - novo sinistro || 2 - alteração
        if(contratante != null && contratante.FormaPagamento__c != null)    item.formaPagto = contratante.FormaPagamento__r.Codigo__c;
        if(endereco != null)    item.siglPais = endereco.Pais__c;
        item.alterTip = '0'; 
        item.alternum = '0'; 
        item.numSinistro = caseSinistro.NumeroSinistro__c; 

        doc.item.add(item);

        System.debug(' \n payload sinistro BCP:> \n' + JSON.serializePretty( bcpPayload,true ) );
        return bcpPayload;
    }

    // Busca sinistros, contratos e contas que serão enviados para BCP
    public void buscaRegistros(Id caseId){   
        
        List<Case> caselst = new List<Case>([  
            SELECT  Id, Contrato__c, Status, NumeroSinistro__c
            FROM    case
            WHERE   Id = :caseId
        ]);
        
        if( caselst.isEmpty() )   return;
        caseSinistro = caselst[0];

        List<contract> contractLst = new List<contract> ([
            SELECT  Id, Name, Tipo__c, StartDate, VigenciaFinal__c, Origem__c, ContractNumber, AccountId, NumeroApolice__c, 
                    Sucursal__c, NumeroProposta__c, CodigoRamo__c
            FROM    contract  
            WHERE   Id = :caseSinistro.Contrato__c
        ]);

        if( contractLst.isEmpty() ) return;
        contrato = contractLst[0];

        List<Account> accountLst  = new List<Account>([
            SELECT  Id, Name, Cpf__c, Sexo__c, Type, PersonBirthdate, EstadoCivil__c, PersonEmail, Phone, PersonHomePhone, PersonOtherPhone,
                    Fax, RecordType.Name, RecordType.DeveloperName, PersonMobilePhone,
                    (SELECT Bairro__c, CEP__c, Cidade__c, Complemento__c, Estado__c, Logradouro__c, Numero__c, Pais__c, TipoEndereco__c FROM Enderecos__r)
            FROM    Account
            WHERE   Id = :contrato.AccountId
        ]);

        if( !accountLst.isEmpty() ) contaSin = accountLst[0];

        //busca favorecidos
        Map<Id,FavorecidoRemuneracaoContrato__c> favorecidoMap  = new Map<Id,FavorecidoRemuneracaoContrato__c>([
            SELECT  Id, Name, Susep__c, RemuneracaoContrato__r.Contrato__c
            FROM    FavorecidoRemuneracaoContrato__c
            WHERE   RemuneracaoContrato__r.Contrato__c = :caseSinistro.Contrato__c
        ]);

        for( FavorecidoRemuneracaoContrato__c fav : favorecidoMap.values() ) contrfavMap.put( fav.RemuneracaoContrato__r.Contrato__c, fav );

        // busca contratantes
        Map<Id,ContratanteContrato__c> contratanteMap  = new Map<Id,ContratanteContrato__c>([
            SELECT  Id, Contrato__c, FormaPagamento__c, FormaPagamento__r.Codigo__c
            FROM    ContratanteContrato__c
            WHERE   Contrato__c = :caseSinistro.Contrato__c
        ]);

        for( ContratanteContrato__c c : contratanteMap.values() ) conContratanteMap.put( c.Contrato__c, c );
    }
}
// PLV-4095 - FIM