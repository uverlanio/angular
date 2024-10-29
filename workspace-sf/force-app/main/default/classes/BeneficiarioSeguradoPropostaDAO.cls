/**

 * BeneficiarioSeguradoPropostaDAO
 * @author Eric Tunú @ 21/06/2018
 *
 **/
public with sharing class BeneficiarioSeguradoPropostaDAO 
{
	private static final BeneficiarioSeguradoPropostaDAO instance = new BeneficiarioSeguradoPropostaDAO();
	public static BeneficiarioSeguradoPropostaDAO getInstance() { return instance; }

	
	public List<BeneficiarioSeguradoProposta__c> buscarBeneficiariosSeguradoProposta(Set<String> idSegurado) 
	{
		return 
		[
			SELECT
				Id,
				Conta__c,
				CpfCnpj__c,
				CpfPep__c,
				GrauParentesco__c,
				GrauParentescoPep__c,
				ImprimirCertificadoSeguro__c,
				Nome__c,
				NomePessoaPep__c,
				Participacao__c,
				Pep__c,
				SeguradoProposta__c,
				TipoBeneficiario__c
			FROM
				BeneficiarioSeguradoProposta__c
			WHERE
				SeguradoProposta__c IN :idSegurado
				
		];
	}	
}