/*PLV-4632 - CRIADO EM 22/11/2020
AUTOR: JEFERSON SANTANA
DESCRIÇÃO: classe responsável por criar as variaveis do VF
*/
public class CartaRecusaController {
    public Integer dia {get;set;}
    public String mes {get;set;}
    public String nomeCorretor {get;set;}
    public String nomeSegurado {get;set;}
    public String produto {get;set;}
    public String mumeroSinistro {get;set;}
    public String observacao {get;set;}
    
    public CartaRecusaController(){
       
        Date data = Date.today();
        dia = data.day();
        Integer m = data.month();
        Map<Integer,String> mapMes = new Map<Integer,String>{1=>'Janeiro',2=>'Fevereiro',3=>'Março',4=>'Abril',5=>'Maio',6=>'Junho',7=>'Juhlo',
            													8=>'Agosto',9=>'Setembro',10=>'Outubro',11=>'Novembro',12=>'Dezembro'};
                                                                    
        mes = mapMes.get(m);
               
        nomeCorretor = ApexPages.currentPage().getParameters().get('nomeCorretor');
        nomeSegurado = ApexPages.currentPage().getParameters().get('nomeSegurado');
        produto = ApexPages.currentPage().getParameters().get('produto');
        mumeroSinistro = ApexPages.currentPage().getParameters().get('mumeroSinistro');
       
        observacao =  ApexPages.currentPage().getParameters().get('observacao');
        
        
        
       
    }
    
}