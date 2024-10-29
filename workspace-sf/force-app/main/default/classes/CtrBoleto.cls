/**
 * @author Pedro Augusto Braz (Sys4B)
 * @date 31/12/2020
 * @description Controller da VFGerarBoleto - responsável por exibir os boletos bancários
 * Classe criada por conta da história PLV-4572
 */
public with sharing class CtrBoleto {
    
    public CtrBoleto() {}

    public ObjBoleto boleto {get;set;}

    public class ObjBoleto {
        public String idcontrato {get;set;}
        public String status {get;set;}
        public String nossonumero {get;set;}
        public String numerodocumento {get;set;}
        public Date vencimento {get;set;}
        public String agenciacodigocedente {get;set;}
        public String especie {get;set;}
        public String sacado {get;set;}
        public String numexternoparceironegocio {get;set;}
        public String susep {get;set;}
        public String corretor {get;set;}
        public String banco {get;set;}
        public String codigobanco {get;set;}
        public String codigodigitavel {get;set;}
        public String localpagamento {get;set;}
        public Date datadocumento {get;set;}
        public String especiedocumento {get;set;}
        public String aceite {get;set;}
        public String usobanco {get;set;}
        public String carteira {get;set;}
        public String instrucao1 {get;set;}
        public String instrucao2 {get;set;}
        public String instrucao3 {get;set;}
        public String instrucao4 {get;set;}
        public String instrucao5 {get;set;}
        public String instrucao6 {get;set;}
        public String instrucao7 {get;set;}
        public String instrucao8 {get;set;}
        public String mensagemobrigatoria {get;set;}
        public String mensagemobrigatoria2 {get;set;}
        public String empresa {get;set;}
        public String viaboleto {get;set;}
        public String sucursal {get;set;}
        public String ramo {get;set;}
        public String numeroapolice {get;set;}
        public String numeroendosso {get;set;}
        public String numeroparcela {get;set;}
        public Date datacriacao {get;set;}
        public Date dataprocessamento {get;set;}
        public Time horacriacao {get;set;}
        public Decimal id {get;set;}
        public String urlboleto {get;set;}
        public Decimal quantidadevalorcontrato {get;set;}
        public String cedente {get;set;} //RVI-204 - INICIO/FIM


        public String gerarNumerodocumento(String numeroparcela,String codigoSucursal,String codigoRamo,String numeroApolice,String endosso){
            return String.valueOf(codigoSucursal.trim().leftPad(3,'0') +
                codigoRamo.trim()+
                numeroApolice.trim().leftPad(9,'0') + '.' +
                endosso.trim().leftPad(9,'0')+ '.' +
                numeroparcela.trim().leftPad(3,'0'));
        }

        //RVI-204 - INICIO
        public String getCedente(String codEmpresa){
            String codEmpresaTratamento = codEmpresa.replaceAll(' ','');
            List<CedenteBoleto__mdt> cedenteBoletoLs = [SELECT CodigoEmpresa__c, TextoCedente__c
                                                        FROM CedenteBoleto__mdt WHERE CodigoEmpresa__c =:codEmpresaTratamento];
            System.debug('texto ' + cedenteBoletoLs[0].TextoCedente__c);
            return cedenteBoletoLs[0].TextoCedente__c;                                                             
        }
        //RVI-204 - FIM


        public ObjBoleto DTO_Boleto(public_boleto__x boleto){
            ObjBoleto boletoToReturn = new ObjBoleto();
            boletoToReturn.idcontrato                      = boleto.idcontrato__c;
            boletoToReturn.status                          = boleto.status__c;
            boletoToReturn.nossonumero                     = boleto.nossonumero__c;
            boletoToReturn.numerodocumento                 = boleto.numerodocumento__c;
            boletoToReturn.vencimento                      = boleto.vencimento__c;
            boletoToReturn.agenciacodigocedente            = boleto.agenciacodigocedente__c;
            boletoToReturn.especie                         = boleto.especie__c;
            boletoToReturn.sacado                          = boleto.sacado__c;
														   //PLV - 4572 INICIO
            boletoToReturn.numexternoparceironegocio       = (boleto.numexternoparceironegocio__c.left(3) + '.' + 
                                                              boleto.numexternoparceironegocio__c.substring(3, 6) + '.' + 
                                                              boleto.numexternoparceironegocio__c.substring(6, 9) + '-' + 
                                                              boleto.numexternoparceironegocio__c.substring(9, 11)
                                                             );
														   //PLV - 4572 FIM

            boletoToReturn.susep                           = boleto.susep__c;
            boletoToReturn.corretor                        = boleto.corretor__c;
            boletoToReturn.banco                           = boleto.banco__c;
            boletoToReturn.codigobanco                     = boleto.codigobanco__c;
            boletoToReturn.codigodigitavel                 = boleto.codigodigitavel__c;
            boletoToReturn.localpagamento                  = boleto.localpagamento__c;
            boletoToReturn.datadocumento                   = boleto.datadocumento__c;
            boletoToReturn.especiedocumento                = boleto.especiedocumento__c;
            boletoToReturn.aceite                          = boleto.aceite__c;
            boletoToReturn.usobanco                        = boleto.usobanco__c;
            boletoToReturn.carteira                        = boleto.carteira__c;
            boletoToReturn.instrucao1                      = boleto.instrucao1__c;
            boletoToReturn.instrucao2                      = boleto.instrucao2__c;
            boletoToReturn.instrucao3                      = boleto.instrucao3__c;
            boletoToReturn.instrucao4                      = boleto.instrucao4__c;
            boletoToReturn.instrucao5                      = boleto.instrucao5__c;
            boletoToReturn.instrucao6                      = boleto.instrucao6__c;
            boletoToReturn.instrucao7                      = boleto.instrucao7__c;
            boletoToReturn.instrucao8                      = boleto.instrucao8__c;
            boletoToReturn.mensagemobrigatoria             = boleto.mensagemobrigatoria__c;
            boletoToReturn.mensagemobrigatoria2            = boleto.mensagemobrigatoria2__c;
            boletoToReturn.empresa                         = boleto.empresa__c;
            boletoToReturn.viaboleto                       = boleto.viaboleto__c;
            boletoToReturn.sucursal                        = boleto.sucursal__c;
            boletoToReturn.ramo                            = boleto.ramo__c;
            boletoToReturn.numeroapolice                   = gerarNumerodocumento(boleto.numeroparcela__c,boleto.sucursal__c,boleto.ramo__c,boleto.numeroapolice__c,boleto.numeroendosso__c);
            boletoToReturn.numeroendosso                   = boleto.numeroendosso__c;
            boletoToReturn.numeroparcela                   = boleto.numeroparcela__c;
            boletoToReturn.datacriacao                     = boleto.datacriacao__c;
            boletoToReturn.dataprocessamento               = boleto.dataprocessamento__c;
            boletoToReturn.id                              = boleto.id__c;
            boletoToReturn.urlboleto                       = boleto.urlboleto__c;
            boletoToReturn.quantidadevalorcontrato         = boleto.quantidadevalorcontrato__c;
            boletoToReturn.cedente                         = getCedente(boleto.empresa__c); //RVI-204 - INICIO/FIM

            return boletoToReturn;
        }       
    }


    public void getBoletoData() {        
        String token = apexpages.currentPage().getParameters().get('token');
        System.debug('TOKEN'+token);
        token = String.isNotBlank(token)? token.replace(' ','+') : '';//DEVIDO A SER GET (PASSAGEM NA URL) O + ACABA SENDO CONVERTIDO EM ESPAÇO, POR ESSE MOTIVO EXISTE O REPLACE
        public_boleto__x boletoFind = new public_boleto__x(); //RVI-204 - INICIO/FIM
        if(String.isNotBlank(token)){
            if (!System.Test.isRunningTest()) { //RVI-204 - INICIO/FIM
                boletoFind = [SELECT ExternalId
                                                        , idcontrato__c
                                                        , status__c
                                                        , nossonumero__c
                                                        , numerodocumento__c
                                                        , vencimento__c
                                                        , agenciacodigocedente__c
                                                        , especie__c
                                                        , sacado__c
                                                        , numexternoparceironegocio__c
                                                        , susep__c
                                                        , corretor__c
                                                        , banco__c
                                                        , codigobanco__c
                                                        , codigodigitavel__c
                                                        , localpagamento__c
                                                        , datadocumento__c
                                                        , especiedocumento__c
                                                        , aceite__c
                                                        , usobanco__c
                                                        , carteira__c
                                                        , instrucao1__c
                                                        , instrucao2__c
                                                        , instrucao3__c
                                                        , instrucao4__c
                                                        , instrucao5__c
                                                        , instrucao6__c
                                                        , instrucao7__c
                                                        , instrucao8__c
                                                        , mensagemobrigatoria__c
                                                        , mensagemobrigatoria2__c
                                                        , empresa__c
                                                        , viaboleto__c
                                                        , sucursal__c
                                                        , ramo__c
                                                        , numeroapolice__c
                                                        , numeroendosso__c
                                                        , numeroparcela__c
                                                        , datacriacao__c
                                                        , dataprocessamento__c
                                                        , id__c
                                                        , urlboleto__c
                                                        , quantidadevalorcontrato__c
                                                        FROM public_boleto__x
                                                        WHERE urlboleto__c =:token];
            }
            //RVI-204 - INICIO
            else{
                String payloadName = 'PayloadBoletoTeste';
                StaticResource payloadBoleto = [SELECT Id, Body FROM StaticResource WHERE Name =: payloadName LIMIT 1];
                String jsonBoleto = payloadBoleto.Body.toString();
                boletoFind = (public_boleto__x) JSON.deserialize(jsonBoleto, public_boleto__x.class);
            }
            //RVI-204 - FIM

            if(boletoFind!=null){
                this.boleto = new ObjBoleto().DTO_Boleto(boletoFind);
            }else {
                throw new BoletoException('Registro não encontrado');
            }
        }else {
            throw new BoletoException('Identificador não encontrado');
        }
    }
    public class BoletoException extends Exception {}
}