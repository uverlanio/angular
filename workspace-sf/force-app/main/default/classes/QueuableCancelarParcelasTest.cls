// /**
//  * Created by Alessandro Ponte on 15/03/2019.
//  */
@IsTest
public class QueuableCancelarParcelasTest {

    @TestSetup
    static void setup(){
        // TestDataFactory.gerarDadosSetup();
        // // TestDataFactory.gerarContrato();

        // // Recupera contrato original e atualiza para emitido
        // Contract contrato = [SELECT Id,Empresa__c,Sucursal__c, RamoSeguro__c, NumeroApolice__c, Status FROM Contract LIMIT 1];
        // contrato.Tipo__c = 'Novo';
        // contrato.Status = 'Cancelado';
        // update contrato;

        // Id idcontrato = clonarContrato(contrato.Id);
    
    }

//     @IsTest
//     static void testCancelarParcelas(){
// /*
//         String responseJsonString = '{"meta": {"dataExecucao": "2019-03-15T21:52:40.231Z","servico": "Cancelar parcelas do contrato.","statusHttp": 200,"mensagem": "1 parcela(s) canceladas"}}';
//         Test.setMock(HttpCalloutMock.class, new MockHttpResponse(responseJsonString, 200, 'OK'));

//         // Busca o contrato original apos o cancelamento
//         Contract contratoOriginal = [SELECT Id, Empresa__c, Sucursal__c, CodigoRamo__c, NumeroApolice__c, Proposta__c, Proposta__r.Id, Proposta__r.RamoSeguro__c, Proposta__r.OpportunityId, Status, Tipo__c  FROM Contract WHERE Status = 'Cancelado' LIMIT 1];

//         // Busca o contrato de cancelamento
//         Contract contratoCancelamento = [SELECT Id, Empresa__c, Sucursal__c, CodigoRamo__c, NumeroApolice__c, Proposta__c, Proposta__r.Id, Proposta__r.RamoSeguro__c, Proposta__r.ContractId, Proposta__r.OpportunityId, Status, Tipo__c From Contract WHERE Status = 'Emitido' LIMIT 1];

//         // Verifica se o contrato original foi cancelado
//         System.assertEquals('Cancelado',contratoOriginal.Status);
//         // Verifica se eh o contrato original
//         System.assertEquals('Novo',contratoOriginal.Tipo__c);
//         // Verifica se o contrato de cancelamento original foi emitido
//         System.assertEquals('Emitido',contratoCancelamento.Status);
//         // Verifica se eh o contrato de cancelamento
//         System.assertEquals('Cancelamento',contratoCancelamento.Tipo__c);
//         // Verifica se a Query retornou os contratos corretamente e se o contrato de cancelamento eh o que cancelou o contrato original
//         System.assertEquals(contratoOriginal.Id,contratoCancelamento.Proposta__r.ContractId);

//         Test.startTest();

//         // Queueable de cancelamento das parcelas dos endossos anteriores
//         // TODO: Inicia o teste de cancelamento das parcelas do contrato, simulando que o Heroku conseguiu com exatidao cancelar as parcelas
//         System.enqueueJob(new QueueableCancelarParcelas(contratoCancelamento.Id, contratoCancelamento.Proposta__r,
//                 Integer.valueOf(contratoCancelamento.Empresa__c),
//                 Integer.valueOf(contratoCancelamento.Sucursal__c),
//                 contratoCancelamento.Proposta__r.RamoSeguro__c,
//                 contratoCancelamento.NumeroApolice__c));

//         Test.stopTest();

//         // Busca o contrato de cancelamento para verificar se continua criado e com o status Emitido
//         List<Contract> listContratoCancelamento = [SELECT Id, Empresa__c, NumeroApolice__c, RamoSeguro__c, Sucursal__c, Status, Proposta__c, Proposta__r.Id, Proposta__r.RamoSeguro__c, Proposta__r.OpportunityId FROM Contract WHERE Id =: contratoCancelamento.Id];

//         // Busca o contrato original para verificar se continua cancelado
//         List<Contract> listContratoOriginal = [SELECT Id, Empresa__c, NumeroApolice__c, RamoSeguro__c, Sucursal__c, Status, Proposta__c, Proposta__r.Id, Proposta__r.RamoSeguro__c, Proposta__r.OpportunityId FROM Contract WHERE Id =: contratoOriginal.Id];

//         // Verifica se o contrato de cancelamento continua emitido
//         System.assertEquals('Emitido',listContratoCancelamento[0].Status);
//         // Verifica se o contrato de original continua cancelado
//         System.assertEquals('Cancelado',listContratoOriginal[0].Status);
// */
//     }


//     @IsTest
//     static void testCancelarParcelasRollback(){

//         Test.startTest();

//         String responseJsonString = '{"meta": {"dataExecucao": "2019-03-15T21:52:40.231Z","servico": "Cancelar parcelas do contrato.","statusHttp": 500,"mensagem": "Apólice, Sucursal, Ramo ou Endosso não informados no contrato"}}';
//         Test.setMock(HttpCalloutMock.class, new MockHttpResponse(responseJsonString, 500, 'OK'));

//         // Busca o contrato original apos o cancelamento
//         Contract contratoOriginal = [SELECT Id, Empresa__c, RamoSeguro__c, Sucursal__c, CodigoRamo__c, NumeroApolice__c, Proposta__c, Proposta__r.Id, Proposta__r.RamoSeguro__c, Proposta__r.OpportunityId, Status, Tipo__c  FROM Contract WHERE Status = 'Cancelado' LIMIT 1];

//         // Busca o contrato de cancelamento
//         Contract contratoCancelamento = [SELECT Id, Empresa__c, RamoSeguro__c,Sucursal__c, CodigoRamo__c, NumeroApolice__c, Proposta__c, Proposta__r.Id, Proposta__r.RamoSeguro__c, Proposta__r.ContractId, Proposta__r.OpportunityId, Status, Tipo__c From Contract WHERE Status = 'Emitido' LIMIT 1];

//         // Verifica se o contrato original foi cancelado
//         System.assertEquals('Cancelado',contratoOriginal.Status);
//         // Verifica se eh o contrato original
//         System.assertEquals('Novo',contratoOriginal.Tipo__c);
//         // Verifica se o contrato de cancelamento original foi emitido
//         System.assertEquals('Emitido',contratoCancelamento.Status);
//         // Verifica se eh o contrato de cancelamento
//         System.assertEquals('Cancelamento',contratoCancelamento.Tipo__c);
//         // Verifica se a Query retornou os contratos corretamente e se o contrato de cancelamento eh o que cancelou o contrato original
//         System.assertEquals(contratoOriginal.Empresa__c,      contratoCancelamento.Empresa__c);
//         System.assertEquals(contratoOriginal.Sucursal__c,     contratoCancelamento.Sucursal__c);
//         System.assertEquals(contratoOriginal.RamoSeguro__c,   contratoCancelamento.RamoSeguro__c);
//         System.assertEquals(contratoOriginal.NumeroApolice__c,contratoCancelamento.NumeroApolice__c);


//         // Queueable de cancelamento das parcelas dos endossos anteriores
//         // TODO: Inicia o teste de rollback de cancelamento de contrato, simulando que o Heroku nao conseguiu cancelar as parcelas
//         System.enqueueJob(new QueueableCancelarParcelas(contratoCancelamento.Id, contratoCancelamento.Proposta__r,
//                 Integer.valueOf(contratoCancelamento.Empresa__c),
//                 Integer.valueOf(contratoCancelamento.Sucursal__c),
//                 contratoCancelamento.RamoSeguro__c,
//                 contratoCancelamento.NumeroApolice__c));

//         Test.stopTest();

//         // Busca o contrato de cancelamento para verificar se foi dado o rollback e excluído o contrato
// //        List<Contract> listContratoCancelamento = [SELECT Id, Empresa__c, NumeroApolice__c, RamoSeguro__c, Sucursal__c, Status, Proposta__c, Proposta__r.Id, Proposta__r.RamoSeguro__c, Proposta__r.OpportunityId FROM Contract WHERE Id =: contratoCancelamento.Id];

//         // Busca o contrato original para verificar se foi dado o rollback e atualizado o status para emitido
//         List<Contract> listContratoOriginal = [SELECT Id, Empresa__c, NumeroApolice__c, RamoSeguro__c, Sucursal__c, Status, Proposta__c, Proposta__r.Id, Proposta__r.RamoSeguro__c, Proposta__r.OpportunityId FROM Contract WHERE Id =: contratoOriginal.Id];

//         // Verifica se o contrato de cancelamento foi excluído
// //        System.assert(listContratoCancelamento.isEmpty());
//         // Verifica se o contrato original ficou como emitido
// //        System.assertEquals('Emitido',listContratoOriginal[0].Status);


//     }

//     public static Id clonarContrato(Id id)
//     {
//         Map<Id, ContratanteContrato__c>      mapContratanteContrato          = new Map<Id, ContratanteContrato__c>();
//         Map<Id, GrupoContrato__c>            mapGrupoContrato                = new Map<Id, GrupoContrato__c>();
//         Map<Id, SeguradoContrato__c>         mapSeguradoContrato             = new Map<Id, SeguradoContrato__c>();

//         // Listas de proposta p/ criar estrutura de contrato

//         List<ContratanteContrato__c>         lstContratanteContratoOriginal          = ContractDAO.getInstance().buscarContratantesContratoByContrato(new Set<Id>{id});
//         List<GrupoContrato__c>               lstGrupoContratoOriginal                = ContractDAO.getInstance().buscarListGrupoContratoByContrato(new Set<Id>{id});
//         List<SeguradoContrato__c>            lstSeguradoContratoOriginal             = ContractDAO.getInstance().buscarListSeguradosContratoByContrato(new Set<Id>{id});
        
//         List<GarantiaContrato__c>            lstGarantiaContratoOriginal             = ContractDAO.getInstance().buscarGarantiaContratoPorId(new Set<Id>{id});
//         List<GarantiaContratanteContrato__c> lstGarantiaContratanteContratoOriginal  = ContractDAO.getInstance().buscarGarantiasContratanteContratoByContrato(new Set<Id>{id});
//         List<GarantiaGrupoContrato__c>      lstGarantiaGrupoContratoOriginal        = ContractDAO.getInstance().buscarGarantiasGrupoContratoByContrato(new Set<Id>{id});
//         List<GarantiaSeguradoContrato__c>    lstGarantiaSeguradoContratoOriginal     = ContractDAO.getInstance().buscarGarantiasSeguradoContratoByContrato(new Set<Id>{id});
        
//         List<RemuneracaoContrato__c>         lstRemuneracaoOriginal                  = ContractDAO.getInstance().buscarRemuneracaoContratoPorId(new Set<Id>{id});
//         List<CriticaContrato__c>             lstCriticaOriginal                      = ContractDAO.getInstance().buscarCriticaContratoByContrato(new Set<Id>{id});

//         //---- Create Contratante do Contrato
//         List<ContratanteContrato__c>         lstContratanteContrato          = new List<ContratanteContrato__c>();
//         List<GrupoContrato__c>               lstGrupoContrato                = new List<GrupoContrato__c>();
//         List<SeguradoContrato__c>            lstSeguradoContrato             = new List<SeguradoContrato__c>();

//         List<BeneficiarioSeguradoContrato__c> lstBeneficiarioSeguradoContrato = new List<BeneficiarioSeguradoContrato__c>();

//         //---- GARANTIAS DO CONTRATO
//         List<GarantiaContrato__c>            lstGarantiaContrato            = new List<GarantiaContrato__c>();
//         List<GarantiaContratanteContrato__c> lstGarantiaContratanteContrato = new List<GarantiaContratanteContrato__c>();
//         List<GarantiaGrupoContrato__c>       lstGarantiaGrupoContrato       = new List<GarantiaGrupoContrato__c>();
//         List<GarantiaSeguradoContrato__c>    lstGarantiaSeguradoContrato    = new List<GarantiaSeguradoContrato__c>();

//         //---- Create Remuneração do Contrato
//         List<RemuneracaoContrato__c>            lstRemuneracaoContrato          = new List<RemuneracaoContrato__c>();
//         List<FavorecidoRemuneracaoContrato__c>  lstFavorecidosContrato          = new List<FavorecidoRemuneracaoContrato__c>();
        
//         List<CriticaContrato__c>                lstCriticaContrato              = new List<CriticaContrato__c>();


//         Contract contratoOriginal = ContractDAO.getInstance().buscarContratoById(id);


//         Integer endosso = Integer.valueOf(contratoOriginal.Endosso__c);
//         endosso++;


//         // criar contrato
//         Contract objContratoClonado = new Contract();


//         objContratoClonado.Seguradora__c           = contratoOriginal.Seguradora__c;
//         objContratoClonado.Parceria__c             = contratoOriginal.Parceria__c;
//         objContratoClonado.NumeroApolice__c        = contratoOriginal.NumeroApolice__c;
//         objContratoClonado.CodigoRamo__c           = contratoOriginal.CodigoRamo__c;
//         objContratoClonado.CanalDistribuicao__c    = contratoOriginal.CanalDistribuicao__c;
//         objContratoClonado.AccountId               = contratoOriginal.AccountId;
//         objContratoClonado.Sucursal__c             = contratoOriginal.Sucursal__c;
//         objContratoClonado.Endosso__c              = String.valueOf(endosso);
//         objContratoClonado.Empresa__c              = contratoOriginal.Empresa__c;
//         objContratoClonado.RamoSeguro__c           = contratoOriginal.RamoSeguro__c;
//         objContratoClonado.RecordTypeId            = contratoOriginal.RecordTypeId;
//         objContratoClonado.CodigoCorretor__c       = contratoOriginal.CodigoCorretor__c;
//         objContratoClonado.Description             = contratoOriginal.Description;
//         objContratoClonado.FormaPagamento__c       = contratoOriginal.FormaPagamento__c;
//         objContratoClonado.Oportunidade__c         = contratoOriginal.Oportunidade__c;
//         objContratoClonado.Produto__c              = contratoOriginal.Produto__c;
//         objContratoClonado.Proposta__c             = contratoOriginal.Proposta__c;
//         objContratoClonado.Status                  = 'Emitido';
//         objContratoClonado.Tipo__c                 = 'Cancelamento';
//         objContratoClonado.DataEmissao__c          = contratoOriginal.DataEmissao__c;
//         objContratoClonado.IdContratoParceiro__c   = contratoOriginal.IdContratoParceiro__c;
//         objContratoClonado.IdContratanteParceiro__c= contratoOriginal.IdContratanteParceiro__c;
//         objContratoClonado.Parceiro__c             = contratoOriginal.Parceiro__c;
//         objContratoClonado.Payload__c              = contratoOriginal.Payload__c;
//         objContratoClonado.StartDate               = contratoOriginal.StartDate;
//         objContratoClonado.VigenciaFinal__c        = contratoOriginal.VigenciaFinal__c;
//         objContratoClonado.MeioComercializacao__c  = contratoOriginal.MeioComercializacao__c;
//         objContratoClonado.PremioComercial__c      = contratoOriginal.PremioComercial__c;
//         objContratoClonado.PremioPuro__c           = contratoOriginal.PremioPuro__c;
//         objContratoClonado.PremioTotal__c          = contratoOriginal.PremioTotal__c;
//         objContratoClonado.TaxaComercial__c        = contratoOriginal.TaxaComercial__c;
//         objContratoClonado.TaxaPura__c             = contratoOriginal.TaxaPura__c;
//         objContratoClonado.TaxaTotal__c            = contratoOriginal.TaxaTotal__c;
//         objContratoClonado.Origem__c               = contratoOriginal.Origem__c;
//         objContratoClonado.TipoEndosso__c          = contratoOriginal.TipoEndosso__c;
//         objContratoClonado.DescontoAgravoPercentualTecnico__c      =  contratoOriginal.DescontoAgravoPercentualTecnico__c;
//         objContratoClonado.DescontoAgravoMonetarioTecnico__c       =  contratoOriginal.DescontoAgravoMonetarioTecnico__c;
//         objContratoClonado.DescontoAgravoPercentualComercial__c    =  contratoOriginal.DescontoAgravoPercentualComercial__c;
//         objContratoClonado.DescontoAgravoMonetarioComercial__c     =  contratoOriginal.DescontoAgravoMonetarioComercial__c;
//         objContratoClonado.DescontoAgravoPercentualInformado__c    =  contratoOriginal.DescontoAgravoPercentualInformado__c;
//         objContratoClonado.DescontoAgravoMonetarioInformado__c     =  contratoOriginal.DescontoAgravoMonetarioInformado__c;

//         insert objContratoClonado;

// /*
//         for(ContratanteContrato__c contratanteProp : objContratoClonado.ContratantesContrato__r)
//         {
//             ContratanteContrato__c objContratanteContrato = new ContratanteContrato__c();
//             try // DEPARA de proposta p/ contrato
//             {
//                 objContratanteContrato.Contrato__c = objContratanteContrato.Id;
//             }
//             catch(Exception e)
//             {
//                 System.debug('ERRO MAPEAMENTO CONTRATANTE:' + e.getLineNumber() + ': ' + e.getMessage());
//             }

//             lstContratanteContrato.add(objContratanteContrato);
//             mapContratanteContrato.put(contratanteProp.Id, objContratanteContrato);
//         }
// */


//         // CONTRATANTES 
//         for(ContratanteContrato__c contratanteProp : lstContratanteContratoOriginal)
//         {
//             ContratanteContrato__c objContratanteContrato = new ContratanteContrato__c();
//             try // DEPARA de proposta p/ contrato
//             {
//                 objContratanteContrato.Contrato__c                        = objContratoClonado.Id;
// /*
//                 objContratanteContrato.Bairro__c                          = contratanteProp.Bairro__c;
//                 objContratanteContrato.BairroCorrespondencia__c           = contratanteProp.BairroCorrespondencia__c;
//                 objContratanteContrato.Cep__c                             = contratanteProp.Cep__c;
//                 objContratanteContrato.CEPCorrespondencia__c              = contratanteProp.CEPCorrespondencia__c;
//                 objContratanteContrato.Cidade__c                          = contratanteProp.Cidade__c;
//                 objContratanteContrato.CidadeCorrespondencia__c           = contratanteProp.CidadeCorrespondencia__c;
//                 objContratanteContrato.Complemento__c                     = contratanteProp.Complemento__c;
//                 objContratanteContrato.ComplementoCorrespondencia__c      = contratanteProp.ComplementoCorrespondencia__c;
//                 objContratanteContrato.Conta__c                           = contratanteProp.Conta__c;
//                 objContratanteContrato.EnderecoBoleto__c                  = contratanteProp.EnderecoBoleto__c;
//                 objContratanteContrato.Estado__c                          = contratanteProp.Estado__c;
//                 objContratanteContrato.EstadoCorrespondencia__c           = contratanteProp.EstadoCorrespondencia__c;
//                 objContratanteContrato.FormaPagamento__c                  = contratanteProp.FormaPagamento__c;
//                 objContratanteContrato.Logradouro__c                      = contratanteProp.Logradouro__c;
//                 objContratanteContrato.LogradouroCorrespondencia__c       = contratanteProp.LogradouroCorrespondencia__c;
//                 objContratanteContrato.NumeroCorrespondencia__c           = contratanteProp.NumeroCorrespondencia__c;
//                 objContratanteContrato.NumeroEndereco__c                  = contratanteProp.NumeroEndereco__c;
//                 objContratanteContrato.Numero__c                          = contratanteProp.Numero__c;
//                 objContratanteContrato.Pais__c                            = contratanteProp.Pais__c;
//                 objContratanteContrato.PaisCorrespondencia__c             = contratanteProp.PaisCorrespondencia__c;
//                 objContratanteContrato.QuantidadeParcelas__c              = contratanteProp.QuantidadeParcelas__c;
//                 objContratanteContrato.ResponsavelPagamento__c            = contratanteProp.ResponsavelPagamento__c;
//                 objContratanteContrato.Tipo__c                            = contratanteProp.Tipo__c;
//                 objContratanteContrato.TipoEndereco__c                    = contratanteProp.TipoEndereco__c;
//                 objContratanteContrato.TipoEnderecoCorrespondencia__c     = contratanteProp.TipoEnderecoCorrespondencia__c;
//                 objContratanteContrato.TipoLogradouro__c                  = contratanteProp.TipoLogradouro__c;
//                 objContratanteContrato.TipoLogradouroCorrespondencia__c   = contratanteProp.TipoLogradouroCorrespondencia__c;
//                 objContratanteContrato.TipoResponsavelPagamento__c        = contratanteProp.TipoResponsavelPagamento__c;
//                 objContratanteContrato.VencimentoPrimeiraParcela__c       = contratanteProp.VencimentoPrimeiraParcela__c;
//                 objContratanteContrato.IOF__c                             = contratanteProp.IOF__c;
//                 objContratanteContrato.PremioComercial__c                 = contratanteProp.PremioComercial__c;               
//                 objContratanteContrato.PremioParcela__c                   = contratanteProp.PremioParcela__c;
//                 objContratanteContrato.PorcentagemParticipacaoVida__c     = contratanteProp.PorcentagemParticipacaoVida__c;
//                 objContratanteContrato.Reenquadramento__c                 = contratanteProp.Reenquadramento__c;
//                 objContratanteContrato.IPCA__c                            = contratanteProp.IPCA__c;
//                 objContratanteContrato.PorcentagemParticipacaoSegurado__c = contratanteProp.PorcentagemParticipacaoSegurado__c;
//                 objContratanteContrato.InformacaoBancaria__c              = contratanteProp.InformacaoBancaria__c;
//                 objContratanteContrato.PlanoParcelamento__c               = contratanteProp.PlanoParcelamento__c;
//                 objContratanteContrato.CartaoCredito__c                   = contratanteProp.CartaoCredito__c;
//                 objContratanteContrato.TipoCusteio__c                     = contratanteProp.TipoCusteio__c;
//                 objContratanteContrato.IOF__c                             = contratanteProp.IOF__c;
//                 objContratanteContrato.PremioComercial__c                 = contratanteProp.PremioComercial__c;
//                 objContratanteContrato.PremioPuro__c                      = contratanteProp.PremioPuro__c;
//                 objContratanteContrato.PremioTotal__c                     = contratanteProp.PremioTotal__c;
//                 objContratanteContrato.TaxaComercial__c                   = contratanteProp.TaxaComercial__c;
//                 objContratanteContrato.TaxaPura__c                        = contratanteProp.TaxaPura__c;
//                 objContratanteContrato.TaxaTotal__c                       = contratanteProp.TaxaTotal__c;
//                 objContratanteContrato.DescontoAgravoPercentualTecnico__c      =  contratanteProp.DescontoAgravoPercentualTecnico__c;
//                 objContratanteContrato.DescontoAgravoMonetarioTecnico__c       =  contratanteProp.DescontoAgravoMonetarioTecnico__c;
//                 objContratanteContrato.DescontoAgravoPercentualComercial__c    =  contratanteProp.DescontoAgravoPercentualComercial__c;
//                 objContratanteContrato.DescontoAgravoMonetarioComercial__c     =  contratanteProp.DescontoAgravoMonetarioComercial__c;
//                 objContratanteContrato.DescontoAgravoPercentualInformado__c    =  contratanteProp.DescontoAgravoPercentualInformado__c;
//                 objContratanteContrato.DescontoAgravoMonetarioInformado__c     =  contratanteProp.DescontoAgravoMonetarioInformado__c;
// */
//             }
//             catch(Exception e)
//             {
//                 System.debug('ERRO MAPEAMENTO CONTRATANTE:' + e.getLineNumber() + ': ' + e.getMessage());
//             }

//             lstContratanteContrato.add(objContratanteContrato);
//             mapContratanteContrato.put(contratanteProp.Id, objContratanteContrato);
//         }


//         try
//         {

//             insert lstContratanteContrato;

//             // GRUPOS 
//             for(GrupoContrato__c objGrupoProp : lstGrupoContratoOriginal)
//             {
//                 try
//                 {
//                     GrupoContrato__c objGrupoContrato       = new GrupoContrato__c();
//                     objGrupoContrato.ContratanteContrato__c = mapContratanteContrato.get(objGrupoProp.ContratanteContrato__c).Id;
// /*
//                     objGrupoContrato.Descricao__c           = objGrupoProp.Descricao__c;
//                     objGrupoContrato.Name                   = objGrupoProp.Name;
//                     objGrupoContrato.Numero__c              = objGrupoProp.Numero__c;
//                     objGrupoContrato.QuantidadeVidas__c     = objGrupoProp.QuantidadeVidas__c;
//                     objGrupoContrato.TipoCalculo__c         = objGrupoProp.TipoCalculo__c;
//                     objGrupoContrato.PremioComercial__c     = objGrupoProp.PremioComercial__c;
//                     objGrupoContrato.PremioPuro__c          = objGrupoProp.PremioPuro__c;
//                     objGrupoContrato.PremioTotal__c         = objGrupoProp.PremioTotal__c;
//                     objGrupoContrato.TaxaComercial__c       = objGrupoProp.TaxaComercial__c;
//                     objGrupoContrato.TaxaPura__c            = objGrupoProp.TaxaPura__c;
//                     objGrupoContrato.TaxaTotal__c           = objGrupoProp.TaxaTotal__c;
//                     objGrupoContrato.DescontoAgravoPercentualTecnico__c      =  objGrupoProp.DescontoAgravoPercentualTecnico__c;
//                     objGrupoContrato.DescontoAgravoMonetarioTecnico__c       =  objGrupoProp.DescontoAgravoMonetarioTecnico__c;
//                     objGrupoContrato.DescontoAgravoPercentualComercial__c    =  objGrupoProp.DescontoAgravoPercentualComercial__c;
//                     objGrupoContrato.DescontoAgravoMonetarioComercial__c     =  objGrupoProp.DescontoAgravoMonetarioComercial__c;
//                     objGrupoContrato.DescontoAgravoPercentualInformado__c    =  objGrupoProp.DescontoAgravoPercentualInformado__c;
//                     objGrupoContrato.DescontoAgravoMonetarioInformado__c     =  objGrupoProp.DescontoAgravoMonetarioInformado__c;
// */
//                     mapGrupoContrato.put(objGrupoProp.Id, objGrupoContrato);
//                     lstGrupoContrato.add(objGrupoContrato);
//                 }
//                 catch(Exception e)
//                 {
//                     System.debug('ERRO MAPEAMENTO GRUPO : ' + e.getLineNumber() + ': ' + e.getMessage());
//                 }
//             }

//             insert lstGrupoContrato;
            
//             // SEGURADOS
//             for(SeguradoContrato__c objSeguradoProp : lstSeguradoContratoOriginal)
//             {
//                 SeguradoContrato__c objSeguradoContrato = new SeguradoContrato__c();

//                 try
//                 {
//                     objSeguradoContrato.GrupoContrato__c                   = mapGrupoContrato.get(objSeguradoProp.GrupoContrato__c).Id;
// /*
//                     objSeguradoContrato.Conta__c                           = objSeguradoProp.Conta__c;
//                     objSeguradoContrato.EnderecoBoleto__c                  = objSeguradoProp.EnderecoBoleto__c;
//                     objSeguradoContrato.FormaPagamento__c                  = objSeguradoProp.FormaPagamento__c;
//                     objSeguradoContrato.QuantidadeParcelas__c              = objSeguradoProp.QuantidadeParcelas__c;
//                     objSeguradoContrato.ResponsavelPagamento__c            = objSeguradoProp.ResponsavelPagamento__c;
//                     objSeguradoContrato.VencimentoPrimeiraParcela__c       = objSeguradoProp.VencimentoPrimeiraParcela__c;
//                     objSeguradoContrato.TipoResponsavelPagamento__c        = objSeguradoProp.TipoResponsavelPagamento__c;
//                     objSeguradoContrato.Numero__c                          = objSeguradoProp.Numero__c;
//                     objSeguradoContrato.PremioParcela__c                   = objSeguradoProp.PremioParcela__c;
//                     objSeguradoContrato.PorcentagemParticipacaoVida__c     = objSeguradoProp.PorcentagemParticipacaoVida__c;
//                     objSeguradoContrato.Reenquadramento__c                 = objSeguradoProp.Reenquadramento__c;
//                     objSeguradoContrato.PorcentagemParticipacaoSegurado__c = objSeguradoProp.PorcentagemParticipacaoSegurado__c;
//                     objSeguradoContrato.InformacaoBancaria__c              = objSeguradoProp.InformacaoBancaria__c;
//                     objSeguradoContrato.PlanoParcelamento__c               = objSeguradoProp.PlanoParcelamento__c;
//                     objSeguradoContrato.CartaoCredito__c                   = objSeguradoProp.CartaoCredito__c;
//                     objSeguradoContrato.TipoCusteio__c                     = objSeguradoProp.TipoCusteio__c;
//                     objSeguradoContrato.IOF__c                             = objSeguradoProp.IOF__c;
//                     objSeguradoContrato.IPCA__c                            = objSeguradoProp.IPCA__c;
//                     objSeguradoContrato.PremioComercial__c                 = objSeguradoProp.PremioComercial__c;
//                     objSeguradoContrato.PremioPuro__c                      = objSeguradoProp.PremioPuro__c;
//                     objSeguradoContrato.PremioTotal__c                     = objSeguradoProp.PremioTotal__c;
//                     objSeguradoContrato.TaxaComercial__c                   = objSeguradoProp.TaxaComercial__c;
//                     objSeguradoContrato.TaxaPura__c                        = objSeguradoProp.TaxaPura__c;
//                     objSeguradoContrato.TaxaTotal__c                       = objSeguradoProp.TaxaTotal__c;
//                     objSeguradoContrato.DescontoAgravoPercentualTecnico__c      =  objSeguradoProp.DescontoAgravoPercentualTecnico__c;
//                     objSeguradoContrato.DescontoAgravoMonetarioTecnico__c       =  objSeguradoProp.DescontoAgravoMonetarioTecnico__c;
//                     objSeguradoContrato.DescontoAgravoPercentualComercial__c    =  objSeguradoProp.DescontoAgravoPercentualComercial__c;
//                     objSeguradoContrato.DescontoAgravoMonetarioComercial__c     =  objSeguradoProp.DescontoAgravoMonetarioComercial__c;
//                     objSeguradoContrato.DescontoAgravoPercentualInformado__c    =  objSeguradoProp.DescontoAgravoPercentualInformado__c;
//                     objSeguradoContrato.DescontoAgravoMonetarioInformado__c     =  objSeguradoProp.DescontoAgravoMonetarioInformado__c;
//                     objSeguradoContrato.VigenciaInicial__c = objSeguradoProp.VigenciaInicial__c;
//                     objSeguradoContrato.VigenciaFinal__c = objSeguradoProp.VigenciaFinal__c;
//                     */
//                 }
//                 catch(Exception e)
//                 {
//                     System.debug('ERRO MAPEAMENTO SEGURADO2:' + e.getLineNumber() + ': ' + e.getMessage());
//                 }

//                 mapSeguradoContrato.put(objSeguradoProp.Id, objSeguradoContrato);
//                 lstSeguradoContrato.add(objSeguradoContrato);

//                 System.debug('Grupo Contrato');
//             }

//             insert lstSeguradoContrato;

//             // BENEFICIARIOS 
//             for(SeguradoContrato__c objSegurado : lstSeguradoContratoOriginal)
//             {
//                 for(BeneficiarioSeguradoContrato__c objBeneficiario : objSegurado.Benefici_rios_dos_segurados_do_contrato__r)
//                 {
//                     try
//                     {
//                         BeneficiarioSeguradoContrato__c objBeneficiarioSeguradoContrato = new BeneficiarioSeguradoContrato__c();

//                         objBeneficiarioSeguradoContrato.SeguradoContrato__c             = mapSeguradoContrato.get(objBeneficiario.SeguradoContrato__c).Id;
// /*
//                         objBeneficiarioSeguradoContrato.Conta__c                        = objBeneficiario.Conta__c;
//                         objBeneficiarioSeguradoContrato.CpfCnpj__c                      = objBeneficiario.CpfCnpj__c;
//                         objBeneficiarioSeguradoContrato.CpfPep__c                       = objBeneficiario.CpfPep__c;
//                         objBeneficiarioSeguradoContrato.GrauParentesco__c               = objBeneficiario.GrauParentescoPep__c;
//                         objBeneficiarioSeguradoContrato.GrauParentescoPep__c            = objBeneficiario.GrauParentescoPep__c;
//                         objBeneficiarioSeguradoContrato.ImprimirCertificadoSeguro__c    = objBeneficiario.ImprimirCertificadoSeguro__c;
//                         objBeneficiarioSeguradoContrato.MotivoSemCpfCnpj__c             = objBeneficiario.MotivoSemCpfCnpj__c;
//                         objBeneficiarioSeguradoContrato.Nome__c                         = objBeneficiario.Nome__c;
//                         objBeneficiarioSeguradoContrato.NomePessoaPep__c                = objBeneficiario.NomePessoaPep__c;
//                         objBeneficiarioSeguradoContrato.Participacao__c                 = objBeneficiario.Participacao__c;
//                         objBeneficiarioSeguradoContrato.Pep__c                          = objBeneficiario.Pep__c;
//                         objBeneficiarioSeguradoContrato.TipoBeneficiario__c             = objBeneficiario.TipoBeneficiario__c;
// */
//                         lstBeneficiarioSeguradoContrato.add(objBeneficiarioSeguradoContrato);

//                         System.debug('Beneficiario Vida Contrato');
//                     }
//                     catch(Exception e)
//                     {
//                         System.debug('ERRO mapeamento beneficiario:' + e.getLineNumber() + ': ' + e.getMessage());
//                     }
//                 }
//             }

//             insert lstBeneficiarioSeguradoContrato;        

//             // CRIAR GARANTIAS DO CONTRATO
//             for(GarantiaContrato__c objGarantiaProp : lstGarantiaContratoOriginal)
//             {
//                 try
//                 {
//                     GarantiaContrato__c objGarantiaContrato             = new GarantiaContrato__c();

//                     objGarantiaContrato.Contrato__c                     = objContratoClonado.Id;
//   /*
//                     objGarantiaContrato.Garantia__c                     = objGarantiaProp.Garantia__c;
//                     objGarantiaContrato.TipoCapital__c                  = objGarantiaProp.TipoCapital__c;
//                     objGarantiaContrato.LimiteCapital__c                = objGarantiaProp.LimiteCapital__c;
//                     objGarantiaContrato.GarantiaProduto__c              = objGarantiaProp.GarantiaProduto__c;
//                     objGarantiaContrato.Capital__c                      = objGarantiaProp.Capital__c;
//                     objGarantiaContrato.NumeroSorte__c                  = objGarantiaProp.NumeroSorte__c;
//                     objGarantiaContrato.NumeroSerie__c                  = objGarantiaProp.NumeroSerie__c;
//                     objGarantiaContrato.DataSorteio__c                  = objGarantiaProp.DataSorteio__c;
//                     objGarantiaContrato.DataSolicitacaoCapitalizacao__c = objGarantiaProp.DataSolicitacaoCapitalizacao__c;
//                     objGarantiaContrato.StatusCapitalizacao__c          = objGarantiaProp.StatusCapitalizacao__c;
//                     objGarantiaContrato.VersaoTitulo__c                 = objGarantiaProp.VersaoTitulo__c;
//                     objGarantiaContrato.NumeroTitulo__c                 = objGarantiaProp.NumeroTitulo__c;
//                     objGarantiaContrato.DataSorteio__c                  = objGarantiaProp.DataSorteio__c;
//                     objGarantiaContrato.LoteCapitalizacao__c            = objGarantiaProp.LoteCapitalizacao__c;
//                     objGarantiaContrato.GarantiaProduto__c              = objGarantiaProp.GarantiaProduto__c;
//                     objGarantiaContrato.PremioComercial__c     = objGarantiaProp.PremioComercial__c;
//                     objGarantiaContrato.PremioPuro__c          = objGarantiaProp.PremioPuro__c;
//                     objGarantiaContrato.PremioTotal__c         = objGarantiaProp.PremioTotal__c;
//                     objGarantiaContrato.TaxaComercial__c       = objGarantiaProp.TaxaComercial__c;
//                     objGarantiaContrato.TaxaPura__c            = objGarantiaProp.TaxaPura__c;
//                     objGarantiaContrato.TaxaTotal__c           = objGarantiaProp.TaxaTotal__c;
//                     objGarantiaContrato.DescontoAgravoPercentualTecnico__c      =  objGarantiaProp.DescontoAgravoPercentualTecnico__c;
//                     objGarantiaContrato.DescontoAgravoMonetarioTecnico__c       =  objGarantiaProp.DescontoAgravoMonetarioTecnico__c;
//                     objGarantiaContrato.DescontoAgravoPercentualComercial__c    =  objGarantiaProp.DescontoAgravoPercentualComercial__c;
//                     objGarantiaContrato.DescontoAgravoMonetarioComercial__c     =  objGarantiaProp.DescontoAgravoMonetarioComercial__c;
//                     objGarantiaContrato.DescontoAgravoPercentualInformado__c    =  objGarantiaProp.DescontoAgravoPercentualInformado__c;
//                     objGarantiaContrato.DescontoAgravoMonetarioInformado__c     =  objGarantiaProp.DescontoAgravoMonetarioInformado__c;
// */

//                     lstGarantiaContrato.add(objGarantiaContrato);
//                 }
//                 catch(Exception e)
//                 {
//                     System.debug('ERRO MAPEAMENTO GARANTIA : ' + e.getLineNumber() + ': ' + e.getMessage());
//                 }

//                 System.debug('Garantia Contrato');
//             }

//             insert lstGarantiaContrato; 
       

//             // GARANTIAS DO CONTRATANTE
//             for(GarantiaContratanteContrato__c objGarantiaContratanteProp : lstGarantiaContratanteContratoOriginal)
//             {
//                 try
//                 {
//                     GarantiaContratanteContrato__c objGarantiaContratanteContrato = new GarantiaContratanteContrato__c();
                    
//                     objGarantiaContratanteContrato.ContratanteContrato__c  = mapContratanteContrato.get(objGarantiaContratanteProp.ContratanteContrato__c).Id;
//   /*
//                     objGarantiaContratanteContrato.Garantia__c             = objGarantiaContratanteProp.Garantia__c;
//                     objGarantiaContratanteContrato.GarantiaProduto__c  = objGarantiaContratanteProp.GarantiaProduto__c;
//                     objGarantiaContratanteContrato.Capital__c          = objGarantiaContratanteProp.Capital__c;
//                     objGarantiaContratanteContrato.NumeroSorte__c      = objGarantiaContratanteProp.NumeroSorte__c;
//                     objGarantiaContratanteContrato.NumeroSerie__c      = objGarantiaContratanteProp.NumeroSerie__c;
//                     objGarantiaContratanteContrato.PremioComercial__c     = objGarantiaContratanteProp.PremioComercial__c;
//                     objGarantiaContratanteContrato.PremioPuro__c          = objGarantiaContratanteProp.PremioPuro__c;
//                     objGarantiaContratanteContrato.PremioTotal__c         = objGarantiaContratanteProp.PremioTotal__c;
//                     objGarantiaContratanteContrato.TaxaComercial__c       = objGarantiaContratanteProp.TaxaComercial__c;
//                     objGarantiaContratanteContrato.TaxaPura__c            = objGarantiaContratanteProp.TaxaPura__c;
//                     objGarantiaContratanteContrato.TaxaTotal__c           = objGarantiaContratanteProp.TaxaTotal__c;

//                     objGarantiaContratanteContrato.DescontoAgravoPercentualTecnico__c      =  objGarantiaContratanteProp.DescontoAgravoPercentualTecnico__c;
//                     objGarantiaContratanteContrato.DescontoAgravoMonetarioTecnico__c       =  objGarantiaContratanteProp.DescontoAgravoMonetarioTecnico__c;
//                     objGarantiaContratanteContrato.DescontoAgravoPercentualComercial__c    =  objGarantiaContratanteProp.DescontoAgravoPercentualComercial__c;
//                     objGarantiaContratanteContrato.DescontoAgravoMonetarioComercial__c     =  objGarantiaContratanteProp.DescontoAgravoMonetarioComercial__c;
//                     objGarantiaContratanteContrato.DescontoAgravoPercentualInformado__c    =  objGarantiaContratanteProp.DescontoAgravoPercentualInformado__c;
//                     objGarantiaContratanteContrato.DescontoAgravoMonetarioInformado__c     =  objGarantiaContratanteProp.DescontoAgravoMonetarioInformado__c;
// */
//                     lstGarantiaContratanteContrato.add(objGarantiaContratanteContrato);

//                 }
//                 catch(Exception e)
//                 {
//                     System.debug('ERRO MAPEAMENTO GARANTIA : ' + e.getLineNumber() + ': ' + e.getMessage());
//                 }

//                 System.debug('Garantia Contrato');
//             }

//             insert lstGarantiaContratanteContrato;
             

//             //---- GARANTIAS DO GRUPO 
//             for(GarantiaGrupoContrato__c objGarantiaGrupoProp : lstGarantiaGrupoContratoOriginal)
//             {
//                 try
//                 {
//                     GarantiaGrupoContrato__c objGarantiaGrupoContrato = new GarantiaGrupoContrato__c();

//                     objGarantiaGrupoContrato.GrupoContrato__c       = mapGrupoContrato.get(objGarantiaGrupoProp.GrupoContrato__c).Id;
//   /*                
//                     objGarantiaGrupoContrato.Capital__c              = objGarantiaGrupoProp.Capital__c;
//                     objGarantiaGrupoContrato.GarantiaReferenciada__c = objGarantiaGrupoProp.GarantiaReferenciada__c;
//                     objGarantiaGrupoContrato.Garantia__c             = objGarantiaGrupoProp.Garantia__c;
//                     objGarantiaGrupoContrato.GarantiaProduto__c      = objGarantiaGrupoProp.GarantiaProduto__c;
//                     objGarantiaGrupoContrato.Percentual__c           = objGarantiaGrupoProp.Percentual__c;
//                     objGarantiaGrupoContrato.Valor__c                = objGarantiaGrupoProp.Valor__c;
//                     objGarantiaGrupoContrato.ValorCotacao__c         = objGarantiaGrupoProp.ValorCotacao__c;
//                     objGarantiaGrupoContrato.NumeroSerie__c          = objGarantiaGrupoProp.NumeroSerie__c;
//                     objGarantiaGrupoContrato.NumeroSorte__c          = objGarantiaGrupoProp.NumeroSorte__c;                   
//                     objGarantiaGrupoContrato.PremioPuro__c           = objGarantiaGrupoProp.PremioPuro__c;
//                     objGarantiaGrupoContrato.PremioComercial__c      = objGarantiaGrupoProp.PremioComercial__c;
//                     objGarantiaGrupoContrato.PremioTotal__c          = objGarantiaGrupoProp.PremioTotal__c;
//                     objGarantiaGrupoContrato.TaxaPura__c             = objGarantiaGrupoProp.TaxaPura__c;
//                     objGarantiaGrupoContrato.TaxaComercial__c        = objGarantiaGrupoProp.TaxaComercial__c;
//                     objGarantiaGrupoContrato.TaxaTotal__c            = objGarantiaGrupoProp.TaxaTotal__c;
//                     objGarantiaGrupoContrato.DescontoAgravoPercentualTecnico__c      =  objGarantiaGrupoProp.DescontoAgravoPercentualTecnico__c;
//                     objGarantiaGrupoContrato.DescontoAgravoMonetarioTecnico__c       =  objGarantiaGrupoProp.DescontoAgravoMonetarioTecnico__c;
//                     objGarantiaGrupoContrato.DescontoAgravoPercentualComercial__c    =  objGarantiaGrupoProp.DescontoAgravoPercentualComercial__c;
//                     objGarantiaGrupoContrato.DescontoAgravoMonetarioComercial__c     =  objGarantiaGrupoProp.DescontoAgravoMonetarioComercial__c;
//                     objGarantiaGrupoContrato.DescontoAgravoPercentualInformado__c    =  objGarantiaGrupoProp.DescontoAgravoPercentualInformado__c;
//                     objGarantiaGrupoContrato.DescontoAgravoMonetarioInformado__c     =  objGarantiaGrupoProp.DescontoAgravoMonetarioInformado__c;
// */

//                     lstGarantiaGrupoContrato.add(objGarantiaGrupoContrato);

//                     System.debug('Garantia Grupo Contrato');
//                 }
//                 catch(Exception e)
//                 {
//                     System.debug('ERRO:' + e.getLineNumber() + ': ' + e.getMessage());
//                 }
//             }

//             insert lstGarantiaGrupoContrato;
                

//             //----- GARANTIAS DO SEGURADO
//             System.debug('==> JJ Inicio SeguradoContrato:');
//             for(GarantiaSeguradoContrato__c objGarantiaSegProp : lstGarantiaSeguradoContratoOriginal)
//             {
//                 try
//                 {
//                     GarantiaSeguradoContrato__c objGarantiaSegContrato = new GarantiaSeguradoContrato__c();

//                     objGarantiaSegContrato.SeguradoContrato__c     = mapSeguradoContrato.get(objGarantiaSegProp.SeguradoContrato__c).Id;

// /*                
//                     objGarantiaSegContrato.Capital__c              = objGarantiaSegProp.Capital__c;
//                     objGarantiaSegContrato.Garantia__c             = objGarantiaSegProp.Garantia__c;
//                     objGarantiaSegContrato.GarantiaProduto__c      = objGarantiaSegProp.GarantiaProduto__c;
//                     objGarantiaSegContrato.Percentual__c           = objGarantiaSegProp.Percentual__c;
//                     objGarantiaSegContrato.Valor__c                = objGarantiaSegProp.Valor__c;
//                     objGarantiaSegContrato.ValorCotacao__c         = objGarantiaSegProp.ValorCotacao__c;
//                     objGarantiaSegContrato.NumeroSerie__c          = objGarantiaSegProp.NumeroSerie__c;
//                     objGarantiaSegContrato.NumeroSorte__c          = objGarantiaSegProp.NumeroSorte__c;
                    
//                     objGarantiaSegContrato.PremioPuro__c           = objGarantiaSegProp.PremioPuro__c;
//                     objGarantiaSegContrato.PremioComercial__c      = objGarantiaSegProp.PremioComercial__c;
//                     objGarantiaSegContrato.PremioTotal__c          = objGarantiaSegProp.PremioTotal__c;
//                     objGarantiaSegContrato.TaxaPura__c             = objGarantiaSegProp.TaxaPura__c;
//                     objGarantiaSegContrato.TaxaComercial__c        = objGarantiaSegProp.TaxaComercial__c;
//                     objGarantiaSegContrato.TaxaTotal__c            = objGarantiaSegProp.TaxaTotal__c;


//                     objGarantiaSegContrato.DescontoAgravoPercentualTecnico__c      =  objGarantiaSegProp.DescontoAgravoPercentualTecnico__c;
//                     objGarantiaSegContrato.DescontoAgravoMonetarioTecnico__c       =  objGarantiaSegProp.DescontoAgravoMonetarioTecnico__c;
//                     objGarantiaSegContrato.DescontoAgravoPercentualComercial__c    =  objGarantiaSegProp.DescontoAgravoPercentualComercial__c;
//                     objGarantiaSegContrato.DescontoAgravoMonetarioComercial__c     =  objGarantiaSegProp.DescontoAgravoMonetarioComercial__c;
//                     objGarantiaSegContrato.DescontoAgravoPercentualInformado__c    =  objGarantiaSegProp.DescontoAgravoPercentualInformado__c;
//                     objGarantiaSegContrato.DescontoAgravoMonetarioInformado__c     =  objGarantiaSegProp.DescontoAgravoMonetarioInformado__c;
// */
//                     lstGarantiaSeguradoContrato.add(objGarantiaSegContrato);

//                     System.debug('Garantia Grupo Contrato');
//                 }
//                 catch(Exception e)
//                 {
//                     System.debug('ERRO:' + e.getLineNumber() + ': ' + e.getMessage());
//                 }
//             }


//             insert lstGarantiaSeguradoContrato;
            
//             //---------  REMUNERAÇÔES

//             Map<Id, RemuneracaoContrato__c> mapRemsContrato = new Map<Id, RemuneracaoContrato__c>();
//             for(RemuneracaoContrato__c objRemuneracao : lstRemuneracaoOriginal)
//             {
//                 RemuneracaoContrato__c objRemuneracaoContrato = new RemuneracaoContrato__c();

//                 objRemuneracaoContrato.Contrato__c          = objContratoClonado.Id;
// /*
//                 objRemuneracaoContrato.Percentual__c        = objRemuneracao.Percentual__c;
//                 objRemuneracaoContrato.RemuneracaoProduto__c= objRemuneracao.RemuneracaoProduto__c;
//                 objRemuneracaoContrato.TipoRemuneracao__c   = objRemuneracao.TipoRemuneracao__c;
// */
//                 lstRemuneracaoContrato.add(objRemuneracaoContrato);

//                 mapRemsContrato.put(objRemuneracao.Id, objRemuneracaoContrato);

//                 System.debug('Remuneracao Proposta');
//             }

//             insert mapRemsContrato.values();

//             for(RemuneracaoContrato__c objRemuneracao : lstRemuneracaoOriginal)
//             {
//                 RemuneracaoContrato__c objRemuneracaoContrato = mapRemsContrato.get(objRemuneracao.Id);

//                 for(FavorecidoRemuneracaoContrato__c objFavorecido : objRemuneracao.FavorecidosContrato__r)
//                 {
//                     FavorecidoRemuneracaoContrato__c objFavorecidoRemuneracaoContrato = new FavorecidoRemuneracaoContrato__c();


//                     objFavorecidoRemuneracaoContrato.Conta__c                   = objFavorecido.Conta__c;
//                     objFavorecidoRemuneracaoContrato.RemuneracaoContrato__c     = objRemuneracaoContrato.Id;
// /*
//                     objFavorecidoRemuneracaoContrato.DadosCorretor__c           = objFavorecido.DadosCorretor__c;
//                     objFavorecidoRemuneracaoContrato.CorretorLider__c           = objFavorecido.CorretorLider__c;
//                     objFavorecidoRemuneracaoContrato.Papel__c                   = objFavorecido.Papel__c;
//                     objFavorecidoRemuneracaoContrato.Participacao__c            = objFavorecido.Participacao__c;
//                     objFavorecidoRemuneracaoContrato.Susep__c                   = objFavorecido.Susep__c;
//                     objFavorecidoRemuneracaoContrato.SusepEmissao__c            = objFavorecido.SusepEmissao__c;
//                     objFavorecidoRemuneracaoContrato.SusepOficialCorretor__c    = objFavorecido.SusepOficialCorretor__c;
//                     objFavorecidoRemuneracaoContrato.SusepOrcamento__c          = objFavorecido.SusepOrcamento__c;
// */
//                     lstFavorecidosContrato.add(objFavorecidoRemuneracaoContrato);
//                 }
//             }

//             insert lstFavorecidosContrato;

//             // ----  Critica do Contrato
//             for(CriticaContrato__c objCritica : lstCriticaOriginal)
//             {
//                 CriticaContrato__c objCriticaContrato = new CriticaContrato__c();

//                 try
//                 {
//                     objCriticaContrato.Contrato__c              = objContratoClonado.Id;
//   /*
//                     objCriticaContrato.Codigo__c                = objCritica.Codigo__c;
//                     objCriticaContrato.DataConclusao__c         = objCritica.DataConclusao__c;
//                     objCriticaContrato.Descricao__c             = objCritica.Descricao__c;
//                     objCriticaContrato.MensagemCliente__c       = objCritica.MensagemCliente__c;
//                     objCriticaContrato.MensagemInterna__c       = objCritica.MensagemInterna__c;
//                     objCriticaContrato.MensagemRepresentante__c = objCritica.MensagemRepresentante__c;
//                     objCriticaContrato.Origem__c                = objCritica.Origem__c;
//                     objCriticaContrato.Procedimento__c          = objCritica.Procedimento__c;
//                     objCriticaContrato.Severidade__c            = objCritica.Severidade__c;
//                     objCriticaContrato.Status__c                = objCritica.Status__c;
//                     objCriticaContrato.Tipo__c                  = objCritica.Tipo__c;
//                     objCriticaContrato.Area__c                  = objCritica.Area__c;
// */
//                     lstCriticaContrato.add(objCriticaContrato);
//                 }
//                 catch(Exception e)
//                 {
//                     System.debug('ERRO MAPEAMENTO CRITICA:' + e.getLineNumber() + ': ' + e.getMessage());
//                 }

//                 System.debug('Critica Proposta');
//             }
           
            
//             insert lstCriticaContrato; 
//         }
//         catch(Exception e)
//         {
//             System.debug('ERRO MAPEAMENTO ERIC:' + e.getLineNumber() + ': ' + e.getMessage());
//         }

//         return objContratoClonado.Id;

//     }



}