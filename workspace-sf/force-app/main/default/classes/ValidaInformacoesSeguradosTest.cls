@IsTest
public class ValidaInformacoesSeguradosTest
{
    static testMethod void TestPass() 
    {
        System.debug('TestPass');
        String json = '{'+
            '   \"proposta\":{'+
            '      \"numeroOrcamento\":\"PPW-478586\",'+
            '      \"numeroPortal\":478586,'+
            '      \"dataProtocolo\":\"2019-11-28\",'+
            '      \"contratantes\":['+
            '         {'+
            '            \"tipo\":\"PRI\",'+
            '            \"numero\":1,'+
            '            \"pessoa\":{'+
            '               \"tipo\":\"FIS\",'+
            '               \"nome\":\"HUGUINHO DUCK\",'+
            '               \"dadosPessoaFisica\":{'+
            '                  \"numeroCpf\":\"450306868\",'+
            '                  \"digitoCpf\":\"78\",'+
            '                  \"dataNascimento\":\"1995-06-27\"'+
            '               }'+
            '            },'+
            '            \"dadosPagamento\":{'+
            '               \"quantidadeParcelas\":6,'+
            '               \"tipoResponsavelPagamento\":\"CON\",'+
            '               \"codigoFormaPagamento\":62,'+
            '               \"descricaoFormaPagamento\":\"CARTAO DE CREDITO (TODAS PARC.EM CARTAO)\",'+
            '               \"codigoMeioRecebimento\":\"Q\",'+
            '               \"vencimentoPrimeiraParcela\":\"2018-08-30\",'+
            '               \"dadosCartaoCredito\":{'+
            '                  \"numero\":\"4902-6277-3514-4152\",'+
            '                  \"validade\":\"2022-10\",'+
            '                  \"nome\":\"HUGUINHO DUCK\",'+
            '                  \"cvv\":666'+
            '               }'+
            '            },'+
            '            \"grupos\":['+
            '               {'+
            '                  \"numero\":1,'+
            '                  \"qtdeVidas\":1,'+
            '                  \"segurados\":['+
            '                     {'+
            '                        \"numero\":1,'+
            '                        \"pessoa\":{'+
            '                           \"tipo\":\"FIS\",'+
            '                           \"nome\":\"HUGUINHO DUCK\",'+
            '                           \"email\":\"xinha36661@hotmail.de\",'+
            '                           \"dadosPessoaFisica\":{'+
            '                              \"numeroCpf\":\"135138848\",'+
            '                              \"digitoCpf\":\"77\",'+
            '                              \"dataNascimento\":\"1975-12-10\"'+
            '                           },'+
            '                           \"enderecos\":['+
            '                              {'+
            '                                 \"uf\":\"SP\",'+
            '                                 \"tipoLogradouro\":\"R\",'+
            '                                 \"tipoEndereco\":\"RES\",'+
            '                                 \"paisResidencia\":\"Brasil\",'+
            '                                 \"numeroLogradouro\":\"92\",'+
            '                                 \"logradouro\":\"Guaianses\",'+
            '                                 \"complementoCep\":\"420\",'+
            '                                 \"complemento\":\"Apto 22\",'+
            '                                 \"cidade\":\"SAO PAULO\",'+
            '                                 \"cep\":\"07114\",'+
            '                                 \"bairro\":\"Centro\"'+
            '                              }'+
            '                           ],'+
            '                           \"telefones\":['+
            '                              {'+
            '                                 \"tipoTelefone\":\"CEL\",'+
            '                                 \"numeroTelefone\":\"971452694\",'+
            '                                 \"dddTelefone\":\"11\"'+
            '                              }'+
            '                           ],'+
            '                           \"pep\":\"PROX\",'+
            '                           \"pessoaRelacionamentoPep\":{'+
            '                              \"tipo\":\"FIS\",'+
            '                              \"nome\":\"Tiririca\",'+
            '                              \"dadosPessoaFisica\":{'+
            '                                 \"numeroCpf\":\"450306868\",'+
            '                                 \"digitoCpf\":\"78\"'+
            '                              }'+
            '                           }'+
            '                        },'+
            '                        \"contatoEmergencia\":{'+
            '                           \"nome\":\"Donald Duck\",'+
            '                           \"ddd\":11,'+
            '                           \"telefone\":\"965214220\"'+
            '                        }'+
            '                     }'+
            '                  ]'+
            '               },'+
            '               {'+
            '                  \"numero\":2,'+
            '                  \"qtdeVidas\":1,'+
            '                  \"segurados\":['+
            '                     {'+
            '                        \"numero\":1,'+
            '                        \"pessoa\":{'+
            '                           \"tipo\":\"FIS\",'+
            '                           \"nome\":\"ZEZINHO DUCK\",'+
            '                           \"email\":\"xinha36661@hotmail.de\",'+
            '                           \"dadosPessoaFisica\":{'+
            '                              \"numeroCpf\":\"509563680\",'+
            '                              \"digitoCpf\":\"85\",'+
            '                              \"dataNascimento\":\"1945-12-10\"'+
            '                           },'+
            '                           \"enderecos\":['+
            '                              {'+
            '                                 \"paisResidencia\":\"Alemanha\"'+
            '                              }'+
            '                           ],'+
            '                           \"telefones\":['+
            '                              {'+
            '                                 \"tipoTelefone\":\"CEL\",'+
            '                                 \"numeroTelefone\":\"971452694\",'+
            '                                 \"dddTelefone\":\"11\"'+
            '                              }'+
            '                           ],'+
            '                           \"pep\":\"PROX\",'+
            '                           \"pessoaRelacionamentoPep\":{'+
            '                              \"tipo\":\"FIS\",'+
            '                              \"nome\":\"Tiririca\",'+
            '                              \"dadosPessoaFisica\":{'+
            '                                 \"numeroCpf\":\"509563680\",'+
            '                                 \"digitoCpf\":\"85\"'+
            '                              }'+
            '                           }'+
            '                        },'+
            '                        \"contatoEmergencia\":{'+
            '                           \"nome\":\"Donald Duck\",'+
            '                           \"ddd\":11,'+
            '                           \"telefone\":\"965214220\"'+
            '                        }'+
            '                     }'+
            '                  ]'+
            '               }'+
            '            ]'+
            '         }'+
            '      ],'+
            '      \"remuneracoes\":['+
            '         {'+
            '            \"tipoRemuneracao\":\"Corretagem\",'+
            '            \"percentual\":20.0,'+
            '            \"favorecidos\":['+
            '               {'+
            '                  \"papel\":\"Corretor\",'+
            '                  \"participacao\":100.0,'+
            '                  \"corretorLider\":true,'+
            '                  \"susep\":\"C1192J\",'+
            '                  \"pessoa\":{'+
            '                     \"tipo\":\"JUR\",'+
            '                     \"nome\":\"CLARA ROSEMBLAT CORRETORA DE SEGUROS\",'+
            '                     \"dadosPessoaJuridica\":{'+
            '                        \"numeroCnpj\":\"27351731\",'+
            '                        \"ordemCnpj\":\"0001\",'+
            '                        \"digitoCnpj\":\"38\"'+
            '                     }'+
            '                  }'+
            '               }'+
            '            ]'+
            '         }'+
            '      ]'+
            '   }'+
            '}'; 
        
        EmissaoTO.PayloadTO payload1 = (EmissaoTO.PayloadTO) System.JSON.deserialize(json, EmissaoTO.PayloadTO.class);
        
        ValidaInformacoesSegurados.ValidaInformacoes(payload1);
    }
    
