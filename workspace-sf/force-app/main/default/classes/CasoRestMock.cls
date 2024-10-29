/**
 * @author AVX - Daniel Zampieri
 * @date 2019-03-28
 * @description CasoRest Classe de Mock
 */
@isTest
global class CasoRestMock implements HttpCalloutMock{
	global HTTPResponse respond(HTTPRequest req){
		Account contaPessoal2 = (Account) new AccountFactory.PessoaFisica().createRecord();
		Garantia__c garantia2 = (Garantia__c) new GarantiaFactory().createRecord();
		
		ContadorCodigo__c contCodigoTec2 = (ContadorCodigo__c) new ContadorCodigoFactory.ProdutoTecnico().createRecord();
        ContadorCodigo__c contCodigoCom2 = (ContadorCodigo__c) new ContadorCodigoFactory.ProdutoComercial().createRecord();
        Product2 produtoTecnico2 = (Product2) new ProdutoFactory.ProdutoTecnico().createRecord();
        produtoTecnico2.Status__c = 'Ativo';
        update produtoTecnico2;
        Product2 produtoComercial2 = (Product2) new ProdutoFactory.ProdutoComercial(produtoTecnico2).createRecord();

        FormaPagamento__c formaPagamento2 = (FormaPagamento__c) new FormaPagamentoFactory().createRecord();
        Parceiro__c parceiro2 = (Parceiro__c) new ParceiroFactory(contaPessoal2, formaPagamento2).createRecord();
        ProdutoParceiro__c prodParc2 = (ProdutoParceiro__c) new ProdutoParceiroFactory(parceiro2, produtoComercial2).createRecord();
        OperacaoProdutoParceiro__c oProdParc2 = (OperacaoProdutoParceiro__c) new OperacaoProdutoParceiroFactory(prodParc2).createRecord();

        Contact contato2 = (Contact) new ContactFactory().createRecord();
        Contract contrato2 = (Contract) new ContratoFactory.ContratoFactoryComParam(contaPessoal2, produtoComercial2, parceiro2).createRecord();
        ContratanteContrato__c contratante2 = (ContratanteContrato__c) new ContratanteFactory(contrato2).createRecord();
        GrupoContrato__c grupo2 = (GrupoContrato__c) new GrupoFactory(contratante2).createRecord();
        SeguradoContrato__c segurado2 = (SeguradoContrato__c) new SeguradoContratoFactory(contaPessoal2, grupo2).createRecord();
        GarantiaSeguradoContrato__c garantiaSegurado2 = (GarantiaSeguradoContrato__c) new GarantiaSeguradoContratoFactory(segurado2, garantia2).createRecord();
		
		Case casoAtendimento3 = (Case) new CasoFactory.AtendimentoSinistro().createRecord();
        
        Case casoSinistro2 = (Case) new CasoFactory.Sinistro(casoAtendimento3, contaPessoal2).createRecord();	

			casoSinistro2.ContactId = contato2.id;
            casoSinistro2.Contrato__c = contrato2.id;
            casoSinistro2.Garantia_do_segurado_do_contrato__c = garantiaSegurado2.id;
            casoSinistro2.NumeroSinistro__c = '321';
            casoSinistro2.Data_sinistro_avisado__c = System.today();
            casoSinistro2.Status = 'Avisado';
            casoSinistro2.Status_Dependente__c = 'Em Análise';
            casoSinistro2.Segurado_do_Contrato__c = segurado2.id;
            update casoSinistro2;

            casoSinistro2.Status = 'Em Regulação';
            update casoSinistro2;

            PagamentoGarantia__c pag = (PagamentoGarantia__c) new PagamentoGarantiaFactory(casoSinistro2, garantiaSegurado2).createRecord();
            pag.Fase__c = 'Em Análise';
            pag.Status_do_pagamento__c = 'Em Análise';
            update pag;

		InformacaoBancaria__c infoBan = (InformacaoBancaria__c) new InformacaoBancariaFactory.InfoPessoaFisica().createRecord();
		BeneficiarioGarantia__c beneGaran = (BeneficiarioGarantia__c) new BeneficiarioGarantiaFactory.BenePessoaFisica(contaPessoal2, infoBan, pag).createRecord();
		HTTPResponse res = new HttpResponse();

      //PLV-2285 - Início - Código alterado para aumento de cobertura na classe de teste
        if (req.getBody() == 'PAGO') {
            res.setHeader('Content-Type', 'application/json');
            res.setBody('[{"id":1,"idconta":"0010j00000FHy4vAAD","idobjeto": "'+ beneGaran.id + '","dataprogramadapagamento":null,"datapagamento":"2019-05-06T00:00:00Z","dataatualizacao":null,"valorpagamento":"100.00000","status":"PAGO","motivo":null}]');
            res.setStatusCode(200);
        }else if(req.getBody() == 'ERRO'){
            res.setHeader('Content-Type', 'application/json');
            res.setBody('[{"id":1,"idconta":"0010j00000FHy4vAAD","idobjeto": "'+ beneGaran.id + '","dataprogramadapagamento":null,"datapagamento":"2019-05-06T00:00:00Z","dataatualizacao":null,"valorpagamento":"100.00000","status":"ERRO","motivo":null}]');
            res.setStatusCode(200);
        }else if(req.getBody() == 'CANCELADO'){
            res.setHeader('Content-Type', 'application/json');
            res.setBody('[{"id":1,"idconta":"0010j00000FHy4vAAD","idobjeto": "'+ beneGaran.id + '","dataprogramadapagamento":null,"datapagamento":"2019-05-06T00:00:00Z","dataatualizacao":null,"valorpagamento":"100.00000","status":"CANCELADO","motivo":null}]');
            res.setStatusCode(200);
        }else if(req.getBody() == 'POST'){
            res.setHeader('Content-Type', 'application/json');
            res.setBody('[{"id":1,"idconta":"0010j00000FHy4vAAD","idobjeto": "'+ beneGaran.id + '","dataprogramadapagamento":null,"datapagamento":"2019-05-06T00:00:00Z","dataatualizacao":null,"valorpagamento":"100.00000","status":"PAGO","motivo":null}]');
            res.setStatusCode(200);
        }
	//PLV-2285 - Fim - Código alterado para aumento de cobertura na classe de teste
		return res;
	}
}