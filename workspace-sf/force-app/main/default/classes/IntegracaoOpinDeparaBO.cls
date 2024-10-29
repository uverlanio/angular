//PLV-5230 - INICIO
public class IntegracaoOpinDeparaBO {

    //Resolve dependências
    private static final MetadataDAO matadataDao = MetadataDAO.getInstance();

    //Implementa Factory
    private static final IntegracaoOpinDeparaBO instance = new IntegracaoOpinDeparaBO();
    public static IntegracaoOpinDeparaBO getInstance() {
		return instance;
	}

    private List<String> deparasNaoEncontrados = new List<String>();
    public List<String> consultarDeparasNaoEncontrados() {
        return deparasNaoEncontrados;
    }

    public IntegracaoOpinDeparaBO() {  }

    public String consultar(String rotulo, String de) {

        List<Integracao_OPIN_Depara__mdt> lst = matadataDao.buscarDeparaOpin(rotulo, de);

        if (lst.size() > 0) {
            return lst[0].Para__c;
        }
        else {
            deparasNaoEncontrados.add('rotulo: ' + rotulo + ', de: '+ de);
            return '';
        }
    }

    public List<String> consultarLista(String rotulo, String de) {

        List<Integracao_OPIN_Depara__mdt> lst = matadataDao.buscarDeparaOpin(rotulo, de);
        if (lst.size() == 0) {
            deparasNaoEncontrados.add('rotulo: ' + rotulo + ', de: '+ de);
            return new List<String>();
        }

        List<String> lstPara = new List<String>();
        for (Integracao_OPIN_Depara__mdt depara: lst) {
            lstPara.add(depara.Para__c);
        }

        return lstPara;
    }

}
//PLV-5230 - FIM