    static testMethod void TestErroCpfInvalidoVazio()
    {
        system.debug('TestErroCpfInvalidoVazio');
        String json = '{'+
            '   \"proposta\":{'+
            '      \"numeroOrcamento\":\"PPW-478586\",'+
            '      \"numeroPortal\":478586,'+
            '      \"dataProtocolo\":\"2019-11-28\",'+
            '      \"contratantes\":['+
            '         {'+
            '            \"tipo\":\"PRI\",'+
            '            \"numero\":1,'+
            '            \"pessoa\":{'+
            '               \"tipo\":\"FIS\",'+
            '               \"nome\":\"HUGUINHO DUCK\",'+
            '               \"dadosPessoaFisica\":{'+
            '                  \"numeroCpf\":\"4503063868\",'+
            '                  \"digitoCpf\":\"78\",'+
            '                  \"dataNascimento\":\"1995-06-27\"'+
            '               }'+
            '            },'+
            '            \"dadosPagamento\":{'+
            '               \"quantidadeParcelas\":6,'+
            '               \"tipoResponsavelPagamento\":\"CON\",'+
            '               \"codigoFormaPagamento\":62,'+
            '               \"descricaoFormaPagamento\":\"CARTAO DE CREDITO (TODAS PARC.EM CARTAO)\",'+
            '               \"codigoMeioRecebimento\":\"Q\",'+
            '               \"vencimentoPrimeiraParcela\":\"2024-08-30\",'+
            '               \"dadosCartaoCredito\":{'+
            '                  \"numero\":\"4902-6277-3514-4152\",'+
            '                  \"validade\":\"2028-10\",'+
            '                  \"nome\":\"HUGUINHO DUCK\",'+
            '                  \"cvv\":666'+
            '               }'+
            '            },'+
            '            \"grupos\":['+
            '               {'+
            '                  \"numero\":1,'+
            '                  \"qtdeVidas\":1,'+
            '                  \"segurados\":['+
            '                     {'+
            '                        \"numero\":1,'+
            '                        \"pessoa\":{'+
            '                           \"tipo\":\"FIS\",'+
            '                           \"nome\":\"HUGUINHO DUCK\",'+
            '                           \"email\":\"xinha36661@hotmail.de\",'+
            '                           \"dadosPessoaFisica\":{'+
            '                              \"numeroCpf\":\"\",'+
            '                              \"digitoCpf\":\"\",'+
            '                              \"dataNascimento\":\"1975-12-10\"'+
            '                           },'+
            '                           \"enderecos\":['+
            '                              {'+
            '                                 \"uf\":\"SP\",'+
            '                                 \"tipoLogradouro\":\"R\",'+
            '                                 \"tipoEndereco\":\"RES\",'+
            '                                 \"paisResidencia\":\"Brasil\",'+
            '                                 \"numeroLogradouro\":\"92\",'+
            '                                 \"logradouro\":\"Guaianses\",'+
            '                                 \"complementoCep\":\"420\",'+
            '                                 \"complemento\":\"Apto 22\",'+
            '                                 \"cidade\":\"SAO PAULO\",'+
            '                                 \"cep\":\"07114\",'+
            '                                 \"bairro\":\"Centro\"'+
            '                              }'+
            '                           ],'+
            '                           \"telefones\":['+
            '                              {'+
            '                                 \"tipoTelefone\":\"CEL\",'+
            '                                 \"numeroTelefone\":\"971452694\",'+
            '                                 \"dddTelefone\":\"11\"'+
            '                              }'+
            '                           ],'+
            '                           \"pep\":\"PROX\",'+
            '                           \"pessoaRelacionamentoPep\":{'+
            '                              \"tipo\":\"FIS\",'+
            '                              \"nome\":\"Tiririca\",'+
            '                              \"dadosPessoaFisica\":{'+
            '                                 \"numeroCpf\":\"45030686878\",'+
            '                                 \"digitoCpf\":\"56\"'+
            '                              }'+
            '                           }'+
            '                        },'+
            '                        \"contatoEmergencia\":{'+
            '                           \"nome\":\"Donald Duck\",'+
            '                           \"ddd\":11,'+
            '                           \"telefone\":\"965214220\"'+
            '                        }'+
            '                     }'+
            '                  ]'+
            '               },'+
            '               {'+
            '                  \"numero\":2,'+
            '                  \"qtdeVidas\":1,'+
            '                  \"segurados\":['+
            '                     {'+
            '                        \"numero\":1,'+
            '                        \"pessoa\":{'+
            '                           \"tipo\":\"FIS\",'+
            '                           \"nome\":\"ZEZINHO DUCK\",'+
            '                           \"email\":\"xinha36661@hotmail.de\",'+
            '                           \"dadosPessoaFisica\":{'+
            '                              \"numeroCpf\":\"\",'+
            '                              \"digitoCpf\":\"\",'+
            '                              \"dataNascimento\":\"1945-12-10\"'+
            '                           },'+
            '                           \"enderecos\":['+
            '                              {'+
            '                                 \"paisResidencia\":\"Alemanha\"'+
            '                              }'+
            '                           ],'+
            '                           \"telefones\":['+
            '                              {'+
            '                                 \"tipoTelefone\":\"CEL\",'+
            '                                 \"numeroTelefone\":\"971452694\",'+
            '                                 \"dddTelefone\":\"11\"'+
            '                              }'+
            '                           ],'+
            '                           \"pep\":\"PROX\",'+
            '                           \"pessoaRelacionamentoPep\":{'+
            '                              \"tipo\":\"FIS\",'+
            '                              \"nome\":\"Tiririca\",'+
            '                              \"dadosPessoaFisica\":{'+
            '                                 \"numeroCpf\":\"509563680\",'+
            '                                 \"digitoCpf\":\"85\"'+
            '                              }'+
            '                           }'+
            '                        },'+
            '                        \"contatoEmergencia\":{'+
            '                           \"nome\":\"Donald Duck\",'+
            '                           \"ddd\":11,'+
            '                           \"telefone\":\"965214220\"'+
            '                        }'+
            '                     }'+
            '                  ]'+
            '               }'+
            '            ]'+
            '         }'+
            '      ],'+
            '      \"remuneracoes\":['+
            '         {'+
            '            \"tipoRemuneracao\":\"Corretagem\",'+
            '            \"percentual\":20.0,'+
            '            \"favorecidos\":['+
            '               {'+
            '                  \"papel\":\"Corretor\",'+
            '                  \"participacao\":100.0,'+
            '                  \"corretorLider\":true,'+
            '                  \"susep\":\"C1192J\",'+
            '                  \"pessoa\":{'+
            '                     \"tipo\":\"JUR\",'+
            '                     \"nome\":\"CLARA ROSEMBLAT CORRETORA DE SEGUROS\",'+
            '                     \"dadosPessoaJuridica\":{'+
            '                        \"numeroCnpj\":\"27351731\",'+
            '                        \"ordemCnpj\":\"0001\",'+
            '                        \"digitoCnpj\":\"38\"'+
            '                     }'+
            '                  }'+
            '               }'+
            '            ]'+
            '         }'+
            '      ]'+
            '   }'+
            '}'; 
        
        EmissaoTO.PayloadTO payload1 = (EmissaoTO.PayloadTO) System.JSON.deserialize(json, EmissaoTO.PayloadTO.class);
        
        ValidaInformacoesSegurados.ValidaInformacoes(payload1);
    } 
    static testMethod void TestErroCpfInvalido()
    {
        system.debug('TestErroCpfInvalido');
        String json = '{'+
            '   \"proposta\":{'+
            '      \"numeroOrcamento\":\"PPW-478586\",'+
            '      \"numeroPortal\":478586,'+
            '      \"dataProtocolo\":\"2019-11-28\",'+
            '      \"contratantes\":['+
            '         {'+
            '            \"tipo\":\"PRI\",'+
            '            \"numero\":1,'+
            '            \"pessoa\":{'+
            '               \"tipo\":\"FIS\",'+
            '               \"nome\":\"HUGUINHO DUCK\",'+
            '               \"dadosPessoaFisica\":{'+
            '                  \"numeroCpf\":\"450306868\",'+
            '                  \"digitoCpf\":\"78\",'+
            '                  \"dataNascimento\":\"1995-06-27\"'+
            '               }'+
            '            },'+
            '            \"dadosPagamento\":{'+
            '               \"quantidadeParcelas\":6,'+
            '               \"tipoResponsavelPagamento\":\"CON\",'+
            '               \"codigoFormaPagamento\":62,'+
            '               \"descricaoFormaPagamento\":\"CARTAO DE CREDITO (TODAS PARC.EM CARTAO)\",'+
            '               \"codigoMeioRecebimento\":\"Q\",'+
            '               \"vencimentoPrimeiraParcela\":\"2018-08-30\",'+
            '               \"dadosCartaoCredito\":{'+
            '                  \"numero\":\"4902-6277-3514-4152\",'+
            '                  \"validade\":\"2022-10\",'+
            '                  \"nome\":\"HUGUINHO DUCK\",'+
            '                  \"cvv\":666'+
            '               }'+
            '            },'+
            '            \"grupos\":['+
            '               {'+
            '                  \"numero\":1,'+
            '                  \"qtdeVidas\":1,'+
            '                  \"segurados\":['+
            '                     {'+
            '                        \"numero\":1,'+
            '                        \"pessoa\":{'+
            '                           \"tipo\":\"FIS\",'+
            '                           \"nome\":\"HUGUINHO DUCK\",'+
            '                           \"email\":\"xinha36661@hotmail.de\",'+
            '                           \"dadosPessoaFisica\":{'+
            '                              \"numeroCpf\":\"13513884877\",'+
            '                              \"digitoCpf\":\"77\",'+
            '                              \"dataNascimento\":\"1975-12-10\"'+
            '                           },'+
            '                           \"enderecos\":['+
            '                              {'+
            '                                 \"uf\":\"SP\",'+
            '                                 \"tipoLogradouro\":\"R\",'+
            '                                 \"tipoEndereco\":\"RES\",'+
            '                                 \"paisResidencia\":\"Brasil\",'+
            '                                 \"numeroLogradouro\":\"92\",'+
            '                                 \"logradouro\":\"Guaianses\",'+
            '                                 \"complementoCep\":\"420\",'+
            '                                 \"complemento\":\"Apto 22\",'+
            '                                 \"cidade\":\"SAO PAULO\",'+
            '                                 \"cep\":\"07114\",'+
            '                                 \"bairro\":\"Centro\"'+
            '                              }'+
            '                           ],'+
            '                           \"telefones\":['+
            '                              {'+
            '                                 \"tipoTelefone\":\"CEL\",'+
            '                                 \"numeroTelefone\":\"971452694\",'+
            '                                 \"dddTelefone\":\"11\"'+
            '                              }'+
            '                           ],'+
            '                           \"pep\":\"PROX\",'+
            '                           \"pessoaRelacionamentoPep\":{'+
            '                              \"tipo\":\"FIS\",'+
            '                              \"nome\":\"Tiririca\",'+
            '                              \"dadosPessoaFisica\":{'+
            '                                 \"numeroCpf\":\"45030686878\",'+
            '                                 \"digitoCpf\":\"56\"'+
            '                              }'+
            '                           }'+
            '                        },'+
            '                        \"contatoEmergencia\":{'+
            '                           \"nome\":\"Donald Duck\",'+
            '                           \"ddd\":11,'+
            '                           \"telefone\":\"965214220\"'+
            '                        }'+
            '                     }'+
            '                  ]'+
            '               },'+
            '               {'+
            '                  \"numero\":2,'+
            '                  \"qtdeVidas\":1,'+
            '                  \"segurados\":['+
            '                     {'+
            '                        \"numero\":1,'+
            '                        \"pessoa\":{'+
            '                           \"tipo\":\"FIS\",'+
            '                           \"nome\":\"ZEZINHO DUCK\",'+
            '                           \"email\":\"xinha36661@hotmail.de\",'+
            '                           \"dadosPessoaFisica\":{'+
            '                              \"numeroCpf\":\"45030686878\",'+
            '                              \"digitoCpf\":\"85\",'+
            '                              \"dataNascimento\":\"1945-12-10\"'+
            '                           },'+
            '                           \"enderecos\":['+
            '                              {'+
            '                                 \"paisResidencia\":\"Alemanha\"'+
            '                              }'+
            '                           ],'+
            '                           \"telefones\":['+
            '                              {'+
            '                                 \"tipoTelefone\":\"CEL\",'+
            '                                 \"numeroTelefone\":\"971452694\",'+
            '                                 \"dddTelefone\":\"11\"'+
            '                              }'+
            '                           ],'+
            '                           \"pep\":\"PROX\",'+
            '                           \"pessoaRelacionamentoPep\":{'+
            '                              \"tipo\":\"FIS\",'+
            '                              \"nome\":\"Tiririca\",'+
            '                              \"dadosPessoaFisica\":{'+
            '                                 \"numeroCpf\":\"509563680\",'+
            '                                 \"digitoCpf\":\"85\"'+
            '                              }'+
            '                           }'+
            '                        },'+
            '                        \"contatoEmergencia\":{'+
            '                           \"nome\":\"Donald Duck\",'+
            '                           \"ddd\":11,'+
            '                           \"telefone\":\"965214220\"'+
            '                        }'+
            '                     }'+
            '                  ]'+
            '               }'+
            '            ]'+
            '         }'+
            '      ],'+
            '      \"remuneracoes\":['+
            '         {'+
            '            \"tipoRemuneracao\":\"Corretagem\",'+
            '            \"percentual\":20.0,'+
            '            \"favorecidos\":['+
            '               {'+
            '                  \"papel\":\"Corretor\",'+
            '                  \"participacao\":100.0,'+
            '                  \"corretorLider\":true,'+
            '                  \"susep\":\"C1192J\",'+
            '                  \"pessoa\":{'+
            '                     \"tipo\":\"JUR\",'+
            '                     \"nome\":\"CLARA ROSEMBLAT CORRETORA DE SEGUROS\",'+
            '                     \"dadosPessoaJuridica\":{'+
            '                        \"numeroCnpj\":\"27351731\",'+
            '                        \"ordemCnpj\":\"0001\",'+
            '                        \"digitoCnpj\":\"38\"'+
            '                     }'+
            '                  }'+
            '               }'+
            '            ]'+
            '         }'+
            '      ]'+
            '   }'+
            '}'; 
        
        
        EmissaoTO.PayloadTO payload1 = (EmissaoTO.PayloadTO) System.JSON.deserialize(json, EmissaoTO.PayloadTO.class);
        
        ValidaInformacoesSegurados.ValidaInformacoes(payload1); 
    }
   // AV-699 Inicio  
      static testMethod void TestCpfBloqueado()
    {
                       
        system.debug('TestCpfBloqueado');
        String json = '{'+
            '   \"proposta\":{'+
            '      \"numeroOrcamento\":\"PPW-478586\",'+
            '      \"numeroPortal\":478586,'+
            '      \"dataProtocolo\":\"2019-11-28\",'+
            '      \"contratantes\":['+
            '         {'+
            '            \"tipo\":\"PRI\",'+
            '            \"numero\":1,'+
            '            \"pessoa\":{'+
            '               \"tipo\":\"FIS\",'+
            '               \"nome\":\"HUGUINHO DUCK\",'+
            '               \"dadosPessoaFisica\":{'+
            '                  \"numeroCpf\":\"450306868\",'+
            '                  \"digitoCpf\":\"78\",'+
            '                  \"dataNascimento\":\"1995-06-27\"'+
            '               }'+
            '            },'+
            '            \"dadosPagamento\":{'+
            '               \"quantidadeParcelas\":6,'+
            '               \"tipoResponsavelPagamento\":\"CON\",'+
            '               \"codigoFormaPagamento\":62,'+
            '               \"descricaoFormaPagamento\":\"CARTAO DE CREDITO (TODAS PARC.EM CARTAO)\",'+
            '               \"codigoMeioRecebimento\":\"Q\",'+
            '               \"vencimentoPrimeiraParcela\":\"2018-08-30\",'+
            '               \"dadosCartaoCredito\":{'+
            '                  \"numero\":\"4902-6277-3514-4152\",'+
            '                  \"validade\":\"2022-10\",'+
            '                  \"nome\":\"HUGUINHO DUCK\",'+
            '                  \"cvv\":666'+
            '               }'+
            '            },'+
            '            \"grupos\":['+
            '               {'+
            '                  \"numero\":1,'+
            '                  \"qtdeVidas\":1,'+
            '                  \"segurados\":['+
            '                     {'+
            '                        \"numero\":1,'+
            '                        \"pessoa\":{'+
            '                           \"tipo\":\"FIS\",'+
            '                           \"nome\":\"HUGUINHO DUCK\",'+
            '                           \"email\":\"xinha36661@hotmail.de\",'+
            '                           \"dadosPessoaFisica\":{'+
            '                              \"numeroCpf\":\"135138848\",'+
            '                              \"digitoCpf\":\"77\",'+
            '                              \"dataNascimento\":\"1975-12-10\"'+
            '                           },'+
            '                           \"enderecos\":['+
            '                              {'+
            '                                 \"uf\":\"SP\",'+
            '                                 \"tipoLogradouro\":\"R\",'+
            '                                 \"tipoEndereco\":\"RES\",'+
            '                                 \"paisResidencia\":\"Brasil\",'+
            '                                 \"numeroLogradouro\":\"92\",'+
            '                                 \"logradouro\":\"Guaianses\",'+
            '                                 \"complementoCep\":\"420\",'+
            '                                 \"complemento\":\"Apto 22\",'+
            '                                 \"cidade\":\"SAO PAULO\",'+
            '                                 \"cep\":\"07114\",'+
            '                                 \"bairro\":\"Centro\"'+
            '                              }'+
            '                           ],'+
            '                           \"telefones\":['+
            '                              {'+
            '                                 \"tipoTelefone\":\"CEL\",'+
            '                                 \"numeroTelefone\":\"971452694\",'+
            '                                 \"dddTelefone\":\"11\"'+
            '                              }'+
            '                           ],'+
            '                           \"pep\":\"PROX\",'+
            '                           \"pessoaRelacionamentoPep\":{'+
            '                              \"tipo\":\"FIS\",'+
            '                              \"nome\":\"Tiririca\",'+
            '                              \"dadosPessoaFisica\":{'+
            '                                 \"numeroCpf\":\"450306868\",'+
            '                                 \"digitoCpf\":\"78\"'+
            '                              }'+
            '                           }'+
            '                        },'+
            '                        \"contatoEmergencia\":{'+
            '                           \"nome\":\"Donald Duck\",'+
            '                           \"ddd\":11,'+
            '                           \"telefone\":\"965214220\"'+
            '                        }'+
            '                     }'+
            '                  ]'+
            '               },'+
            '               {'+
            '                  \"numero\":2,'+
            '                  \"qtdeVidas\":1,'+
            '                  \"segurados\":['+
            '                     {'+
            '                        \"numero\":1,'+
            '                        \"pessoa\":{'+
            '                           \"tipo\":\"FIS\",'+
            '                           \"nome\":\"ZEZINHO DUCK\",'+
            '                           \"email\":\"xinha36661@hotmail.de\",'+
            '                           \"dadosPessoaFisica\":{'+
            '                              \"numeroCpf\":\"509563680\",'+
            '                              \"digitoCpf\":\"85\",'+
            '                              \"dataNascimento\":\"1945-12-10\"'+
            '                           },'+
            '                           \"enderecos\":['+
            '                              {'+
            '                                 \"paisResidencia\":\"Alemanha\"'+
            '                              }'+
            '                           ],'+
            '                           \"telefones\":['+
            '                              {'+
            '                                 \"tipoTelefone\":\"CEL\",'+
            '                                 \"numeroTelefone\":\"971452694\",'+
            '                                 \"dddTelefone\":\"11\"'+
            '                              }'+
            '                           ],'+
            '                           \"pep\":\"PROX\",'+
            '                           \"pessoaRelacionamentoPep\":{'+
            '                              \"tipo\":\"FIS\",'+
            '                              \"nome\":\"Tiririca\",'+
            '                              \"dadosPessoaFisica\":{'+
            '                                 \"numeroCpf\":\"509563680\",'+
            '                                 \"digitoCpf\":\"85\"'+
            '                              }'+
            '                           }'+
            '                        },'+
            '                        \"contatoEmergencia\":{'+
            '                           \"nome\":\"Donald Duck\",'+
            '                           \"ddd\":11,'+
            '                           \"telefone\":\"965214220\"'+
            '                        }'+
            '                     }'+
            '                  ]'+
            '               }'+
            '            ]'+
            '         }'+
            '      ],'+
            '      \"remuneracoes\":['+
            '         {'+
            '            \"tipoRemuneracao\":\"Corretagem\",'+
            '            \"percentual\":20.0,'+
            '            \"favorecidos\":['+
            '               {'+
            '                  \"papel\":\"Corretor\",'+
            '                  \"participacao\":100.0,'+
            '                  \"corretorLider\":true,'+
            '                  \"susep\":\"C1192J\",'+
            '                  \"pessoa\":{'+
            '                     \"tipo\":\"JUR\",'+
            '                     \"nome\":\"CLARA ROSEMBLAT CORRETORA DE SEGUROS\",'+
            '                     \"dadosPessoaJuridica\":{'+
            '                        \"numeroCnpj\":\"27351731\",'+
            '                        \"ordemCnpj\":\"0001\",'+
            '                        \"digitoCnpj\":\"38\"'+
            '                     }'+
            '                  }'+
            '               }'+
            '            ]'+
            '         }'+
            '      ]'+
            '   }'+
            '}'; 
        
        EmissaoTO.PayloadTO payload1 = (EmissaoTO.PayloadTO) System.JSON.deserialize(json, EmissaoTO.PayloadTO.class);
        
        ValidaInformacoesSegurados.ValidaInformacoes(payload1); 
    }
    // AV-699 fim
    
    
    static testMethod void TestDataDeNascInvalido()
    {
        system.debug('TestDataDeNascInvalido');
        date hoje = System.today();
        String json = '{'+
            '   \"proposta\":{'+
            '      \"numeroOrcamento\":\"PPW-478586\",'+
            '      \"numeroPortal\":478586,'+
            '      \"dataProtocolo\":\"2019-11-28\",'+
            '      \"contratantes\":['+
            '         {'+
            '            \"tipo\":\"PRI\",'+
            '            \"numero\":1,'+
            '            \"pessoa\":{'+
            '               \"tipo\":\"FIS\",'+
            '               \"nome\":\"HUGUINHO DUCK\",'+
            '               \"dadosPessoaFisica\":{'+
            '                  \"numeroCpf\":\"450306868\",'+
            '                  \"digitoCpf\":\"78\",'+
            '                  \"dataNascimento\":\"'+hoje+'\"'+
            '               }'+
            '            },'+
            '            \"dadosPagamento\":{'+
            '               \"quantidadeParcelas\":6,'+
            '               \"tipoResponsavelPagamento\":\"CON\",'+
            '               \"codigoFormaPagamento\":62,'+
            '               \"descricaoFormaPagamento\":\"CARTAO DE CREDITO (TODAS PARC.EM CARTAO)\",'+
            '               \"codigoMeioRecebimento\":\"Q\",'+
            '               \"vencimentoPrimeiraParcela\":\"2018-08-30\",'+
            '               \"dadosCartaoCredito\":{'+
            '                  \"numero\":\"4902-6277-3514-4152\",'+
            '                  \"validade\":\"2022-10\",'+
            '                  \"nome\":\"HUGUINHO DUCK\",'+
            '                  \"cvv\":666'+
            '               }'+
            '            },'+
            '            \"grupos\":['+
            '               {'+
            '                  \"numero\":1,'+
            '                  \"qtdeVidas\":1,'+
            '                  \"segurados\":['+
            '                     {'+
            '                        \"numero\":1,'+
            '                        \"pessoa\":{'+
            '                           \"tipo\":\"FIS\",'+
            '                           \"nome\":\"HUGUINHO DUCK\",'+
            '                           \"email\":\"xinha36661@hotmail.de\",'+
            '                           \"dadosPessoaFisica\":{'+
            '                              \"numeroCpf\":\"135138848\",'+
            '                              \"digitoCpf\":\"77\",'+
            '                  				\"dataNascimento\":\"'+hoje+'\"'+
            '                           },'+
            '                           \"enderecos\":['+
            '                              {'+
            '                                 \"uf\":\"SP\",'+
            '                                 \"tipoLogradouro\":\"R\",'+
            '                                 \"tipoEndereco\":\"RES\",'+
            '                                 \"paisResidencia\":\"Brasil\",'+
            '                                 \"numeroLogradouro\":\"92\",'+
            '                                 \"logradouro\":\"Guaianses\",'+
            '                                 \"complementoCep\":\"420\",'+
            '                                 \"complemento\":\"Apto 22\",'+
            '                                 \"cidade\":\"SAO PAULO\",'+
            '                                 \"cep\":\"07114\",'+
            '                                 \"bairro\":\"Centro\"'+
            '                              }'+
            '                           ],'+
            '                           \"telefones\":['+
            '                              {'+
            '                                 \"tipoTelefone\":\"CEL\",'+
            '                                 \"numeroTelefone\":\"971452694\",'+
            '                                 \"dddTelefone\":\"11\"'+
            '                              }'+
            '                           ],'+
            '                           \"pep\":\"PROX\",'+
            '                           \"pessoaRelacionamentoPep\":{'+
            '                              \"tipo\":\"FIS\",'+
            '                              \"nome\":\"Tiririca\",'+
            '                              \"dadosPessoaFisica\":{'+
            '                                 \"numeroCpf\":\"45030686878\",'+
            '                                 \"digitoCpf\":\"56\"'+
            '                              }'+
            '                           }'+
            '                        },'+
            '                        \"contatoEmergencia\":{'+
            '                           \"nome\":\"Donald Duck\",'+
            '                           \"ddd\":11,'+
            '                           \"telefone\":\"965214220\"'+
            '                        }'+
            '                     }'+
            '                  ]'+
            '               },'+
            '               {'+
            '                  \"numero\":2,'+
            '                  \"qtdeVidas\":1,'+
            '                  \"segurados\":['+
            '                     {'+
            '                        \"numero\":1,'+
            '                        \"pessoa\":{'+
            '                           \"tipo\":\"FIS\",'+
            '                           \"nome\":\"ZEZINHO DUCK\",'+
            '                           \"email\":\"xinha36661@hotmail.de\",'+
            '                           \"dadosPessoaFisica\":{'+
            '                              \"numeroCpf\":\"509563680\",'+
            '                              \"digitoCpf\":\"85\",'+
            '                  				\"dataNascimento\":\"'+hoje+'\"'+
            '                           },'+
            '                           \"enderecos\":['+
            '                              {'+
            '                                 \"paisResidencia\":\"Alemanha\"'+
            '                              }'+
            '                           ],'+
            '                           \"telefones\":['+
            '                              {'+
            '                                 \"tipoTelefone\":\"CEL\",'+
            '                                 \"numeroTelefone\":\"971452694\",'+
            '                                 \"dddTelefone\":\"11\"'+
            '                              }'+
            '                           ],'+
            '                           \"pep\":\"PROX\",'+
            '                           \"pessoaRelacionamentoPep\":{'+
            '                              \"tipo\":\"FIS\",'+
            '                              \"nome\":\"Tiririca\",'+
            '                              \"dadosPessoaFisica\":{'+
            '                                 \"numeroCpf\":\"509563680\",'+
            '                                 \"digitoCpf\":\"85\"'+
            '                              }'+
            '                           }'+
            '                        },'+
            '                        \"contatoEmergencia\":{'+
            '                           \"nome\":\"Donald Duck\",'+
            '                           \"ddd\":11,'+
            '                           \"telefone\":\"965214220\"'+
            '                        }'+
            '                     }'+
            '                  ]'+
            '               }'+
            '            ]'+
            '         }'+
            '      ],'+
            '      \"remuneracoes\":['+
            '         {'+
            '            \"tipoRemuneracao\":\"Corretagem\",'+
            '            \"percentual\":20.0,'+
            '            \"favorecidos\":['+
            '               {'+
            '                  \"papel\":\"Corretor\",'+
            '                  \"participacao\":100.0,'+
            '                  \"corretorLider\":true,'+
            '                  \"susep\":\"C1192J\",'+
            '                  \"pessoa\":{'+
            '                     \"tipo\":\"JUR\",'+
            '                     \"nome\":\"CLARA ROSEMBLAT CORRETORA DE SEGUROS\",'+
            '                     \"dadosPessoaJuridica\":{'+
            '                        \"numeroCnpj\":\"27351731\",'+
            '                        \"ordemCnpj\":\"0001\",'+
            '                        \"digitoCnpj\":\"38\"'+
            '                     }'+
            '                  }'+
            '               }'+
            '            ]'+
            '         }'+
            '      ]'+
            '   }'+
            '}'; 
        
        
        EmissaoTO.PayloadTO payload1 = (EmissaoTO.PayloadTO) System.JSON.deserialize(json, EmissaoTO.PayloadTO.class);
        
        ValidaInformacoesSegurados.ValidaInformacoes(payload1);     
        
    } 
    
