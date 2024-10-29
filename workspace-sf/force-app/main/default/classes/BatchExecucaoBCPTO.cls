public with sharing class BatchExecucaoBCPTO {
    public class consultarBCPRetorno{
        public String servico                              {get;set;}
        public String status                               {get;set;}
        public Decimal codigoProcessamento                 {get;set;}
        public String dataExecucao                         {get;set;}
        public String descricao                            {get;set;}
        public List<consultarBCPdados> dados               {get;set;}
    }
    public class consultarBCPdados{
        public List<consultarBCPregistros> registros       {get;set;}
        public Integer totalRegistros                      {get;set;}
    }

    public class consultarBCPregistros {
        public String numeroProposta                       {get;set;}
    }
}