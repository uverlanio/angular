/*********************************************************************************************************************************************************************
@description Classe responsavel pela busca de logs BCP no SF.
@author Uverlanio Silva - Globant
@date 23/01/2023
**********************************************************************************************************************************************************************/
//LECVP-72 - INICIO
public with sharing class BCPLogDAO {
    
    private static final BCPLogDAO instancia = new BCPLogDAO();

	private BCPLogDAO() {	
	}

	public static BCPLogDAO getInstance(){
		return instancia;
	}

    public List<BCP_Log__c> buscarLogsBCPPorIdCtr(Set<Id> idsContrato){
        List<BCP_Log__c> listaLogsBCP = 
         [
            SELECT 
                Id,
                BCP_DataHoraEnvio__c,
                BCP_Contrato__c 
            FROM 
                BCP_Log__c
            WHERE 
                BCP_Contrato__c 
            IN :idsContrato
        ];

        return listaLogsBCP;
    }

    public List<BCP_Log__c> buscarLogsBCPPorId(Set<Id> idsLog){
        List<BCP_Log__c> listaLogsBCP = 
         [
            SELECT 
                Id
            FROM 
                BCP_Log__c
            WHERE 
                Id 
            IN :idsLog
        ];

        return listaLogsBCP;
    }

    public void atualizarLogBCPAPI(Contract contrato, String mensagem){

        BCP_Log__c log = [
                SELECT 
                    BCP_DataHoraRetorno__c,
                    BCP_Descricao__c,
                    BCP_Status__c
                FROM
                    BCP_Log__c
                WHERE
                    BCP_Contrato__c = :contrato.Id
        ];

        log.BCP_DataHoraRetorno__c = Util.montarDataHoraComGMT(Datetime.now());
        log.BCP_Descricao__c = mensagem;
        log.BCP_Status__c = mensagem.contains('sucesso') ? 'CIV - Sucesso' : 'CIV - Erro API REST';      

        update log;
    }

    public void gerarLogBCPErroAPI(String mensagem){

        BCP_Log__c log = new BCP_Log__c(
            BCP_DataHoraRetorno__c = Util.montarDataHoraComGMT(Datetime.now()),
            BCP_Descricao__c = mensagem,
            BCP_Status__c = 'CIV - Erro API REST'
        );

        insert log;
    }
}
//LECVP-72 - FIM