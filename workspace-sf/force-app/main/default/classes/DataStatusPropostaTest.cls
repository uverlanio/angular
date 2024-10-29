@isTest
public class DataStatusPropostaTest {
    
    @TestSetup
    static void setupUnit(){
        List<Quote> lstProposta = new List<Quote>();
        Account conta = new Account(
            FirstName = 'FRANCIS',
            LastName = 'LIU',
            Sexo__c = 'MASC',
            Fumante__c = 'Não',                      
			Renda__c = 3000.00,
            Cpf__c = '518.179.180-87',
            TipoDocidentificacao__c = 'rg',
            Rg__c = '0000002',
            OrgaoExpedidor__c = 'SSP',            
            EmpresaTrabalhaSocio__c = 'GLOBANT',
            EstadoCivil__c = 'Solteiro (a)',
            Nacionalidade__c = 'Brasileira',            
			RegimeTrabalho__c = 'CLT',
            ResideBrasil__c = true,
            PaisResidencia__c = 'Brasil',
            Pep__c = 'Não',
            PersonBirthdate = System.today().addDays(-20000)
        );
        insert conta;
        
        Opportunity orcamento = new Opportunity(
            AccountId = conta.Id,
            StageName = 'Em criação',
            Name = 'SFC-00068615',
            CloseDate = System.today().addDays(1)
        );
        insert orcamento;		
        
        Quote proposta1 = new Quote(            
            DependentesFinanceiros__c = false,
            OpportunityId = orcamento.id,
            Name = '18-00037715',
			Status = 'Recusada'            
        );
        Quote proposta2 = new Quote(            
            DependentesFinanceiros__c = false,
            OpportunityId = orcamento.id,
            Name = '18-00037716',
			Status = 'Recusada'            
        );
        Quote proposta3 = new Quote(            
            DependentesFinanceiros__c = false,
            OpportunityId = orcamento.id,
            Name = '18-00037717',
			Status = 'Recusada'            
        );
        Quote proposta4 = new Quote(            
            DependentesFinanceiros__c = false,
            OpportunityId = orcamento.id,
            Name = '18-00037718',
			Status = 'Recusada'            
        );
        Quote proposta5 = new Quote(            
            DependentesFinanceiros__c = false,
            OpportunityId = orcamento.id,
            Name = '18-00037719',
			Status = 'Recusada'            
        );

        lstProposta.add(proposta1);
        lstProposta.add(proposta2);
        lstProposta.add(proposta3);
        lstProposta.add(proposta4);
        lstProposta.add(proposta5);
        insert lstProposta;
        
        CriticaProposta__c critica = new CriticaProposta__c(
        	Status__c = 'Pendente',
            Codigo__c = '71',
            Proposta__c = proposta1.Id
        );
        insert critica;
                
    }
    
    @isTest
    static void testdataStatus(){
        
    }
}