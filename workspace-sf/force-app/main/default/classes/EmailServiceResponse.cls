global class EmailServiceResponse{

   // #PLV-3718 - Reenvio de e-mail do kit boas vindas - apólices

    public class Meta {
        public String dataExecucao;
        public String mensagem;
        public String servico;
        public Integer statusHttp;
    }

    public class Data {
        public Integer statusChamada;
        public String descricaoChamada;
        public List<String> apolice;
    }
    
    public Data data;
    public Meta meta;
    
       // #PLV-3718 - FIM
}