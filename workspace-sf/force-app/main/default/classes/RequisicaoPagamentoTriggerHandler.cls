// CRIAÇÃO EM FUNÇÃO DA HISTORIA PLV-3918
public class RequisicaoPagamentoTriggerHandler extends TriggerHandler{
    //PLV-3918-FIX3 - INICIO
    @TestVisible  private List<Pagamento_de_Sinistro__c> lPagSinistrotest = new List<Pagamento_de_Sinistro__c>();
    //PLV-3918-FIX3 - FIM
    //PLV-4604 - INICIO
    private Id idRTTributaveis = Schema.SObjectType.Requisicao_de_Pagamento__c.getRecordTypeInfosByDeveloperName().get('Despesas_com_Sinistros_Tributaveis').getRecordTypeId();
    private Id idRTNaoTributaveis = Schema.SObjectType.Requisicao_de_Pagamento__c.getRecordTypeInfosByDeveloperName().get('Despesas_com_Sinistros_Nao_Tributaveis').getRecordTypeId();
    //PLV-4604 - FIM
    //PLV-4148 - INICIO
	public override void beforeUpdate(){
        
        if(trigger.isBefore){
            if(trigger.isUpdate){
               List<Requisicao_de_Pagamento__c> lrequisitpPagamentoOld = Trigger.old;
               List<Requisicao_de_Pagamento__c> lrequisitpPagamentoNew = Trigger.new;
                for(Requisicao_de_Pagamento__c rqold : lrequisitpPagamentoOld){
                    if(rqold.Status__c == 'Cancelado'){
                        system.debug('map new'+ Trigger.newMap.get(rqold.Id));
                        //Requisicao_de_Pagamento__c requisicao = Trigger.oldMap.get(rqold.Id);
                        //requisicao.addError('Este registro não pode ser alterado, pois seu status já esta cancelado!');
        
                    } 
                  
                }
                //PLV-4148-FIX1 - INICIO
                Requisicao_de_Pagamento__c requisicao = lrequisitpPagamentoNew[0];
                system.debug('tipo requisicao'+lrequisitpPagamentoOld);
                Matricula_Usuario__mdt usuarioDS = buscaMatricula('Usuario_DataStage');
                //PLV-4148-FIX4 - INICIO
                //PLV-4148-FIX5 - INICIO
                List<Profile> perfil = [select Id, Name from Profile where Name =: usuarioDS.Aprovador__c OR Name = 'Administrador do sistema' OR Name = 'System administrator']; //PLV-4501 - FIX4 - INICIO/FIM
                List<String> usuarioPerfil = new List<String>();
                if(perfil.size() > 0){
                    for(Profile p : perfil){
                        usuarioPerfil.add(p.Id); 
                    }
                	
                }
                //PLV-4148-FIX5 - FIM
                
                //PLV-4148-FIX4 - FIM
                //system.debug('recordTypeName'+nomeRecordType);
                if(lrequisitpPagamentoNew[0].Valor_da_Cotacao_de_Moeda_Estrangeira__c > 0 && lrequisitpPagamentoNew[0].Tipo_moeda__c != 'BRL' && lrequisitpPagamentoNew[0].Valor_da_Cotacao_de_Moeda_Estrangeira__c != null){
                    Decimal somarValores = valotTotalPagamentosPorRequisicao(lrequisitpPagamentoNew[0].Id) * lrequisitpPagamentoNew[0].Valor_da_Cotacao_de_Moeda_Estrangeira__c;
                    lrequisitpPagamentoNew[0].Valor_Total_Prestadora__c = somarValores;
                }
                
                
                Boolean validar = true;
                String mensagem;
                switch on lrequisitpPagamentoOld[0].Status__c {
                    //OLD PENDENTE SOMENTE PARA SINISTRO("Enviar p/ Tesouraria" e "Cancelado")  OPERACIONAL("Enviar p/ Financeiro")
                    when 'Pendente'{
                        if(lrequisitpPagamentoNew[0].Status__c == 'Enviar p/ Tesouraria' || lrequisitpPagamentoNew[0].Status__c == 'Pendente' || lrequisitpPagamentoNew[0].Status__c == 'Cancelado' || lrequisitpPagamentoNew[0].Status__c == 'Enviar p/ Financeiro'){
                           validar = true;                            
                        }else{
                            validar = false;
                            mensagem = 'Você não pode alterar esta requisição para o Status '+lrequisitpPagamentoNew[0].Status__c+' selecionado.';
                        }
                    }
                    when 'Enviar p/ Tesouraria'{
                        if(lrequisitpPagamentoNew[0].Status__c == 'Enviado p/ Tesouraria'){
                            validar = true;   
                        }else{
                            validar = false;
                            mensagem = 'Você não pode alterar esta requisição para o Status '+lrequisitpPagamentoNew[0].Status__c+' selecionado.';
                        }
                    }
                    //OLD Enviado p/ Tesouraria SOMENTE PARA SINISTRO("Enviar para Registro Financeiro" e "Cancelado")
                    when 'Enviado p/ Tesouraria'{
                        if(lrequisitpPagamentoNew[0].Status__c == 'Cancelado' || lrequisitpPagamentoNew[0].Status__c == 'Enviar para Registro Financeiro'){
                            validar = true;   
                        }else{
                            validar = false;
                            mensagem = 'Você não pode alterar esta requisição para o Status '+lrequisitpPagamentoNew[0].Status__c+' selecionado.';
                        }
                    }
                    //OLD Enviar para Registro Financeiro SOMENTE PARA SINISTRO("Pago")
                    when 'Enviar para Registro Financeiro'{
                        if(lrequisitpPagamentoNew[0].Status__c == 'Pago' || lrequisitpPagamentoNew[0].Status__c == 'Erro'){
                            validar = true;   
                        }else{
                            //PLV-4604 - INICIO
                            if(lrequisitpPagamentoNew[0].Status__c != lrequisitpPagamentoOld[0].Status__c){
                                validar = false;
                                mensagem = 'Você não pode alterar esta requisição para o Status '+lrequisitpPagamentoNew[0].Status__c+' selecionado.';
                            }
                            //PLV-4604 - FIM
                        }
                    }
                    when 'Enviar p/ Financeiro'{
                        if(lrequisitpPagamentoNew[0].Status__c == 'Enviado p/ Financeiro'){
                            validar = true;   
                        }else{
                            //PLV-4604 - INICIO
                            if(lrequisitpPagamentoNew[0].Status__c != lrequisitpPagamentoOld[0].Status__c){
                                validar = false;
                                mensagem = 'Você não pode alterar esta requisição para o Status '+lrequisitpPagamentoNew[0].Status__c+' selecionado.';
                            }
                            //PLV-4604 - FIM
                        }
                    }
                    //OLD Enviado para Financeiro SOMENTE PARA OPERACIONAL para usuário não DS("Cancelado") usuário DS (OP Em criação)
                    //OP Criada, Em Pagamento,Pago, Cancelado,Em aprovação,Rejeitada,Erro
                    when 'Enviado p/ Financeiro'{
                        if(lrequisitpPagamentoNew[0].Status__c == 'Cancelado'){
                            if(lrequisitpPagamentoNew[0].Valor_da_Cotacao_de_Moeda_Estrangeira__c != lrequisitpPagamentoOld[0].Valor_da_Cotacao_de_Moeda_Estrangeira__c){
                                validar = false;
                                mensagem = 'Você esta tentando alterar o valor da cotação, não é permitido pois este pagamento já foi enviado para o Financeiro';
                            }else{
                               validar = true;    
                            }
                            
                        }else{
                            //PLV-4604 - INICIO
                            if(lrequisitpPagamentoNew[0].Status__c != lrequisitpPagamentoOld[0].Status__c){
                                validar = false;
                                mensagem = 'Você não pode alterar esta requisição para o Status '+lrequisitpPagamentoNew[0].Status__c+' selecionado. Selecione o Status Cancelado';
                            }
                            //PLV-4604 - FIM
                        }
                    }
                     //OLD Erro SOMENTE PARA SINISTRO(Pendente e cancelado)
                    when 'Erro'{
                        if(lrequisitpPagamentoNew[0].Status__c == 'Pendente' || lrequisitpPagamentoNew[0].Status__c == 'Cancelado'){
                            validar = true;   
                        }else{
                            validar = false;
                            mensagem = 'Você não pode alterar esta requisição para o Status '+lrequisitpPagamentoNew[0].Status__c+' selecionado. O status deve ser Pendente ou Cancelado';
                        }
                    }
                    when 'Pago'{
                            validar = false;
                            mensagem = 'Este registro não pode ser alterado, pois já esta Pago!';
                    }
                    when 'Cancelado'{
                            validar = false;
                            mensagem = 'Este registro não pode ser alterado, pois já esta Cancelado!';
                    }
                }
                //PLV-4148-FIX1 - INICIO
                if(requisicao.Status__c == 'OP Em criação' || requisicao.Status__c == 'OP Criada' || requisicao.Status__c == 'Em Pagamento' || requisicao.Status__c == 'Em aprovação' || requisicao.Status__c == 'Rejeitada'){
                    //PLV-4148-FIX4 - INICIO
                    system.debug('requisicao.LastModifiedById'+requisicao.LastModifiedById); //PLV-4501-FIX2 - INICIO/FIM
                    //PLV-4501-FIX3 - INICIO
                    String idPerfil = UserInfo.getProfileId();
                    system.debug('IDPERFIL'+idPerfil);
                    system.debug('usuarioPerfil'+usuarioPerfil);
                    //Id perfilUserAlteracao = [select Id, ProfileId from user where Id =: requisicao.LastModifiedById].ProfileId;
                    //PLV-4501-FIX3 - FIM

                    //PLV-4148-FIX5 - INICIO
                    if(usuarioPerfil.contains(idPerfil)){ //PLV-4501-FIX3 - INICIO/FIM
                        system.debug('mesmo usuário permite alterar');
                        validar = true;
                    }else{
                        system.debug('usuário diferente não pode alterar');
                        validar = false;
                        mensagem = 'Requisição não pode ser alterada';
                    }
                    //PLV-4148-FIX5 - FIM
                    //PLV-4148-FIX4 - FIM
                }
                
                //PLV-4148-FIX - FIM
                if(!validar)
                    requisicao.addError(mensagem);
                //PLV4148-FIX1 - FIM
            } 
        }       
       
    }    
    public void integraSAP(List<Requisicao_de_Pagamento__c> req){
        
        geraJsonSAP.Ordempagamento ordempagamento = new geraJsonSAP.Ordempagamento();
        geraJsonSAP obj = new geraJsonSAP();
        geraJsonSAP.Fornecedor fornecedor = new geraJsonSAP.Fornecedor();
        geraJsonSAP.Fatura fatura = new geraJsonSAP.Fatura();
        geraJsonSAP.Endereco endereco = new geraJsonSAP.Endereco();
        geraJsonSAP.Requisitante requisitante = new geraJsonSAP.Requisitante();
        geraJsonSAP.DadosBancarios dadosBancarios = new geraJsonSAP.DadosBancarios();
        List<geraJsonSAP.Itens> itens = new List<geraJsonSAP.Itens>();
        String regExp = '[/.-]';        
 
        Set<Id> contaIds = new Set<Id>();
        Set<Id> requisicaoIds = new Set<Id>();
        Set<Id> faturaIds = new Set<Id>();
        contaIds.add(req[0].Contas_de_Parceiro__c);
        requisicaoIds.add(req[0].Id);
        faturaIds.add(req[0].Fatura__c);
        String[] dataCreate = String.valueOf(req[0].CreatedDate).split(' ');  
        //PLV-4148-FIX1 - INICIO
        Matricula_Usuario__mdt matriculas = buscaMatricula('Matricula_SAP');
        //PLV-4148-FIX1-FIM
        if(req[0].Status__c == 'Enviar para Registro Financeiro'){
            system.debug('entrou status Enviar para Registro Financeiro');            
            //tag ordem pagamento
            ordempagamento.codigoOrigem = '35';
            ordempagamento.empresa = '01';
            ordempagamento.moeda = req[0].CurrencyIsoCode;
            ordempagamento.numeroDocumento = req[0].Name;
            ordempagamento.numeroSinistroAno = '';
            ordempagamento.localRiscoUF = 'SP'; //VERIFICAR!!!!
            ordempagamento.tipoUsuAprov = 'F';
            ordempagamento.codigoEmpMatAprov = '01';
             //PLV-4148-FIX1 - INICIO
            ordempagamento.matriculaRespAprov = matriculas.Aprovador__c;
             //PLV-4148-FIX1 FIM 
            ordempagamento.tipoUsuarioRequisitante = 'F';
            ordempagamento.codigoEmpMatRequisitante = '01';
            //PLV-4148-FIX1 - INICIO
            ordempagamento.matriculaRespRequisitante = matriculas.Requisitante__c;
            //PLV-4148-FIX1 FIM         
            ordempagamento.dataAprovLegado = tradaDatasPayload(dataCreate[0]);
            ordempagamento.dataContabil = tradaDatasPayload(dataCreate[0]);
            ordempagamento.indTributavel = 'N';
            ordempagamento.categoriaContaContrato = 'SG';
            ordempagamento.grupoPrevTesouraria = 'PG';
            ordempagamento.visaoContaExterna = 'E';
            ordempagamento.categoriaObjetoSeguro = 'PG';
            ordempagamento.numeroApolice = '';
            ordempagamento.numeroProposta = '';
            ordempagamento.numeroEndosso = '';
            ordempagamento.dataVigenciaInicio = '';
            ordempagamento.dataVigenciaFinal = '';
            ordempagamento.susepCorretor = '';
            ordempagamento.dataCobertura = '';
            ordempagamento.dataEmissao = '';
                        
        }
        system.debug('ID REQUISICAO PAGAMENTO'+requisicaoIds);
        List<Pagamento_de_Sinistro__c> pagamentoSinistroDados  = buscarRamoModalidade(requisicaoIds);
        system.debug('dados contrato e sinistro'+ pagamentoSinistroDados);

        if(contaIds.size() > 0 && pagamentoSinistroDados.size() > 0){
            List<Account> lConta =  AccountDAO.getInstance().buscarContasComFilhos(contaIds);
            List<Endereco__c> lEndereco = EnderecoDAO.getInstance().buscarEnderecoContas(contaIds); 
            
            String cpfcnpj = (lConta[0].Cnpj__c != '') ? lConta[0].Cnpj__c : lConta[0].Cpf__c;
            regExp = '[/.-]';
            String cpfcnpjTratado = cpfcnpj.replaceAll(regExp, '');
            //tag fornecedores
            String origemDados = pagamentoSinistroDados[0].Caso_de_Sinistro__r.Contrato__r.Origem__c;
            fornecedor.origemDados = 'Z'+origemDados.leftPad(3,'0');
            fornecedor.nome = lConta[0].Name;
            fornecedor.complementoNome = '';
            fornecedor.termoPequisa = (lConta[0].NomeFantasia__c == null) ? '' : lConta[0].NomeFantasia__c;
            fornecedor.tipoPessoa = 'PJ';
            //PLV-4148-FIX6 - INICIO
            fornecedor.cpfCnpj = '214268';//cpfcnpjTratado.substring(0,8);
            fornecedor.ordemCnpj = '4100';//cpfcnpjTratado.substring(8,12);
            fornecedor.digitoCpfCnpj = '14';//cpfcnpjTratado.substring(12,14);
            fornecedor.email = (lConta[0].Email__c == null) ? '' : lConta[0].Email__c;
            fornecedor.tipoParceiroNegocio = '0002';
            //PLV-4148-FIX6 - FIM
            fornecedor.tipoCategoriaCtaContrato = 'PR';
            fornecedor.grupoPrevisaoTesouraria = 'PG';
            fornecedor.visaoCtaExterna = 'E';
            //tag endereço
            endereco.endereco = lEndereco[0].Logradouro__c;
            //PLV-4148-FIX5 - INICIO
            endereco.complemento = '';
            //PLV-4148-FIX5 - FIM
            endereco.cidade = lEndereco[0].Cidade__c;
            endereco.numero = lEndereco[0].Numero__c;
            endereco.bairro = lEndereco[0].Bairro__c;
            endereco.uf = lEndereco[0].Estado__c;
            endereco.cep = lEndereco[0].CEP__c;
            endereco.pais = 'BR';//lEndereco[0].Pais__c;
            endereco.prefixoTelefone = '';
            endereco.telefone = '';
            fornecedor.endereco = endereco;
            
            //tag requisitante
            requisitante.tipoUsuario = 'F';
            requisitante.codigoEmpresaMatricula = '01';
            requisitante.matriculaResponsavel = '10277';
            fornecedor.requisitante = requisitante;
            //PLV-4148-FIX5 - INICIO
            List<Fatura__c> lFaturas = FaturaDAO.getInstance().buscarFaturasPorIds(faturaIds);
            //tag fatura
            fatura.codigoSucursal = '011';//(lFaturas[0].Sucursal__c == null)? '' : lFaturas[0].Sucursal__c;
           
            fatura.dataFatura = tradaDatasPayload(String.valueOf(Date.today()));
            //PLV-4148-FIX2 - INICIO
            fatura.montanteBruto = String.valueOf(req[0].Valor_Total_Prestadora__c.setscale(2));//(String.valueOf(lFaturas[0].ValorLiquido__c) == null) ? String.valueOf(req[0].Valor_Total_Prestadora__c.setscale(2)) : String.valueOf(lFaturas[0].ValorLiquido__c.setscale(2));
            //PLV-4148-FIX2 - FIM
            fatura.dataBaseCalculoVenc = tradaDatasPayload(String.valueOf(Date.today()+2));//(String.valueOf(lFaturas[0].DataVencimento__c) == null) ? tradaDatasPayload(dataCreate[0]) : tradaDatasPayload(String.valueOf(lFaturas[0].DataVencimento__c));
            fatura.condicaoPagamento = '';
            fatura.categoriaNotaFiscal = '';
            fatura.aliquotaISS = '';
            fatura.numeroDocCompras = '';
           
            //tag DadosBancarios
            dadosBancarios.paisBanco = 'BR';//lEndereco[0].Pais__c;
            dadosBancarios.banco = '';
            dadosBancarios.agencia = '';
            dadosBancarios.digitoAgencia = '';
            dadosBancarios.contaCorrente = '';
            dadosBancarios.digitoContaCorrente = '';
            fatura.dadosBancarios = dadosBancarios;     
            
            //tag itens
            for(Integer x = 0; x < 1; x++){
                geraJsonSAP.Itens item = new geraJsonSAP.Itens();
                item.numeroParcela = '1';
                //PLV-4148-FIX2 - INICIO
                item.valorParcela = String.valueOf(req[0].Valor_Total_Prestadora__c.setscale(2));
                //PLV-4148-FIX2 - FIM
                item.dataVencimento = tradaDatasPayload(String.valueOf(Date.today()+2));
                item.formaPagamento = 'B';
                item.codigoSucursal = '011';//(lFaturas[0].Sucursal__c == null)? pagamentoSinistroDados[0].Caso_de_Sinistro__r.Contrato__r.Sucursal__c : lFaturas[0].Sucursal__c;
                item.codigoMunicipio = '';
                String itemModalidade = String.valueOf(pagamentoSinistroDados[0].Caso_de_Sinistro__r.Contrato__r.CodigoModalidade__c);
                String itemRamo = String.valueOf(pagamentoSinistroDados[0].Caso_de_Sinistro__r.Contrato__r.CodigoRamo__c);
                item.codigoRamoModalidade = itemRamo+''+itemModalidade.leftPad(3,'0');
                item.centroCusto = '';
                item.codigoDespesa = '19';
                item.criterioOperacaoSub = '0';
                item.grupoPrevTesouraria = '';
                item.bloqueioDocumento = '';
                item.descricaoOrdemPagamento = '';
                                
                itens.add(item);
            }
             //PLV-4148-FIX5 - FIM
            
        }else{
            Requisicao_de_Pagamento__c requisicao = req[0];
			requisicao.addError('Este registro não pode ser alterado, pois não existe uma Conta ou Pagamento de Sinistro vinculado!');            
        }
        
        if(pagamentoSinistroDados.size()>0){
            system.debug('obj'+obj); 
         
            ordempagamento.fornecedor = fornecedor;
            ordempagamento.fatura = fatura;
            ordempagamento.itens = itens;
            obj.ordempagamento = ordempagamento;
            String json = JSON.serializePretty(obj);
            system.debug('json'+json);
            if(!Test.isRunningTest()){
                //PLV-4148-FIX1 - INICIO
            	// EnviaDadosSAP.enviaRequicaoPagamentoAPI(json, req[0].Name); //MGRC-1657 - INICIO/FIM
            	//PLV-4148-FIX1 - FIM
			}
         }
    }
    
