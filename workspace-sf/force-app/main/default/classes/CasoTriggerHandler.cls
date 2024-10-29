public class CasoTriggerHandler extends TriggerHandler {
    private static CasoBO bo = CasoBO.getInstance();
    public static Boolean isFirstTime = true;
    public static Boolean beneCriado = false;
    
    public override void beforeInsert(){
        //bo.validaProposta(trigger.new);
        bo.preencherDataLimite(trigger.new,null);
        bo.validaDuplicidade(trigger.new,null);
        bo.PreencheCorretorCaso(trigger.new);
    }
    
    public override void beforeUpdate() {
        bo.preencheContratonoCaso(trigger.new, (Map<Id,Case>)trigger.oldMap);
        //bo.validaGarantiaNoCaso(trigger.new);
        //bo.validarCasoFilhoAutomatico(trigger.new);
        bo.preencherDataLimite(trigger.new,(Map<Id,Case>)trigger.oldMap);
        bo.PreencheCorretorCaso(trigger.new);
        bo.validaDuplicidade(trigger.new,(Map<Id,Case>)trigger.oldMap);
        //bo.validaProposta(trigger.new); // remover quando terminar, só acontece no insert
        //remover depois de testar 
        bo.atualizaStatusIntegracao(trigger.new, (Map<Id,Case>)trigger.oldMap);
        bo.obrigarPreenchimentoAssistCard(Trigger.new, (Map<Id,Case>)Trigger.oldMap); //LECVP-317 - INICIO / FIM
        //PLV-4009 - Codigo removido
    }
    
    // PLV-2015 - FIX - INICIO
    public override void afterInsert(){
        System.debug('afterInsert');
        //PLV-4516 INICIO
        // bo.enviarSinistroEmRegulacaoODM(Trigger.new, (Map<Id,Case>) Trigger.oldMap); //MGRC-1657 - INICIO/FIM
        //PLV-4516 FIM
        //PLV-4096 - Inicio
        //bo.chamaEnvioSinistroBCP(Trigger.new, null);
        //PLV-4096 - Fim	
        
        //PLV-3918 inicio
        bo.criarPagamentoSinistro(Trigger.new);	
        //PLV-3918 Fim

        
        bo.integracaoCivSinistro(Trigger.new, (Map<Id,Case>) Trigger.oldMap); //PLV-4826 - Inicio/Fim
    }
    // PLV-2015 - FIM
    
    
    public override void afterUpdate(){
        
        //PLV-4535 - FIX 6 INICIO
        if(isFirstTime){	
            // bo.gerarMovimentoJuridico(trigger.new, (Map<Id,Case>)trigger.oldMap); // POR062-1 INICIO/FIM /* Obs: Remover essa linha */
            
            //PLV-4516 INICIO
            // bo.enviarSinistroEmRegulacaoODM(Trigger.new, (Map<Id,Case>) Trigger.oldMap); //MGRC-1657 - INICIO/FIM
            //PLV-4516 FIM
            //bo.criarCasosFilhos(trigger.new); 
            //bo.preencherBeneficiarioSinistro(trigger.new, (Map<Id,Case>)trigger.oldMap);
            //bo.recuperanumerosorte(trigger.new);
            //LECVP-318 - INICIO
            if(!System.isBatch()){
                bo.criarRegistrosFilhosSinistro(Trigger.new, (Map<Id,Case>) Trigger.oldMap);
            }
            //LECVP-318 - FIM
            bo.atualizaAvisadoMovimentoSinistro(Trigger.new, (Map<Id,Case>) Trigger.oldMap);
            bo.atualizaRecusadoMovimentoSinistro(Trigger.new, (Map<Id,Case>) Trigger.oldMap);
            
            //PLV-4096 - Inicio
            //PLV-4096 - inicio fix
            bo.integracaoCivSinistro(Trigger.new, (Map<Id,Case>) Trigger.oldMap);
            //PLV-4096 - Fim
            //PLV-4096 - fim fix
            
            //PLV-2433 - Erro - Numeração de Sinistro/Benefício
            //PLV-4096 - Inicio
            bo.preenchenumsinistro(Trigger.new, (Map<Id,Case>) Trigger.oldMap);  // POR062-1 - INICIO | FIM
            //PLV-4096 - Fim
            
            //PLV-4096 Inicio
            //bo.chamaEnvioSinistroBCP(Trigger.new, (Map<Id,Case>) Trigger.oldMap); // PLV-2015 - FIX
            //PLV-4096 - Fim
            
            //PLV-3918 - Inicio
            //PLV-3918 Alteração para chamar a CriarPagamentoSinistro No avisado - Inicio
            //bo.inserirPagamentoSinistroBO(Trigger.new, (Map<Id,Case>) Trigger.oldMap);
            //PLV-3918 Alteração para chamar a CriarPagamentoSinistro No avisado - Fim
            //PLV-3918 - Fim
            
            //PLV-4198 - Inicio
            bo.fecharGarantiaBeneficiario(Trigger.new, (Map<Id,Case>) Trigger.oldMap);
            //PLV-4198 - Fim
            
            //PLV-3916 - inicio fix
            //FIX 6 Mudado para Workflow
            //bo.enviaAvisoSinistro(Trigger.new, (Map<Id,Case>) Trigger.oldMap);
            //PLV-3916 - Fim 
            
            
            
            
            //PLV-4632 - INICIO
            system.debug('chama carta recusa');
            GeraCartaRecusa.validarCartaRecusa(Trigger.new);
            //PLV-4632 - FIM
            
            
            //PLV-4560 - Inicio
            if(!beneCriado){
                bo.preencherBeneficiariosSinistro2(Trigger.new);
            }
            //PLV-4560 - Fim
            
            //PLV-4707 - Inicio
            bo.realizarEndossoAutomatico(Trigger.new, (Map<Id,Case>) Trigger.oldMap);
            //PLV-4707 - Fim
            bo.atualizaPrazoSusep(Trigger.new, (Map<Id,Case>) Trigger.oldMap);//PLV-4535 - FIX 6 INICIO/FIM
            bo.obrigarPreenchimentoAssistCard(Trigger.new, (Map<Id,Case>)Trigger.oldMap); //LECVP-317 - INICIO / FIM
            isFirstTime = false;
        }
        //PLV-4535 - FIX 6 INICIO
        
    } 
}