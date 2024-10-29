/*********************************************************************************************************************************************************************
@description Classe BO responsavel por disparar o job BatchContrPropRenvJob
@author Uverlanio Silva - Globant
@date 22/09/2023
**********************************************************************************************************************************************************************/
//RVI-297 - INICIO
public class BatchContrPropRenvBO{

    private static final BatchContrPropRenvBO instance = new BatchContrPropRenvBO();

    public static BatchContrPropRenvBO getInstance() {
        return instance;
    }

    public void init() {
        try{
            System.scheduleBatch(new BatchContrPropRenv(), 'BatchContrPropRenvJob', 3);
        }catch (Exception e){
            System.debug('Erro ao agendar execução da Batch: ' + e.getMessage() + ' na linha: ' + e.getLineNumber());
        }
    }
}
//RVI-297 - FIM