/**
 * Caso REST Status
 * @author GFS @ 30/01/2019
 *
 **/
@RestResource(urlMapping='/caso/status/*')
global with sharing class CasoRestStatus
{
    @HttpPost
    global static String consultarJobs(String Idjob) {
       String result = processarServico('POST', Idjob);
       return result;
    }

    public static String processarServico(String metodo, String Idjob) {
        try {
                system.debug('Idjob  ' + Idjob);
                AsyncApexJob jobInfo = [SELECT Status,NumberOfErrors FROM AsyncApexJob WHERE Id=:Idjob limit 1];
                system.debug('jobInfo '+ jobInfo);

            return String.valueof(jobInfo.Status);   
                
        }
        catch (Exception e) {
            return String.valueof(e.getMessage());
        }
    }
}