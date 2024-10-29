/**************************************************************************************************************************************************************************
 * 
 *	Classe responsável pelo negócio do objeto de QuestionarioProduto__c
 *
 **************************************************************************************************************************************************************************/
public class QuestionarioProdutoBO {
	private static final QuestionarioProdutoBO instance = new QuestionarioProdutoBO();
	//private static final ProductDAO dao = ProductDAO.getInstance();

	public static QuestionarioProdutoBO getInstance() {
		return instance;
	}

	private QuestionarioProdutoBO() {
		
	}

	//De acordo com os questionarios vindos de uma trigger, busca os quetionarios que já existem com relação a um produto
	public List<QuestionarioProduto__c> buscarQuestionariosProdutoPorProdutos(List<QuestionarioProduto__c> questionariosProduto){
		Set<Id> produtosIds = new Set<Id>();

		for(QuestionarioProduto__c questionario : questionariosProduto){
			produtosIds.add(questionario.Produto__c);	
		}

		return ProductDAO.getInstance().buscarQuestionariosProduto(produtosIds);
	}

	//Executa as validações necessárias para um quetionário
	public void validarQuestionario(List<QuestionarioProduto__c> questionariosProduto, List<QuestionarioProduto__c> questionariosProdutoExistentes){
		//Agrupa todos os quetionarios do DML por produto
		Map<Id, List<QuestionarioProduto__c>> mapQuestionariosProduto = this.gerarMapQuestionariosProduto(questionariosProduto);
		Map<Id, List<QuestionarioProduto__c>> mapQuestionariosProdutoExistentes = this.gerarMapQuestionariosProduto(questionariosProdutoExistentes);
		System.debug('mapQuestionariosProduto> ' + JSON.serializePretty(mapQuestionariosProduto));
		System.debug('mapQuestionariosProdutoExistentes> ' + JSON.serializePretty(mapQuestionariosProdutoExistentes));
		//Varre todos os questionarios a partir de um produto
		for(Id produtoId : mapQuestionariosProduto.keySet()){
			System.debug('produtoId>> ' + produtoId);
			for(QuestionarioProduto__c questionarioDML : mapQuestionariosProduto.get(produtoId)){
				System.debug('questionarioDML> ' + JSON.serializePretty(questionarioDML));
				if(mapQuestionariosProdutoExistentes.containsKey(produtoId)){
					for(QuestionarioProduto__c questionarioExistente : mapQuestionariosProdutoExistentes.get(produtoId)){

						//Valida as prioridades dos questionarios
						this.validarPrioridade(questionarioDML, questionarioExistente);

						//Valida os limite de capital
						this.validarLimiteCapital(questionarioDML, questionarioExistente);
					}
				}
			}
		}
	}

	//Verifica se existe alguma prioridade repetida
	private void validarPrioridade(QuestionarioProduto__c questionarioDML, QuestionarioProduto__c questionarioExistente){
		if(questionarioDML.Id != questionarioExistente.Id && questionarioDML.Prioridade__c == questionarioExistente.Prioridade__c && questionarioDML.GarantiaProduto__c != questionarioExistente.GarantiaProduto__c){
			questionarioDML.addError('Prioridade já utilizada em outra garantia.');
		}
	}

	//Verifica se para uma mesmo produto e garantia, os limites de capital são diferentes e não se intercalam
	private void validarLimiteCapital(QuestionarioProduto__c questionarioDML, QuestionarioProduto__c questionarioExistente){
		//Identifica questionário que precisa de validação de limite de capital
		if(questionarioDML.Id != questionarioExistente.Id && questionarioDML.GarantiaProduto__c == questionarioExistente.GarantiaProduto__c){
			Boolean limiteInvalido = false;

			//Não permite cadastro de questionários que incidem no range de outro para uma mesma garantia
			if(questionarioDML.LimiteCapitalMinimo__c >= questionarioExistente.LimiteCapitalMinimo__c && questionarioDML.LimiteCapitalMinimo__c <= questionarioExistente.LimiteCapitalMaximo__c){
				limiteInvalido = true;
			}

			if(questionarioDML.LimiteCapitalMaximo__c <= questionarioExistente.LimiteCapitalMinimo__c && questionarioDML.LimiteCapitalMaximo__c >= questionarioExistente.LimiteCapitalMaximo__c){
				limiteInvalido = true;
			}

			if(limiteInvalido){
				questionarioDML.addError('Garantia e Importância segurada já cadastradas');
			}
		}
	}

	//Gera map com a relação produto X questionarios
	private Map<Id, List<QuestionarioProduto__c>> gerarMapQuestionariosProduto(List<QuestionarioProduto__c> questionariosProduto){
		Map<Id, List<QuestionarioProduto__c>> mapQuestionariosProduto = new Map<Id, List<QuestionarioProduto__c>>();

		//Agrupa todos os quetionarios do DML por produto
		for(QuestionarioProduto__c questionario : questionariosProduto){
			if(!mapQuestionariosProduto.containsKey(questionario.Produto__c)){
				mapQuestionariosProduto.put(questionario.Produto__c, new List<QuestionarioProduto__c>());				
			}

			mapQuestionariosProduto.get(questionario.Produto__c).add(questionario);
		}

		return mapQuestionariosProduto;
	}
}