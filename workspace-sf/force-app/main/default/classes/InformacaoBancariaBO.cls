/**
 * InformacaoBancariaBO 
 * @author Fernando Barcellos @ 06/02/2018
 * @modified GFS 18/01/2019
 * @Linhas criadas pela Avanxo da 53 até a 141
 **/
public without sharing class InformacaoBancariaBO {
    
    private static String msg;
    private static final InformacaoBancariaBO instancia = new InformacaoBancariaBO();
    private static InformacaoBancariaDAO dao = InformacaoBancariaDAO.getInstance();
        
    private InformacaoBancariaBO() { 
        String[] success;
    }

    public static InformacaoBancariaBO getInstance(){
        return instancia;
    }

    /**
     * verificarDuplicidade - Não permite o cadastro de uma nova informação 
     * bancária (Banco, Agência e Número da conta) para uma mesma conta (Account)
     **/
    /*public void verificarDuplicidade(List<InformacaoBancaria__c> informacoesBancarias) {
        if(checkRecursive.runOnce())
    {
        Map<String, InformacaoBancaria__c> mapIdExternoInformacaoBancaria = new Map<String, InformacaoBancaria__c>();
        for (InformacaoBancaria__c ib : informacoesBancarias) {
            
            if (ib.IdExterno__c != null)  {
                mapIdExternoInformacaoBancaria.put(ib.IdExterno__c, ib);
            }   
        
        }
        
        List<InformacaoBancaria__c> informacoesBancariasExistentes = dao.buscarInformacoesBancariasPorIdExterno(mapIdExternoInformacaoBancaria.keySet());
        
        if (informacoesBancariasExistentes.size() > 0) {
            
            for (InformacaoBancaria__c ib : informacoesBancariasExistentes) {
                InformacaoBancaria__c ib2 = mapIdExternoInformacaoBancaria.get(ib.IdExterno__c);
        
                if(ib.Id != ib2.Id)
                    ib2.addError('Esta informação bancária já existe para esta conta.');
            }
        }
    }
    }*/

    //PLV-4293 INICIO
    //PLV-4440 INICIO
    public static Map<Id,Banco__c> getMapBancos() {
        Map<Id,Banco__c> result = new Map<Id,Banco__c>();

        List<Banco__c> bancos = [
            SELECT Id
                ,CodigoBanco__c
                ,Name
            FROM Banco__c
            WHERE Ativo__c = true
            LIMIT 10000
        ];

        if(bancos.size() > 0) {
            for (Banco__c banco : bancos) {
                result.put(banco.Id, banco);
            }
        }

        return result;
    }
    //PLV-4440 FIM
    //PLV-4293 FIM

    //AVX SP26 - PLV-1690 -- Diego Zampieri
    public void preencherNomenclaturaInformacaoBancaria(List<InformacaoBancaria__c> lstInfBanc){
		//PLV-4363 - INICIO
        /*List<Schema.PicklistEntry> lPe  = Schema.getGlobalDescribe().get('InformacaoBancaria__c').getDescribe().Fields.getMap().get('Banco__c').getDescribe().getPicklistValues();
        Map<String,String> mString = new Map<String,String>();
        for(Schema.PicklistEntry pe : lPe){
           mString.put(pe.getValue(), pe.getLabel());
        }*/
        
        //PLV-4293 INICIO
        Map<Id,Banco__c> mBancos = getMapBancos();
		system.debug('map bancos'+mBancos);
        for(InformacaoBancaria__c ib : lstInfBanc){
            //system.debug('banco relacionado'+mBancos.get(ib.BancoNew__c).Name);
            //String vLabelBanco = mString.get(ib.Banco__c);
            //System.debug('ISA BancoNew__c ' + ib.BancoNew__c);
            //PLV-4445 INICIO
            if (ib.BancoNew__c != null && mBancos.containsKey(ib.BancoNew__c)) {
                ib.Banco__c = mBancos.get(ib.BancoNew__c).CodigoBanco__c;
                ib.NomenclaturaPesquisa__c = mBancos.get(ib.BancoNew__c).Name + '-' + ib.Agencia__c + '-' + ib.NumeroConta__c; //PLV-4363 - FIX3 - INICIO/FIM
                System.debug('nomeclatura'+ ib.NomenclaturaPesquisa__c);
            }
            //PLV-4445 FIM  
        }
        //PLV-4363- FIM
        //PLV-4293 FIM
    }

    // 2666 - INICIO
    public static String getIdExterno(InformacaoBancaria__c pInformacaoBancaria) {
        //PLV-3918-FIX6 - INCIO
        //PLV-3918-FIX7 - INCIO
        
        //PLV-4363 - INICIO
        //PLV-4363 - FIX3 - INICIO
        Banco__c banco = [SELECT CodigoBanco__c FROM Banco__c where Id =: pInformacaoBancaria.BancoNew__c];
        return pInformacaoBancaria.Conta__c + banco.CodigoBanco__c + pInformacaoBancaria.Agencia__c.leftPad(4,'0') +
               pInformacaoBancaria.NumeroConta__c +'-'+ pInformacaoBancaria.Digito__c;
        //PLV-4363 - FIX3 - FIM
        //PLV-4363 - FIM
        
        //PLV-3918-FIX7 - FIM
        //PLV-3918-FIX6 - FIM
    }

    //PLV-4293 INICIO
    //PLV-4440 INICIO
    public static String getIdExterno(InformacaoBancaria__c pInformacaoBancaria, Map<Id, Banco__c> mBancos) {
        String result = '';

        if (mBancos.containsKey(pInformacaoBancaria.BancoNew__c)) {
            // PLV-4473
            result = pInformacaoBancaria.Conta__c + mBancos.get(pInformacaoBancaria.BancoNew__c).CodigoBanco__c + pInformacaoBancaria.Agencia__c.leftPad(4,'0') +
                pInformacaoBancaria.NumeroConta__c +'-'+ pInformacaoBancaria.Digito__c + '-' + pInformacaoBancaria.Papel__c;
        }

        return result;
    }
    //PLV-4440 FIM
    //PLV-4293 FIM

    public void setDefaultValues(List<InformacaoBancaria__c> plInformacaoBancaria) {

        //PLV-4293 INICIO
        Map<Id,Banco__c> mBancos = getMapBancos();
        //PLV-4293 FIM
        for (InformacaoBancaria__c informacaoBancaria : plInformacaoBancaria) {
			//PLV-3918-FIX6 - INCIO
			//PLV-3918-FIX7 - INCIO
			
            if (TriggerHelper.isChanged(informacaoBancaria, new Set<String>{'Conta__c', 'Banco__c', 'Agencia__c', 'NumeroConta__c', 'Digito__c','BancoNew__c'})) //PLV-4363 - INICIO/FIM
                //PLV-4293 INICIO
                informacaoBancaria.IdExterno__c = getIdExterno(informacaoBancaria, mBancos);
                //PLV-4293 FIM
            //PLV-3918-FIX7 - FIM
            //PLV-3918-FIX6 - FIM
        }
    }
    // 2666 - FIM
    
    //metodo que valida a composicao bancaria
    @AuraEnabled
    public static String validarComposicaoBancaria(String recordId){

        if(checkRecursive.runOnce())
    {
        system.debug(' executa pimeiro');
        List<BeneficiarioGarantia__c> Lstverificadadosnulo = [Select Informacao_Bancaria__c FROM BeneficiarioGarantia__c 
                                                              WHERE Id =: recordId];
        
        system.debug('Lstverificadadosnulo '+ Lstverificadadosnulo);
        if(Lstverificadadosnulo[0].Informacao_Bancaria__c == null)
        {
          msg = 'Dados Nulos';
          return msg;
        }
        
        String IdBeneficiario_da_garantia = recordId;
        String Idben;
        
        List<BeneficiarioGarantia__c> InfoBancaria = dao.buscarinfobancaria(IdBeneficiario_da_garantia);
        
        List<InformacaoBancaria__c> informacoesBancarias = dao.buscarinfobancariasdosbeneficiarios(InfoBancaria[0].Informacao_Bancaria__c) ;
        informacoesBancarias[0].StatusIntegracao__c = 'Não Validada';
        
        for(InformacaoBancaria__c ib : informacoesBancarias){ 
            //PLV-3918-FIX6 - INICIO
            //PLV-3918-FIX7 - INICIO
            String validarComposicaoBancariaTO = '{"DadosBancarios": {'+
                +'"banco": "'+ib.Banco__c+'",'
                +'"agencia": "'+ib.Agencia__c+'",'
                +'"contaCorrente": "'+ib.NumeroConta__c+'",'
                +'"digitoContaCorrente": "'+String.valueOf(ib.Digito__c)+'"}}';
            //PLV-3918-FIX7 - FIM
            //PLV-3918-FIX6 - FIM
                
            //Código removido por causa da história PLV-2310 para tratamento na class de teste 
                List<InformacaoBancaria__c> LstInfoBancaria = new List<InformacaoBancaria__c>();
                Idben = servicoValidarComposicaoBancaria(validarComposicaoBancariaTO, String.valueof(ib.id));
                
                System.debug('Idben '+ Idben);
                                      
            //Código removido por causa da história PLV-2310 para tratamento na class de teste 
        }

        List<InformacaoBancaria__c> Info2show = dao.buscarinfobancariasdosbeneficiarios(Idben);
        System.debug('Info2show '+ Info2show);
         
        if(Info2show[0].StatusIntegracao__c == 'Validada'){msg = 'Validada';}
        else
        {
            msg = 'Não Validada';
        }
    }
    return msg;
    }
    
 
    public static String servicoValidarComposicaoBancaria(String validarComposicaoBancariaTO, String recordId){
        system.debug('recordId'+recordId);
    
        Set<id> idInformacoesBancarias = new Set<id>();
        ValidarComposicaoBancariaTO composicaoBancaria = (ValidarComposicaoBancariaTO)JSON.deserialize(validarComposicaoBancariaTO, ValidarComposicaoBancariaTO.class);
        System.debug(validarComposicaoBancariaTO);
        System.debug(composicaoBancaria);
        
        String retorno; 
         
        List<InformacaoBancaria__c> Info2Update = new List<InformacaoBancaria__c>();
        
        if(InformacaoBancariaTriggerHandler.isFirstTime)
    {
        InformacaoBancariaTriggerHandler.isFirstTime = false;
        
        //Código removido por causa da história PLV-2310 para tratamento na class de teste 
        retorno = SensediaServices.getInstance().montagemServicoSensedia(SensediaServices.VERB.POST, SensediaServices.DOMAIN.AWS_EXTERNO, SensediaServices.VALIDAR_COMPOSICAO_BANCARIA, JSON.serialize(validarComposicaoBancariaTO)); //MGRC-1822-INICIO/FIM
        // retorno = CIVServices.getInstance().validarComposicaoBancaria(validarComposicaoBancariaTO);
            
            
            system.debug('retorno');
            system.debug(retorno);
            
        //Código removido por causa da história PLV-2310 para tratamento na class de teste 
         
            Map<String, Object> result = (Map<String, Object>)JSON.deserializeUntyped(retorno);
			
        	system.debug('result');
        	system.debug(result.get('codigo'));
        	system.debug(result.get('status'));
            
            List<InformacaoBancaria__c> ib = dao.buscarinfobancariasdosbeneficiarios(recordId);
        	
        	
            if(result.get('status') == 0)
            {
                ib[0].StatusIntegracao__c = 'Validada';
                ib[0].IdExterno__c = null;
                
                List<InformacaoBancaria__c> LstVerifica = [select Id From InformacaoBancaria__c Where Id =: ib[0].Id];

                Info2Update.add(ib[0]);
            }else if(result.get('status') == null)
            {
             	system.debug('nuloooooooooooooooooooooooooooooooooo');   
                ib[0].StatusIntegracao__c = 'Não Validada';
                ib[0].IdExterno__c = null;
                Info2Update.add(ib[0]);
            }else{ 
                ib[0].StatusIntegracao__c = 'Não Validada';
                ib[0].IdExterno__c = null;
                Info2Update.add(ib[0]);
            }
            if(!Info2Update.isempty())update(Info2Update);
        	
        	system.debug('ib[0]');
        	system.debug(ib[0]);
        	
        	system.debug('Info2Update');
        	system.debug(Info2Update);
        
        
       // TriggerHandler.bypass('InformacaoBancariaTriggerHandler');
        
        
    } return Info2Update[0].id;}
    
      
      public void MudaStatusIntegracao(List<InformacaoBancaria__c> informacoesbancarias, Map<Id,InformacaoBancaria__c> minformacoesbancariasOld){
        if(checkRecursive.runOnce())
        {   
            List<InformacaoBancaria__c> LstInformacaoBancaria = new List<InformacaoBancaria__c>();
            
            for(InformacaoBancaria__c inf : informacoesbancarias){
                //PLV-3918-FIX6 - INICIO
                //PLV-3918-FIX7 - INICIO
                if(inf.Agencia__c !=  minformacoesbancariasOld.get(inf.id).Agencia__c || inf.Digito__c !=  minformacoesbancariasOld.get(inf.id).Digito__c || inf.NumeroConta__c !=  minformacoesbancariasOld.get(inf.id).NumeroConta__c)
                {
                    inf.StatusIntegracao__c = 'Aguardando validação'; 
                }
                
                //PLV-3918-FIX7 - INICIO
                //PLV-3918-FIX6 - INICIO
            }
        }
      }
    
    
    //metodo que verificar o bloqueio
    @AuraEnabled
    public static String verificarbloqueiobancario(String recordId){
       String IdBeneficiario_da_garantia = recordId;
       String Idben;
       
       List<BeneficiarioGarantia__c> InfoBancaria = dao.buscarinfobancaria(IdBeneficiario_da_garantia);
       List<InformacaoBancaria__c> informacoesBancarias = dao.buscarinfobancariasdosbeneficiarios(InfoBancaria[0].Informacao_Bancaria__c);
        
       for(InformacaoBancaria__c ib : informacoesBancarias)
       { 
           String ExternalId;
           if(ib.Conta__r.Cpf__c != null){
               ExternalId = ib.Conta__r.Cpf__c;
           }else{
               ExternalId = ib.Conta__r.Cnpj__c;
           }

           String ExtId = ExternalId;
           String Str = ExtId.replace('.','').replace('-','').replace('/','');
		   //PLV-3918-FIX6 - INICIO
		   //PLV-3918-FIX7 - INICIO
           String validarbloqueiobancarioTO = '{'+
                +'"tipoConsulta": "2",'+
                +'"idExterno": "'+Str+'",'+
                +'"dadosBancarios": "'+ib.Banco__c+ib.Agencia__c+ib.NumeroConta__c+'-'+String.valueOf(ib.Digito__c)+'"}';
             
           //PLV-3918-FIX7 - FIM
           //PLV-3918-FIX6 - FIM
             Idben = servicoValidarBloqueioBancario(validarbloqueiobancarioTO, recordId);
             system.debug(Idben);  
       }        
        
    return Idben;
    }
    
     public static String servicoValidarBloqueioBancario(String validarBloqueioBancarioTO, String recordId){
        String retorno;

        if(!Test.isRunningTest()){
            retorno = SensediaServices.getInstance().montagemServicoSensedia(SensediaServices.VERB.POST, SensediaServices.DOMAIN.AWS_EXTERNO, SensediaServices.VALIDAR_BLOQUEIO_BANCARIO, JSON.serialize(validarBloqueioBancarioTO)); //MGRC-1821-INICIO/FIM
            //retorno = CIVServices.getInstance().validarBloqueioBancario(validarBloqueioBancarioTO); 
            
        }else{
            HttpRequest req = new HttpRequest();
            req.setMethod('POST');
            req.setHeader('Content-Type', 'application/json');
            InformacaoBancariaMock mock = new InformacaoBancariaMock();
            HttpResponse res = mock.respond(req);
            retorno = res.getBody();
            
        }

        system.debug('retorno ===>> ' + retorno);
 
        Map<String, Object> result = (Map<String, Object>)JSON.deserializeUntyped(retorno);
        Map<String, Object> result2 = (Map<String, Object>)result.get('MsgRetornoSOAP');
        Map<String, Object> result3 = (Map<String, Object>)result2.get('Mensagem');

        String RetornoAttStatus = atualizarstatusbloqueio(recordId, String.valueof(result3.get('codigoRetorno')));

         //retorna codigoretorno do json
        system.debug('RetornoAttStatus ==============' + RetornoAttStatus);
        return RetornoAttStatus;
     }    

    @AuraEnabled
    public static String atualizarstatusbloqueio(String recordId, String resultado)
    {
       String IdBeneficiario_da_garantia = recordId;
       List<InformacaoBancaria__c> Info2Update = new List<InformacaoBancaria__c>();
	   List<BeneficiarioGarantia__c> InfoBancaria = dao.buscarinfobancaria(IdBeneficiario_da_garantia);
       List<InformacaoBancaria__c> informacoesBancarias = dao.buscarinfobancariasdosbeneficiarios(InfoBancaria[0].Informacao_Bancaria__c);
       
       system.debug('resultado ' + resultado);
        
       if(resultado == '1' || resultado == '2')
       {
          informacoesBancarias[0].StatusIntegracao__c = 'Validada';
          informacoesBancarias[0].IdExterno__c = null;
          Info2Update.add(informacoesBancarias[0]);   
       }
       else
       {
          informacoesBancarias[0].StatusIntegracao__c = 'Não Validada';
          informacoesBancarias[0].IdExterno__c = null;
          Info2Update.add(informacoesBancarias[0]); 
       }

       if(!Info2Update.isempty())update(Info2Update);

       return informacoesBancarias[0].StatusIntegracao__c;

    }
    
    //AVX SP27 - PLV-1673 - metodo que verifica nome no serasa
    @AuraEnabled
    public static String validarnomeserasa(String recordId)
    {
        String tipo;
        String cpfcnpj;
        String Retorno;
            List<BeneficiarioGarantia__c> LstBeneficiario = [SELECT Id, StatusSerasa__c, 
                                                                    Conta__r.Name, Conta__r.Cpf__c, Conta__r.cnpj__c 
                                                             FROM BeneficiarioGarantia__c 
                                                             Where Id =: recordId];
            
            if(LstBeneficiario.isEmpty()) return 'lista vazia';        
            
            if(LstBeneficiario[0].Conta__r.Cpf__c != null)
            {
                tipo = 'PF';
                cpfcnpj = LstBeneficiario[0].Conta__r.Cpf__c;
            }else
            {
                tipo = 'PJ';
                cpfcnpj = LstBeneficiario[0].Conta__r.cnpj__c;
            }

            //Código removido por causa da história PLV-2310 para tratamento na class de teste 
            //MGRC-1260 - INICIO
            Retorno = SensediaServices.getInstance().servicoconsultanomeserasa(tipo, cpfcnpj.remove('.').remove('-').remove('/'));
            //MGRC-1260 - FIM
            system.debug('Retorno');
            system.debug(Retorno);
                
                
            //Código removido por causa da história PLV-2310 para tratamento na class de teste 
                
            system.debug('Retorno');
            system.debug(Retorno);
            
            InformacaoBancariaTO.RetornoNomeSerasaTO ret = (InformacaoBancariaTO.RetornoNomeSerasaTO)JSON.deserialize(Retorno, InformacaoBancariaTO.RetornoNomeSerasaTO.class);
            
        	system.debug('ret.codigo');
        	system.debug(ret.codigo);
        
        	if(ret.codigo == '404')
            {
                try{
                    if(LstBeneficiario[0].StatusSerasa__c != 'Não encontrado no Serasa'){
                        BeneficiarioGarantia__c bene = new BeneficiarioGarantia__c();
                        bene.Id = recordId;
                        bene.StatusSerasa__c = 'Não encontrado no Serasa';
                        update bene;
                    }
                }catch(Exception e){
                    system.debug('Mensagem de Erro ' + e.getMessage());
                    return 'Erro no update' + e.getMessage();
                }
                return 'Não encontrado registro no Serasa';
            }else if(ret.codigo == '500')
            {
                //Inicio da lógica para a história PLV-2310 
                //Tratativa do retorno do serviço com código 500 
                try{
                    if(LstBeneficiario[0].StatusSerasa__c != 'Erro no Serviço'){
                        BeneficiarioGarantia__c bene = new BeneficiarioGarantia__c();
                        bene.Id = recordId;
                        bene.StatusSerasa__c = 'Erro no Serviço';
                        update bene;
                    }
                }catch(Exception e){
                    system.debug('Mensagem de Erro ' + e.getMessage());
                    return 'Erro no update' + e.getMessage();
                }
                //Fim da lógica para a história PLV-2310
                return 'Erro no serviço';
            }
        	else{
                if(ret.NOME_ENR != ''){
                    if(ret.NOME_ENR == LstBeneficiario[0].Conta__r.Name){
                        if(LstBeneficiario[0].StatusSerasa__c != 'Atualizado'){
                            BeneficiarioGarantia__c bene = new BeneficiarioGarantia__c();
                            bene.Id = recordId;
                            bene.StatusSerasa__c = 'Atualizado';
                            update bene;
                        }
                        return 'Nome já atualizado';
                    }else
                    {
        
                        List<String> nameSplitted = ret.NOME_ENR.split(' ');
                        String LastName = ret.NOME_ENR.replace(nameSplitted[0], '');
                        
                        
                        Account Acc = new Account(); 
                        Acc.Id = LstBeneficiario[0].Conta__r.Id;
                        
                        Acc.FirstName = nameSplitted[0];
                        Acc.LastName = LastName;
                        update Acc;
                        
                        BeneficiarioGarantia__c bene = new BeneficiarioGarantia__c();
                        bene.Id = LstBeneficiario[0].Id;
                        bene.StatusSerasa__c = 'Atualizado';
                        update bene;
        
                        return 'Nome foi atualizado'; 
                    }
                }
                return 'Não entrou em nenhuma regra';
            }
    }
    
     //se o registro n passou, atualizar o status para nao validado
    @AuraEnabled
    public static Boolean validarcheque(String recordId)
    {	
        List<BeneficiarioGarantia__c> LstBeneficiario = [SELECT Tipo_de_Pagamento__c 
                                         		         FROM BeneficiarioGarantia__c 
                                                		 Where Id =: recordId]; 
        
        if(LstBeneficiario.isempty()) return false;
        
        if(LstBeneficiario[0].Tipo_de_Pagamento__c == 'Cheque'){
            return true;
        }else{
            return false;
        }
    }

	public class mensagensErro{
		String retornoSerasa = 'Não é possível validar o beneficiário com o status do pagamento diferente de Pendente.';
	}
    
    //PLV-4217 - INICIO - Nova chamada para o civ liquidacao
    @AuraEnabled
    public static Map<String, Object> acionaCIVLiquidacao(String recordId){        
		//PLV-4217
		Map<String, Object> mapaRetorno = new Map<String, Object>();
		mapaRetorno.put('sucesso', true);
		mensagensErro erro = new mensagensErro();
		//PLV-4217

		//PLV-4217 FIX - INICIO - Trazendo o campo
        Pagamento_de_Sinistro__c vPag = [SELECT Id, Status__c, Dados_Bancarios__c, Dados_Bancarios__r.Banco__c, Dados_Bancarios__r.Agencia__c, Dados_Bancarios__r.NumeroConta__c, Dados_Bancarios__r.Digito__c,Beneficiario_da_Garantia__c, Beneficiario_da_Garantia__r.Cpf__c FROM Pagamento_de_Sinistro__c WHERE Id = :recordId LIMIT 1];
        //PLV-4217 FIX - FIM
        
		//PLV-4217
		if(vPag.Dados_Bancarios__c == null){
			mapaRetorno.put('DadosBancarios', 'Dados bancários não informado!'); 
			return mapaRetorno;
		}  
        if(vPag.Beneficiario_da_Garantia__c == null){
			mapaRetorno.put('BeneficiarioGarantia', 'Beneficiário não encontrado!'); 
			return mapaRetorno;
		}  
        if(vPag.Status__c != 'Pendente'){
			System.debug('Entrou If Pendente');  
			mapaRetorno.put('Status', 'Não é possível validar o beneficiário com o status do pagamento diferente de Pendente.'); 
			return mapaRetorno; //PLV-4217 FIX - INICIO/FIM - Ajuste para validar o status
		} 
		//PLV-4217

        String cpf = vPag.Beneficiario_da_Garantia__r.Cpf__c.remove('.').remove('-');
        InformacoesTO informacoes = new InformacoesTO();
        DadosBancariosTO dadosBanc = new DadosBancariosTO();
        system.debug('cpf: ' + cpf);
        dadosBanc.banco = vPag.Dados_Bancarios__r.Banco__c;
        dadosBanc.agencia = vPag.Dados_Bancarios__r.Agencia__c;
        dadosBanc.contaCorrente = vPag.Dados_Bancarios__r.NumeroConta__c;
        dadosBanc.digitoContaCorrente = vPag.Dados_Bancarios__r.Digito__c;
        informacoes.cpfbeneficiario = cpf;
        informacoes.tipoconsulta = 2;
        informacoes.DadosBancarios = dadosBanc;

        //MGRC-1252 - INICIO
        // String retorno = CIVServices.getInstance().civLiquidacao(JSON.serialize(informacoes));
        String retorno = SensediaServices.getInstance().montagemServicoSensedia(SensediaServices.VERB.POST, SensediaServices.DOMAIN.AWS_EXTERNO, SensediaServices.CIV_LIQUIDACAO, JSON.serialize(informacoes));
        //MGRC-1252 - FIM
        
        system.debug('retorno: ' + retorno);

        RetornoCIVLiquidacaoTO ret = (RetornoCIVLiquidacaoTO) JSON.deserialize(retorno, RetornoCIVLiquidacaoTO.class);

        InformacaoBancaria__c infBan = [SELECT Id FROM InformacaoBancaria__c WHERE Id = :vPag.Dados_Bancarios__c LIMIT 1];

        Account contaBase = [SELECT Id, Name FROM Account WHERE Id = :vPag.Beneficiario_da_Garantia__c LIMIT 1];

        if(ret.bloqueioBancario.MsgRetornoSOAP.Mensagem.codigoRetorno == 1 || ret.bloqueioBancario.MsgRetornoSOAP.Mensagem.codigoRetorno == 2){
            InformacaoBancaria__c inf = new InformacaoBancaria__c();
            inf.StatusIntegracao__c = 'Validada';
            inf.Id = infBan.Id;
            inf.IdExterno__c = null;

            update inf;
        } else {
            InformacaoBancaria__c inf = new InformacaoBancaria__c();
            inf.StatusIntegracao__c = 'Não Validada';
            inf.Id = infBan.Id;
            inf.IdExterno__c = null;

            update inf;
            //PLV-4217
			mapaRetorno.put('DadosBancarios', 'Erro na validação dos dados bancários');
			vPag.BeneficiarioValidado__c = true;
			update vPag;
			return mapaRetorno;
			//PLV-4217
        }
        Account Acc = new Account(); 
        Acc.Id = contaBase.Id;
		//Map<String, String> mapRetorno = new Map<String, String>();
		//PLV-4217
        if(ret.pep.pep == 0){
            Acc.Pep__c = 'Não';
            if(!String.isBlank(ret.pep.ultimaConsulta)){
			 Acc.UltimaConsultaPEP__c = Date.valueOf(ret.pep.ultimaConsulta);
            }
			if(!String.isBlank(ret.pep.dataAtualizacao)){
			 Acc.DataAtualizacaoPEP__c = Date.valueOf(ret.pep.dataAtualizacao);
			}
			mapaRetorno.put('PEP', 'Pessoa não é PEP.');
			//return 'Pessoa não é PEP.';
			
        } else if(ret.pep.pep == 1){
            Acc.Pep__c = 'Sim';
            if(!String.isBlank(ret.pep.ultimaConsulta)){
			 Acc.UltimaConsultaPEP__c = Date.valueOf(ret.pep.ultimaConsulta);
            }
			if(!String.isBlank(ret.pep.dataAtualizacao)){
			 Acc.DataAtualizacaoPEP__c = Date.valueOf(ret.pep.dataAtualizacao);
			}
			mapaRetorno.put('PEP', 'Pessoa é PEP.');
			//return 'Pessoa é PEP.';			
        }
		//PLV-4217
        if(ret.serasa.codigo == null){
            if(ret.serasa.nome_ENR == contaBase.Name){
                update Acc;
                //PLV-4217
				mapaRetorno.put('Serasa', 'Nome já atualizado no Salesforce');
				vPag.BeneficiarioValidado__c = true;
				update vPag;
				return mapaRetorno;
				//PLV-4217
            } else if(ret.serasa.nome_ENR != null){
                List<String> nameSplitted = ret.serasa.nome_ENR.split(' ');
                String LastName = '';//MGRC-1260 - INICIO// = ret.serasa.nome_ENR.replace(nameSplitted[0], '');        
                for(Integer i = 0; i < nameSplitted.size(); i++){
                    if(nameSplitted.size() == 2){
                        LastName = nameSplitted[1];
                    }
                    if(i > 0 && nameSplitted.size() > 1){
                        LastName +=  nameSplitted[i] + ' ';
                    }                    
                }
                Acc.FirstName = nameSplitted[0];
                Acc.LastName = LastName.removeEnd(' ');//MGRC-1260 - FIM

                update Acc;

				//PLV-4217
                mapaRetorno.put('Serasa', 'Nome foi atualizado');
				vPag.BeneficiarioValidado__c = true;
				update vPag;
				return mapaRetorno;
				//PLV-4217
            }
        } else if(ret.serasa.codigo == 404){
            update Acc;
            //PLV-4217
			mapaRetorno.put('Serasa', 'Não encontrado registro no Serasa');
			vPag.BeneficiarioValidado__c = true;
			update vPag;
			return mapaRetorno;
			//PLV-4217
        } else {
            update Acc;
            //PLV-4217
			mapaRetorno.put('Serasa', 'Erro no serviço do Serasa');
			vPag.BeneficiarioValidado__c = true;
			return mapaRetorno;
			//PLV-4217
        }
		//PLV-4217
		System.debug('vPag.BeneficiarioValidado__c = ' + vPag.BeneficiarioValidado__c);
		vPag.BeneficiarioValidado__c = true;
		return mapaRetorno;
		//PLV-4217
    }

    public class InformacoesTO{
        public String cpfBeneficiario {get;set;}
        public Integer tipoConsulta {get;set;}
        public DadosBancariosTO DadosBancarios {get;set;}
    }

    public class DadosBancariosTO{
        public String banco {get;set;}
        public String agencia {get;set;}
        public String contaCorrente {get;set;}
        public String digitoContaCorrente {get;set;}
    }

    public class RetornoCIVLiquidacaoTO{
        public BloqueioBancarioTO bloqueioBancario {get;set;}
        public ComposicaoBancariaTO composicaoBancaria {get;set;}
	    public SerasaTO serasa {get;set;}
	    public PepTO pep {get;set;}
    }

    public class BloqueioBancarioTO {
		public MsgRetornoSOAPTO MsgRetornoSOAP {get;set;}
    }
    
    public class ComposicaoBancariaTO {
		public Integer status {get;set;}
    }
    
    public class SerasaTO {
		public String status {get;set;}
		public String data_de_atualizacao {get;set;}
		public String origem_informacao {get;set;}
		public String dddcel2_ENR {get;set;}
		public String logr_TITULO2_ENR {get;set;}
		public String cel3_ENR {get;set;}
		public String cep3_ENR {get;set;}
		public String cep2_ENR {get;set;}
		public String logr_TITULO1_ENR {get;set;}
		public String ddd3_ENR {get;set;}
		public String ddd2_ENR {get;set;}
		public String orgao_EMISSOR_ENR {get;set;}
		public String logr_NUMERO2_ENR {get;set;}
		public String fone2_ENR {get;set;}
		public String logr_COMPLEMENTO1_ENR {get;set;}
		public String uf1_ENR {get;set;}
		public String fone3_ENR {get;set;}
		public String endereco2_ENR {get;set;}
		public String cpf_DIGITO {get;set;}
		public String bairro2_ENR {get;set;}
		public String nome_ENR {get;set;}
		public String cel1_ENR {get;set;}
		public String uf3_ENR {get;set;}
		public String bairro1_ENR {get;set;}
		public String dddcel1_ENR {get;set;}
		public String endereco3_ENR {get;set;}
		public String logr_TIPO2_ENR {get;set;}
		public String cep1_ENR {get;set;}
		public String nome_MAE_ENR {get;set;}
		public String logr_COMPLEMENTO3_ENR {get;set;}
		public String cel2_ENR {get;set;}
		public String sexo_ENR {get;set;}
		public String logr_TITULO3_ENR {get;set;}
		public String logr_NOME3_ENR {get;set;}
		public String cpf_RADICAL {get;set;}
		public String ddd1_ENR {get;set;}
		public String logr_NUMERO3_ENR {get;set;}
		public String logr_TIPO1_ENR {get;set;}
		public String nascimento_ENR {get;set;}
		public String endereco1_ENR {get;set;}
		public String uf2_ENR {get;set;}
		public String rg_ENR {get;set;}
		public String cidade2_ENR {get;set;}
		public String logr_NUMERO1_ENR {get;set;}
		public String uf_EMISSAO_ENR {get;set;}
		public String logr_TIPO3_ENR {get;set;}
		public String logr_COMPLEMENTO2_ENR {get;set;}
		public String logr_NOME1_ENR {get;set;}
		public String logr_NOME2_ENR {get;set;}
		public String cidade3_ENR {get;set;}
		public String dddcel3_ENR {get;set;}
		public String bairro3_ENR {get;set;}
		public String cidade1_ENR {get;set;}
        public String fone1_ENR {get;set;}
        public Integer codigo {get;set;}
        public String descricao {get;set;}
    }
    
    public class PepTO {
		public Integer pep {get;set;}
		public String ultimaConsulta {get;set;}
		public String dataAtualizacao {get;set;}
    }
    
    public class MsgRetornoSOAPTO {
		public HeaderTO Header {get;set;}
		//public String Parceiro {get;set;} //PLV-4217 FIX - INICIO/FIM - Trecho comentado
		public MensagemTO Mensagem {get;set;}
		public TrailerTO Trailer {get;set;}
    }
    
    public class HeaderTO {
		public Integer tipoConsulta {get;set;}
    }
    
    public class MensagemTO {
		public Integer codigoRetorno {get;set;}
		public String mensagem {get;set;}
    }
    
    public class TrailerTO {
		public Integer qntdRegistros {get;set;}
	}
    //PLV-4217 - FIM

}