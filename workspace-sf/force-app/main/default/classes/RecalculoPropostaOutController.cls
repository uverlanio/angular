/*
@author Rogerio Menezes - Globant
@date 09/09/2024
@Classe criada para a história (FNPVVEP-126)
*/
global without sharing class RecalculoPropostaOutController {

    global class FlowInputs {
        @InvocableVariable public String recordId;
    }

    global class EncryptedIdWrapper {
        @InvocableVariable public String encryptedId;
        
        global EncryptedIdWrapper(String encryptedId) {
            this.encryptedId = encryptedId;
        }
    }

    global static String nameKey = 'Key Recalculo';

    @InvocableMethod
    global static List<EncryptedIdWrapper> encryptId(List<FlowInputs> idList) {
        List<EncryptedIdWrapper> encryptedIds = new List<EncryptedIdWrapper>();

        List<Encryption_Key__mdt> metadadoKey = [SELECT
            Key__c
        FROM
            Encryption_Key__mdt
        WHERE Name__c =: nameKey];
        
        for (FlowInputs input : idList) {
            String recordId = input.recordId;
            System.debug('entrou aqui? recordId' + recordId);
            Blob key = EncodingUtil.convertFromHex(metadadoKey[0].Key__c);
            Blob encryptedBlob = Crypto.encryptWithManagedIV('AES192', key, Blob.valueOf(recordId));
            String encryptedId = EncodingUtil.convertToHex(encryptedBlob);
            System.debug('encryptedId >?' + encryptedId);
            encryptedIds.add(new EncryptedIdWrapper(encryptedId));
        }
        
        return encryptedIds;
    }	
}