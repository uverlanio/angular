/**
 * Created by Losada on 16/02/2019.
 */

@IsTest
private class ConsultarDadosContratoTOTest {

    @IsTest
    static void testBehavior() {


		ConsultarDadosContratoTO.PropostaTO propostaTO = new ConsultarDadosContratoTO.PropostaTO();
		propostaTO.empresa = 'Teste';
		propostaTO.origemProposta = 'Teste';
		propostaTO.numeroProposta = 'Teste';
		propostaTO.codigoOperacaoComissoes = 'Teste';
		propostaTO.dataEmissaoDocumento = Date.newInstance(2015,10,10);
		propostaTO.codigoRamoSeguro = 'Teste';
		propostaTO.codigoSubramo = 'Teste';
		propostaTO.modalidadeSeguro = 'Teste';
		propostaTO.sucursalEmissaoSeguro = 'Teste';
		propostaTO.numeroApolice = 'Teste';
		propostaTO.numeroEndosso = 'Teste';
		propostaTO.dataInicioVigencia = Date.newInstance(2015,10,10);
		propostaTO.dataFinalVigencia = Date.newInstance(2015,10,10);
		propostaTO.codigoFormaPagamento = 'Teste';
		propostaTO.premioLiquido = 1;
		propostaTO.valorAdicionalFracionamento = 1;
		propostaTO.premioBruto = 1;
		propostaTO.quantidadeParcelas = 1;
		propostaTO.statusProposta = 'Teste';
		propostaTO.taxaOficialComissao = 1;
		propostaTO.dataBaseCalculo = Date.newInstance(2015,10,10);
		propostaTO.nomeSegurado = 'Teste';
		propostaTO.corretorPrincipal = 'Teste';
		propostaTO.descontoEmissaoEspecial = 1;

		ConsultarDadosContratoTO.MetaTO metaTO = new ConsultarDadosContratoTO.MetaTO();
		metaTO.dataExecucao = 'Teste';
		metaTO.servico = 'Teste';
		metaTO.statusHttp = 1;
		metaTO.mensagem = 'Teste';

		ConsultarDadosContratoTO.ParcelasTO parcelasTO = new ConsultarDadosContratoTO.ParcelasTO();
		parcelasTO.idexterno = 'Teste';
		parcelasTO.idfatura = 1;
		parcelasTO.codigoparceiro = 'Teste';
		parcelasTO.idcontratosalesforce = 'Teste';
		parcelasTO.origemproposta = 1;
		parcelasTO.numeroproposta = 'Teste';
		parcelasTO.numerofatura = 'Teste';
		parcelasTO.responsavelfinanceiro = 'Teste';
		parcelasTO.tiporesponsavelpagamento = 'Teste';
		parcelasTO.seguradosalesforce = 'Teste';
		parcelasTO.vidasalesforce = 'Teste';
		parcelasTO.datapagamento = 'Teste';
		parcelasTO.datavencimento = 'Teste';
		parcelasTO.numeroparcela = 1;
		parcelasTO.status = 'Teste';
		parcelasTO.titulo = 'Teste';
		parcelasTO.produto = 'Teste';
		parcelasTO.valoriof = 'Teste';
		parcelasTO.valorliquido = 'Teste';
		parcelasTO.valorparcela = 'Teste';
		parcelasTO.valorpago = 'Teste';
		parcelasTO.empresa = 'Teste';
		parcelasTO.sucursal = 'Teste';
		parcelasTO.ramo = 'Teste';
		parcelasTO.apolice = 'Teste';
		parcelasTO.endosso = 'Teste';
		parcelasTO.quantidadevidacontrato = 1;
		parcelasTO.id = 1;

		ConsultarDadosContratoTO.DadosParcelasTO dadosparcelasTO = new ConsultarDadosContratoTO.DadosParcelasTO();
		dadosparcelasTO.meta = metaTO;
		dadosparcelasTO.data =  new List<ConsultarDadosContratoTO.ParcelasTO>{parcelasTO};

		ConsultarDadosContratoTO.ApoliceTO  apoliceTO = new ConsultarDadosContratoTO.ApoliceTO();
		apoliceTO.empresa = 'Teste';
		apoliceTO.codigoRamoSeguro = 'Teste';
		apoliceTO.codigoSubRamo = 'Teste';
		apoliceTO.sucursalEmissaoSeguro = 'Teste';
		apoliceTO.modalidadeSeguro = 'Teste';
		apoliceTO.numeroApolice = 'Teste';
		apoliceTO.numeroEndosso = 'Teste';
		apoliceTO.numeroEndossoReferencia = 'Teste';
		apoliceTO.dataEmissaoDocumento = 'Teste';
		apoliceTO.dataEmissaoApolice = 'Teste';
		apoliceTO.dataInicioVigencia = 'Teste';
		apoliceTO.dataFinalVigencia = 'Teste';
		apoliceTO.codigoFormaPagamento = 'Teste';
		apoliceTO.moedaPremio = 'Teste';
		apoliceTO.codigoTaxaComissao = 'Teste';
		apoliceTO.origemProposta = 'Teste';
		apoliceTO.numeroProposta = 'Teste';
		apoliceTO.flagComissaoNegociada = 'Teste';
		apoliceTO.percentualParticipacaoCia = 1;
		apoliceTO.descontoEmissaoEspecial = 1;
		apoliceTO.codigoOperacaoComissoes = 'Teste';
		apoliceTO.taxaOficialComissao = 1;
		apoliceTO.nomeSegurado = 'Teste';
		apoliceTO.parcela = 1;
		apoliceTO.flagNotaComplementar = 'Teste';
		apoliceTO.tipoMovimento = 'Teste';
		apoliceTO.quantidadeParcelas = 1;
		apoliceTO.valorAdicionalFracionamento = 1;
		apoliceTO.premioLiquido = 1;
		apoliceTO.dataBaseCalculo = 'Teste';
		apoliceTO.corretorCodigoDerivadoSUSEP1 = 'Teste';
		apoliceTO.percentualParticipacaoCorretor1 = 1;
		apoliceTO.corretorCodigoDerivadoSUSEP2 = 'Teste';
		apoliceTO.percentualParticipacaoCorretor2 = 1;
		apoliceTO.corretorCodigoDerivadoSUSEP3 = 'Teste';
		apoliceTO.percentualParticipacaoCorretor3 = 1;
		apoliceTO.susep = 'Teste';
		apoliceTO.parcelas =   new List<ConsultarDadosContratoTO.ParcelasTO>{parcelasTO};

        // EventoTO
        ConsultarDadosContratoTO.DadosContratoTO contratoTO = new ConsultarDadosContratoTO.DadosContratoTO();
		contratoTO.statusChamada = 1;
		contratoTO.descricaoErro = 'Teste';
		contratoTO.proposta = propostaTO;
		contratoTO.apolice = new List<ConsultarDadosContratoTO.ApoliceTO>{apoliceTO};

		ConsultarDadosContratoTO.NumeroPropostaTO numeropropsotaTO = new ConsultarDadosContratoTO.NumeroPropostaTO();
		//numeropropsotaTO.empresa = 1; //RVI-298 Comentar
		numeropropsotaTO.sucursal = 1;
		numeropropsotaTO.ramo = 1;

	}
}