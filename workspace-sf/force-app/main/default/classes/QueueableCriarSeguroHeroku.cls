public class QueueableCriarSeguroHeroku implements Queueable, Database.AllowsCallouts
{
	private Set<Id> IdContratos { get; set; }

    private static HerokuService herokuServ = HerokuService.getInstance();

	public QueueableCriarSeguroHeroku(Set<Id> setContrato) 
	{
		this.IdContratos = setContrato;
	}

	public void execute(QueueableContext queueCont)
	{	

		List<ServiceTO.SeguroContratoTO> seguros = gerarParametro(IdContratos);

    	HerokuService.getInstance().gerarDadosSeguroContrato(seguros);

	}

	private List<ServiceTO.SeguroContratoTO> gerarParametro(Set<Id> setContrato)
	{
	  	ContractDAO dao = ContractDAO.getInstance();

	    Map<String,ProdutoParceiro__c> mapProdutoParceiroPorChaveParceiroEProduto = new Map<String, ProdutoParceiro__c>();
    
	    List<Contract> contratos = dao.buscarContratos(setContrato);

	    Set<String> parceiro = new Set<String>();
	    Set<Id> produto = new Set<Id>();

	    // carrega os dados de parceiro/produto para busca do produto do parceiro
	    for(Contract contrato : contratos)
	    {
	      parceiro.add(contrato.Parceiro__c);
	      produto.add(contrato.Produto__c);
	    }

	    List<ServiceTO.SeguroContratoTO> seguros = new List<ServiceTO.SeguroContratoTO>();

	    // Lê contratos para geração do Json
	    for(Contract contrato : contratos)
	    {
	      // Busca o codigo do produto do parceiro
	      for(ProdutoParceiro__c produtoParceiro : dao.buscarProdutoDoParceiro(parceiro, produto)){
	        mapProdutoParceiroPorChaveParceiroEProduto.put(produtoParceiro.Parceiro__r.Codigo__c + '_' + produtoParceiro.Produto__c, produtoParceiro);
	      }

	      ServiceTO.SeguroContratoTO seguro = new ServiceTO.SeguroContratoTO();

	      // Carrega Json para altualização do arquivo no Heroku
	      seguro.empresa            = contrato.Empresa__c;
	      seguro.sucursal           = contrato.Sucursal__c;
	      seguro.ramo               = contrato.CodigoRamo__c;
	      seguro.apolice            = contrato.NumeroApolice__c;
	      seguro.endosso            = contrato.Endosso__c;
	      seguro.idSalesforce       = contrato.Id;
	      if(contrato.Tipo__c == 'Novo' || contrato.Tipo__c == 'Endosso')
	            seguro.situacaoApolice    = 'ATIVO';
	      else if(contrato.Tipo__c == 'Cancelamento')
	            seguro.situacaoApolice    = 'CANCELADO';
	      seguro.statusContrato     = contrato.Status;
	      seguro.vigenciaInicial    = Contrato.StartDate;
	      seguro.vigenciaFinal      = contrato.VigenciaFinal__c;

	      if(mapProdutoParceiroPorChaveParceiroEProduto.containsKey(contrato.Parceiro__c + '_' + contrato.Produto__c))
	      {
	           ProdutoParceiro__c produtoParceiro = mapProdutoParceiroPorChaveParceiroEProduto.get(contrato.Parceiro__c + '_' + contrato.Produto__c);
	           seguro.produto       = produtoParceiro.CodigoProdutoParceiro__c;
		// PLV-4222 - INICIO
		}else{
			seguro.produto 		= contrato.Produto__r.ProductCode;
		}
		// PLV-4222 - FIM
	      seguro.canal              = contrato.CanalDistribuicao__r.Sigla__c;
	      seguro.susepLider         = contrato.CodigoCorretor__r.Name;           //  Corretor Principal - Código derivado do SUSEP
	      seguro.tipoEndosso        = contrato.TipoEndosso__c;
	      seguro.tipoSeguro         = contrato.Tipo__c;

	      for(ContratanteContrato__c contratante : contrato.ContratantesContrato__r)
	      {
	        seguro.quantidadeParcelas = (Integer)contratante.QuantidadeParcelas__c;
	        break;
	      }

		  seguros.add(seguro);

	    }

	    return seguros;
	}


}