//LECVP-72 - INICIO
public with sharing class BCPContratoTcktTO {    

    public Boolean chamouBCP { get; set;}
    public String mensagem { get; set; }
    public String origem { get; set; }
    public String proposta { get; set; }
    public RespostaBCP respostaBCP { get; set; }

    public class RespostaBCP{
        public String numeroSequenciaControle { get; set; }
        public String codigo { get; set; }
    }
}
//LECVP-72 - INICIO