    static testMethod void TestErroSeguradoMesmoCpf()
    {
        String json = '{'+
            '   \"proposta\":{'+
            '      \"numeroOrcamento\":\"PPW-478586\",'+
            '      \"numeroPortal\":478586,'+
            '      \"dataProtocolo\":\"2019-11-28\",'+
            '      \"contratantes\":['+
            '         {'+
            '            \"tipo\":\"PRI\",'+
            '            \"numero\":1,'+
            '            \"pessoa\":{'+
            '               \"tipo\":\"FIS\",'+
            '               \"nome\":\"HUGUINHO DUCK\",'+
            '               \"dadosPessoaFisica\":{'+
            '                  \"numeroCpf\":\"450306868\",'+
            '                  \"digitoCpf\":\"78\",'+
            '                  \"dataNascimento\":\"1995-06-27\"'+
            '               }'+
            '            },'+
            '            \"dadosPagamento\":{'+
            '               \"quantidadeParcelas\":6,'+
            '               \"tipoResponsavelPagamento\":\"CON\",'+
            '               \"codigoFormaPagamento\":62,'+
            '               \"descricaoFormaPagamento\":\"CARTAO DE CREDITO (TODAS PARC.EM CARTAO)\",'+
            '               \"codigoMeioRecebimento\":\"Q\",'+
            '               \"vencimentoPrimeiraParcela\":\"2018-08-30\",'+
            '               \"dadosCartaoCredito\":{'+
            '                  \"numero\":\"4902-6277-3514-4152\",'+
            '                  \"validade\":\"2022-10\",'+
            '                  \"nome\":\"HUGUINHO DUCK\",'+
            '                  \"cvv\":666'+
            '               }'+
            '            },'+
            '            \"grupos\":['+
            '               {'+
            '                  \"numero\":1,'+
            '                  \"qtdeVidas\":1,'+
            '                  \"segurados\":['+
            '                     {'+
            '                        \"numero\":1,'+
            '                        \"pessoa\":{'+
            '                           \"tipo\":\"FIS\",'+
            '                           \"nome\":\"HUGUINHO DUCK\",'+
            '                           \"email\":\"xinha36661@hotmail.de\",'+
            '                           \"dadosPessoaFisica\":{'+
            '                              \"numeroCpf\":\"135138848\",'+
            '                              \"digitoCpf\":\"77\",'+
            '                              \"dataNascimento\":\"1975-12-10\"'+
            '                           },'+
            '                           \"enderecos\":['+
            '                              {'+
            '                                 \"uf\":\"SP\",'+
            '                                 \"tipoLogradouro\":\"R\",'+
            '                                 \"tipoEndereco\":\"RES\",'+
            '                                 \"paisResidencia\":\"Brasil\",'+
            '                                 \"numeroLogradouro\":\"92\",'+
            '                                 \"logradouro\":\"Guaianses\",'+
            '                                 \"complementoCep\":\"420\",'+
            '                                 \"complemento\":\"Apto 22\",'+
            '                                 \"cidade\":\"SAO PAULO\",'+
            '                                 \"cep\":\"07114\",'+
            '                                 \"bairro\":\"Centro\"'+
            '                              }'+
            '                           ],'+
            '                           \"telefones\":['+
            '                              {'+
            '                                 \"tipoTelefone\":\"CEL\",'+
            '                                 \"numeroTelefone\":\"971452694\",'+
            '                                 \"dddTelefone\":\"11\"'+
            '                              }'+
            '                           ],'+
            '                           \"pep\":\"PROX\",'+
            '                           \"pessoaRelacionamentoPep\":{'+
            '                              \"tipo\":\"FIS\",'+
            '                              \"nome\":\"Tiririca\",'+
            '                              \"dadosPessoaFisica\":{'+
            '                                 \"numeroCpf\":\"45030686878\",'+
            '                                 \"digitoCpf\":\"56\"'+
            '                              }'+
            '                           }'+
            '                        },'+
            '                        \"contatoEmergencia\":{'+
            '                           \"nome\":\"Donald Duck\",'+
            '                           \"ddd\":11,'+
            '                           \"telefone\":\"965214220\"'+
            '                        }'+
            '                     }'+
            '                  ]'+
            '               },'+
            '               {'+
            '                  \"numero\":2,'+
            '                  \"qtdeVidas\":1,'+
            '                  \"segurados\":['+
            '                     {'+
            '                        \"numero\":1,'+
            '                        \"pessoa\":{'+
            '                           \"tipo\":\"FIS\",'+
            '                           \"nome\":\"ZEZINHO DUCK\",'+
            '                           \"email\":\"xinha36661@hotmail.de\",'+
            '                           \"dadosPessoaFisica\":{'+
            '                              \"numeroCpf\":\"135138848\",'+
            '                              \"digitoCpf\":\"77\",'+
            '                              \"dataNascimento\":\"1945-12-10\"'+
            '                           },'+
            '                           \"enderecos\":['+
            '                              {'+
            '                                 \"paisResidencia\":\"Alemanha\"'+
            '                              }'+
            '                           ],'+
            '                           \"telefones\":['+
            '                              {'+
            '                                 \"tipoTelefone\":\"CEL\",'+
            '                                 \"numeroTelefone\":\"971452694\",'+
            '                                 \"dddTelefone\":\"11\"'+
            '                              }'+
            '                           ],'+
            '                           \"pep\":\"PROX\",'+
            '                           \"pessoaRelacionamentoPep\":{'+
            '                              \"tipo\":\"FIS\",'+
            '                              \"nome\":\"Tiririca\",'+
            '                              \"dadosPessoaFisica\":{'+
            '                                 \"numeroCpf\":\"45036868\",'+
            '                                 \"digitoCpf\":\"78\"'+
            '                              }'+
            '                           }'+
            '                        },'+
            '                        \"contatoEmergencia\":{'+
            '                           \"nome\":\"Donald Duck\",'+
            '                           \"ddd\":11,'+
            '                           \"telefone\":\"965214220\"'+
            '                        }'+
            '                     }'+
            '                  ]'+
            '               }'+
            '            ]'+
            '         }'+
            '      ],'+
            '      \"remuneracoes\":['+
            '         {'+
            '            \"tipoRemuneracao\":\"Corretagem\",'+
            '            \"percentual\":20.0,'+
            '            \"favorecidos\":['+
            '               {'+
            '                  \"papel\":\"Corretor\",'+
            '                  \"participacao\":100.0,'+
            '                  \"corretorLider\":true,'+
            '                  \"susep\":\"C1192J\",'+
            '                  \"pessoa\":{'+
            '                     \"tipo\":\"JUR\",'+
            '                     \"nome\":\"CLARA ROSEMBLAT CORRETORA DE SEGUROS\",'+
            '                     \"dadosPessoaJuridica\":{'+
            '                        \"numeroCnpj\":\"27351731\",'+
            '                        \"ordemCnpj\":\"0001\",'+
            '                        \"digitoCnpj\":\"38\"'+
            '                     }'+
            '                  }'+
            '               }'+
            '            ]'+
            '         }'+
            '      ]'+
            '   }'+
            '}'; 
        
        EmissaoTO.PayloadTO payload1 = (EmissaoTO.PayloadTO) System.JSON.deserialize(json, EmissaoTO.PayloadTO.class);
        
        ValidaInformacoesSegurados.ValidaInformacoes(payload1);   
    }    
    static testMethod void TestErroCpfValores()
    {	
        String json = '{'+
            '   \"proposta\":{'+
            '      \"numeroOrcamento\":\"PPW-478586\",'+
            '      \"numeroPortal\":478586,'+
            '      \"dataProtocolo\":\"2019-11-28\",'+
            '      \"contratantes\":['+
            '         {'+
            '            \"tipo\":\"PRI\",'+
            '            \"numero\":1,'+
            '            \"pessoa\":{'+
            '               \"tipo\":\"FIS\",'+
            '               \"nome\":\"HUGUINHO DUCK\",'+
            '               \"dadosPessoaFisica\":{'+
            '                  \"numeroCpf\":\"450306868\",'+
            '                  \"digitoCpf\":\"78\",'+
            '                   \"dataNascimento\":\"1975-12-10\"'+
            '               }'+
            '            },'+
            '            \"dadosPagamento\":{'+
            '               \"quantidadeParcelas\":6,'+
            '               \"tipoResponsavelPagamento\":\"CON\",'+
            '               \"codigoFormaPagamento\":62,'+
            '               \"descricaoFormaPagamento\":\"CARTAO DE CREDITO (TODAS PARC.EM CARTAO)\",'+
            '               \"codigoMeioRecebimento\":\"Q\",'+
            '               \"vencimentoPrimeiraParcela\":\"2018-08-30\",'+
            '               \"dadosCartaoCredito\":{'+
            '                  \"numero\":\"4902-6277-3514-4152\",'+
            '                  \"validade\":\"2022-10\",'+
            '                  \"nome\":\"HUGUINHO DUCK\",'+
            '                  \"cvv\":666'+
            '               }'+
            '            },'+
            '            \"grupos\":['+
            '               {'+
            '                  \"numero\":1,'+
            '                  \"qtdeVidas\":1,'+
            '                  \"segurados\":['+
            '                     {'+
            '                        \"numero\":1,'+
            '                        \"pessoa\":{'+
            '                           \"tipo\":\"FIS\",'+
            '                           \"nome\":\"HUGUINHO DUCK\",'+
            '                           \"email\":\"xinha36661@hotmail.de\",'+
            '                           \"dadosPessoaFisica\":{'+
            '                              \"numeroCpf\":\"135138848\",'+
            '                              \"digitoCpf\":\"79\",'+
            '                              \"dataNascimento\":\"1975-12-10\"'+
            '                           },'+
            '                           \"enderecos\":['+
            '                              {'+
            '                                 \"uf\":\"SP\",'+
            '                                 \"tipoLogradouro\":\"R\",'+
            '                                 \"tipoEndereco\":\"RES\",'+
            '                                 \"paisResidencia\":\"Brasil\",'+
            '                                 \"numeroLogradouro\":\"92\",'+
            '                                 \"logradouro\":\"Guaianses\",'+
            '                                 \"complementoCep\":\"420\",'+
            '                                 \"complemento\":\"Apto 22\",'+
            '                                 \"cidade\":\"SAO PAULO\",'+
            '                                 \"cep\":\"07114\",'+
            '                                 \"bairro\":\"Centro\"'+
            '                              }'+
            '                           ],'+
            '                           \"telefones\":['+
            '                              {'+
            '                                 \"tipoTelefone\":\"CEL\",'+
            '                                 \"numeroTelefone\":\"971452694\",'+
            '                                 \"dddTelefone\":\"11\"'+
            '                              }'+
            '                           ],'+
            '                           \"pep\":\"PROX\",'+
            '                           \"pessoaRelacionamentoPep\":{'+
            '                              \"tipo\":\"FIS\",'+
            '                              \"nome\":\"Tiririca\",'+
            '                              \"dadosPessoaFisica\":{'+
            '                                 \"numeroCpf\":\"45030686878\",'+
            '                                 \"digitoCpf\":\"56\"'+
            '                              }'+
            '                           }'+
            '                        },'+
            '                        \"contatoEmergencia\":{'+
            '                           \"nome\":\"Donald Duck\",'+
            '                           \"ddd\":11,'+
            '                           \"telefone\":\"965214220\"'+
            '                        }'+
            '                     }'+
            '                  ]'+
            '               },'+
            '               {'+
            '                  \"numero\":2,'+
            '                  \"qtdeVidas\":1,'+
            '                  \"segurados\":['+
            '                     {'+
            '                        \"numero\":1,'+
            '                        \"pessoa\":{'+
            '                           \"tipo\":\"FIS\",'+
            '                           \"nome\":\"ZEZINHO DUCK\",'+
            '                           \"email\":\"xinha36661@hotmail.de\",'+
            '                           \"dadosPessoaFisica\":{'+
            '                              \"numeroCpf\":\"450306868\",'+
            '                              \"digitoCpf\":\"76\",'+
            '                              \"dataNascimento\":\"1945-12-10\"'+
            '                           },'+
            '                           \"enderecos\":['+
            '                              {'+
            '                                 \"paisResidencia\":\"Alemanha\"'+
            '                              }'+
            '                           ],'+
            '                           \"telefones\":['+
            '                              {'+
            '                                 \"tipoTelefone\":\"CEL\",'+
            '                                 \"numeroTelefone\":\"971452694\",'+
            '                                 \"dddTelefone\":\"11\"'+
            '                              }'+
            '                           ],'+
            '                           \"pep\":\"PROX\",'+
            '                           \"pessoaRelacionamentoPep\":{'+
            '                              \"tipo\":\"FIS\",'+
            '                              \"nome\":\"Tiririca\",'+
            '                              \"dadosPessoaFisica\":{'+
            '                                 \"numeroCpf\":\"45036868\",'+
            '                                 \"digitoCpf\":\"78\"'+
            '                              }'+
            '                           }'+
            '                        },'+
            '                        \"contatoEmergencia\":{'+
            '                           \"nome\":\"Donald Duck\",'+
            '                           \"ddd\":11,'+
            '                           \"telefone\":\"965214220\"'+
            '                        }'+
            '                     }'+
            '                  ]'+
            '               }'+
            '            ]'+
            '         }'+
            '      ],'+
            '      \"remuneracoes\":['+
            '         {'+
            '            \"tipoRemuneracao\":\"Corretagem\",'+
            '            \"percentual\":20.0,'+
            '            \"favorecidos\":['+
            '               {'+
            '                  \"papel\":\"Corretor\",'+
            '                  \"participacao\":100.0,'+
            '                  \"corretorLider\":true,'+
            '                  \"susep\":\"C1192J\",'+
            '                  \"pessoa\":{'+
            '                     \"tipo\":\"JUR\",'+
            '                     \"nome\":\"CLARA ROSEMBLAT CORRETORA DE SEGUROS\",'+
            '                     \"dadosPessoaJuridica\":{'+
            '                        \"numeroCnpj\":\"27351731\",'+
            '                        \"ordemCnpj\":\"0001\",'+
            '                        \"digitoCnpj\":\"38\"'+
            '                     }'+
            '                  }'+
            '               }'+
            '            ]'+
            '         }'+
            '      ]'+
            '   }'+
            '}'; 
        
        
        EmissaoTO.PayloadTO payload1 = (EmissaoTO.PayloadTO) System.JSON.deserialize(json, EmissaoTO.PayloadTO.class);
        
        ValidaInformacoesSegurados.ValidaInformacoes(payload1); 
    }    
    static testMethod void TestErroCpfContratante()
    {	
        String json = '{'+
            '   \"proposta\":{'+
            '      \"numeroOrcamento\":\"PPW-478586\",'+
            '      \"numeroPortal\":478586,'+
            '      \"dataProtocolo\":\"2019-11-28\",'+
            '      \"contratantes\":['+
            '         {'+
            '            \"tipo\":\"PRI\",'+
            '            \"numero\":1,'+
            '            \"pessoa\":{'+
            '               \"tipo\":\"FIS\",'+
            '               \"nome\":\"HUGUINHO DUCK\",'+
            '               \"dadosPessoaFisica\":{'+
            '                  \"numeroCpf\":\"450306868\",'+
            '                  \"digitoCpf\":\"78\",'+
            '                   \"dataNascimento\":\"1975-12-10\"'+
            '               }'+
            '            },'+
            '            \"dadosPagamento\":{'+
            '               \"quantidadeParcelas\":6,'+
            '               \"tipoResponsavelPagamento\":\"CON\",'+
            '               \"codigoFormaPagamento\":62,'+
            '               \"descricaoFormaPagamento\":\"CARTAO DE CREDITO (TODAS PARC.EM CARTAO)\",'+
            '               \"codigoMeioRecebimento\":\"Q\",'+
            '               \"vencimentoPrimeiraParcela\":\"2018-08-30\",'+
            '               \"dadosCartaoCredito\":{'+
            '                  \"numero\":\"4902-6277-3514-4152\",'+
            '                  \"validade\":\"2022-10\",'+
            '                  \"nome\":\"HUGUINHO DUCK\",'+
            '                  \"cvv\":666'+
            '               }'+
            '            },'+
            '            \"grupos\":['+
            '               {'+
            '                  \"numero\":1,'+
            '                  \"qtdeVidas\":1,'+
            '                  \"segurados\":['+
            '                     {'+
            '                        \"numero\":1,'+
            '                        \"pessoa\":{'+
            '                           \"tipo\":\"FIS\",'+
            '                           \"nome\":\"HUGUINHO DUCK\",'+
            '                           \"email\":\"xinha36661@hotmail.de\",'+
            '                           \"dadosPessoaFisica\":{'+
            '                              \"numeroCpf\":\"135138848\",'+
            '                              \"digitoCpf\":\"77\",'+
            '                              \"dataNascimento\":\"1975-12-10\"'+
            '                           },'+
            '                           \"enderecos\":['+
            '                              {'+
            '                                 \"uf\":\"SP\",'+
            '                                 \"tipoLogradouro\":\"R\",'+
            '                                 \"tipoEndereco\":\"RES\",'+
            '                                 \"paisResidencia\":\"Brasil\",'+
            '                                 \"numeroLogradouro\":\"92\",'+
            '                                 \"logradouro\":\"Guaianses\",'+
            '                                 \"complementoCep\":\"420\",'+
            '                                 \"complemento\":\"Apto 22\",'+
            '                                 \"cidade\":\"SAO PAULO\",'+
            '                                 \"cep\":\"07114\",'+
            '                                 \"bairro\":\"Centro\"'+
            '                              }'+
            '                           ],'+
            '                           \"telefones\":['+
            '                              {'+
            '                                 \"tipoTelefone\":\"CEL\",'+
            '                                 \"numeroTelefone\":\"971452694\",'+
            '                                 \"dddTelefone\":\"11\"'+
            '                              }'+
            '                           ],'+
            '                           \"pep\":\"PROX\",'+
            '                           \"pessoaRelacionamentoPep\":{'+
            '                              \"tipo\":\"FIS\",'+
            '                              \"nome\":\"Tiririca\",'+
            '                              \"dadosPessoaFisica\":{'+
            '                                 \"numeroCpf\":\"45030686878\",'+
            '                                 \"digitoCpf\":\"56\"'+
            '                              }'+
            '                           }'+
            '                        },'+
            '                        \"contatoEmergencia\":{'+
            '                           \"nome\":\"Donald Duck\",'+
            '                           \"ddd\":11,'+
            '                           \"telefone\":\"965214220\"'+
            '                        }'+
            '                     }'+
            '                  ]'+
            '               },'+
            '               {'+
            '                  \"numero\":2,'+
            '                  \"qtdeVidas\":1,'+
            '                  \"segurados\":['+
            '                     {'+
            '                        \"numero\":1,'+
            '                        \"pessoa\":{'+
            '                           \"tipo\":\"FIS\",'+
            '                           \"nome\":\"ZEZINHO DUCK\",'+
            '                           \"email\":\"xinha36661@hotmail.de\",'+
            '                           \"dadosPessoaFisica\":{'+
            '                              \"numeroCpf\":\"450306868\",'+
            '                              \"digitoCpf\":\"78\",'+
            '                              \"dataNascimento\":\"1975-12-19\"'+
            '                           },'+
            '                           \"enderecos\":['+
            '                              {'+
            '                                 \"paisResidencia\":\"Alemanha\"'+
            '                              }'+
            '                           ],'+
            '                           \"telefones\":['+
            '                              {'+
            '                                 \"tipoTelefone\":\"CEL\",'+
            '                                 \"numeroTelefone\":\"971452694\",'+
            '                                 \"dddTelefone\":\"11\"'+
            '                              }'+
            '                           ],'+
            '                           \"pep\":\"PROX\",'+
            '                           \"pessoaRelacionamentoPep\":{'+
            '                              \"tipo\":\"FIS\",'+
            '                              \"nome\":\"Tiririca\",'+
            '                              \"dadosPessoaFisica\":{'+
            '                                 \"numeroCpf\":\"45036868\",'+
            '                                 \"digitoCpf\":\"78\"'+
            '                              }'+
            '                           }'+
            '                        },'+
            '                        \"contatoEmergencia\":{'+
            '                           \"nome\":\"Donald Duck\",'+
            '                           \"ddd\":11,'+
            '                           \"telefone\":\"965214220\"'+
            '                        }'+
            '                     }'+
            '                  ]'+
            '               }'+
            '            ]'+
            '         }'+
            '      ],'+
            '      \"remuneracoes\":['+
            '         {'+
            '            \"tipoRemuneracao\":\"Corretagem\",'+
            '            \"percentual\":20.0,'+
            '            \"favorecidos\":['+
            '               {'+
            '                  \"papel\":\"Corretor\",'+
            '                  \"participacao\":100.0,'+
            '                  \"corretorLider\":true,'+
            '                  \"susep\":\"C1192J\",'+
            '                  \"pessoa\":{'+
            '                     \"tipo\":\"JUR\",'+
            '                     \"nome\":\"CLARA ROSEMBLAT CORRETORA DE SEGUROS\",'+
            '                     \"dadosPessoaJuridica\":{'+
            '                        \"numeroCnpj\":\"27351731\",'+
            '                        \"ordemCnpj\":\"0001\",'+
            '                        \"digitoCnpj\":\"38\"'+
            '                     }'+
            '                  }'+
            '               }'+
            '            ]'+
            '         }'+
            '      ]'+
            '   }'+
            '}'; 
        
        
        EmissaoTO.PayloadTO payload1 = (EmissaoTO.PayloadTO) System.JSON.deserialize(json, EmissaoTO.PayloadTO.class);
        
        ValidaInformacoesSegurados.ValidaInformacoes(payload1); 
    }    
    
}