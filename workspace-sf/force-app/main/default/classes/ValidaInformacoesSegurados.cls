//PLV-3294 - Inicio - Classe criada para validação do Payload
/*
* @author Sys4b - Gustavo Peira
* @date 2020-01-13
* @description validação do Payload
*/
public class ValidaInformacoesSegurados{
    
    private class ValidaInformacoesSeguradosException extends Exception {}
    
    public static List<RetornoPropostaRestTO.DevolutivasTO> ValidaInformacoes(EmissaoTO.PayloadTO payloadTO)
    {
        RetornoPropostaRestTO.DevolutivasTO devolutiva = new RetornoPropostaRestTO.DevolutivasTO();
        List<RetornoPropostaRestTO.DevolutivasTO> lRetorno = 
        new List<RetornoPropostaRestTO.DevolutivasTO>();
        List<RetornoPropostaRestTO.DevolutivasTO> segurados = new List<RetornoPropostaRestTO.DevolutivasTO>();
        List<String> descricao = new List<String>();
        List<String> cpfSegurados = new List<String>();
        List<Date> dataNascSegurados = new List<Date>(); 
        List<String> segurados1 =  new List<String>();
        String numeroOrcamento = payloadTO.proposta.numeroOrcamento;
        integer i = 0;
        String MascaraCPF;
        Boolean verificaCPFBloqueado = false; // AV-699 INICIO/FIM 
        for(EmissaoTO.ContratanteTO c: payloadTO.proposta.contratantes)
        {          
            for(EmissaoTO.GrupoTO g: c.grupos)
            {
                for(EmissaoTO.SeguradoTO s: g.segurados)
                {
                    CpfSegurados.add(s.pessoa.DadosPessoaFisica.numeroCpf+s.pessoa.DadosPessoaFisica.digitoCpf);
                    DataNascSegurados.add(Date.valueOf(s.pessoa.DadosPessoaFisica.dataNascimento));
                }
            }
        }
        try
        {
           
            for(string cpf : cpfSegurados)
            {
             
              if(cpf == '' || cpf == null)
                {
                    devolutiva.codigo = -2;
                    descricao.add('CPF do '+(i+1)+'º Segurado é invalido.');
                    lRetorno.addAll(segurados);
                }else
                {
                    //valida se existe 2 segurados com o mesmo CPF
                    if(segurados1.contains(string.valueOF(cpf)))
                    {
                        devolutiva.descricao = 'Não foi possível prosseguir pois um mesmo passageiro foi adicionado mais de uma vez na lista. Por favor, verifique os dados inseridos.';
                        devolutiva.codigo = -2;
                        break;
                    // AV-699 VIAG-159 INICIO 
                    } else {
                        MascaraCPF = MascaraCPF(cpf);
                        verificaCPFBloqueado = getVerificaCPFBloqueado(numeroOrcamento, MascaraCPF(cpf));
                        System.debug('O Valor do CPF>>>>'+  MascaraCPF + 'esta Bloqueado?'+ verificaCPFBloqueado);
                        
                        if (verificaCPFBloqueado == true) {
                            devolutiva.codigo = -3;
                            String Link = 'https://portoseguro.com.br/canal-de-ajuda';
                            String target = '_blank';
                            devolutiva.descricao = '<center><h5>Ops!Algo deu errado.</h5><br><h6>Para seguir com a contratação, por favor, entre em contato com a nossa central de ajuda:</h6><br><a href='+Link+' target='+target+'>IR PARA A CENTRAL DE AJUDA</a></center>';
                            devolutiva.link = 'https://portoseguro.com.br/canal-de-ajuda';
                            break;
                        }  
                    }
                    // AV-699  VIAG-159 FIM
                } 
                               
            }
            if(devolutiva.codigo == null)
            {
                segurados = ValidaInformacoesSegurados.ValidaSegurados(CpfSegurados, DataNascSegurados, numeroOrcamento);
            
            }
        }catch(Exception e)
        {
            throw new ValidaInformacoesSeguradosException(e.getMessage());
        }

        
        
        if(segurados.size() > 0)
        {
            if(segurados[0].codigo != null)
            {
                lRetorno.addAll(segurados);

            }
        }else
        {
            lRetorno.clear();
        }       
        if(devolutiva.codigo != null)
        {
            lRetorno.add(devolutiva);
        }
        
        System.debug('lRETORNO: '+lRetorno);        
        return lRetorno;
    }
    
