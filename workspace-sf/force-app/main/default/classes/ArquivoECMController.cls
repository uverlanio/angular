/*
Created by Fábio Rente on 10/04/2019.
*/
public with sharing class ArquivoECMController {

	public static ContractBO bo = ContractBO.getInstance();
	private static PdfEcmBO objPdfEcmBO = PdfEcmBO.getInstance();

	@AuraEnabled
	public static String consultarArquivoECM(String consultarArquivoECMTOString){
		ContratoTO.ConsultarArquivoECMTO consultarArquivoECMTO = (ContratoTO.ConsultarArquivoECMTO ) JSON.deserialize( consultarArquivoECMTOString, ContratoTO.ConsultarArquivoECMTO.class );
		return JSON.serialize(bo.consultarArquivoECM(consultarArquivoECMTO));
	}
	
	@AuraEnabled
	public static String buscarDominioSf(){
		return objPdfEcmBO.buscarDominioSf();
	}

	// PLV-1393 - Início
  @AuraEnabled
  public static String buscaIdECM(String codigoECMString){

    List<Constante__mdt> constante = MetadataDAO.getInstance().buscarConstante('ECM_Pasta_Operacao_Produto_Parceiro');
    String pastaOperacaoProdutoParceiro = constante[0].Valor__c;

    String[] aryCodigoECM = codigoECMString.split('_');
    String strCNPJ = aryCodigoECM[0];
    String strDataTrocaArquivo = aryCodigoECM[1];
    String strLote = aryCodigoECM[2];
    String strTipoArquivo = aryCodigoECM[3];

    EcmService.BuscarDocumentoIdEntradaTO buscarDocumentoIdEntradaTO = new EcmService.BuscarDocumentoIdEntradaTO();
    buscarDocumentoIdEntradaTO.attrList = new List<EcmService.AttrList>();
    
    EcmService.AttrList arrListCNPJ = new EcmService.AttrList();
    arrListCNPJ.attr = pastaOperacaoProdutoParceiro + '_2';
    arrListCNPJ.valor = strCNPJ;
    buscarDocumentoIdEntradaTO.attrList.add(arrListCNPJ);

    EcmService.AttrList arrListDataTrocaArquivo = new EcmService.AttrList();
    arrListDataTrocaArquivo.attr = pastaOperacaoProdutoParceiro + '_3';
    arrListDataTrocaArquivo.valor = strDataTrocaArquivo;
    buscarDocumentoIdEntradaTO.attrList.add(arrListDataTrocaArquivo);

    EcmService.AttrList arrListLote = new EcmService.AttrList();
    arrListLote.attr = pastaOperacaoProdutoParceiro + '_4';
    arrListLote.valor = strLote;
    buscarDocumentoIdEntradaTO.attrList.add(arrListLote);

    EcmService.AttrList arrListTipoArquivo = new EcmService.AttrList();
    arrListTipoArquivo.attr = pastaOperacaoProdutoParceiro + '_5';
    arrListTipoArquivo.valor = strTipoArquivo;
    buscarDocumentoIdEntradaTO.attrList.add(arrListTipoArquivo);

    EcmService.RetornoDocumentoIdEntradaTO retornoDocumentoIdEntradaTO = EcmService.getInstance().buscarDocumentoId(buscarDocumentoIdEntradaTO);
    return retornoDocumentoIdEntradaTO.id;


  }
  // PLV-1393 - Final

}