    public static string tradaDatasPayload(String valor){
        String retorno = '';
        
        if(valor != null && valor != ''){
           String[] arrayData = valor.split('-');
           retorno = arrayData[2]+''+arrayData[1]+''+arrayData[0];
        } 
        
        return retorno;
    }
    
    //PLV-4148 - FIM
    
	public override void afterUpdate(){       
         List<Requisicao_de_Pagamento__c> lrequisitpPagamento = trigger.new;
         Set<Id> idRequisitoPagamento = new Set<Id>();
         set<Id> idsrequisitoPagFinanceiro = new Set<Id>();
         Boolean integraSAPRequisicaoIndenizacao = false;
		 //PLV-4148 - INICIO 
		 List<Requisicao_de_Pagamento__c> lrequisitpPagamentoOld = Trigger.old;                  
         system.debug('trigger afterUpdate'+lrequisitpPagamento);
        //PLV-4604 - INICIO
        List<Requisicao_de_Pagamento__c> lstRequisicaoMovimento = new List<Requisicao_de_Pagamento__c>();
        List<Requisicao_de_Pagamento__c> lstRequisicaoSinistro = new List<Requisicao_de_Pagamento__c>();
        List<Requisicao_de_Pagamento__c> lstRequisicaoPagamento = new List<Requisicao_de_Pagamento__c>();
        Map<Id, Requisicao_de_Pagamento__c> mapRequisicaoOld = new Map<Id, Requisicao_de_Pagamento__c>();
        Set<Id> setIdCase = new Set<Id>();
        for(Requisicao_de_Pagamento__c rp : lrequisitpPagamento){
            if((rp.RecordTypeId == this.idRTTributaveis || rp.RecordTypeId == this.idRTNaoTributaveis) && rp.Numero_do_Sinistro__c != null){
                Requisicao_de_Pagamento__c rpOld = (Requisicao_de_Pagamento__c) Trigger.OldMap.get(rp.Id); 
                if((rp.Status__c == 'Cancelado' && rp.Status__c != rpOld.Status__c) || (rp.Valor_Total_Prestadora__c != rpOld.Valor_Total_Prestadora__c)){
                    lstRequisicaoMovimento.add(rp);
                    setIdCase.add(rp.Numero_do_Sinistro__c);
                    mapRequisicaoOld.put(rpOld.Id, rpOld);
                }
                else if(rp.RecordTypeId == this.idRTNaoTributaveis && (rp.Status__c == 'Enviar p/ Financeiro' && rp.Status__c != rpOld.Status__c)){
                    lstRequisicaoSinistro.add(rp);
                }
                else if(rp.RecordTypeId == this.idRTTributaveis && (rp.Status__c == 'Enviar p/ Financeiro' && rp.Status__c != rpOld.Status__c)){
                    lstRequisicaoPagamento.add(rp);
                }
            }
            else{ 
                switch on rp.Status__c {
                    when 'Cancelado' {	
                        idRequisitoPagamento.add(rp.Id);
                    }	
                    when 'Enviar p/ Financeiro' {		
                        idsrequisitoPagFinanceiro.add(rp.Id);
                    }
                    when 'Enviar para Registro Financeiro' {
                        system.debug('Staus trigger old'+lrequisitpPagamentoOld[0].Status__c);
                        if(lrequisitpPagamentoOld[0].Status__c == 'Enviado p/ Tesouraria' && lrequisitpPagamentoOld[0].Status__c != rp.Status__c && rp.Numero_OP_SAP__c == null){
                            system.debug('aqui chama a integração com CIV-SAP');
                            integraSAPRequisicaoIndenizacao = true;
                        }
                                            
                    }
                }
            }
        }
        if(lstRequisicaoMovimento.size() > 0) {
            gerarMovimento(lstRequisicaoMovimento, setIdCase, mapRequisicaoOld);
        }
        if(lstRequisicaoSinistro.size() > 0) {
            gerarPagamentoDeSinistro(lstRequisicaoSinistro);
        }
        if(lstRequisicaoPagamento.size() > 0) {
            gerarPagamentoExterno(lstRequisicaoPagamento);
        }
        //PLV-4604 - FIM
        if(integraSAPRequisicaoIndenizacao){
            //PLV-4148-FIX5 - INICIO
            if(lrequisitpPagamento[0].Tipo_moeda__c  != 'BRL' && (String.valueOf(lrequisitpPagamento[0].Valor_da_Cotacao_de_Moeda_Estrangeira__c)  != '' && String.valueOf(lrequisitpPagamento[0].Valor_da_Cotacao_de_Moeda_Estrangeira__c) != null)){
                system.debug('chamou integracao Dolar'); 
                integraSAP(lrequisitpPagamento);
            }
            //PLV-4148-FIX5 - FIM
            if(lrequisitpPagamento[0].Tipo_moeda__c  == 'BRL' && lrequisitpPagamento[0].Fatura__c != null){
                system.debug('dados old'+lrequisitpPagamento); 
                integraSAP(lrequisitpPagamento);
            }
        }
        
        
        if(idRequisitoPagamento.size() > 0){
            atualizaPagamentoSinistro(idRequisitoPagamento);
        }
        //PLV-4148 -FIM
        
        if(idsrequisitoPagFinanceiro.size() > 0){
            List<Requisicao_de_Pagamento__c> lrequisitoPagFinanceiro = buscarPagamentosSinistro(idsrequisitoPagFinanceiro);
            //PLV-3918-FIX3 - INICIO
            //Pegar o Ramo e Modalidade para enviar para Pagamento__x pois o mesmo é necessário para o processo financeiro. Pegar o primeniro registro
            //que encotrar, diferente de nulo.
            List<Pagamento_de_Sinistro__c> lPagSinistro = (!lPagSinistrotest.isEmpty()) ? lPagSinistrotest : buscarRamoModalidade(idsrequisitoPagFinanceiro);
            List<String> mr = new List<String>();
            Map<Id,List<String>> mRamoModalidade = new Map<Id,List<String>>();
            system.debug('lPagSinistro'+lPagSinistro);
            for(Pagamento_de_Sinistro__c p : lPagSinistro){
                if(String.isNotBlank(p.Caso_de_Sinistro__r.Contrato__r.CodigoRamo__c) && String.isNotBlank(String.valueOf(p.Caso_de_Sinistro__r.Contrato__r.CodigoModalidade__c))){
                    mr.add(p.Caso_de_Sinistro__r.Contrato__r.CodigoRamo__c);
                 	mr.add(String.valueOf(p.Caso_de_Sinistro__r.Contrato__r.CodigoModalidade__c));
                    mRamoModalidade.put(p.Requisicao_de_Pagamento__c,mr);
                }
                
                
            }
            salvarPagamentos(lrequisitoPagFinanceiro, mRamoModalidade);
            //PLV-3918-FIX3 -FIM
        }

		//PLV-4501 Inicio
		//List<Requisicao_de_Pagamento__c> lrequisitpPagamentoOld = Trigger.old;
		
		Requisicao_de_Pagamento__c requisitpPagamentoOld =  lrequisitpPagamentoOld[0];
		Requisicao_de_Pagamento__c requisicaoPagamento =  lrequisitpPagamento[0];
		
		if(requisicaoPagamento.Status__c == 'Cancelado' && requisitpPagamentoOld.Status__c == 'Enviado p/ Financeiro'){
			Set<Id> setRequisicaoId = new Set<Id>();
			setRequisicaoId.add(requisicaoPagamento.Id);
			atualizaPagamentoExterno(setRequisicaoId);
		}
		//PLV-4501 Fim
           
    }
    
