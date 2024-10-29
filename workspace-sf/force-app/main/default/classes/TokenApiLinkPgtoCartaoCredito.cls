/*
@description Gera link de pagamento é uma funcionalidade que permite o envio de um link para que o cliente
@author Uverlanio Pereira - Globant
@date 05/09/2022
@Classe criada por conta da história TKCL-263
*/
public class TokenApiLinkPgtoCartaoCredito {

    public String access_token {get; set;}
    public String token_type {get; set;}
    public Integer expires_in {get; set;}
    public String scope {get; set;}

    public TokenApiLinkPgtoCartaoCredito(String json) {
        TokenApiLinkPgtoCartaoCredito tokenObj = (TokenApiLinkPgtoCartaoCredito) System.JSON.deserialize(json, TokenApiLinkPgtoCartaoCredito.class);
        access_token = tokenObj.access_token;
        token_type = tokenObj.token_type;
        expires_in = tokenObj.expires_in;
        scope = tokenObj.scope;
    }
}