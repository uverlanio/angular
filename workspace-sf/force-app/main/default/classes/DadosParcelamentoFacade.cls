public class DadosParcelamentoFacade
{
    private final String	PESSOA_FISICA	= 'FIS';
    private final String	PESSOA_JURIDICA	= 'JUR';

    private static final DadosParcelamentoFacade classInstance;
    static { classInstance = new DadosParcelamentoFacade(); }
    private DadosParcelamentoFacade() {}
    public static DadosParcelamentoFacade getInstance() { return classInstance; }

    private static AccountBO contaBo = AccountBO.getInstance();
    // 2610 - INICIO
    public void parseDadosParcelamentocontratanteProposta(EmissaoTO proposta, EmissaoTO.ContratanteTO contratanteTO, Map<String, Account> mapContas, Map<String, FormaPagamento__c> mapFormasPgto, Map<String, PlanoParcelamento__c> mapPlanoParcelamento, contratanteProposta__c contratante, Parceiro__c parceiro, Account contaParceiro, String meioComercializacao)
    {
        Account             responsavelPGTO;
        FormaPagamento__c   formaPGTO;
        
        System.debug('4588>> contratanteTO: ' + JSON.serialize(contratanteTO));
        System.debug('4588>> contratante: ' + JSON.serialize(contratante));
        
        System.debug('4588>> proposta: ' + JSON.serialize(proposta));

        if(contratanteTO.dadosPagamento != null){
            if(contratanteTO.dadosPagamento.formaPagamento != null && contratanteTO.dadosPagamento.formaPagamento.codigo != null)
            {
                formaPGTO = mapFormasPgto.get(String.valueOf(contratanteTO.dadosPagamento.formaPagamento.codigo));

                if(formaPGTO == null)
                    throw new PropostaException('Forma de pagamento não encontrada. [parametro: ' + String.valueOf(contratanteTO.dadosPagamento.formaPagamento.codigo)+']');
                System.debug('4588>>1 ');
                contratante.FormaPagamento__c = formaPGTO.Id;

                //PlanoParcelamento__c plano = mapPlanoParcelamento.get(contratanteTO.dadosPagamento.descricaoPlanoParcelamento);
            }
        }
     
        System.debug('Verifica o meio de comercializacao ------------------');
        System.debug('meioComercializacao ---------------- ' + meioComercializacao);
        responsavelPGTO = contaParceiro;
       

        System.debug('responsavelPGTO --------------------------- ' + responsavelPGTO);
        System.debug('test1612-7');
        if(contratanteTO.dadosPagamento != null){

            contratante.ResponsavelPagamento__c        = responsavelPGTO.Id;
            contratante.QuantidadeParcelas__c          = Integer.valueof(contratanteTO.dadosPagamento.quantidadeParcelas);
            contratante.VencimentoPrimeiraParcela__c   = date.ValueOf(contratanteTO.dadosPagamento.vencimentoPrimeiraParcela);
            contratante.EnderecoBoleto__c              = contratanteTO.dadosPagamento.boleto;

         
        }


        if(contratanteTO.dadosPagamento != null){

            if(contratanteTO.dadosPagamento.tipoResponsavelPagamento == null)
            {
                system.debug('tipo responsavel pgto: ' + contratanteTO.dadosPagamento.tipoResponsavelPagamento);
                throw new PropostaException('tipo responsavel pagamento contratante não encontrado. ' + contratanteTO.dadosPagamento.tipoResponsavelPagamento);
            }

            contratante.tipoResponsavelPagamento__c    = contratanteTO.dadosPagamento.tipoResponsavelPagamento;

        }

        // }
    }

    /*---- rotina não utilizada
    public void parseDadosParcelamentoSeguradoProposta(EmissaoTO proposta, EmissaoTO.SeguradoTO seguradoTO, Map<String, Account> mapContas, Map<String, FormaPagamento__c> mapFormasPgto, Map<String, PlanoParcelamento__c> mapPlanoParcelamento, SeguradoProposta__c contratante, Parceiro__c parceiro, Account contaParceiro, String meioComercializacao)
    {
        Account             responsavelPGTO;
        FormaPagamento__c   formaPGTO;

        if(seguradoTO.dadosPagamento != null){
            if(seguradoTO.dadosPagamento.codigoFormaPagamento != null)
            {
                formaPGTO = mapFormasPgto.get(String.valueOf(seguradoTO.dadosPagamento.codigoFormaPagamento));

                if(formaPGTO == null)
                    throw new PropostaException('Forma de pagamento não encontrada. [parametro: ' + String.valueOf(seguradoTO.dadosPagamento.codigoFormaPagamento)+']');

                contratante.FormaPagamento__c = formaPGTO.Id;

                PlanoParcelamento__c plano = mapPlanoParcelamento.get(seguradoTO.dadosPagamento.descricaoPlanoParcelamento);
            }
        }
    
        System.debug('Verifica o meio de comercializacao ------------------');
        System.debug('meioComercializacao ---------------- ' + meioComercializacao);
        responsavelPGTO = contaParceiro;


        System.debug('responsavelPGTO --------------------------- ' + responsavelPGTO);

        if(seguradoTO.dadosPagamento != null){

            contratante.ResponsavelPagamento__c        = responsavelPGTO.Id;
            contratante.QuantidadeParcelas__c          = Integer.valueof(seguradoTO.dadosPagamento.quantidadeParcelas);
            contratante.VencimentoPrimeiraParcela__c   = date.ValueOf(seguradoTO.dadosPagamento.vencimentoPrimeiraParcela);
            contratante.EnderecoBoleto__c              = seguradoTO.dadosPagamento.boleto;
        }


        if(seguradoTO.dadosPagamento != null){

            if(seguradoTO.dadosPagamento.tipoResponsavelPagamento == null)
            {
                system.debug('tipo responsavel pgto: ' + seguradoTO.dadosPagamento.tipoResponsavelPagamento);
                throw new PropostaException('tipo responsavel pagamento contratante não encontrado. ' + seguradoTO.dadosPagamento.tipoResponsavelPagamento);
            }

            contratante.tipoResponsavelPagamento__c    = seguradoTO.dadosPagamento.tipoResponsavelPagamento;

        }

        // }
    }
    ----*/

    public void parseDadosParcelamentoSeguradoProposta(EmissaoTO proposta, EmissaoTO.ContratanteTO contratante, EmissaoTO.SeguradoTO SeguradoTO,
     Map<String, Account> mapContas, Map<String, FormaPagamento__c> mapFormasPgto, Map<String, PlanoParcelamento__c> mapPlanoParcelamento, 
     SeguradoProposta__c segurado, Parceiro__c parceiro, Account contaParceiro, String meioComercializacao)
    {
        Account             responsavelPGTO;
        FormaPagamento__c   formaPGTO;
        PlanoParcelamento__c plano;

        if(SeguradoTO.dadosPagamento != null)
        {   
            
            if(SeguradoTO.dadosPagamento.formaPagamento.codigo != null)
            {
                formaPGTO = mapFormasPgto.get(String.valueOf(SeguradoTO.dadosPagamento.formaPagamento.codigo));

                if(formaPGTO == null)
                    throw new PropostaException('Forma de pagamento não encontrada. [parametro: ' + String.valueOf(SeguradoTO.dadosPagamento.formaPagamento.codigo)+']');

                segurado.FormaPagamento__c = formaPGTO.Id;
            }
            
            else
            {
                segurado.FormaPagamento__c = parceiro.FormaPagamento__c;

                if(parceiro.FormaPagamento__r == null)
                    throw new PropostaException('Forma de pagamento não encontrada.');
            }

            //plano = mapPlanoParcelamento.get(SeguradoTO.dadosPagamento.descricaoPlanoParcelamento);
            // if(plano == null)
            //     throw new PropostaException('plano parcelamento não encontrado. [parametro: ' + SeguradoTO.dadosPagamento.descricaoPlanoParcelamento +']');
        }
        // 2610 - FIM

        if(meioComercializacao == 'ARQ')
        {
            responsavelPGTO = contaParceiro;
            segurado.FormaPagamento__c = parceiro.FormaPagamento__c;

            if(parceiro.FormaPagamento__r == null)
                throw new PropostaException('Forma de pagamento não encontrada.');
        }

        if(responsavelPGTO == null)
            throw new PropostaException('responsavel pagamento segurado não encontrado.');

        segurado.ResponsavelPagamento__c = responsavelPGTO.Id;

        if(SeguradoTO.dadosPagamento != null)
        {
            // segurado.PlanoParcelamento__c           = plano.id;
            segurado.QuantidadeParcelas__c          = Integer.valueof(SeguradoTO.dadosPagamento.quantidadeParcelas);
            segurado.VencimentoPrimeiraParcela__c   = date.ValueOf(SeguradoTO.dadosPagamento.vencimentoPrimeiraParcela);
            segurado.EnderecoBoleto__c              = SeguradoTO.dadosPagamento.boleto;
            segurado.tipoResponsavelPagamento__c    = SeguradoTO.dadosPagamento.tipoResponsavelPagamento;
        }
    }

    public class PropostaException extends Exception {}
}