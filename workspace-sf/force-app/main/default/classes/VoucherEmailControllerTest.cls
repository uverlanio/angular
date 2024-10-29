/*
        @Autor: Pedro Augusto Braz - SYS4B
        @Criado em: 03/06/2020
        @Descrição: Classe de Testes da VoucherEmailController
 
        Histórico de alterações:
            03/06/2020 - Pedro Augusto Braz - SYS4B - Criação - PLV-3755
*/
    @isTest
    public class VoucherEmailControllerTest{
        
        @testSetup
        static void setup(){
            /*TestDataFactory.gerarDadosSetup();
            TestDataFactory.gerarContrato(true);*/

            SenhaCriptografia__c sCripto = new SenhaCriptografia__c();
            sCripto.Name = 'Senha';
            sCripto.Senha__c = 'TesteCrypto';
            insert sCripto;

            Account conta = (Account) new AccountFactory.PessoaFisica().createRecord();
            ContadorCodigo__c contCodigoTec = (ContadorCodigo__c) new ContadorCodigoFactory.ProdutoTecnico().createRecord();
            ContadorCodigo__c contCodigoCom = (ContadorCodigo__c) new ContadorCodigoFactory.ProdutoComercial().createRecord();
            
            Product2 produtoTecnico = (Product2) new ProdutoFactory.ProdutoTecnico().createRecord();
            produtoTecnico.NumeroSusep__c = '123';
            produtoTecnico.VersaoRenovacao__c = 'Versão atual';
            produtoTecnico.Status__c = 'Ativo';
            produtoTecnico.GerarVoucher__c = true; //PLV - 4440  INICIO/FIM
            update produtoTecnico;
            
            Product2 produtoComercial = (Product2) new ProdutoFactory.ProdutoComercial(produtoTecnico).createRecord();
            produtoComercial.Status__c = 'Ativo';
            update produtoComercial;
            
            FormaPagamento__c formaPagamento = (FormaPagamento__c) new FormaPagamentoFactory().createRecord();
            Parceiro__c parceiro = (Parceiro__c) new ParceiroFactory(conta, formaPagamento).createRecord();
            Contract contrato = (Contract) new ContratoFactory.ContratoFactoryComParam(conta, produtoComercial, parceiro).createRecord();
            
            ProdutoParceiro__c produtoParceiro = TestDataFactory.gerarProdutoParceiro(parceiro, produtoComercial);
            
            ContratanteContrato__c contratante = (ContratanteContrato__c) new ContratanteFactory(contrato).createRecord();
            contratante.Numero__c = 123;

            contratante.IOF__c = 10;
            contratante.Contrato__c = contrato.Id;
            update contratante;
            
            GrupoContrato__c grupo = (GrupoContrato__c) new GrupoFactory(contratante).createRecord();
            grupo.Numero__c = 123;
            update grupo;
            
            SeguradoContrato__c segurado = (SeguradoContrato__c) new SeguradoContratoFactory(conta, grupo).createRecord();
            segurado.Numero__c = 123;
            update segurado;
            
            
            RamoSeguro__c ramoSeguro = (RamoSeguro__c) new RamoSeguroFactory(conta).createRecord();
            DadosCorretor__c dadosCorretor = (DadosCorretor__c) new DadosCorretorFactory(conta).createRecord();
            Modalidade__c modalidade = (Modalidade__c) new ModalidadeFactory(ramoSeguro).createRecord();    
            Opportunity orcamento = (Opportunity) new OrcamentoFactory.VidaIndividual(produtoComercial, conta).createRecord();
            Quote proposta = (Quote) new PropostaFactory(produtoComercial, ramoSeguro, conta, dadosCorretor, orcamento, modalidade).createRecord();

            Quote proposta2 = new Quote(
                Name = '18-00006769',
                NumeroPropostaUnico__c = '18-00006769',
                Produto__c = produtoComercial.Id,
                RamoSeguro__c = ramoSeguro.Id,
                Status = 'Disponível para contratação',
               // Segmento__c = 'Viagem',
                VigenciaInicial__c = System.today(),
                VigenciaFinal__c = System.today().addMonths(1),
                Empresa__c = conta.Id,
                CodigoCorretor__c = dadosCorretor.Id,
                DataCalculo__c = System.today(),
                DataCriacaoPortal__c = System.today(),
                TipoVigencia__c = 'Anual',
                MeioComercializacao__c = 'PMC', //PLV-4550 INICIO/FIM
                OpportunityId = orcamento.Id,
                Origem__c = '18',
                Modalidade__c = modalidade.Id,
                Modalidade__r = modalidade,
                NumeroProposta__c = '00006769',
                Parceiro__c = '67708896000139',
                Senha__c = 'ewewqwdd',
                DistributionPublicUrl__c ='https://google.com/'
                
            );

            insert proposta2;
            
            contrato.Empresa__c = '1';
            contrato.Sucursal__c = '1';
            contrato.NumeroApolice__c = '12345';
            contrato.Endosso__c = '0';
            contrato.VigenciaFinal__c = contrato.StartDate.addMonths(3);  
            contrato.MeioComercializacao__c = 'ARQ';
            contrato.Proposta__c = proposta.Id;
            contrato.RamoSeguro__c = ramoSeguro.Id;
            contrato.Status = 'Emitido';
            contrato.Senha__c = 'ewewqwdd';
            contrato.DistributionPublicUrl__c ='https://google.com/';
                
            update contrato;
            
        }

        @IsTest
        public static void testUnit(){
            
            Quote proposta = [SELECT Id FROM Quote LIMIT 1];
            
            proposta.DataProtocolo__c = system.today();
            proposta.Email__c = 'teste@teste.com';
            proposta.VoucherPdfDownloadUrl__c = 'abcd';
            proposta.Senha__c = 'ewewqwdd';
            proposta.DistributionPublicUrl__c ='https://google.com/';
                
            update proposta;

            Test.startTest();
            
            Map<String,String> retorno = VoucherEmailController.SendEmails(new Set<String>{proposta.Id}, proposta.Id);
            System.debug('retorno > '+retorno);
            
            Test.stopTest();

            System.assertEquals('true', retorno.get('Sucesso'));
        }
        

        @IsTest
        public static void moreQuotes(){
        
            
            
            List<Quote> propostas = [SELECT Id FROM Quote LIMIT 2];
            Set<String> ids = new Set<String>();
            List<Quote> to = new List<Quote>();
            for(Quote proposta : propostas){

                proposta.DataProtocolo__c = system.today();
                proposta.Email__c = 'teste@teste.com';
                proposta.VoucherPdfDownloadUrl__c = 'abcd';
                proposta.Senha__c = 'ewewqwdd';
                proposta.DistributionPublicUrl__c ='https://google.com/';
                
                ids.add(proposta.Id);
                to.add(proposta);
            }
            String principal = propostas[1].Id;
            update to;

            
            Test.startTest();

            Map<String,String> retorno = VoucherEmailController.SendEmails(ids, principal);
            SYSTEM.debug('retorno > '+retorno);
            
            Test.stopTest();

            System.assertEquals('true', retorno.get('Sucesso'));
        }
    }