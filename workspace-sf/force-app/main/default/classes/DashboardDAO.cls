/**
 * Camada de abstração de dados do Dashboard
 * @author Fernando Barcellos @ 05/12/2017
 *
 **/
public class DashboardDAO {
	private static final DashboardDAO instance = new DashboardDAO();

	private DashboardDAO() { }

	public static DashboardDAO getInstance() {
		return instance;
	}

	public Dashboard buscarDashboardPorTitulo(String titulo) {
		return buscarDashboardPorTitulo(new Set<String> { titulo })[0];
	}

	public List<Dashboard> buscarDashboardPorTitulo(Set<String> lstTitulos) {
		return [
			SELECT
				Id,
				Title,
				DeveloperName
			FROM
				Dashboard
			WHERE
				Title IN :lstTitulos
		];
	}

}