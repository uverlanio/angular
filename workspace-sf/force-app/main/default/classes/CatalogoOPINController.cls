//PLV-5230 - INICIO
/*
/*  @author: Squad Globant 
/*  @description: Controller responsável pelas ações presentes na página de Catálogos OPIN
/*  @modifiedAt: 08/12/2021
/*/
public class CatalogoOPINController {
    
    //PLV-5230 - FIX02 - INICIO
    public static final String MSG_SUCESSOGERACAO = 'Catálogo de Produtos OPIN gerado com sucesso (max. 40 produtos por click)';
    public static final String MSG_SUCESSOTRANSMISSAO = 'Catalogo de Produtos OPIN transmitido com Sucesso';
    //PLV-5230 - FIX02 - FIM

    @AuraEnabled
    public static String gerarBaseProdutosOpin() {
        
        RetornoAcaoBotaoTO retorno = new RetornoAcaoBotaoTO();

        try {
            
            IntegracaoOpin.getInstance().gerarProdutoOPIN();

            retorno.tipo = RetornoAcaoBotaoTO.SUCCESS;
            retorno.mensagens.add(MSG_SUCESSOGERACAO); //PLV-5230 - FIX02 - INICIO/FIM
            
        } catch (Exception e) {
            retorno.tipo = RetornoAcaoBotaoTO.ERROR;
            retorno.mensagens.add(e.getMessage());
        }

        return JSON.serialize(retorno);
    }

    @AuraEnabled
    public static String transmitirBaseProdutosOpin() {
        
        RetornoAcaoBotaoTO retorno = new RetornoAcaoBotaoTO();
        try {

            IntegracaoOpin.getInstance().enviarTodosProdutosOPIN();

            retorno.tipo = RetornoAcaoBotaoTO.SUCCESS;
            retorno.mensagens.add(MSG_SUCESSOTRANSMISSAO); //PLV-5230 - FIX02 - INICIO/FIM
            
        } catch (Exception e) {
            retorno.tipo = RetornoAcaoBotaoTO.ERROR;
            retorno.mensagens.add(e.getMessage());
        }

        return JSON.serialize(retorno);

    }
}
//PLV-5230 - FIM