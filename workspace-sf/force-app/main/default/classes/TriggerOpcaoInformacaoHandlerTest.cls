/*********************************************************************************************************************************************************************
@description  Valida a handler do trigger.
@author Carlos Pessoa - META
@date 12/05/2021
@Classe criada por conta da história PLV-4946    
**********************************************************************************************************************************************************************/

@isTest
public class TriggerOpcaoInformacaoHandlerTest {
    public TriggerOpcaoInformacaoHandlerTest() {

    }

    @isTest
    static void test01(){
        
		ContadorCodigo__c contadorCodigoTEC = (ContadorCodigo__c) new ContadorCodigoFactory.ProdutoTecnico().createRecord();

        ContadorCodigo__c contadorCodigoCom = (ContadorCodigo__c) new ContadorCodigoFactory.ProdutoComercial().createRecord();
        
        Product2 produtoTecnico = (Product2) new produtoFactory.ProdutoTecnico().createRecord();
        produtoTecnico.Status__c = 'Em ativação';
        produtoTecnico.NumeroSusep__c = '123';
        produtoTecnico.VersaoRenovacao__c = 'Versão atual';
        update produtoTecnico;
        produtoTecnico.Status__c = 'Ativo';
        update produtoTecnico;
        Product2 produtoComercial = (Product2) new produtoFactory.produtoComercial(produtoTecnico).createRecord();
        produtoComercial.Status__c = 'Ativo';
        update produtoComercial;

        TipoRemuneracao__c TipoRemuneracao = (TipoRemuneracao__c) new TipoRemuneracaoFactory().createRecord(); 

        remuneracaoProduto__c remuneracaoProduto = (remuneracaoProduto__c) new RemuneracaoProdutoFactory(TipoRemuneracao, produtoComercial).createRecord();

        RamoSeguro__c ramoSegurado = (RamoSeguro__c) new RamoSeguroFactory().createRecord();

        Garantia__c garantia = (garantia__c) new GarantiaFactory().createRecord();

        RamoGarantia__c ramoGarantia = (RamoGarantia__c) new RamoGarantiaFactory(garantia, ramoSegurado).createRecord(); 

        GarantiaProduto__c garantiaProdutoTEC = (GarantiaProduto__c) new GarantiaProdutoFactory.GarantiaProdutoTec(garantia, produtoTecnico, ramoSegurado).createRecord();

        GarantiaProduto__c garantiaProduto = (GarantiaProduto__c) new GarantiaProdutoFactory.GarantiaProdutoCom(produtoComercial, garantia, garantiaProdutoTEC, ramoSegurado).createRecord();
		//PLV - 4283 - INICIO
        garantiaProduto.LimiteMaximoCaracteristicaEspecial__c = 99; //PLV - 4283 INICIO/FIM - FIX 
        garantiaProduto.LimiteMinimoCaracteristicaEspecial__c = 1;  //PLV - 4283 INICIO/FIM - FIX
        update garantiaProduto;
		//PLV - 4283 - FIM
        
        

        Oferta__c Oferta = new Oferta__c(
            name = 'OfertaDaClasseTeste',
            produto__c = produtoComercial.id,
            VigenciaInicio__c = System.today(), //PLV-3690 - MVP B - Configurador de oferta - Criação de vigência da oferta e processo de ativação
            Ativo__c = false
        );
        insert Oferta;


        GeradorOferta__c gerador = new GeradorOferta__c();
		gerador.CodigoOfertaConsultiva__c = 'ABC';
		gerador.Status__c = 'Ativo';
		gerador.InicioVigencia__c = System.today();
		gerador.FinalVigencia__c = System.today().addDays(7);
		insert gerador;

		ConjuntoInformacoes__c conjunto = new ConjuntoInformacoes__c();
		conjunto.GeradorOfertas__c = gerador.Id;
		conjunto.Identificador__c = 123;
		conjunto.titulo__c = 'Conjunto X';
		conjunto.subtitulo__c = 'Subtitulo Conjunto X';
		insert conjunto;
        
        InformacaoOferta__c info = new InformacaoOferta__c();
		info.ConjuntoInformacoes__c = conjunto.Id;
		info.Id__c = 'ID_XPTO';
		info.Servico__c = 'Serviço X';
		info.tipo__c = 'Opções fixas';
		insert info;

		OpcaoInformacao__c opcao = new OpcaoInformacao__c();
		opcao.InformacaoOferta__c = info.Id;
		opcao.Codigo__c = '123';
        opcao.Default__c = true;
        insert opcao;

		OpcaoInformacao__c opcao2 = new OpcaoInformacao__c();
		opcao2.InformacaoOferta__c = info.Id;
		opcao2.Codigo__c = '1234';
        opcao2.Default__c = false;
        insert opcao2;

        try{
            OpcaoInformacao__c opcao3 = new OpcaoInformacao__c();
            opcao3.InformacaoOferta__c = info.Id;
            opcao3.Codigo__c = '1234';
            opcao3.Default__c = true;
            insert opcao3;
        }catch(Exception e){

        }
    }
}