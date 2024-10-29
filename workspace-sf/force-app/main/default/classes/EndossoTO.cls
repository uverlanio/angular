/**
 * PLV-4484
 **/
public class EndossoTO {

    public Request request {get;set;}

    public class OrcamentoTO {

        public String susepOrcamento {get;set;} //PLV-4587 FIX 2 INICIO/FIM
        public String tipoSeguro {get;set;}
        public String numeroOrcamento {get;set;}
        //public String motivoCancelamento {get;set;}
        public String numeroOferta {get;set;}
        public String orcnum {get;set;}
        public String dataCalculo {get;set;}
        public String codigoProdutoVida {get;set;}
        //public String codigoPrecProd {get;set;} // PLV-5382 INICIO / FIM FIX01
        public String idProdutoSf {get;set;} // PLV-5331 INICIO / FIM
        public String meioComercializacao {get;set;}
        public Decimal ordemPortal {get;set;}        
        public String canalDistribuicao {get;set;}
        // PLV-4481
        //public String susep {get;set;}

        public String numeroPortal {get;set;}
        public String tipoVigencia {get;set;}
        public Date vigenciaInicial {get;set;}
        public Date vigenciaFinal {get;set;}
        public Integer qtdDiasVigencia { get;set; } //PLV-5833 INICIO/FIM
        public Integer entradaNegocio {get;set;}
        public String segmento {get;set;}
        public ViagemTO viagem{get;set;} //PLV-4587-INICIO/FIM
        public String dataEndosso {get;set;}//PLV-4587-INICIO/FIM
        public Date closeDate {get;set;} // PLV-4574
        public Boolean consultivo {get;set;} // PLV-4574

        public Integer cicloVacinal { get; set; } // PLV-5150 - INICIO/FIM


        public ContratoOriginalTO contratoOriginal {get;set;}
        public List<ContratanteTO> contratantes {get;set;}
        public List<RemuneracaoTO> remuneracoes {get;set;}



    }
    //PLV-4587-INICIO
    public class ViagemTO{
        public String tipoViagem{get;set;}
        public Boolean praticaEsportesAventura{get;set;}
        public Boolean utilizaraMotocicleta{get;set;}
        public Integer passageirosNaoIdosos{get;set;}
        public Integer passageirosIdosos{get;set;}
        public List<DestinoTo> destinos{get;set;}

    }
    public class DestinoTo{
        public String codigo{get;set;}
        public String pais{get;set;}
    }
    //PLV-4587-FIM
    public class ContratoOriginalTO {

        public String empresa {get;set;}
        public String sucursal {get;set;}
        public String ramo {get;set;}
        public String apolice {get;set;}
        public String endosso {get;set;}
        // PLV-4481
        public String tipoContrato { get; set; }

        public Decimal percentual {get;set;} //PLV-5784 INICIO - FIM

        // PLV-4655 INICIO
        public Date vigenciaInicial {get;set;}
        public Date vigenciaFinal {get;set;}
        public string dataEndosso {get;set;}
        public Integer qtdDiasVigencia { get;set; } //PLV-5833 INICIO/FIM
        //public Double premioPago {get;set;}
        // PLV-4655 FIM
        /*
        public String vigenciaFinal {get;set;}
        public String codigoProdutoVida {get;set;}
        public Double premioTotal {get;set;}
        public String vigenciaInicial {get;set;}
        public Double premioPago {get;set;}

        public PrecificacaoTO precificacao {get;set;}
        */
        // PLV-4655
        public List<ContratanteTO> contratantes {get;set;}
        public Double premioPago {get;set;}

    }
    /*
    public class PrecificacaoTO {

        public Double encargos {get;set;}
        public Double iof {get;set;}
        public Double juros {get;set;}
        public Double custoApolice {get;set;}

        public TaxaTO taxa {get;set;}
        public PremioTO premio {get;set;}
        public List<CoberturaTO> coberturas {get;set;}
        public List<ContratanteTO> contratantes {get;set;}

    }

    */

    public class PremioTO {

        public Double comercial {get;set;}
        public Double total {get;set;}
        public Double puro {get;set;}
        public Decimal minimo {get; set;}


    }


    public class TaxaTO {

        public Double pura {get;set;}
        public Double comercial {get;set;}
        public Double total {get;set;}

    }

    public class CoberturaTO{
        
        public String sigla {get;set;}
        public String moeda {get;set;} // PLV-4574
        public Double cotacaoMoeda {get;set;} // PLV-4574
        public Double valor {get;set;}
        // PLV-4655
        public Decimal quantidade {get;set;}
        public String cobrado {get;set;}

        //public TaxaTO taxa {get;set;}
        //public PremioTO premio {get;set;} 
        // PLV-4655
        public String franquia { get; set; }
        
    }

    public class PessoaTO{
        
        public String tipo { get; set; }
        public String nome { get; set; }
        public String nomeSocial {get;set;} // LECVPV-188 INICIO/FIM
        public String rendaMensal { get; set; } // PLV-4574
        public DadosPessoaFisicaTO dadosPessoaFisica { get; set; }
        //public DadosPessoaJuridicaTO dadosPessoaJuridica {get;set;}

    }

    public class DadosPessoaFisicaTO
    {
        public String profissao { get; set; }
        public String sexo { get; set; }
        public String dataNascimento { get; set; }
        public Boolean fumante { get; set; }
        public String regimeTrabalho  { get; set; }
        //public String CicloVacinal { get; set; } // PLV-5150 ("C" maiúsculo por exigência da porto) PLV-5150 - FIX01 - INICIO/FIM
        //public String cpf { get; set;}
        public String grupoProfissao {get; set;}
        public String numeroCpf {get; set;}
        public String digitoCpf {get; set;}
        public String renda { get; set; } //PLV-5134 INICIO/FIM


    }
    public class DadosPessoaJuridicaTO{
        public String numeroCnpj {get;set;}
        public String ordemCnpj {get;set;}
        public String digitoCnpj {get;set;}
    }

    public class ContratanteTO{
        
        public String tipo {get;set;}
        public Integer numero {get;set;}
        //public TaxaTO taxa {get;set;}
        //public PremioTO premio {get;set;} //PLV-5169
        public Boolean manterPlanoParcelamento {get;set;} //PLV-5066 INICIO/FIM

        public List<GrupoTO> grupos {get;set;}

    }

    public class GrupoTO {
        public Integer tarifa {get;set;} // PLV-4574
        public String tipoCalculo {get;set;} // PLV-4574
        public Integer numero {get;set;}
        public String nome {get;set;}
        public Integer qtdeVidas {get;set;}

        public List<SeguradoTO> segurados {get;set;}

    }
    public class SeguradoTO {
        public Integer numero {get;set;}
        public List<CoberturaTO> coberturas {get;set;}
        public PessoaTO pessoa { get; set; }
    }
    
    public class RemuneracaoTO {
        public Double percentual {get;set;}
        public String tipoRemuneracao {get;set;}
        public Double bonusCampanha {get;set;} //II-167 INICIO-FIM
    }

    public class Request {
        public OrcamentoTO orcamento {get;set;}
    }

    public class Response {

        public String numeroOrcamento { get; set; }
        public String tipoSeguro { get; set; }
        public String status { get; set; }

    }

    // PLV-4706 inicio
    public class Propostas {
        List<OrcamentoTO> propostas = new List<OrcamentoTO>();
    }
    // PLV-4706 fim

    
}