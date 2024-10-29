//PLV-5099 INICIO
public class SyncHerokuResponseTO {
    public MetaTO meta { get; set; }

  public class MetaTO{
    public String dataExecucao { get; set; }
    public String servico { get; set; }
    public Integer statusHttp { get; set; }
    public String mensagem { get; set; }
  }

  public class TituloTO extends HerokuResponseTO{
    public TituloDetalheTO data { get; set; }
  }

  public class LoteTO extends HerokuResponseTO{
    public List<LoteTODetalhe> data { get; set; }
  }

  public class ArquivoECMTO extends HerokuResponseTO{
    public List<ArquivoECMTODetalhe> data { get; set; }
  }

  public class ApoliceTO extends HerokuResponseTO{
    public Map<String, String> data { get; set; }
  }

  public class TituloDetalheTO{
    public Integer lote { get;set; }
    public String nome { get;set; }
    public String status { get;set; }
    public List<String> numeros { get;set; }
  }

  public class LoteTODetalhe{
    public Integer idlote;
    public String produto;
    public String dataregistro;
    public String codigoparceiro;
    public String status;
    public String quantidade;
  }

  public class ArquivoECMTODetalhe{
    public Id idsf { get; set; }
    public String idecm { get; set; }
    public String nomearquivo { get; set; }
    public DateTime datainclusao { get; set; }
    public String tipoarquivo { get; set; }
    public Integer id { get; set; }
  }

  public class HerokuResponseErrorTO{
    public HerokuResponseErrorDetailTO error;
  }

  public class HerokuResponseErrorDetailTO{

    public Integer statusCode { get; set; }
    public String message { get; set; }

  }
}
//PLV-5099 FIM