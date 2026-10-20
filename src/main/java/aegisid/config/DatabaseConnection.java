package aegisid.config;

import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.SQLException;

public class DatabaseConnection {
    private static DatabaseConnection instance;
    private String url;
    private String usuarioDb;
    private String passwordDb;

    // Constructor privado: evita que se instancie directamente con 'new'
    private DatabaseConnection() {
        try {
            Class.forName("com.mysql.cj.jdbc.Driver");
            String host = System.getenv("MYSQLHOST") != null ? System.getenv("MYSQLHOST") : "localhost";
            String port = System.getenv("MYSQLPORT") != null ? System.getenv("MYSQLPORT") : "3306";
            String db = System.getenv("MYSQLDATABASE") != null ? System.getenv("MYSQLDATABASE") : "AegisID_DB";
            this.usuarioDb = System.getenv("MYSQLUSER") != null ? System.getenv("MYSQLUSER") : "root";
            this.passwordDb = System.getenv("MYSQLPASSWORD") != null ? System.getenv("MYSQLPASSWORD") : "";
            this.url = "jdbc:mysql://" + host + ":" + port + "/" + db 
                     + "?useSSL=false&allowPublicKeyRetrieval=true&characterEncoding=UTF-8";
        } catch (ClassNotFoundException e) {
            e.printStackTrace();
        }
    }

    // Método estático sincronizado para garantizar la única instancia (Singleton)
    public static synchronized DatabaseConnection getInstance() {
        if (instance == null) {
            instance = new DatabaseConnection();
        }
        return instance;
    }

    // Retorna la conexión activa utilizando la configuración centralizada
    public Connection getConnection() throws SQLException {
        return DriverManager.getConnection(url, usuarioDb, passwordDb);
    }
}