    public static void atualizaPagamentoSinistro(Set<Id>idRequisicaoPag){
        //PLV-4148 - INICIO
        List<Pagamento_de_Sinistro__c> lPagamentoSinistro =  [SELECT 
                                                              	Id, Requisicao_de_Pagamento__c, Garantia_do_Sinistro__c  
                                                              FROM 
                                                              	Pagamento_de_Sinistro__c 
                                                              WHERE 
                                                             	Requisicao_de_Pagamento__c IN: (idRequisicaoPag)
                                                            ];
        list<Pagamento_de_Sinistro__c> deletePagamentoSinistro = new List<Pagamento_de_Sinistro__c>();
        //PLV-4148 - FIM
        list<Pagamento_de_Sinistro__c> updatePagamentoSinistro = new List<Pagamento_de_Sinistro__c>();
        system.debug('santana trigger pagamentos'+ lPagamentoSinistro);
        //PLV-4148 - INICIO
        for(Pagamento_de_Sinistro__c ps : lPagamentoSinistro){
            ps.Requisicao_de_Pagamento__c = null;
            if(ps.Garantia_do_Sinistro__c != null){
              deletePagamentoSinistro.add(ps);  
            }else{
               //PLV-3918-FIX3 - INICIO
                ps.Status__c = 'Pendente';
                //PLV-3918-FIX3 - FIM
                //PLV-4148-FIX1 - INICIO
                ps.OP_SAP__c = null;
                //PLV-4148-FIX - FIM
                updatePagamentoSinistro.add(ps); 
            }
        }
        //PLV-4148-FIX5 - INICIO
        if(updatePagamentoSinistro.size() > 0){
            update updatePagamentoSinistro;
        }
        	
        if(deletePagamentoSinistro.size() > 0){
            delete deletePagamentoSinistro;
             List<BeneficiarioGarantia__c> lbenificiarioUpdate = new  List<BeneficiarioGarantia__c>();
            List<BeneficiarioGarantia__c> lbenificiario = [select 
                                                           Id, 
                                                           Pagamento_de_Sinistro__c, 
                                                           Requisi_o_de_Pagamento__c, 
                                                           Pagamento_de_garantia__c 
                                                           from 
                                                           BeneficiarioGarantia__c
                                                           where 
                                                           Requisi_o_de_Pagamento__c in: (idRequisicaoPag)];
            for(BeneficiarioGarantia__c b : lbenificiario){
                b.Requisi_o_de_Pagamento__c = null;
                lbenificiarioUpdate.add(b);
                
            }
            update lbenificiarioUpdate;
        }
          
        //PLV-4148-FIX5 - FIM
        //PLV-4148 - FIM
        
        //PLV-3918-FIX4 - INICIO
        atualizaPagamentoExterno(idRequisicaoPag);        
        //PLV-3918-FIX4 - FIM
        
    }
    //PLV-3918-FIX3 - INICIO
    public static void salvarPagamentos(List<Requisicao_de_Pagamento__c> pgSinistros, Map<Id,List<String>> mRamoModalidade){
        system.debug('pgSinistros'+pgSinistros);
        List<Pagamento__x> pagamentos = new List<Pagamento__x>();
        system.debug('mRamoModalidade'+mRamoModalidade);
        for(Requisicao_de_Pagamento__c ps : pgSinistros){
            //PLV-3918-FIX4 - INICIO
            if(String.isNotBlank(ps.Nota_fiscal__c)){
               Pagamento__x pagamento = new Pagamento__x();
                String cpfcnpj = (ps.Contas_de_Parceiro__r.Cnpj__c != '') ? ps.Contas_de_Parceiro__r.Cnpj__c : ps.Contas_de_Parceiro__r.Cpf__c;
                String regExp = '[/.-]';
                String cpfcnpjTratado = cpfcnpj.replaceAll(regExp, '');
                pagamento.IdConta__c = ps.Contas_de_Parceiro__c;
                pagamento.CnpjCpf__c = cpfcnpjTratado;
                //PLV-4501 Inicio
				//Requisicao_de_Pagamento__c.SObjectType
				pagamento.Descricao__c = (ps.RecordType.Name == 'Pagamento de Prestadora') ? 'PAGAMENTO DE PRESTADORA' : 'PAGAMENTO SINISTRO OPERACIONAL';
                //PLV-4501 Fim
				pagamento.Status__c = 'PENDENTE';
                pagamento.TipoPagamento__c = 'REMUNERACAO';
                pagamento.ValorBruto__c = ps.Valor_Total_Prestadora__c.setScale(2);
                pagamento.idObjeto__c = ps.Id;
                pagamento.TipoConta__c = 'Parceiro';
                pagamento.ValorPagamento__c =  ps.Valor_Total_Prestadora__c.setScale(2);
                pagamento.tributacao__c = true;
                pagamento.TipoRemuneracao__c = 'REP';                
				//PLV - 4501 Inico
				pagamento.ramo__c = (mRamoModalidade.get(ps.Id) != null) ? mRamoModalidade.get(ps.Id)[0] : (ps.RecordType.Name == 'Pagamento de Prestadora') ? '1391' : null; //PLV-4501 - FIX1 - INICIO/FIM              
				pagamento.modalidade__c = (mRamoModalidade.get(ps.Id) != null) ? mRamoModalidade.get(ps.Id)[1] : (ps.RecordType.Name == 'Pagamento de Prestadora') ? '000' : null;  //PLV-4501 - FIX1 - INICIO/FIM
				//PLV - 4501 Fim
                //PLV-3918-FIX5 - INICIO
                pagamento.Matricula__c = 'P0610277';
                //PLV-3918-FIX5 - FIM
                //PLV-4148-FIX1 - INICIO
                pagamento.DataProgramadaPagamento__c = ps.Data_Programada_de_Pagamento__c;
                //pagamento.DataPagamento__c  = ps.data_de_pagamento__c;
                //PLV-4148-FIX1 - FIM
                pagamentos.add(pagamento); 
            }
            
            //PLV-3918-FIX4 - FIM
            
        }
        //PLV-3918-FIX3 FIM
                    
        
        if(!pagamentos.isEmpty()){
            //insert pagamentos;
            Database.SaveResult[] srList = Database.insertAsync(pagamentos, new Callback());
       		
        }
       


    }
    
