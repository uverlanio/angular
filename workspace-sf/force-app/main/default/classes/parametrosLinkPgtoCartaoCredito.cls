public with sharing class parametrosLinkPgtoCartaoCredito {


        public class ConfiguracaoPagamento {
            public Produto produto;
            public CartaoCredito cartaoCredito;
            public List<Contratos> contratos;
          }
        
          public Integer expiraEm;
          public ConfiguracaoPagamento configuracaoPagamento;
        
          public class Contratos {
            public String descricao;
            public Double valorTotal;
            public String idExterno;
          }
        
          public class CartaoCredito {}
        
          public class Produto {
            public String codProduto;
            public String nomeVertical;
            public String nomeProduto;
            public String icone;
          }
        
          
          public static parametrosLinkPgtoCartaoCredito parse(String json) {
            return (parametrosLinkPgtoCartaoCredito) System.JSON.deserialize(json, parametrosLinkPgtoCartaoCredito.class);
          }
    
}