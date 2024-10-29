global class IntegradorRequest 
{
	private static final IntegradorRequest instance = new IntegradorRequest();
	public IntegradorRequest() {}
	public static IntegradorRequest getInstance() 
	{
		return instance;
	}

	public HttpResponse sendRequest(String token, String method, String jsonBody, String EndPoint, String type, List<Header> headers) 
	{
		//Webservices__mdt metadataConfContaWs = CustomMetadataTypesDAO.getInstance().obtemConfiguracaoWS(method);

		Http 		httpClient 	= new Http();
		HttpRequest request 	= new HttpRequest();

		request.setEndpoint(EndPoint);
		request.setMethod(type);
		request.setHeader('Content-Type', 'application/json');
		//request.setHeader('cache-control', 'no-cache');

		for(Header item : headers)
			request.setHeader(item.key, item.value);
		
		if(!String.isBlank(token))
		{
			System.debug('insere token');
			request.setHeader('Authorization', token);
		}
		if(!String.isBlank(jsonBody))
		{
			System.debug('insere body');
			request.setBody(jsonBody);
			System.debug('#Request Body: ' + jsonBody);
		}

		HttpResponse response = httpClient.send(request);
		response.setBody(response.getBody());
		System.debug('#Response Body: ' + response.getBody());
		return response;
	}

	public class Header
	{
		public String key {get; set;}
		public String value {get; set;}
	}
}