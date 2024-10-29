/****
@description Classe de teste para classe EndossoOrcamentoResponse e EndossoOrcamentoVIResponse aumentar a coberura do teste
@author jeferson santana
@date 03/01/2021
-Classe criada por conta 4695    
*****/
@isTest
public class EndossoOrcamentoResponseTest {
    @isTest
    static void testSuccess() {
        Test.startTest();
        
        List<EndossoOrcamentoResponse.DevolutivasTO> listaDevolutivas = new List<EndossoOrcamentoResponse.DevolutivasTO>();
        EndossoOrcamentoResponse.DevolutivasTO dev = new EndossoOrcamentoResponse.DevolutivasTO();
        dev.codigo = 1;
        dev.origem = 'teste';
        dev.descricao = 'teste';
        dev.tipoRegistro = 1;
        dev.numeroCampo = 1;
        listaDevolutivas.add(dev);
        
        EndossoOrcamentoResponse.ValidacaoOrcamentoTO devolutiva = new EndossoOrcamentoResponse.ValidacaoOrcamentoTO();
        devolutiva.devolutivas = listaDevolutivas;

        EndossoOrcamentoResponse.OrcamentoAtualizadoTO orc = new EndossoOrcamentoResponse.OrcamentoAtualizadoTO();
        orc.status = 'CAN';
		orc.apolice = 1; 
		orc.ramo = 1391;
		orc.tipoSeguro = 'teste';
		orc.tipoAdesao = 'teste';
		orc.vigenciaFinal = '2021-01-03';
		orc.empresa = 1;
		orc.dataCalculo = '2021-01-03';
		orc.sucursal = 1;
		orc.vigenciaInicial = '2021-01-03';
		orc.numeroOrcamento = 1;
		orc.meioComercializacao = 'teste';
        orc.qtdDiasVigencia = 1;
        
        List<EndossoOrcamentoResponse.OfertasTO> listaOfertas = new List<EndossoOrcamentoResponse.OfertasTO>();
        EndossoOrcamentoResponse.OfertasTO oferta = new EndossoOrcamentoResponse.OfertasTO();
        oferta.orcamento = orc;
    
        devolutiva.ofertas = listaOfertas;

        Test.stopTest();
    }

    @isTest
    static void testSuccessVI() {
        Test.startTest();
        
        List<EndossoOrcamentoVIResponse.DevolutivasTO> listaDevolutivas = new List<EndossoOrcamentoVIResponse.DevolutivasTO>();
        EndossoOrcamentoVIResponse.DevolutivasTO dev = new EndossoOrcamentoVIResponse.DevolutivasTO();
        dev.codigo = 1;
        dev.origem = 'teste';
        dev.descricao = 'teste';
        dev.tipoRegistro = 1;
        dev.numeroCampo = 1;
        listaDevolutivas.add(dev);
        
        EndossoOrcamentoVIResponse.ValidacaoOrcamentoTO devolutiva = new EndossoOrcamentoVIResponse.ValidacaoOrcamentoTO();
        devolutiva.devolutivas = listaDevolutivas;

        EndossoOrcamentoVIResponse.OrcamentoAtualizadoTO orc = new EndossoOrcamentoVIResponse.OrcamentoAtualizadoTO();
        orc.status = 'CAN';
		orc.apolice = 1; 
		orc.ramo = 1391;
		orc.tipoSeguro = 'teste';
		orc.tipoAdesao = 'teste';
		orc.vigenciaFinal = '2021-01-03';
		orc.empresa = 1;
		orc.dataCalculo = '2021-01-03';
		orc.sucursal = 1;
		orc.vigenciaInicial = '2021-01-03';
		orc.numeroOrcamento = 1;
		orc.meioComercializacao = 'teste';
        orc.qtdDiasVigencia = 1;
        
        List<EndossoOrcamentoVIResponse.OfertasTO> listaOfertas = new List<EndossoOrcamentoVIResponse.OfertasTO>();
        EndossoOrcamentoVIResponse.OfertasTO oferta = new EndossoOrcamentoVIResponse.OfertasTO();
        oferta.orcamento = orc;
    
        devolutiva.ofertas = listaOfertas;
		EndossoOrcamentoVIResponse.RemuneracoesTO remuneracao = new EndossoOrcamentoVIResponse.RemuneracoesTO();
        remuneracao.percentual = 0;
        remuneracao.tipoRemuneracao = 'teste';
        
        Test.stopTest();
    }
}