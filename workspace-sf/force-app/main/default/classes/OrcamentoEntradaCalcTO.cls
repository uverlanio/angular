// RVI-202 - INICIO
public class OrcamentoEntradaCalcTO {

        public Orcamento orcamento { get; set; } 
        
        public consultivoTO consultivo;

        public class Orcamento {
            public String tipoVigencia { get; set; } 
            public String tipoSeguro { get; set; } 
            public String vigenciaFinal { get; set; } 
            public Integer qtdDiasVigencia { get; set; } 
            public Boolean customizavel { get; set; } 
            public String canalDistribuicao { get; set; } 
            public viagemTO viagem { get; set; } 
            public Boolean varConsultivo { get; set; } 
            public String idProdutoSf { get; set; } 
            public Integer ramoSeguro { get; set; } 
            public Integer ordemPortal { get; set; } 
            public String rotulo { get; set; } 
            public String susepOrcamento { get; set; } 
            public List<Remuneracoes> remuneracoes { get; set; } 
            public String dataCalculo { get; set; } 
            public Integer numeroPortal { get; set; } 
            public String codigoProdutoVida { get; set; } 
            public List<Contratantes> contratantes { get; set; } 
            public String meioComercializacao { get; set; } 
            public String segmento { get; set; } 
            public Boolean gerarDocumento { get; set; } 
            public String vigenciaInicial { get; set; }
        }

        class viagemTO {
        }

        public class Remuneracoes {
            public Integer percentual { get; set; } 
            public String tipoRemuneracao { get; set; } 
        }

        public class Contratantes {
            public String tipo { get; set; } 
            public Integer numero { get; set; } 
            public List<Grupos> grupos { get; set; } 
        }

        public class Grupos {
            public Integer numero { get; set; } 
            public List<Segurados> segurados { get; set; } 
            public String nome { get; set; } 
            public Integer qtdeVidas { get; set; } 
            public List<Coberturas> coberturas { get; set; } 
        }

        public class Segurados {
            public Pessoa pessoa { get; set; } 
            public Integer numero { get; set; } 
            public List<Coberturas> coberturas { get; set; } 
        }

        public class Pessoa {
            public String tipo { get; set; } 
            public List<Enderecos> enderecos { get; set; } 
            public String nome { get; set; } 
            public DadosPessoaFisica dadosPessoaFisica { get; set; } 
            public String email { get; set; } 
        }

        public class Enderecos {
            public String uf { get; set; } 
            public String cidade { get; set; } 
            public String complemento { get; set; } 
            public String logradouro { get; set; } 
            public String bairro { get; set; } 
            public String complementoCep { get; set; } 
            public String paisResidencia { get; set; } 
            public String tipoEndereco { get; set; } 
            public String numeroLogradouro { get; set; } 
            public String cep { get; set; } 
        }

        public class DadosPessoaFisica {
            public String grupoProfissao { get; set; } 
            public String cicloVacinal { get; set; } 
            public String profissao { get; set; } 
            public Boolean temDependentes { get; set; } 
            public String tipoContrato { get; set; } 
            public String tempoGarantiaRenda { get; set; } 
            public String dataNascimento { get; set; } 
            public String sexo { get; set; } 
            public Boolean fumante { get; set; } 
            public String regimeTrabalho { get; set; } 
            public String renda { get; set; } 
        }
        
        public class Coberturas {
            public String caracteristica { get; set; } 
            public String limitemaximo { get; set; } 
            public String limiteminimo { get; set; } 
            public String moeda { get; set; } 
            public String sigla { get; set; } 
            public String valor { get; set; } 
            public String franquia { get; set; } 
            public String caracteristicaespecialvalor { get; set; } 
            public String caracteristicaespecialtipo { get; set; } 

        }

        class consultivoTO {
	    }

	    public static OrcamentoEntradaCalcTO parse(String json) {
		    return (OrcamentoEntradaCalcTO) System.JSON.deserialize(json, OrcamentoEntradaCalcTO.class);
	    }
}
// RVI-202 - FIM