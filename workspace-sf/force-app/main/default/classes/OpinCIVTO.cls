/********************************************************************************************************************
* OpinCIVTO (Open Insurance)
* @author Squad_VidaDoSeuJeito
* @date 08/10/2021
* Classe para tratamento das responses do CIV criada por conta da história PLV-5230
*********************************************************************************************************************/

public class OpinCIVTO {
    public class ResponseOpinCIVTO {
        public Boolean routed   { get; set; }           
    }

    public class ResponseRequestErrorOpinCIVTO {
        public String error     { get; set; }           
        public String reason    { get; set; }
    }
}