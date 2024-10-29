/**
 * Regras de Negócio do objeto Dashboard
 * @author Fernando Barcellos @ 05/12/2017
 *
 **/
public class DashboardBO {
	private static final DashboardBO instance = new DashboardBO();

	private DashboardBO() { }

	public static DashboardBO getInstance() {
		return instance;
	}

	public Dashboard buscarDashboardPorTitulo(String titulo) {
		return DashboardDAO.getInstance().buscarDashboardPorTitulo(titulo);
	}

	public Dashboard buscarDashboardIntegracao() {
		return buscarDashboardPorTitulo('Painel de Integrações');
	}

}