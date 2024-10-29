/**
 * @author AVX - Leonardo Camacho
 * @date 2019-12-04
 * @description: Classe de testes para a classe GravarPropostaControleIntegracao
 **/


@IsTest
public class GravarPropostaControleIntegracaoTest {

        @IsTest
        public static void gravarPropostaTest(){

            Account conta = (Account) new AccountFactory.PessoaFisica().createRecord();
            RamoSeguro__c ramoSeguro = (RamoSeguro__c) new RamoSeguroFactory(conta).createRecord();
            DadosCorretor__c dadosCorretor = (DadosCorretor__c) new DadosCorretorFactory(conta).createRecord();
            Modalidade__c modalidade = (Modalidade__c) new ModalidadeFactory(ramoSeguro).createRecord();
            ContadorCodigo__c contadorTecnico = (ContadorCodigo__c) new ContadorCodigoFactory.ProdutoTecnico().createRecord();
            ContadorCodigo__c contadorComercial = (ContadorCodigo__c) new ContadorCodigoFactory.ProdutoComercial().createRecord();

            Product2 produtoTecnico = (Product2) new ProdutoFactory.ProdutoTecnico().createRecord();
            produtoTecnico.Status__c = 'Em ativação';
            produtoTecnico.NumeroSusep__c = '123';
            produtoTecnico.VersaoRenovacao__c = 'Versão atual';
            update produtoTecnico;

            produtoTecnico.Status__c = 'Ativo';
            update produtoTecnico;

            Product2 produtoComercial = (Product2) new ProdutoFactory.ProdutoComercial(produtoTecnico).createRecord();

            Opportunity orcamento = (Opportunity) new OrcamentoFactory.VidaIndividual(produtoComercial, conta).createRecord();

            Quote proposta = (Quote) new PropostaFactory(produtoComercial, ramoSeguro, conta, dadosCorretor, orcamento, modalidade).createRecord();

            formaPagamento__c formaPagamento = (formaPagamento__c) new FormaPagamentoFactory().createRecord();
            formaPagamento.codigo__c = '52';
            update formaPagamento;

            system.debug('Antes de chamar a factory do contratante da proposta');

            ContratanteProposta__c contratanteProposta = (ContratanteProposta__c) new ContratantePropostaFactory(proposta, formaPagamento).createRecord();

            CondicaoCobranca__c condicaoCobranca = new CondicaoCobranca__c();
            condicaoCobranca.produto__c = produtoComercial.id;
            condicaoCobranca.TipoPagamento__c = 'ADC';
            
            insert condicaoCobranca;

            proposta.Status = 'Contratada';
            proposta.tipo__c = 'Novo';

            update proposta;
    }   

}