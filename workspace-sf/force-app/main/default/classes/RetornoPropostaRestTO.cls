/**
* Retorno Proposta Rest TO
* @author Eric Tunú @ 21/08/2018
*
**/
public class RetornoPropostaRestTO 
{
	public ValidacaopropostaTO Validacaoproposta { get; set; }
	// PLV-2430-29 INICIO
	public ValidacaopropostaTO data { get;set; }
	// PLV-2430-29 FIM


	public class ValidacaopropostaTO 
	{
		public List<DevolutivasTO> devolutivas { get; set; }
		public PropostaTO proposta { get; set; }
		//PLV-3763 - INICIO - Converter serviço de Devolutivas da Proposta em lista
		public List<RetornoPropostaRestTO> resultados { get; set; }
		//PLV-3763 - FIM - Converter serviço de Devolutivas da Proposta em lista
		// PLV-3285 INICIO 
		// public propostaTO proposta { get; set; }
		// public List<DevolutivasTO> devolutivas { get; set; }
		// public retornoAceitacaoTO retornoAceitacao { get;set; }
		// PLV-3285 FIM
        

	}
	//PLV-3763 - INICIO - Converter serviço de Devolutivas da Proposta em lista
	public List<DevolutivasTO> devolutivas { get; set; }
	public PropostaTO proposta { get; set; }
	//PLV-3763 - FIM - Converter serviço de Devolutivas da Proposta em lista

	public class DevolutivasTO 
	{
		public Integer codigo { get; set; }
		public String  origem { get; set; }
		public Integer tipoRegistro { get; set; }
		public Integer numeroCampo { get; set; }
		public String  descricao { get; set; }
		public String  link { get; set; } // AV-620 INICIO/FIM
		
		
	}
    
	public class PropostaTO 
	{
		public Integer numeroOrcamento { get; set; }
		public String numero { get; set; }  // TKCL-246 - INICIO/FIM
		public Long empresa { get; set; }
		public Long sucursal { get; set; }
		public Long qtdDiasVigencia { get; set; }
		public String status { get; set; }
		public String meioComercializacao { get; set; }
		public Long ramo { get; set; }
		public String dataCalculo { get; set; }
		public String tipoSeguro { get; set; }
		public Long origem { get; set; }
		public String vigenciaInicial { get; set; }
		public String vigenciaFinal { get; set; }
		public Long apolice { get; set; }
		public String tipoAdesao { get; set; }
		public String dataTransmissao { get; set; }
		public String dataEmissao { get; set; }
		public Decimal limiteProfissao { get; set; } //PLV-4790 FIX 5 INICIO/FIM
		public String validadePagamento { get; set; } // VIAG-141
		public String  senha { get; set; } // MGRC-505 INICIO-FIM
		public String  distributionPublicUrl { get; set; } // MGRC-505 INICIO-FIM
		public String  voucherPdfDownloadUrl    {get; set;} // MGRC-624 INICIO-FIM
	 
	   
		//PLV-3285 - INICIO - 
		public String dataProtocolo { get; set; }
		public Integer ramoSeguro { get; set; }
		public List<contratanteTO> contratantes { get; set; }
		public List<arquivoTO> arquivos { get; set; } // PLV-3285 
		public Integer indice { get; set; }     //PLV-3285 - 
		//PLV-3285 - FIM - 

		//PLV_3196 - INICIO - Alteração do Serviço "Gravar Proposta" para retornar Ramo e Modalidade da Proposta
		public String modalidade {get; set;}
		//PLV_3196 - FIM - Alteração do Serviço "Gravar Proposta" para retornar Ramo e Modalidade da Proposta
		//PLV-3285 - INICIO - MVP A Transmissão da proposta
		public String canalDistribuicao { get; set; }
		public Integer codigoEmpresa {get; set;}
		//PLV-3285 - FIM - MVP A Transmissão da proposta	
	}
	
	// PLV-3285 INICIO
	public class ContratanteTO {
		public String numero { get; set; }
		public dadosPagamentoTO dadosPagamento { get; set; }
	}	
	public class DadosPagamentoTO {
		public Integer codigoFormaPagamento { get; set; }
		public Integer quantidadeParcelas { get; set; }
		public String premioTotal { get; set; }
		// TKCL 473 - INICIO
		public Boolean recorrencia { get; set; }
		public String valorPrimeiraParcela { get; set; }
		public String valorDemaisParcelas { get; set; }
		// TKCL 473 - FIM
	}	
	//PLV-3285 - FIM - 
	
	// PLV-3285 INICIO
	public class RetornoAceitacaoTO {
		public List<avisoTO> avisos { get; set; }
	}	
	public class AvisoTO {
		public Integer codigo { get; set; }
		public String descricao { get; set; }
		public String area { get; set; }
		public String procedimento { get; set; }
		public List<mensagenTO> mensagens { get; set; }
	}
	public class MensagenTO {
        public String interna { get; set; }
        public String cliente { get; set; }
        public String representante { get; set; }
	}
	public class ArquivoTO {
        public String nome { get; set; }
        public String descricao { get; set; }
        public String link { get; set; }
        public Integer tamanhoBytes { get; set; }
	}

	// PLV-3285 retorno metadata
	public class MetadataTO {
        public String nome { get; set; }
	}

	
	// PLV-3285 FIM
}