    public List<Requisicao_de_Pagamento__c> buscarPagamentosSinistro(Set<Id> idsRequisitoPagamento){
        List<Requisicao_de_Pagamento__c> lpagametoSinistro =  [SELECT Id, Contas_de_Parceiro__r.Id, Contas_de_Parceiro__r.Name, 
                                                               			Contas_de_Parceiro__r.Cpf__c, Contas_de_Parceiro__r.Cnpj__c, 
                                                               			Valor_Total_Prestadora__c
                                                               			//PLV-3918-FIX4 - INICIO
                                                               			,Nota_fiscal__c
                                                               			//PLV-3918-FIX4 - FIM
                                                               			//PLV-4148-FIX1 - INICIO
                                                               			,data_de_pagamento__c
                                                               			,Data_Programada_de_Pagamento__c
                                                               			//PLV-4148-FIX1 - FIM
																		//PLV-4501 Inicio
																		,RecordType.Name
																		//PLV-4501 Fim
                                                               FROM Requisicao_de_Pagamento__c 
                                                             	WHERE 
                                                             	Id IN: (idsRequisitoPagamento)
                                                            ]; 
        return lpagametoSinistro;
    }
    //PLV-3918 - FIX3 - INICIO
    public List<Pagamento_de_Sinistro__c> buscarRamoModalidade(Set<Id> requisicaoPagamento){
        List<Pagamento_de_Sinistro__c> lobj = [SELECT  
                                               	Caso_de_Sinistro__r.Contrato__r.CodigoRamo__c, 
                                               Caso_de_Sinistro__r.Contrato__r.CodigoModalidade__c, 
                                               //PLV-4148 - INICIO
                                               Caso_de_Sinistro__r.Contrato__r.Origem__c,
                                               Caso_de_Sinistro__r.Contrato__r.Sucursal__c,
                                               //PLV-4148 - FIM
                                               Requisicao_de_Pagamento__c
                                       			FROM Pagamento_de_Sinistro__c 
                                               WHERE Requisicao_de_Pagamento__c IN: (requisicaoPagamento)
                                       ];
        return lobj;
        
    }
     //PLV-3918 - FIX3 - FIM
    
