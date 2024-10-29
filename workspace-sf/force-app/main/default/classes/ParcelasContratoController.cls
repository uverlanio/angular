/**
 * ParcelasContratoController
 * @author Eric Tunú @ 08/08/2f018
 *
 **/
public with sharing class ParcelasContratoController 
{
	@AuraEnabled
    public static List<Parcelamento> obterParcelas(String id)
	{
		List<Parcelamento> lstParcelas = new List<Parcelamento>();

		//TODO: chamar rotina de consulta de parcelas do contrato do HEROKU
		ParcelamentoContratoTO retorno = ContractFacade.getInstance().ObterParcelasContratoSegurado(id);

		if(!retorno.data.isEmpty())
		{
			for(ParcelamentoContratoTO.DataTO item: retorno.data)
			{
				Parcelamento parcela 	= new Parcelamento();
				parcela.id 				= item.id;
				parcela.dataVencimento 	= item.dataVencimento;
				parcela.numeroParcela 	= String.valueOf(item.numeroParcela);
				parcela.status 			= item.status;
				//INICIO | PLV-2216
				//	//parcela.titulo 			= item.titulo;
				//FIM | PLV-2216
				parcela.valorIOF 		= item.valorIOF;
				parcela.valorLiquido 	= item.valorLiquido;
				parcela.valorTotal 		= item.valorparcela;				
				//INICIO | PLV-2216
				parcela.dataPagamentoParceiro = item.dataPagamentoParceiro;
				//FIM | PLV-2216

				lstParcelas.add(parcela);		
				system.debug('lstParcelas' + lstParcelas);		
			}
		}

		return lstParcelas;
    }

	@AuraEnabled
	public static Boolean atualizarParcelaContrato(Integer id, String status){
		system.debug('atualizarParcelaContrato');
		return ContractFacade.getInstance().atualizarParcelaContrato(id,status);
	}

	//PLV-3869 - INICIO - PEDRO AUGUSTO -SYS4B
	@AuraEnabled
	public static Boolean getCanEdit(){
		//LISTAR AQUI TODOS OS PERFIS QUE PODEM EDITAR A PARCELA NO COMPONENTE
		List<String> permitidos = new List<String>();
		permitidos.add('Emissão');
		permitidos.add('Processos e Projetos');
		permitidos.add('Administrador Porto');
		permitidos.add('Administrador do sistema');
		permitidos.add('System Administrator');//Eu sei, parece redundante, mas ao mudar para English você percebe a surpresinha do nosso ♥ Salesforce

		String perfilAtual = [SELECT Id,Name FROM Profile WHERE Id=:Userinfo.getProfileId()].Name;
		return permitidos.contains(perfilAtual);
	}
	//PLV-3869 - FIM - PEDRO AUGUSTO -SYS4B

	public class Parcelamento
	{
		@AuraEnabled public Integer id { get; set; }
		@AuraEnabled public String dataVencimento { get; set; }
		//INICIO | PLV-2216
		@AuraEnabled public String dataPagamentoParceiro { get; set; }
		//FIM | PLV-2216
		@AuraEnabled public String numeroParcela { get; set; }
		@AuraEnabled public String titulo { get; set; }
		@AuraEnabled public String valorTotal { get; set; }
		@AuraEnabled public String valorIOF { get; set; }
		@AuraEnabled public String valorLiquido { get; set; }
		@AuraEnabled public String status { get; set; }
	}
}