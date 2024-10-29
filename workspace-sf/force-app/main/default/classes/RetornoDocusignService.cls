/******************************************************************************************************************************
* Executa alterações após a assinatura do documento Docusign
* @author Carlos - Meta
* @date 03/03/2021
* Classe criada por conta da história PLV-4839
******************************************************************************************************************************/
public class RetornoDocusignService {
    private RetornoDocusignREST.ConsultaParam param;
    public RetornoDocusignService(RetornoDocusignREST.ConsultaParam param) {
        this.param = param;
    }

    public RetornoDocusignREST.DataTO consultar(){
        RetornoDocusignREST.DataTO resposta =  new RetornoDocusignREST.DataTO();
        Map<String, Object> returnObject = atualizarCritica(this.param);//PLV-4883 - INICIO/FIM - PEDRO AUGUSTO BRAZ
        resposta.atualizado = Boolean.valueOf(returnObject.get('Boolean'));
        resposta.descricaoErro = String.valueOf(returnObject.get('String'));
        resposta.statusChamada = 200;
        return resposta;
    }

    private Map<String, Object> atualizarCritica(RetornoDocusignREST.ConsultaParam param){//PLV-4883 - INICIO/FIM - PEDRO AUGUSTO BRAZ
        Map<String, Object> returnObject = new Map<String, Object>();
        //PLV-4839-FIX
        //PLV-4925 INICIO
        List<CriticaProposta__c> listCritica = [SELECT Id, Status__c, Parecer__c FROM CriticaProposta__c whERE Proposta__c =: param.sfid AND (Status__c = 'Em aprovação' OR Status__c = 'Pendente'  OR Status__c = 'Pendenciado' ) AND Integracao__c = 'DOCUSIGN'];//PLV-4883 - INICIO/FIM - PEDRO AUGUSTO BRAZ
        //PLV-4925 FIM
        if(listCritica.size() > 0 ){
            //PLV-4925 INICIO
            if(listCritica[0].Status__c == 'Pendenciado'){
                listCritica[0].DataFimPendencia__c = System.today();
            }
            //PLV-4925 FIM
            listCritica[0].Status__c = param.status;//PLV-4883 - INICIO/FIM - PEDRO AUGUSTO BRAZ
            listCritica[0].Parecer__c = String.isBlank(param.parecer) ? listCritica[0].Parecer__c : param.parecer ;//PLV-4883 - INICIO/FIM - PEDRO AUGUSTO BRAZ
            Database.SaveResult[] srList = Database.update(listCritica, false);
    
            for (Database.SaveResult sr : srList) {
                if (sr.isSuccess()) {
                    returnObject.put('Boolean', true);
                    returnObject.put('String', null);
                    return returnObject;
                }
                else {
                    returnObject.put('Boolean', false);
                    for(Database.Error err : sr.getErrors()) {
                        System.debug('The following error has occurred.');                    
                        System.debug(err.getStatusCode() + ': ' + err.getMessage());
                        System.debug('Account fields that affected this error: ' + err.getFields());
                        returnObject.put('String', err.getMessage() + ' ' + err.getFields());
                    }
                    return returnObject;
                }
            }
        }else{
            returnObject.put('Boolean', false);
            returnObject.put('String', 'Não foi encontrado nenhuma crítica para a proposta informada.');
            return returnObject;
        }
        returnObject.put('Boolean', false);
        returnObject.put('String', 'Não foi encontrado nenhuma crítica para a proposta informada.');
        return returnObject;
    }
}