    //PLV-3918-FIX4 - INICIO
    @future(callout=true)
    public static void atualizaPagamentoExterno(Set<Id>idRequisicaoPag){
        List<Pagamento__x> lPagamentoExterno = [SELECT idObjeto__c, Status__c FROM Pagamento__x WHERE idObjeto__c IN : (idRequisicaoPag)];
        List<Pagamento__x> lPagamentoExternoUpdate = new List<Pagamento__x>();
        for(Pagamento__x p : lPagamentoExterno){
            p.Status__c = 'CANCELADO';
            lPagamentoExternoUpdate.add(p);
        }
      
		if(!lPagamentoExternoUpdate.isEmpty()){
            //update pagamentos;
            //PLV-4148 - INICIO
            Database.SaveResult[] srList = Database.updateAsync(lPagamentoExternoUpdate);
            //PLV-4148 - FIM
       		
        }		
    }
    //PLV-3918-FIX4 - FIM
    
    
    //PLV-4148-FIX1 - INICIO
    Public static Decimal valotTotalPagamentosPorRequisicao(Id rqp){
       LIST<Pagamento_de_Sinistro__c> ps = [SELECT 
                                      Valor_total_a_ser_indenizado__c
                                     FROM Pagamento_de_Sinistro__c 
                                     WHERE Requisicao_de_Pagamento__c =: rqp 
                                     ];
       
        Decimal soma = 0;
        for(Pagamento_de_Sinistro__c p : ps){
            soma += p.Valor_total_a_ser_indenizado__c;
        }
        system.debug('soma'+soma);
        return soma;
    } 
    public Matricula_Usuario__mdt buscaMatricula(String nome){
          Matricula_Usuario__mdt matricula = [SELECT Aprovador__c, Requisitante__c, DeveloperName FROM Matricula_Usuario__mdt WHERE DeveloperName =: nome LIMIT 1];
    	  return matricula;
    }
     
