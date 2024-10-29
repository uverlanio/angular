/*********************************************************************************************************************************************************************
@description Classe BO que utiliza metadados para parametrização do agendamento da batch no reenvio dos contratos a BCP.
@author Uverlanio Silva - Globant
@date 23/01/2023
**********************************************************************************************************************************************************************/
//LECVP-72 - INICIO
public class BCPTcktContratoBO {

    private static final BCPTcktContratoBO instance = new BCPTcktContratoBO();

    public static BCPTcktContratoBO getInstance() {
        return instance;
    }

    public void init() {

        String cronExp = '';

        BCP_BatchSchedulerConfig__mdt bcpBatchSchedulerConfig = MetadataDAO.getInstance().bcpBatchSchedulerConfig();

        if(Test.isRunningTest()){
            bcpBatchSchedulerConfig.BCP_DataHoraInicio__c = Datetime.now().addDays(2);
            bcpBatchSchedulerConfig.BCP_DataHoraFim__c = Datetime.now().addDays(3);
        }

        if(bcpBatchSchedulerConfig != null && bcpBatchSchedulerConfig.Ativo__c){

            Datetime dataHoraInicio = Util.montarDataHoraComGMT(bcpBatchSchedulerConfig.BCP_DataHoraInicio__c);
            Datetime dataHoraFim = Util.montarDataHoraComGMT(bcpBatchSchedulerConfig.BCP_DataHoraFim__c);
            
            Integer frequencia = Integer.valueOf(bcpBatchSchedulerConfig.BCP_Frequencia_h__c * 60);
            Integer frequenciaAux = 0;
            Integer minutos = 0;
            Decimal roundQtdeVezes = 24 / Decimal.valueOf(frequencia);
            Decimal qtdeVezesAgendamento = roundQtdeVezes.round(RoundingMode.UP);

                try{
                    Integer incrementaDias = 1;

                    while(dataHoraInicio < dataHoraFim){                       
                        
                        if(frequencia > 0){                
                            for(Integer i = 0; i <= qtdeVezesAgendamento; i++){
                                cronExp = montarCronExp(dataHoraInicio.addMinutes(minutos));
                                
                                try{
                                    String dataHoraJob = String.valueOf(Datetime.now());
                                    System.schedule('BCPTcktContratoJob - ' + dataHoraJob, cronExp, new BatchReenvioContratoBCP());
                                    minutos = frequencia * ++frequenciaAux;
                                }catch(AsyncException ae){
                                    String erro = ae.getMessage();

                                    if(erro.contains('Based on configured')){
                                        throw new BCPTcktContratoBOException('Favor validar data de agendamento.');
                                    }
                                }
                            }                           
                            
                            dataHoraInicio = addDiasDataHoraInicio(dataHoraInicio, incrementaDias);
                            incrementaDias++;
                        }else{
                            throw new BCPTcktContratoBOException('A frequência precisa ser maior que zero.');
                        }
                    }
                }catch(Exception e){
                    throw new BCPTcktContratoBOException(e.getMessage());
                }              
        }
    }
    
    private String montarCronExp(Datetime dataHoraInicio){
        String cronExp = '';

        String segundo = String.valueOf(dataHoraInicio.second()) + ' ';
        String minuto = String.valueOf(dataHoraInicio.minute()) + ' ';
        String hora = String.valueOf(dataHoraInicio.hourGmt()) + ' ';

        String dia = String.valueOf(dataHoraInicio.day()) + ' ';
        String mes = String.valueOf(dataHoraInicio.month()) + ' ';
        String diaDaSemana = '?' + ' ';
        String ano = String.valueOf(dataHoraInicio.year());

        cronExp = segundo + minuto + hora + dia + mes + diaDaSemana + ano;

        return cronExp;
    }

    private Datetime addDiasDataHoraInicio(Datetime dataHoraInicio, Integer qtdDias){
        
        Date data = dataHoraInicio.date().addDays(qtdDias);
        Time hora = dataHoraInicio.time();

        return Datetime.newInstance(data, Hora);
    }

    private static Boolean validarDataAgendamento(Datetime dataHoraInicio, Datetime dataHoraFim){

        Boolean dataValidaInicio = dataHoraInicio < Datetime.now() ? true : false;
        Boolean dataValidaFim = dataHoraInicio < dataHoraFim ? true : false;
        Boolean datasValidas = false;

        if(dataValidaInicio && dataValidaFim){
            datasValidas = true;
        }

        return datasValidas;
    }

    public class BCPTcktContratoBOException extends Exception{}
}
//LECVP-72 - FIM