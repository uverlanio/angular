/**
 * @author AVX - Leonardo Camacho
 * @date 2019-12-10
 * @description: Classe criada por conta da história PLV_3134
 * para gravar o Id da proposta na tabela de controle de integração quando a proposta é contratada
 **/

public class GravarPropostaControleIntegracao {

        public static final GravarPropostaControleIntegracao instancia = new GravarPropostaControleIntegracao();

        public static GravarPropostaControleIntegracao getInstance(){
            return instancia;
        }

        public void inserirRegistroControleIntegracao(List<Quote> PropostasEntrada){
            
            List<ControleIntegracao__c> listControleIntegracao = new List<ControleIntegracao__c>();            
            Set<Id> setProdutos = new Set<Id>();
            Set<Id> setPropostas = new Set<Id>();
            Set<String> setFormaPagamento = new Set<String>{'51','52','53'};

            system.debug('setFormaPagamento: ' + setFormaPagamento);

             for(Quote proposta : PropostasEntrada){             
             
                if(proposta.tipo__c == 'Novo' && TriggerHelper.isChanged(proposta, 'Status') && proposta.Status == 'Contratada'){

                    setPropostas.add(proposta.id);
                    setProdutos.add(proposta.produto__c);                    
                }
            }

            if(setProdutos.isEmpty()) return;

            List<CondicaoCobranca__c> listTipoPagamento = [SELECT id, TipoPagamento__c, produto__c, produto__r.name 
                                                        FROM CondicaoCobranca__c
                                                        WHERE produto__c IN :setProdutos
                                                        AND TipoPagamento__c = 'ADC']; 


            if(listTipoPagamento.isEmpty()) return;


            List<contratanteProposta__c> listaContratantesProposta = [SELECT id, FormaPagamento__c, proposta__c
                                                                    FROM contratanteProposta__c 
                                                                    WHERE proposta__c IN : setPropostas
                                                                    AND formaPagamento__r.codigo__c IN : setFormaPagamento];

            if(listaContratantesProposta.isEmpty()) return;

            for(contratanteProposta__c contratanteProposta : listaContratantesProposta){
                            ControleIntegracao__c controleIntegracao = new ControleIntegracao__c(
                            CodigoIntegracao__c = '7',
                            IdObjeto__c = contratanteProposta.proposta__c,
                            DataCriacaoRegistro__c = System.today(),
                            Status__c = 'Pendente');

                            listControleIntegracao.add(controleIntegracao);
            }                   
            insert listControleIntegracao;
        }
}