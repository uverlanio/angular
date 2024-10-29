public class QuestionarioProdutoTriggerHandler extends TriggerHandler {

		
	
	private static QuestionarioProdutoBO objBO = QuestionarioProdutoBO.getInstance();

	public override void beforeInsert() {
		List<QuestionarioProduto__c> questionariosProdutoExistentes = objBO.buscarQuestionariosProdutoPorProdutos(trigger.new);
		objBO.validarQuestionario(trigger.new, questionariosProdutoExistentes);
	}

	public override void beforeUpdate() {
		List<QuestionarioProduto__c> questionariosProdutoExistentes = objBO.buscarQuestionariosProdutoPorProdutos(trigger.new);
		objBO.validarQuestionario(trigger.new, questionariosProdutoExistentes);
	}
	
		
}