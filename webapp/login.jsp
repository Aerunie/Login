<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@page import="java.sql.*"%>
<%
    String mensaje = "";
    if ("POST".equalsIgnoreCase(request.getMethod())) {
        request.setCharacterEncoding("UTF-8");
        String correo = request.getParameter("correo");
        String clave = request.getParameter("clave");

        String host = System.getenv("MYSQLHOST") != null ? System.getenv("MYSQLHOST") : "localhost";
        String port = System.getenv("MYSQLPORT") != null ? System.getenv("MYSQLPORT") : "3306";
        String db = System.getenv("MYSQLDATABASE") != null ? System.getenv("MYSQLDATABASE") : "AegisID_DB";
        String usuario = System.getenv("MYSQLUSER") != null ? System.getenv("MYSQLUSER") : "root";
        String password = System.getenv("MYSQLPASSWORD") != null ? System.getenv("MYSQLPASSWORD") : "";
        String url = "jdbc:mysql://" + host + ":" + port + "/" + db
                   + "?useSSL=false&allowPublicKeyRetrieval=true&characterEncoding=UTF-8";

        try {
            Class.forName("com.mysql.cj.jdbc.Driver");
            Connection conn = DriverManager.getConnection(url, usuario, password);

            Statement st = conn.createStatement();
            // Aseguramos la tabla con columnas de seguridad para los 3 intentos
            st.executeUpdate("CREATE TABLE IF NOT EXISTS usuarios ("
                + "id_usuario INT AUTO_INCREMENT PRIMARY KEY, "
                + "correo VARCHAR(100) NOT NULL UNIQUE, "
                + "clave VARCHAR(100) NOT NULL, "
                + "intentos_fallidos INT DEFAULT 0, "
                + "bloqueado BOOLEAN DEFAULT FALSE)");
            
            // Insertar usuario por defecto si no existe
            st.executeUpdate("INSERT IGNORE INTO usuarios (correo, clave, intentos_fallidos, bloqueado) "
                + "VALUES ('admin@correo.com', '1234', 0, FALSE)");
            st.close();

            // 1. Consultar el estado del usuario por correo
            PreparedStatement psUser = conn.prepareStatement(
                "SELECT id_usuario, clave, intentos_fallidos, bloqueado FROM usuarios WHERE correo = ?");
            psUser.setString(1, correo.trim());
            ResultSet rsUser = psUser.executeQuery();

            if (rsUser.next()) {
                boolean bloqueado = rsUser.getBoolean("bloqueado");
                int intentos = rsUser.getInt("intentos_fallidos");
                String claveReal = rsUser.getString("clave");

                if (bloqueado) {
                    mensaje = "Tu cuenta está BLOQUEADA por superar los 3 intentos fallidos. Contacta al administrador.";
                } else if (claveReal.equals(clave.trim())) {
                    // Contraseña correcta: reseteamos los intentos a 0
                    PreparedStatement psReset = conn.prepareStatement(
                        "UPDATE usuarios SET intentos_fallidos = 0 WHERE correo = ?");
                    psReset.setString(1, correo.trim());
                    psReset.executeUpdate();
                    psReset.close();

                    session.setAttribute("usuario", correo.trim());
                    response.setStatus(302);
                    response.setHeader("Location", "bienvenido.jsp");
                    rsUser.close();
                    psUser.close();
                    conn.close();
                    return;
                } else {
                    // Contraseña incorrecta: incrementamos intentos
                    intentos++;
                    if (intentos >= 3) {
                        PreparedStatement psBlock = conn.prepareStatement(
                            "UPDATE usuarios SET intentos_fallidos = ?, bloqueado = TRUE WHERE correo = ?");
                        psBlock.setInt(1, intentos);
                        psBlock.setString(2, correo.trim());
                        psBlock.executeUpdate();
                        psBlock.close();
                        mensaje = "Contraseña incorrecta. Has superado los 3 intentos. Tu cuenta ha sido BLOQUEADA.";
                    } else {
                        PreparedStatement psUpdate = conn.prepareStatement(
                            "UPDATE usuarios SET intentos_fallidos = ? WHERE correo = ?");
                        psUpdate.setInt(1, intentos);
                        psUpdate.setString(2, correo.trim());
                        psUpdate.executeUpdate();
                        psUpdate.close();
                        mensaje = "Correo o contraseña incorrectos. Intentos fallidos: " + intentos + " de 3.";
                    }
                }
            } else {
                mensaje = "El correo ingresado no se encuentra registrado.";
            }

            rsUser.close();
            psUser.close();
            conn.close();

        } catch (Exception e) {
            mensaje = "Error: " + e.getMessage();
        }
    }
