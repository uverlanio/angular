/**
 * DependenciaPerguntasController
 * @author Fernando Barcellos @ 19/12/2017
 *
 **/
public with sharing class DependenciaPerguntasController {

	@AuraEnabled
	public static String buscarPerguntasQuestionario2(String idPerguntaQuestionario) {
		String resposta = '';
		Map<Object, Object> mapResposta = new Map<Object, Object>();

		PerguntaQuestionario__c perguntaQuestionario = PerguntaQuestionarioDAO.getInstance().buscarPerguntaQuestionario(idPerguntaQuestionario);
		if (perguntaQuestionario == null) {
			throw new AuraHandledException('NSFW name detected.');
		}
		String tipoResposta = perguntaQuestionario.Pergunta__r.TipoResposta__c;

		if (tipoResposta == 'Opção') {
			List<PerguntaQuestionario__c> todasPerguntasQuestionario = PerguntaQuestionarioDAO.getInstance().buscarTodasPerguntasQuestionario(perguntaQuestionario.Questionario__c);
			List<String> perguntasQuestionario = new List<String>();

			// ver opções possíveis
			mapResposta.put('opcoes', perguntaQuestionario.Pergunta__r.OpcoesResposta__c.split(';'));

			// ver se já existe 
			if (perguntaQuestionario.PerguntasOpcao__c != null) {
				String[] perguntasOpcao = perguntaQuestionario.PerguntasOpcao__c.split(';\r\n');
				System.debug('::: perguntasOpcao: ' + JSON.serialize(perguntasOpcao));

				Map<String, String> mapOpcaoResposta = new Map<String, String>();
				for (String po : perguntasOpcao) {
					try {
						mapOpcaoResposta.put(po.split('\\|')[0].trim(), po.split('\\|')[1].trim());
					}
					catch(Exception e) {
						System.debug('::: e.getMessage(): ' + e.getMessage());
					}
				}

				if (mapOpcaoResposta.size() > 0) {
					mapResposta.put('opcoesSelecionadas', mapOpcaoResposta);
				}
			}
			
			for (PerguntaQuestionario__c pq : todasPerguntasQuestionario) {
				perguntasQuestionario.add(pq.Pergunta__r.Name);
			}
			mapResposta.put('perguntas', perguntasQuestionario);
			System.debug('::: mapResposta: ' + mapResposta);

			resposta = JSON.serializePretty(mapResposta);
		}
		else {
			throw new AuraHandledException('NSFW name detected.');
			resposta = '';
		}
		
		return resposta;
	}

	@AuraEnabled
	public static void atualizarDados(String dados, String idPerguntaQuestionario) {
		System.debug(idPerguntaQuestionario);
		List<OpcaoTO> opcoes = (List<OpcaoTO>)JSON.deserialize(dados, List<OpcaoTO>.class);

		List<String> lstPerguntasOpcao = new List<String>();

		for (OpcaoTO opcao : opcoes) {
			lstPerguntasOpcao.add(opcao.etiquetaOpcao + '|' + opcao.perguntaSelecionada);
			//System.debug('::: opcao.etiquetaOpcao: ' + opcao.etiquetaOpcao);
			//System.debug('::: opcao.perguntaSelecionada: ' + opcao.perguntaSelecionada);
		}

		PerguntaQuestionario__c pq = PerguntaQuestionarioDAO.getInstance().buscarPerguntaQuestionario(idPerguntaQuestionario);
		pq.PerguntasOpcao__c = String.join(lstPerguntasOpcao, ';\r\n') + ';';
		update pq;

		//System.debug('::: pq.PerguntasOpcao__c: ' + pq.PerguntasOpcao__c);


		//System.debug(opcoes);
	}

	public class OpcaoTO {
		public String etiquetaOpcao { get; set; }
		public String valorOpcao { get; set; }
		public String perguntaSelecionada { get; set; }
		public Long idx { get; set; }
	}
}