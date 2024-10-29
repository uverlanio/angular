/*********************************************************************************************************************************************************************


@description  Classe que valida os Favorecidos.
@author Renan Martins e Alexandre Ferreira - Avanxo
@date 26/09/2019
@Classe criada por conta da história PLV-2681
        
**********************************************************************************************************************************************************************/

public class ValidaFavorecidos {

    public static List < RetornoPropostaRestTO.DevolutivasTO > validarExistenciaOrcamento(EmissaoTO.PayloadTO payloadTO) {

        List < RetornoPropostaRestTO.DevolutivasTO > lFavorecidos = new List < RetornoPropostaRestTO.DevolutivasTO > ();

        Set<String> setSusepsCorretores = new Set <string>();

        Set<String> setCPF = new Set<String>();
        Set<String> setCNPJ = new Set<String>();

        //For que percorre a lista de remuneração e Favorecido
        for (EmissaoTO.RemuneracaoTO remuneracaoTO: payloadTO.proposta.remuneracoes) {
            System.debug('Chegou aqui remu ' + remuneracaoTO.tipoRemuneracao);
            //Validação quando Tipo de remuneração            
            if (remuneracaoTO.tipoRemuneracao == 'COR') {
                System.debug('Chegou aqui antes for susep');
                for (EmissaoTO.FavorecidoTO favorecido: remuneracaoTO.favorecidos) {
                    System.debug('Chegou aqui antes if susep');
                    if(setSusepsCorretores.contains(favorecido.susep)){
                            RetornoPropostaRestTO.DevolutivasTO devolutiva = new RetornoPropostaRestTO.DevolutivasTO();
                            devolutiva.codigo = -2;
                            devolutiva.descricao = 'Não pode haver Susep duplicada';
                            devolutiva.link = ''; // AV-620 INICIO/FIM;
                            lFavorecidos.add(devolutiva);
                            return lFavorecidos;
                    }else{
                        System.debug('Chegou aqui for susep');
                        System.debug('Chegou aqui for susep fav ' + favorecido);
                        setSusepsCorretores.add(favorecido.susep);
                        }
                }
            }
                //Validação da Pessoa Fisica e Juridica
            if (remuneracaoTO.tipoRemuneracao == 'AGE') {
                String numeroOrcamento = payloadTO.proposta.numeroOrcamento; // AV-699 INICIO/FIM
                for (EmissaoTO.FavorecidoTO favorecido: remuneracaoTO.favorecidos) {
                    EmissaoTO.PessoaTO pessoas = favorecido.pessoa;

                    if (pessoas.tipo == 'FIS') {
                        EmissaoTO.DadosPessoaFisicaTO pessoaFisica = pessoas.dadosPessoaFisica;
                        RetornoPropostaRestTO.DevolutivasTO devolutiva = new RetornoPropostaRestTO.DevolutivasTO();


                        if( pessoaFisica.numeroCpf.length() < 9 || pessoaFisica.digitoCpf.length() < 2 ){
                            devolutiva.codigo = -2;
                            devolutiva.descricao = 'CPF Inválido';
                            lFavorecidos.add(devolutiva);
                        }else {
                         
                            setCPF.add( pessoaFisica.numeroCpf.substring(0,3) + '.' + pessoaFisica.numeroCpf.substring(3,6) + '.' + 
                                    pessoaFisica.numeroCpf.substring(6,9) + '-' + pessoaFisica.digitoCpf );
                          
                       }

                    } else if (pessoas.tipo == 'JUR') {
                        EmissaoTO.DadosPessoaJuridicaTO pessoaJuridica = pessoas.dadosPessoaJuridica;

                        if( pessoaJuridica.numeroCnpj.length() < 8 ||  pessoaJuridica.ordemCnpj.length() < 4 ||
                            pessoaJuridica.digitoCnpj.length() < 2 ){
                            RetornoPropostaRestTO.DevolutivasTO devolutiva = new RetornoPropostaRestTO.DevolutivasTO();
                            devolutiva.codigo = -2;
                            devolutiva.descricao = 'CNPJ Inválido';
                            devolutiva.link = ''; // AV-620 INICIO/FIM
                            lFavorecidos.add(devolutiva);
                        }else{
                            setCNPJ.add(    pessoaJuridica.numeroCnpj.substring(0,2) + '.' +
                                        pessoaJuridica.numeroCnpj.substring(2,5) + '.' +
                                        pessoaJuridica.numeroCnpj.substring(5,8) + '/' +
                                        pessoaJuridica.ordemCnpj + '-' + pessoaJuridica.digitoCnpj );
                        }
                    }
                }
            }
        }

        System.debug('Chegou aqui!!');

        if(!lFavorecidos.isEmpty()) return lFavorecidos;
        set<String> susepToAtt = new set<String>();

        System.debug('Chegou aqui 2!!!');
        
       
        // AV-620 inicio
        Boolean verificacorretorBloqueado = false;
        String numeroOrcamento = payloadTO.proposta.numeroOrcamento;
        if ((numeroOrcamento !='') || (numeroOrcamento != null)) {
        verificacorretorBloqueado = getVerificaBloqueio(numeroOrcamento, setSusepsCorretores);
     
        System.debug('verificacorretorBloqueado>>>: '+ verificacorretorBloqueado);
        }
        // AV-620 Fim


        for( DadosCorretor__c dc : [SELECT Id, Name FROM DadosCorretor__c WHERE Name IN :setSusepsCorretores]){
            susepToAtt.add(dc.Name);
            setSusepsCorretores.remove(dc.Name);
        }
       
        
        if( !setSusepsCorretores.isEmpty() || setSusepsCorretores.size() > 0 || verificacorretorBloqueado == true ) {  // AV-620  inicio/fim
            RetornoPropostaRestTO.DevolutivasTO devolutiva = new RetornoPropostaRestTO.DevolutivasTO();
            
            // AV-620  VIAG-159 INICIO 
            if (verificacorretorBloqueado == true) {
                devolutiva.codigo = -3;
                String Link = 'https://portoseguro.com.br/canal-de-ajuda';
                String target = '_blank';
                devolutiva.descricao = '<center><h5>Ops!Algo deu errado.</h5><br><h6>Para seguir com a contratação, por favor, entre em contato com a nossa central de ajuda:</h6><br><a href='+Link+' target='+target+'>IR PARA A CENTRAL DE AJUDA</a></center>';
               } else {
               devolutiva.codigo = -2;
               devolutiva.descricao = 'Favorecido nâo Encontrado';
               devolutiva.link = ''; 
            }
            // AV-620 VIAG-159 FIM
            lFavorecidos.add(devolutiva);
        }

        System.debug('Chegou aqui 3!!!!');
        
        if(!lFavorecidos.isEmpty()) return lFavorecidos;

        System.debug('Chegou aqui 4!!!!');
        System.debug('Set Susep1!!!! ' + susepToAtt);



        for( Account acc : [SELECT Id, Cpf__c FROM Account WHERE Cpf__c IN :setCPF ]){
            setCPF.remove(acc.Cpf__c);
        }
        for( Account acc : [SELECT Id, Cnpj__c FROM Account WHERE Cnpj__c IN :setCNPJ ]){
            setCNPJ.remove(acc.Cnpj__c);
        }
      
        // AV-699 inicio
        Boolean verificaCPFBloqueado = false;
        if ((numeroOrcamento !='') || (numeroOrcamento != null)) {
         verificaCPFBloqueado =  getVerificaCPFBloqueado(numeroOrcamento, setCPF);
         System.debug('verificaCPFBloqueado: '+  verificaCPFBloqueado);
        }
        // AV-699 Fim

        System.debug('Chegou aqui 5!!!!');
        if(!setCPF.isEmpty() || setCPF.size() > 0 ){
            RetornoPropostaRestTO.DevolutivasTO devolutiva = new RetornoPropostaRestTO.DevolutivasTO();
            devolutiva.codigo = -2;
            devolutiva.descricao = 'CPF do favorecido não encontrado';
            devolutiva.link = ''; // AV-620 INICIO/FIM;
            lFavorecidos.add(devolutiva);
        }

        System.debug('Chegou aqui 6!!!!');
        if(!lFavorecidos.isEmpty()) return lFavorecidos;
        System.debug('Chegou aqui 7!!!!');
        if(!setCNPJ.isEmpty() || setCNPJ.size() > 0){
     
            RetornoPropostaRestTO.DevolutivasTO devolutiva = new RetornoPropostaRestTO.DevolutivasTO();
            devolutiva.codigo = -2;
            devolutiva.descricao = 'CNPJ do favorecido não encontrado';
            devolutiva.link = ''; // AV-620 INICIO/FIM;
       
            lFavorecidos.add(devolutiva);
        }
        System.debug('Chegou aqui 8!!!!');
        if(!lFavorecidos.isEmpty()) return lFavorecidos;
        System.debug('Chegou aqui 9!!!!');
        System.debug('Set Susep!!!! ' + susepToAtt);
        Map<String,DadosCorretor__c> mapCorretor = new Map<String,DadosCorretor__c>();
        for(DadosCorretor__c corretor : [   SELECT Id, Name, NomeCorretor__r.Cnpj__c, NomeCorretor__r.Cpf__c  
                                            FROM DadosCorretor__c WHERE Name IN :susepToAtt]){
            mapCorretor.put(corretor.Name, corretor);
        }
        System.debug('Chegou aqui 10!!!!');
        
        for (EmissaoTO.RemuneracaoTO remuneracaoTO: payloadTO.proposta.remuneracoes) {
            if (remuneracaoTO.tipoRemuneracao == 'COR') {
                for (EmissaoTO.FavorecidoTO favorecido: remuneracaoTO.favorecidos) {

                    DadosCorretor__c corretor = new DadosCorretor__c(); 
                    favorecido.pessoa = new EmissaoTO.PessoaTO();

                    if(mapCorretor.containsKey(favorecido.susep)) corretor = mapCorretor.get(favorecido.susep);
                    else continue;

                    if( corretor.NomeCorretor__r.Cpf__c != null ){
                        favorecido.pessoa.dadosPessoaFisica = new EmissaoTO.DadosPessoaFisicaTO();
                        favorecido.pessoa.tipo = 'FIS';
                        favorecido.pessoa.dadosPessoaFisica.numeroCpf = corretor.NomeCorretor__r.Cpf__c.substringBefore('-').remove('.');
                        favorecido.pessoa.dadosPessoaFisica.digitoCpf = corretor.NomeCorretor__r.Cpf__c.substringAfterLast('-');
                    }
                    else if( corretor.NomeCorretor__r.Cnpj__c != null ){
                        favorecido.pessoa.dadosPessoaJuridica = new EmissaoTO.DadosPessoaJuridicaTO();
                        favorecido.pessoa.tipo = 'JUR';
                        favorecido.pessoa.dadosPessoaJuridica.numeroCnpj = corretor.NomeCorretor__r.Cnpj__c.substringBefore('/').remove('.');
                        favorecido.pessoa.dadosPessoaJuridica.ordemCnpj = corretor.NomeCorretor__r.Cnpj__c.substringAfterLast('/').substringBefore('-');
                        favorecido.pessoa.dadosPessoaJuridica.digitoCnpj = corretor.NomeCorretor__r.Cnpj__c.substringAfterLast('-');
                    }
                    System.debug('#### pessoa: ' + favorecido.pessoa);
                    System.debug('#### payloadTO>: ' + JSON.serialize( payloadTO ) );
                }
            }
        }
        return lFavorecidos;
    }

