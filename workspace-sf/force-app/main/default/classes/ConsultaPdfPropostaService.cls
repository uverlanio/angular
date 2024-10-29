/*******************************************************************************************************************************
* Consulta PDF Proposta
* @author Yuri - Sys4B
* @date 22/04/2021
* Classe criada por conta da história PLV-4896
******************************************************************************************************************************/
public with sharing class ConsultaPdfPropostaService {

    private ConsultaPdfPropostaREST.ConsultaParam param;

    public ConsultaPdfPropostaService(ConsultaPdfPropostaREST.ConsultaParam param) {
        this.param = param;
    }

    public ConsultaPdfPropostaREST.DataTO consultar(){
      	try {
             List<Quote> proposta = [SELECT Name FROM Quote WHERE CodigoCorretor__r.Name =: this.param.idCanal
             						AND CanalDistribuicao__r.Name =: this.param.canal AND Name =: this.param.proposta LIMIT 1];
 
            if(proposta.size() > 0){
                ConsultaPdfPropostaREST.DataTO retorno = new ConsultaPdfPropostaREST.DataTO();
            	PageReference pdf = Page.PropostaIndividual;
            	pdf.setRedirect(false);
            	pdf.getParameters().put('numProposta', proposta[0].Name);
                retorno.pdfData = EncodingUtil.base64Encode(pdf.getContentAsPDF());
            	return retorno;
            }
            return null;
           
         } catch (Exception ex) {
            return null;
        }
    }
}