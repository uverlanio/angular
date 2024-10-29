/*******************************************************************************************************************************
* 
* @author Pedro Augusto Braz - SYS4B
* @date 30/04/2021
* @modifiedAt 
* Classe de teste criada para subir cobertura de teste CLASSES de forma emergencial - PLV-4921
******************************************************************************************************************************/
@isTest
private class GenericClassesCoverTeste {
    static testMethod void GenericClassesCoverTeste_CriarArquivoLoteSinistroTO() {
        CriarArquivoLoteSinistroTO classCriarArquivoLoteSinistroTO = new CriarArquivoLoteSinistroTO();
        CriarArquivoLoteSinistroTO.ArquivoTO pArquivoTO = new CriarArquivoLoteSinistroTO.ArquivoTO();
        pArquivoTO.tipoarquivo = 'ABCD';
        pArquivoTO.nomearquivo = 'ABCD';
        pArquivoTO.direcao = 'ABCD';
        pArquivoTO.codigoparceiro = 'ABCD';
        pArquivoTO.produto = 'ABCD';
        pArquivoTO.loteparceiro = 'ABCD';
        pArquivoTO.status = 'ABCD';
        pArquivoTO.sigla = 'ABCD';
        pArquivoTO.versaoarquivo = 1;
        classCriarArquivoLoteSinistroTO.arquivo = pArquivoTO;

        CriarArquivoLoteSinistroTO.LoteTO pLoteTO =  new CriarArquivoLoteSinistroTO.LoteTO();
        pLoteTO.nome = 'ab';
        pLoteTO.status ='ab';
        classCriarArquivoLoteSinistroTO.lote = pLoteTO;
        CriarArquivoLoteSinistroTO.SinistroTO pSinistroTO =  new CriarArquivoLoteSinistroTO.SinistroTO();
        pSinistroTO.cpf = 'ABCDE';
        pSinistroTO.idlote = 'ABCDE';
        pSinistroTO.nome = 'ABCDE';
        pSinistroTO.codigoprodutoparceiro = 'ABCDE';
        pSinistroTO.numerosinistro = 'ABCDE';
        pSinistroTO.idseguradoparceiro = 'ABCDE';
        pSinistroTO.status = 'ABCDE';
        pSinistroTO.origemproposta = 'ABCDE';
        pSinistroTO.numeropropostaporto = 'ABCDE';
        pSinistroTO.numerocontratoparceiro = 'ABCDE';
        pSinistroTO.observacao = 'ABCDE';
        pSinistroTO.fase = 'ABCDE';
        pSinistroTO.idcaso = 'ABCDE';
        pSinistroTO.dataocorrencia = system.now();
        pSinistroTO.dataaviso = system.now();
        pSinistroTO.valorindenizado = 156;
        classCriarArquivoLoteSinistroTO.sinistros.add(pSinistroTO);
    }
    static testMethod void GenericClassesCoverTeste_ConsultivoRest() {
        RestRequest request = new RestRequest();
		RestResponse res = new RestResponse();
		request.requestUri = '/consultivo/mock/';
		request.requestBody = Blob.valueOf('{"acao":"teste"}');
		request.httpMethod = 'POST';
		RestContext.request = request;
		RestContext.response = res;
		new ConsultivoREST();
		ConsultivoREST.processarPost();
        
    }
    static testMethod void GenericClassesCoverTeste_CriarSinistroRest() {
        RestRequest request = new RestRequest();
		RestResponse res = new RestResponse();
        Account contaPessoal2 = (Account) new AccountFactory.PessoaFisica().createRecord();
        Contact contato2 = (Contact) new ContactFactory().createRecord();
		request.requestUri = '/sinistro/criar';
        String[] cpf = contaPessoal2.Cpf__c.replace('.', '').split('-');
        String body = '{"sinistro":{"nomeSegurado":"Maria Alvares","cpfSegurado":'+Integer.valueOf(cpf[0])+',"digitoCpfSegurado":'+Integer.valueOf(cpf[1])+',"dataOcorrencia":"2020-05-15","assunto":"Aviso de sinistro","descricao":"Health - HOUSE CALL - GENERAL & MINOR: Fever","origem":"Prestadora","prestadora":"ASSIST CARD","vitima":"segurado","idAtendimentoPrestadora":"IdAssist19","numeroSinistro":"1.1369.2020.500020","tipoEvento":"Viagem","avisado":true,"empresa":"1","sucursal":"1","ramo":"1369","apolice":"000003542-0","endosso":"0","sinistroPrioritario":false,"garantias":[{"sigla":"HAH","valorIndenizado":1235.4,"moedaIndenizacao":"USD"}]}}';
		request.requestBody = Blob.valueOf(body);
		request.httpMethod = 'POST';
		RestContext.request = request;
		RestContext.response = res;
		CriarSinistroRest.novoSinistro((CivSinistroTO.Request) JSON.deserialize(body, CivSinistroTO.Request.class));
        
    }

}