%>
<!DOCTYPE html>
<html lang="es">
<head>
<meta charset="utf-8"/>
<meta content="width=device-width, initial-scale=1.0" name="viewport"/>
<title>Aegis ID - Iniciar Sesión</title>
<link href="https://fonts.googleapis.com/css2?family=Plus+Jakarta+Sans:wght@400;500;600;700&display=swap" rel="stylesheet"/>
<link href="https://fonts.googleapis.com/css2?family=Material+Symbols+Outlined:wght,FILL@100..700,0..1&display=swap" rel="stylesheet"/>
<script src="https://cdn.tailwindcss.com"></script>
</head>
<body class="bg-surface text-on-surface min-h-screen antialiased font-sans" style="font-family:'Plus Jakarta Sans',sans-serif;">
<div class="min-h-screen w-full flex flex-col lg:flex-row bg-surface">

  <!-- Panel izquierdo decorativo -->
  <div class="relative w-full lg:w-5/12 xl:w-1/2 bg-gradient-to-br from-slate-900 via-indigo-950 to-purple-950 text-white p-8 md:p-14 lg:p-16 flex flex-col justify-between overflow-hidden shadow-xl">
    <div class="relative z-10">
      <div class="flex items-center gap-3.5 mb-10">
        <div class="w-12 h-12 rounded-xl bg-white/10 backdrop-blur-md p-1.5 shadow-md flex items-center justify-center">
          <span class="material-symbols-outlined text-white text-[28px]">shield_lock</span>
        </div>
        <div>
          <span class="text-lg font-semibold text-white">Aegis ID</span>
          <p class="text-xs text-indigo-200">Plataforma Unificada de Identidad</p>
        </div>
      </div>
      <h1 class="text-4xl font-bold leading-tight text-white mb-4">Seguridad y control en un solo lugar</h1>
      <p class="text-base text-indigo-100/90">Accede a tu consola corporativa con autenticación segura y políticas de bloqueo por seguridad.</p>
    </div>
  </div>

  <!-- Panel derecho: formulario -->
  <div class="w-full lg:w-7/12 xl:w-1/2 flex items-center justify-center p-6 sm:p-10 md:p-14 lg:p-16 bg-white">
    <div class="w-full max-w-[480px]">

      <div class="mb-8">
        <h2 class="text-3xl font-bold text-slate-900">Bienvenido de nuevo</h2>
        <p class="text-sm text-slate-500 mt-1.5">Ingresa tus credenciales autorizadas para acceder.</p>
      </div>

      <!-- FORMULARIO CONECTADO Y CON CONTROL DE INTENTOS -->
      <form method="post" action="login.jsp" class="space-y-4">

        <% if (!mensaje.isEmpty()) { %>
        <div class="p-4 rounded-xl text-sm font-medium text-center border <% if(mensaje.contains("BLOQUEADA")) { %> bg-red-100 text-red-800 border-red-300 <% } else { %> bg-amber-50 text-amber-800 border-amber-200 <% } %>">
          <%= mensaje %>
        </div>
        <% } %>

        <div>
          <label class="text-xs text-slate-700 font-semibold mb-1.5 block">Correo Electrónico Corporativo</label>
          <input class="w-full h-[52px] px-4 rounded-xl border border-slate-200 text-sm outline-none focus:ring-2 focus:ring-indigo-600"
                 name="correo" placeholder="admin@correo.com" required type="email"/>
        </div>

        <div>
          <label class="text-xs text-slate-700 font-semibold mb-1.5 block">Contraseña</label>
          <input class="w-full h-[52px] px-4 rounded-xl border border-slate-200 text-sm outline-none focus:ring-2 focus:ring-indigo-600"
                 name="clave" placeholder="••••••••••••" required type="password"/>
        </div>

        <button type="submit"
                class="w-full h-[52px] rounded-xl bg-indigo-600 hover:bg-indigo-700 text-white font-semibold text-sm shadow-md transition-all">
          Iniciar Sesión
        </button>
      </form>

    </div>
  </div>
</div>
</body>
</html>
