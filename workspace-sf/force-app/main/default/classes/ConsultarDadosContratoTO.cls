public with sharing class ConsultarDadosContratoTO
{
	public class DadosContratoTO
	{
		public Integer statusChamada { get; set; }
		public String descricaoErro { get; set; }
		public PropostaTO proposta { get; set; }
		public List<ApoliceTO> apolice  { get; set; }	

	}

	public class MetaTO 
	{
		public String dataExecucao { get; set; }
		public String servico { get; set; }
		public Integer statusHttp { get; set; }
		public String mensagem { get; set; }
	}

	public class PropostaTO 
	{
		public String empresa { get; set; }
		public String origemProposta  { get; set; }                          
		public String numeroProposta   { get; set; }                         
		public String codigoOperacaoComissoes  { get; set; }          
		public Date dataEmissaoDocumento  { get; set; }                
		public String codigoRamoSeguro  { get; set; }                 
		public String codigoSubramo { get; set; }
		public String modalidadeSeguro  { get; set; }                     
		public String sucursalEmissaoSeguro  { get; set; }            
		public String numeroApolice { get; set; }
		public String numeroEndosso { get; set; }
		public Date dataInicioVigencia  { get; set; }               
		public Date dataFinalVigencia    { get; set; }             
		public String codigoFormaPagamento  { get; set; }             
		public Decimal premioLiquido { get; set; }
		public Decimal valorAdicionalFracionamento { get; set; }       
		public Decimal premioBruto { get; set; }
		public Integer quantidadeParcelas  { get; set; }                   
		public String statusProposta { get; set; }
		public Decimal taxaOficialComissao  { get; set; }                 
		public Date dataBaseCalculo { get; set; }
		public String nomeSegurado { get; set; }                             
		public String corretorPrincipal { get; set; }
		public Decimal percentualParticipacaoCia { get; set; }          
		public Decimal descontoEmissaoEspecial { get; set; }
	}


	public class ApoliceTO 
	{
		public String empresa { get; set; }
		public String codigoRamoSeguro { get; set; }                  
		public String codigoSubRamo { get; set; }
		public String sucursalEmissaoSeguro { get; set; }             
		public String modalidadeSeguro { get; set; }                      
		public String numeroApolice { get; set; }
		public String numeroEndosso { get; set; }
		public String numeroEndossoReferencia { get; set; }           
		public String dataEmissaoDocumento { get; set; }                 
		public String dataEmissaoApolice { get; set; }                
		public String dataInicioVigencia { get; set; }                
		public String dataFinalVigencia { get; set; }                
		public String codigoFormaPagamento { get; set; }              
		public String moedaPremio { get; set; }                           
		public String codigoTaxaComissao { get; set; }
		public String origemProposta { get; set; }                           
		public String numeroProposta { get; set; }                           
		public String flagComissaoNegociada { get; set; }                
		public Decimal percentualParticipacaoCia { get; set; }         
		public Decimal descontoEmissaoEspecial { get; set; }
		public String codigoOperacaoComissoes { get; set; }           
		public Decimal taxaOficialComissao { get; set; }                  
		public String nomeSegurado { get; set; }                             
		public Integer parcela { get; set; }
		public String flagNotaComplementar { get; set; }                 
		public String tipoMovimento { get; set; }
		public Integer quantidadeParcelas { get; set; }                    
		public Decimal valorAdicionalFracionamento { get; set; }       
		public Decimal premioLiquido { get; set; }
		public String dataBaseCalculo { get; set; }
		public String corretorCodigoDerivadoSUSEP1 { get; set; }     
		public Decimal percentualParticipacaoCorretor1 { get; set; }  
		public String corretorCodigoDerivadoSUSEP2 { get; set; }
		public Decimal percentualParticipacaoCorretor2 { get; set; }
		public String corretorCodigoDerivadoSUSEP3 { get; set; }
		public Decimal percentualParticipacaoCorretor3 { get; set; }
		public String susep { get; set; }
        //PLV_3384 inicio
        public String susep1 { get; set; }
        //PLV_3384 fim
		public List<ParcelasTO> parcelas { get; set; }
		//PLV-4464 Inicio
		public String codigoPessoaBCP { get; set; }
		//PLV-4464 Fim
		public String endossoReferencia { get; set; } //INÍCIO/FIM - PLV-4660 - GUILHERME BRITO
		public String parcelaCanceladaInicial { get; set; } //INÍCIO/FIM - PLV-4660 - GUILHERME BRITO
	}
	
	
	
	public class DadosParcelasTO
	{
		public MetaTO meta { get; set; }
		public List<ParcelasTO> data { get; set; }
	}
	
	public class ParcelasTO
	{
		public String idexterno { get; set; }
		public Integer idfatura { get; set; }
		public String codigoparceiro { get; set; }
		public String idcontratosalesforce { get; set; }
		public Integer origemproposta { get; set; }
		public String numeroproposta { get; set; }
		public String numerofatura { get; set; }
		public String responsavelfinanceiro { get; set; }
		public String tiporesponsavelpagamento { get; set; }
		public String seguradosalesforce { get; set; }
		public String vidasalesforce { get; set; }
		public String datapagamento { get; set; }
		public String datavencimento { get; set; }
		public Integer numeroparcela { get; set; }
		public String status { get; set; }
		public String titulo { get; set; }
		public String produto { get; set; }
		public String valoriof { get; set; }
		public String valorliquido { get; set; }
		public String valorparcela { get; set; }
		public String valorpago { get; set; }
		public String valorrestituicao { get; set; }//PLV-4601 - INICIO/FIM
		public String empresa { get; set; }
		public String sucursal { get; set; }
		public String ramo { get; set; }
		public String apolice { get; set; }
		public String endosso { get; set; }
		public Integer quantidadevidacontrato { get; set; }
		public Integer id { get; set; }
		public String antecipacaocomissao{get;set;} //PLV-4465 - INICIO/FIM
	}

	public class NumeroPropostaTO{
		//public Integer empresa { get; set; } //RVI-298 Comentar
		public Integer sucursal { get; set; }
		public Integer ramo { get; set; }
	}

}