    //PLV-4148-FIX1 -FIM
                     
    //PLV-4604 - INICIO
    public override void afterInsert(){
        List<Requisicao_de_Pagamento__c> lstRequisicao = new List<Requisicao_de_Pagamento__c>();
        Set<Id> setIdCase = new Set<Id>();
        for(Requisicao_de_Pagamento__c requisicao : (List<Requisicao_de_Pagamento__c>)Trigger.new){
            if((requisicao.RecordTypeId == this.idRTTributaveis || requisicao.RecordTypeId == this.idRTNaoTributaveis )&& requisicao.Numero_do_Sinistro__c != null){
                lstRequisicao.add(requisicao);
                setIdCase.add(requisicao.Numero_do_Sinistro__c);
            }
        }
        if(lstRequisicao.size() > 0) {
            gerarMovimento(lstRequisicao, setIdCase, null);
        }
    }

    private void gerarPagamentoDeSinistro(List<Requisicao_de_Pagamento__c> lstRequisicao){
        List<Pagamento_de_Sinistro__c> lstPagamentoDeSinistro = new List<Pagamento_de_Sinistro__c>();
        for(Requisicao_de_Pagamento__c requisicao : lstRequisicao){
            Pagamento_de_Sinistro__c pagamento = new Pagamento_de_Sinistro__c(
                Caso_de_Sinistro__c = requisicao.Numero_do_Sinistro__c,
                Requisicao_de_Pagamento__c = requisicao.Id,
                Beneficiario_da_Garantia__c = requisicao.Contas_de_Parceiro__c,
                Valor_total_a_ser_indenizado__c = requisicao.Valor_Total_Prestadora__c,
                Data_Programada_de_Pagamento__c = requisicao.Data_Programada_de_Pagamento__c,
                Tipo_de_Aprova_o__c = 'Alçada SAP',
                Tipo_de_OP__c = 'Indenização',
                Status__c = 'Pendente'
            );
            lstPagamentoDeSinistro.add(pagamento);
        }
        insert lstPagamentoDeSinistro;
        /*for(Pagamento_de_Sinistro__c pagamento : lstPagamentoDeSinistro){
            pagamento.Status__c = 'Liberado';
            pagamento.BeneficiarioValidado__c = true;
        }
        update lstPagamentoDeSinistro;*/
    }

