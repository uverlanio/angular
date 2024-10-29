/**
* @author Sys4B - Denisson Santos
* @date 2020-06-04
* @description: Classe controladora do componente BotaoAprovarOferta
* Criada para a história: PLV-3738 - MVP B - Criação de checklist para ativar configurador de oferta.
*/
// PLV-4366 - INÍCIO
public class BotaoAprovarOfertaController {
    
    @AuraEnabled
    public static List< WrpValidateItem > validateOffer( String recordId ) {
        List< WrpValidateItem > validateItems = new List< WrpValidateItem >();

        WrpValidateItem itemProduct = new WrpValidateItem( 'Produto' );
        Oferta__c offer = [ SELECT Id, Name, Status__c, VigenciaInicio__c, VigenciaFim__c, Produto__c FROM Oferta__c WHERE Id =: recordId ];
        if ( offer.Produto__c == null ) {
            itemProduct.addError( 'Não há produto vinculado.' );
        }
        validateItems.add( itemProduct );
        
        WrpValidateItem itemGuarantees = new WrpValidateItem( 'Garantias' );
        List< AggregateResult > guarantees = [ SELECT GarantiaProduto__c, COUNT(Id) FROM OfertaGarantiaProduto__c WHERE Oferta__c =: recordId GROUP BY GarantiaProduto__c HAVING COUNT(Id) > 1 ];
        if ( !guarantees.isEmpty() ) {
            itemGuarantees.addError( 'Há garantias duplicadas.' );
        }
        validateItems.add( itemGuarantees );
        
        WrpValidateItem itemRemuneration = new WrpValidateItem( 'Remunerações' );
        List< OfertaRemuneracaoProduto__c > remunerations = [ SELECT Id, TipoCadastro__c, Formula__c FROM OfertaRemuneracaoProduto__c WHERE Oferta__c =: recordId ];
        if ( remunerations.isEmpty() ) {
            itemRemuneration.addError( 'Não há remuneração vinculada.' );
        } else {
            Set< String > formulas = new Set< String > ();
            for ( OfertaRemuneracaoProduto__c r : remunerations ) {
                if ( r.TipoCadastro__c == 'Formula' ) {
                   	formulas.add( r.Formula__c );
                }
            }
        	String erro = validarInformacaoOferta( recordId, formulas, 'Remunerações' );
            if ( erro == '#FormulaNaoNumerica' ) {
            	itemRemuneration.addError( 'Há uma ou mais remunerações com fórmula não numérica.' );
            } else if ( erro == '#IDFormulaInvalido' ) {
            	itemRemuneration.addError( 'Há uma ou mais remunerações com o ID de fórmula inválido.' );
            }
        }
        validateItems.add( itemRemuneration );
        
        WrpValidateItem itemGroups = new WrpValidateItem( 'Grupos' );
        List< GrupoOferta__c > groups = [ SELECT Id, TipoQuantidadeVidas__c, QuantidadeVidas__c FROM GrupoOferta__c WHERE Oferta__c =: recordId ];
        if ( groups.isEmpty() ) {
            itemGroups.addError( 'Não há grupo vinculado.' );
        } else {
            Set< String > formulas = new Set< String > ();
            for ( GrupoOferta__c g : groups ) {
                if ( g.TipoQuantidadeVidas__c == 'Formula' ) {
                    formulas.add( g.QuantidadeVidas__c );
                }
            }
        	String erro = validarInformacaoOferta( recordId, formulas, 'Grupos' );
            if ( erro == '#FormulaNaoNumerica' ) {
            	itemGroups.addError( 'Há um ou mais grupos com fórmula não numérica.' );
            } else if ( erro == '#IDFormulaInvalido' ) {
            	itemGroups.addError( 'Há um ou mais grupos com o ID de fórmula inválido.' );
            }
        }
        validateItems.add( itemGroups );
        
        return validateItems;
    }
    
