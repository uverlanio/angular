/**
 * @description       : atualizarSLAProposta
 * @author            : giordano.menezes@globant.com
 * @group             : 
 * @last modified on  : 02-07-2023
 * @last modified by  : giordano.menezes@globant.com
**/
public class QuoteTriggerHandler extends TriggerHandler {
	// public static Boolean isFirstTime = true; //PLV - 4694 INICIO/FIM // PLV-4694 - FIX
	private static QuoteBO objBO = QuoteBO.getInstance();
	public static Boolean isAPI {get;set;}//PLV-5022 - INICIO/FIM
//PLV_3134 - INICIO - Integração de Normas

private static GravarPropostaControleIntegracao ObjGPC = GravarPropostaControleIntegracao.getInstance();

public static Boolean bypassGerarPDF = false;// PLV-4544 INICIO/FIM

//PLV_3134 - FIM - Integração de Normas

public static Boolean sendEmail = false;//II-106 INICIO-FIM

public static Boolean sendEmailVou = false; //MGRC-505-FIX INICO/FIM

// public override void beforeInsert() {
// //	objBO.validarProdutoProposta(Trigger.new);

// 	objBO.validarPropostaJaIncluida(trigger.new);
// }

public override void beforeUpdate() {
	//PLV-5022 - INICIO
	for(Quote proposta: (List<Quote>)Trigger.new){
		isAPI = isAPI== true ? isAPI : proposta.isAPI__c==null ? false : proposta.isAPI__c;
		proposta.isAPI__c = false;
	}
	//PLV-5022 - FIM
//	objBO.validarProdutoProposta(Trigger.new);
	//PLV-2932 - Inicio - Chamada de metodo para atualizar a data emissao
	objBO.atualizarDataEmissao(Trigger.new); //RVI-160 - INICIO/FIM
	//PLV-2932 - Fim - Chamada de metodo para atualizar a data emissao
	//PLV-4871 - INICIO
	objBO.atualizarVigencia(trigger.new, (Map<Id, Quote>)trigger.oldMap);
	//PLV-4871 - FIM
	//PLV-4589 - INICIO
	objBO.atualizarSLAProposta(trigger.new, (Map<Id, Quote>)trigger.oldMap);
	//PLV-4589 - FIM
	//PLV-4495 - INICIO
	CriticaPropostaStatus.automacaoProposta(trigger.new, (Map<Id, Quote>)trigger.oldMap);
	//PLV-4495 - FIM			
	
	//PLV-4667 INICIO
	//objBO.integrarNaoClienteBCP(trigger.new);//PLV-5022 - INICIO/FIM MGRC-504 - INICIO-FIM
	//PLV-4667 FIM

	//DataStatusProposta.dataStatus(trigger.new, (Map<Id, Quote>)trigger.oldMap);
	objBO.limparCamposReemissao(Trigger.new);//FCVEP-39 - INICIO / FIM
} 

public override void afterUpdate() 
{
    // VIAG-166 INICIO
	// objBO.validarStatusProposta(trigger.new); //LECVP-140 INICIO/FIM
	// VIAG-166 FIM
	//PLV-5022 - INICIO
	for(Quote proposta: (List<Quote>)Trigger.new){
		isAPI = isAPI== true ? isAPI : proposta.isAPI__c==null ? false : proposta.isAPI__c;
	}
	//PLV-5022 - FIM
	//PLV - 4694 INICIO
	// if(isFirstTime){ // PLV-4694 - FIX
		// isFirstTime = false; // PLV-4694 - FIX
	objBO.validarPercentualBeneficiarios(trigger.new);
	System.debug(LoggingLevel.ERROR, 'Log>>>CriacaoContrato');
	objBO.processarCriacaoContrato(trigger.new, (Map<Id, Quote>)trigger.oldMap);
	// PLV-2939 INICIO
	objBO.criarVoucher(Trigger.new);
	// PLV-2939 FIM
	
	//PLV_3134 - INICIO - Integração de Normas
	ObjGPC.inserirRegistroControleIntegracao(trigger.new);
	//PLV_3134 - FIM - Integração de Normas
	//PLV-4179 - INICIO
	//PLV-5022 - INICIO
	if(isAPI!=true){
		System.debug(LoggingLevel.ERROR, 'CHAMANDO API - IS API !=TRUE POR ALGUM MOTIVO');
		objBO.salvarIntegracaoAS(trigger.new, (Map<Id, Quote>)trigger.oldMap);
	 //	objBO.integrarNaoClienteBCP(trigger.new); MGRC-504 - INICIO-FIM
	}
	//PLV-5022 - FIM
	//PLV-4179 - FIM
	// PLV-4570 INICIO
	QuoteBO.callGerarPDFProposta(trigger.new, (Map<Id, Quote>)trigger.oldMap, bypassGerarPDF);// PLV-4544 inicio/fim
	// PLV-4570 FIM		
	// }// PLV-4694 - FIX
	//PLV - 4694 FIM
	// VIAG-166 INICIO
	// objBO.validarStatusProposta(trigger.new); //LECVP-140 INICIO/FIM
	// VIAG-166 FIM
	//objBO.sendEmailRecusaProposta(Trigger.new, (Map<Id, Quote>)trigger.oldMap); //PLV-4980 INICIO/FIM //II-106 INICIO-FIM
	//II-106 INICIO
	if(!sendEmail){
		objBO.sendEmailPropostaRecusada(Trigger.new, (Map<Id, Quote>)trigger.oldMap);
	}
	//II-106 FIM
	isAPI = false;//PLV-5022 - INICIO/FIM

	//PLV-5436 - INICIO
	DataStatusProposta.dataStatus(trigger.new, (Map<Id, Quote>)trigger.oldMap);

	//PLV-5436 - FIM

	//DataStatusProposta.AtualizaCampoDataFase(trigger.new, (Map<Id, CriticaProposta__c>)trigger.oldMap);
	//MGRC-505-FIX INICIO
	if(sendEmailVou== true){ //
		System.debug('sendEmailVou == true');
 		VoucherEmailControllerNew.SendEmailVoucher(trigger.new, (Map<Id, Quote>)trigger.oldMap);
	}
     //MGRC-505-FIX FIM
}

public override void afterInsert() 
{
	//PLV-4179 - INICIO
	objBO.salvarIntegracaoAS(trigger.new, (Map<Id, Quote>)trigger.oldMap);
	//PLV-4179 - FIM
		
	objBO.processarCriacaoContrato(trigger.new, (Map<Id, Quote>)trigger.oldMap);
	
	//AV-824 - INICIO
	objBO.getGarantiasOportunity(trigger.new);
	//AV-824 - FIM
	
}

//PLV-4337 - INÍCIO
public override void beforeInsert() {

	if ( Test.isRunningTest() ) { objBO.atualizarDataVencimento( Trigger.new ); } // Mantendo ativado apenas para teste
	//PLV-4589 - INICIO
	objBO.atualizarSLAProposta(trigger.new, (Map<Id, Quote>)trigger.oldMap);
	//PLV-4589 - FIM
}
//PLV-4337 - FIM
}