    private void gerarMovimento(List<Requisicao_de_Pagamento__c> lstRequisicao, Set<Id> setIdCase, Map<Id, Requisicao_de_Pagamento__c> mapRequisicaoOld){
        Map<Id,Integer> mapSequencia = SequenciaMovimentoSinistroHelper.sequenciaMovimentos(setIdCase);
        List<MovimentoSinistro__c> lstMovimento = new List<MovimentoSinistro__c>();
        Datetime agora = Datetime.now();
        
        for(Requisicao_de_Pagamento__c requisicao : lstRequisicao){
            Integer sequencia = 1;
            if(mapSequencia == null){
                mapSequencia = new Map<Id,Integer>();
            }
            else if(mapSequencia.containsKey(requisicao.Numero_do_Sinistro__c)){
                sequencia = mapSequencia.get(requisicao.Numero_do_Sinistro__c) + 1;
            }
            //(mapSequencia == null || !mapSequencia.containsKey(requisicao.Numero_do_Sinistro__c)) ? 1 : mapSequencia.get(requisicao.Numero_do_Sinistro__c) + 1;
            Requisicao_de_Pagamento__c reqOld = (mapRequisicaoOld != null && mapRequisicaoOld.containskey(requisicao.Id)) ? mapRequisicaoOld.get(requisicao.Id) : null;
            String descricaoMovimento = '16';
            if(reqOld != null){
                if(requisicao.Status__c == 'Cancelado' && requisicao.Status__c != reqOld.Status__c){
                    descricaoMovimento = '18';
                }
                else if(requisicao.Valor_Total_Prestadora__c != reqOld.Valor_Total_Prestadora__c){
                    descricaoMovimento = '17';
                }
            }
            MovimentoSinistro__c movimento = new MovimentoSinistro__c(
                Caso__c = requisicao.Numero_do_Sinistro__c,
                DataMovimento__c = agora,
                TipoMovimento__c = 'Despesa',
                DescricaoMovimento__c = descricaoMovimento, 
                SequenciaMovimento__c = String.valueOf(sequencia),
                ValorMovimento__c = requisicao.Valor_Total_Prestadora__c
            );
            lstMovimento.add(movimento);
            
            mapSequencia.put(requisicao.Numero_do_Sinistro__c, sequencia);
        }
        insert lstMovimento;
    }

