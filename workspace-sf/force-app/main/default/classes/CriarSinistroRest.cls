/*******************************************************************************************************************************
* 
* @author Leonardo - Globant
* @date 16/06/2020
* @modifiedAt 
* Classe criada por conta da história PLV-3875
* Serviço para criar sinistro (Caso)
******************************************************************************************************************************/
@RestResource(urlMapping='/sinistro/criar')
global with sharing class CriarSinistroRest {
   
    @HttpPost
    global static CivSinistroTO.Response novoSinistro(CivSinistroTO.Request sinistro){ //PLV-4094 - INICIO/FIM      
        system.debug('PLV-4826 - Sinistro = ' + sinistro);
        sinistro.fillData();
        system.debug('PLV-4826 - Sinistro = ' + sinistro);
        CivSinistroTO.Response retorno = new CivSinistroTO.Response(); //PLV-4094 - INICIO/FIM
       
        String msg = sinistro.validar(); 
        system.debug('PLV-4826 - Sinistro = ' + sinistro);
        system.debug('MENSAGEM: '+ msg);
        if(String.isNotBlank(msg)) return retorno.setError(msg);

        //PLV-4094 - TRECHO DE CÓDIGO REMOVIDO -
        
        Savepoint sp = Database.setSavepoint();

        Boolean error = false;
        try{        
            //PLV-4166 - INICIO
            system.debug('PLV-4826 - Sinistro = ' + sinistro);
            SinistroService sService = new SinistroService(sinistro);
            system.debug('PLV-4826 - sinistro = ' + sinistro);
            system.debug('PLV-4826 - sinistro - Existe? = ' + sinistro.numeroSinistroExiste);
            if(sinistro.numeroSinistroExiste && sinistro.numeroSinistroExiste != null){ //PLV-4826               
                retorno.data = sService.AtualizaCasoSinistro();
            }else{                
                retorno.data = sService.criarCasoSinistro();
            }
           //PLV-4166 - FIM
            //gera a movimentação do sinistro avisado
            SinistroService.movimentoSinistro(retorno.data.caseId); //PLV-4037 - INÍCIO/FIM
        }
        catch(Exception e){
            Database.rollback(sp);
            retorno.meta.statusHttp = 500;
            retorno.meta.mensagem   = 'Erro no processamento do serviço: ' + 'Linha: ' + e.getLineNumber() + ' - ' + e.getMessage();
        }
        system.debug('4870 - Retorno = ' + retorno);
        return retorno;
    }

    //PLV-4094 - TRECHO DE CÓDIGO REMOVIDO - Código migrado para a classe CivSinistroTO    
}