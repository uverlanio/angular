/**
 * Created by Alessndro Ponte on 29/05/2018.
 */
({
  buildListsTableGroup: function(component,event,helper){
    let groups = component.get('v.grupos');
    let columns = [];
    let dados = [];

    groups.forEach(function (element, index, array) {
      if(index == 0) columns.push(...Object.keys(element.Garantias));
      dados.push(Object.values(element.Garantias));
    });
    component.set('v.columns',columns);
    component.set('v.dados',dados);
  },
  parseJSON : function (component, event, helper) {
    let jsonString = '{\n' +
      '    "orcamentos":[\n' +
      '        {\n' +
      '            "solicitacaoOferta":{\n' +
      '                "segmento":"VG",\n' +
      '                "meioComercializacao":"PPW",\n' +
      '                "numeroOrcamento":647658,\n' +
      '                "numeroPortal":988444,\n' +
      '                "dataCalculo":"2016-09-16",\n' +
      '                "dataCriacaoPortal":"2016-09-09",\n' +
      '                "codigoProdutoPortal":121,\n' +
      '                "codigoProdutoVida":260,\n' +
      '                "tipoVigencia":"PCU",\n' +
      '                "vigenciaInicial":"2016-09-23",\n' +
      '                "vigenciaFinal":"2016-09-30",\n' +
      '                "qtdDiasVigencia":8,\n' +
      '                "tipoSeguro":"NOV",\n' +
      '                "tipoAdesao":"TOT",\n' +
      '                "evento":{\n' +
      '                    "tipoEvento":"SHO",\n' +
      '                    "qstControlePublico":"SIM",\n' +
      '                    "qstLocalEvento":"SIM",\n' +
      '                    "informacoesEvento":"Ocorrerá durante os jogos do Brasil na Copa do Mundo"\n' +
      '                },\n' +
      '                "viagem":{\n' +
      '                    "tipoViagem":"INT",\n' +
      '                    "praticaEsportesAventura":"NAO",\n' +
      '                    "utilizaraMotocicleta":"SIM",\n' +
      '                    "incluiPaisSchengen":"NAO",\n' +
      '                    "trackageBagagem":"SIM",\n' +
      '                    "destinos":[\n' +
      '                        {\n' +
      '                            "pais":"Alemanha"\n' +
      '                        },\n' +
      '                        {\n' +
      '                            "pais":"Italia"\n' +
      '                        },\n' +
      '                        {\n' +
      '                            "pais":"China"\n' +
      '                        }\n' +
      '                    ],\n' +
      '                    "passageirosNaoIdosos":3,\n' +
      '                    "passageirosIdosos":1\n' +
      '                },\n' +
      '                "transferenciaCongenere":{\n' +
      '                    "congenere":"SULAMERICA",\n' +
      '                    "tempoPermanencia":3,\n' +
      '                    "sinistralidade":1.2,\n' +
      '                    "taxaVigencia":2.1\n' +
      '                },\n' +
      '                "observacoesGerais":"Solicito atendimento especial.",\n' +
      '                "segurados":[\n' +
      '                    {\n' +
      '                        "tipo":"PRI",\n' +
      '                        "pessoa":{\n' +
      '                            "tipo":"FIS",\n' +
      '                            "telefones":[\n' +
      '                                {\n' +
      '                                    "tipoTelefone":"CEL",\n' +
      '                                    "numeroTelefone":"971452694",\n' +
      '                                    "dddTelefone":"11"\n' +
      '                                }\n' +
      '                            ],\n' +
      '                            "nome":"Mussum Forevis",\n' +
      '                            "enderecos":[\n' +
      '                                {\n' +
      '                                    "uf":"SP",\n' +
      '                                    "tipoLogradouro":"R",\n' +
      '                                    "tipoEndereco":"RES",\n' +
      '                                    "paisResidencia":"BRA",\n' +
      '                                    "numeroLogradouro":"92",\n' +
      '                                    "logradouro":"Guaianses",\n' +
      '                                    "complementoCep":"420",\n' +
      '                                    "complemento":"Apto 22",\n' +
      '                                    "cidade":"SAO PAULO",\n' +
      '                                    "cep":"07114",\n' +
      '                                    "bairro":"Centro"\n' +
      '                                }\n' +
      '                            ],\n' +
      '                            "email":"mussum.forevis@gmail.com",\n' +
      '                            "dadosPessoaJuridica":{\n' +
      '                                "cnpj":"00062999/0001-01",\n' +
      '                                "codigoCNAE":7490101,\n' +
      '                                "descricaoCNAE":"SERVI&#199;OS DE TRADU&#199;&#195;OINTERPRETA&#199;&#195;O E SIMILARES"\n' +
      '                            },\n' +
      '                            "dadosPessoaFisica":{\n' +
      '                                "tipoRelacionamentoPep":"Pai",\n' +
      '                                "sexo":"MAS",\n' +
      '                                "profissao":"493-09/883",\n' +
      '                                "pessoaRelacionamentoPep":{\n' +
      '                                    "tipo":"FIS",\n' +
      '                                    "nome":"Marcelo Freixo",\n' +
      '                                    "dadosPessoaFisica":{\n' +
      '                                        "numeroCpf":"123456789",\n' +
      '                                        "digitoCpf":"56"\n' +
      '                                    }\n' +
      '                                },\n' +
      '                                "pep":true,\n' +
      '                                "numeroCpf":"387308998",\n' +
      '                                "nacionalidade":"BRA",\n' +
      '                                "estadoCivil":"CAS",\n' +
      '                                "documentos":[\n' +
      '                                    {\n' +
      '                                        "tipoDocumentoIdentidade":"RG",\n' +
      '                                        "orgaoExpedidorDocumento":"SSP",\n' +
      '                                        "numeroDocumentoIdentidade":"4798840555",\n' +
      '                                        "dataExpedicaoDocumento":"2000-06-29"\n' +
      '                                    }\n' +
      '                                ],\n' +
      '                                "digitoCpf":"00",\n' +
      '                                "dataNascimento":"1980-06-29"\n' +
      '                            }\n' +
      '                        },\n' +
      '                        "grupos":[\n' +
      '                            {\n' +
      '                                "tipoSegurado":"COO",\n' +
      '                                "qtdeVidas":444,\n' +
      '                                "idArquivoVidas":"Planilha_Upload_Vida_09_03_2018_15_53_40.xls",\n' +
      '                                "tipoCalculo":"GLO",\n' +
      '                                "prazoMaximoFinanciamentoPrestamista":56,\n' +
      '                                "saldoDevedor":5000.0,\n' +
      '                                "valorDoBem":40000.0,\n' +
      '                                "vidas":[\n' +
      '                                    {\n' +
      '                                        "numeroCpf":null,\n' +
      '                                        "digitoCpf":null,\n' +
      '                                        "nome":null,\n' +
      '                                        "dataNascimento":"1975-12-10",\n' +
      '                                        "afastado":"NAO",\n' +
      '                                        "cid":null,\n' +
      '                                        "coberturas":[\n' +
      '                                            {\n' +
      '                                                "sigla":"IPA",\n' +
      '                                                "percentual":75.0,\n' +
      '                                                "garantiaReferenciada":"MAP",\n' +
      '                                                "agravo":10.0\n' +
      '                                            },\n' +
      '                                            {\n' +
      '                                                "sigla":"AFI",\n' +
      '                                                "valor":4000.0,\n' +
      '                                                "desconto":6.0\n' +
      '                                            },\n' +
      '                                            {\n' +
      '                                                "sigla":"COJ",\n' +
      '                                                "percentual":80.0,\n' +
      '                                                "inclusaoIndenizacaoEspecial":"SIM",\n' +
      '                                                "percentualIndenizacaoEspecial":50\n' +
      '                                            },\n' +
      '                                            {\n' +
      '                                                "sigla":"CJP",\n' +
      '                                                "percentual":80.0,\n' +
      '                                                "inclusaoFilhos":"SIM",\n' +
      '                                                "percentualFilhos":50.0\n' +
      '                                            }\n' +
      '                                        ]\n' +
      '                                    },\n' +
      '                                    {\n' +
      '                                        "numeroCpf":null,\n' +
      '                                        "digitoCpf":null,\n' +
      '                                        "nome":null,\n' +
      '                                        "dataNascimento":"1966-02-21",\n' +
      '                                        "afastado":"NAO",\n' +
      '                                        "cid":null,\n' +
      '                                        "coberturas":[\n' +
      '                                            {\n' +
      '                                                "sigla":"IPA",\n' +
      '                                                "percentual":100.0,\n' +
      '                                                "garantiaReferenciada":"MAP"\n' +
      '                                            },\n' +
      '                                            {\n' +
      '                                                "sigla":"AFI",\n' +
      '                                                "valor":3000.0\n' +
      '                                            },\n' +
      '                                            {\n' +
      '                                                "sigla":"COJ",\n' +
      '                                                "percentual":80.0,\n' +
      '                                                "inclusaoIndenizacaoEspecial":"SIM",\n' +
      '                                                "percentualIndenizacaoEspecial":50\n' +
      '                                            },\n' +
      '                                            {\n' +
      '                                                "sigla":"CJP",\n' +
      '                                                "percentual":80.0,\n' +
      '                                                "inclusaoFilhos":"SIM",\n' +
      '                                                "percentualFilhos":50.0\n' +
      '                                            }\n' +
      '                                        ]\n' +
      '                                    },\n' +
      '                                    {\n' +
      '                                        "numeroCpf":null,\n' +
      '                                        "digitoCpf":null,\n' +
      '                                        "nome":null,\n' +
      '                                        "dataNascimento":"1981-06-30",\n' +
      '                                        "afastado":"SIM",\n' +
      '                                        "cid":345,\n' +
      '                                        "coberturas":[\n' +
      '                                            {\n' +
      '                                                "sigla":"IPA",\n' +
      '                                                "percentual":100.0,\n' +
      '                                                "garantiaReferenciada":"MAP"\n' +
      '                                            },\n' +
      '                                            {\n' +
      '                                                "sigla":"AFI",\n' +
      '                                                "valor":5000.0\n' +
      '                                            },\n' +
      '                                            {\n' +
      '                                                "sigla":"COJ",\n' +
      '                                                "percentual":80.0,\n' +
      '                                                "inclusaoIndenizacaoEspecial":"SIM",\n' +
      '                                                "percentualIndenizacaoEspecial":50\n' +
      '                                            },\n' +
      '                                            {\n' +
      '                                                "sigla":"CJP",\n' +
      '                                                "percentual":80.0,\n' +
      '                                                "inclusaoFilhos":"SIM",\n' +
      '                                                "percentualFilhos":50.0\n' +
      '                                            }\n' +
      '                                        ]\n' +
      '                                    }\n' +
      '                                ],\n' +
      '                                "coberturas":[\n' +
      '                                    {\n' +
      '                                        "sigla":"MAP",\n' +
      '                                        "valor":56000.0\n' +
      '                                    },\n' +
      '                                    {\n' +
      '                                        "sigla":"DMHO",\n' +
      '                                        "valor":250.0\n' +
      '                                    },\n' +
      '                                    {\n' +
      '                                        "sigla":"DIT",\n' +
      '                                        "valor":400.0,\n' +
      '                                        "quantidade":30,\n' +
      '                                        "clausulaReducaoFranquiaAcidente":"SIM"\n' +
      '                                    }\n' +
      '                                ]\n' +
      '                            }\n' +
      '                        ]\n' +
      '                    }\n' +
      '                ],\n' +
      '                "descontoComercial":1.1,\n' +
      '                "agravoComercial":1.0,\n' +
      '                "remuneracao":{\n' +
      '                    "canal":"COR",\n' +
      '                    "agentes":[\n' +
      '                        {\n' +
      '                            "papel":"COR",\n' +
      '                            "corretagem":5.0,\n' +
      '                            "susep":"C1192J",\n' +
      '                            "tipoPessoaCorsus":"J",\n' +
      '                            "susepEmissao":"C1192J",\n' +
      '                            "susepOrcamento":"C1192J",\n' +
      '                            "pessoa":{\n' +
      '                                "tipo":"JUR",\n' +
      '                                "nome":"Potencia Corretora",\n' +
      '                                "dadosPessoaJuridica":{\n' +
      '                                    "numeroCnpj":"00062999",\n' +
      '                                    "ordemCnpj":"0001",\n' +
      '                                    "digitoCnpj":"01"\n' +
      '                                }\n' +
      '                            }\n' +
      '                        },\n' +
      '                        {\n' +
      '                            "papel":"AGE",\n' +
      '                            "agenciamento":2.0,\n' +
      '                            "pessoa":{\n' +
      '                                "tipo":"FIS",\n' +
      '                                "nome":"Xuxa Meneghel",\n' +
      '                                "dadosPessoaJuridica":{\n' +
      '                                    "numeroCpf":"00062999",\n' +
      '                                    "digitoCpf":"23"\n' +
      '                                }\n' +
      '                            }\n' +
      '                        },\n' +
      '                        {\n' +
      '                            "papel":"REP",\n' +
      '                            "proLabore":10.0,\n' +
      '                            "pessoa":{\n' +
      '                                "tipo":"FIS",\n' +
      '                                "nome":"Pelé",\n' +
      '                                "dadosPessoaJuridica":{\n' +
      '                                    "numeroCpf":"00062999",\n' +
      '                                    "digitoCpf":"23"\n' +
      '                                }\n' +
      '                            }\n' +
      '                        },\n' +
      '                        {\n' +
      '                            "papel":"ASS",\n' +
      '                            "assessoria":4.0,\n' +
      '                            "pessoa":{\n' +
      '                                "tipo":"FIS",\n' +
      '                                "nome":"Ayrton Senna",\n' +
      '                                "dadosPessoaJuridica":{\n' +
      '                                    "numeroCpf":"00062999",\n' +
      '                                    "digitoCpf":"23"\n' +
      '                                }\n' +
      '                            }\n' +
      '                        }\n' +
      '                    ],\n' +
      '                    "codigoOperacaoImprimir":"SIM"\n' +
      '                }\n' +
      '            },\n' +
      '            "guiaPostal":[\n' +
      '                {\n' +
      '                    "cep":"12345-123",\n' +
      '                    "cidade":"São Paulo",\n' +
      '                    "uf":"São Paulo"\n' +
      '                }\n' +
      '            ],\n' +
      '            "licitacoes":[\n' +
      '                {\n' +
      '                    "orgaoPublico":"S",\n' +
      '                    "cnpj":"60.856.443/0001-00"\n' +
      '                }\n' +
      '            ],\n' +
      '            "serasa":[\n' +
      '                {\n' +
      '                    "cnpj":"222.222.222-22",\n' +
      '                    "cnae":"22525-12",\n' +
      '                    "cep":"12345-123"\n' +
      '                }\n' +
      '            ],\n' +
      '            "indiceMonetario":[\n' +
      '                {\n' +
      '                    "USS":2.40000\n' +
      '                },\n' +
      '                {\n' +
      '                    "EUR":3.40000\n' +
      '                }\n' +
      '            ],\n' +
      '            "retornoValidacaoProduto":{\n' +
      '                "codigoProduto":1,\n' +
      '                "versaoProduto":1,\n' +
      '                "descontoComercial":40.0,\n' +
      '                "descontoTecnico":40.0,\n' +
      '                "agravoComercial":10,\n' +
      '                "agravoTecnico":10,\n' +
      '                "premiosMinimos":[\n' +
      '                    {\n' +
      '                        "quantidadeParcelas":1,\n' +
      '                        "formaPagamento":"ADC",\n' +
      '                        "premioMinimo":50.0\n' +
      '                    }\n' +
      '                ],\n' +
      '                "moedasExtrangeiras":[\n' +
      '                    "USS",\n' +
      '                    "EUR"\n' +
      '                ]\n' +
      '            },\n' +
      '            "retornoAceitacao":{\n' +
      '                "avisos":[\n' +
      '                    {\n' +
      '                        "codigo":10080,\n' +
      '                        "decricao":"Verifique a naturaza dos afastamentos"\n' +
      '                    }\n' +
      '                ],\n' +
      '                "analises":[\n' +
      '                    {\n' +
      '                        "codigo":10085,\n' +
      '                        "decricao":"Quantidade de afastados necessita análise"\n' +
      '                    }\n' +
      '                ],\n' +
      '                "recusas":[\n' +
      '                    {\n' +
      '                        "codigo":10090,\n' +
      '                        "decricao":"Idade máxima excedida"\n' +
      '                    }\n' +
      '                ]\n' +
      '            },\n' +
      '            "oferta":{\n' +
      '                "permiteTransmissao":"SIM",\n' +
      '                "parcelamentos":[\n' +
      '                    {\n' +
      '                        "valorDemaisParcelas":0,\n' +
      '                        "valor1aParcela":313.01,\n' +
      '                        "qtdParcelas":1,\n' +
      '                        "juros":0,\n' +
      '                        "iof":0.38,\n' +
      '                        "encargos":0,\n' +
      '                        "descricao":"1X - Cartao de Credito demais bandeiras",\n' +
      '                        "custoapolice":0,\n' +
      '                        "codigo":62\n' +
      '                    },\n' +
      '                    {\n' +
      '                        "valorDemaisParcelas":0,\n' +
      '                        "valor1aParcela":297.37,\n' +
      '                        "qtdParcelas":1,\n' +
      '                        "juros":0,\n' +
      '                        "iof":0.38,\n' +
      '                        "encargos":0,\n' +
      '                        "descricao":"1X - Cartao Porto Seguro",\n' +
      '                        "custoapolice":0,\n' +
      '                        "codigo":97\n' +
      '                    }\n' +
      '                ],\n' +
      '                "origem":"PPW",\n' +
      '                "numeroPortal":988444,\n' +
      '                "numero":647658,\n' +
      '                "calculo":{\n' +
      '                    "preficicacao":{\n' +
      '                        "juros":0.0,\n' +
      '                        "iof":0.0038,\n' +
      '                        "encargos":0.0,\n' +
      '                        "custoApolice":0.0,\n' +
      '                        "premio":{\n' +
      '                            "puro":8.0834,\n' +
      '                            "puroDesconto":7.8643,\n' +
      '                            "puroInterno":7.97435,\n' +
      '                            "puroResseguro":1.97434,\n' +
      '                            "comercial":3.09834,\n' +
      '                            "comercialDesconto":2.75435\n' +
      '                        },\n' +
      '                        "taxa":{\n' +
      '                            "pura":0.87443,\n' +
      '                            "mensal":0.74435,\n' +
      '                            "anual":0.12344,\n' +
      '                            "puroInterno":0.97435,\n' +
      '                            "puroResseguro":0.97434,\n' +
      '                            "comercial":0.86434\n' +
      '                        },\n' +
      '                        "coberturas":[\n' +
      '                            {\n' +
      '                                "sigla":"MAP",\n' +
      '                                "capital":737456.95,\n' +
      '                                "premio":{\n' +
      '                                    "puro":8.0834,\n' +
      '                                    "puroInterno":0.97435,\n' +
      '                                    "puroResseguro":0.97434,\n' +
      '                                    "comercial":3.09834\n' +
      '                                },\n' +
      '                                "taxa":{\n' +
      '                                    "pura":0.87443,\n' +
      '                                    "puroInterno":0.97435,\n' +
      '                                    "puroResseguro":0.97434,\n' +
      '                                    "comercial":0.86434\n' +
      '                                }\n' +
      '                            }\n' +
      '                        ],\n' +
      '                        "segurados":[\n' +
      '                            {\n' +
      '                                "premio":{\n' +
      '                                    "puro":8.0834,\n' +
      '                                    "comercial":3.09834\n' +
      '                                },\n' +
      '                                "taxa":{\n' +
      '                                    "pura":0.87443,\n' +
      '                                    "comercial":0.86434\n' +
      '                                },\n' +
      '                                "coberturas":[\n' +
      '                                    {\n' +
      '                                        "sigla":"MAP",\n' +
      '                                        "capital":737456.95,\n' +
      '                                        "premio":{\n' +
      '                                            "puro":8.0834,\n' +
      '                                            "comercial":3.09834\n' +
      '                                        },\n' +
      '                                        "taxa":{\n' +
      '                                            "pura":0.87443,\n' +
      '                                            "comercial":0.86434\n' +
      '                                        }\n' +
      '                                    }\n' +
      '                                ],\n' +
      '                                "grupos":[\n' +
      '                                    {\n' +
      '                                        "premio":{\n' +
      '                                            "puro":8.0834,\n' +
      '                                            "comercial":3.09834\n' +
      '                                        },\n' +
      '                                        "taxa":{\n' +
      '                                            "pura":0.87443,\n' +
      '                                            "comercial":0.86434\n' +
      '                                        },\n' +
      '                                        "coberturas":[\n' +
      '                                            {\n' +
      '                                                "sigla":"MAP",\n' +
      '                                                "capital":737456.95,\n' +
      '                                                "premio":{\n' +
      '                                                    "puro":8.0834,\n' +
      '                                                    "comercial":3.09834\n' +
      '                                                },\n' +
      '                                                "taxa":{\n' +
      '                                                    "pura":0.87443,\n' +
      '                                                    "comercial":0.86434\n' +
      '                                                }\n' +
      '                                            }\n' +
      '                                        ],\n' +
      '                                        "vidas":[\n' +
      '                                            {\n' +
      '                                                "premio":{\n' +
      '                                                    "puro":8.0834,\n' +
      '                                                    "comercial":3.09834\n' +
      '                                                },\n' +
      '                                                "taxa":{\n' +
      '                                                    "pura":0.87443,\n' +
      '                                                    "comercial":0.86434\n' +
      '                                                },\n' +
      '                                                "coberturas":[\n' +
      '                                                    {\n' +
      '                                                        "sigla":"MAP",\n' +
      '                                                        "capital":737456.95,\n' +
      '                                                        "premio":{\n' +
      '                                                            "puro":8.0834,\n' +
      '                                                            "comercial":3.09834\n' +
      '                                                        },\n' +
      '                                                        "taxa":{\n' +
      '                                                            "pura":0.87443,\n' +
      '                                                            "comercial":0.86434\n' +
      '                                                        }\n' +
      '                                                    }\n' +
      '                                                ]\n' +
      '                                            }\n' +
      '                                        ]\n' +
      '                                    }\n' +
      '                                ]\n' +
      '                            }\n' +
      '                        ]\n' +
      '                    },\n' +
      '                    "analiseAtuarial":{\n' +
      '                        "estatistica":{\n' +
      '                            "faixaEtaria":[\n' +
      '                                {\n' +
      '                                    "tipo":"FXA",\n' +
      '                                    "inicioFaixa":18,\n' +
      '                                    "finalFaixa":40,\n' +
      '                                    "quantidade":7,\n' +
      '                                    "percentual":100.0,\n' +
      '                                    "capital":400000.0,\n' +
      '                                    "mediaCapital":400000.0\n' +
      '                                },\n' +
      '                                {\n' +
      '                                    "tipo":"FXA",\n' +
      '                                    "inicioFaixa":40,\n' +
      '                                    "finalFaixa":60,\n' +
      '                                    "quantidade":8,\n' +
      '                                    "percentual":100.0,\n' +
      '                                    "capital":400000.0,\n' +
      '                                    "mediaCapital":400000.0\n' +
      '                                },\n' +
      '                                {\n' +
      '                                    "tipo":"TOT",\n' +
      '                                    "quantidade":15,\n' +
      '                                    "percentual":100.0,\n' +
      '                                    "capital":400000.0,\n' +
      '                                    "mediaCapital":400000.0\n' +
      '                                }\n' +
      '                            ],\n' +
      '                            "faixaCapital":[\n' +
      '                                {\n' +
      '                                    "tipo":"FXA",\n' +
      '                                    "finalFaixa":400000.0,\n' +
      '                                    "quantidade":13,\n' +
      '                                    "percentual":100.0,\n' +
      '                                    "capital":5200000000.0,\n' +
      '                                    "mediaCapital":400000.0\n' +
      '                                },\n' +
      '                                {\n' +
      '                                    "tipo":"FXA",\n' +
      '                                    "inicioFaixa":400000.0,\n' +
      '                                    "quantidade":1,\n' +
      '                                    "percentual":100.0,\n' +
      '                                    "capital":200000000.0,\n' +
      '                                    "mediaCapital":2000000.0\n' +
      '                                },\n' +
      '                                {\n' +
      '                                    "tipo":"TOT",\n' +
      '                                    "quantidade":13,\n' +
      '                                    "percentual":100.0,\n' +
      '                                    "capital":5200000000.0,\n' +
      '                                    "mediaCapital":400000.0\n' +
      '                                }\n' +
      '                            ],\n' +
      '                            "status":[\n' +
      '                                {\n' +
      '                                    "stauts":"Ativo(s)",\n' +
      '                                    "quantidade":13\n' +
      '                                },\n' +
      '                                {\n' +
      '                                    "stauts":"Afastado(s)",\n' +
      '                                    "quantidade":1\n' +
      '                                },\n' +
      '                                {\n' +
      '                                    "stauts":"Aposentado(s)",\n' +
      '                                    "quantidade":0\n' +
      '                                }\n' +
      '                            ]\n' +
      '                        },\n' +
      '                        "analitica":{\n' +
      '                            "quantidadeVidas":23,\n' +
      '                            "publicoMasculino":53.09,\n' +
      '                            "publicoFeminino":43.05,\n' +
      '                            "capitalMedio":43205444.99,\n' +
      '                            "idadeMediaAtuarial":35.94,\n' +
      '                            "idadeMediaPonderada":24.054,\n' +
      '                            "idadeMediaPonderadaPorIS":54.95,\n' +
      '                            "idadeMediaAritmetica":43.54,\n' +
      '                            "taxaModelagem":0.89743,\n' +
      '                            "percentualDescontoModelagem":-95.9854,\n' +
      '                            "expectativaSinistrosAnual":0.007543,\n' +
      '                            "capitalPonderadoPorExpectativaSinistro":10249.07\n' +
      '                        },\n' +
      '                        "segurados":[\n' +
      '                            {\n' +
      '                                "numeroSegurado":1,\n' +
      '                                "estatistica":{\n' +
      '                                    "faixaEtaria":[\n' +
      '                                        {\n' +
      '                                            "tipo":"FXA",\n' +
      '                                            "inicioFaixa":18,\n' +
      '                                            "finalFaixa":40,\n' +
      '                                            "quantidade":7,\n' +
      '                                            "percentual":100.0,\n' +
      '                                            "capital":400000.0,\n' +
      '                                            "mediaCapital":400000.0\n' +
      '                                        },\n' +
      '                                        {\n' +
      '                                            "tipo":"FXA",\n' +
      '                                            "inicioFaixa":40,\n' +
      '                                            "finalFaixa":60,\n' +
      '                                            "quantidade":8,\n' +
      '                                            "percentual":100.0,\n' +
      '                                            "capital":400000.0,\n' +
      '                                            "mediaCapital":400000.0\n' +
      '                                        },\n' +
      '                                        {\n' +
      '                                            "tipo":"TOT",\n' +
      '                                            "quantidade":15,\n' +
      '                                            "percentual":100.0,\n' +
      '                                            "capital":400000.0,\n' +
      '                                            "mediaCapital":400000.0\n' +
      '                                        }\n' +
      '                                    ],\n' +
      '                                    "faixaCapital":[\n' +
      '                                        {\n' +
      '                                            "tipo":"FXA",\n' +
      '                                            "finalFaixa":400000.0,\n' +
      '                                            "quantidade":13,\n' +
      '                                            "percentual":100.0,\n' +
      '                                            "capital":5200000000.0,\n' +
      '                                            "mediaCapital":400000.0\n' +
      '                                        },\n' +
      '                                        {\n' +
      '                                            "tipo":"FXA",\n' +
      '                                            "inicioFaixa":400000.0,\n' +
      '                                            "quantidade":1,\n' +
      '                                            "percentual":100.0,\n' +
      '                                            "capital":200000000.0,\n' +
      '                                            "mediaCapital":2000000.0\n' +
      '                                        },\n' +
      '                                        {\n' +
      '                                            "tipo":"TOT",\n' +
      '                                            "quantidade":13,\n' +
      '                                            "percentual":100.0,\n' +
      '                                            "capital":5200000000.0,\n' +
      '                                            "mediaCapital":400000.0\n' +
      '                                        }\n' +
      '                                    ],\n' +
      '                                    "status":[\n' +
      '                                        {\n' +
      '                                            "stauts":"Ativo(s)",\n' +
      '                                            "quantidade":13\n' +
      '                                        },\n' +
      '                                        {\n' +
      '                                            "stauts":"Afastado(s)",\n' +
      '                                            "quantidade":1\n' +
      '                                        },\n' +
      '                                        {\n' +
      '                                            "stauts":"Aposentado(s)",\n' +
      '                                            "quantidade":0\n' +
      '                                        }\n' +
      '                                    ]\n' +
      '                                },\n' +
      '                                "analitica":{\n' +
      '                                    "quantidadeVidas":23,\n' +
      '                                    "publicoMasculino":53.09,\n' +
      '                                    "publicoFeminino":43.05,\n' +
      '                                    "capitalMedio":43205444.99,\n' +
      '                                    "idadeMediaAtuarial":35.94,\n' +
      '                                    "idadeMediaPonderada":24.054,\n' +
      '                                    "idadeMediaPonderadaPorIS":54.95,\n' +
      '                                    "idadeMediaAritmetica":43.54,\n' +
      '                                    "taxaModelagem":0.89743,\n' +
      '                                    "percentualDescontoModelagem":-95.9854,\n' +
      '                                    "expectativaSinistrosAnual":0.007543,\n' +
      '                                    "capitalPonderadoPorExpectativaSinistro":10249.07\n' +
      '                                },\n' +
      '                                "grupos":[\n' +
      '                                    {\n' +
      '                                        "numeroGrupo":1,\n' +
      '                                        "estatistica":{\n' +
      '                                            "faixaEtaria":[\n' +
      '                                                {\n' +
      '                                                    "tipo":"FXA",\n' +
      '                                                    "inicioFaixa":18,\n' +
      '                                                    "finalFaixa":40,\n' +
      '                                                    "quantidade":7,\n' +
      '                                                    "percentual":100.0,\n' +
      '                                                    "capital":400000.0,\n' +
      '                                                    "mediaCapital":400000.0\n' +
      '                                                },\n' +
      '                                                {\n' +
      '                                                    "tipo":"FXA",\n' +
      '                                                    "inicioFaixa":40,\n' +
      '                                                    "finalFaixa":60,\n' +
      '                                                    "quantidade":8,\n' +
      '                                                    "percentual":100.0,\n' +
      '                                                    "capital":400000.0,\n' +
      '                                                    "mediaCapital":400000.0\n' +
      '                                                },\n' +
      '                                                {\n' +
      '                                                    "tipo":"TOT",\n' +
      '                                                    "quantidade":15,\n' +
      '                                                    "percentual":100.0,\n' +
      '                                                    "capital":400000.0,\n' +
      '                                                    "mediaCapital":400000.0\n' +
      '                                                }\n' +
      '                                            ],\n' +
      '                                            "faixaCapital":[\n' +
      '                                                {\n' +
      '                                                    "tipo":"FXA",\n' +
      '                                                    "finalFaixa":400000.0,\n' +
      '                                                    "quantidade":13,\n' +
      '                                                    "percentual":100.0,\n' +
      '                                                    "capital":5200000000.0,\n' +
      '                                                    "mediaCapital":400000.0\n' +
      '                                                },\n' +
      '                                                {\n' +
      '                                                    "tipo":"FXA",\n' +
      '                                                    "inicioFaixa":400000.0,\n' +
      '                                                    "quantidade":1,\n' +
      '                                                    "percentual":100.0,\n' +
      '                                                    "capital":200000000.0,\n' +
      '                                                    "mediaCapital":2000000.0\n' +
      '                                                },\n' +
      '                                                {\n' +
      '                                                    "tipo":"TOT",\n' +
      '                                                    "quantidade":13,\n' +
      '                                                    "percentual":100.0,\n' +
      '                                                    "capital":5200000000.0,\n' +
      '                                                    "mediaCapital":400000.0\n' +
      '                                                }\n' +
      '                                            ],\n' +
      '                                            "status":[\n' +
      '                                                {\n' +
      '                                                    "stauts":"Ativo(s)",\n' +
      '                                                    "quantidade":13\n' +
      '                                                },\n' +
      '                                                {\n' +
      '                                                    "stauts":"Afastado(s)",\n' +
      '                                                    "quantidade":1\n' +
      '                                                },\n' +
      '                                                {\n' +
      '                                                    "stauts":"Aposentado(s)",\n' +
      '                                                    "quantidade":0\n' +
      '                                                }\n' +
      '                                            ]\n' +
      '                                        },\n' +
      '                                        "analitica":{\n' +
      '                                            "quantidadeVidas":23,\n' +
      '                                            "publicoMasculino":53.09,\n' +
      '                                            "publicoFeminino":43.05,\n' +
      '                                            "capitalMedio":43205444.99,\n' +
      '                                            "idadeMediaAtuarial":35.94,\n' +
      '                                            "idadeMediaPonderada":24.054,\n' +
      '                                            "idadeMediaPonderadaPorIS":54.95,\n' +
      '                                            "idadeMediaAritmetica":43.54,\n' +
      '                                            "taxaModelagem":0.89743,\n' +
      '                                            "percentualDescontoModelagem":-95.9854,\n' +
      '                                            "expectativaSinistrosAnual":0.007543,\n' +
      '                                            "capitalPonderadoPorExpectativaSinistro":10249.07\n' +
      '                                        }\n' +
      '                                    }\n' +
      '                                ]\n' +
      '                            }\n' +
      '                        ]\n' +
      '                    }\n' +
      '                }\n' +
      '            },\n' +
      '            "mensagem":"Cálculo realizado com sucesso",\n' +
      '            "erro":0\n' +
      '        }\n' +
      '    ]\n' +
      '}';

    let orcamento = JSON.parse(jsonString);
    let calculo = orcamento.orcamentos[0].oferta.calculo;
    component.set('v.calculo',calculo);

  },


  buildLstCoberturas:function(component,event,helper,lcoberturas){

    function buildElements(elementEntry,indexEntry,arrayEntry,tableObject, prefix) {
      let jumpNext = false;
      if(prefix != '') prefix = prefix + ' ';

        elementEntry.forEach((element,index,array) => {

        if(!jumpNext && !(index % 2)){
          if(typeof array[index+1] != "object"){

            let lstColumns = tableObject.columns;
            let lstDados = tableObject.dados;
            if(element == 'sigla') {
              lstColumns.push('');
            }else{
              lstColumns.push(prefix + element);
            }
            lstDados.push(array[index+1]);
            jumpNext = true;
          }else{
            let entriesObject = Object.entries(array[index+1]);
            entriesObject.forEach((elementEntry,indexEntry,arrayEntry) => {
              tableObject = buildElements(elementEntry,indexEntry,arrayEntry,tableObject,element);
            });
          }
        }else{
          jumpNext = false;
        }
      });

      return tableObject;
    }

    let lstCoberturas = [];
    let lstCoberturasEntriesByTable = [];

    lcoberturas.forEach((element, index, array) => {
      lstCoberturasEntriesByTable.push(Object.entries(element));
    });

    lstCoberturasEntriesByTable.forEach((element,index,array) => {
      let tableObject = this.tableObject(component,event,helper,[],[]);

      element.forEach((elementEntry,indexEntry,arrayEntry) => {
        tableObject = buildElements(elementEntry,indexEntry,arrayEntry,tableObject,'');
      });
      lstCoberturas.push(tableObject);
    });

    component.set('v.lstCoberturas',lstCoberturas);
  },

  tableObject:function (component, event, helper,lstColumns,lstDados) {
    return {
      columns:lstColumns,
      dados:lstDados
    }

  }
})