/**
 * @author AVX - Alexandre Ferreira / Leonardo Camacho
 * @date 2019-10-30
 * @description: Criada para a história PLV_2928
 **/

public class OfertaTriggerHandler extends TriggerHandler {

    private List<Oferta__c> listOfertaNew {get;set;}
    private List<Oferta__c> listOfertaOld {get;set;}
    private Map<Id,Oferta__c> mapOfertaNew {get;set;}
    private Map<Id,Oferta__c> mapOfertaOld {get;set;}

    public OfertaTriggerHandler() {

        this.listOfertaNew = (List<Oferta__c>) Trigger.new;
        this.listOfertaOld = (List<Oferta__c>) Trigger.old;
        this.mapOfertaNew = (Map<Id,Oferta__c>) Trigger.newMap;
        this.mapOfertaOld = (Map<Id,Oferta__c>) Trigger.oldMap;
    }
    
    //PLV-2928 - INICIO - Atribuição de Oferta de Garantia e Oferta de Remuneração à oferta ao ser inserida. 
    public override void afterInsert(){
        this.criarOfertaGarantiaRemuneracaoProduto();
    }
    
    private void criarOfertaGarantiaRemuneracaoProduto(){

        set<Id> setIdProdutos = new Set<Id>();
        List<OfertaGarantiaProduto__c> listaOfertasGarantia = new List<OfertaGarantiaProduto__c>();
        List<OfertaRemuneracaoProduto__c> listaOfertasRemuneracao = new List<OfertaRemuneracaoProduto__c>();
        List<String> listaIdGarantias = new List<String>();
        Map<String, List<GarantiaProduto__c>> mapGarantiasProdutos = new Map<String, List<GarantiaProduto__c>>();
        
        for(Oferta__c oferta : this.listOfertaNew){
            setIdProdutos.add(oferta.produto__c);
        }

        if(setIdProdutos.isEmpty()) return;
        //PLV-3858 - INICIO - Ajuste na query
        Map<Id, Product2> mapProduto = new Map<Id, Product2>(
            [SELECT Id, (SELECT Name, Produto__c, Obrigatoria__c, CurrencyIsoCode
                            FROM GarantiasProduto__r 
                            WHERE Obrigatoria__c  = true),
                        (SELECT name, produto__c, Obrigatoria__c
                            FROM RemuneracoesProduto__r 
                            WHERE Obrigatoria__c  = true)
                        
            FROM Product2 
            WHERE Id IN :setIdProdutos]
        );
        //PLV-3858 - FIM
        if(mapProduto.isEmpty()) return;
        
        //Itera a lista de Ofertas recebidas
        for(Oferta__c oferta : this.listOfertaNew){
            //Procura o produto associado a oferta dentro do Mapa de produtos/garantias/remunerações
            if(!mapProduto.containsKey(oferta.produto__c)) continue;
            //Itera as Garantias do produto associado a Oferta dentro do Mapa
            Product2 produto = mapProduto.get(oferta.produto__c);
            
            for(GarantiaProduto__c garantiaProduto : produto.GarantiasProduto__r){
                //Cria o objeto Oferta de Garantia do Produto
                OfertaGarantiaProduto__c ofertaGarantiaProduto = new OfertaGarantiaProduto__c(
                    Oferta__c = oferta.Id,
                    GarantiaProduto__c = garantiaProduto.Id,
                    CurrencyIsoCode = garantiaProduto.CurrencyIsoCode //PLV-3858 - INICIO/FIM - Inclusão da moeda na inserção do registro
                );

                listaOfertasGarantia.add(ofertaGarantiaProduto);
            }

            for(RemuneracaoProduto__c remuneracaoProduto : produto.RemuneracoesProduto__r){
                //Cria o objeto Oferta de Remuneração do Produto
                OfertaRemuneracaoProduto__c OfertaRemuneracaoProduto = new OfertaRemuneracaoProduto__c(
                    Oferta__c = oferta.id,
                    RemuneracaoProduto__c = remuneracaoProduto.id
                );

                listaOfertasRemuneracao.add(OfertaRemuneracaoProduto);
            }            
        }

        insert listaOfertasGarantia;
        insert listaOfertasRemuneracao;
    }
    //PLV-2928 - INICIO - Atribuição de Oferta de Garantia e Oferta de Remuneração à oferta ao ser inserida.
}