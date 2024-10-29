public class BackgroundConsoleController {
	private static BackgroundConsoleDAO dao = BackgroundConsoleDAO.getInstance();
    private static OpportunityBO boOpportunity = OpportunityBO.getInstance();
	/**
     * Realiza a busca de oportunidade por Id de um roteamento
     *
     * @param routeId - Id do roteamento
     */
    @AuraEnabled
    public static Opportunity burcarOportunidadePorRoteamentoId(String routerId){
        return dao.burcarOportunidadePorRoteamentoId((Id)routerId);
        
    }

    /**
     * Recebe uma oportunidade e executa a gravação da mesma
     *
     * @param oportunidade - objeto opportunity
     */
    @AuraEnabled
    public static void atualizarOportunidade(Opportunity oportunidade){
        boOpportunity.atualizaOportunidade(oportunidade);
    }
}