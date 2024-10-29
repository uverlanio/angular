public class PdfEcmController {
	private static PdfEcmBO objPdfEcmBO = PdfEcmBO.getInstance();
	
	@AuraEnabled
  	public static String buscarDominioSf(){
  		return objPdfEcmBO.buscarDominioSf();
  	}

  	@AuraEnabled
  	public static String buscarCodigoEcmDocumento(String objetoId){
  		return objPdfEcmBO.buscarCodigoEcmDocumento(objetoId);
  	}
}