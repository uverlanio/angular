/**
 * Regras de Negócio do objeto User
 * @author Fernando Barcellos @ 04/12/2017
 *
 **/
public class UserBO {

	private static final UserBO instance = new UserBO();

	private String apelidoUsuarioIntegracao = 'int';

	public static UserBO getInstance() {
		return instance;
	}

	public User buscarUsuarioPorApelido(String apelido) {
		return UserDAO.getInstance().buscarUsuarioPorApelido(new Set<String> { apelido })[0];
	}

	public List<User> buscarUsuarioPorApelido(Set<String> lstApelidos) {
		return UserDAO.getInstance().buscarUsuarioPorApelido(lstApelidos);
	}

	public User buscarUsuarioIntegracao() {
		return buscarUsuarioPorApelido(apelidoUsuarioIntegracao);
	}

	public List<User> tempBuscarAliasNotificacoes() {
		return buscarUsuarioPorApelido(new Set<String>{ 'ckume', 'jazev', 'fbar', 'reste', 'kstra' });
	}
}