   // AV-620 inicio
    public Static  Boolean getVerificaBloqueio(String numeroOrcamento, Set<String> susep) {
        Boolean CorretorBloqueado = false;
       
        List<DadosCorretor__c> Corretores = new List<DadosCorretor__c>();
        Corretores = [Select Name from DadosCorretor__c where Name in :susep];
        System.debug('Quantidade de corretores'+corretores.size() );
        if (corretores.size() > 0 ) {
            for(integer i=0; i< corretores.size() ; i++) {
             Boolean statusCorretor =  getVerificaProdutoBloqueado(numeroOrcamento, Corretores[i].Name);
             System.debug('StatusCorretor !!!!' + statusCorretor);
             if (statusCorretor == true) {
                CorretorBloqueado = true;
             } 
            }
        }

       return CorretorBloqueado;
       }
       
    public Static Boolean getVerificaProdutoBloqueado(String numeroOrcamento, String susep) {
        Boolean possuiProdutoBloqueado = false;
        List<Opportunity> orcamento = new List<Opportunity>();
        orcamento = [SELECT Produto__r.ProductCode from Opportunity where Numero__c =: numeroOrcamento Limit 1];
        if (orcamento.size()>0 ) {
         String NomeProduto = orcamento[0].Produto__r.ProductCode;
         AggregateResult[] groupedResults = [SELECT Count(Id) Total FROM DadosCorretor__c WHERE Name  =: susep AND Produtos_Bloqueados__c includes (:NomeProduto)]; 
         Integer somaProdutos = Integer.valueOf(groupedResults[0].get('Total'));
         if (somaProdutos > 0 ) {
            possuiProdutoBloqueado = true;
         }
        }
       
        return possuiProdutoBloqueado;
    }
     // AV-620 fim
     // AV-699 Inicio
         
    public Static Boolean getVerificaCPFBloqueado(String numeroOrcamento, Set<String> CPF) {
        Boolean possuiProdutoBloqueado = false;
        List<Opportunity> orcamento = new List<Opportunity>();
        orcamento = [SELECT Produto__r.ProductCode from Opportunity where Numero__c =: numeroOrcamento Limit 1];
        if (orcamento.size()>0 ) {
            
         String codigoProduto  =  orcamento[0].Produto__r.ProductCode;
         AggregateResult[] groupedResults = [SELECT Count(Id) Total FROM Account WHERE Cpf__c IN :CPF AND Produtos_Bloqueados__c INCLUDES (: codigoProduto)]; 
         Integer somaProdutos = Integer.valueOf(groupedResults[0].get('Total'));
         if (somaProdutos > 0 ) {
            possuiProdutoBloqueado = true;
         }
        }
       
        return possuiProdutoBloqueado;
    }
   
   
    // AV-699 fim
}