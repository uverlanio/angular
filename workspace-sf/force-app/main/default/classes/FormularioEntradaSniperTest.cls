/*********************************************************************************************************************************************************************

@description  Classe que contem a ClasseTeste para o CtrFormularioEntradaSniper.
@author Renan Martins - Avanxo
@date 06/006/2019
@Hackathon Sniper Atualização 06/06/2019
@Classe criada por conta da história PLV-2318
        
**********************************************************************************************************************************************************************/

@isTest
public class FormularioEntradaSniperTest {
    
    
   @isTest
     static void testFormularioEntradaSnipper() {
         
       test.startTest();
        
			String  XmlConsultivo= '{ '+
	
                +'"consultivo":{ '+
		+'"codigoOfertaConsultiva":"SNIPER",'+
		+'"canalDistribuicao":"COR",'+
		+'"susepCorretor":"S5005J",'+
		+'"meioComercializacao":"SFC",'+ //PLV-4550 INICIO/FIM
		+'"conjuntos": [ '+
		+'{ '+
				+'"id": 1,'+
				+'"titulo":"Simulação de Seguro de Vida",'+
				+'"subtitulo":"Para simular seu seguro, você só precisa preencher algumas informações.",'+
				+'"informacoes": [ '+
				+'{ '+
					+'"id":"TIPOCONTRATO",'+
					+'"nome":"Tipo de Contrato",'+
					+'"descricao":"Selecione seu tipo de contrato",'+
					+'"tipo":"Opções fixas",'+
					+'"obrigatorio": true,'+
					+'"opcoes": [ '+
					+'{ '+
							+'"codigo":"VOCE",'+
							+'"rotulo":"Plano para você"'+
						+'} ,'+
						+'{ '+
							+'"codigo":"FAMILIA",'+
							+'"rotulo":"Plano para sua família"'+
						+'},'+
						+'{ '+
							+'"codigo":"TODOS",'+
							+'"rotulo":"Plano para todos"'+
						+'} '+
					+'] '+
				+'} '+
				+'] ,'+
				+'"regrasSequencia": [ '+
				+'{ '+
					+'"sequencia": 1,'+
					+'"proximoConjunto": 2'+
				+'} '+
				+'] '+
			+'} ,'+
			+'{ '+
				+'"id": 2,'+
				+'"titulo":"Simulação de Seguro de Vida",'+
				+'"subtitulo":"Preencha as informações básicas.",'+
				+'"informacoes": [ '+
				+'{ '+
						+'"id":"NOMECOMPLETO",'+
						+'"nome":"Nome Completo",'+
						+'"tipo":"Texto",'+
						+'"obrigatorio": true'+
					+'} ,'+
					+'{ '+
						+'"id":"NASCIMENTO",'+
						+'"nome":"Nascimento",'+
						+'"tipo":"Data",'+
						+'"obrigatorio": true'+
					+'} ,'+
					+'{ '+
						+'"id":"SEXO",'+
						+'"nome":"Sexo",'+
						+'"tipo":"Opções fixas",'+
						+'"obrigatorio": true,'+
						+'"opcoes": [ '+
						+'{ '+
								+'"codigo":"MASC",'+
								+'"rotulo":"Masculino"'+
							+'} ,'+
							+'{ '+
								+'"codigo":"FEM",'+
								+'"rotulo":"Feminino"'+
							+'} '+
						+'] '+
					+'} ,'+
					+'{ '+
						+'"id":"FUMANTE",'+
						+'"nome":"Fumante",'+
						+'"tipo":"Booleano",'+
						+'"obrigatorio": true'+
					+'} ,'+
					+'{ '+
						+'"id":"ESTADOCIVIL",'+
						+'"nome":"Estado civil",'+
						+'"tipo":"Opções fixas",'+
						+'"obrigatorio": true,'+
						+'"opcoes": [ '+
						+'{ '+
								+'"codigo":"SOL",'+
								+'"rotulo":"Solteiro"'+
							+'} ,'+
							+'{ '+
								+'"codigo":"CAS",'+
								+'"rotulo":"Casado"'+
							+'} ,'+
							+'{ '+
								+'"codigo":"DIV",'+
								+'"rotulo":"Divorciado"'+
							+'} ,'+
							+'{ '+
								+'"codigo":"VIU",'+
								+'"rotulo":"Viúvo"'+
							+'} '+
						+'] '+
					+'} ,'+
					+'{ '+
						+'"id":"PROFISSAO",'+
						+'"nome":"Profissão",'+
						+'"tipo":"Opções de serviço",'+
						+'"servico":"/consultas/profissao/",'+
						+'"obrigatorio": true'+
					+'} '+
				+'],'+
				+'"regrasSequencia": [ '+
				+'{ '+
					+'"sequencia": 1,'+
					+'"proximoConjunto": 3'+
				+'} '+
				+'] '+
			+'} ,'+
			+'{ '+
				+'"id": 3,'+
				+'"titulo":"Referência para o valor do seguro",'+
				+'"subtitulo":"Você pode alterar o valor do seguro depois. Isso é só para iniciarmos.",'+
				+'"informacoes": [ '+
				+'{ '+
					+'"id":"RENDAMENSAL",'+
					+'"nome":"Renda mensal",'+
					+'"descricao":"Qual sua faixa de renda mensal?",'+
					+'"tipo":"Opções fixas",'+
					+'"obrigatorio": true,'+
					+'"opcoes": [ '+
					+'{ '+
							+'"codigo":"0-4000",'+
							+'"rotulo":"Até R$ 4.000,00"'+
						+'} ,'+
						+'{ '+
							+'"codigo":"4001-8000",'+
							+'"rotulo":"De R$ 4.000,01 a R$ 8.000,00"'+
						+'} ,'+
						+'{ '+
							+'"codigo":"8001-12000",'+
							+'"rotulo":"De R$ 8.000,01 a R$ 12.000,00"'+
						+'} ,'+
						+'{ '+
							+'"codigo":"12001-16000",'+
							+'"rotulo":"De R$ 12.000,01 a R$ 16.000,00"'+
						+'} ,'+
						+'{ '+
							+'"codigo":"16001-infinito",'+
							+'"rotulo":"Acima de R$ 16.000,00"'+
						+'} '+
					+'] '+
				+'} '+
				+'] '+
			+'} '+
		+'] '+
	 +'} '+
         +'} ';
                                       
                    Test.setMock(HttpCalloutMock.class, new MockHttpResponse(XmlConsultivo, 200, 'OK'));
         
             CtrFormularioEntradaSniper testeSnipper = new CtrFormularioEntradaSniper ();
         PageReference page = Page.formularioSniper;
         Test.setCurrentPage(page);
         
             testeSnipper.redirecionar();  
		test.stopTest();
         

     }

    //PLV-2411-Sniper - Início - Lógica para tratamento de exceção.
    @isTest
	static void FormularioEntradaSniperTestRetornoErro(){

		test.startTest();

			String erroServico = 'Erro na requisição';

			Test.setMock(HttpCalloutMock.class, new MockHttpResponse(erroServico, 404, 'NOK'));
         
             CtrFormularioEntradaSniper testeSnipper = new CtrFormularioEntradaSniper ();
        	 PageReference page = Page.formularioSniper;
        	 Test.setCurrentPage(page);
         
             testeSnipper.redirecionar();  

		test.stopTest();

	}
	//PLV-2411-Sniper - Fim - Lógica para tratamento de exceção.
	
}