    private void gerarPagamentoExterno(List<Requisicao_de_Pagamento__c> lstRequisicaoPagamento){
        List<Pagamento__x> pagamentos = new List<Pagamento__x>();
        //PLV-4931 INICIO
        Operacao__mdt operacao = [SELECT Operacao__c, SubOperacao__c FROM Operacao__mdt WHERE TipoPagamento__c = 'SINISTRO' AND TipoSinistro__c = 'DPS'];
        Map<String,Map<String,String>> mapPessoaCodigoServico = new Map<String, Map<String,String>>();
        for(ServicoTributavel__mdt servico : [SELECT Id, Label, TipoPessoa__c, Servico__c, CodigoServico__c FROM ServicoTributavel__mdt]){
            if(!mapPessoaCodigoServico.containsKey(servico.TipoPessoa__c)){
                mapPessoaCodigoServico.put(servico.TipoPessoa__c, new Map<String,String>());
            }
            Map<String,String> mapCodigoServico =  mapPessoaCodigoServico.get(servico.TipoPessoa__c);
            mapCodigoServico.put(servico.Servico__c, servico.CodigoServico__c);
            mapPessoaCodigoServico.put(servico.TipoPessoa__c, mapCodigoServico);
        }
        //PLV - 4931 FIM
        for(Requisicao_de_Pagamento__c requisicao : getRequisicoesPagamento(lstRequisicaoPagamento)){
            Pagamento__x pagamento = new Pagamento__x();
            String cpfcnpj = (String.isNotBlank(requisicao.Contas_de_Parceiro__r.Cnpj__c)) ? requisicao.Contas_de_Parceiro__r.Cnpj__c : requisicao.Contas_de_Parceiro__r.Cpf__c;
            String cpfcnpjTratado = '';
            if(String.isNotBlank(cpfcnpj)){
                String regExp = '[/.-]';
                cpfcnpjTratado = cpfcnpj.replaceAll(regExp, '');
            }
            pagamento.IdConta__c = requisicao.Contas_de_Parceiro__c;
            pagamento.CnpjCpf__c = cpfcnpjTratado;
            pagamento.Descricao__c = 'DESPESAS COM SINISTROS TRIBUTAVEIS';
            pagamento.Status__c = 'PENDENTE';
            pagamento.TipoPagamento__c = 'SINISTRO'; //PLV-4931 INICIO/FIM
            pagamento.ValorBruto__c = requisicao.Valor_Total_Prestadora__c.setScale(2);
            pagamento.idObjeto__c = requisicao.Id;
            pagamento.TipoConta__c = 'Parceiro';
            pagamento.ValorPagamento__c =  requisicao.Valor_Total_Prestadora__c.setScale(2);
            pagamento.tributacao__c = true;
            //PLV - 4931 INICIO
            pagamento.TipoRemuneracao__c = null;
            pagamento.TipoSinistro__c = 'DPS';
            pagamento.Operacao__c = operacao.Operacao__c;
            pagamento.SubOperacao__c = operacao.SubOperacao__c;
            Map<String,String> mapCodigoServico = new Map<String,String>();
            if(requisicao.Contas_de_Parceiro__r.RecordType.DeveloperName == 'PessoaJuridica'){
                mapCodigoServico = mapPessoaCodigoServico.get('Jurídica');
            }
            else{
                mapCodigoServico = mapPessoaCodigoServico.get('Física');
            }
            pagamento.CodigoServico__c = mapCodigoServico.get(requisicao.Tipo_de_pagamento__c);
            //PLV - 4931 FIM
            pagamento.ramo__c = '1391';
            pagamento.modalidade__c = '000';
            if(requisicao.Numero_do_Sinistro__r.Contrato__c != null){
                if(String.isNotBlank(requisicao.Numero_do_Sinistro__r.Contrato__r.CodigoRamo__c)){
                    pagamento.ramo__c = requisicao.Numero_do_Sinistro__r.Contrato__r.CodigoRamo__c;    
                }
                if(String.isNotBlank(requisicao.Numero_do_Sinistro__r.Contrato__r.CodigoRamo__c)){
                    pagamento.modalidade__c = String.valueOf(requisicao.Numero_do_Sinistro__r.Contrato__r.CodigoModalidade__c); 
                }
            }
            pagamento.Matricula__c = 'P0610277';
            pagamento.DataProgramadaPagamento__c = requisicao.Data_Programada_de_Pagamento__c;
            pagamentos.add(pagamento); 
            
        }
        Database.SaveResult[] srList = Database.insertAsync(pagamentos, new Callback());
    }
    private List<Requisicao_de_Pagamento__c> getRequisicoesPagamento(List<Requisicao_de_Pagamento__c> lstRequisicaoPagamento){
        List<Requisicao_de_Pagamento__c> lstRequisicoesPagamento =  [SELECT Id, Numero_do_Sinistro__c,  Numero_do_Sinistro__r.Contrato__c,
                    Numero_do_Sinistro__r.Contrato__r.CodigoRamo__c, Numero_do_Sinistro__r.Contrato__r.CodigoModalidade__c,
                    Numero_do_Sinistro__r.Contrato__r.Origem__c, Numero_do_Sinistro__r.Contrato__r.Sucursal__c,
                    Contas_de_Parceiro__c, Contas_de_Parceiro__r.Name, Contas_de_Parceiro__r.Cpf__c, Contas_de_Parceiro__r.Cnpj__c, 
                    Valor_Total_Prestadora__c, Nota_fiscal__c, Data_Programada_de_Pagamento__c,RecordType.Name, Contas_de_Parceiro__r.RecordType.DeveloperName, Tipo_de_pagamento__c //PLV-4931 INICIO/FIM
                    FROM Requisicao_de_Pagamento__c WHERE Id IN: lstRequisicaoPagamento];
        return lstRequisicoesPagamento;
    }
    //PLV-4604 - FIM
}