/****
@description Classe para pagina de redirecionamento (Acesso externo ao portal)
@author Carlos Ponteli / Isabela Fin - Globant
@date 16/07/2020
@Classe referente a historia PLV-4039      
*****/
public with sharing class CtrCredentialVida {

    public String statusUsuario {get; set;}
    private String corsus;
    private String webusrcod;
    private String sesnum;
    private String codigoOfertaConsultiva;
    private String canalDistribuicao;
    private String meioComercializacao;
    private String entradaNegocio;
    
    private String cliente;
    private String corretagem;
    private String agenciamento;
    private String retencao; 

    public CtrCredentialVida() {
        this.corsus = Apexpages.currentPage().getParameters().get('corsus');
        this.webusrcod = Apexpages.currentPage().getParameters().get('webusrcod');
        this.sesnum = Apexpages.currentPage().getParameters().get('sesnum');
        this.codigoOfertaConsultiva = Apexpages.currentPage().getParameters().get('codigoOfertaConsultiva');
        this.canalDistribuicao = Apexpages.currentPage().getParameters().get('canalDistribuicao');
        this.meioComercializacao = Apexpages.currentPage().getParameters().get('meioComercializacao');
        this.entradaNegocio = Apexpages.currentPage().getParameters().get('entradaNegocio');

        this.cliente = Apexpages.currentPage().getParameters().get('cliente');
        this.corretagem = Apexpages.currentPage().getParameters().get('corretagem');
        this.agenciamento = Apexpages.currentPage().getParameters().get('agenciamento');
        this.retencao = Apexpages.currentPage().getParameters().get('retencao');
    }

    //MGRC-1657 - INICIO
    public PageReference doRedirect() {

        if(this.corsus != null && this.webusrcod != null && this.sesnum != null && this.codigoOfertaConsultiva != null &&
           this.canalDistribuicao != null && this.meioComercializacao != null && this.entradaNegocio != null) {

            this.corsus = this.corsus.replaceAll('[^a-zA-Z0-9]', '');
            this.webusrcod = this.webusrcod.replaceAll('[^a-zA-Z0-9]', '');
            this.sesnum = this.sesnum.replaceAll('[^a-zA-Z0-9]', '');
            this.codigoOfertaConsultiva = this.codigoOfertaConsultiva.replaceAll('[^a-zA-Z0-9]', '');
            this.canalDistribuicao = this.canalDistribuicao.replaceAll('[^a-zA-Z0-9]', '');
            this.meioComercializacao = this.meioComercializacao.replaceAll('[^a-zA-Z0-9]', '');
            this.entradaNegocio = this.entradaNegocio.replaceAll('[^a-zA-Z0-9]', '');

            ParamConsultaSessao param = new ParamConsultaSessao(this.corsus, this.webusrcod, this.sesnum);

            CIVServices civServ = CIVServices.getInstance();
            String resposta = ''; //civServ.consultaSessaoLegado(param.toString()); //MGRC-1657 - INICIO/FIM

            if(resposta == 'CIV Error'){
                this.statusUsuario = 'Ocorreu um erro inesperado. Por favor, tente novamente mais tarde.';
                return null;
            }

            Map<String,Object> mapResposta = (Map<String,Object>) JSON.deserializeUntyped(resposta);
            System.debug('mapResposta ' + mapResposta);

            if(mapResposta.containsKey('codigo') && mapResposta.get('codigo') == '0') {
                
                PageReference ref = Page.formulariosniper;
                FrmEntrada frm = new FrmEntrada(this.corsus, this.codigoOfertaConsultiva, this.canalDistribuicao, this.meioComercializacao, this.entradaNegocio);
                ref.getParameters().put('dados', frm.toString());
                ref.setRedirect(true);

                return ref;
            }
            else{
                PageReference ref = Page.formulariosniper;
                FrmEntrada frm = new FrmEntrada(this.corsus, this.codigoOfertaConsultiva, this.canalDistribuicao, this.meioComercializacao, this.entradaNegocio);
                ref.getParameters().put('dados', frm.toString());
                ref.setRedirect(true);

                return ref;
                //this.statusUsuario = 'Sessão inválida ou expirada.';
                //return null;
            }
        }
        else{
            this.statusUsuario = 'Usuário não autenticado.';
            return null;
        }
    }
    //MGRC-1657 - FIM
    
    private class ParamConsultaSessao {
        public String codigoUsuario {get; set;}
        public String numeroSessao  {get; set;}
        public String susepCorretor {get; set;}

        public ParamConsultaSessao(String susep, String cod, String sessao){
            this.codigoUsuario = cod;
            this.numeroSessao = sessao;
            this.susepCorretor = susep;
        }

        public override String toString(){
            return JSON.serialize(this);
        }
    }

    private class FrmEntrada {
        public Consultivo consultivo {get; set;}
        public Boolean    acao       {get; set;}

        public FrmEntrada(String susep, String codigoOfertaConsultiva, String canalDistribuicao, String meioComercializacao, String entradaNegocio){
            this.consultivo = new Consultivo(susep, codigoOfertaConsultiva, canalDistribuicao, meioComercializacao, entradaNegocio);
            this.acao       = false;
        }

        public override String toString(){
            return JSON.serializePretty(this);
        }
    }

    private class Consultivo {

        public String codigoOfertaConsultiva {get; set;}
        public String canalDistribuicao {get; set;}
        public String identificadorRepresentante {get; set;}
        public String meioComercializacao {get; set;} 
        public String entradaNegocio {get; set;}
        public Boolean voltar {get; set;} 

        public Consultivo(String susep, String codigoOferta, String canal, String meio, String entrada){
            this.codigoOfertaConsultiva = codigoOferta;
            this.canalDistribuicao = canal;
            this.identificadorRepresentante = susep;
            this.meioComercializacao = meio;
            this.entradaNegocio = entrada;
            this.voltar = false;
        }
    }
}