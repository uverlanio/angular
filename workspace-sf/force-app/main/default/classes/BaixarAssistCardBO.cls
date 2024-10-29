/*********************************************************************************************************************************************************************
@description Classe BO que utiliza metadados para parametrização do agendamento da batch
@date 25/05/2023
**********************************************************************************************************************************************************************/
//LECVP-318 - INICIO
public class BaixarAssistCardBO {
    
    private static final BaixarAssistCardBO instance = new BaixarAssistCardBO();

    public static BaixarAssistCardBO getInstance() {
        return instance;
    }

    public void agendarExecucao(){

        String cronExp = '';

        ConfigHoraExecBatch__mdt configHoraExecBatch;

        if(Test.isRunningTest()){
            configHoraExecBatch = new ConfigHoraExecBatch__mdt();
            configHoraExecBatch.Ativo__c = true;
            configHoraExecBatch.horaExecucao__c = Datetime.now().addDays(1);
        }else{
            configHoraExecBatch = MetadataDAO.getInstance().configHoraExecBatch();
        }

        if(configHoraExecBatch != null && configHoraExecBatch.Ativo__c){
            Datetime horaExecucao = Util.montarDataHoraComGMT(configHoraExecBatch.horaExecucao__c);
            cronExp = montarCronExp(horaExecucao);

            try{
                String dataHoraJob = String.valueOf(Datetime.now());
                System.schedule('BatchBaixarAssistCard - ' + dataHoraJob, cronExp, new BatchBaixarAssistCard());
            }catch(AsyncException ae){
                String erro = ae.getMessage();

                if(erro.contains('Based on configured')){
                    throw new BaixarAssistCardBOException('Favor validar data de agendamento.');
                }
            }
        }
    }

    private String montarCronExp(Datetime dataHoraInicio){
        String cronExp = '';

        String segundo = String.valueOf(dataHoraInicio.second()) + ' ';
        String minuto = String.valueOf(dataHoraInicio.minute()) + ' ';
        String hora = String.valueOf(dataHoraInicio.hourGmt()) + ' ';

        String dia = '*' + ' ';
        String mes = '*' + ' ';
        String diaDaSemana = '?' + ' ';
        String ano = '*';

        cronExp = segundo + minuto + hora + dia + mes + diaDaSemana + ano;

        return cronExp;
    }

    public class BaixarAssistCardBOException extends Exception{}
}
//LECVP-318 - FIM