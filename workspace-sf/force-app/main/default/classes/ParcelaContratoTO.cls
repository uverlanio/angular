/**
 * Created by Alessndro Ponte on 14/08/2018.
 */

public class ParcelaContratoTO {

    public Integer id {get;set;}
    public String idexterno {get;set;}
    public String codigoparceiro;
    public Integer idfatura;
    public Integer origemproposta;
    public String idproposta;
    public String numeropropostaporto;
    public String produto;
    public String apolice;
    public String empresa;
    public String sucursal;
    public String ramo;
    public String endosso;
    public String responsavelfinanceiro;
    public String tiporesponsavelpagamento;
    public String seguradosalesforce;
    public String vidasalesforce;
    public String datapagamento;
    public String datavencimento;
    public String dataemissao;
    public String datacancelamento;
    public Integer numeroparcela;
    public String status;
    public String titulo;
    public Decimal valoriof;
    public Decimal valorliquido;
    public Decimal valorparcela;
    public Decimal valorpago;
    public String antecipacaocomissao; //PLV-4344-Fix - Inicio/Fim
    public String datacobertura; //PLV-4532	
    public Decimal valoragenciamento; //PLV-4794
    public Decimal valorrestituicao; //PLV-4973
    public String statusIntegracao; //PLV-4674
}