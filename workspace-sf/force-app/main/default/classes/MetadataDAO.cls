/**************************************************************************************************************************************************************************
 *
 *	Classe responsável pelas buscas nos metadados da Organização
 *
 **************************************************************************************************************************************************************************/
public class MetadataDAO {
    private static final MetadataDAO instance = new MetadataDAO();

    private MetadataDAO() {
    }

    public static MetadataDAO getInstance() {
        return instance;
    }

    /**
     * Realiza listagem dos registros do metadado de Continente
     *
     */
    public List<Continente__mdt> listarContinentes() {
        return [
            SELECT
                Id,
                DeveloperName,
                MasterLabel
            FROM
                Continente__mdt
            ORDER BY
                DeveloperName
        ];
    }

    /**
     * Realiza listagem dos registros do metadado de Pais
     *
     */
    public List<Pais_OLD__mdt> listarPaises() {
        return [
            SELECT
                Id,
                DeveloperName,
                MasterLabel,
                Continente__r.MasterLabel
            FROM
                Pais_OLD__mdt
            ORDER BY
                DeveloperName
        ];
    }

    /**
     * Realiza busca dos registros de paises de acordo com um continente
     *
     * @param  	continente  - nome do continente a ser usado como parametro
     */
    public List<Pais_OLD__mdt> buscarPaises(String continente) {
        return [
            SELECT
                Id,
                DeveloperName,
                MasterLabel
            FROM
                Pais_OLD__mdt
            WHERE
                Continente__r.MasterLabel =: continente
            ORDER BY
                DeveloperName
        ];
    }

    /**
     * Realiza a busca no metadados de Serviço
     *
     * @param  	nomeServico  - nome do serviço a ser buscado
     */
    public Servico__mdt buscarServico(String nomeServico) {
        return [
            SELECT
                NomeCredencial__c,
                NomeToken__c,
                Endpoint__c
            FROM
                Servico__mdt
            WHERE
                DeveloperName =: nomeServico
            LIMIT 1
        ];
    }

    /**
     * Realiza a busca no metadados de Critérios de Integração
     *
     * @param  	nomeCriterio
     */
    public List<CriterioIntegracao__mdt> buscarCriterio(String nomeObjecto) {
        return [
            SELECT
                CodigoIntegracao__c,
                Criterio__c,
                NomeObjeto__c
            FROM
                CriterioIntegracao__mdt
            WHERE
                NomeObjeto__c =: nomeObjecto
        ];
    }


    /**
     * Realiza a busca na configuração personaliza e Contador de código
     *
     * @param  	nome  - nome do contador
     */
    public ContadorCodigo__c buscarContadorCodigo(String nome) {
        system.debug('Name MetadataDAO: '+nome);
        return [
            SELECT
                Id,
                Numero__c
            FROM
                ContadorCodigo__c
            WHERE
                Name =: nome
            LIMIT 1
        ];
    }

    /**
     * Realiza listagem dos registros do metadado de Serviços papel
     *
     */
    public List<ServicoPapel__mdt> buscarServicosPapel(){
        return [
            SELECT
                Id,
                MasterLabel,
                Papel__r.MasterLabel
            FROM
                ServicoPapel__mdt
        ];
    }


    /**
     * Realiza busca de um registro de metadado de Field set de orçamento
     *
     */
    public List<FieldSetOrcamento__mdt> buscarFieldSetOrcamento(String codigoProduto, String objeto){
        return [
            SELECT
                Id,
                MasterLabel,
                FieldSet__c
            FROM
                FieldSetOrcamento__mdt
            Where
            CodigoProduto__c = :codigoProduto
            And Objeto__c = :objeto
        ];
    }

    /**
	 * Realiza busca de um registro de metadado de conversao
	 *
	 */
    public List<Conversao__mdt> buscarFieldSetConversao(String nomeCampo, String nomeObjeto, String valorInterno){
        return [
            SELECT
                Area__c,
                NomeCampo__c,
                Objeto__c,
                ValorExterno__c,
                ValorInterno__c
            FROM
                Conversao__mdt
            WHERE
            NomeCampo__c =: nomeCampo
            AND Objeto__c =: nomeObjeto
            AND ValorInterno__c =: valorInterno
        ];
    }

    /**
	 * Realiza busca de um registro de metadado de conversao
	 *
	 */
    public List<Conversao__mdt> buscarFieldSetConversaoExterno(String nomeCampo, String nomeObjeto){
        return [
            SELECT
                Area__c,
                NomeCampo__c,
                Objeto__c,
                ValorExterno__c,
                ValorInterno__c
            FROM
                Conversao__mdt
            WHERE
            NomeCampo__c =: nomeCampo
            AND Objeto__c =: nomeObjeto
        ];
    }

    /**
	 * Realiza busca de um registro de metadado de constantes
	 *
	 */
    public List<Constante__mdt> buscarConstantes(Set<String> setAtributos){
        return [
            SELECT
                Valor__c,
                Area__c,
                Atributo__c
            FROM
                Constante__mdt
            WHERE Atributo__c =: setAtributos
        ];
    }

   /**
     * Realiza busca de um registro de metadado de Empresas PortoCAP
     *
     */
    public EmpresaPortoCAP__mdt buscarEmpresaPortoCap(){
        return [
            SELECT
                NomeEmpresa__c,
                CNPJ__c
            FROM
                EmpresaPortoCAP__mdt
            LIMIT 1
        ];
    }


