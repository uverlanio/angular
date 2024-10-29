/**
 * Created by Alessandro Ponte on 03/09/2018.
 */

public with sharing class TituloCapitalizacaoTO {
    public String Nm_empresa;
    public String Nr_cnpj;
    public String Cd_promocao;
    public List<CessionarioTO> Cessionario;

    public class CessionarioTO{
        public String Cd_cessionario;
        public Decimal vr_titulo;
        public Integer nr_lote;
        public Integer nr_sorte;
    }
}