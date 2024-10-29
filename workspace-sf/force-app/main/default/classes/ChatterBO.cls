/**
 * Regras de Negócio do Chatter
 * @author Fernando Barcellos @ 05/12/2017
 *
 **/
public class ChatterBO {
	public static void publicarItemFeed(String mensagem, List<User> usuariosParaNotificar) {
		String virgula = ', ';
		String doisPontos = ': ';
		String apelidoUsuarioIntegracao = 'int';
		
		ConnectApi.FeedItemInput feedItemInput = new ConnectApi.FeedItemInput();
		ConnectApi.MentionSegmentInput mentionSegmentInput = new ConnectApi.MentionSegmentInput();
		ConnectApi.TextSegmentInput textSegmentInput = new ConnectApi.TextSegmentInput();
		ConnectApi.TextSegmentInput segmentoVirgula = new ConnectApi.TextSegmentInput(); segmentoVirgula.text = virgula;
		ConnectApi.TextSegmentInput segmentoDoisPontos = new ConnectApi.TextSegmentInput(); segmentoDoisPontos.text = doisPontos;
		ConnectApi.MarkupBeginSegmentInput markupBeginSegment = new ConnectApi.MarkupBeginSegmentInput(); markupBeginSegment.markupType = ConnectApi.MarkupType.Paragraph;
		ConnectApi.MarkupEndSegmentInput markupEndSegment = new ConnectApi.MarkupEndSegmentInput(); markupEndSegment.markupType = ConnectApi.MarkupType.Paragraph;
		ConnectApi.MessageBodyInput messageBodyInput = new ConnectApi.MessageBodyInput();
		messageBodyInput.messageSegments = new List<ConnectApi.MessageSegmentInput>();

		List<ConnectApi.MentionSegmentInput> lstMencoes = new List<ConnectApi.MentionSegmentInput>();

		for (User usuario : usuariosParaNotificar) {
			ConnectApi.MentionSegmentInput temp = new ConnectApi.MentionSegmentInput();
			temp.Id = usuario.Id;
			lstMencoes.add(temp);
		}

		Integer contador = 0;
		Integer tamanhoMaximoListaMencoes = lstMencoes.size();
		messageBodyInput.messageSegments.add(markupBeginSegment);
		for (ConnectApi.MentionSegmentInput segmentoMencao : lstMencoes) {
			messageBodyInput.messageSegments.add(segmentoMencao);
			contador++;
			if (contador < tamanhoMaximoListaMencoes) {
				messageBodyInput.messageSegments.add(segmentoVirgula);
			}
			else {
				messageBodyInput.messageSegments.add(segmentoDoisPontos);
			}
		}
		messageBodyInput.messageSegments.add(markupEndSegment);

		textSegmentInput.text = mensagem;

		messageBodyInput.messageSegments.add(markupBeginSegment);
		messageBodyInput.messageSegments.add(textSegmentInput);
		messageBodyInput.messageSegments.add(markupEndSegment);

		ConnectApi.LinkSegmentInput linkPainelIntegracoes = new ConnectApi.LinkSegmentInput();

		if (!Test.isRunningTest()) {
			linkPainelIntegracoes = montarSegmentoUrl(DashboardBO.getInstance().buscarDashboardIntegracao().Id);
		}
		else {
			linkPainelIntegracoes = montarSegmentoUrl(UserInfo.getUserId());
		}
		//
		messageBodyInput.messageSegments.add(markupBeginSegment);
		messageBodyInput.messageSegments.add(markupEndSegment);
		//
		messageBodyInput.messageSegments.add(markupBeginSegment);
		messageBodyInput.messageSegments.add(linkPainelIntegracoes);
		messageBodyInput.messageSegments.add(markupEndSegment);

		feedItemInput.body = messageBodyInput;
		feedItemInput.feedElementType = ConnectApi.FeedElementType.FeedItem;
		feedItemInput.subjectId = UserBO.getInstance().buscarUsuarioIntegracao().Id;

		if (!Test.isRunningTest()) {
			ConnectApi.ChatterFeeds.postFeedElement(Network.getNetworkId(), feedItemInput);
		}
	}

	private static ConnectApi.LinkSegmentInput montarSegmentoUrl(Id idPainel) {
		ConnectApi.LinkSegmentInput temp = new ConnectApi.LinkSegmentInput();
		temp.url = URL.getSalesforceBaseUrl().toExternalForm() + '/' + idPainel;
		return temp;
	}
}