    private static List<RetornoPropostaRestTO.DevolutivasTO> ValidaSegurados(List<String> CpfSegurados, List<Date> DataNascSegurados, String numeroOrcamento)
    {
        RetornoPropostaRestTO.DevolutivasTO devolutiva = new RetornoPropostaRestTO.DevolutivasTO();
        EmissaoTO.DadosPessoaFisicaTO segurados = new EmissaoTO.DadosPessoaFisicaTO();
        List<RetornoPropostaRestTO.DevolutivasTO> retorno = new List<RetornoPropostaRestTO.DevolutivasTO>();
        List<String> descricao = new List<String>();
        
        if(CpfSegurados.size() == DataNascSegurados.size())
        {
            Integer aux = CpfSegurados.size();
            Date hoje = System.today();
            Integer anoAtual = hoje.year();
            String textCPF;
            String textDataNasc;
            String ano;
            String mes;
            String dia;
            for(Integer i = 0; i < aux; i++)
            {
                segurados = new EmissaoTO.DadosPessoaFisicaTO();                
                textCPF = CpfSegurados[i].replaceAll('[^0-9]','');
                
                if(textCPF == '00000000000' || textCPF == '11111111111' ||
                   textCPF == '22222222222' || textCPF == '33333333333' ||
                   textCPF == '44444444444' || textCPF == '55555555555' ||
                   textCPF == '66666666666' || textCPF == '77777777777' ||
                   textCPF == '88888888888' || textCPF == '99999999999' ||
                   textCPF.length() != 11)
                {                    
                    segurados.numeroCpf = CpfSegurados[i].substring(0, 9);
                    segurados.digitoCpf = CpfSegurados[i].substring(9);  
                  
                    if(i == aux-1)
                    {
                        descricao.add('CPF do '+aux+'º segurado é invalido');
                        devolutiva.codigo = -2;
                    }
                    else{
                        descricao.add('CPF do '+(i+1)+'º segurado é invalido');
                        devolutiva.codigo = -2;
                    }                
                } else
                {
                    Integer c1 = 0;
                    Integer c2 = 0;
                    
                    for (Integer t = 9; t < 11; t++) 
                    {
                        Integer d = 0;   
                        
                        for (Integer c = 0; c < t; c++) 
                        {
                            c2 = c+1;
                            d += integer.valueOf(textCPF.substring(c, c2)) * ((t + 1) - c);
                            c1 = c;
                        }
                        d = Math.mod((Math.mod((10 * d),11)), 10);
                        if (integer.valueOf(textCPF.substring(c2,c2+1)) != d) 
                        {
                            if(i == aux-1)
                            {
                                system.debug('1');
                                descricao.add('CPF do '+aux+'º segurado é invalido');
                                devolutiva.codigo = -2;
                            }
                            else
                            {
                                system.debug('2');
                                descricao.add('CPF do  '+(i+1)+'º segurado é invalido');
                                devolutiva.codigo = -2;
                            }             
                        }

                        
                    }
                }


                textDataNasc = String.valueOf(DataNascSegurados[i]).replaceAll('[^0-9]','');
                ano = textDataNasc.substring(0,4);
                mes = textDataNasc.substring(4,6);
                dia = textDataNasc.substring(6);
                system.debug('ano: '+ano);
                system.debug('anoatual: '+ anoatual);
                if(DataNascSegurados[i] == hoje || DataNascSegurados[i] > hoje)
                {
                    if(i == aux-1)
                    {
                        descricao.add('Data de nascimento do '+aux+'º segurado é invalida');
                        devolutiva.codigo = -2;
                        
                    }else
                    {
                        descricao.add('Data de nascimento do '+(i+1)+'º segurado é invalida');
                        devolutiva.codigo = -2;
                    }
                    
                }
            }

            list<string> contem = new list<string>();
            if(descricao.size() > 0)
            {
                system.debug('descricaosize: '+descricao.size());
                for(integer k = 0; k < descricao.size(); k++)
                {
                    if(!contem.contains(descricao[k])){
                        
                        devolutiva.descricao += descricao[k]+' ';
                        contem.add(descricao[k]);
                        
                    }
                    devolutiva.descricao = devolutiva.descricao.replace('null','');
                }
            }
            retorno.add(devolutiva);
        }
        return retorno;
    }

   // AV-699 Inicio
         
    public Static Boolean getVerificaCPFBloqueado(String numeroOrcamento, String CpfSegurados) {
        Boolean possuiProdutoBloqueado = false;
        List<Opportunity> orcamento = new List<Opportunity>();
        orcamento = [SELECT Produto__r.ProductCode from Opportunity where Numero__c =: numeroOrcamento Limit 1];
        if (orcamento.size()>0 ) {
         String codigoProduto  =  orcamento[0].Produto__r.ProductCode;
         AggregateResult[] groupedResults = [SELECT Count(Id) Total FROM Account WHERE Cpf__c =:CpfSegurados AND Produtos_Bloqueados__c INCLUDES (: codigoProduto)]; 
         Integer somaProdutos = Integer.valueOf(groupedResults[0].get('Total'));
         if (somaProdutos > 0 ) {
            possuiProdutoBloqueado = true;
         }
        }
       
        return possuiProdutoBloqueado;
    }

       public Static String MascaraCPF(String CPF) {
           String CPFValor = CPF.substring(0, 3) + '.' + CPF.substring(3, 6) + + '.' + CPF.substring(6, 9) + '-'+ CPF.substring(9, 11);
           System.debug('O valor do CPF eh '+CPFValor);
           return CPFValor;
       }
    // AV-699 fim
}
//PLV-3294 - Fim - Classe criada para validação do Payloads