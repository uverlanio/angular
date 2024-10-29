/**
 * BO ParametroVigencia
 * @author Fernando Barcellos @ 17/05/2018
 *
 **/
public class ParametroVigenciaBO {

    private static final Integer DIAS_POR_ANO = 365;
    private static final String DIAS = 'Dias';
    private static final String ANOS = 'Anos';
    private static final String TIPO_DETERMINADO = 'Determinado';
    private static final String TIPO_PERIODICO = 'Periódico';
    private static final String TIPO_VITALICIO = 'Vitalício';

    private static ParametroVigenciaBO classInstance;

    static {
        classInstance = new ParametroVigenciaBO();
    }

    private ParametroVigenciaBO() {
        
    }

    public static ParametroVigenciaBO getInstance() {
        return classInstance;
    }

    /**
     * Validação de acordo com o Tipo__c
     * @author Fernando Barcellos @ 17/05/2018
     * 
     */
    public void validarParametros(List<ParametroVigencia__c> parametrosVigencia) {
        List<ParametroVigencia__c> parametrosComerciais = new List<ParametroVigencia__c>();
        List<ParametroVigencia__c> parametrosTecnicos = new List<ParametroVigencia__c>();
        
        Set<Id> idsParametrosVigenciaTecnicos = new Set<Id>();

        for(ParametroVigencia__c param0 : parametrosVigencia) {
            if (param0.ParametroVigencia__c != null) {
                parametrosComerciais.add(param0);
                idsParametrosVigenciaTecnicos.add(param0.ParametroVigencia__c);
            }
            else {
                parametrosTecnicos.add(param0);
            }
        }

        // Parâmetros de vigência técnico para usar na validação dos batentes
        Map<Id, ParametroVigencia__c> parametrosVigenciaTecnico = new Map<Id, ParametroVigencia__c>(ParametroVigenciaDAO.getInstance().buscarParametrosVigencia(idsParametrosVigenciaTecnicos));

        // Validações para a criação de registro do tipo produto comercial
        for(ParametroVigencia__c param1 : parametrosComerciais) {
            ParametroVigencia__c paramTecnico = parametrosVigenciaTecnico.get(param1.ParametroVigencia__c);

            if (param1.Produto__c == null) {
                param1.addError('O produto não pode ser alterado.');
            }

            if (param1.Tipo__c != paramTecnico.Tipo__c) {
                param1.addError('O tipo de parâmetro de vigência não pode ser alterado.');
            }

            if (param1.Tipo__c == TIPO_DETERMINADO) {
                Decimal prazoMinimoTecnico = paramTecnico.PeriodoMinimoVigencia__c == null ? 0 : paramTecnico.PeriodoMinimoVigencia__c;
                Decimal prazoMaximoTecnico = paramTecnico.PeriodoMaximoVigencia__c == null ? 0 : paramTecnico.PeriodoMaximoVigencia__c;

                if (param1.TipoPeriodo__c != paramTecnico.TipoPeriodo__c) {
                    if (param1.TipoPeriodo__c == DIAS) {
                        prazoMinimoTecnico *= DIAS_POR_ANO;
                        prazoMaximoTecnico *= DIAS_POR_ANO;
                    }
                    else {
                        prazoMinimoTecnico /= DIAS_POR_ANO;
                        prazoMaximoTecnico /= DIAS_POR_ANO;
                    }
                }
                
                if (param1.PeriodoMinimoVigencia__c > prazoMinimoTecnico) {
                    param1.addError('Período mínimo de vigência acima do limite técnico.');
                }

                if (param1.PeriodoMaximoVigencia__c > prazoMaximoTecnico) {
                    param1.addError('Período máximo de vigência acima do limite técnico.');
                }
            }
            else if (param1.Tipo__c == TIPO_PERIODICO) {
                //PeriodoCoberturaMinimo__c, PeriodoCoberturaMaximo__c, Periodicidade__c
                Decimal periodoCoberturaMinimo = paramTecnico.PeriodoCoberturaMinimo__c == null ? 0 : paramTecnico.PeriodoCoberturaMinimo__c;
                Decimal periodoCoberturaMaximo = paramTecnico.PeriodoCoberturaMaximo__c == null ? 0 : paramTecnico.PeriodoCoberturaMaximo__c;

                if (param1.Periodicidade__c != paramTecnico.Periodicidade__c) {
                    if (param1.Periodicidade__c == DIAS) {
                        periodoCoberturaMinimo *= DIAS_POR_ANO;
                        periodoCoberturaMaximo *= DIAS_POR_ANO;
                    }
                    else {
                        periodoCoberturaMinimo /= DIAS_POR_ANO;
                        periodoCoberturaMaximo /= DIAS_POR_ANO;
                    }
                }

                if (param1.PeriodoCoberturaMinimo__c > periodoCoberturaMinimo) {
                    param1.addError('Período de cobertura mínimo está acima do limite técnico.');
                }
                else if (param1.PeriodoCoberturaMaximo__c > periodoCoberturaMaximo) {
                    param1.addError('Período de cobertura máximo está acima do limite técnico.');
                }
            }
            else if (param1.Tipo__c == TIPO_VITALICIO) {
                //ModeloResgate__c, PrazoAplicacaoReajuste__c, PrazoMinimoCancelamento__c, IndiceReajuste__c
                if (param1.ModeloResgate__c != paramTecnico.ModeloResgate__c) {
                    param1.addError('Modelo de resgate diferente do parâmetro técnico.');
                }
                else if (param1.PrazoAplicacaoReajuste__c != paramTecnico.PrazoAplicacaoReajuste__c) {
                    param1.addError('Prazo para aplicação de reajuste diferente do parâmetro técnico.');
                }
                else if (param1.PrazoMinimoCancelamento__c != paramTecnico.PrazoMinimoCancelamento__c) {
                    param1.addError('Prazo mínimo de cancelamento diferente do parâmetro técnico.');
                }
                else if (param1.IndiceReajuste__c != paramTecnico.IndiceReajuste__c) {
                    param1.addError('Índice de reajuste diferente do parâmetro técnico.');
                }
            }
        }

        // Validações para a criação de registro do tipo produto técnico
        for(ParametroVigencia__c param2 : parametrosTecnicos) {
            if (param2.Tipo__c == TIPO_DETERMINADO) {

                if ((param2.PeriodoMinimoVigencia__c == null || param2.PeriodoMaximoVigencia__c == null) && param2.TipoPeriodo__c == null) {
                    param2.addError('Obrigatório preencher o tipo de período, o período máximo e mínimo de vigência.');
                }
            }
            else if (param2.Tipo__c == TIPO_PERIODICO) {
                //PeriodoCoberturaMinimo__c, PeriodoCoberturaMaximo__c, Periodicidade__c
                if (param2.PeriodoCoberturaMinimo__c == null && param2.PeriodoCoberturaMaximo__c == null && param2.Periodicidade__c == null) {
                    param2.addError('Obrigatório preencher os períodos de cobertura mínimo e máximo e periodicidade.');
                }
            }
        }
    }
}