    /**
     * Realiza a busca no metadados de Serviço
     *
     * @param   nomeCredencial  - nome do serviço a ser buscado
     */
    public CredencialOAuth2__mdt buscarCredencial(String nomeCredencial) {
        return [
            SELECT
                Audience__c,
                ClientId__c,
                ClientSecret__c,
                GrantType__c,
                Username__c, //ANNVI-208 - INICIO
                Password__c, //ANNVI-208 - FIM
                Status__c
            FROM
                CredencialOAuth2__mdt
            WHERE
                DeveloperName =: nomeCredencial
            LIMIT 1
        ];
    }

    /**
     * Realiza busca de um registro de metadado de constantes
     *
     */
    public List<Constante__mdt> buscarConstante(String nameConstante){
        return [
            SELECT
                Valor__c
            FROM
                Constante__mdt
            WHERE DeveloperName =: nameConstante
        ];
    }

    //PLV-4179 - INICIO
    //Realiza listagem dos registros do metadado da Integracao AS    
    public IntegracaoAS__mdt buscarDadosIntegracaoAS(String taskNumber){
        IntegracaoAS__mdt response = null;

        // TODO CLASSE DE TESTE

        try {
            response = [
                SELECT
                    NomeCredencial__c,
                    NomeToken__c,
                    Endpoint__c,
                    Tarefa__c,
                    Setor__c,
                    Unidade__c
                FROM
                    IntegracaoAS__mdt
                WHERE Tarefa__c =: taskNumber
                LIMIT 1
            ];
        } catch (Exception e) {
            System.debug(e);
        }

        return response;
    }
    //PLV-4179 - FIM

    //PLV-4875 INICIO
    public Map<String, IntegracaoAS__mdt> buscarDadosIntegracaoAS(List<String> taskNumber){
        List<IntegracaoAS__mdt> lstIntegracaoMdt = [
            SELECT
                NomeCredencial__c,
                NomeToken__c,
                Endpoint__c,
                Tarefa__c,
                Setor__c,
                Unidade__c
            FROM
                IntegracaoAS__mdt
            WHERE Tarefa__c IN: taskNumber
        ];

        Map<String, IntegracaoAS__mdt> response = new  Map<String, IntegracaoAS__mdt>();

        for(IntegracaoAS__mdt i : lstIntegracaoMdt) response.put(i.Tarefa__c, i);

        return response;
    }
    //PLV-4875 FIM

    //PLV-5230 -INICIO
    public List<Integracao_OPIN_Depara__mdt> buscarDeparaOpin(string rotulo, string de){
        List<Integracao_OPIN_Depara__mdt> Integracao_OPIN_DeparaMdt = [
            SELECT
                Para__c		
            FROM
                Integracao_OPIN_Depara__mdt
            WHERE De__c	 =: de AND MasterLabel =: rotulo
        ];

        return Integracao_OPIN_DeparaMdt;
    }
    
    public List<Integracao_OPIN_Depara__mdt> buscarDeparaOpinTodos(string rotulo){
         List<Integracao_OPIN_Depara__mdt> Integracao_OPIN_DeparaMdt = [
            SELECT
                Para__c	
            FROM
                Integracao_OPIN_Depara__mdt
            WHERE MasterLabel =: rotulo
        ];

        return Integracao_OPIN_DeparaMdt; 
    }
    //PLV-5230 -FIM

    //PLV-5133 - INICIO
    public TipoDeEndosso__mdt buscarTipoEndosso(String siglaEndosso){
        return [
            SELECT
                Id, 
                FrasePadrao__c
            FROM
                TipoDeEndosso__mdt
            WHERE DeveloperName =: siglaEndosso
            LIMIT 1
        ];
    }
    //PLV-5133 - FIM

    //TKCL-263 - INICIO
    public API_Link_de_Pagamento__mdt apiLinkDePgto(String name){//RVI-294
        return [ 
            SELECT 
                Id,
                client_id__c,
                secret_id__c,
                token_url__c,
                endpoint__c,
                timeOut__c,
                expiraEm__c
            FROM 
                API_Link_de_Pagamento__mdt 
            WHERE DeveloperName =: name //RVI-294
            LIMIT 1
        ];
    }
    //TKCL-263 - FIM

    //LECVP-72 - INICIO
    public BCP_BatchSchedulerConfig__mdt bcpBatchSchedulerConfig(){
        return [
            SELECT 
                Id,
                Ativo__c,
                BCP_DataHoraInicio__c,
                BCP_DataHoraFim__c, 
                BCP_Frequencia_h__c,
                BCP_NomeBatch__c
            FROM
                BCP_BatchSchedulerConfig__mdt
            LIMIT 1
        ];
    }
    //LECVP-72 - FIM

    //RVI-240 - INICIO
    public Boolean existsInMetadata(String segmento, String codProdVida, Integer codEmpresa){
        Boolean exist = false;
        List<recorrenciaCobranca__mdt> recorrencias = [SELECT Id, codEmpresa__c, codProduto__c, segmentoProduto__c 
                                                       FROM recorrenciaCobranca__mdt
                                                       WHERE segmentoProduto__c =:segmento
                                                       AND codProduto__c =:codProdVida
                                                       AND codEmpresa__c =: codEmpresa];

        exist = recorrencias.size() > 0 ?  true : exist;

        return exist;
    }
    //RVI-240 - FIM
    //LECVP-318 - INICIO
    public ConfigHoraExecBatch__mdt configHoraExecBatch(){
        return [
            SELECT 
                Id,
                horaExecucao__c,
                Ativo__c
            FROM
                ConfigHoraExecBatch__mdt
            LIMIT 1
        ];
    }
    //LECVP-318 - FIM
}