/**
 * Atualiza Id arquivo MCE nos objetos correspondentes
 *
 **/
public class AtualizarDadosArquivosEcmFacade {

    public static final String tipoBoleto       = 'Boleto'; 
    public static final String tipoContrato     = 'Contrato'; 
    public static final String tipoAnexoFatura  = 'Anexo Fatura'; 

    private static final AtualizarDadosArquivosEcmFacade classInstance;

    static {
        classInstance = new AtualizarDadosArquivosEcmFacade();
    }

    private AtualizarDadosArquivosEcmFacade() {}

    public static AtualizarDadosArquivosEcmFacade getInstance() {
        return classInstance;
    }

    public RetornoRestTO Atualizar(String payload) 
    {
        RetornoRestTO retorno;

        Savepoint sp = Database.setSavepoint();
        ServiceTO.PayloadDadosEcmTO objPayload;
        Boolean success = false;
        List<DadosUpdate> dadosUpdateContrato = new List<DadosUpdate>();
        List<DadosUpdate> dadosUpdateFatura = new List<DadosUpdate>();

        try {

            // Parser do Payload
            objPayload = (ServiceTO.PayloadDadosEcmTO) JSON.deserialize(payload, ServiceTO.PayloadDadosEcmTO.class);

            for (ServiceTO.DetalheDadosEcmTO payloadParametros : objPayload.dados) {

                DadosUpdate dadosUpdate = new DadosUpdate();

                if(payloadParametros.tipoarquivo == tipoBoleto)
                {
                    dadosUpdate.tipo     = tipoBoleto;
                    dadosUpdate.codigo   = payloadParametros.codfatura;
                    dadosUpdate.idarquivo = payloadParametros.idarquivo;
                    dadosUpdateFatura.add(dadosUpdate);                        
                }
                else if(payloadParametros.tipoarquivo == tipoAnexoFatura)
                {
                    dadosUpdate.tipo     = tipoAnexoFatura;
                    dadosUpdate.codigo   = payloadParametros.codfatura;
                    dadosUpdate.idarquivo = payloadParametros.idarquivo;
                    dadosUpdateFatura.add(dadosUpdate);                        
                }
                if(payloadParametros.tipoarquivo == tipoContrato)
                {
                    dadosUpdate.tipo     = tipoContrato;
                    dadosUpdate.codigo   = payloadParametros.codcontrato;
                    dadosUpdate.idarquivo = payloadParametros.idarquivo;
                    dadosUpdateContrato.add(dadosUpdate);
                }                        
            }

            if(dadosUpdateFatura != null)
            {
                executaAtualizacaoFatura(dadosUpdateFatura);
            }

            if(dadosUpdateContrato != null)
            {
                executaAtualizacaoContrato(dadosUpdateContrato);                
            }


        }
        catch(Exception e) {
            throw new AtualizarIdECMArquivosException(e.getLineNumber() + ': ' + e);
        }
        finally {
                System.debug('');
                System.debug('========================================================================');
                System.debug('::: JSON Payload');
                System.debug(JSON.serialize(objPayload));
                System.debug('========================================================================');
        }


        System.debug('');
        System.debug('========================================================================');
        System.debug('::: JSON Retorno');
        System.debug('::: ' + JSON.serialize(retorno, true));
        System.debug('========================================================================');

        return retorno;
    }


    private void executaAtualizacaoFatura(List<DadosUpdate> dadosUpdateFatura)
    {
        List<String> codigo = new List<String>();
        List<Fatura__c> lstUpdatesFatura = new List<Fatura__c>();
        Map<String, Fatura__c> mapFaturas = new Map<String, Fatura__c>();

        //--- monta cheves de busca
        for(DadosUpdate parametro : dadosUpdateFatura)
        {
            codigo.add(parametro.codigo);
        }

        //--- busca faturas para algeração
        for(Fatura__c obj : FaturaDAO.getInstance().buscarFaturasPorCodigo(codigo))
        {
            mapFaturas.put(obj.Name, obj);
        }

        //---  monta atualização
        for(DadosUpdate parametro : dadosUpdateFatura)
        {
            if(mapFaturas.containsKey(parametro.codigo))
            {
                Fatura__c obj = mapFaturas.get(parametro.codigo);

                Fatura__c faturaUpd = new Fatura__c();

                faturaUpd.Id = obj.Id;
                
                if(parametro.tipo == tipoBoleto)
                    faturaUpd.CodigoBoleto__c = parametro.idarquivo;
                else
                    faturaUpd.CodigoAnexoFatura__c = parametro.idarquivo;

                lstUpdatesFatura.add(faturaUpd);
            }

        }

        update lstUpdatesFatura;

    }

    private void executaAtualizacaoContrato(List<DadosUpdate> dadosUpdateContrato)
    {
        List<String> codigo = new List<String>();
        List<Contract> lstUpdatesContrato = new List<Contract>();
        Map<String, Contract> mapContratos = new Map<String, Contract>();

        //--- monta cheves de busca
        for(DadosUpdate parametro : dadosUpdateContrato)
        {
            codigo.add(parametro.codigo);
        }

        //--- busca faturas para algeração
        for(Contract obj : ContractDAO.getInstance().buscarContratosPorCodigo(codigo))
        {
            mapContratos.put(obj.Name, obj);
        }

        //---  monta atualização
        for(DadosUpdate parametro : dadosUpdateContrato)
        {
            if(mapContratos.containsKey(parametro.codigo))
            {
                Contract obj = mapContratos.get(parametro.codigo);

                Contract contratoUpd = new Contract();

                contratoUpd.Id = obj.Id;                
                contratoUpd.CodigoAnexoContrato__c = parametro.idarquivo;

                lstUpdatesContrato.add(contratoUpd);
            }

        }

        update lstUpdatescontrato;

    }



    private class DadosUpdate
    {
        public String  codigo  { get; set; }
        public String  tipo    { get; set; }
        public String  idarquivo  { get; set; }
    }

    public class AtualizarIdECMArquivosException extends Exception {}
}