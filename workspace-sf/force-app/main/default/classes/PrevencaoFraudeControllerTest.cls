/*******************************************************************************************************************************
* @author: Leonardo - Avx
* @data: 30/11/2020
* Classe criada por conta da história PLV-4523 - Vida Individual
* Description: Classe de teste da classe: PrevencaoFraudeController
******************************************************************************************************************************/
@Istest
public class PrevencaoFraudeControllerTest {
   
    @TestSetup
    private static void Setup(){
        Account contaPF = (Account) new AccountFactory.PessoaFisica().createRecord(); 
        
        ContadorCodigo__c contadorTec = (ContadorCodigo__c) new ContadorCodigoFactory.ProdutoTecnico().createRecord();
        ContadorCodigo__c contadorCom = (ContadorCodigo__c) new ContadorCodigoFactory.ProdutoComercial().createRecord();

        Product2 produtoTecnico = (Product2) new ProdutoFactory.ProdutoTecnico().createRecord();
        produtoTecnico.Status__c = 'Ativo';
        update produtoTecnico;

        Product2 produtoCom = (Product2) new ProdutoFactory.ProdutoComercial(produtoTecnico).createRecord();
        FormaPagamento__c formaPag = (FormaPagamento__c) new FormaPagamentoFactory().createRecord();
        Parceiro__c parceiro = (Parceiro__c) new ParceiroFactory(contaPF, formaPag).createRecord();    
        Contract contrato = (Contract) new ContratoFactory.ContratoFactoryComParam(contaPF, produtoCom, parceiro).createRecord();
        ContratanteContrato__c contratante = (ContratanteContrato__c) new ContratanteFactory(contrato).createRecord();
        GrupoContrato__c grupoContrato = (GrupoContrato__c) new GrupoFactory(contratante).createRecord();
        SeguradoContrato__c segurado = (SeguradoContrato__c) new SeguradoContratoFactory(contaPF, grupoContrato).createRecord();
        Garantia__c garantia = (Garantia__c) new GarantiaFactory().createRecord();
        GarantiaSeguradoContrato__c garantiaSegContrato = (GarantiaSeguradoContrato__c) new GarantiaSeguradoContratoFactory(segurado, garantia).createRecord();

        Case caso = (Case) new CasoFactory.AtendimentoSinistro(contaPF).createRecord();
        Case sinistro = (Case) new CasoFactory.Sinistro(caso, contaPF).createRecord();
        Sinistro.contrato__c = contrato.id;
        sinistro.Dataocorrencia__c = Date.newInstance(2020, 09, 07);
        sinistro.Data_Aviso_Cliente__c = Date.newInstance(2020, 09, 07);
        update Sinistro;
        PagamentoGarantia__c garantiaSinistro = (PagamentoGarantia__c) new PagamentoGarantiaFactory(Sinistro, garantiaSegContrato).createRecord();
        
        CriticaSinistro__c criticaResseguro = (CriticaSinistro__c) new CriticaSinistroFactory.CriticaPrevencaoFraude(sinistro,garantiaSinistro).createRecord();                
    }

    @isTest
    private static void TemplateEmailPrevFraudeTest(){

        CriticaSinistro__c criticaResseguro = [
            SELECT id, email__c 
            FROM CriticaSinistro__c 
            WHERE TemplateEmail__c = 'PrevencaoFraude'
        ];

        PrevencaoFraudeController prevFraudeObj = new PrevencaoFraudeController();
        prevFraudeObj.mCriticaId = criticaResseguro.id;
        prevFraudeObj.getInit();
        
        System.assertEquals(prevFraudeObj.mCritica.id, prevFraudeObj.mCriticaId);
    }
}