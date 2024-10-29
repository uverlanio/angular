/****************************
@description  Classe que contém a regra para reenvio de link de solicitação de informações do cartão de crédito na proposta.
@author Andreza R. e Luiz N. - SYS4B
@date 07/02/2023
@Classe criada por conta da história RVI-223        
****************************/

public class CreditCardInformationController {

    @AuraEnabled(cacheable=true)
    public static String linkValidations(){

        String profileName = [SELECT Name FROM profile WHERE id = :UserInfo.getProfileId()].Name;
        return profileName;      
    }

    // ********************* RVI 223 - INICIO ************************ //
    
    @AuraEnabled(cacheable=true)
    public static String resendLinkCard(String dadosEmailRequest, String dadosPropostaRequest){


          RestResponseEmail resp = new RestResponseEmail(); 

          try {
              
          API_Link_de_Pagamento__mdt mtd = API_Link_de_Pagamento__mdt.getInstance('API_Link_de_Pagamento_Email');
          APITokenizacaoService service = new APITokenizacaoService();
      
          HttpResponse tokenResponse = service.getToken(mtd);
          String tokenMensagem = '';
          tokenMensagem = tokenResponse.getBody();
      
          system.debug('tokenMensagem '+ tokenMensagem);
      
          TokenApiLinkPgtoCartaoCredito tokenApiLinkPgtoCartaoCredito = new TokenApiLinkPgtoCartaoCredito(tokenResponse.getBody());
          HttpResponse urlResponse = new HttpResponse();
      

          DadosProposta dadosProposta = (DadosProposta) System.JSON.deserialize(dadosPropostaRequest, DadosProposta.class);
          String jsonRequest  = getParamsRequest(dadosProposta);

          urlResponse = service.getLinkPgtoCartaoCredito(jsonRequest, mtd, tokenApiLinkPgtoCartaoCredito);
      
          Link linkEmail = new Link();
          linkEmail = (Link) System.JSON.deserialize(urlResponse.getBody(), Link.class);
      
          if(urlResponse.getStatusCode() == 200 && !String.isEmpty(linkEmail.link)){
            EnviaEmailLink.Input dadosEmail = new EnviaEmailLink.Input();
            dadosEmail = EnviaEmailLink.parse(dadosEmailRequest);
            dadosEmail.link = linkEmail.link;   
            EnviaEmailLink.formatarEmail(dadosEmail);
            resp.success = true;
            resp.message = 'Email enviado com sucesso';

          }else{
            resp.success = false;
            resp.message = 'Erro na geração do reenvio do link';
          }
      
          } catch (Exception ex) {
              
              System.debug('Error resend link ' + ex.getMessage()); 
              resp.success = false;
              resp.message = ex.getMessage();
          }

          return JSON.serialize(resp);

  }

  public static String getParamsRequest(DadosProposta proposta) {

    parametrosLinkPgtoCartaoCredito params = new parametrosLinkPgtoCartaoCredito();
    params.expiraEm = 100800;

    parametrosLinkPgtoCartaoCredito.Produto produto = new parametrosLinkPgtoCartaoCredito.Produto();
    produto.codProduto = '8b4da283-389d-47d5-83f0-fd8fc6d02708';
    produto.nomeVertical = 'Vida e Previdência';
    produto.nomeProduto = 'Vida do Seu Jeito';
    produto.icone = 'vida_previdencia';
    
    parametrosLinkPgtoCartaoCredito.CartaoCredito cartaoCredito = new parametrosLinkPgtoCartaoCredito.CartaoCredito();

    parametrosLinkPgtoCartaoCredito.Contratos contrato = new parametrosLinkPgtoCartaoCredito.Contratos();
    contrato.descricao = '';
    contrato.valorTotal = proposta.premioTotal;
    contrato.idExterno = proposta.numeroProposta;
    
    parametrosLinkPgtoCartaoCredito.ConfiguracaoPagamento configuracaoPagamento = new parametrosLinkPgtoCartaoCredito.ConfiguracaoPagamento();
    
    List<parametrosLinkPgtoCartaoCredito.Contratos> contratoList = new List<parametrosLinkPgtoCartaoCredito.Contratos>();
    contratoList.Add(contrato);
    configuracaoPagamento.produto = produto;
    configuracaoPagamento.cartaoCredito = cartaoCredito;
    configuracaoPagamento.contratos = contratoList;

    params.configuracaoPagamento = configuracaoPagamento;

    return JSON.serialize(params);
  }

   public class Link {
    public String link; 
   }

   public class RestResponseEmail {
    public Boolean success;
    public String message;
   }

   public class DadosProposta {
     public Integer qtdeParcelas; 
     public Double premioTotal; 
     public String numeroProposta; 
   }

  
   // ********************* RVI 223 - FIM ************************ //
}