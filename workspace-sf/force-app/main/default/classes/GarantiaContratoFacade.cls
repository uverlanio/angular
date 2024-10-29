/**
 * GarnatiaContrato Facade
 *
 **/
public class GarantiaContratoFacade {

    private static final GarantiaContratoFacade classInstance;

    static {
        classInstance = new GarantiaContratoFacade();
    }

    private GarantiaContratoFacade() {}

    public static GarantiaContratoFacade getInstance() {
        return classInstance;
    }

    public void consultarTituloPortoCap() {
    	System.debug('Inicio');

        try {

            Set<String> lstPromocoes = new Set<String>();

            // processa dados por código de promoção
            for(AggregateResult groupResultPromocao : GarantiaProdutoDAO.getInstance().buscarGarantiasProdutoPorProdutoCapByGroup())
            {
                System.debug('Montando parametro: ' + String.valueOf(groupResultPromocao.get('CodigoPromocao__c')));

                lstPromocoes.add(String.valueOf(groupResultPromocao.get('CodigoPromocao__c')));
            }

            montarParamtros(lstPromocoes);

        }
        catch(Exception e) {
            System.debug(e.getLineNumber() + ': ' + e.getMessage());
            throw new GarantiaContratoException(e.getLineNumber() + ': ' + e);
        }

        return;
    }

    private void montarParamtros(Set<String> lstPromocoes)
    {
        Map<String, dadosEnvioTO> mapParametros = new Map<String, dadosEnvioTO>();

        //--- monta dados de parametros por promoção
        for(GarantiaProduto__c objGarantiaProduto : GarantiaProdutoDAO.getInstance().buscarGarantiasProdutoPorProdutoCap(lstPromocoes))
        {
            for(GarantiaContrato__c objGarantiaContrato : objGarantiaProduto.Garantias_do_contrato__r)
            {
                if(!mapParametros.containsKey(objGarantiaProduto.CodigoPromocao__c + objGarantiaContrato.VersaoTitulo__c))
                {
                    dadosEnvioTO dadosEnvio = new dadosEnvioTO();
                    
                    dadosEnvio.codPromocao      = objGarantiaProduto.CodigoPromocao__c;
                    dadosEnvio.codVersao        = objGarantiaContrato.VersaoTitulo__c;

                    mapParametros.put(objGarantiaProduto.CodigoPromocao__c + objGarantiaContrato.VersaoTitulo__c, dadosEnvio);   
                }
            }
        }

        //--- prepara json de parametros de envio para o serviço
        Integer contador = 0;
        List<GarantiaContratoTO.DadosPortoCap> lstDadosPortoCap = new List<GarantiaContratoTO.DadosPortoCap>();

        EmpresaPortoCAP__mdt empresaPortoCap = new EmpresaPortoCAP__mdt();

        empresaPortoCap = MetadataDAO.getInstance().buscarEmpresaPortoCap();        

        for (String key : mapParametros.keySet())
        {
            dadosEnvioTO dadosEnvio = new dadosEnvioTO();
            GarantiaContratoTO.DadosPortoCap parametro = new GarantiaContratoTO.DadosPortoCap();             

            dadosEnvio = mapParametros.get(key);

            parametro.Nr_cnpj       = empresaPortoCap.CNPJ__c;
            parametro.Cd_promocao   = dadosEnvio.codPromocao;
            if(dadosEnvio.codVersao != null)
                parametro.cd_versao     = Integer.valueOf(dadosEnvio.codVersao);

            lstDadosPortoCap.add(parametro);
            contador++;            
        }

        System.debug('Executa Qeueable Principal - No. Parametros: ' + contador);
        System.enqueueJob(new QueueableProcessaPortoCap(lstDadosPortoCap));

    }

    public class dadosEnvioTO
    {
        public String codPromocao  { get; set; }
        public String codVersao { get; set; }
    }

    public class GarantiaContratoException extends Exception {}
}