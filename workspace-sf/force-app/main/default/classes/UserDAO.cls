/**
 * UserDAO
 * @author Fernando Barcellos @ 04/12/2017
 *
 **/
public class UserDAO {

	private static final UserDAO instance = new UserDAO();

	public static UserDAO getInstance() {
		return instance;
	}

	//public User buscarUsuarioPorApelido(String apelido) {
	//	return buscarUsuarioPorApelido(new Set<String> { apelido })[0];
	//}

	public List<User> buscarUsuarioPorApelido(Set<String> lstApelidos) {
		return [
			SELECT
				Id,
				Name,
				Alias,
				Email,
				Username
			FROM
				User
			WHERE
				Alias IN :lstApelidos
		];
	}
}

//[SELECT Id, Name, Email, Username, Alias FROM User WHERE Alias = 'int']