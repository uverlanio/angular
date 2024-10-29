/**
 * @author AVX - Leonardo Camacho
 * @date 2019-08-26
 * @description: Classe de teste para a classe CriticaOrçamentoBO
 */
@isTest
public class CriticaOrcamentoTest {

    @TestSetup
    static void setup(){
        
        new ContadorCodigoFactory.ProdutoTecnico().createRecord();
        new ContadorCodigoFactory.ProdutoComercial().createRecord();
        
    }    
    
    @isTest
	public static void criaCriticaOrcamento(){
		CriticaOrcamento__c critFilaCoord = (CriticaOrcamento__c) new CriticaOrcamentoFactory.FilaCoordenadorOrcamento().createRecord();
		CriticaOrcamento__c critFilaTecnica = (CriticaOrcamento__c) new CriticaOrcamentoFactory.FilaTecnicaOrcamento().createRecord();
		CriticaOrcamento__c critFilaMedica = (CriticaOrcamento__c) new CriticaOrcamentoFactory.FilaMedicaOrcamento().createRecord();
	}       
}