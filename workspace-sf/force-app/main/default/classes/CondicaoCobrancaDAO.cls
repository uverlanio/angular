/**
 * Classe CondicaoCobrancaDAO
 * @author Fernando Barcellos @ 11/01/2018
 *
 **/
public class CondicaoCobrancaDAO {
	private static final CondicaoCobrancaDAO instance = new CondicaoCobrancaDAO();
	
	public static CondicaoCobrancaDAO getInstance() {
		return instance;
	}

	private CondicaoCobrancaDAO() { }

}