//ANNVI-208 - INICIO
public with sharing class ConsultarDadosPessoaBCPTO {
    
    public static final ConsultarDadosPessoaBCPTO instance = new ConsultarDadosPessoaBCPTO();

    public String nomeCompleto {get; set;}
    public String dataNascimento {get; set;}
    public String sexo {get; set;}

    public static ConsultarDadosPessoaBCPTO getInstance() {
        return instance;
    }
}
//ANNVI-208 - FIM