@isTest
private class GarantiaContratoTOTest 
{
	@isTest
	static void testGarantiaContratoTO()
	{
		GarantiaContratoTO.DadosPortoCap  portoCap = new GarantiaContratoTO.DadosPortoCap();
		portoCap.Nr_cnpj = '69151342000139';
		portoCap.Cd_promocao = '1';
		portoCap.cd_versao = 1;


		GarantiaContratoTO.RetornoConsultaTitulosTO retornoTitulo = new GarantiaContratoTO.RetornoConsultaTitulosTO();
		GarantiaContratoTO.PropostasTO proposta = new GarantiaContratoTO.PropostasTO();
		GarantiaContratoTO.DadosTitulos dadosTitulos = new GarantiaContratoTO.DadosTitulos();
		dadosTitulos.Titulos = new List<GarantiaContratoTO.Titulos>();
		GarantiaContratoTO.Titulos titulo = new GarantiaContratoTO.Titulos();
 
		titulo.cd_cessionario = '01';
		titulo.nm_cessionario = '01';
		titulo.nr_cpfcnpj_cessionario = 1;
		titulo.Nr_titulo = 11;
		titulo.nr_Lote = 12;
		titulo.vr_desconto = 10;
		titulo.Vr_valor = 10;
		titulo.nr_sorte = '13';
		titulo.nm_status = 'OK';
		titulo.dt_sorteio = Date.valueOf(System.now());

		dadosTitulos.Titulos.add(titulo);

		proposta.nm_pessoa = 'Teste';
		proposta.nr_cnpjcpf = 11;
		proposta.Cd_promocao = '11';
		proposta.cd_versao = 1;
		proposta.nr_serie = '01';
		proposta.nr_proposta = '123';
		proposta.dt_emissao = '10/10/2018';
		proposta.dt_inicio_vigencia = '10/10/2018';
		proposta.DadosTitulos = dadosTitulos;
		proposta.nm_retorno = 'OK';


	}
}