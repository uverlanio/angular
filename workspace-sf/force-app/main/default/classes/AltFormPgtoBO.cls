//II-172 - INICIO
public without sharing class AltFormPgtoBO { //FNPVVEP-126 INICIO-FIM

    public AltFormPgtoBO() {}

    public CondicaoCobranca__c montarParcelas(CondicaoCobranca__c cc, Decimal percAgenciamento){

        if(percAgenciamento > 0){
            if(cc.FormaPagamento__r.Codigo__c == '62' || cc.FormaPagamento__r.Codigo__c == '97' ||
                cc.FormaPagamento__r.Codigo__c == '70' || cc.FormaPagamento__r.Codigo__c == '98'){
                cc.QuantidadeParcelas__c = '11';
            }
            if(cc.FormaPagamento__r.Codigo__c == '41' || cc.FormaPagamento__r.Codigo__c == '52'){
                cc.QuantidadeParcelas__c = '12';
            }
        }else{
            if(cc.FormaPagamento__r.Codigo__c == '52' || cc.FormaPagamento__r.Codigo__c == '41'){
                if(cc.QuantidadeParcelas__c == '1;2;3;4'){
                    cc.QuantidadeParcelas__c = cc.QuantidadeParcelas__c + ';5;6;7;8;9;10;11;12';
                }
                if(cc.QuantidadeParcelas__c == '5;6;7;8;9;10;11;12'){
                    cc.QuantidadeParcelas__c = '1;2;3;4;' + cc.QuantidadeParcelas__c;
                }
            }
            
            if(cc.FormaPagamento__r.Codigo__c == '62' || cc.FormaPagamento__r.Codigo__c == '97' ||
                cc.FormaPagamento__r.Codigo__c == '70' || cc.FormaPagamento__r.Codigo__c == '98'){
                if(cc.QuantidadeParcelas__c == '1;2;3;4'){
                    cc.QuantidadeParcelas__c = cc.QuantidadeParcelas__c + ';5;6;7;8;9;10;11';
                }
                if(cc.QuantidadeParcelas__c =='5;6;7;8;9;10;11'){
                    cc.QuantidadeParcelas__c = '1;2;3;4;' + cc.QuantidadeParcelas__c;
                }                    
            }
        }
        return cc;
    }

    public List<AltFormPgtoTO.EnderecoTO> getEnderecos(String cepPrefixo, String cepSufixo, String retorno){

        List<AltFormPgtoTO.EnderecoTO> enderecos = new List<AltFormPgtoTO.EnderecoTO>();
        AltFormPgtoTO.EnderecoTO endereco = new AltFormPgtoTO.EnderecoTO();

        F5Service.ObjLogradouros response = (F5Service.ObjLogradouros) JSON.deserialize(retorno, F5Service.ObjLogradouros.class);
        
        if(response != null){
            List<F5Service.Logradouros> listaLogradouros = response.logradouros;

                for(F5Service.Logradouros logradouro : listaLogradouros){
                    endereco = new AltFormPgtoTO.EnderecoTO();
                    
                    endereco.logradouro = logradouro.nomeLogradouro;
                    endereco.bairro = logradouro.bairro != null ?  logradouro.bairro.nomeBairro : '';
                    endereco.cidade = logradouro.localidade != null ? logradouro.localidade.nomeLocalidade : '';
                    endereco.estado = logradouro.localidade.estado != null ? logradouro.localidade.estado.nomeEstado : '';
                    endereco.uf = logradouro.localidade != null && logradouro.localidade.estado != null ? logradouro.localidade.estado.siglaEstado : '';
                    endereco.cepPrefixo = cepPrefixo;
                    endereco.cepSufixo = cepSufixo;

				    enderecos.add(endereco);
            }        
        }
        return enderecos;
    }   
} //II-172 - FIM