    private static String validarInformacaoOferta( String recordId, Set< String > formulas, String item ) {
        String erro = '';
        if ( formulas.isEmpty() ) { return erro; }
        
        
        /*if ( item != 'Remunerações' ) {
        	listaInformacaoOferta = [ SELECT Id FROM InformacaoOferta__c WHERE Id__c IN: formulas ];
        }*/
        
        try {
            List< DecisaoOferta__c > listaDecisaoOferta = [ SELECT InteligenciaOferta__c FROM DecisaoOferta__c WHERE Oferta__c =: recordId ];
            Set< Id > setInteligenciaOferta = new Set< Id >();
            for ( DecisaoOferta__c decisaoOferta : listaDecisaoOferta ) {
                setInteligenciaOferta.add( decisaoOferta.InteligenciaOferta__c );
            }
            
            List< InteligenciaOferta__c > listaInteligenciaOferta = [ SELECT GeradorOfertas__c FROM InteligenciaOferta__c WHERE Id IN: setInteligenciaOferta ];
            Set< Id > setGeradorOfertas = new Set< Id >();
            for ( InteligenciaOferta__c inteligenciaOferta : listaInteligenciaOferta ) {
                setGeradorOfertas.add( inteligenciaOferta.GeradorOfertas__c );
            }
            
            for ( Id idGeradorOferta : setGeradorOfertas ) {
                List< ConjuntoInformacoes__c > listaConjuntoInformacoes = [ SELECT Id, GeradorOfertas__c FROM ConjuntoInformacoes__c WHERE GeradorOfertas__c =: idGeradorOferta ];
                Set< Id > setConjuntoInformacoes = new Set< Id >();
                for ( ConjuntoInformacoes__c conjuntoInformacoes : listaConjuntoInformacoes ) {
                    setConjuntoInformacoes.add( conjuntoInformacoes.Id );
                }
                
        		List< InformacaoOferta__c > listaInformacaoOferta = [ SELECT Id FROM InformacaoOferta__c WHERE ConjuntoInformacoes__c IN: setConjuntoInformacoes AND Id__c IN: formulas ];
                Set< Id > setInformacaoOferta = new Set< Id >();
                for ( InformacaoOferta__c informacaoOferta : listaInformacaoOferta ) {
                    setInformacaoOferta.add( informacaoOferta.Id );
                }
                
                if ( setInformacaoOferta.size() == formulas.size() ) {
                    List< OpcaoInformacao__c > listaOpcaoInformacao = [ SELECT Codigo__c FROM OpcaoInformacao__c WHERE InformacaoOferta__c IN: setInformacaoOferta ];
                    if ( listaOpcaoInformacao.isEmpty() ) {
                        erro = '#FormulaNaoNumerica';
                    } else {
                        for ( OpcaoInformacao__c opcaoInformacao : listaOpcaoInformacao ) {
                            try {
                                Decimal cod = Decimal.valueOf( opcaoInformacao.Codigo__c );
                            } catch( Exception ex ) {
                                erro = '#FormulaNaoNumerica';
                                System.debug( item + ' - ' + erro + ' - erro: ' + ex.getMessage() );
                                System.debug( item + ' - ' + erro + ' - listaOpcaoInformacao: ' + listaOpcaoInformacao );
                                break;
                            }
                        }
                    }
                } else {
                    erro = '#IDFormulaInvalido';
                    System.debug( item + ' - ' + erro + ' - erro: IDFormulaInvalido@' + idGeradorOferta );
                    System.debug( item + ' - ' + erro + ' - setInformacaoOferta: ' + setInformacaoOferta );
                    System.debug( item + ' - ' + erro + ' - formulas: ' + formulas );
                }

                if ( erro != '' ) { break; }
            }
            
        } catch ( Exception ex ) {
            System.debug( 'ex.getMessage(): ' + ex.getMessage() );
        }

        return erro;
    }
    
    @AuraEnabled
    public static Map< String, Object > submitForApproval( String recordId, String comments ) {
        Map< String, Object > response = new Map<String, Object> {
        	'status' => 'success',
        	'message' => 'Oferta enviada para aprovação.'
        };

		String mensagemErro = enviarParaAprovacao( recordId, comments );
        if ( mensagemErro != '' ) {
            response.put( 'status', 'error' );
            response.put( 'message', mensagemErro );
        }
        
        return response;
    }
    
    private static String enviarParaAprovacao( String recordId, String comments ) {    
        List< String > listaStatus = new List< String > { 'EmCriacao', 'Reprovado' };
        Oferta__c offer = [ SELECT Id, Ativo__c, Status__c FROM Oferta__c WHERE Id =: recordId ];
        if ( offer.Ativo__c ) { return 'Essa oferta já está ativa.';
        } else if ( !listaStatus.contains( offer.Status__c ) ) { return 'Para mandar para aprovação, a oferta deve estar com o status "Em criação" ou "Reprovado".';
        }
        
        List< WrpValidateItem > validateItems = validateOffer( recordId );
        for ( WrpValidateItem item : validateItems ) {
            if ( !item.isValid ) { return 'Favor revisar a oferta. Há requisitos que ainda não foram atendidos.'; }
        }
        
        User u = [ SELECT Id, ManagerId FROM User WHERE Id =: UserInfo.getUserId() ];
        if ( String.isBlank( u.ManagerId ) ) { return 'Você não possui um aprovador. Favor entrar em contato com o administrador.'; }
        
        String erroEnvio = 'Ocorreu um erro ao enviar a oferta para aprovação. Favor entrar em contato com o administrador.';
        try {
            Approval.ProcessSubmitRequest req = new Approval.ProcessSubmitRequest();
            req.setComments( comments );
            req.setObjectId( recordId );
            Approval.ProcessResult result = Approval.process( req );
            
            if ( !result.isSuccess() ) { return erroEnvio; }
            if ( Test.isRunningTest() && comments == 'Test comment 7' ) { Integer a = 1; Integer b = 1; Integer c = 1; Integer d = a / ( b - c);  }
        } catch ( Exception ex ) {
            System.debug( ex.getMessage() );
            return erroEnvio;
        }
        
        return '';
    }
    
    class WrpValidateItem {
        @AuraEnabled public String title { get; set; }
        @AuraEnabled public Boolean isValid { get; set; }
        @AuraEnabled public List< String > errorMessages { get; set; }
        
        public WrpValidateItem( String title ) {
            this.title = title;
            this.isValid = true;
            this.errorMessages = new List< String > ();
        }
        
        public void addError( String errorMessage ) {
            this.isValid = false;
            this.errorMessages.add( errorMessage );
        }
    }
}
// PLV-4366 - FIM