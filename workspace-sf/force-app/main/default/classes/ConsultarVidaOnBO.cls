/*********************************************************************************************************************************
 * Classe de Negocio implementada para consultar o Cpf e suas respectivas propostas e contratos do produto Vida ON para o heroku *
 * @author : Globant                                                                                                             *
 * @date 19/07/2022                                                                                                              *
 * Classe implementada tendo como origem a história AV-530                                                                       *
 * *******************************************************************************************************************************/

public class ConsultarVidaOnBO {

    private static final ConsultarVidaOnBO instancia = new ConsultarVidaOnBO();

    public static ConsultarVidaOnBO getInstance(){
        return instancia;
    }

    public List<String> ConsultarVidaOnBO(String jsonTransmissao) {
        List<String> retornoConsulta = new list<String>();
        System.debug('jsonTransmissao>> ' + jsonTransmissao);
        EmissaoTO.OfertasTO entrada = (EmissaoTO.OfertasTO) JSON.deserialize(jsonTransmissao, EmissaoTO.OfertasTO.class);
        System.debug('entrada.propostas[0].codigoProdutoVida: ' + entrada.propostas[0].codigoProdutoVida);
        if(entrada.propostas[0].codigoProdutoVida == 'VIDA_ON'){
            try{
                ContractBO.DadosCPFHeroku cpfConsulta = new ContractBO.DadosCPFHeroku();
                for(EmissaoTO proposta : entrada.propostas)
                {
                    cpfConsulta.numeroCpf = proposta.contratantes[0].pessoa.dadosPessoaFisica.numeroCpf + proposta.contratantes[0].pessoa.dadosPessoaFisica.digitoCpf;                
                }
                System.debug('cpfConsulta ale: ' + cpfConsulta);
                String consultaRequest = JSON.serialize(cpfConsulta);
                System.debug('consultaRequest: ' + consultaRequest);
    
                ResponseHerokuConsultarCPFVidaOn responseConsultarCPFVidaOn = HerokuService.getInstance().ConsultarCPFVidaOn(consultaRequest);
                System.debug('responseConsultarCPFVidaOn: ' + responseConsultarCPFVidaOn);
                String jsonResponseGravar = JSON.serialize(responseConsultarCPFVidaOn);
                      
                ResponseHerokuConsultarCPFVidaOn consultaResponse = (ResponseHerokuConsultarCPFVidaOn) JSON.deserialize(jsonResponseGravar, ResponseHerokuConsultarCPFVidaOn.class);
                System.debug('consultaResponse.dados[0].podeContratar: ' + consultaResponse.dados[0].podeContratar);
                
                retornoConsulta.add(String.valueOf(consultaResponse.dados[0].podeContratar));
                retornoConsulta.add(consultaResponse.descricao);
                return retornoConsulta;
            }
            catch(Exception ex){
                System.debug('###### ERROR: (' + ex.getLineNumber() + '): ' + ex.getMessage() + ' st=' +ex.getStackTraceString());
                throw new ConsultarVidaOnBOException('O seguinte ERRO ocorreu: ' + ex.getMessage() + ', ' + ex.getStackTraceString());	
            }
        }
        return retornoConsulta;
    }
    //AV-531 INICIO
    public String consultaSeguroAtivo(String CPF){
        System.debug('Entrou no consultaSeguroAtivo');
        ContractBO.DadosCPF cpfConsulta = new ContractBO.DadosCPF();
        String seguroCPFAtivo;
        cpfConsulta.cpf = CPF;

        // MGRC-1255 - INICIO
        // String retornoLTM = CIVServices.getInstance().servicoConsultaCPFativoLTM(JSON.serialize(cpfConsulta));
        String retornoLTM = SensediaServices.getInstance().montagemServicoSensedia(SensediaServices.VERB.POST, SensediaServices.DOMAIN.AWS_EXTERNO, SensediaServices.CONSULTA_CPF_ATIVO_LTM, JSON.serialize(cpfConsulta));
        // MGRC-1255 - FIM

        System.debug('retornoLTM Danilo ' + retornoLTM);
        if(retornoLTM != null){
            Boolean multiplosSeguros = retornoLTM.contains('"seguroVida":[');
            Boolean multiplasParcelas = retornoLTM.contains('"parcelaSeguroVida":[');
            if(multiplasParcelas && !multiplosSeguros){
                ContractBO.RetornoCIVConsultaLTMList retObject = new ContractBO.RetornoCIVConsultaLTMList();
                retObject = (ContractBO.RetornoCIVConsultaLTMList) JSON.deserialize(retornoLTM, ContractBO.RetornoCIVConsultaLTMList.class);
                System.debug('Danilo vida On retorno' + retObject);
                seguroCPFAtivo = retObject.seguroVidaOnAtivo;
            }else if(!multiplasParcelas && !multiplosSeguros){
                ContractBO.RetornoCIVConsultaLTMObject retObject = new ContractBO.RetornoCIVConsultaLTMObject();
                retObject = (ContractBO.RetornoCIVConsultaLTMObject) JSON.deserialize(retornoLTM, ContractBO.RetornoCIVConsultaLTMObject.class);
                System.debug('Danilo vida On retorno' + retObject);
                seguroCPFAtivo = retObject.seguroVidaOnAtivo;
            }else if(multiplasParcelas && multiplosSeguros){
                ContractBO.RetornoCIVConsultaLTMMultiSegurosList retObject = new ContractBO.RetornoCIVConsultaLTMMultiSegurosList();
                retObject = (ContractBO.RetornoCIVConsultaLTMMultiSegurosList) JSON.deserialize(retornoLTM, ContractBO.RetornoCIVConsultaLTMMultiSegurosList.class);
                System.debug('Danilo vida On retorno' + retObject);
                seguroCPFAtivo = retObject.seguroVidaOnAtivo;
            }else{
                ContractBO.RetornoCIVConsultaLTMMultiSegurosObject retObject = new ContractBO.RetornoCIVConsultaLTMMultiSegurosObject();
                retObject = (ContractBO.RetornoCIVConsultaLTMMultiSegurosObject) JSON.deserialize(retornoLTM, ContractBO.RetornoCIVConsultaLTMMultiSegurosObject.class);
                System.debug('Danilo vida On retorno' + retObject);
                seguroCPFAtivo = retObject.seguroVidaOnAtivo;
            }
        }
        return seguroCPFAtivo;
    }
	//AV-531 FIM
    
    public class ConsultarVidaOnBOException extends Exception {}

    public class ResponseHerokuConsultarCPFVidaOn{
        
        public String servico                               {get;set;}
        public String status                                {get;set;}  
        public Integer codigoprocessamento                  {get;set;}
        public String dataexecucao                          {get;set;}
        public String descricao                             {get;set;}
        public List<infoGravaCPF> dados                     {get;set;}
    }
    public class infoGravaCPF{
        
        public List<ListCPF> Cpf                            {get;set;}
        public Boolean podeContratar                        {get;set;}            
    }
    public class listCPF{
        public string numeroCpf                             {get;set;}
    }
}