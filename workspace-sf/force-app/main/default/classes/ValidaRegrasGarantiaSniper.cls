/*********************************************************************************************************************************************************************

@description  Classe que contem a Controller para o Validar Regras da Garantia Sniper.
Validação 1: Estrutura de nós presente: Contratante, Grupo
Validação 2: CPF válido (checksum)
Validação 3: Segurado tem idade valido para a garantia.LimiteIdadeMinimo__c e garantia.LimiteIdadeMaximo__c
Validação 4: Se as coberturas estão dentro do Limite de capital da garantia caso seja do tipo Monetário (Com e sem segurado)
Validação 5: Se a cobertura se encontra dentro das garantias do produto comercial (Com e sem segurado)
Validação 6: Se a cobertura contem alguma garantia excludente ou não contem uma includente
Validação 7: Se as garantias obrigatórias constam no json
@author Renan Martins - Avanxo
@date 29/07/2019
@Classe criada por conta da história PLV-2502
        
**********************************************************************************************************************************************************************/

public class ValidaRegrasGarantiaSniper {

    //PLV_2826 - INICIO - Criar oportunidade sem conta
    public static ServiceTO.PayRetornoOfertasTO ValidaGarantias(EmissaoTO.PayloadTO payload){
        system.debug('gerarOrcamentoEmissao >> inicio');        
        //EmissaoTO.PayloadTO retorno = (EmissaoTO.PayloadTO) JSON.deserialize(payload, EmissaoTO.PayloadTO.class);
        //PLV_2826 - Comentei a linha acima por que alterei a chamada do metodo.
		//PLV_2826 - FIM - Criar oportunidade sem conta		
		ServiceTO.PayRetornoOfertasTO retorno2 = new ServiceTO.PayRetornoOfertasTO();

        system.debug('PAYLOaD TESTE1 >>>>>' + JSON.serialize(payload));

        string ValidacaoDeRegra;

        set < String > codigoProdutoVida = new set < String > ();
		//Buscar os Orçamentos
		
        //PLV_2826 - INICIO - Criar oportunidade sem conta
        for (EmissaoTO.OfertasTO oferta: payload.ofertas) { 
        //PLV_2826 - FIM - Criar oportunidade sem conta    
		
            EmissaoTO orcamento = oferta.orcamento;

            //Popular o codigo vida
            codigoProdutoVida.add(orcamento.codigoProdutoVida);
            
            system.debug('PAYLOaD TESTE2 >>>>>' + codigoProdutoVida);
        }

        //Monta o map de comparação de Codigo Produto vida com as Siglas
        map < String, map < String, GarantiaProduto__c >> mCodigoProdutoVidaBD = new map < String, map < String, GarantiaProduto__c >> ();
        map < string, set < String >> mCodigoProdutoVidaObrigatorioBD = new map < String, set < String >> ();


        for (GarantiaProduto__c garantia: GarantiaProdutoDAO.getInstance().buscarGarantiasProdutoPorCodigoProduto(codigoProdutoVida)) {
            system.debug('PAYLOaD TESTE4 >>>>>' + garantia);

            map < String, GarantiaProduto__c > mSigla;
			
            //Código do produto é api ProductCode
            if (mCodigoProdutoVidaBD.containsKey(garantia.Produto__r.ProductCode)) {

                mSigla = mCodigoProdutoVidaBD.get(garantia.Produto__r.ProductCode);
            } else {

                mSigla = new map < String, GarantiaProduto__c > ();
            }
            mSigla.put(garantia.Garantia__r.Sigla__c, garantia);
            mCodigoProdutoVidaBD.put(garantia.Produto__r.ProductCode, mSigla);

            set < String > sSiglaObrigatorio;
            if (mCodigoProdutoVidaObrigatorioBD.containsKey(garantia.Produto__r.ProductCode)) {

                sSiglaObrigatorio = mCodigoProdutoVidaObrigatorioBD.get(garantia.Produto__r.ProductCode);
            } else {

                sSiglaObrigatorio = new set < String > ();
            }

            if (garantia.Obrigatoria__c) {

                sSiglaObrigatorio.add(garantia.Garantia__r.Sigla__c);
                mCodigoProdutoVidaObrigatorioBD.put(garantia.Produto__r.ProductCode, sSiglaObrigatorio);				
                 
            }
            system.debug('PAYLOaD TESTE3 >>>>>' + garantia);
        }
        //For Principal     
    	system.debug('TESTE RENAN 5' + mCodigoProdutoVidaBD);
        system.debug('TESTE RENAN 6' + mCodigoProdutoVidaObrigatorioBD);
        
		//PLV_2826 - INICIO - Criar oportunidade sem conta
        for (EmissaoTO.OfertasTO oferta: payload.ofertas) { 
        //PLV_2826 - FIM - Criar oportunidade sem conta
		
            EmissaoTO orcamento = oferta.orcamento;

            // Percorre Orçamento      
            List < EmissaoTO.ContratanteTO > contratantes = orcamento.contratantes;

				system.debug('PAYLOaD TESTE4 >>>>>' + contratantes);
            if (orcamento.contratantes.isEmpty()) {

                //Erro Recusa
                adicionarErros(retorno2,10,'Sem Contratante'+contratantes +' não se encontra no arquivo JSON ');

            }
				

            // Percorre Grupo
            List < EmissaoTO.GrupoTO > grupos = new List < EmissaoTO.GrupoTO > ();

            for (EmissaoTO.ContratanteTO contratante: contratantes) {
                if (contratante.grupos.isEmpty()) continue;
                grupos.addAll(contratante.grupos);
                system.debug('PAYLOaD TESTE5 >>>>>' + grupos);
            }

            if (grupos.isEmpty()) {

                //Erro Recusa
                adicionarErros(retorno2,14,'Sem grupo'+grupos +' não se encontra no arquivo JSON ');
            }

            // Percorre Segurado 
            List < EmissaoTO.SeguradoTO > segurados = new List < EmissaoTO.SeguradoTO > ();

            for (EmissaoTO.GrupoTO grupo: grupos) {
	    	// PLV-3138 - Orçamento sem segurado - INICIO
                if (grupo.segurados == null || grupo.segurados.isEmpty()) continue;
                // PLV-3138 - Orçamento sem segurado - FIM
		        segurados.addAll(grupo.segurados);
                system.debug('PAYLOaD TESTE6 >>>>>' + segurados);
            }

            // PLV-3138 - ORCAMENTO SEM SEGURADO - INICIO
            // if (segurados.isEmpty()) {
            //     //Erro Recusa
            //     adicionarErros(retorno2,7,'Sem Segurados'+segurados +' não se encontra no arquivo JSON ');               
            // }
            // PLV-3138 - ORCAMENTO SEM SEGURADO - INICIO

            String produto = orcamento.codigoProdutoVida;

            //Recuperando do Map
            map < String, GarantiaProduto__c > mSiglaBD = mCodigoProdutoVidaBD.get(produto);
            if (mSiglaBD == null || mSiglaBD.isEmpty()) continue;

            //chave
            set < String > sSiglAJSON = new set < String > ();

            for (EmissaoTO.ContratanteTO contratante : orcamento.contratantes) {
                
                for (EmissaoTO.GrupoTO grupo : contratante.grupos) {

                    // PLV-3138 - ORCAMENTO SEM SEGURADO - INICIO
                    if(grupo.segurados != null){
                    // PLV-3138 - ORCAMENTO SEM SEGURADO - FIM
                    for (EmissaoTO.SeguradoTO segurado : grupo.segurados) {

                        //PLV-2607 - Inicio - Validação de CPF
                        //PLV_2826 - INICIO - Criar oportunidade sem conta
                            if(String.isNotEmpty(segurado.pessoa.dadosPessoaFisica.numeroCpf)){
                              
                                String cpf = segurado.pessoa.dadosPessoaFisica.numeroCpf + segurado.pessoa.dadosPessoaFisica.digitoCpf;
                                
                                if(!Util.isCPF(cpf)){
                                  adicionarErros(retorno2,2,'Cpf inválido.');
                                }
                            } 
                        //PLV_2826 - FIM - Criar oportunidade sem conta
                        //PLV-2607 - Fim - Validação de CPF 

                        //List<String> dateParts = segurado.pessoa.dadosPessoaFisica.dataNascimento.split('/');
                        //segurado.pessoa.dadosPessoaFisica.dataNascimento = dateParts[2] + '-' + dateParts[1] + '-' + dateParts[0];

                        //Regra de Idade
                        Integer idade = converterDataComtracosParaIdade(segurado.pessoa.dadosPessoaFisica.dataNascimento);

                        for (EmissaoTO.CoberturaTO coberturasProduto : segurado.coberturas) {

                            GarantiaProduto__c garantiaBD = mSiglaBD.get(coberturasProduto.sigla);

                            

                            if(garantiaBD == null ) continue; 

                            //system.debug('PAYLOaD TESTE7 >>>>>' + garantiaBD);

                             if (garantiaBD.LimiteIdadeMinimo__c > idade || garantiaBD.LimiteIdadeMaximo__c < idade) {

                                 //Erro Recusa
                                 //PLV-2801 - Ajuste na mensagem de erro
                                //  adicionarErros(retorno2,1,'A idade informada está fora dos limites de contratação permitidos pelo produto - (Mínimo: '+garantiaBD.LimiteIdadeMinimo__c +' anos / Máximo: '+garantiaBD.LimiteIdadeMaximo__c+' anos).');
                                 continue;//PLV-4840 INICIO/FIM

                            }


                             system.debug('PAYLOaD TESTE10 >>>>>' + idade);
                             system.debug('PAYLOaD TESTE11 >>>>>' + segurado);
                             system.debug('PAYLOaD TESTE8 >>>>>' + garantiaBD.TipoLimiteCapital__c);
                             system.debug('PAYLOaD TESTE9 >>>>>' + garantiaBD.Id);
                            
                            //PLV-4549 - Inicio
                            //Regra de limite Capital
                            //Regra mantida para avaliar se existem diferencas de limites entre heroku postgres e salesforce para a mesma garantia
                            if (garantiaBD.TipoLimiteCapital__c == 'Monetário' && (garantiaBD.LimiteCapitalMinimo__c > coberturasProduto.valor || garantiaBD.LimiteCapitalMaximo__c < coberturasProduto.valor)) {
                                System.debug('PLV-4549 - Garantia erro:' + coberturasProduto.sigla + '/' + garantiaBD.Id);
                                adicionarErros(retorno2,2,'Limite Capital Inválido:' + coberturasProduto.sigla + ' ');
                            }
                            //PLV-4549 - Fim

                            sSiglAJSON.add(coberturasProduto.sigla);
                            if (mSiglaBD.containsKey(coberturasProduto.sigla)) continue;

                            //Erro Recusa
                			adicionarErros(retorno2,2,'Sigla da Cobertura do Produto Inválido'+mSiglaBD +' não se encontra no arquivo JSON ('+String.join(new List<String>(sSiglAJSON), ',')+')');        
                            }
                        }

                    // PLV-3138 - ORCAMENTO SEM SEGURADO - INICIO
                    }else if(grupo.coberturas != null){
                        for(EmissaoTO.CoberturaTO coberturasProduto : grupo.coberturas) {
                            sSiglAJSON.add(coberturasProduto.sigla);
                            GarantiaProduto__c garantiaBD = mSiglaBD.get(coberturasProduto.sigla);
                            if(garantiaBD == null) {
                                continue;
                            }
                            //PLV-4549 - Inicio
                            //Regra de limite Capital
                            //Regra mantida para avaliar se existem diferencas de limites entre heroku postgres e salesforce para a mesma garantia
                            if(garantiaBD.TipoLimiteCapital__c == 'Monetário' && (garantiaBD.LimiteCapitalMinimo__c > coberturasProduto.valor || garantiaBD.LimiteCapitalMaximo__c < coberturasProduto.valor)) {
                                System.debug('PLV-4549 - Garantia erro:' + coberturasProduto.sigla + '/' + garantiaBD.Id);
                                adicionarErros(retorno2,2,'Limite Capital Inválido:' + coberturasProduto.sigla + ' ');
                            }
                            //PLV-4549 - Fim
                            if(mSiglaBD.containsKey(coberturasProduto.sigla)){
                                continue;
                            }
                            //Erro Recusa
                            //PLV-4151 - Inicio - Erro comentado. A garantias do segurado, mesmo as obrigatorias, podem nao ser ofertadas
                            //adicionarErros(retorno2,2,'Sigla da Cobertura do Produto Inválido'+mSiglaBD +' não se encontra no arquivo JSON ('+String.join(new List<String>(sSiglAJSON), ',')+')');
                            //PLV-4151 - Fim    
                        }
                    }
                    // PLV-3138 - ORCAMENTO SEM SEGURADO - FIM
                }
            }

            for (EmissaoTO.ContratanteTO contratante : orcamento.contratantes) {
                
                for (EmissaoTO.GrupoTO grupo : contratante.grupos) {

                    // PLV-3138 - ORCAMENTO SEM SEGURADO - INICIO
                    if(grupo.segurados != null){
                    // PLV-3138 - ORCAMENTO SEM SEGURADO - FIM
                        for (EmissaoTO.SeguradoTO segurado : grupo.segurados) {

                            for (EmissaoTO.CoberturaTO coberturasProduto : segurado.coberturas) {

                                GarantiaProduto__c garantiaBD = mSiglaBD.get(coberturasProduto.sigla);

                                if (garantiaBD == null) continue;

                                //Todas as garantias includentes e excludentes 
                                for(GarantiaRelacionada__c garantiaRel : garantiaBD.GarantiasRelacionada__r ){
                                    if(garantiaRel.TipoDependencia__c == 'Includente' && !sSiglAJSON.contains(garantiaRel.GarantiaRelacionada__r.Garantia__r.Sigla__c )){
                                    
                                        //Erro Recusa
                                        adicionarErros(retorno2,3,'Sigla obrigatória Includente ');
                                    // adicionarErros(retorno2,3,'Sigla obrigatória Includente '+garantiaRel +' não se encontra no arquivo JSON ('+String.join(new List<String>(sSiglAJSON), ',')+')');
                                        
                                    }else if(garantiaRel.TipoDependencia__c == 'Excludente' && sSiglAJSON.contains(garantiaRel.GarantiaRelacionada__r.Garantia__r.Sigla__c ) ){
                                        
                                        //Erro Recusa
                                        adicionarErros(retorno2,3,'Sigla obrigatória Excludente ');
                                        
                                        
                                    } 
                                }
                            }
                        }
                    }
                }
            }

            Set<String> sSiglaObrigatorio = mCodigoProdutoVidaObrigatorioBD.get(produto);

            if (sSiglaObrigatorio == null) continue;

            System.debug('sSiglAJSON ' + JSON.serialize(sSiglAJSON));

            //verifica se a garantia é Obrigatório
            for (string siglaObrigatorioBD : sSiglaObrigatorio) {
                System.debug('siglaObrigatorioBD ' + JSON.serialize(siglaObrigatorioBD));
                System.debug('sSiglAJSON.contains(siglaObrigatorioBD) ' + sSiglAJSON.contains(siglaObrigatorioBD));
                
                if (sSiglAJSON.contains(siglaObrigatorioBD)) continue;
                system.debug('PAYLOaD TESTE12 >>>>>' + siglaObrigatorioBD);

               //Erro Recusa
                adicionarErros(retorno2,12,'Sigla obrigatória '+siglaObrigatorioBD+' não se encontra no arquivo JSON ('+String.join(new List<String>(sSiglAJSON), ',')+')');
            }

        }
        system.debug('ERROS '+ retorno2.retornoValidacaoProduto);
        system.debug('@JVBDS RETORNO FINAL '+ JSON.serialize(retorno2));

        return retorno2;
    }

