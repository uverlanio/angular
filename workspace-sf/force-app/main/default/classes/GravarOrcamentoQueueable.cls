/**************************************************************************************************
 * 
 * Classe queueable responsavel pela gravação dos dados do Orçamento no Salesforce
 *
 *************************************************************************************************** */
//PLV-3649 - INICIO - Performance - Gravar Orçamentos
public class GravarOrcamentoQueueable implements Queueable{

    private EmissaoTO.OfertasTO ofertaTO;
    private OrcamentoGenericoBuilder orcamentoGenerico; //PLV-3649-FIX2 - INICIO/FIM - Ajuste na construcao da classe
    
    //Construtor
    public GravarOrcamentoQueueable(EmissaoTO.OfertasTO ofertaEntrada){
        this.ofertaTO = ofertaEntrada;
        this.orcamentoGenerico = new OrcamentoGenericoBuilder(false); //PLV-3649-FIX2 - INICIO/FIM - Ajuste na construcao da classe
    }

    public void execute(QueueableContext context){
        system.debug(LoggingLevel.FINEST,'this.ofertaTO:::'+ JSON.serialize(this.ofertaTO));
        this.orcamentoGenerico.gravarOrcamentoCIV(this.ofertaTO);
    }
}
//PLV-3649 - FIM - Performance - Gravar Orçamentos