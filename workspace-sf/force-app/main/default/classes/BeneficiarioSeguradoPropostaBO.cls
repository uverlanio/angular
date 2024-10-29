/**
 * BeneficiarioSeguradoPropostaBO
 * @author Eric Tunú @ 21/06/2018
 *
 **/
public with sharing class BeneficiarioSeguradoPropostaBO 
{
	public static final String mensagemErro = 'Soma dos percentuais dos beneficiários deve ser igual a 100%';
	public static final String mensagemValidacao = 'Percentual de participação não informado, igual ou menor que zero.';

	private static final BeneficiarioSeguradoPropostaBO instance = new BeneficiarioSeguradoPropostaBO();
	public static BeneficiarioSeguradoPropostaBO getInstance() { return instance; }
	private BeneficiarioSeguradoPropostaBO() { }

/*---- LOSADA: rotina descontinuada
	public void validaPercentalParticipacao(List<BeneficiarioSeguradoProposta__c> lstNew)
	{
		System.debug('BeneficiarioSeguradoPropostaBO >> validaPercentalParticipacao >> Lista de beneficiarios:  '  + lstNew);
		Set<String> 						 setIdsSegurado		= new Set<String>();
		Map<String, BeneficiarioSeguradoProposta__c> mapBeneficiarios	= new Map<String, BeneficiarioSeguradoProposta__c>();
		List<BeneficiarioSeguradoProposta__c> 		 lstOld	 			= new List<BeneficiarioSeguradoProposta__c>();
		
		Map<String, List<BeneficiarioSeguradoProposta__c>> mapBeneficiariosAgrupados = new Map<String, List<BeneficiarioSeguradoProposta__c>>();

		for(BeneficiarioSeguradoProposta__c beneficiario : lstNew)
		{
			if(beneficiario.TipoBeneficiario__c == 'Nome do beneficiário')
			{
				if(beneficiario.Participacao__c == null)
					beneficiario.addError(mensagemValidacao);
					
				if(beneficiario.Participacao__c <= 0)
					beneficiario.addError(mensagemValidacao);

				if(!setIdsSegurado.contains(beneficiario.SeguradoProposta__c))
					setIdsSegurado.add(beneficiario.SeguradoProposta__c);
			}
		}

		lstOld = BeneficiarioSeguradoPropostaDAO.getInstance().buscarBeneficiariosSeguradoProposta(setIdsSegurado);
		//tratas os registros em caso de update
		if(!lstOld.isEmpty())
		{
			system.debug('old:  ' + lstOld);
			for(BeneficiarioSeguradoProposta__c beneficiario : lstOld)
			{
				// if(!String.isBlank(beneficiario.Id))
				// {
					if(beneficiario.TipoBeneficiario__c == 'Nome do beneficiário')
						mapBeneficiarios.put(beneficiario.Id, beneficiario);
				//}
			}

			system.debug('new:  ' + lstNew);
			for(BeneficiarioSeguradoProposta__c beneficiario : lstNew)
			{
				BeneficiarioSeguradoProposta__c itemDuplicado = mapBeneficiarios.get(beneficiario.Id);
				if(itemDuplicado != null)
				{
					if(beneficiario.TipoBeneficiario__c == 'Nome do beneficiário')
						mapBeneficiarios.remove(beneficiario.Id);
				}
			}
		}

		system.debug('map:  ' + mapBeneficiarios.values());

		//agrupa beneficiarios por Seguradoproposta
		for(String SeguradopropsotaId : setIdsSegurado)
		{
			//valida se os beneficiarios de cada Segurado proposta ultrapassaram os 100 % de 
			Decimal limite = 100;
			List<BeneficiarioSeguradoProposta__c> lstTemp = new List<BeneficiarioSeguradoProposta__c>();
			for(BeneficiarioSeguradoProposta__c beneficiario : mapBeneficiarios.values())
			{
				if(beneficiario.SeguradoProposta__c == SeguradopropsotaId)
					lstTemp.add(beneficiario);
			}

			for(BeneficiarioSeguradoProposta__c beneficiario : lstTemp)
				limite = limite - beneficiario.Participacao__c;
				
			if(limite > 0)
			{
				lstTemp = new List<BeneficiarioSeguradoProposta__c>();
				for(BeneficiarioSeguradoProposta__c beneficiario : lstNew)
				{
					if(beneficiario.SeguradoProposta__c == SeguradopropsotaId)
						lstTemp.add(beneficiario);
				}

				boolean ultrapassouLimite = false;
				system.debug('lstTemp ' + lstTemp);
				for(BeneficiarioSeguradoProposta__c beneficiario : lstTemp)
				{
					if(beneficiario.Participacao__c == null)
						beneficiario.addError(mensagemValidacao);
					else
					{
						system.debug('limite ' + limite);
						system.debug('participação beneficiario; ' + beneficiario.Participacao__c);
						limite = limite - beneficiario.Participacao__c;
						if(limite < 0)
							ultrapassouLimite = true;
					}
				}

				if(ultrapassouLimite)
				{
					system.debug('ultrapassouLimite' + limite);
					for(BeneficiarioSeguradoProposta__c beneficiario : lstTemp)
						beneficiario.addError(mensagemErro);
				}				
			}
			else
			{
				system.debug('Limite '  + limite);
				lstTemp = new List<BeneficiarioSeguradoProposta__c>();
				for(BeneficiarioSeguradoProposta__c beneficiario : lstNew)
				{
					if(beneficiario.SeguradoProposta__c == SeguradopropsotaId)
						lstTemp.add(beneficiario);
				}

				for(BeneficiarioSeguradoProposta__c beneficiario : lstTemp)
					beneficiario.addError(mensagemErro);
			}
		}
	}
*/
	public BeneficiarioSeguradoProposta__c incluirBeneficiariosSeguradoProposta(Account Conta, Id SeguradoGrupo, String tipoBeneficiario, boolean imprimirCertificadoSeguro, Decimal participacao )
	{
		BeneficiarioSeguradoProposta__c beneficiario = new BeneficiarioSeguradoProposta__c();

		beneficiario.Conta__c 						= Conta.Id;
		beneficiario.SeguradoProposta__c 			= SeguradoGrupo;
		beneficiario.Pep__c 						= 'Nao';//Conta.Pep__c == 'null' ? 'Nao' : Conta.Pep__c;
		beneficiario.CpfCnpj__c 					= Conta.CPF__C == null ? Conta.CNPJ__c.replace('.','').replace('-','').replace('/','') : Conta.CPF__C.replace('.','').replace('-','').replace('/','');
		beneficiario.Nome__c 						= Conta.Name;
		beneficiario.CurrencyIsoCode 				= Conta.CurrencyIsoCode;
		beneficiario.TipoBeneficiario__c 			= tipoBeneficiario;
		beneficiario.ImprimirCertificadoSeguro__c 	= imprimirCertificadoSeguro;
		beneficiario.Participacao__c 				= participacao;
		beneficiario.GrauParentesco__c 				= 'Prestamista';
		// beneficiario.NomePessoaPep__c 				= Conta.NomePessoaPep__c;
		// beneficiario.CpfPep__c 						= Conta.CpfPep__c;
		// beneficiario.GrauParentescoPep__c 			= Conta.GrauParentescoPep__c;
		// beneficiario.MotivoSemCpfCnpj__c 			= Conta.MotivoSemCpfCnpj__c;

		return beneficiario;
	}
	

	public class BeneficiarioSeguradoPropostaException extends Exception {	}
}