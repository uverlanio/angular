/****************************************************************************************************************************
 * Classe de Negocio implementada para o envio de dados do contrato para o seriço de Telemedicina *
 * @author : Rogerio Menezes - Globant                                                                                                        *
 * @date 10/10/2024                                                                                                         *
 * Classe implementada tendo como origem a história FNPVVEP-114                                                            *
 * **************************************************************************************************************************/
public with sharing class ComunicacaoTelemedicina {

    @Future(Callout=true)
    public static void enviarComunicacaoTelemed(Id recordId) {

        try{
            Contract contrato = [SELECT Id, Name, StartDate, VigenciaFinal__c, Segmento__c, Tipo__c, DataEmissao__c , Account.Name, Account.Sexo__c, Account.PersonMobilePhone, Account.Cpf__c, Account.PersonBirthdate, Account.PersonEmail, Account.PersonHomePhone  FROM Contract WHERE Id =: recordId];

            List<GarantiaContrato__c> garantias = [SELECT Id, Garantia__r.Name FROM GarantiaContrato__c WHERE Garantia__r.Name = 'Telemedicina' AND Contrato__c =: recordId];

            if(contrato != null && !garantias.isEmpty()){

                String letraOperacao = new Map<String, String>{
                    'Renovacao' => 'I',
                    'Cancelamento' => 'E',
                    'Endosso' => 'A',
                    'Novo' => 'I'
                }.get(contrato.Tipo__c);
        
                String sexo = (contrato.Account.Sexo__c == 'FEM') ? 'F' : (contrato.Account.Sexo__c == 'MASC') ? 'M' : '';
                
                ComunicacaoTelemedicinaTO comunicacaoTO = new ComunicacaoTelemedicinaTO();
                comunicacaoTO.ID_EMPRESA = contrato.Name; 
                comunicacaoTO.NOME = contrato.Account.Name; 
                comunicacaoTO.DNAS = contrato.Account.PersonBirthdate; 
                comunicacaoTO.NCPF = contrato.Account.Cpf__c; 
                comunicacaoTO.SEXO = sexo; 
                comunicacaoTO.NCPFTITULAR = ''; 
                comunicacaoTO.TITU = 'TITU';  
                comunicacaoTO.PAREN = '15'; 
                comunicacaoTO.EMAIL = contrato.Account.PersonEmail; 
                comunicacaoTO.FONE = contrato.Account.PersonHomePhone; 
                comunicacaoTO.VAL_DE = contrato.StartDate; 
                comunicacaoTO.VAL_ATE = contrato.VigenciaFinal__c; 
                comunicacaoTO.SUBGRUPO = 'Porto Seguro'; 
                comunicacaoTO.OPERACAO = (letraOperacao != null) ? letraOperacao : '';
                comunicacaoTO.DATAEMISSAO = contrato.DataEmissao__c; //FNPVVEP-114 FIX02 INICIO/FIM
                comunicacaoTO.STATUS = 'PENDENTE';  //FNPVVEP-114 FIX02 INICIO/FIM
        
                String payload = JSON.serialize(comunicacaoTO);
                System.debug('payload rogerio teste ><><>' + payload);
                SensediaServices.comunicarTelemed(payload);
            }
        } catch (Exception e) {
            System.debug('Erro ao enviar comunicação para telemedicina: ' + e.getMessage() + ' Linha: ' + e.getLineNumber());
        }
    }

    public class ComunicacaoTelemedicinaTO {
        public String ID_EMPRESA { get; set; }
        public String NOME { get; set; }
        public Date DNAS { get; set; }
        public String NCPF { get; set; }
        public String SEXO { get; set; }
        public String NCPFTITULAR { get; set; }
        public String TITU { get; set; }
        public String PAREN { get; set; }
        public String EMAIL { get; set; }
        public String FONE { get; set; }
        public Date VAL_DE { get; set; }
        public Date VAL_ATE { get; set; }
        public String SUBGRUPO { get; set; }
        public String OPERACAO { get; set; }
        public Date DATAEMISSAO { get; set; } //FNPVVEP-114 FIX02 INICIO/FIM
        public String STATUS { get; set; }
    }
}