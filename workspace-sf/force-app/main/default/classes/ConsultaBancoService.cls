/******************************************************************************************************************************
* Consulta dados de Banco
* @author Carlos - Meta
* @date 08/09/2020
* Classe criada por conta da história PLV-4383
******************************************************************************************************************************/
public class ConsultaBancoService {
    private ConsultaBancoREST.ConsultaParam param;

    public ConsultaBancoService(ConsultaBancoREST.ConsultaParam param) {
        this.param = param;
    }

    public ConsultaBancoREST.DataTO consultar(){
        ConsultaBancoREST.DataTO resposta =  new ConsultaBancoREST.DataTO();
        resposta.Bancos = atribuirModel(this.param.bancosConveniados);
        resposta.statusChamada = 200;
        return resposta;
    }

    private List<ConsultaBancoREST.ConsultaBancoTO> atribuirModel(String param){
        //PLV-4324 - Inicio
        List<ConsultaBancoREST.ConsultaBancoTO> listReturn = new List<ConsultaBancoREST.ConsultaBancoTO>();
        
        if(param == 'true' || param == 'false'){
            String soql = 'SELECT Id, CodigoBanco__c, Name FROM Banco__c WHERE Ativo__c = true';
            if(param == 'true')
                soql += ' AND ConveniadoADC__c = true';
            else if(param == 'false')
                soql += ' AND ConveniadoADC__c = false';
                
            for(Banco__c banco : (List<Banco__c>) Database.query(soql)){
                ConsultaBancoREST.ConsultaBancoTO model = new ConsultaBancoREST.ConsultaBancoTO();
                model.codigoBanco = banco.CodigoBanco__c;
                model.nomeBanco = banco.Name;
                listReturn.add(model);
            }
        }
        //PLV-4324 - Fim
        return listReturn;
    }
}