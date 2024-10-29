/**
    * ContractBO
    * @author João Losada @ 26/06/2018
    *
    **/
    public class ContractBO {

        private static final String CLASS_NAME = 'ContractBO';
        private static final ContractBO instance = new ContractBO();
        private static final String TipoBeneficiarioSemConta = 'Herdeiros legais, conforme artigo 792 do código civil.'; // PLV-4524-FIX INICIO/FIM
        private final String NOME = 'PC_NOME';
        private final String CNPJ = 'PC_CNPJ';
        private static ContractDAO dao = ContractDAO.getInstance();
        private static HerokuService herokuServ = HerokuService.getInstance();
        public static Decimal restit;//PLV-5766-INICIO/FIM
        
        public static ContractBO getInstance() {
            return instance;
        }
        
        private ContractBO() {}
        
        public class ContractException extends Exception {}
        
        
        public List < Contract > buscarContratos(Set < Id > setContratoId) {
            return dao.buscarContratos(setContratoId);
        }
      
        //PLV-4536 inicio
        //PLV-5057 INICIO
        public void gravarUltimoModificador(List<Contract> contratoInseridos){
            Set<ID> lstContratoOriginal = new Set<ID>();
            for(Contract ctr : contratoInseridos) {
                if(ctr.ContratoOriginal__c != null) lstContratoOriginal.add(ctr.ContratoOriginal__c);
            }

            List<Contract> lstContractOriginal = [SELECT ID, Usuario_temporario__c FROM Contract WHERE ID IN: lstContratoOriginal];
            Map<ID, Contract> mpContractOld = new Map<ID, Contract>(lstContractOriginal);
            
            for(Contract ctr : contratoInseridos){
                if(ctr.ContratoOriginal__c != null && mpContractOld.containsKey(ctr.ContratoOriginal__c)){
                    ctr.Usuario_ultima_modificacao__c = mpContractOld.get(ctr.ContratoOriginal__c).Usuario_temporario__c;
                    ctr.Data_BackOffice_Endosso__c = System.Now();
                 }
            }

            // try {
            //     Map<String,Contract> mapNewContrats = new Map<String,Contract>();
            //     Map<String,Contract> mapOldContrats = new Map<String,Contract>();
            //     List<String> listContractsNames = new List<String>();
            // for (Contract contrato: contratoInseridos){
            //     if (contrato.Endosso__c>'0') {
            //         String nomeContrato = contrato.Empresa__c+'-'+contrato.sucursal__c+'-'+contrato.CodigoRamo__c+'-'+contrato.NumeroApolice__c;

            //         listContractsNames.add(nomeContrato+'-'+String.valueOf(Integer.valueOf(contrato.Endosso__c)-1));

            //         mapNewContrats.put(nomeContrato, contrato);
            //     }
            // }
            //     List<Contract> oldContrasts = [SELECT Id,Name, Usuario_temporario__c, Empresa__c, sucursal__c, CodigoRamo__c, NumeroApolice__c, Endosso__c FROM Contract WHERE Name in :listContractsNames];
            //     for (Contract contrato: oldContrasts){
            //         String nomeContrato = contrato.Empresa__c+'-'+contrato.sucursal__c+'-'+contrato.CodigoRamo__c+'-'+contrato.NumeroApolice__c;
            //         mapOldContrats.put(nomeContrato,contrato);
            //     }
                
            //     for (String key : listContractsNames) {
            //         key = key.substring(0,key.length()-2);
            //         Contract contratoNovo = mapNewContrats.get(key);
            //         Contract contratoAntigo = mapOldContrats.get(key);
            //         if (contratoAntigo!=null && contratoAntigo.Usuario_temporario__c!=null) {
            //             contratoNovo.Usuario_ultima_modificacao__c = contratoAntigo.Usuario_temporario__c;
            //             contratoNovo.Data_BackOffice_Endosso__c = system.now();
            //             contratoAntigo.Usuario_temporario__c = null;
            //             update contratoAntigo;
            //         }else{
            //             contratoNovo.Usuario_ultima_modificacao__c = UserInfo.getUserId();
            //             contratoNovo.Data_BackOffice_Endosso__c = system.now();
            //         }
            //     }
            // } catch(Exception e) {
            //     System.debug('gravarUltimoModificador ERRO:   '+e.getMessage());
            // }
        }
        //PLV-5057 FIM
        //PLV-4536 fim
        
        /**
    * Verifica necessidade de criação de contas
    *
    * @param contratoInserido  - Contrato inserido
    */
        public void processarContasContrato(List < Contract > contratoInseridos) {
            String METHOD_NAME = 'processarContasContrato'; 
            Map < String, Account > mapAccountBenificiarios = new Map < String, Account > ();
            List < BeneficiarioSeguradoProposta__c > BeneficiariosProcessar = new List < BeneficiarioSeguradoProposta__c > ();
            List < Account > contasNovas = new List < Account > ();
            Set < String > cpfBeneficiarios = new Set < String > ();
            Set < Id > idsContratos = new Set < Id > ();
            String strCpf;
            
           

            System.debug(LoggingLevel.ERROR + 'CLASS_NAME: '+ CLASS_NAME + ' => METHOD_NAME: '+ METHOD_NAME + ' => contratoInseridos: ' + contratoInseridos);            
            
            for (Contract contrato: contratoInseridos) {
                idsContratos.add(contrato.Proposta__c);
            }
            
            // List<Quote> lstPropostas = QuoteDAO.getInstance().buscarPropostasPorId(idsContratos);
            
            
            List < SeguradoProposta__c > lstSeguradoPropostas = QuoteDAO.getInstance().buscarListSeguradoProposta(idsContratos);
            
            
            // Lê beneficiários da proposta
            
            for (SeguradoProposta__c seguradoproposta: lstSeguradoPropostas) {
                // monta busca dos beneficiários (existentes ou novos)
                for (BeneficiarioSeguradoProposta__c Beneficiario: seguradoproposta.BeneficiariosSeguradosProposta__r) {
                    // se não é tipo "artigo 792" e tem cpf e não tem conta definida
                    if (Beneficiario.TipoBeneficiario__c != TipoBeneficiarioSemConta &&
                        !String.isBlank(Beneficiario.CpfCnpj__c) &&
                        String.isBlank(Beneficiario.Conta__c)) {
                            strCpf = Beneficiario.CpfCnpj__c.replace('.', '');
                            strCpf = strCpf.replace('-', '');
                            
                            cpfBeneficiarios.add(strCpf);
                            
                            BeneficiariosProcessar.add(Beneficiario);
                        }
                }
                
                // Verifica account
                BuscarContaBeneficiarios(cpfBeneficiarios, mapAccountBenificiarios);
                
                // verifica beneficiários que devem ser criados
                // PLV-5099 - INICIO
                if(contratoInseridos[0].Segmento__c != 'Individual'){
                    for (BeneficiarioSeguradoProposta__c Beneficiario: BeneficiariosProcessar) {
                        strCpf = Beneficiario.CpfCnpj__c.replace('.', '');
                        strCpf = strCpf.replace('-', '');
                        
                        if (!mapAccountBenificiarios.containsKey(strCpf)) {
                            CriarAccountBeneficiario(Beneficiario, contasNovas);
                        }
                    }
                }
                // PLV-5099 - FIM
                
                Savepoint sp = Database.setSavepoint();
                
                try {
                    
                    // criar registros novos em Account
                    if (contasNovas.size() > 0) {
                        insert contasNovas;
                        
                        for (Account conta: contasNovas) {
                            strCpf = conta.CPF__c.replace('.', '');
                            strCpf = conta.CPF__c.replace('-', '');
                            
                            mapAccountBenificiarios.put(strCpf, conta);
                        }
                    }
                    
                    for (BeneficiarioSeguradoProposta__c Beneficiario: BeneficiariosProcessar) {
                        strCpf = Beneficiario.CpfCnpj__c.replace('.', '');
                        strCpf = strCpf.replace('-', '');
                        
                        if (mapAccountBenificiarios.containsKey(strCpf)) {
                            Account conta = mapAccountBenificiarios.get(strCpf);
                            
                            Beneficiario.Conta__c = conta.Id;
                        }
                    }
                    
                    update BeneficiariosProcessar;
                    
                } catch (Exception e) {
                    System.debug(e.getMessage());
                    
                    Database.rollback(sp);
                    
                    contratoInseridos[0].addError(e.getMessage());
                }
                
                cpfBeneficiarios.clear();
                BeneficiariosProcessar.clear();
                mapAccountBenificiarios.clear();
                contasNovas.clear();
                
            }
            
            
        }
        
        
        private void BuscarContaBeneficiarios(Set < String > cpfBeneficiarios, Map < String, Account > mapAccountBenificiarios) {
            List < Account > contas = AccountDAO.getInstance().buscarContasPorIdExterno(cpfBeneficiarios);
            
            for (Account conta: contas) {
                mapAccountBenificiarios.put(conta.IdExterno__c, conta);
            }
            
        }
        
        private void CriarAccountBeneficiario(BeneficiarioSeguradoProposta__c Beneficiario, List < Account > contasNovas) {
            Account conta = new Account();
            
            conta.RecordTypeId = RecordTypeBO.buscarTipoRegistro('Account', 'PessoaFisica').Id;
            conta.LastName = Beneficiario.Nome__c;
            conta.CPF__c = Beneficiario.CpfCnpj__c;
            
            contasNovas.add(conta);
        }
        
        public void executarRegrasLog(List < Contract > contratoInseridos) {
            String METHOD_NAME = 'executarRegrasLog';
        //PLV-3672 inicio
            String CodigoIntegracao = '33';
            String script;
            List < String > fields = new List < String > ();
            fields.add('Id');
            fields.add('Massificados__c');
            fields.add('RamoSeguro__r.Codigo__c');

            List < CriterioIntegracao__mdt > lstCriterio = MetadataDAO.getInstance().buscarCriterio('Contract');
            List < ControleIntegracao__c > lstLog = new List < ControleIntegracao__c > ();
            
            System.debug('lstCriterio ----------------------------------- ' + lstCriterio.size());
            
            //---PLV1882-28 Inicio
            //-- Verifica contratos Emitidos
            List < Contract > contratoEmitidos = new List < Contract > ();
            
            for (Contract contrato: contratoInseridos) {
                System.debug('contrato.Status = ' + contrato.Status);
                //Emitido
                //Em elaboração
                if (contrato.Status == 'Emitido')
                    contratoEmitidos.add(contrato);
            }
            system.debug('ContratosEmitidos ' + contratoEmitidos);
            if (contratoEmitidos.size() > 0) {
                
                for (CriterioIntegracao__mdt criterio: lstCriterio) {
                    System.debug(LoggingLevel.ERROR + 'CLASS_NAME: '+ CLASS_NAME + ' => METHOD_NAME: '+ METHOD_NAME + ' => criterio: ' + criterio);
                    script = util.gerarQuery(criterio.NomeObjeto__c, fields, criterio.Criterio__c);
                    script += MontarFiltroAdicional(contratoEmitidos);
                    System.debug(LoggingLevel.ERROR + 'CLASS_NAME: '+ CLASS_NAME + ' => METHOD_NAME: '+ METHOD_NAME + ' => script: ' + script);
                    for (Contract contrato: Database.query(script)) {
                        System.debug(LoggingLevel.ERROR + 'CLASS_NAME: '+ CLASS_NAME + ' => METHOD_NAME: '+ METHOD_NAME + ' => contrato: ' + contrato);
                        ControleIntegracao__c log = new ControleIntegracao__c();
                        log.DataCriacaoRegistro__c = Date.today();
                        log.IdObjeto__c = contrato.Id;
                        log.Status__c = 'Pendente';
                        System.debug(LoggingLevel.ERROR + 'CLASS_NAME: '+ CLASS_NAME + ' => METHOD_NAME: '+ METHOD_NAME + ' => contrato.Massificados__c: ' + contrato.Massificados__c);
                        System.debug(LoggingLevel.ERROR + 'CLASS_NAME: '+ CLASS_NAME + ' => METHOD_NAME: '+ METHOD_NAME + ' => contrato.RamoSeguro__r.Codigo__c: ' + contrato.RamoSeguro__r.Codigo__c);                        
                        if(contrato.Massificados__c == true && contrato.RamoSeguro__r.Codigo__c == '1377'){
                            log.CodigoIntegracao__c = criterio.CodigoIntegracao__c;
                        }else{
                            log.CodigoIntegracao__c = CodigoIntegracao;
                        }

                        lstLog.add(log);
    //PLV-3672 fim					
                        
                        if (Test.isRunningTest()) {
                            break;
                        }
                    }
                    //---PLV1882-28 Fim
                    
                    if (Test.isRunningTest()) {
                        break;
                    }
                }
                System.debug(LoggingLevel.ERROR + 'CLASS_NAME: '+ CLASS_NAME + ' => METHOD_NAME: '+ METHOD_NAME + ' => lstLog: ' + lstLog);                        
                insert lstLog;
            }
            
        }
        
        public HerokuResponseTO.LoteTO consultarEstoque(ContratoTO.ConsultarEstoqueTO consultarEstoqueTO) {
            return herokuServ.consultarEstoque(consultarEstoqueTO);
        }
        
        public HerokuResponseTO.ArquivoECMTO consultarArquivoECM(ContratoTO.ConsultarArquivoECMTO consultarArquivoECMTO) {
            return herokuServ.consultarArquivoECM(consultarArquivoECMTO);
        }
        
    //PLV-4344-Fix - Inicio
    //PLV-2605-29 INICIO
    public List<ParcelaContratoTO> gerarParcelasContrato(List<Contract> listContrato, List<BusinessHours> lstHorariosComerciais, Map<Id, Boolean> mapAntecipaComissaoContrato){ //PLV-4438 - Inicio/Fim
    //PLV-2605-29 FIM
    //PLV-4344-Fix - Fim

            // Instancias
            Set < Id > setResponsavelPagamentoId = new Set < Id > ();
            Set < Id > setSeguradoContrato = new Set < Id > ();
            Set < String > setCodigoParceiro = new Set < String > ();
            Set < Id > setProdutos = new Set < Id > ();
            Map < String, ProdutoParceiro__c > mapProdutoParceiroPorChaveParceiroEProduto = new Map < String, ProdutoParceiro__c > ();
            Map < Id, Parceiro__c > mapParceiroPorContaResponsavelPagamento = new Map < Id, Parceiro__c > ();
            Map < Id, List < SeguradoContrato__c >> mapSeguradosContratoPorContratanteContrato = new Map < Id, List < SeguradoContrato__c >> ();
            List < ParcelaContratoTO > listParcelaContratoTO = new List < ParcelaContratoTO > ();
            
            Double periodoMaximoInadimplenciaProd = util.buscaPeriodoInadimplenciaProd(listContrato[0].produto__c);// PLV-5768 - INICIO/FIM

            // Busca os contratos com as informacoes necessarias para a geracao de parcelas
            for (Contract contrato: listContrato) {
                
                // recupera os contratantes que possuem as informacoes de parcelas
                List < ContratanteContrato__c > listContratanteContrato = contrato.ContratantesContrato__r;
                
                if (contrato.Parceiro__c != null) {
                    // PLV-4660 INICIO
                    // PLV-4660-FIX 2 INICIO
                    if(contrato.Tipo__c == 'Cancelamento'){
                        setCodigoParceiro.add(contrato.Proposta__r.Contract.Parceiro__c);
                        setProdutos.add(contrato.Proposta__r.Contract.Produto__c);
                    }else{
                        setCodigoParceiro.add(contrato.Parceiro__c);
                        setProdutos.add(contrato.Produto__c);
                    }
                    // PLV-4660 FIM
                    // PLV-4660-FIX 2 FIM
                }
                
                
                for (ContratanteContrato__c contratanteContrato: listContratanteContrato) {
                    setSeguradoContrato.add(contratanteContrato.Id);
                    System.debug('test1612-1');
                    if (contratanteContrato.ResponsavelPagamento__c != null) {
                        setResponsavelPagamentoId.add(contratanteContrato.ResponsavelPagamento__c);
                    }
                }
                
            }
            
            // Busca as vidas do Segurado
            for (SeguradoContrato__c seguradoContrato: dao.buscarSeguradosContrato(setSeguradoContrato)) {
                List < SeguradoContrato__c > listSeguradoContrato = mapSeguradosContratoPorContratanteContrato.get(seguradoContrato.GrupoContrato__r.ContratanteContrato__c);
                if (listSeguradoContrato == null) listSeguradoContrato = new List < SeguradoContrato__c > ();
                listSeguradoContrato.add(seguradoContrato);
                mapSeguradosContratoPorContratanteContrato.put(seguradoContrato.GrupoContrato__r.ContratanteContrato__c, listSeguradoContrato);
                
                if (seguradoContrato.ResponsavelPagamento__c != null) {
                    setResponsavelPagamentoId.add(seguradoContrato.ResponsavelPagamento__c);
                }
            }
            
            // Busca o codigo do produto do parceiro
            for (ProdutoParceiro__c produtoParceiro: dao.buscarProdutoDoParceiro(setCodigoParceiro, setProdutos)) {
                System.debug('Produto do parceiro ------- ' + produtoParceiro);
                mapProdutoParceiroPorChaveParceiroEProduto.put(produtoParceiro.Parceiro__r.Codigo__c + '_' + produtoParceiro.Produto__c, produtoParceiro);
            }
            
            // Busca os Parceiros
            for (Parceiro__c parceiro: dao.buscarParceiros(setResponsavelPagamentoId)) {
                mapParceiroPorContaResponsavelPagamento.put(parceiro.Conta__c, parceiro);
            }
            
            // itera os contratos
        //PLV-4101 - INICIO
        system.debug('PLV-4101 - lista contrato'+listContrato);
        //PLV-4101 - FIM
        for(Contract contrato : listContrato){

                // Pega os segurados do contrato
                List < ContratanteContrato__c > listContratanteContrato = contrato.ContratantesContrato__r;
                if (listContratanteContrato == null) listContratanteContrato = new List < ContratanteContrato__c > ();
                
                // Itera os segurados do contrato
        for(ContratanteContrato__c contratanteContrato : listContratanteContrato)
        {
                    if (contratanteContrato.QuantidadeParcelas__c == null)
                        contratanteContrato.QuantidadeParcelas__c = 0;
                    
                    System.debug('==> contratanteContrato.QuantidadeParcelas__c ' + contratanteContrato.QuantidadeParcelas__c);
                    
                    System.debug('==> Gerar parcelas ' + contrato.Parceiro__c + '_' + contrato.Produto__c);
                    
                    //PLV-5094 - INICIO
                    system.debug('checkCancelamentoRecuperaAGE HENRIQUE 2: ' + checkCancelamentoRecuperaAGE(contrato));
                    if(contratanteContrato.QuantidadeParcelas__c == 0 && checkCancelamentoRecuperaAGE(contrato)) { // PLV-5766-INICIO/FIM
                        contratanteContrato.QuantidadeParcelas__c = 1;
                    }
                    //PLV-5094 - FIM
                    
                    //PLV-2780 - Inicio - Criar parcelas do contrato
                    String produto;
                    
                    List < SeguradoContrato__c > listSeguradoContrato = mapSeguradosContratoPorContratanteContrato.get(contratanteContrato.Id);
                    
                    // Verifica se tem Vidas nesse segurado
                    if (!listSeguradoContrato.isEmpty()) {
                        
                        // Itera as vidas para gerar as parcelas
                    for(SeguradoContrato__c seguradoContrato : listSeguradoContrato)
                    {

                            if (seguradoContrato.TipoResponsavelPagamento__c == 'PAR' || contratanteContrato.TipoResponsavelPagamento__c == 'PAR') {
                                System.debug('contrato.Parceiro__c = ' + contrato.Parceiro__c);
                                System.debug('contrato.Produto__c = ' + contrato.Produto__c);

                                if (contrato.Parceiro__c == null || contrato.Produto__c == null) {
                                    throw new ContractException('Produto/Parceiro do contrato não encontrado.');
                                }
                                // PLV-4660-FIX INICIO
                                ProdutoParceiro__c produtoParceiro = null;
                                if(contrato.Tipo__c == 'Cancelamento'){
                                    produtoParceiro = mapProdutoParceiroPorChaveParceiroEProduto.get(contrato.Proposta__r.Contract.Parceiro__c + '_' + contrato.Produto__c) == null ? null : mapProdutoParceiroPorChaveParceiroEProduto.get(contrato.Proposta__r.Contract.Parceiro__c + '_' + contrato.Produto__c);  //PLV-5884 FIX-13 INICIO/FIM
                                }else{
                                    produtoParceiro = mapProdutoParceiroPorChaveParceiroEProduto.get(contrato.Parceiro__c + '_' + contrato.Produto__c);
                                }
                                // PLV-4660-FIX FIM
                                
                            
                                system.debug('Teste Doug Perfil >>'+contrato.Parceiro__c + '_' + contrato.Produto__c);
                                system.debug('Teste Doug Perfil >>'+mapProdutoParceiroPorChaveParceiroEProduto);
                                // PLV-4660-FIX 3
                                if(contrato.Tipo__c == 'Cancelamento'){
                                    produto = contrato.Proposta__r.Contract.Parceiro__c == null ? null : contrato.Proposta__r.Contract.Parceiro__c;   //PLV-5884 FIX-13 INICIO/FIM
                                }else{
                                    if (produtoParceiro == null || String.isBlank(produtoParceiro.CodigoProdutoParceiro__c)) {
                                        throw new ContractException('Produto do parceiro não encontrado.');
                                    }
                                    produto = produtoParceiro.CodigoProdutoParceiro__c;
                                }
                                System.debug('Codigo do produto na parcela ' + produto);
                            } else { //PLV-3565 - INICIO/FIM - Removido a logica para atender as necessidades
                                if (contratanteContrato.ResponsavelPagamento__c == null || contrato.Produto__c == null) {
                                    throw new ContractException('Responsável pelo pagamento/produto do contrato não encontrado.');
                                }
                                produto = contrato.Produto__r.ProductCode;
                                System.debug('Codigo do produto na parcela ' + produto);
                            }
                            //PLV-2780 - Fim - Criar parcelas do contrato
                            //PLV-3565 - INICIO - Trecho comentado momentaneamente
                            /*for (Integer i = 0; i < seguradoContrato.QuantidadeParcelas__c; i++) {
                                
                                // Gera parcelas do contrato para o segurado
                                ParcelaContratoTO parcelaContratoTO =
                                    gerarParcelaContratoTO(
                                        contrato,
                                        contratanteContrato,
                                        seguradoContrato,
                                        produto,
                                        i + 1,
                                        i,
                                        mapParceiroPorContaResponsavelPagamento,
                                        true
                                    );
                                
                                listParcelaContratoTO.add(parcelaContratoTO);
                            }*/
                            //PLV-3565 - FIM
                        }
                    }
                    
                    // Gera as Parcelas do contrato de acordo com a quantidade de Parcelas
                    //PLV-4101 - INICIO
                    System.debug('PLV-4101 - lista contratanteContrato'+contratanteContrato);
                    //PLV-4101 - FIM

                    //PLV-4603 - Inicio - Isabela Fin - Globant

                     /*
                      TO-DO -> TRAZER A VALIDAÇÃO DO checkCancelamentoRecuperaAGE PARA ESSE PONTO
                    */
                    Map<String, Object> mapParams = new Map<String, Object>();
                    mapParams.put('contratanteContrato', (Object) contratanteContrato);
                    mapParams.put('seguradoContrato', (Object) null);
                    mapParams.put('contrato', (Object) contrato);
                    mapParams.put('ehSergurado', (Object) false);
                    mapParams.put('qtdParcelas', (Object) Integer.valueOf(contratanteContrato.QuantidadeParcelas__c));
                    mapParams.put('produto', (Object) produto);
                    mapParams.put('mapAntecipaComissaoContrato', (Object) mapAntecipaComissaoContrato);
                    mapParams.put('mapParceiroPorContaResponsavelPagamento', (Object) mapParceiroPorContaResponsavelPagamento);
                    //mapParams.put('lstHorariosComerciais', (Object) lstHorariosComerciais);
                    System.debug('Danilo mapParams==>' + mapParams);
                    gerarParcelaContratoTO(mapParams, 1, null, listParcelaContratoTO,periodoMaximoInadimplenciaProd); //PLV-5768 - INCIO/FIM
                    //PLV-4603 - Fim - Isabela Fin - Globant
                }
            }
            
            // Envia as parcelas
        //PLV-2605-29 INICIO
        return listParcelaContratoTO;
        //PLV-2605-29 FIM
        }
        // PLV-2312-28 FIM
        
        // PLV-2312 INICIO
        public Boolean verificarContratosMassificados() {
            List < Contract > listContratos = dao.verificarContratosMassificados();
            if (listContratos.isEmpty()) {
                return false;
            }
            return true;
        }
        // PLV-2312 FIM
        
        // PLV-2312-28 INICIO
        public Boolean cancelarParcelasContratoOriginaisHeroku(List < Contract > listContratoCancelamento) {
            
            List < ServiceTO.ParcelaCancelamentoTO > parcelas = new List < ServiceTO.ParcelaCancelamentoTO > ();
            

            
            
        for(Contract contratoCancelamento : listContratoCancelamento){
           
        Contract contratoOriginal = contratoCancelamento.Proposta__r.Contract;

        if(contratoOriginal == null){
                    System.debug('Erro: Contrato original não encontrado');
                    throw new ContractException('Erro: Contrato original do não encontrado.');
                }

            
                ServiceTO.ParcelaCancelamentoTO parcela = new ServiceTO.ParcelaCancelamentoTO();
        parcela.apolice = contratoOriginal.NumeroApolice__c;
        parcela.ramo = contratoOriginal.RamoSeguro__r.Codigo__c;
        parcela.endosso = contratoOriginal.Endosso__c;
        parcela.sucursal = contratoOriginal.Sucursal__c;
                parcelas.add(parcela);
            }
            
            return HerokuService.getInstance().cancelarParcelasContrato(parcelas);
        }
        // PLV-2312-28 FIM
        
        // PLV-2312-28 INICIO
        public Boolean cancelarContratosOriginaisHeroku(List < Contract > listContratoCancelamento) {
            
            List < ServiceTO.SeguroContratoCancelamentoTO > listSeguroContratoCancelamentoTO = new List < ServiceTO.SeguroContratoCancelamentoTO > ();
            
        for(Contract contratoCancelamento : listContratoCancelamento){

        Contract contratoOriginal = contratoCancelamento.Proposta__r.Contract;

        if(contratoOriginal == null){
            System.debug('Erro: Contrato original não encontrado');
            throw new ContractException('Erro: Contrato original não encontrado.');
        }
        ServiceTO.SeguroContratoCancelamentoTO seguro = new ServiceTO.SeguroContratoCancelamentoTO();
        seguro.apolice  = contratoOriginal.NumeroApolice__c;
        seguro.endosso  = contratoOriginal.Endosso__c;
        seguro.sucursal = contratoOriginal.Sucursal__c;
        seguro.ramo     = contratoOriginal.RamoSeguro__r.Codigo__c;
        seguro.empresa  = contratoOriginal.Empresa__c;
                listSeguroContratoCancelamentoTO.add(seguro);
            }
            
            
            return HerokuService.getInstance().cancelarContrato(listSeguroContratoCancelamentoTO);
        }
        // PLV-2312-28 FIM
        
        // PLV-2312-28 INICIO REMOCAO DE METODO NAO UTILIZADO
        // PLV-2312-28 FIM REMOCAO DE METODO NAO UTILIZADO

        // PLV-4603 - Inicio - Isabela Fin - Globant
        // PLV-2312-28 INICIO
        // PLV-4438 - Inicio
        // PLV-4344-Fix - Inicio
        
        public void gerarParcelaContratoTO(Map<String, Object> mapParams, Integer numeroParcela, Date vencimentoParcelaAnterior, List<ParcelaContratoTO> parcelasContrato, Double periodoMaximoInadimplenciaProd) { //PLV-5768 - INCIO/FIM
        // PLV-4344-Fix - Fim
        System.debug('mapParams : ' + mapParams);
        System.debug('numeroParcela : ' + numeroParcela);
        System.debug('vencimentoParcelaAnterior : ' + vencimentoParcelaAnterior);
        System.debug('parcelasContrato : ' + parcelasContrato);
        System.debug('periodoMaximoInadimplenciaProd : ' + periodoMaximoInadimplenciaProd);
        System.debug(LoggingLevel.ERROR, 'gerarParcelaContratoTO');
            
            //Muitos parametros no metodo, coloca os fixos em mapa de string/object
            Integer qtdParcelas = (Integer) mapParams.get('qtdParcelas');
            if(numeroParcela > qtdParcelas) return; //encerra geracao

            String produto = (String) mapParams.get('produto');
            Boolean ehSegurado = (Boolean) mapParams.get('ehSegurado');
            Contract contrato = (Contract) mapParams.get('contrato');
            ContratanteContrato__c contratanteContrato = (ContratanteContrato__c) mapParams.get('contratanteContrato');
            SeguradoContrato__c seguradoContrato = (SeguradoContrato__c) mapParams.get('seguradoContrato');
            Map<Id, Parceiro__c> mapParceiroPorContaResponsavelPagamento = (Map<Id, Parceiro__c>) mapParams.get('mapParceiroPorContaResponsavelPagamento');
            Map<Id, Boolean> mapAntecipaComissaoContrato = (Map<Id, Boolean>) mapParams.get('mapAntecipaComissaoContrato');
            //List<BusinessHours> lstHorariosComerciais = (List<BusinessHours>) mapParams.get('lstHorariosComerciais');
        
            System.debug('------ Gerar Parcela do contrato para o contratante : ' + contratanteContrato + 'e segurado: ' + seguradoContrato);
            
            System.debug('===>mapParamsContrato: ' + mapParams.get('contrato'));
            System.debug('===>mapParams: ' + mapParams);
            System.debug('===>mapParceiroPorContaResponsavelPagamento: ' + mapParceiroPorContaResponsavelPagamento);
            Parceiro__c parceiro = mapParceiroPorContaResponsavelPagamento.get(contratanteContrato.ResponsavelPagamento__c);
            
            ParcelaContratoTO parcelaContratoTO = new ParcelaContratoTO();
            
            try {
                parcelaContratoTO.origemproposta = Integer.valueOf(contrato.Proposta__r.Origem__c);
                parcelaContratoTO.idproposta = contrato.Proposta__r.Name;
                parcelaContratoTO.numeropropostaporto = contrato.Proposta__r.NumeroProposta__c;
                parcelaContratoTO.produto = produto;
                parcelaContratoTO.apolice = contrato.NumeroApolice__c;
                parcelaContratoTO.empresa = contrato.Empresa__c;
                parcelaContratoTO.sucursal = contrato.Sucursal__c;
                parcelaContratoTO.ramo = contrato.RamoSeguro__r.Codigo__c;
                parcelaContratoTO.endosso = contrato.Endosso__c;
                parcelaContratoTO.numeroparcela = numeroParcela;
                parcelaContratoTO.status = 'PENDENTE';
                parcelaContratoTO.statusIntegracao = 'PENDENTE'; //PLV-4674 - INICIO/FIM
                parcelaContratoTO.titulo = '';
                //PLV-4344-Fix - Inicio
                //PLV-4702 INICIO
                System.debug('Danilo mapAntecipaComissaoContrato ==>' + mapAntecipaComissaoContrato);
                System.debug('Danilo contrato.Id ==>' + contrato.Id);
                if(mapAntecipaComissaoContrato.containsKey(contrato.Id))
                    parcelaContratoTO.antecipacaocomissao = mapAntecipaComissaoContrato.get(contrato.Id) == true ? 'S' : 'P';
                else
                    parcelaContratoTO.antecipacaocomissao = 'P';
                //PLV-4702 FIM
                //PLV-4344-Fix - Fim
                    //PLV-4415 - INICIO 
                System.debug('contratanteContrato.Id Danilo: ' + contratanteContrato.Id);
                parcelaContratoTO.seguradosalesforce = contratanteContrato.Id;
                //parcelaContratoTO.seguradosalesforce = seguradoContrato.Id;
                //PLV-4415 - FIM
                parcelaContratoTO.dataemissao = String.valueOf(System.today());
                //parcelaContratoTO.dataemissao = '2023-01-10';
                //System.debug('parcelaContratoTO.dataemissao: ' + parcelaContratoTO.dataemissao);

                // Verifica se eh um parceiro
                System.debug('Danilo 629');
                System.debug('Danilo contratanteContrato.TipoResponsavelPagamento__c ==> ' + contratanteContrato.TipoResponsavelPagamento__c);
                System.debug('Danilo contratanteContrato.parcelaContratoTO.codigoparceiro ==> ' + parcelaContratoTO.codigoparceiro);
                //System.debug('Danilo parceiro.Codigo__c ==> ' + parceiro.Codigo__c);
                if (contratanteContrato.TipoResponsavelPagamento__c == 'PAR')
                    parcelaContratoTO.codigoparceiro = parceiro.Codigo__c;
                
                // Verifica se eh vida ou segurado
                // Trecho comentado, pois VI e Viagem não gravam parcelas e forma de pagamento em segurado,
                // mas nesse momento (09/10/2020), não sabemos se VG gravará parcelas e forma de pagamento em segurado
                /*if(ehSegurado)
                {
                    parcelaContratoTO.vidasalesforce = seguradoContrato.Id;
                    parcelaContratoTO.idexterno = contrato.Id + '_' + seguradoContrato.Id;
                    parcelaContratoTO.responsavelfinanceiro = seguradoContrato.ResponsavelPagamento__c;
                    parcelaContratoTO.tiporesponsavelpagamento = seguradoContrato.TipoResponsavelPagamento__c;
                    parcelaContratoTO.datavencimento = String.valueOf(seguradoContrato.VencimentoPrimeiraParcela__c.addMonths(mesesAteVencer));   
                    
                    parcelaContratoTO.valoriof = calcularValor(Integer.valueOf(seguradoContrato.QuantidadeParcelas__c), numeroParcela, seguradoContrato.IOF__c);
                    parcelaContratoTO.valorparcela = calcularValor(Integer.valueOf(seguradoContrato.QuantidadeParcelas__c), numeroParcela, seguradoContrato.PremioTotal__c);
                    // premio liquido da parcela eh a diferença entre premio total e valor iof
                    parcelaContratoTO.valorliquido = parcelaContratoTO.valorparcela - parcelaContratoTO.valoriof;
                }
                else
                {*/
                    parcelaContratoTO.idexterno = contrato.Id + '_' + contratanteContrato.Id;
                    parcelaContratoTO.responsavelfinanceiro = contratanteContrato.ResponsavelPagamento__c;
                    parcelaContratoTO.tiporesponsavelpagamento = contratanteContrato.TipoResponsavelPagamento__c;
                    parcelaContratoTO.valoriof = calcularValor(Integer.valueOf(contratanteContrato.QuantidadeParcelas__c), numeroParcela, contratanteContrato.IOF__c);
                    parcelaContratoTO.valorparcela = calcularValor(Integer.valueOf(contratanteContrato.QuantidadeParcelas__c), numeroParcela, contratanteContrato.PremioTotal__c);
                    // premio liquido da parcela eh a diferença entre premio total e valor iof
                    //FNPVVEP-96 INICIO
                    //FNPVVEP-148 INICIO
                    if(contratanteContrato.PremioComercial__c == 0){
                        parcelaContratoTO.valorliquido = parcelaContratoTO.valorparcela - parcelaContratoTO.valoriof;
                    }else{
                        parcelaContratoTO.valorliquido = calcularValor(Integer.valueOf(contratanteContrato.QuantidadeParcelas__c), numeroParcela, contratanteContrato.PremioComercial__c); 
                    }
                    //FNPVVEP-148 FIM
                    //FNPVVEP-96 FIM

                    //PLV-4893 FIX 2 - INÍCIO
                    if(parcelaContratoTO.valorparcela < 0){
                        parcelaContratoTO.datacobertura = String.valueOf(contrato.StartDate);
                    }
                    //PLV-4893 FIX 2 - FIM

                    //PLV-4794 - Inicio
                    Decimal valorAgenciamento 	= 0;
                    
                    Map<String,Object> mapValorEndosso = new Map<String,Object>();//PLV-4973 - INICIO/FIM
                    //PLV-4601 - INICIO
                    System.debug('Danilo numeroParcela >' + numeroParcela);
                    System.debug('Danilo contrato.Tipo__c >' + contrato.Tipo__c);
                    if((numeroParcela == 1 || numeroParcela == 2) && (contrato.Tipo__c == 'Endosso' || contrato.Tipo__c == 'Cancelamento')){

                        Set<Id> idsContrato = new Set<Id>();
                        idsContrato.add(contrato.Id);
                        valorAgenciamento = 0;

                        //PLV-5101 - INICIO - Se houver restituição, utilizar agenciamento do contrato original
                        if(contrato.Tipo__c == 'Endosso' && contratanteContrato.PremioComercial__c != null && 
                        contratanteContrato.PremioComercial__c < 0 ){
                            idsContrato.clear();
                            idsContrato.add(contrato.contratoOriginal__r.Id);
                        }
                        //PLV-5101 - FIM

                        //PLV-4973 - INICIO
                        for(RemuneracaoContrato__c  remContr : ContractDAO.getInstance().buscarRemuneracaoContratoPorId(idsContrato))
                        {
                            if(remContr.TipoRemuneracao__r.Name == 'AGENCIAMENTO'){
                                mapValorEndosso = GerarPremioAGE.gravaValorEndosso(contrato, remContr, numeroParcela);
                                valorAgenciamento = (decimal) mapValorEndosso.get('proRataAgenciador'); 
                            }
                        }
                        decimal excludente = mapValorEndosso.containskey('excludenteCorretor') ? (decimal)mapValorEndosso.get('excludenteCorretor') > valorAgenciamento? valorAgenciamento :(decimal)mapValorEndosso.get('excludenteCorretor') :0;
                        parcelaContratoTO.valorrestituicao = valorAgenciamento > 0 ? mapValorEndosso.containskey('excludenteCorretor') ? valorAgenciamento-excludente : valorAgenciamento : null;//PLV-4973-INICIO/FIM - PEDRO AUGUSTO BRAZ
                        
                        
                        Integer qtdParcelasPagas =  mapValorEndosso.containskey('qtdParcelasPagas') ? (Integer) mapValorEndosso.get('qtdParcelasPagas') : null;
                        Decimal percAgenc =  mapValorEndosso.containskey('percAgenc') ? (decimal) mapValorEndosso.get('percAgenc') : null;
                        Decimal originalParcelas =  mapValorEndosso.containskey('originalParcelas') ? (decimal) mapValorEndosso.get('originalParcelas') : null;
                        //PLV-5094-FIX2 - INICIO
                        Boolean temPremio = (contratanteContrato.PremioComercial__c != null && contratanteContrato.PremioComercial__c != 0);
                        System.debug('temPremio HENRIQUE: '+ temPremio);
                        if((originalParcelas==11 && temPremio) || (percAgenc!=null &&  qtdParcelasPagas!=null && ((percAgenc==100 && qtdParcelasPagas>1) ||(percAgenc==200 && qtdParcelasPagas>2))))
                            parcelaContratoTO.valorrestituicao = valorAgenciamento > 0 ? mapValorEndosso.containskey('excludenteCorretor') ? valorAgenciamento + parcelaContratoTO.valorliquido : valorAgenciamento : null;//PLV-4973-INICIO/FIM - PEDRO AUGUSTO BRAZ
                        else if(!temPremio)
                            parcelaContratoTO.valorrestituicao = null;   
                        //PLV-5094-FIX2 - FIM
                        //bkp//parcelaContratoTO.valorrestituicao = valorAgenciamento > 0 ? mapValorEndosso.containskey('excludenteCorretor') ? (valorAgenciamento-excludente) + parcelaContratoTO.valorliquido : valorAgenciamento + parcelaContratoTO.valorliquido : null;//PLV-4973-INICIO/FIM - PEDRO AUGUSTO BRAZ
                        //verificar as parcelas do contrato o
                        //parcelaContratoTO.valorrestituicao = valorAgenciamento > 0 ? valorAgenciamento + parcelaContratoTO.valorliquido : null;//PLV-4973-INICIO/FIM - PEDRO AUGUSTO BRAZ
                        //PLV-4973 - FIM

                    }
                    restit = parcelaContratoTO.valorrestituicao;//PLV-5766-INICIO/FIM
                    System.debug('Valor Restituicao Jhow '+ restit);
                    if((numeroParcela == 1 && (contrato.Tipo__c != 'Endosso' && contrato.Tipo__c != 'Cancelamento')) || (numeroParcela ==2 && contratanteContrato.PremioComercial__c != null && contratanteContrato.PremioComercial__c > 0 && (contrato.Tipo__c != 'Endosso' && contrato.Tipo__c != 'Cancelamento'))){
                    //PLV-4601 - FIM
                        Set<Id> idsContrato = new Set<Id>();
                        Decimal percentualAgenciamento = 0;
                        
                        idsContrato.add(contrato.Id);
                        
                        for(RemuneracaoContrato__c  remContr : ContractDAO.getInstance().buscarRemuneracaoContratoPorId(idsContrato))
                        {
                            if(remContr.TipoRemuneracao__r.Name == 'AGENCIAMENTO')
                                percentualAgenciamento = remContr.Percentual__c;
                        }
                        
                        //PLV-4794 - FIX02 - INICIO (Problema apontado por Camila Kume - RENNER)
                        valorAgenciamento = 0;
                        if (contratanteContrato.PremioComercial__c != null || contratanteContrato.PremioComercial__c > 0) {
                            valorAgenciamento = contratanteContrato.PremioComercial__c/12;
                        }
                        //PLV-4794 - FIX02 - FIM (Problema apontado por Camila Kume - RENNER)                   
                        
                        if(percentualAgenciamento == 100 && numeroParcela == 2)
                            valorAgenciamento = 0;
                        
                    }
                    parcelaContratoTO.valoragenciamento = valorAgenciamento;
                    //PLV-4794 - Fim
                    
                    //PLV-4438-Fix3 - Inicio
                    //PLV-4438-Fix2 - Inicio
                    //PLV-5470 INICIO
                    Date dataVenc;
                    //Date dataVenc = numeroParcela == 1 ? contratanteContrato.VencimentoPrimeiraParcela__c : vencimentoParcelaAnterior;
                    //PLV-5832 INICIO
                    Integer vencDemaisParcelas;
                    if(contratanteContrato.VencimentoDemaisParcelas__c != null){
                        System.debug('ENTROU AQUI HENRIQUE NO IFVencimentoDemaisParcelas__c ');
                        vencDemaisParcelas = contratanteContrato.VencimentoDemaisParcelas__c != null && contratanteContrato.VencimentoDemaisParcelas__c.isNumeric() ?
                        Integer.valueOf(contratanteContrato.VencimentoDemaisParcelas__c) : Integer.valueOf(contratanteContrato.VencimentoDemaisParcelas__c.replaceAll('[^0-9]', '')); //PLV-5768
                    }
                    //PLV-5832 FIM
                    system.debug('vencDemaisParcelas HENRIQUE 1:  ' + vencDemaisParcelas);
                    //PLV-5470 FIX-02 INICIO
                    Integer vencDemaisParcelasIncluindoSempre30;
                    if (vencDemaisParcelas != null) vencDemaisParcelasIncluindoSempre30 = Integer.valueOf(contratanteContrato.VencimentoDemaisParcelas__c.replaceAll('[^0-9]', ''));
                    system.debug('vencDemaisParcelasIncluindoSempre30 HENRIQUE 1:  ' + vencDemaisParcelasIncluindoSempre30);
                    Integer numDiasCheck;
                    //Chamado 8096889 INICIO
                    Integer numDiasProximoMes; 
                    Integer numDiasEsteMes; 
                    Boolean proximoMes;
                    //PLV-5470 FIX-01 INICIO
                    if(vencDemaisParcelas != null){
                        if(numeroParcela == 1){                        
                            if(vencDemaisParcelasIncluindoSempre30 < contratanteContrato.VencimentoPrimeiraParcela__c.Day()){
                                System.debug('Entrou aqui vencimento demais parcela menor');
                                numDiasCheck = contratanteContrato.VencimentoPrimeiraParcela__c.daysBetween(Date.newInstance(contratanteContrato.VencimentoPrimeiraParcela__c.year(), (contratanteContrato.VencimentoPrimeiraParcela__c.month()+1), vencDemaisParcelasIncluindoSempre30));
                            }else{
                                System.debug('Entrou aqui no else');
                                numDiasCheck = contratanteContrato.VencimentoPrimeiraParcela__c.daysBetween(Date.newInstance(contratanteContrato.VencimentoPrimeiraParcela__c.year(), contratanteContrato.VencimentoPrimeiraParcela__c.month(), vencDemaisParcelasIncluindoSempre30));
                            }
                        }else{
                            if(numeroParcela == 2){
                                System.debug('Entrou no else 2');
                                System.debug('contratanteContrato.VencimentoPrimeiraParcela__c <><> ' + contratanteContrato.VencimentoPrimeiraParcela__c);
                                System.debug('vencDemaisParcelasIncluindoSempre30 <><> ' + vencDemaisParcelasIncluindoSempre30);
                                System.debug('contratanteContrato.VencimentoPrimeiraParcela__c.Day() <><> ' + contratanteContrato.VencimentoPrimeiraParcela__c.Day());
                                numDiasProximoMes = contratanteContrato.VencimentoPrimeiraParcela__c.daysBetween(Date.newInstance(contratanteContrato.VencimentoPrimeiraParcela__c.year(), (contratanteContrato.VencimentoPrimeiraParcela__c.month()+1), vencDemaisParcelasIncluindoSempre30)); //
                                //Chamado 8096889 FIX01 INICIO
                                if(vencDemaisParcelasIncluindoSempre30 < contratanteContrato.VencimentoPrimeiraParcela__c.Day()){
                                    proximoMes = true;
                                    numDiasCheck = 0;
                                //Chamado 8096889 FIX01 FIM
                                }else{
                                    System.debug('Entrou aqui no else 2');
                                    numDiasEsteMes = contratanteContrato.VencimentoPrimeiraParcela__c.daysBetween(Date.newInstance(contratanteContrato.VencimentoPrimeiraParcela__c.year(), contratanteContrato.VencimentoPrimeiraParcela__c.month(), vencDemaisParcelasIncluindoSempre30));
                                    if(numDiasEsteMes < 20){
                                        numDiasCheck = numDiasEsteMes;
                                        proximoMes = true;
                                    }else{
                                        numDiasCheck = numDiasEsteMes;
                                        proximoMes = false;
                                    }
                                }
                            }
                        }
                    }else{
                        System.debug('entrou no else do vencDemaisParcelas != null');
                        numDiasCheck = 30;
                    }
                    System.debug('NumDiasCheck depois de atribuição: ' + numDiasCheck);
                    //PLV-5470 FIX-02 FIM  
                    //PLV-5470 FIX-01 FIM
                    if(numeroParcela == 1){
                        dataVenc = contratanteContrato.VencimentoPrimeiraParcela__c;
                    }else if(numeroParcela == 2){
                        System.debug('Entrou aqui no else if aqui');
                        if(vencDemaisParcelas != null){
                            if(proximoMes){
                                System.debug('Entrou no if aqui');
                                dataVenc = Date.newInstance(contratanteContrato.VencimentoPrimeiraParcela__c.year(), (contratanteContrato.VencimentoPrimeiraParcela__c.month()+1), vencDemaisParcelasIncluindoSempre30);
                                numDiasCheck += 30;
                                System.debug('numDiasCheck if certo 2 ' + numDiasCheck);
                            }else{
                                System.debug('Entrou no else aqui');
                                //dataVenc = Date.newInstance(vencimentoParcelaAnterior.year(), (vencimentoParcelaAnterior.month()+1), vencDemaisParcelasIncluindoSempre30);
                                dataVenc = Date.newInstance(vencimentoParcelaAnterior.year(), vencimentoParcelaAnterior.month(), vencimentoParcelaAnterior.day()); //PLV-5832 INICIO/FIM FIX03
                                System.debug('Data venc do else 796 ' + dataVenc);
                            }
                        }
                    //Chamado 8096889 FIM
                    }else{
                        dataVenc = vencimentoParcelaAnterior.addMonths(1);
                        //dataVenc = vencimentoParcelaAnterior;
                    }
                    //PLV-4893 FIX 2 - INÍCIO
                    //PLV-4532 - INICIO - FIX 3
                     
                    
                    //System.debug('novaDataCobertura HENRIQUE:' + novaDataCobertura);
                    //system.debug('HENRIQUE parcelaContratoTO.datacobertura: ' + parcelaContratoTO.datacobertura);
                    //PLV-4532 - FIM - FIX 3         
                    // //PLV-4532 - FIM 
                    if(parcelaContratoTO.valorparcela < 0){
                        parcelaContratoTO.datacobertura = String.valueOf(contrato.StartDate);
                    }
                    //PLV-4893 FIX 2 - FIM
                    if(numeroParcela > 1) {
                        //PLV-5773 INICIO
                        Date vigenciaFinal = contrato.VigenciaFinal__c;
                        //PLV-5832 INICIO
                        if(contratanteContrato.VencimentoDemaisParcelas__c != 'A cada 30 dias' && contratanteContrato.VencimentoDemaisParcelas__c != null ){
                            System.debug('VENCIMENTO DE MAIS PARCELAS: ' + contratanteContrato.VencimentoDemaisParcelas__c);
                            if(vencimentoParcelaAnterior.month() == 1 && vencDemaisParcelasIncluindoSempre30 > 27){
                                Integer diasMes = Date.daysInMonth(vencimentoParcelaAnterior.year(), (vencimentoParcelaAnterior.month()+1));
                                System.debug('Dias mes?: ' +diasMes );
                                if(numDiasCheck < 20){
                                    System.debug('Entrou nesse if aqui em baixo');
                                    datavenc = Date.newInstance(datavenc.year(), (dataVenc.month()+1), diasMes);
                                }else{
                                    System.debug('Entrou nesse else aqui em baixo');
                                    datavenc = Date.newInstance(datavenc.year(), (dataVenc.month()), diasMes);
                                }
                                Integer diasEntreVigenciaFinalUltimaParcela = dataVenc.daysBetween(vigenciaFinal);
                                if(numeroParcela == 12 && diasEntreVigenciaFinalUltimaParcela < 15) {
                                    Integer diasIncluidosDataVencimento = 15 - diasEntreVigenciaFinalUltimaParcela;
                                    dataVenc = Date.newInstance(dataVenc.year(), dataVenc.month(), diasMes - diasIncluidosDataVencimento);
                                }
                            }
                            else { //PLV-5773 FIM
                                System.debug('Data venc do else If 836: ' +dataVenc );
                                System.debug('NumDiasCheck da 836: ' + numDiasCheck);
                               //Integer diasEntreParcelas = dataVenc.day() - vencDemaisParcelas;
                                //Integer numeroDiasMes = diasEntreParcelas < 20 ?
                                Integer numeroDiasMes = numDiasCheck < 20 ?
                                Date.daysInMonth(dataVenc.addMonths(1).year(), dataVenc.addMonths(1).month()) :
                                Date.daysInMonth(dataVenc.year(), dataVenc.month()); //ATENCAO
                                vencDemaisParcelas = vencDemaisParcelas > numeroDiasMes ? numeroDiasMes : vencDemaisParcelas;
                               //dataVenc = diasEntreParcelas < 20 ? 
                                dataVenc = numDiasCheck < 20 ? 
                                Date.newInstance(dataVenc.year(), (dataVenc.month()+1), vencDemaisParcelas) :
                                Date.newInstance(dataVenc.year(), dataVenc.month(), vencDemaisParcelas);
                                //INICIO - PLV-4696 - Guilherme Brito
                                //Date vigenciaFinal = contrato.VigenciaFinal__c; //PLV-5773 INICIO/FIM
                                //Integer diasEntreVigenciaFinalUltimaParcela = dataVenc.daysBetween(vigenciaFinal);
                                //if(numeroParcela == 12 && diasEntreVigenciaFinalUltimaParcela < 15) {
                                //    System.debug('Danilo 1');
                                //    Integer diasIncluidosDataVencimento = 15 - diasEntreVigenciaFinalUltimaParcela;
                                //    dataVenc = Date.newInstance(dataVenc.year(), dataVenc.month(), vencDemaisParcelas - diasIncluidosDataVencimento);
                                //}
                                //FIM - PLV-4696 - Guilherme Brito
                            }
                        }else{
                            dataVenc = contratanteContrato.VencimentoPrimeiraParcela__c.addMonths(numeroParcela-1); //PLV-4603-Fix - Inicio/Fim - Isabela Fin - Globant
                        }
                        if(contrato.Segmento__c != 'viagem'){
                            Integer diasEntreVigenciaFinalUltimaParcela = dataVenc.daysBetween(vigenciaFinal);
                            if(numeroParcela == 12 && diasEntreVigenciaFinalUltimaParcela < 15) {
                                System.debug('Danilo 1');
                                Integer diasIncluidosDataVencimento = 15 - diasEntreVigenciaFinalUltimaParcela;
                                if(contratanteContrato.VencimentoDemaisParcelas__c != 'A cada 30 dias'){
                                    dataVenc = Date.newInstance(dataVenc.year(), dataVenc.month(), vencDemaisParcelas - diasIncluidosDataVencimento);
                                }else{
                                    dataVenc = dataVenc.addDays(-15);
                                }                                
                            }
                        }
                        //PLV-5832 FIM
                    }
                    
                    Date novaDataCobertura = (dataVenc).addDays(Integer.valueof(periodoMaximoInadimplenciaProd));//PLV-5768 - INICIO/FIM
                    parcelaContratoTO.datacobertura = String.valueOf(novaDataCobertura); 

                    //PLV-5470 FIM
                    //PLV-4438-Fix2 - Fim
                    //PLV-4438-Fix3 - Fim
                    // PLV-4816-COMPLEMENTO INICIO
                    if(contrato.Segmento__c == 'Massificados' && numeroParcela == 1){
                        dataVenc = contrato.StartDate;
                    }else if(contrato.Segmento__c == 'Massificados'){
                        dataVenc = contrato.StartDate.addMonths(numeroParcela-1);
                    }
                    // PLV-4816-COMPLEMENTO FIM

                    vencimentoParcelaAnterior = dataVenc;
                    parcelaContratoTO.datavencimento = String.valueOf(dataVenc);
                    System.debug('Danilo Contrato Debug');
                //}

            } catch (Exception e) {
                System.debug('ERRO:' + e.getLineNumber() + ': ' + e.getMessage());
                throw new ContractException(e.getLineNumber() + ': ' + e);
            }
            System.debug('JSON PARCELAS: ' + JSON.serialize(parcelaContratoTO));

            parcelasContrato.add(parcelaContratoTO);
            numeroParcela++;
            gerarParcelaContratoTO(mapParams, numeroParcela, vencimentoParcelaAnterior, parcelasContrato,periodoMaximoInadimplenciaProd);// PLV-5768 - INICIO/FIM
        }
        // PLV-4344-Fix - Fim
        // PLV-4438 - Fim
        // PLV-2312-28 FIM
        //PLV-4603 - Fim - Isabela Fin - Globant
        
        
        public String gerarNumeroPropostaCapitalizacao(ContratoTO.SolicitarTituloTO solicitarTituloTO) {
            
            return JSON.serialize(herokuServ.gerarNumeroPropostaCapitalizacao(solicitarTituloTO));
            
        }
        
        private String MontarFiltroAdicional(List < Contract > contratoInseridos) {
            String filtro = '';
            
            for (Contract contrato: contratoInseridos) {
                filtro += (filtro == '' ? ' AND Id IN (' : ',') + '\'' + contrato.Id + '\'';
            }
            
            filtro += ')';
            
            return filtro;
        }
        
        // PLV-2312-28 INICIO Remocao de metodo nao utilizado
        // PLV-2312-28 FIM Remocao de metodo nao utilizado
        
        
        public decimal calcularValor(Integer quantidade, Integer incluiResidual, decimal valor) {
            System.debug('CHegou aqui: quantidade' + quantidade + ' valor:' + valor + ' incluiResidual:' + incluiResidual);
            if (valor == null)
                valor = 0;
            decimal vParcela = Math.floor(100.0 * (valor / quantidade)) / 100.0;
            system.debug('PARCELA VALOR: ' + vParcela);
            decimal vResidual = valor - (vParcela * quantidade);
            system.debug('PARCELA RESIDUAL VALOR: ' + vResidual);
            
            if (vResidual != 0) {
                if (incluiResidual == 1)
                    vParcela = vParcela + vResidual;
            }
            
            return vParcela;
        }
        
        public void processarRecompraTitulos(List < GarantiaContrato__c > listGarantiaContrato) {
            
            // Declara variaveis
            Map < String, List < GarantiaContrato__c >> mapGarantiasContratoPorCodigoPromocao = new Map < String, List < GarantiaContrato__c >> ();
            Map < String, TituloCapitalizacaoTO > mapTituloCapitalizacaoPorCodigoPromocao = new Map < String, TituloCapitalizacaoTO > ();
            
            // Agrupa as Garantia da Capitalização no MAP por CódigoPromocao
            for (GarantiaContrato__c garantiaContrato: listGarantiaContrato) {
                List < GarantiaContrato__c > listGarantiaContratoTemp = mapGarantiasContratoPorCodigoPromocao.get(garantiaContrato.GarantiaProduto__r.CodigoPromocao__c);
                if (listGarantiaContratoTemp == null) listGarantiaContratoTemp = new List < GarantiaContrato__c > ();
                listGarantiaContratoTemp.add(garantiaContrato);
                mapGarantiasContratoPorCodigoPromocao.put(garantiaContrato.GarantiaProduto__r.CodigoPromocao__c, listGarantiaContratoTemp);
            }
            
            // Busca o nome da empresa e o CNPJ no Metadado de Constantes
            String nomeEmpresa;
            String cnpjEmpresa;
            for (Constante__mdt constante: MetadataDAO.getInstance().buscarConstantes(new Set < String > {
                NOME,
                    CNPJ
                    })) {
                        if (constante.Atributo__c == NOME) nomeEmpresa = constante.Valor__c;
                        if (constante.Atributo__c == CNPJ) cnpjEmpresa = constante.Valor__c;
                    }
            
            if (nomeEmpresa == null || cnpjEmpresa == null) throw new ContractException('Metadado de constante da empresa não cadastrado');
            
            // Criacao dos titulos de capitalizacao com todos os contratos que estiverem nessa situação por CODIGO DE PROMOCAO
            for (String codigoPromocao: mapGarantiasContratoPorCodigoPromocao.keySet()) {
                List < GarantiaContrato__c > listGarantiaContrato2 = mapGarantiasContratoPorCodigoPromocao.get(codigoPromocao);
                TituloCapitalizacaoTO tituloCapitalizacaoTO = gerarTituloCapitalizacaoTO(codigoPromocao, nomeEmpresa, cnpjEmpresa, listGarantiaContrato2);
                mapTituloCapitalizacaoPorCodigoPromocao.put(codigoPromocao, tituloCapitalizacaoTO);
            }
            
            // Envia os titulos para o PortoCAP por CODIGO DE PROMOCAO
            List < GarantiaContrato__c > listGarantiaContratoParaAtualizar = new List < GarantiaContrato__c > ();
            for (String codigoPromocao: mapTituloCapitalizacaoPorCodigoPromocao.keySet()) {
                
                TituloCapitalizacaoTO tituloCapitalizacaoTO2 = mapTituloCapitalizacaoPorCodigoPromocao.get(codigoPromocao);
                List < GarantiaContrato__c > listGarantiaContratoParaAtualizarTemp = mapGarantiasContratoPorCodigoPromocao.get(codigoPromocao);
                List < TituloCapitalizacaoTO > listTituloCapitalizacaoTO = new List < TituloCapitalizacaoTO > {
                    tituloCapitalizacaoTO2
                        };
                            
                            // Envia os titulos para a PortoCap
                            List < ServiceTO.RetornoPortoCapTO > listRetornoPortoCap;
                String codigoVersao = '';
                
                if (!Test.isRunningTest()) {
                    listRetornoPortoCap = PortoCapService.getInstance().solicitarRecompraTitulos(listTituloCapitalizacaoTO);
                    
                    // Verifica se o titulo foi rejeitado
                    if (listRetornoPortoCap[0].cd_retorno == 0) {
                        codigoVersao = String.valueOf(listRetornoPortoCap[0].cd_versao);
                    } else {
                        continue;
                    }
                } else {
                    //Utilizado na classe de teste
                    codigoVersao = '2';
                }
                
                for (GarantiaContrato__c garantiaContrato: listGarantiaContratoParaAtualizarTemp) {
                    garantiaContrato.VersaoTitulo__c = codigoVersao;
                    garantiaContrato.StatusCapitalizacao__c = 'AguardandoRecompra';
                    garantiaContrato.DataSolicitacaoCapitalizacao__c = System.today();
                    listGarantiaContratoParaAtualizar.add(garantiaContrato);
                }
            }
            
            if (listGarantiaContratoParaAtualizar.size() > 0) {
                // Atualizo a lista de garantias do contrato
                Database.SaveResult[] srList = Database.update(listGarantiaContratoParaAtualizar, false);
                for (Database.SaveResult sr: srList) {
                    if (sr.isSuccess()) {
                        System.debug('Atualizou a garantia do contrato com sucesso. GarantiaContrato__c.Id: ' + sr.getId());
                    } else {
                        for (Database.Error err: sr.getErrors()) {
                            System.debug('Os seguinte erros ocorreram.');
                            System.debug(err.getStatusCode() + ': ' + err.getMessage());
                            System.debug('Campos da Garantia do contrato afetados com esse erro: ' + err.getFields());
                        }
                    }
                }
            }
        }
        
        public TituloCapitalizacaoTO gerarTituloCapitalizacaoTO(String codigoPromocao, String nomeEmpresa, String cnpj, List < GarantiaContrato__c > listGarantiaContrato) {
            TituloCapitalizacaoTO tituloCapitalizacaoTO = new TituloCapitalizacaoTO();
            
            try {
                tituloCapitalizacaoTO.Nm_empresa = nomeEmpresa;
                tituloCapitalizacaoTO.Nr_cnpj = cnpj;
                tituloCapitalizacaoTO.Cd_promocao = codigoPromocao;
                
                // Criar a lista de cessionario
                List < TituloCapitalizacaoTO.CessionarioTO > listCessionarioTO = new List < TituloCapitalizacaoTO.CessionarioTO > ();
                
                for (GarantiaContrato__c garantiaContrato: listGarantiaContrato) {
                    //Envia para portocap apenas titulos com a data de sortei vencida
                    if (garantiaContrato.DataSorteio__c < System.today()) {
                        TituloCapitalizacaoTO.CessionarioTO cessionarioTO = new TituloCapitalizacaoTO.CessionarioTO();
                        cessionarioTO.Cd_cessionario = garantiaContrato.Contrato__r.Proposta__r.Origem__c + garantiaContrato.Contrato__r.Proposta__r.Name;
                        cessionarioTO.vr_titulo = garantiaContrato.GarantiaProduto__r.ValorTitulo__c;
                        cessionarioTO.nr_sorte = Integer.valueOf(garantiaContrato.NumeroSorte__c);
                        
                        if (garantiaContrato.LoteCapitalizacao__c != null) {
                            cessionarioTO.nr_lote = Integer.valueOf(garantiaContrato.LoteCapitalizacao__c);
                        }
                        
                        listCessionarioTO.add(cessionarioTO);
                    }
                }
                
                tituloCapitalizacaoTO.Cessionario = listCessionarioTO;
            } catch (Exception e) {
                System.debug('ERRO:' + e.getLineNumber() + ': ' + e.getMessage());
                throw new ContractException(e.getLineNumber() + ': ' + e);
                
            }
            return tituloCapitalizacaoTO;
        }
        
        public Contract buscarPorNumeroApolice(String numeroApolice) {
            try {
                return dao.buscarPorNumeroApolice(new Set < String > {
                    numeroApolice
                        }).get(0);
            } catch (Exception ex) {
                throw new ContractException('Apólice não encontrada');
            }
        }
        
        public List < ContratanteContrato__c > buscarContratantesPorNumeroApolice(String numeroApolice) {
        return dao.buscarContratantesPorNumeroApolice(new Set<String> {numeroApolice});
        }
        
        public List < GrupoContrato__c > buscarGruposPorNumeroApolice(String numeroApolice) {
        return dao.buscarGruposPorNumeroApolice(new Set<String> {numeroApolice});
        }
        
        
    // PLV-4438 - Inicio - Adicao de parametro lstHorariosComerciais
    // PLV-4344-Fix - Inicio - Adicao de parametro mapAntecipaComissaoContrato
    // PLV-2605-29 INICIO
    public List<ServiceTO.SeguroContratoTO> gerarDadosSeguro(Set<Id> setContractId, List<Contract> listContrato, Map<Id, Boolean> mapAntecipaComissaoContrato, List<BusinessHours> lstHorariosComerciais){
        List<ServiceTO.SeguroContratoTO> seguros = gerarParametros(setContractId, listContrato, mapAntecipaComissaoContrato, lstHorariosComerciais);
        return seguros;
    }
    // PLV-2605-29 FIM
    // PLV-4344-Fix - Fim
    // PLV-4438 - Fim

    // PLV-4438 - Inicio - Adicao de parametro lstHorariosComerciais
    // PLV-2605-29 INICIO
    private List<ServiceTO.SeguroContratoTO> gerarParametros(Set<Id> setContrato, List<Contract> contratos,  Map<Id, Boolean> mapAntecipaComissaoContrato, List<BusinessHours> lstHorariosComerciais) //PLV-4344-Fix - Inicio/Fim
    {
    // PLV-4438 - Fim
            System.debug('Danilo entrou na gerarParametros');
            ContractDAO dao = ContractDAO.getInstance();
            //PLV-2225-28 INICIO

            Map < Id, List < SeguradoContrato__c >> mapSeguradoContratoPorContractId = new Map < Id, List < SeguradoContrato__c >> ();
            // Busca os segurados do contrato e popula mapa
            for (SeguradoContrato__c seguradoContrato: dao.buscarSeguradoContratoPorContractId(setContrato)) {
                if (!mapSeguradoContratoPorContractId.containsKey(seguradoContrato.GrupoContrato__r.ContratanteContrato__r.Contrato__c)) {
                    mapSeguradoContratoPorContractId.put(seguradoContrato.GrupoContrato__r.ContratanteContrato__r.Contrato__c, new List < SeguradoContrato__c > ());
                }
                mapSeguradoContratoPorContractId.get(seguradoContrato.GrupoContrato__r.ContratanteContrato__r.Contrato__c).add(seguradoContrato);
            }
            //PLV-2225-28 FIM
            List < ServiceTO.SeguroContratoTO > seguros = new List < ServiceTO.SeguroContratoTO > ();
            Set < String > setCodigoParceiro = new Set < String > ();
            Set < Id > setProdutos = new Set < Id > ();
            Map < String, ProdutoParceiro__c > mapProdutoParceiroPorChaveParceiroEProduto = new Map < String, ProdutoParceiro__c > ();
            
            //-- busca produtos/parceiros
        for(Contract contrato : contratos)
        {
        if(contrato.Parceiro__c != null)
        {
                    setCodigoParceiro.add(contrato.Parceiro__c);
                    setProdutos.add(contrato.Produto__c);
                }
            }
            
            // Busca o codigo do produto do parceiro
            for (ProdutoParceiro__c produtoParceiro: dao.buscarProdutoDoParceiro(setCodigoParceiro, setProdutos)) {
                mapProdutoParceiroPorChaveParceiroEProduto.put(produtoParceiro.Parceiro__r.Codigo__c + '_' + produtoParceiro.Produto__c, produtoParceiro);
            }
            
            // Lê contratos para geração do Json
        //PLV-4101 - INCIO
        Integer contadorContrato = 0;
        //PLV-4101 - FIM
        for(Contract contrato : contratos)
        {
        ServiceTO.SeguroContratoTO seguro = new ServiceTO.SeguroContratoTO();
        //PLV-2225-28 INICIO
        List<SeguradoContrato__c> listSeguradoContrato = mapSeguradoContratoPorContractId.get(contrato.Id);
        //PLV-2225-28 FIM

        // Carrega Json para altualização do arquivo no Heroku
        seguro.idsalesforce        = contrato.Id;
        seguro.empresa             = contrato.Empresa__c;
        // PLV-4660 INICIO
        if(contrato.Tipo__c == 'Cancelamento' || contrato.Tipo__c == 'Endosso'){//POR062-72 INICIO - FIM
            seguro.sucursal            = contrato.Proposta__r.Contract.Sucursal__c;
        }else{
            seguro.sucursal            = contrato.Sucursal__c;
        }
        // PLV-4660 FIM
        seguro.ramo                = contrato.CodigoRamo__c;
        seguro.apolice             = contrato.NumeroApolice__c;
        seguro.endosso             = contrato.Endosso__c;
        seguro.statuscontrato      = 'Emitido';//contrato.Status;
        seguro.vigenciainicial     = Contrato.StartDate;
        seguro.vigenciafinal       = contrato.VigenciaFinal__c;
        seguro.canal               = contrato.CanalDistribuicao__r.Sigla__c;
        seguro.suseplider          = contrato.CodigoCorretor__r.Name;           //  Corretor Principal - Código derivado do SUSEP
        seguro.tipoendosso         = contrato.TipoEndosso__c;
        seguro.tiposeguro          = contrato.Tipo__c;
        // PLV-4488 
        seguro.siglaTipoEndosso    = contrato.siglaTipoEndosso__c;
        //PLV-2576 Ajustanto o campo NumeroProposta__c
        seguro.numeropropostaporto = contrato.NumeroProposta__c;
        //PLV-2576 Ajustanto o campo NumeroProposta__c
        seguro.numerocontratoparceiro = contrato.IdContratoParceiro__c;
        seguro.nome                = contrato.Account.Name;
        seguro.cpf                 = contrato.Account.IdExterno__c;
        // PLV-4222
        seguro.produto             = contrato.Produto__r.ProductCode;
        //PLV-2576 Adicionando o campo origemproposta
        seguro.origemproposta = contrato.Origem__c;
        //PLV-2576 Adicionando o campo origemproposta
        //PLV-2591 Inicio Adicionando a data atual
        seguro.dataemissao         = System.today();
        //PLV-2591 Inicio Adicionando a data atual
        seguro.codigoparceiro      = contrato.Parceiro__c;
        seguro.payload             = contrato.Payload__c;
        //PLV-2225-28 INICIO
        seguro.quantidadevidas     = (listSeguradoContrato != null)? listSeguradoContrato.size() : null;
        //PLV-2225-28 FIM        

        //--- busca o código do produto do parceiro
        ProdutoParceiro__c produtoParceiro = mapProdutoParceiroPorChaveParceiroEProduto.get(contrato.Parceiro__c + '_' + contrato.Produto__c);
        if(produtoParceiro == null || String.isBlank(produtoParceiro.CodigoProdutoParceiro__c))
        {
            System.debug('Produto do parceiro não encontrado.');
            system.debug('Teste Doug Perfil >>'+contrato.Parceiro__c + '_' + contrato.Produto__c);
            system.debug('Teste Doug Perfil >>'+mapProdutoParceiroPorChaveParceiroEProduto);  
        }
        else
        {
            seguro.produto = produtoParceiro.CodigoProdutoParceiro__c;
            System.debug('==> Produto do parceiro: ' + produtoParceiro.CodigoProdutoParceiro__c);
        }

        //PLV-2619 - Início - Registros errados na tabela seguro para Cancelamento por Inadimplência
        //Alterado em 03/09/2019

        /*if(contrato.Tipo__c == 'Novo' || contrato.Tipo__c == 'Endosso')
                seguro.situacaoapolice    = 'ATIVO';
        else if(contrato.Tipo__c == 'Cancelamento')
                seguro.situacaoapolice    = 'CANCELADA';*/
            
        if(contrato.Tipo__c == 'Novo' || contrato.Tipo__c == 'Endosso'){
            seguro.situacaoapolice = 'ATIVO';
        }
        else if(contrato.Tipo__c == 'Cancelamento'){
            seguro.situacaoapolice = 'CANCELADA';
            seguro.datacancelamento = System.today();
            seguro.valorrestituicao = BotaoCancelarContratoController.gerarPremioRecuperaCOR(contrato.Proposta__r.Contract.Id,System.today(),false);  //PLV-4601-FIX3 - INICIO/FIM
        }
        //PLV-2619 - Fim - Registros errados na tabela seguro para Cancelamento por Inadimplência

        for(ContratanteContrato__c contratante : contrato.ContratantesContrato__r)
        {
            seguro.quantidadeparcelas = (Integer)contratante.QuantidadeParcelas__c;
            break;
        }

        //PLV-5094 - INICIO
        System.debug('checkCancelamentoRecuperaAGE HENRIQUE 1: ' + checkCancelamentoRecuperaAGE(contrato));
        if(seguro.quantidadeparcelas == 0 && checkCancelamentoRecuperaAGE(contrato)) { //PLV-5766-INICIO/FIM
            seguro.quantidadeparcelas = 1;
        }
        //PLV-5094 - FIM

        //Encontra numero da sorte
        for(GarantiaContrato__c garantia : contrato.GarantiasContrato__r){
            if(garantia.Garantia__r.Sigla__c == 'CAP'){

            if(String.isNotBlank(garantia.NumeroSorte__c)){
                seguro.titulocapitalizacao = Integer.valueOf(garantia.NumeroSorte__c);
            }

            break;
            }
        }

        //PLV-5066 - INICIO - YURI
        Boolean endossoCAD = false;
        if(contrato.Tipo__c == 'Endosso' && seguro.siglaTipoEndosso != null){
            endossoCAD = true;
            for(String sigla : seguro.siglaTipoEndosso.split(';')){
                if(sigla != 'BEN' && sigla != 'CAD') endossoCAD = false;
            }
      
         //PLV-5166 - FIM
            
        }
        //PLV-5066 - FIM - YURI

        //AV-85 - INICIO
        // if(seguro.produto.toLowerCase() == 'viagem-prata' && contrato.Tipo__c.toLowerCase() == 'novo'){
        //     endossoCAD = false;
        // }
        //AV-85 - FIM

        //PLV-4101 - INICIO
        List<Contract> listaContatoT = new List<contract>();
        listaContatoT.add(contratos[contadorContrato]);
        //PLV-4344-Fix - Inicio
        //PLV-5066 - INICIO - YURI
        if(!endossoCAD) {
            seguro.parcelas = gerarParcelasContrato(listaContatoT, lstHorariosComerciais, mapAntecipaComissaoContrato); //PLV-4438 - Inicio/Fim
            System.debug('Danilo  !endossoCAD seguro.parcelas>>>>>>>>>> ' + seguro.parcelas);
        } else {
            seguro.parcelas = new List<ParcelaContratoTO>();
        }
        //PLV-5066 - FIM - YURI
        //PLV-4344-Fix - Fim
        //seguro.parcelas = gerarParcelasContrato(contratos);
        seguros.add(seguro);
        contadorContrato++;
        //PLV-4101 - FIM
        // PLV-4720 INICIO - FIX 3
        // PLV-4720 FIM - FIX 3
        }
        
        return seguros;
    }

    //PLV-5094 - INICIO
    //Método p/ checar se cancelamento é sem restituição e se haverá recuperação de agenciamento
	public static Boolean checkCancelamentoRecuperaAGE(Contract contrato){
		System.debug('checkRecuperaAGE > contrato.Tipo__c > ' +  contrato.Tipo__c);
		System.debug('checkRecuperaAGE > contrato.Proposta__r.PremioTotal__c > ' +  contrato.Proposta__r.PremioTotal__c);
        System.debug('checkRecuperaAGE > restit > ' +  restit);

		if(contrato.Tipo__c == 'Cancelamento' && contrato.Proposta__r.PremioTotal__c == 0 && restit != null) {//PLV-5766-INICIO/FIM
			System.debug('Entrou no if');
            System.debug('restiti valor 1261 ' + restit);
            System.debug('contrato.RemuneracoesContrato__r> ' + contrato.RemuneracoesContrato__r);
            for(RemuneracaoContrato__c remuneracao : contrato.RemuneracoesContrato__r){
				System.debug('checkRecuperaAGE > remuneracao > ' +  remuneracao.TipoRemuneracao__r.Name + ' ' + remuneracao.Percentual__c);
				if(remuneracao.TipoRemuneracao__r.Name == 'AGENCIAMENTO' && remuneracao.Percentual__c > 0 ){ 
					return true;
				}
			}
		}
		return false;
 	}
	//PLV-5094 - FIM

    // PLV-4720 INICIO 
    // PLV-4720 INICIO - FIX 3
    // PLV-4720 INICIO - FIX 4
    @future(callout=true)
    //public static void gerarComposicaoParcela(String listContractJson, String parcelasContratoJson, List<String> listParcelasSeguros){ //PLV-5710 INICIO/FIM
    public static void gerarComposicaoParcela(String listContractJson, List<String> listParcelasSeguros){ //PLV-5710 INICIO/FIM
        // PLV-4720 INICIO - FIX 12 - PEDRO AUGUSTO BRAZ
        //System.debug('gerarComposicaoParcela |listParcelasSeguros :>> '+ JSON.serialize(listParcelasSeguros));
        //System.debug('gerarComposicaoParcela |listParcelasSeguros :>> '+ listParcelasSeguros);
        System.debug('gerarComposicaoParcela |listContractJson :>> '+listContractJson);
        //System.debug('gerarComposicaoParcela |parcelasContratoJson :>> '+parcelasContratoJson);
        // PLV-4720 FIM - FIX 12 - PEDRO AUGUSTO BRAZ
        //PLV-4921 - INICIO - PEDRO AUGUSTO BRAZ
        try{
            System.debug('gerarComposicaoParcela |listParcelasSeguros :>> '+ listParcelasSeguros);
            List<Contract> listContract = (List<Contract>)JSON.deserialize(listContractJson, List<Contract>.class);
            //List<ParcelaContratoTO> parcelasContrato = (List<ParcelaContratoTO>) JSON.deserialize(parcelasContratoJson, List<ParcelaContratoTO>.class); 
            List<ParcelaContratoTO> parcelasContrato = new List<ParcelaContratoTO>(); //PLV-5710 INICIO/FIM

                // PLV-4720 FIM - FIX 3
                System.debug('CARLOS - GERAR COMPOSICAO PARCELA');
                // PLV-4720 INICIO - FIX 8 - PEDRO AUGUSTO BRAZ
                List<ComposicaoParcelaTO> listComposicaoParcela = new List<ComposicaoParcelaTO>();
                Map<Integer,List<ComposicaoParcelaTO>> mapParcelaComposicaoParcela = new Map<Integer,List<ComposicaoParcelaTO>>();
                Map<Id,Map<Integer,List<ComposicaoParcelaTO>>> mapContratanteParcelaComposicaoParcela = new Map<Id,Map<Integer,List<ComposicaoParcelaTO>>>(); //PLV-5710 INICIO/FIM
                // PLV-4720 FIM - FIX 8
                List<GarantiaContratanteContrato__c> listGarantiaContratanteContrato = [SELECT Id, GarantiaProduto__r.RamoSeguro__r.Codigo__c, ContratanteContrato__c, ContratanteContrato__r.Contrato__c, PremioTotal__c, PremioComercial__c FROM GarantiaContratanteContrato__c WHERE ContratanteContrato__r.Contrato__c IN: listContract];
                Set<Id> contratoPercorrido = new Set<Id>(); //PLV-5710 INICIO/FIM
                Map<String, List<String>> mapContractlistRamos = new Map<String, List<String>>();
                Map<String, List<ParcelaContratoTO>> mapContractlistParcelaTO = new Map<String, List<ParcelaContratoTO>>();
                Map<String, List<GarantiaContratanteContrato__c>> mapContratanteGarantia = new Map<String, List<GarantiaContratanteContrato__c>>();
                Map<Id, Set<String>> mapContratanteRamos = new Map<Id, Set<String>>();
                Map<String, List<Id>> mapContratoContratanteId = new Map<String, List<Id>>();
                Map<String, Decimal> mapRamoPremioComercial = new Map<String, Decimal>();
                Map<Id, String> mapContratanteRamoPremioComercial = new Map<Id, String>(); //PLV-5710 INICIO/FIM
                Map<String, Decimal> mapRamoPremioTotal = new Map<String, Decimal>();
                Map<Id, String> mapContratanteRamoPremioTotal = new Map<Id,  String>(); //PLV-5710 INICIO/FIM
                
                //PLV-5710 INICIO 
                for(String jsonParcelas : listParcelasSeguros){
                    parcelasContrato = (List<ParcelaContratoTO>) JSON.deserialize(jsonParcelas, List<ParcelaContratoTO>.class); 
                    System.debug('Danilo jsonParcelas' + jsonParcelas);
                    for(ParcelaContratoTO parcela : parcelasContrato){
                        System.debug('Danilo Validacao FOR ' + mapContractlistParcelaTO.get(parcela.idexterno.split('_')[0]));
                        List<ParcelaContratoTO> listParcela = mapContractlistParcelaTO.get(parcela.idexterno.split('_')[0]) != null ? mapContractlistParcelaTO.get(parcela.idexterno.split('_')[0]) : new List<ParcelaContratoTO>();
                        system.debug('listParcela> ' + JSON.Serialize(listParcela));
                        system.debug('parcela> ' + JSON.Serialize(parcela));
                        listParcela.add(parcela);
                        mapContractlistParcelaTO.put(parcela.idexterno.split('_')[0], listParcela);
                    }
                    System.debug('Danilo mapContractlistParcelaTO>>>>>> ' + mapContractlistParcelaTO);
                }
                
                //PLV-5710 FIM
                System.debug('Danilo listGarantiaContratanteContrato ' + listGarantiaContratanteContrato);
                Set<Id> Contratante = new Set<Id>(); //PLV-5710 INICIO/FIM
                for(GarantiaContratanteContrato__c garantia : listGarantiaContratanteContrato){
                    System.debug('Contratante Danilo>>>> ' + Contratante);
                    Set<String> listRamos = mapContratanteRamos.get(garantia.ContratanteContrato__c) != null ? mapContratanteRamos.get(garantia.ContratanteContrato__c) : new Set<String>();
                    listRamos.add(garantia.GarantiaProduto__r.RamoSeguro__r.Codigo__c);
                    System.debug('listRamos Danilo ' + JSON.serialize(listRamos));
                    mapContratanteRamos.put(garantia.ContratanteContrato__c, listRamos);
                    System.debug('mapContratanteRamos Danilo ' + JSON.serialize(mapContratanteRamos));

                    List<Id> listContratante = mapContratoContratanteId.get(garantia.ContratanteContrato__c) != null ? mapContratoContratanteId.get(garantia.ContratanteContrato__c) : new List<Id>();
                    listContratante.add(garantia.ContratanteContrato__c);
                    mapContratoContratanteId.put(garantia.ContratanteContrato__r.Contrato__c, listContratante);

                    //PLV-5710 INICIO
                    if(Contratante.contains(garantia.ContratanteContrato__c)){
                        System.Debug('Entrou No If');
                        Decimal comercial = mapRamoPremioComercial.get(garantia.GarantiaProduto__r.RamoSeguro__r.Codigo__c) != null ? mapRamoPremioComercial.get(garantia.GarantiaProduto__r.RamoSeguro__r.Codigo__c) : 0;
                        Decimal total = mapRamoPremioTotal.get(garantia.GarantiaProduto__r.RamoSeguro__r.Codigo__c) != null ? mapRamoPremioTotal.get(garantia.GarantiaProduto__r.RamoSeguro__r.Codigo__c) : 0;
                    
                        comercial = garantia!=null && garantia.PremioComercial__c!=null ? comercial + garantia.PremioComercial__c : comercial;//PLV-4720 INICIO - FIX 11
                        total = garantia!=null && garantia.PremioTotal__c!=null ? total + garantia.PremioTotal__c : total;//PLV-4720 INICIO - FIX 11
                        
                        mapRamoPremioComercial.put(garantia.GarantiaProduto__r.RamoSeguro__r.Codigo__c, comercial);
                        mapRamoPremioTotal.put(garantia.GarantiaProduto__r.RamoSeguro__r.Codigo__c, total);

                        System.debug('mapRamoPremioComercial Danilo: ' + JSON.serialize(mapRamoPremioComercial));
                        System.debug('mapRamoPremioTotal Danilo: ' + JSON.serialize(mapRamoPremioTotal));
                    }else{
                        System.Debug('Else: ');
                        mapRamoPremioComercial.clear();
                        mapRamoPremioTotal.clear();
                        contratante.clear();
                        contratante.add(garantia.ContratanteContrato__c);
                        
                        Decimal comercial = mapRamoPremioComercial.get(garantia.GarantiaProduto__r.RamoSeguro__r.Codigo__c) != null ? mapRamoPremioComercial.get(garantia.GarantiaProduto__r.RamoSeguro__r.Codigo__c) : 0;
                        Decimal total = mapRamoPremioTotal.get(garantia.GarantiaProduto__r.RamoSeguro__r.Codigo__c) != null ? mapRamoPremioTotal.get(garantia.GarantiaProduto__r.RamoSeguro__r.Codigo__c) : 0;
                    
                        comercial = garantia!=null && garantia.PremioComercial__c!=null ? comercial + garantia.PremioComercial__c : comercial;//PLV-4720 INICIO - FIX 11
                        total = garantia!=null && garantia.PremioTotal__c!=null ? total + garantia.PremioTotal__c : total;//PLV-4720 INICIO - FIX 11

                        mapRamoPremioComercial.put(garantia.GarantiaProduto__r.RamoSeguro__r.Codigo__c, comercial);
                        mapRamoPremioTotal.put(garantia.GarantiaProduto__r.RamoSeguro__r.Codigo__c, total);

                        // System.debug('mapRamoPremioComercial Danilo: ' + JSON.serialize(mapRamoPremioComercial));
                        // System.debug('mapRamoPremioTotal Danilo: ' + JSON.serialize(mapRamoPremioTotal));
                    }
                    
                    mapContratanteRamoPremioTotal.put(garantia.ContratanteContrato__c, String.valueof(JSON.serialize(mapRamoPremioTotal)));
                    mapContratanteRamoPremioComercial.put(garantia.ContratanteContrato__c, String.valueof(JSON.serialize(mapRamoPremioComercial)));

                    System.debug('Danilo mapContratanteRamoPremioComercial ' + JSON.serialize(mapContratanteRamoPremioComercial));
                    System.debug('Danilo mapContratanteRamoPremioTotal ' + JSON.serialize(mapContratanteRamoPremioTotal));
                    //PLV-5710 FIM
                }

                Map<Decimal, Decimal> mapRamoParcela = new Map<Decimal, Decimal>();
                Map<Decimal, Decimal> mapRamoLiquido = new Map<Decimal, Decimal>();
                Map<Decimal, Decimal> mapRamoIOF = new Map<Decimal, Decimal>();
                //PLV-5710 INICIO
                Map<Id, Map<Decimal, Decimal>> ContratoMapRamoParcela = new Map<Id, Map<Decimal, Decimal>>();
                Map<Id, Map<Decimal, Decimal>> ContratoMapRamoLiquido = new Map<Id, Map<Decimal, Decimal>>();
                Map<Id, Map<Decimal, Decimal>> ContratoMapRamoIOF = new Map<Id, Map<Decimal, Decimal>>();
                //PLV-5710 FIM

                for(Contract contrato : listContract){
                    System.debug('Contrato: ' + contrato.Name + ' ' + contrato.Id);
                    for(String contratanteContratoId : mapContratoContratanteId.get(contrato.Id)){
                        System.debug('ContratanteContratoId ' + contratanteContratoId);
                        for(String ramo : mapContratanteRamos.get(contratanteContratoId)){
                            System.debug('Ramo: ' + ramo);
                            System.debug('PARCELAS DO RAMO');
                            System.debug('-------');
                            Decimal totalParcela = 0;
                            Decimal totalLiquido = 0;
                            Decimal totalIOF = 0;
                            System.debug('mapContractlistParcelaTO> ' + mapContractlistParcelaTO);
                            for(ParcelaContratoTO parcela : mapContractlistParcelaTO.get(contrato.Id)){
                                System.debug('-------');
                                System.debug('Parcela  Object' + parcela);
                                System.debug('Parcela ' + parcela.numeroparcela);
                                ComposicaoParcelaTO composicaoParcela = new ComposicaoParcelaTO();
                                composicaoParcela = (ComposicaoParcelaTO) JSON.deserialize(JSON.serialize(parcela), ComposicaoParcelaTO.class);
                                composicaoParcela.ramo = ramo;  
                                composicaoParcela.ramoLider = parcela.ramo;
                                composicaoParcela.statusIntegracao = 'PENDENTE'; //PLV-4674 - INICIO/FIM
                                // PLV-4720- FIX3 INICIO  
                                composicaoParcela.apolice = contrato.NumeroApolice__c; // PLV-4720 FIX 2
                                composicaoParcela.modalidade = String.valueOf(Integer.valueOf(contrato.CodigoModalidade__c));
                                
                                mapRamoPremioTotal = (Map<String, Decimal>)JSON.deserialize(mapContratanteRamoPremioTotal.get(contratanteContratoId),  Map<String, Decimal>.class); //PLV-5710 INICIO/FIM

                                System.debug('composicaoParcela mapRamoPremioTotal>>>> ' + mapRamoPremioTotal);
                                System.debug('composicaoParcela ramo>>>> ' + ramo);
                                System.debug('composicaoParcela.valorparcela>>>> ' + composicaoParcela.valorparcela);
                                System.debug('mapRamoPremioTotal.get(ramo)>>> ' + mapRamoPremioTotal.get(ramo));
                                System.debug('mapContractlistParcelaTO.get(contrato.Id).size()>>>>> '+ mapContractlistParcelaTO.get(contrato.Id).size());

                                composicaoParcela.valorparcela = (mapRamoPremioTotal.get(ramo) / mapContractlistParcelaTO.get(contrato.Id).size()).setScale(2, RoundingMode.HALF_EVEN);// PLV-4720 INICIO - FIX 12 - PEDRO AUGUSTO BRAZ

                                mapRamoPremioComercial = (Map<String, Decimal>)JSON.deserialize(mapContratanteRamoPremioComercial.get(contratanteContratoId),  Map<String, Decimal>.class); //PLV-5710 INICIO/FIM

                                composicaoParcela.valorliquido = (mapRamoPremioComercial.get(ramo) / mapContractlistParcelaTO.get(contrato.Id).size()).setScale(2, RoundingMode.HALF_EVEN);// PLV-4720 INICIO - FIX 12 - PEDRO AUGUSTO BRAZ
                                
                                composicaoParcela.valoriof = composicaoParcela.valorparcela.setScale(2, RoundingMode.HALF_EVEN) - composicaoParcela.valorliquido.setScale(2, RoundingMode.HALF_EVEN);// PLV-4720 INICIO - FIX 12 - PEDRO AUGUSTO BRAZ
                                
                                //PLV-5710 INICIO
                                
                                if(contratoPercorrido.contains(contrato.Id)){
                                    System.debug('ENTROU NO IF CONTRATO PERCORRIDO');
                                    
                                    totalParcela = mapRamoParcela.get(composicaoParcela.numeroparcela) == null ? composicaoParcela.valorparcela : mapRamoParcela.get(composicaoParcela.numeroparcela) + composicaoParcela.valorparcela;
                                    totalLiquido = mapRamoLiquido.get(composicaoParcela.numeroparcela) == null ? composicaoParcela.valorliquido : mapRamoLiquido.get(composicaoParcela.numeroparcela) + composicaoParcela.valorliquido;
                                    totalIOF = totalParcela!=null && totalLiquido!=null ? totalParcela - totalLiquido: 0;
                                    mapRamoParcela.put(composicaoParcela.numeroparcela, totalParcela);
                                    mapRamoLiquido.put(composicaoParcela.numeroparcela, totalliquido);
                                    mapRamoIOF.put(composicaoParcela.numeroparcela, totalIOF);
    
                                    System.debug('Composicao Parcela ' + composicaoParcela);
                                    System.debug('Map Parcela ' + mapRamoParcela);

                                    if(!mapParcelaComposicaoParcela.containsKey(parcela.numeroparcela)) mapParcelaComposicaoParcela.put(parcela.numeroparcela,new List<ComposicaoParcelaTO>());
                                    mapParcelaComposicaoParcela.get(parcela.numeroparcela).add(composicaoParcela);
                                }else{
                                    System.debug('ENTROU NO ELSE CONTRATO PERCORRIDO');
                                    mapRamoParcela.clear();
                                    mapRamoLiquido.clear();
                                    mapRamoIOF.clear();
                                    mapParcelaComposicaoParcela.clear();
                                    contratoPercorrido.clear();
                                    contratoPercorrido.add(contrato.Id);

                                    totalParcela = mapRamoParcela.get(composicaoParcela.numeroparcela) == null ? composicaoParcela.valorparcela : mapRamoParcela.get(composicaoParcela.numeroparcela) + composicaoParcela.valorparcela;
                                    totalLiquido = mapRamoLiquido.get(composicaoParcela.numeroparcela) == null ? composicaoParcela.valorliquido : mapRamoLiquido.get(composicaoParcela.numeroparcela) + composicaoParcela.valorliquido;
                                    totalIOF = totalParcela!=null && totalLiquido!=null ? totalParcela - totalLiquido: 0;
                                    mapRamoParcela.put(composicaoParcela.numeroparcela, totalParcela);
                                    mapRamoLiquido.put(composicaoParcela.numeroparcela, totalliquido);
                                    mapRamoIOF.put(composicaoParcela.numeroparcela, totalIOF);
    
                                    System.debug('Composicao Parcela ' + composicaoParcela);
                                    System.debug('Map Parcela ' + mapRamoParcela);

                                    if(!mapParcelaComposicaoParcela.containsKey(parcela.numeroparcela)) mapParcelaComposicaoParcela.put(parcela.numeroparcela,new List<ComposicaoParcelaTO>());
                                    mapParcelaComposicaoParcela.get(parcela.numeroparcela).add(composicaoParcela);
                                }
                                mapContratanteParcelaComposicaoParcela.put(contrato.Id, mapParcelaComposicaoParcela);
                                ContratoMapRamoParcela.put(contrato.Id, mapRamoParcela);
                                ContratoMapRamoLiquido.put(contrato.Id, mapRamoLiquido); 
                                ContratoMapRamoIOF.put(contrato.Id, mapRamoIOF);
                                System.debug('Danilo mapContratanteParcelaComposicaoParcela '+ JSON.serialize(mapContratanteParcelaComposicaoParcela));
                                System.debug('Danilo ContratoMapRamoParcela '+ JSON.serialize(ContratoMapRamoParcela));
                                System.debug('Danilo ContratoMapRamoLiquido '+ JSON.serialize(ContratoMapRamoLiquido));
                                //PLV-5710 FIM
                                // PLV-4720 FIM - FIX 8 - PEDRO AUGUSTO BRAZ
                            }
                        }
                    }
                    // PLV-4720 INICIO - FIX 8 - PEDRO AUGUSTO BRAZ
                    Decimal totalRamo = 0;
                    Decimal totalParcela = 0;
                    String ramoLider = '';
                    Boolean ajustarValores = false;
                    Decimal diffParcela = 0;
                    Decimal diffTotal = 0;
                    
                    for(ParcelaContratoTO parcela : mapContractlistParcelaTO.get(contrato.Id)){
                        ramoLider = parcela.ramo;
                        
                        //PLV-5710 INICIO
                        mapRamoParcela = ContratoMapRamoParcela.get(contrato.Id);
                        mapRamoLiquido = ContratoMapRamoLiquido.get(contrato.Id);
                        //PLV-5710 FIM

                        System.debug('ramoLider: ' + ramoLider);
                        System.debug('MapRamoParcela.get(parcela.numeroparcela): ' + mapRamoParcela.get(parcela.numeroparcela));
                        System.debug('mapRamoLiquido.get(parcela.numeroparcela): ' + mapRamoLiquido.get(parcela.numeroparcela));
                        // PLV-4720-FIX-14 AJUSTE NO IF
                        
                        if((parcela.valorparcela!=null && mapRamoParcela.get(parcela.numeroparcela)!=null)  && ((parcela.valorparcela != mapRamoParcela.get(parcela.numeroparcela) || parcela.valorliquido != mapRamoLiquido.get(parcela.numeroparcela)))){//PLV-4720 INICIO - FIX 11
                            diffParcela = parcela.valorparcela - mapRamoParcela.get(parcela.numeroparcela);
                            diffTotal = parcela.valorliquido - mapRamoLiquido.get(parcela.numeroparcela);//PLV-4720 INICIO - FIX 9
                        }

                        //PLV-5710 INICIO
                        System.debug('mapContratanteParcelaComposicaoParcela ANTES de dar get ' + JSON.serialize(mapContratanteParcelaComposicaoParcela));
                        mapParcelaComposicaoParcela = mapContratanteParcelaComposicaoParcela.get(contrato.Id);
                        System.debug('mapParcelaComposicaoParcela DEPOIS de dar get ' + JSON.serialize(mapParcelaComposicaoParcela));
                        //PLV-5710 FIM

                        // PLV-4720 INICIO - FIX 7
                        System.debug('PEDRO |ORIGEM : '+parcela.numeroparcela+' : ' + JSON.serialize(mapParcelaComposicaoParcela.get(parcela.numeroparcela)));
                        //PLV-4921 - INICIO - PEDRO AUGUSTO BRAZ

                        //PLV-5094-FIX - INICIO
                        if(contrato.Tipo__c == 'Cancelamento' && contrato.Proposta__r.PremioTotal__c == 0){
                            if(mapParcelaComposicaoParcela.containsKey(parcela.numeroparcela)){ 
                                for(ComposicaoParcelaTO composicaoparcela : mapParcelaComposicaoParcela.get(parcela.numeroparcela)){
                                    composicaoparcela.valorparcela = 0;
                                    composicaoparcela.valorliquido = 0;
                                    composicaoparcela.valoriof = 0;
                                    composicaoparcela.status = 'A RESTITUIR';
                                    listComposicaoParcela.add(composicaoParcela); 
                                }
                            }
                        }else if(diffParcela != 0 || diffTotal != 0){ //PLV-5094-FIX - FIM
                            if(mapParcelaComposicaoParcela.containsKey(parcela.numeroparcela)){ 
                                for(ComposicaoParcelaTO composicaoparcela : mapParcelaComposicaoParcela.get(parcela.numeroparcela)){
                                    //PLV-4973-INICIO
                                    if(composicaoparcela.ramo == ramoLider && parcela.numeroparcela == composicaoparcela.numeroparcela){
                                        System.debug('@@@@@'); 
                                        System.debug('Ramo: ' + composicaoparcela.ramo); 
                                        System.debug('NPARCELA: ' + composicaoparcela.numeroparcela); 
                                        System.debug('----'); 
                                        System.debug('Antes parcela valorparcela: ' + composicaoparcela.valorparcela); 
                                        System.debug('Antes parcela valorliquido: ' + composicaoparcela.valorliquido); 
                                        System.debug('Antes parcela valoriof: ' + composicaoparcela.valoriof); 
                                        System.debug('Antes parcela status: ' + composicaoparcela.status); 
                                        composicaoparcela.valorparcela = (composicaoparcela.valorparcela + diffParcela).setScale(2, RoundingMode.HALF_EVEN);// PLV-4720 INICIO - FIX 12 - PEDRO AUGUSTO BRAZ 
                                        composicaoparcela.valorliquido = (composicaoparcela.valorliquido + diffTotal).setScale(2, RoundingMode.HALF_EVEN);// PLV-4720 INICIO - FIX 13 - PEDRO AUGUSTO BRAZ 
                                        composicaoparcela.valoriof = (composicaoparcela.valorparcela - composicaoparcela.valorliquido).setScale(2, RoundingMode.HALF_EVEN);// PLV-4720 INICIO - FIX 13 - PEDRO AUGUSTO BRAZ 
                                        System.debug('DEPOIS parcela valorparcela: ' + composicaoparcela.valorparcela); 
                                        System.debug('DEPOIS parcela valorliquido: ' + composicaoparcela.valorliquido); 
                                        System.debug('DEPOIS parcela valoriof: ' + composicaoparcela.valoriof); 
                                        System.debug('DEPOIS parcela status: ' + composicaoparcela.status); 
                                        diffParcela = 0;
                                        diffTotal = 0;
                                    }
                                    composicaoparcela.status = composicaoparcela.valorparcela < 0 ? 'A RESTITUIR' : 'PENDENTE';
                                    //PLV-4973-FIM
                                    listComposicaoParcela.add(composicaoParcela); 
                                } 
                            }
                        }else{ 
                            //PLV-4720 INICIO - FIX 12 - PEDRO AUGUSTO BRAZ
                            System.debug('@@@@@ NÃO TEM DIFERENÇA PARCELA OU TOTAL'); 
                            for(ComposicaoParcelaTO composicaoparcela : mapParcelaComposicaoParcela.get(parcela.numeroparcela)){
                                    System.debug('Antes parcela valorparcela: ' + composicaoparcela.valorparcela); 
                                    System.debug('Antes parcela valorliquido: ' + composicaoparcela.valorliquido); 
                                    System.debug('Antes parcela valoriof: ' + composicaoparcela.valoriof); 
                                    System.debug('Antes parcela status: ' + composicaoparcela.status); 
                                    composicaoparcela.valorparcela = (composicaoparcela.valorparcela).setScale(2, RoundingMode.HALF_EVEN); 
                                    composicaoparcela.valorliquido = (composicaoparcela.valorliquido).setScale(2, RoundingMode.HALF_EVEN);//PLV-4720 INICIO - FIX 10 
                                    composicaoparcela.valoriof = (composicaoparcela.valorparcela - composicaoparcela.valorliquido).setScale(2, RoundingMode.HALF_EVEN);//PLV-4720 INICIO - FIX 10 
                                    composicaoparcela.status = composicaoparcela.valorparcela < 0 ? 'A RESTITUIR' : 'PENDENTE'; //PLV-4601 - INICIO/FIM
                                    System.debug('DEPOIS parcela valorparcela: ' + composicaoparcela.valorparcela); 
                                    System.debug('DEPOIS parcela valorliquido: ' + composicaoparcela.valorliquido); 
                                    System.debug('DEPOIS parcela valoriof: ' + composicaoparcela.valoriof); 
                                    System.debug('DEPOIS parcela status: ' + composicaoparcela.status); 
                            } 
                            //PLV-4720 FIM - FIX 12 - PEDRO AUGUSTO BRAZ 
                            listComposicaoParcela.addAll(mapParcelaComposicaoParcela.get(parcela.numeroparcela)); 
                        } 
                        //PLV-4921 - FIM - PEDRO AUGUSTO BRAZ
                            
                            
                        System.debug('diffParcela');
                        System.debug(diffParcela);
                        System.debug('diffTotal');
                        System.debug(diffTotal);
                        System.debug('PEDRO | : '+parcela.numeroparcela+' : ' + JSON.serialize(mapParcelaComposicaoParcela.get(parcela.numeroparcela)));      
                    }

                    // PLV-4720 FIM - FIX 8 - PEDRO AUGUSTO BRAZ
                    // PLV-4720 FIM - FIX 7
                }
                if(listComposicaoParcela != null && listComposicaoParcela.size() > 0){// PLV-4720 FIX - 20/01// PLV-4720 INICIO - FIX 12 - PEDRO AUGUSTO BRAZ
                    System.debug('gerarComposicaoParcela :: SAIDA : '+ JSON.serialize(listComposicaoParcela));
                    // PLV-4720 FIM - FIX 12 - PEDRO AUGUSTO BRAZ
                    HerokuService.getInstance().gerarComposicaoParcelas(listComposicaoParcela);// PLV-4720 INICIO/FIM - FIX 8 - PEDRO AUGUSTO BRAZ
                }// PLV-4720 FIX - 20/01
            //} //PLV-4893 - INÍCIO/FIM
        }catch(Exception ex){
            System.debug('gerarComposicaoParcela :: Exception : ' + ex.getMessage() + ', ' + ex.getStackTraceString());//PLV-4720 INICIO - FIX 11
            throw new ContractException('gerarComposicaoParcela :: Exception : ' + ex.getMessage() + ', ' + ex.getStackTraceString() + ', parametros : ' + ' list contract ' + listContractJson + ', PARCELAS ' + listParcelasSeguros );//PLV-4720 INICIO - FIX 11 // ANALISE-COMPOSICAO-PARCELA
        }
        //PLV-4921 - FIM - PEDRO AUGUSTO BRAZ
    }
    // PLV-4720 FIM
    // PLV-2605-29 FIM
    // PLV-4720 FIM - FIX 4

    // Gera o campo name do contrato
    public String gerarNameContrato(String codigoEmpresa, String codigoSucursal, String codigoRamo, Integer numeroApolice, String endosso){
        return gerarNameContrato(codigoEmpresa, codigoSucursal, codigoRamo, String.valueOf(numeroApolice), endosso);
    }

    // PLV-2508 INICIO
    // Gera o campo name do contrato
    public String gerarNameContrato(String codigoEmpresa, String codigoSucursal, String codigoRamo, String numeroApolice, String endosso){
        return codigoEmpresa.trim() + '-' +
                codigoSucursal.trim() + '-' +
                codigoRamo.trim() + '-' +
                numeroApolice.trim().leftPad(9,'0') + '-' +
                endosso.trim();
    }
    // PLV-2508 FIM

    // PLV-2508 INICIO
    // PLV-2312-28 INICIO
    // Gera o campo name do contrato para utilizacao em mapa
    public String gerarChaveMapaContrato(String codigoEmpresa, String codigoSucursal, String codigoRamo, String numeroApolice){
        return codigoEmpresa.trim() + '-' +
                codigoSucursal.trim() + '-' +
                codigoRamo.trim() + '-' +
                numeroApolice.trim().leftPad(9,'0');
    }
    // PLV-2312-28 FIM
    // PLV-2508 FIM


    //PLV-2334-27 INICIO
    // PLV-2312-28 INICIO
    // Para processo de cancelamento, busca endosso anterior e soma 1
    public RetornoDadosEndossoTO buscarUltimoEndossoApolice(String empresa,
            String sucursal,
            String ramo, //PLV-3460 Fix 5 - INICIO/FIM  
            String numeroApolice)
    {
        RetornoDadosEndossoTO retorno = new RetornoDadosEndossoTO();
        Contract contratoRetorno;

        // retorna o último endosso registrado
        Integer endosso = 0;

        // busca contratos anteriores para cancelamento
        List<Contract> lstContratos = ContractDAO.getInstance().buscarContratosAnteriores(new Set<String>{empresa + '-' + sucursal + '-' + ramo + '-' + numeroApolice + '-%'}); //PLV-3460 Fix 5 - INICIO/FIM
        System.debug('lstContratos2 ' + lstContratos);

        //List<Contract> lstContratosExistentes = ContractDAO.getInstance().buscarContratosAnteriores(new Set<String>{empresa + '-' + sucursal + '-' + ramo + '-' + numeroApolice + '-%'}); //PLV-3460 Fix 5 - INICIO/FIM

        // altera status para cancelado e atualiza contratos
        for(Contract contrato : lstContratos)
        {
        if(!String.isBlank(contrato.Endosso__c) && Integer.valueOf(contrato.Endosso__c) > endosso)
            endosso = Integer.valueOf(contrato.Endosso__c);
        contratoRetorno = contrato;
        System.debug('endosso1: ' + endosso);
        System.debug('contratoRetorno: ' + contratoRetorno);
        }

        //---- soma 1 para a criação do novo endosso
        if(lstContratos.size() == 0) endosso++; //PLV - 4362 inicio/fim
        System.debug('endosso2: ' + endosso);
        retorno.numeroEndosso = endosso;
        retorno.objContrato = contratoRetorno;


        return retorno;
    }
    //PLV-2334-27 FINAL
    // PLV-2312-28 FIM


        // PLV-2312-28 INICIO Remocao de metodo nao utilizado
        // PLV-2312-28 FIM Remocao de metodo nao utilizado

    // PLV-2312-28 INICIO REMOCAO DE METODOS NAO UTILIZADOS
    // PLV-2312-28 FIM REMOCAO DE METODOS NAO UTILIZADOS


    //--Inicio-PLV1197-27: Cancelamento de contrato
    //MGRC-1657 - INICIO
    public RetornoAcaoBotaoTO cancelarContratoSelecionado(Id idContrato, String tipoEndosso)
    {
        RetornoAcaoBotaoTO retorno = new RetornoAcaoBotaoTO();

        ServiceTO.ParamOrcamentoCalculoTO param = new ServiceTO.ParamOrcamentoCalculoTO();
        ServiceTO.OrcamentoCalculoTO orcamento = new ServiceTO.OrcamentoCalculoTO();

        Contract contrato = dao.buscarContratoById(idContrato);
        System.debug('************** contrato.status ' + contrato.Status);
        if(contrato.Status == 'Cancelado')
        {
        retorno.tipo = RetornoAcaoBotaoTO.ERROR;
        retorno.mensagens.add('Contrato já cancelado');
        }
        else
        {

        orcamento.empresa         = contrato.Empresa__c;
        orcamento.sucursal        = contrato.Sucursal__c;
        orcamento.ramo            = contrato.RamoSeguro__r.Codigo__c;
        orcamento.apolice         = contrato.NumeroApolice__c;
        orcamento.tipoSeguro      = 'CAN';
        orcamento.tipoEndosso     = tipoEndosso;
        orcamento.dataCalculo     = contrato.Proposta__r.DataCalculo__c;
        orcamento.vigenciaInicial = contrato.StartDate;
        orcamento.meioComercializacao = contrato.MeioComercializacao__c;

        param.orcamento = orcamento;
        System.debug('param> ' + JSON.serialize(param));
        try {

            //--- chama CIV Oferta
            System.debug('***************** entrou no try');
            ServiceTO.DataCancelamentoTO retornoCalculo = CIVServices.getInstance().calculoOrcamentoOferta(param); //MGRC-1657 - INICIO/FIM

            System.debug('===> Retorno: ' + JSON.serialize(retornoCalculo));

            ServiceTO.ParamPropostaCalculoTO param2 = new ServiceTO.ParamPropostaCalculoTO();
            ServiceTO.PropostaCalculoTO proposta = new ServiceTO.PropostaCalculoTO();
            
            if(String.isBlank(retornoCalculo.data.ofertas[0].orcamento.numeroOrcamento))
            {
            retorno.tipo = RetornoAcaoBotaoTO.ERROR;
            retorno.mensagens.add('Não foi possivel efetuar o cancelamento do Contrato!');
            }
            else
            {
            proposta.numeroOrcamento = retornoCalculo.data.ofertas[0].orcamento.numeroOrcamento;
            param2.proposta = proposta;

            // PLV-2430-29 INICIO
            //--- chama CIV Transmissao
            RetornoPropostaRestTO.ValidacaopropostaTO retornoEmissao = CIVServices.getInstance().calculoPropostaTransmissao(param2);

                // PLV-2312-28 INICIO
                if(!Test.isRunningTest()) {
                    if (retornoEmissao.devolutivas.isEmpty() || retornoEmissao.devolutivas[0].codigo != 0) {
                        retorno.tipo = RetornoAcaoBotaoTO.ERROR;
                        retorno.mensagens.add('Não foi possivel efetuar o cancelamento do Contrato!');
                        return retorno;
                    }
                }
                // PLV-2312-28 FIM
            // PLV-2430-29 FIM

            retorno.tipo = RetornoAcaoBotaoTO.SUCCESS;
            retorno.mensagens.add('Contrato cancelado com sucesso!');
            }
        }
        catch (Exception e)
        {
            retorno.tipo = RetornoAcaoBotaoTO.ERROR;
            retorno.mensagens.add('Não foi possivel efetuar o cancelamento do Contrato!');

            System.debug('ERRO:' + e.getLineNumber() + ': ' + e.getMessage());
            throw new ContractException(e.getLineNumber() + ': ' + e);
        }
        }

        return retorno;

    }
    //MGRC-1657 - FIM
    //--Fim-PLV1197-27: Cancelamento de contrato

    // PLV-2366 - INICIO
    public void atualizarPayloadSeguro(List<Contract> listStage){
        system.debug('quantidade de registros Stage: ' + listStage.size());

        for(Contract item : listStage){
        ServiceTO.SeguroContratoTO atualizarPayloadSeguro = new ServiceTO.SeguroContratoTO();
        atualizarPayloadSeguro.idsalesforce = item.id;
        atualizarPayloadSeguro.payload = item.Payload__c;

        herokuServ.atualizarPayloadSeguro(atualizarPayloadSeguro);
        }
    }
    // PLV-2366 - FIM

    // public List<GarantiaGrupoContrato__c> buscarGarantiasContratantesPorNumeroApolice(String numeroApolice){
    //   return dao.buscarGarantiasVidasPorNumeroApolice(new Set<String> {numeroApolice});
    // }

    // PLV-2312-28 INICIO REMOCAO DE METODOS NAO UTILIZADOS
    // PLV-2312-28 FIM REMOCAO DE METODOS NAO UTILIZADOS

    // PLV-2312-28 INICIO
    //PLV-2334-27 INICIO
    public class RetornoDadosEndossoTO
    {
        public Integer numeroEndosso;
        public Contract objContrato;
    }
    //PLV-2334-27 FINAL
    // PLV-2312-28 FIM
        //PLV-3133 INICIO
        public void criarApolice(List<Contract> plContract) {
            
            Set<Id> sContratoId = new Set<Id>();
            
            for (Contract con : plContract) {
                System.debug('con henrique: ' +con );
                // Parceria__c == null pois massificado não deve gerar Apolice
                //PLV-3872 - INICIO - Inibir geracao de documentos em caso de cancelamento unitario
                //PLV-4568 - INICIO - Inibir geracao de documentos de endosso
                //con.Parceria__c == null &&
                if (con.CodigoRamo__c != '1377' &&  con.Tipo__c != 'Cancelamento' && con.Tipo__c != 'Endosso') { //PLV-3460 - INICIO/FIM // VIAG-139 - INICIO/FIM
                //PLV-4568 - FIM
                    sContratoId.add(con.Id);
                }
                //PLV-3872 - FIM
            }
            
            if (sContratoId.isEmpty()) return;
            
            // PLV-3404 - INICIO - Chamada apenas quando a thread não é a assincrona
        /* if (!System.isFuture() && !System.isBatch() && !System.isQueueable()) { 
                criarApoliceAsync(sContratoId);
            }*/
            if(!Test.isRunningTest()){
               criarApoliceAsync(sContratoId);
      
            }else{
                criarApoliceSync(sContratoId);
            }
            // PLV-3404 - FIM
        }
        
        @future(callout=true)
        public static void criarApoliceAsync(Set<Id> psContratoId) {
            
            criarApoliceSync(psContratoId);
        }
        
        public static void criarApoliceSync(Set<Id> psContratoId) {
            system.debug('contrato'+psContratoId);
            Map<Id,ContentVersion> mContentVersion = new Map<Id,ContentVersion>();
            
            //PLV-3601 - INICIO
            Map<Id,Contract> mapContract = new Map<Id,Contract>();
            //PLV-4566 - INICIO
            List<Contract> listContract = [SELECT Id, Name, Empresa__c, Sucursal__c, CodigoRamo__c, NumeroApolice__c, Endosso__c, Produto__c, Produto__r.Segmento__c 
                                        FROM Contract WHERE id IN:(psContratoId)];

            System.debug('XXX - listContract : ' + JSON.serialize(listContract));
            //PLV-4566 - FIM
            for(Contract pcontract : listContract){
                mapContract.put(pcontract.Id,pcontract);
            }        
            //PLV-3601 - FIM
            for (Id contratoId : psContratoId) {
                //PLV-4566 - INICIO
                PageReference pdf = null;
                String title = null;
                if(mapContract.get(contratoId).Produto__c != null && mapContract.get(contratoId).Produto__r.Segmento__c == 'Individual'){
                    System.debug('XXX - ApoliceVidaIndividual ');
                    pdf = Page.ApoliceVidaIndividual;
                    pdf.getParameters().put('nomeContract', mapContract.get(contratoId).Name);
                    title = 'Apolice_Individual_';
                }
                else {
                    System.debug('XXX - ApolicePage ');
                    pdf = Page.ApolicePage;
                    //PageReference pdf = Page.Apolice_teste;
                    Map<String,String> mPDFParam = pdf.getParameters();
                    mPDFParam.put('contratoId', contratoId);
                    mPDFParam.put('renderAs', 'pdf');
                    title = 'Apolice_';
                }
                //PLV-4566 - FIM
                //PLV-3601 - INICIO
                string nomeApolice;
                nomeApolice = mapContract.get(contratoId).Empresa__c+'_'+mapContract.get(contratoId).Sucursal__c+'_'+mapContract.get(contratoId).CodigoRamo__c+'_'+mapContract.get(contratoId).NumeroApolice__c+'_'+mapContract.get(contratoId).Endosso__c;
                ContentVersion file = new ContentVersion(
                    //PLV-4566 - INICIO
                    Title = title+nomeApolice,
                    //PLV-4566 - FIM
                    VersionData = Test.IsRunningTest() ? Blob.valueOf('TEST') : pdf.getContentAsPDF(),
                    PathOnClient ='/apolice.pdf',
                    origin = 'H'
                );
                //PLV-3601 - FIM
                mContentVersion.put(contratoId, file);
            }
            system.debug('mContentVersion HENRIQUE : '+mContentVersion);
            if (mContentVersion.isEmpty()) return;
            
            insert mContentVersion.values();
            //PLV-3601 - INCIO
            Map<Id, ContentVersion> mContentVersionInserted = new Map<Id, ContentVersion>(
                [SELECT Id, ContentDocumentId, Title FROM ContentVersion WHERE Id IN :mContentVersion.values()]
            );
            //PLV-3601 - FIM
            List<ContentDocumentLink> lContentDocumentLink = new List<ContentDocumentLink>();
            //PLV3601 - INICIO
            List<ControleIntegracao__c>lControleIntegracao = new list<ControleIntegracao__c>();
            //PLV3601 - FIM
            
            for (Id contratoId : psContratoId) {
                
                ContentDocumentLink fileLink = new ContentDocumentLink(
                    LinkedEntityId = contratoId,
                    ContentDocumentId = mContentVersionInserted.get(mContentVersion.get(contratoId).Id).ContentDocumentId,
                    ShareType = 'V'
                );
                
                lContentDocumentLink.add(fileLink);
                //PLV-3601 - INICIO
                ControleIntegracao__c controleIntegracao = new ControleIntegracao__c(
                    IdObjeto__c = contratoId+'_'+mContentVersionInserted.get(mContentVersion.get(contratoId).Id).Id,
                    Status__c = 'Pendente',
                    DataCriacaoRegistro__c = Date.today(),
                    CodigoIntegracao__c = '85',
                    // PLV - 4599 - INICIO - HENRIQUE R. META
                    Objeto__c = 'Contract',
                    // PLV - 4599 - FIM - HENRIQUE R. META
                    //PLV - 4599 FIX - INICIO - HENRIQUE R. META
                    Pasta_ECM__c = 'Enterprise:Corporativo:Vida:Contrato:Apolice'
                    //PLV - 4599 FIX - FIM - HENRIQUE R. META
                    
                );
                lControleIntegracao.add(controleIntegracao);
                //PLV-3601 - FIM
            }
            
            insert lContentDocumentLink;
            
            //PLV-3601 - INICIO
            insert lControleIntegracao;
            //PLV-3601 - FIM
            
            //3404 - Inicio
            //PLV-3601 - INICIO MELHORIA NESTE PROCESSO
            List<ContentVersion> lContentVersion = mContentVersionInserted.values();
            //List<ContentVersion> lContentVersion = [SELECT Id,Title, ContentDocumentId FROM ContentVersion WHERE Id IN :mContentVersion.values()];
            //PLV-3601 - FIM
            // List<Contract> c = [SELECT Id, ApolicePdfDownloadUrl__C, Proposta__r.Account.PersonEmail from contract where id IN: psContratoId];  // PLV-4289
            List<Contract> c = [SELECT Id, ApolicePdfDownloadUrl__c, Proposta__r.Account.PersonEmail from contract where id IN: psContratoId];  // PLV-5236
            List<Contract> c2update = new List<Contract>();
            List<ContentDistribution> lContentDistribution2Insert = new List<ContentDistribution>();
            system.debug('contentversion: '+lcontentversion);
            system.Debug('contract: '+c);
            
            
            for(ContentVersion cvv: lContentVersion){	
                ContentDistribution cd = new ContentDistribution (
                    Name = cvv.Title,
                    ContentVersionId = cvv.id,
                    PreferencesPasswordRequired = true  // MGRC-505 INICIO/FIM
                );
                lContentDistribution2Insert.add(cd);
            
                system.debug('cd: '+cd);
            }
            insert lContentDistribution2Insert;
            
                    
            List <ContentDocumentLink> mContentDocumentLink = new List <ContentDocumentLink>([select LinkedEntityId,ContentDocumentId from ContentDocumentLink where LinkedEntityId in: (psContratoId)]); 
            Map <ID, ID> mContractContent = new Map<ID,ID>();
            List<string> lcontentDocument = new List<string>();
            for(ContentDocumentLink obj : mContentDocumentLink){
            
                mContractContent.put(obj.ContentDocumentId,obj.LinkedEntityId);
                lcontentDocument.add(obj.ContentDocumentId);
            }
            
            Map <ID,ContentDistribution> lContentDistribution = new map<ID,ContentDistribution>([select ContentDocumentId,ContentVersionId, PdfDownloadUrl,Password, DistributionPublicUrl from ContentDistribution where ContentDocumentId in : (lcontentDocument) ]);
            system.debug('map contrato + id documento'+mContractContent);
            system.debug('ID contentDoc'+lcontentDocument);
            system.debug('link para contrato' + lContentDistribution);
            map <ID,String> contractURL = new map <ID,String>();
            map <ID,String> contractSenha = new map <ID,String>();
            map <ID,String> contractDistribution = new map <ID,String>();

            //PLV-3744 - INICIO
            Map<String,String> versionxContract = new Map<String,String>();
            String baseURL = [SELECT Endpoint FROM NamedCredential WHERE DeveloperName = 'SFECM' LIMIT 1].Endpoint;
            baseURL += [SELECT NomeCredencial__c,NomeToken__c,Endpoint__c,DeveloperName FROM Servico__mdt WHERE DeveloperName='Consultar_ArquivoSF' LIMIT 1].Endpoint__c;
            
            for(String key : mContentVersion.keyset()){
                versionxContract.put((String)mContentVersion.get(key).Id,key);
            }
            //PLV-3744 - FIM
            
            for(ID idkey : lContentDistribution.keyset()){
                if(mContractContent.containsKey(lContentDistribution.get(idkey).ContentDocumentId)){
                system.debug('encontrou contrato ID Contrato'+mContractContent.get(lContentDistribution.get(idkey).ContentDocumentId)); 
                //PLV-3744 - INICIO
                //contractURL.put(mContractContent.get(lContentDistribution.get(idkey).ContentDocumentId),lContentDistribution.get(idkey).PdfDownloadUrl);
                //Ao invés de colocar o link, será gerado o map com contrato e Tokens
                system.debug('mContentVersionInserted> '+ JSON.serialize(mContentVersionInserted));
                System.debug('lContentDistribution>' + JSON.serialize(lContentDistribution));
                system.debug('versionxContract> ' + JSON.serialize(versionxContract));
                String token = Util.encryptDocPublicURL(versionxContract.get(lContentDistribution.get(idkey).ContentVersionId),
                mContentVersionInserted.get(lContentDistribution.get(idkey).ContentVersionId).Title+'.pdf');
                contractURL.put(mContractContent.get(lContentDistribution.get(idkey).ContentDocumentId),token);
                contractSenha.put(mContractContent.get(lContentDistribution.get(idkey).ContentDocumentId),lContentDistribution.get(idkey).Password);
                contractDistribution.put(mContractContent.get(lContentDistribution.get(idkey).ContentDocumentId),lContentDistribution.get(idkey).DistributionPublicUrl);
                //PLV-3744 - FIM
                }
                system.debug('DocumentoID' + lContentDistribution.get(idkey).ContentDocumentId);
            }
            system.debug('URL COM ID DO CONTRATO'+contractURL);
            
            
            for(Contract contr: c){
            if(contractURL.containsKey(contr.Id))
                    system.debug('contrato:' + contr.Id);
                    System.debug('baseURL> ' + JSON.serialize(baseURL) + ' >> ' + JSON.serialize(contractURL));
                    contr.ApolicePdfDownloadUrl__c = baseURL + contractURL.get(contr.Id);
                    System.debug('APOLICEPDFDOWNLOADURL > ' + contr.ApolicePdfDownloadUrl__c);
                    // PLV-4289 - INICIO 
                    contr.Senha__c = contractSenha.get(contr.Id);
                    contr.DistributionPublicUrl__c = contractDistribution.get(contr.Id);
                    if(contr.Proposta__r.Account.PersonEmail != null)
                        contr.email__c = contr.Proposta__r.Account.PersonEmail;
                    c2update.add(contr);
                    // PLV-4289 - FIM
            }
            //PLV-3744 - FIM
            update(c2update);
            system.debug('c2update: '+c2update);
            //FIM
            
            //3404 - FIM
            
        }
        //PLV-3133 FIM
        //PLV-3392 - INICIO
        //PLV-3392-FIX2 - INICIO/FIM - Trecho de código removido
        /*public void atualizarIOF(List<Contract> newLstContract, Map<Id, Contract> oldMapContract){
            List<Contract> contratoIOF = new List<Contract>();
            List<Id> lstContratoId = new List<Id>();
            for(Contract cont : newLstContract){
                if(cont.Status == 'Emitido' && cont.Status != oldMapContract.get(cont.Id).Status && !cont.Massificados__c){ //PLV-3392-FIX - INCIO/FIM - Ajuste da logica para não gerar quando massificado
                    contratoIOF.add(cont);
                    lstContratoId.add(cont.id);
                }
            }
            if(contratoIOF.isEmpty()) return;
            Map<Id, Decimal> mapContratoIOF = new Map<Id, Decimal>();
            for(ContratanteContrato__c contratante : [SELECT Id, Contrato__c, IOF__c FROM ContratanteContrato__c WHERE Contrato__c IN: lstContratoId]){
                mapContratoIOF.put(contratante.Contrato__c, contratante.IOF__c);
            }
            if(mapContratoIOF.isEmpty()) return;

            for(Contract contract : contratoIOF){
                contract.ValorIOF__c = mapContratoIOF.get(contract.Id);
            }
        }*/
        
    //plv - 4014 inicio
    public void criarEndosso(List<Contract> plContract) {
            
            Set<Id> sContratoId = new Set<Id>();
            
            for (Contract con : plContract) {
                // Parceria__c == null pois massificado não deve gerar Apolice
                if (con.Parceria__c == null && (con.Tipo__c == 'Cancelamento' || con.Tipo__c == 'Endosso')) { ////PLV-4568 - INICIO/FIM
                    sContratoId.add(con.Id);
                }
            }
            if (sContratoId.isEmpty()) return;
        
            if(!Test.isRunningTest()){
                criarEndossoAsync(sContratoId);
            }else{
                criarEndossoSync(sContratoId);
            }
        }
        
        @future(callout=true)
        public static void criarEndossoAsync(Set<Id> psContratoId) {
            
            criarEndossoSync(psContratoId);
        }
        
        public static void criarEndossoSync(Set<Id> psContratoId) {
            
            system.debug('contrato'+psContratoId);
            Map<Id,ContentVersion> mContentVersion = new Map<Id,ContentVersion>();
            
            Map<Id,Contract> mapContract = new Map<Id,Contract>();
            //PLV-4568 - INICIO
            List<Contract> listContract = [SELECT Id, Name, Empresa__c, Sucursal__c, CodigoRamo__c, NumeroApolice__c, Endosso__c , Produto__c, Produto__r.Segmento__c, Tipo__c
                                        FROM Contract WHERE id IN:(psContratoId)];
            //PLV-4568 - FIM
            for(Contract pcontract : listContract){
                mapContract.put(pcontract.Id,pcontract);
            }        

            for (Id contratoId : psContratoId) {
                //PLV-4568 - INICIO
                PageReference pdf = null;
                String title = null;
                Contract contrato = mapContract.get(contratoId);
                //PLV-5052 INICIO
                if(contrato.Tipo__c.toUpperCase() == 'CANCELAMENTO'){
                    pdf = Page.EndossoPage;
                    pdf.getParameters().put('contratoId', contrato.id);
                    
                    if(contrato.Produto__r.Segmento__c != null) //POR062-72 - INICIO - FIM
                        title = 'Cancelamento_' + contrato.Produto__r.Segmento__c.replace(' ', '_') + '_'; //PLV-5133 - FIX01 - INICIO/FIM
                }
                else if(contrato.Produto__c != null && contrato.Produto__r.Segmento__c == 'Individual'){
                    pdf = Page.ApoliceVidaIndividual; //PLV 5032 INICIO FIM
                    pdf.getParameters().put('nomeContract', contrato.Name);
                    title = 'Endosso_Individual_';
                }
                //PLV-5052 FIM
                //PLV - 5007 INICIO
                //PLV-4588 FIX EP- INÍCIO
                 else if(contrato.Produto__c != null && contrato.Produto__r.Segmento__c == 'Viagem'){
                    pdf = Page.ApolicePage; //PLV-5053 INICIO/FIM
                    pdf.getParameters().put('contratoId', contrato.Id);
                    title = 'Endosso_Viagem_';
                }
                //PLV-4588 FIX EP - FIM
                //PLV - 5007 FIM
                if(pdf != null){
                    //POR062-72 - INICIO
                    String sucursalContratoOriginal = '';
                    if(contrato != null){
                        Contract contract = [select Id, Proposta__r.Contract.Sucursal__c from Contract where Id = :contrato.Id];
                        sucursalContratoOriginal = contract.Proposta__r.Contract.Sucursal__c;
                    }
                    string nomeApolice;
                    nomeApolice = title+contrato.Empresa__c+'_'+sucursalContratoOriginal+'_'+contrato.CodigoRamo__c+'_'+contrato.NumeroApolice__c+'_'+contrato.Endosso__c;//POR062-721 - FIM
                    ContentVersion file = new ContentVersion(
                        Title = nomeApolice,
                        VersionData = Test.IsRunningTest() ? Blob.valueOf('TEST') : pdf.getContentAsPDF(),
                        PathOnClient ='/endosso.pdf',
                        origin = 'H'
                    );
                    mContentVersion.put(contratoId, file);
                }
                //PLV-4568 - FIM
            }
            system.debug('mContentVersion'+mContentVersion);
            if (mContentVersion.isEmpty()) return;
            
            insert mContentVersion.values();
            Map<Id, ContentVersion> mContentVersionInserted = new Map<Id, ContentVersion>(
                [SELECT Id, ContentDocumentId, Title FROM ContentVersion WHERE Id IN :mContentVersion.values()]
            );
            List<ContentDocumentLink> lContentDocumentLink = new List<ContentDocumentLink>();
            List<ControleIntegracao__c>lControleIntegracao = new list<ControleIntegracao__c>();
            for (Id contratoId : psContratoId) {
                
                ContentDocumentLink fileLink = new ContentDocumentLink(
                    LinkedEntityId = contratoId,
                    ContentDocumentId = mContentVersionInserted.get(mContentVersion.get(contratoId).Id).ContentDocumentId,
                    ShareType = 'V'
                );
                
                lContentDocumentLink.add(fileLink);
                ControleIntegracao__c controleIntegracao = new ControleIntegracao__c(
                    IdObjeto__c = contratoId+'_'+mContentVersionInserted.get(mContentVersion.get(contratoId).Id).Id,
                    Status__c = 'Pendente',
                    DataCriacaoRegistro__c = Date.today(),
                    CodigoIntegracao__c = '85',
                    // PLV - 4599 - INICIO - HENRIQUE R. META
                    Objeto__c = 'Contract',
                    // PLV - 4599 - FIM - HENRIQUE R. META
                    // PLV - 4599 FIX - INICIO - HENRIQUE R. META
                    Pasta_ECM__c = 'Enterprise:Corporativo:Vida:Contrato:Apolice'
                    // PLV - 4599 FIX - FIM - HENRIQUE R. META
                
                );
                lControleIntegracao.add(controleIntegracao);
            }
            insert lContentDocumentLink;
            
            insert lControleIntegracao;
            List<ContentVersion> lContentVersion = mContentVersionInserted.values();
            List<Contract> c = [SELECT Id, EndossoPdfDownloadUrl__C, Account.PersonEmail from contract where id IN: psContratoId];
            List<Contract> c2update = new List<Contract>();
            List<ContentDistribution> lContentDistribution2Insert = new List<ContentDistribution>();
            system.debug('contentversion: '+lcontentversion);
            system.Debug('contract: '+c);
            
            
            for(ContentVersion cvv: lContentVersion){	
                ContentDistribution cd = new ContentDistribution (
                    Name = cvv.Title,
                    ContentVersionId = cvv.id,
                    PreferencesPasswordRequired = true  // MGRC-505 INICIO/FIM
                );
                lContentDistribution2Insert.add(cd);
            
                system.debug('cd: '+cd);
            }
            insert lContentDistribution2Insert;
            
                    
            List <ContentDocumentLink> mContentDocumentLink = new List <ContentDocumentLink>([select LinkedEntityId,ContentDocumentId from ContentDocumentLink where LinkedEntityId in: (psContratoId)]); 
            Map <ID, ID> mContractContent = new Map<ID,ID>();
            List<string> lcontentDocument = new List<string>();
            for(ContentDocumentLink obj : mContentDocumentLink){
            
                mContractContent.put(obj.ContentDocumentId,obj.LinkedEntityId);
                lcontentDocument.add(obj.ContentDocumentId);
            }
            
            Map <ID,ContentDistribution> lContentDistribution = new map<ID,ContentDistribution>([select ContentDocumentId,ContentVersionId, PdfDownloadUrl,Password, DistributionPublicUrl from ContentDistribution where ContentDocumentId in : (lcontentDocument) ]);
            system.debug('map contrato + id documento'+mContractContent);
            system.debug('ID contentDoc'+lcontentDocument);
            system.debug('link para contrato' + lContentDistribution);
            map <ID,String> contractURL = new map <ID,String>();
            map <ID,String> contractSenha = new map <ID,String>();
            map <ID,String> contractDistribution = new map <ID,String>();
            Map<String,String> versionxContract = new Map<String,String>();
            String baseURL = [SELECT Endpoint FROM NamedCredential WHERE DeveloperName = 'SFECM' LIMIT 1].Endpoint;
            baseURL += [SELECT NomeCredencial__c,NomeToken__c,Endpoint__c,DeveloperName FROM Servico__mdt WHERE DeveloperName='Consultar_ArquivoSF' LIMIT 1].Endpoint__c;
            
            for(String key : mContentVersion.keyset()){
                versionxContract.put((String)mContentVersion.get(key).Id,key);
            }
            
            for(ID idkey : lContentDistribution.keyset()){
            
                if(mContractContent.containsKey(lContentDistribution.get(idkey).ContentDocumentId)){
                    system.debug('encontrou contrato ID Contrato'+mContractContent.get(lContentDistribution.get(idkey).ContentDocumentId)); 

                //Ao invés de colocar o link, será gerado o map com contrato e Tokens
                String token = Util.encryptDocPublicURL(versionxContract.get(lContentDistribution.get(idkey).ContentVersionId),
                                    mContentVersionInserted.get(lContentDistribution.get(idkey).ContentVersionId).Title+'.pdf');

                contractURL.put(mContractContent.get(lContentDistribution.get(idkey).ContentDocumentId),token);
                // MGRC-505-FIX2 INICIO
                contractSenha.put(mContractContent.get(lContentDistribution.get(idkey).ContentDocumentId), lContentDistribution.get(idkey).Password); // MGRC-505 INICIO/FIM 
                contractDistribution.put( mContractContent.get(lContentDistribution.get(idkey).ContentDocumentId), lContentDistribution.get(idkey).DistributionPublicUrl);  // MGRC-505 INICIO/FIM 
                // MGRC-505-FIX2 FIM
                
            }
                system.debug('DocumentoID' + lContentDistribution.get(idkey).ContentDocumentId);
            }
            system.debug('URL COM ID DO CONTRATO'+ JSON.serialize(contractURL));
            
            
            for(Contract contr: c){
                if(contractURL.containsKey(contr.Id))
                    system.debug('contrato dentro:' + contr.Id);
                    
                contr.EndossoPdfDownloadUrl__c = baseURL + contractURL.get(contr.Id);
                contr.Senha__c =  contractSenha.get(contr.Id);  // MGRC-505 INICIO/FIM
                contr.DistributionPublicUrl__c = contractDistribution.get(contr.Id);  // MGRC-505 INICIO/FIM
                if(contr.Account.PersonEmail != null)
                    contr.email__c = contr.Account.PersonEmail;
                c2update.add(contr);
            }
            update(c2update);
            system.debug('c2update: '+c2update);
           
        }
        //plv - 4014 fim

        //PLV-3990 - INICIO - Ajuste na criação de controles de integração
        //PLV-3460 - INICIO
        public void criarControlesIntegracao(List<Contract> newLstContract){
            List<ControleIntegracao__c> lstControleIntegracao = new List<ControleIntegracao__c>();
            for(Contract cont : newLstContract){

                List<String> endossos = cont.SiglaTipoEndosso__c != null ? cont.SiglaTipoEndosso__c.split(';') : new List<String>(); //INÍCIO/FIM - PLV-4610 - GUILHERME BRITO

                //PLV-5170-INICIO
                if((cont.SiglaTipoEndosso__c != 'BEN;CAD' && cont.SiglaTipoEndosso__c != 'BEN' && cont.SiglaTipoEndosso__c != 'CAD') && !cont.Massificados__c) {
                   // if(!cont.Massificados__c){ //PLV-3392-FIX - INCIO/FIM - Ajuste da logica para não gerar quando massificado //PLV-4588 - FIX4 - INICIO/FIM   
                        ControleIntegracao__c controleIntegracao = new ControleIntegracao__c();
                            controleIntegracao.IdObjeto__c = cont.Id;
                            controleIntegracao.CodigoIntegracao__c = '82';
                            controleIntegracao.Status__c = 'Pendente';
                            controleIntegracao.DataCriacaoRegistro__c = System.today();
                            lstControleIntegracao.add(controleIntegracao);
                   // }
                }else if((cont.SiglaTipoEndosso__c == 'BEN;CAD' || cont.SiglaTipoEndosso__c == 'BEN' || cont.SiglaTipoEndosso__c == 'CAD') && cont.Tipo__c == 'Endosso'){                                       
                    ControleIntegracao__c controleIntegracao = new ControleIntegracao__c();                    
                    String[] siglaTipoEndosso = cont.SiglaTipoEndosso__c == null ? new List<String>{'', ''} : cont.SiglaTipoEndosso__c.split(';');                                                                                         
                    String siglaTipoEndossoTratada = cont.SiglaTipoEndosso__c.contains(';') ? siglaTipoEndosso[0] + '|' + siglaTipoEndosso[1] : siglaTipoEndosso[0];                    
                    controleIntegracao.IdObjeto__c = cont.Id + '|' + cont.AccountId + '|' + siglaTipoEndossoTratada;
                    controleIntegracao.CodigoIntegracao__c = '108';
                    controleIntegracao.Status__c = 'Pendente';
                    controleIntegracao.DataCriacaoRegistro__c = System.today();
                    lstControleIntegracao.add(controleIntegracao);                    
                }
                //PLV-5170-FIM
                
                 // PLV-5166-INICIO FIX01
                 if(cont.SiglaTipoEndosso__c != 'BEN;CAD' && cont.SiglaTipoEndosso__c != 'BEN' && cont.SiglaTipoEndosso__c != 'CAD'){
                    System.debug('cont.SiglaTipoEndosso__c->' + cont.SiglaTipoEndosso__c);
                    // PLV-4488-INICIO
                    if(!cont.Massificados__c && cont.Tipo__c == 'Endosso'){ //PLV-4588 - FIX4 - INICIO/FIM
                        ControleIntegracao__c controleIntegracao2 = new ControleIntegracao__c();
                        controleIntegracao2.IdObjeto__c = cont.Id;
                        controleIntegracao2.CodigoIntegracao__c = '87';
                        controleIntegracao2.Status__c = 'Pendente';
                        controleIntegracao2.DataCriacaoRegistro__c = System.today();
                        lstControleIntegracao.add(controleIntegracao2);
                        //INÍCIO - PLV-4610 - GUILHERME BRITO
                        //if((cont.SiglaTipoEndosso__c != null && endossos.size() == 1 && endossos[0] != 'CAD') || (cont.SiglaTipoEndosso__c != null && endossos.size() > 1)) { //INICIO/FIM - FIX - PLV-4610
                            ControleIntegracao__c controleIntegracao3 = new ControleIntegracao__c();
                            controleIntegracao3.IdObjeto__c = cont.Id;
                            controleIntegracao3.CodigoIntegracao__c = '101';
                            controleIntegracao3.Status__c = 'Pendente';
                            controleIntegracao3.DataCriacaoRegistro__c = System.today();
                            lstControleIntegracao.add(controleIntegracao3);
                        //} //INICIO/FIM - FIX - PLV-4610 
                        //FIM - PLV-4610 - GUILHERME BRITO
                    }
                // PLV-4488-FIM
                }
                // PLV-5166-FIM FIX01

                if(!cont.Massificados__c && cont.Tipo__c == 'Cancelamento'){ //PLV-4588 - FIX4 - INICIO/FIM
                    ControleIntegracao__c controleIntegracao1 = new ControleIntegracao__c();
                        controleIntegracao1.IdObjeto__c = cont.Id;
                        controleIntegracao1.CodigoIntegracao__c = '88';
                        controleIntegracao1.Status__c = 'Pendente';
                        controleIntegracao1.DataCriacaoRegistro__c = System.today();
                        lstControleIntegracao.add(controleIntegracao1);

                        ControleIntegracao__c controleIntegracao2 = new ControleIntegracao__c();
                        controleIntegracao2.IdObjeto__c = cont.Id;
                        controleIntegracao2.CodigoIntegracao__c = '87';
                        controleIntegracao2.Status__c = 'Pendente';
                        controleIntegracao2.DataCriacaoRegistro__c = System.today();
                        lstControleIntegracao.add(controleIntegracao2);                    
                }
            }
            insert lstControleIntegracao;
        }
        //PLV-3460 - FIM
        //PLV-3990 - FIM
        //PLV-3392 - FIM

    //PLV-4556 - INÍCIO
    //PLV-5458 - INICIO
    //MGRC-1657 - INICIO
    @future(callout=true)
    public static void cancelarContratoInadimplencia(String Serializedcontracts)
    {
        List<Contract> contracts = (List<Contract>) JSON.deserialize(Serializedcontracts, List<Contract>.class);
        for(Contract contrato : contracts){
            ServiceTO.ParamOrcamentoCalculoTO param = new ServiceTO.ParamOrcamentoCalculoTO();
            ServiceTO.OrcamentoCalculoTO orcamento = new ServiceTO.OrcamentoCalculoTO();
        
            if(contrato.Status != 'Cancelado')
            {
                Date inicioVigencia = validarDataInicialVigencia(contrato.Id, System.today()); //PLV-5708 INICIO/FIM
                System.debug('inicioVigencia Danilo: ' + inicioVigencia);
                Date dataCancel = validarDataCancelamento(contrato.Id, inicioVigencia); //PLV-5708 INICIO/FIM
                System.debug('dataCancel Danilo: ' + dataCancel);
                orcamento.empresa         = contrato.Empresa__c;
                orcamento.sucursal        = contrato.Sucursal__c;
                orcamento.ramo            = contrato.RamoSeguro__r.Codigo__c;
                orcamento.apolice         = contrato.NumeroApolice__c;
                orcamento.tipoSeguro      = 'CAN';
                orcamento.tipoEndosso     = 'INA';
                orcamento.dataCalculo     = inicioVigencia; //PLV-5708 INICIO/FIM
                orcamento.vigenciaInicial = inicioVigencia; //PLV-5708 INICIO/FIM
                orcamento.meioComercializacao = contrato.MeioComercializacao__c;
                orcamento.segmento = contrato.Segmento__c;
			    orcamento.endosso = contrato.Endosso__c; 
                param.orcamento = orcamento;

                try {
                    ServiceTO.DataCancelamentoTO retornoCalculo = CIVServices.getInstance().calculoOrcamentoOferta(param); //MGRC-1657 - INICIO/FIM
                    System.debug('retornorCalculo> ' + JSON.serialize(retornoCalculo));
                    Integer numeroOrcamento = Integer.valueOf(retornoCalculo.data.ofertas[0].orcamento.numeroOrcamento);
                    BotaoCancelarContratoController.gerarPropostaEndosso(numeroOrcamento, contrato.id, dataCancel);
                }
                catch (Exception e)
                {
                    System.debug('ERRO:' + e.getLineNumber() + ': ' + e.getMessage());
                }
            }
        }
    }
    //MGRC-1657 - FIM
    //PLV-5458 - FIM

    public void processarStatusHeroku(List<Contract> newContracts) {
        
        if(System.isBatch() || System.isFuture()) return;
        processarStatusHerokuAsync(JSON.serialize(newContracts));
    }

    @future(callout=true)
    public static void processarStatusHerokuAsync(String listContractJson) {

        try {
            List<Contract> newContracts = (List<Contract>)JSON.deserialize(listContractJson, List<Contract>.class);
            
           
            
            
            Set<Id> IdcontratosAtualizarHeroku = new Set<Id>();
            List<Contract> contratosAtualizarHeroku = new List<Contract>();

            for(Contract newContract : newContracts){
                
              system.debug('newContract.Status>>>'+ newContract);
                
                if(newContract.Status == 'Cancelado' && newContract.StatusHeroku__c == 'Aguardando Processamento'){
                    IdcontratosAtualizarHeroku.add(newContract.id);
                }
            }

            if(IdcontratosAtualizarHeroku.size() > 0){
                contratosAtualizarHeroku = [SELECT Id, Name, StatusHeroku__c, NumeroApolice__c FROM Contract WHERE Id IN :IdcontratosAtualizarHeroku];
            }

            if(contratosAtualizarHeroku.size() > 0){

                ApoliceInadimplenciaREST.Response response = new ApoliceInadimplenciaREST.Response();
                response.itens = new List<ApoliceInadimplenciaREST.ItemResponse>();
                for(Contract contrato : contratosAtualizarHeroku){
                    contrato.StatusHeroku__c = 'Processado';
                    ApoliceInadimplenciaREST.ItemResponse item = new ApoliceInadimplenciaREST.ItemResponse();
                    item.id = String.valueOf(contrato.Id);
                    item.contrato = contrato.name;
                    item.apolice = contrato.NumeroApolice__c;
                    item.status = 'Processado';
                    item.sucesso = true;
                    response.itens.add(item);
                }
                
                HerokuService.getInstance().atualizarStatusApolice(JSON.serialize(response));
                
                TriggerHandler.bypass('ContractTriggerHandler');
                update contratosAtualizarHeroku;
                TriggerHandler.clearBypass('ContractTriggerHandler');
            }
        }
        catch (Exception e)
        {
            System.debug('ERRO:' + e.getLineNumber() + ': ' + e.getMessage());
        }
    }
    
    @TestVisible//FCVEP-29 - INICIO
    private static Date validarDataInicialVigencia(Id contractId, Date dataCancelar) {
        
        Date returnedDate = dataCancelar;
        List<Contract> ltContrato = new List<Contract>();
        ParcelamentoContratoTO parcCtrTO = new ParcelamentoContratoTO();
        String idExterno = '';

        ltContrato = [SELECT VigenciaFinal__c, StartDate FROM Contract WHERE Id = :contractId];

            try{
                if (ltContrato.isEmpty()){
                    throw new ContractException('Contrato não encontrado.');
                }

                Contract contratoVerificar = ltContrato[0];
                if (contratoVerificar.StartDate != null && contratoVerificar.VigenciaFinal__c != null) {
                    if (dataCancelar >= contratoVerificar.StartDate && dataCancelar <= contratoVerificar.VigenciaFinal__c) {
                        returnedDate = dataCancelar;
                    } else {
                        List<ContratanteContrato__c> cttsCtr = ContratanteContratoDAO.getInstance().obterContratCtr(contractId);
                        idExterno = contractId + '_' + cttsCtr[0].Id;

                        try {
                            if(!Test.isRunningTest()){
                                parcCtrTO = HerokuService.getInstance().consultarParcelasContrato(idExterno);                           
                                returnedDate = retonarDataParcInadim(parcCtrTO);
                            }
                        } catch (Exception e) {
                            returnedDate = retornarParcContrExtHerokuExcp(idExterno);
                        }                   
                    }
                }
            }catch (ContractException ce){
                returnedDate = retornarParcContrExtHerokuExcp(idExterno);
            }
        return returnedDate;
    }

    public static Date retornarParcContrExtHerokuExcp(String idExterno) {
        Date dataParcInadim = System.today();
        
        List<public_parcelacontrato__x> parcelas = ContratanteContratoDAO.getInstance().obterParcCtr(idExterno);
        
        if (Test.isRunningTest()) {
            public_parcelacontrato__x parcelaPendente = new public_parcelacontrato__x(status__c = 'PENDENTE', datavencimento__c = System.today());
            public_parcelacontrato__x parcelaInadimplente = new public_parcelacontrato__x(status__c = 'INADIMPLENTE', datavencimento__c = System.today().addDays(1));
            
            parcelas.add(parcelaPendente);
            parcelas.add(parcelaInadimplente); 
        }
        
        for (public_parcelacontrato__x parcela : parcelas) {
            if (parcela.status__c == 'INADIMPLENTE') {
                dataParcInadim = parcela.datavencimento__c;
                break;
            }
        }
        
        return dataParcInadim;
    }

    public static Date retonarDataParcInadim(ParcelamentoContratoTO parcCtrTO) {

        Date dataParcInadim = System.today();
        
        for (ParcelamentoContratoTO.DataTO parcela : parcCtrTO.data) {
            if (parcela.status == 'INADIMPLENTE') {
                dataParcInadim = Date.valueOf(parcela.datavencimento);
                break;
            }
        }        
        return dataParcInadim;
    }
    //FCVEP-29 - FIM
    //PLV-4556 - FIM
    //PLV-4871 - INICIO
    //RVI-160 - FIX02 - INICIO
    public void atualizarVigencia(List<Contract> newLstContract, Map<Id, Contract> oldMapContract){
        //PLV-4871 - FIX - INICIO
        Map<Id,Id> mapContractQuote = new Map<Id,Id>();
        for(Contract contract : newLstContract){            
            if(contract.Segmento__c == 'Individual' && contract.Tipo__c == 'Novo' && contract.Status == 'Emitido' && oldMapContract.get(contract.Id).Status != contract.Status){ //PLV-4871 - FIX - FIM   
                mapContractQuote.put(contract.Id, contract.Proposta__c);
            }            
        }
        Map<Id, Quote> mapQuote = new Map<Id,Quote>([SELECT Id, Name, DataEmissao__c, VigenciaInicial__c, VigenciaFinal__c FROM Quote WHERE Id in:mapContractQuote.values()]);
        for(Contract contract : newLstContract){
            
            if(mapContractQuote.containsKey(contract.Id) && mapQuote.containsKey(contract.Proposta__c)){
                Quote proposta = mapQuote.get(contract.Proposta__c);
                contract.DataEmissao__c = proposta.DataEmissao__c;
                contract.StartDate = proposta.VigenciaInicial__c;
                contract.VigenciaFinal__c = proposta.VigenciaFinal__c;
            }
        }
    }
    //RVI-160 - FIX02 - FIM
    //PLV-4871 - FIM
    //PLV-4905 - INICIO
    public void processarIntegracaoAntares(List<Contract> newLstContract, Map<Id, Contract> oldMapContract){
        List<Id> lstIntegrar = new List<Id>();
        for(Contract contrato : newLstContract){
            if(contrato.Tipo__c == 'Endosso' && contrato.Status == 'Emitido' && oldMapContract.get(contrato.Id).Status != contrato.Status){
                for(String sigla : contrato.SiglaTipoEndosso__c.split(';')){
                    if(sigla != 'BEN' && sigla != 'CAD'){
                        lstIntegrar.add(contrato.ContratoOriginal__c);
                    } 
                }
            }
        }
        if(lstIntegrar.size() > 0){
            ContractBo.IntegracaoAntares restBody = new ContractBo.IntegracaoAntares();
            restBody.dataIntegracao = new List<ContractBo.DataIntegracao>();
            for(Contract contrato : [SELECT Id, Name, Empresa__c, Sucursal__c, CodigoRamo__c, NumeroApolice__c, Endosso__c FROM Contract WHERE Id IN : lstIntegrar]){
                ContractBo.DataIntegracao dadosContrato = new ContractBo.DataIntegracao();
                dadosContrato.empresa = contrato.Empresa__c;
                dadosContrato.sucursal = contrato.Sucursal__c;
                dadosContrato.ramo = contrato.CodigoRamo__c;
                dadosContrato.apolice = contrato.NumeroApolice__c;
                dadosContrato.endosso = contrato.Endosso__c;
                restBody.dataIntegracao.add(dadosContrato);
            }
            processarIntegracaoAntaresAsync(JSON.serialize(restBody));
        }
    }
    //PLV-4905 - FIM

    //PLV-4905 - INICIO
    @future(callout=true)
    public static void processarIntegracaoAntaresAsync(String lstContractJson) {
        HerokuService.getInstance().atualizarIntegracaoAntares(lstContractJson);
    }
    //PLV-4905 - FIM


    public static void setUltimoModificador(List<Contract> lstContract){
        String METHOD_NAME = 'setUltimoModificador';
        // List<String> nameBlackList = new List<String>{''};
        
        System.debug(LoggingLevel.ERROR + 'CLASS_NAME: '+ CLASS_NAME + ' => METHOD_NAME: '+ METHOD_NAME + ' => setUltimoModificador: ' + UserInfo.getName());
    }

    // POR062-1 - INICIO
	public Map<Id, Contract> mapearContratosPorIdCaso(List<Case> casoLista) {
		Map<Id, Contract> mapaContratoPorIdDeCaso = new Map<Id, Contract>();
		for(Case registro : casoLista) {
            mapaContratoPorIdDeCaso.put(registro.Id, registro.Contrato__r);
        }
		return mapaContratoPorIdDeCaso;
	}
    // POR062-1 - FIM

    //PLV-5708 INICIO
    @TestVisible //FNPVVEP-96 INICIO/FIM
    private static Date validarDataCancelamento(Id ContractId, Date inicioVigencia){
		Date returnedDate;
        Boolean hasPaga = false;
		List<Contract> ltContrato = new List<Contract>();
		
		ltContrato = [SELECT  VigenciaFinal__c, StartDate, origem__c, NumeroProposta__c  //PLV-5708 FIX-03 INICIO/FIM 
                      FROM	Contract 
                      WHERE 	Id =: ContractId];

		if(!ltContrato.isEmpty()){
			contract contratoVerificar = ltContrato[0];
			if(contratoVerificar.StartDate != null && contratoVerificar.VigenciaFinal__c != null){
                List<public_parcelacontrato__x> ltParcelas = 
                                                [SELECT datavencimento__c, status__c FROM public_parcelacontrato__x 
                                                WHERE origemproposta__c =: Integer.valueOf(contratoVerificar.origem__c) AND numeropropostaporto__c  =: contratoVerificar.NumeroProposta__c //PLV-5708 FIX-03 INICIO/FIM 
                                                ORDER BY datavencimento__c ASC]; //PLV-5708 FIX-02 INICIO/FIM
                List<date> parcInadim = new List<date>();
                for(public_parcelacontrato__x parcela : ltParcelas){
                    if(parcela.status__c == 'PAGA') hasPaga = true;
                    else if(parcela.status__c == 'INADIMPLENTE'){
                        parcInadim.add(parcela.datavencimento__c);
                    }
                }
                if(hasPaga){
					returnedDate = parcInadim[0].addDays(91); //PLV-5708 FIX-02 INICIO/FIM
				}else {
					returnedDate = contratoVerificar.StartDate.addDays(91); //PLV-5708 FIX-01 INICIO/FIM
				}
			}
		}else{
			returnedDate = inicioVigencia;  //PLV-5708 FIX-01 INICIO/FIM
		}
		return returnedDate;
	}
    //PLV-5708 FIM

    //FNPVVEP-108 INICIO
    @future(callout=true)
    public static void calloutEmissaoBoletoVida(Set<Id> setContratoId, Set<String> setIdProposta) {
        List<ApoliceTO> apoliceList = new List<ApoliceTO>();

        List<public_parcelacontrato__x> listParcelaCtr = [SELECT Id, idexterno__c, numeroparcela__c FROM public_parcelacontrato__x WHERE idproposta__r.Id IN :setContratoId];
        List<Contract> listCtr = dao.buscarContratos(setContratoId);
        for (Contract contract : listCtr) {
            for (ContratanteContrato__c contratante : contract.ContratantesContrato__r) {
                String idExterno = contract.id + '_' + contratante.Id;
                if(contratante.FormaPagamento__r.Codigo__c == '41' && contract.Id == contratante.Contrato__c){
                    ApoliceTO apolice = new ApoliceTO();
                    apolice.numeroApolice = contract.NumeroApolice__c != null ? contract.NumeroApolice__c : '';
                    apolice.sucursal = contract.Sucursal__c != null ? contract.Sucursal__c : '';
                    apolice.ramo = contract.CodigoRamo__c != null ? contract.CodigoRamo__c : '';
                    apolice.senhaPdf = contract.Senha__c != null ? contract.Senha__c : '';
                    apolice.endosso = contract.Endosso__c != null ? contract.Endosso__c : '';
                    apolice.email = contract.Account.PersonEmail != null ? contract.Account.PersonEmail : '';
                    apolice.nomeCliente = contract.Account.Name != null ? contract.Account.Name : '';
                    apolice.cpfCliente = contract.Account.Cpf__c != null ? contract.Account.Cpf__c : '';
                    apolice.linkPdf = contract.DistributionPublicUrl__c != null ? contract.DistributionPublicUrl__c : '';
                    apolice.status = 'PENDENTE';
                
                    for(public_parcelacontrato__x parcelaCtr : listParcelaCtr){
                        if (idExterno == parcelaCtr.idexterno__c) {
                            apolice.numeroParcela.add(String.valueOf(parcelaCtr.numeroparcela__c));
                        }
                    }
                    apoliceList.add(apolice);
                    System.debug('contract.Senha__c ><:' + contract.Senha__c);
                }
            }
        }

        ApoliceResponse response = new ApoliceResponse(apoliceList);
        if(!apoliceList.isEmpty()) {
            String result = JSON.serialize(response);
            System.debug('result ><:' + result);
            if(!Test.IsRunningTest()) SensediaServices.gerarBoleto(result);
        }
    }

    public static void emissaoBoletoVida(List<Contract> newContracts) {
        Set<Id> setContratoId = new set<Id>();
        Set<String> setIdProposta = new set<String>();

        for (Contract contract : newContracts) {
            if(contract.Status == 'Emitido' && contract.Tipo__c != 'Cancelamento'){
                setContratoId.add(contract.Id);
                setIdProposta.add(contract.Proposta__c);
            }
        }
        System.debug('setContratoId ><:' + setContratoId);
        System.debug('setIdProposta ><:' + setIdProposta);
        if(!setContratoId.isEmpty() && !setIdProposta.isEmpty()){
            calloutEmissaoBoletoVida(setContratoId, setIdProposta);
        }
    }
    //FNPVVEP-108 FIM

    //PLV-4905 - INICIO
    public class IntegracaoAntares {
        public List<DataIntegracao> dataIntegracao {get;set;}
    }
    //PLV-4905 - FIM

    //PLV-4905 - INICIO
    public class DataIntegracao {
        public String empresa {get;set;}
        public String sucursal {get;set;}
        public String ramo {get;set;}
        public String apolice {get;set;}
        public String endosso {get;set;}
    }
    //PLV-4905 - FIM

    //PLV-4905 - INICIO
    public class ResponseHerokuAntares {
        public String servico {get;set;}
        public String status {get;set;}
        public Integer codigoprocessamento {get;set;}
        public String descricao {get;set;}
    }
    //PLV-4905 - FIM

    //AV-85 - INICIO
    public class ResponseHerokuConsultarVoucher {
        public String servico                                               {get;set;}
        public String status                                                {get;set;}
        public Integer codigoprocessamento                                  {get;set;}
        public String dataexecucao                                          {get;set;}
        public String descricao                                             {get;set;}
        public List<dadoConsultaVoucher> dados                              {get;set;}
    }
    public class dadoConsultaVoucher {
        public Integer totalutilizacao                                      {get;set;}
        public Boolean podeutilizar                                         {get;set;}        
        public List<infoConsultaVoucher> voucher                            {get;set;}
    }
    public class infoConsultaVoucher {
        public String cpf                                                   {get;set;}
        public String voucher                                               {get;set;}        
        public String produto                                               {get;set;}
        public String datautilizacao                                        {get;set;}
    }

    public class ResponseHerokuGravarVoucher {
        public String servico                                               {get;set;}
        public String status                                                {get;set;}
        public Integer codigoprocessamento                                  {get;set;}
        public String dataexecucao                                          {get;set;}
        public String descricao                                             {get;set;}
        public List<infoGravaVoucher> dados                                 {get;set;}
    }

    public class infoGravaVoucher {
        public String cpf                                                   {get;set;}
        public String voucher                                               {get;set;}        
        public String produto                                               {get;set;}
        public String datautilizacao                                        {get;set;}
    }

    //AV-85 FIX 2 INICIO

    public class RetornoCIVConsultaLTMMultiSegurosList{
        public String seguroVidaOnAtivo                                     {get;set;}
        public listaSegurosTOListMulti listaSeguros                         {get;set;}
        public String mensagemRetorno                                       {get;set;}
        public String codigoRetorno                                         {get;set;}
    }

    public class RetornoCIVConsultaLTMMultiSegurosObject{
        public String seguroVidaOnAtivo                                     {get;set;}
        public listaSegurosTOObjectMulti listaSeguros                       {get;set;}
        public String mensagemRetorno                                       {get;set;}
        public String codigoRetorno                                         {get;set;}
    }

    public class RetornoCIVConsultaLTMList{
        public String seguroVidaOnAtivo                                     {get;set;}
        public listaSegurosTOList listaSeguros                              {get;set;}
        public String mensagemRetorno                                       {get;set;}
        public String codigoRetorno                                         {get;set;}
    }

    public class RetornoCIVConsultaLTMObject{
        public String seguroVidaOnAtivo                                     {get;set;}
        public listaSegurosTOObject listaSeguros                            {get;set;}
        public String mensagemRetorno                                       {get;set;}
        public String codigoRetorno                                         {get;set;}
    }

    public class listaSegurosTOListMulti{
        public List <seguroVidaTOList> seguroVida                           {get;set;}
    }
    
    public class listaSegurosTOObjectMulti{
        public List <seguroVidaTOObject> seguroVida                        {get;set;}
    }

    public class listaSegurosTOList{
        public seguroVidaTOList seguroVida                                  {get;set;}
    }
    
    public class listaSegurosTOObject{
        public seguroVidaTOObject seguroVida                                {get;set;}
    }

    //AV-85 FIX 2 FIM

    public class seguroVidaTOList{
        public String codigoFormaPagamento                                  {get;set;}
        public String ramo                                                  {get;set;}
        public listaParcelaSeguroVidaTOList listaParcelaSeguroVida          {get;set;}
        public String linkApolice                                           {get;set;}
        public String dataTransmissao                                       {get;set;}
        public String nomeComercialProduto                                  {get;set;}
        public String nomeSegurado                                          {get;set;}
        public String inicioVigencia                                        {get;set;}
        public String apolice                                               {get;set;}
        public String sucursal                                              {get;set;}
        public String finalVigencia                                         {get;set;}
        public listaBeneficiariosSeguroTO listaBeneficiariosSeguro          {get;set;}
        public String cpf                                                   {get;set;}        
        public listaGarantiasContratadasTO listaGarantiasContratadas        {get;set;}
        public String descricaoFormaPagamento                               {get;set;}
    }

    public class seguroVidaTOObject{
        public String codigoFormaPagamento                                  {get;set;}
        public String ramo                                                  {get;set;}
        public listaParcelaSeguroVidaTOObject listaParcelaSeguroVida        {get;set;}
        public String linkApolice                                           {get;set;}
        public String dataTransmissao                                       {get;set;}
        public String nomeComercialProduto                                  {get;set;}
        public String nomeSegurado                                          {get;set;}
        public String inicioVigencia                                        {get;set;}
        public String apolice                                               {get;set;}
        public String sucursal                                              {get;set;}
        public String finalVigencia                                         {get;set;}
        public listaBeneficiariosSeguroTO listaBeneficiariosSeguro          {get;set;}
        public String cpf                                                   {get;set;}        
        public listaGarantiasContratadasTO listaGarantiasContratadas        {get;set;}
        public String descricaoFormaPagamento                               {get;set;}
    }

    public class listaParcelaSeguroVidaTOList{
        public List<parcelaSeguroVidaTO> parcelaSeguroVida                  {get;set;}
    }

    public class listaParcelaSeguroVidaTOObject{
        public parcelaSeguroVidaTO parcelaSeguroVida                        {get;set;}
    } 

    public class parcelaSeguroVidaTO{
        public String numeroParcela                                         {get;set;}
        public String valorParcela                                          {get;set;}   
    }    

    public class listaBeneficiariosSeguroTO{
        public beneficiarioSeguroTO beneficiarioSeguro                      {get;set;}
    }    

    public class beneficiarioSeguroTO{
        public String percentualDistribuicaoCapital                         {get;set;}
    }    

    public class listaGarantiasContratadasTO{
        public List<garantiaContratada> garantiaContratada                  {get;set;}
    }    

    public class garantiaContratada{
        public String nomeGarantia                                          {get;set;}
        public String valorCapital                                          {get;set;}
    }    

    public class DadosCPF{
        public String cpf                                                   {get;set;}
    }

    //PLV-530 INICIO
    public class DadosCPFHeroku{
        public String numeroCpf                                                   {get;set;}
    }
    //PLV-530 FIM

    public class paramsPortoPlus{
            public consultivoPortoPlus consultivo                           {get;set;}
            public string acao                                              {get;set;}
            public string IDPortoVidaON                                     {get;set;}
    }

    public class consultivoPortoPlus{
        public string codigoOfertaConsultiva                                {get;set;}
        public string canalDistribuicao                                     {get;set;}
        public string identificadorRepresentante                            {get;set;}
        public string meioComercializacao                                   {get;set;}
        public string entradaNegocio                                        {get;set;}
        public boolean voltar                                               {get;set;}
        public string nProposta                                             {get;set;} //PLV-5441 - INICIO/FIM
    }
    //AV-85 - FIM
    //RVI-292 INICIO
    public class entradaConsultivo{
        public consultivo consultivo                                        {get;set;}
        public string acao                                                  {get;set;}
    }

    public class consultivo{
        public string codigoOfertaConsultiva                                {get;set;}
        public string canalDistribuicao                                     {get;set;}
        public string identificadorRepresentante                            {get;set;}
        public string meioComercializacao                                   {get;set;}
        public string entradaNegocio                                        {get;set;}
        public boolean voltar                                               {get;set;}
    }
    //RVI-292 FIM

    //FNPVVEP-108 INICIO
    public class ApoliceTO {
        public String numeroApolice { get; set; }
        public String sucursal { get; set; }
        public String ramo { get; set; }
        public String endosso { get; set; }
        public String senhaPdf { get; set; }
        public String nomeCliente { get; set; }
        public String cpfCliente { get; set; }
        public String linkPdf { get; set; }
        public String email { get; set; } 
        public String status { get; set; } 
        public List<String> numeroParcela { get; set; }

        public ApoliceTO() {
            this.numeroParcela = new List<String>();
        }
    }

    public class ApoliceResponse {
        public List<ApoliceTO> apolices;
    
        public ApoliceResponse(List<ApoliceTO> apoliceList) {
            this.apolices = apoliceList;
        }
    }
    //FNPVVEP-108 FIM
}