    // Lógica Fim

    // Conversão de Data para Idade 
    public static Integer converterDataComtracosParaIdade(String data) {
        Date nascimento = Date.ValueOf(data);
        Date hoje = Date.today();
        Integer meses = nascimento.monthsBetween(hoje);

        if (nascimento.month() == hoje.month() && nascimento.day() > hoje.day())
            meses -= 1;

        Integer idade = meses / 12;
        system.debug('idade : >> ' + idade);

        return idade;
    }
    
    public static void adicionarErros(ServiceTO.PayRetornoOfertasTO payload,Integer codigo, String msgError){
        
        //Erro recusa
        ServiceTO.RecusaTO recusa = new ServiceTO.RecusaTO();
        ServiceTO.MensagenTO mensagem = new ServiceTO.MensagenTO();
        
        
        recusa.codigo = codigo;
        mensagem.cliente = msgError;                       
        recusa.mensagens = mensagem;

        if (payload.retornoValidacaoProduto == null)
            payload.retornoValidacaoProduto = new ServiceTO.RetornoValidacaoProdutoTO();

        if (payload.retornoValidacaoProduto.recusas == null)
            payload.retornoValidacaoProduto.recusas = new List<ServiceTO.RecusaTO>();

        payload.retornoValidacaoProduto.recusas.add(recusa);
        
        
    }

}