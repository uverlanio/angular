/**
 * @author AVX - Leonardo Camacho
 * @date 2019-12-12
 * @description: Classe Factory para o objeto Contratante do Orçamento
 **/

public class ContratantePropostaFactory extends SObjectFactory{

    public static ContratanteProposta__c staticRecord;
    
    public static contratanteProposta__c getRecordStatic(Quote proposta, FormaPagamento__c formaPagamento){

        if(staticRecord == null){
            staticRecord = new ContratanteProposta__c(
                proposta__c = proposta.id,
                formaPagamento__c = formaPagamento.id, 
                TipoResponsavelPagamento__c = 'SEG',
                TipoEndereco__c = 'Residencial',
                TipoLogradouro__c = 'Rua',
                NumeroEndereco__c = '100',
                Bairro__c = 'Bom Retiro',
                Estado__c = 'SP',
                Cep__c = '01204-000',
                Logradouro__c = 'Guaianases',
                Cidade__c = 'São Paulo',
                Pais__c = 'Brasil'
                );
        }

        return staticRecord;
      }

      public ContratantePropostaFactory(){

          this(
            (Quote) new PropostaFactory().createRecord(),
            (formaPagamento__c) new FormaPagamentoFactory().createRecord()
          );
      }

      public ContratantePropostaFactory(Quote proposta, FormaPagamento__c formaPagamento){
          super(getRecordStatic(proposta, formaPagamento));

          System.debug('Dentro do construtor - proposta: ' + proposta.id);
          System.debug('Dentro do construtor - Forma de pagamento: ' + formaPagamento.id);
      }
}