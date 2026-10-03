<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@page import="java.sql.*"%>
<%
    String mensaje = "";
    if ("POST".equalsIgnoreCase(request.getMethod())) {
        request.setCharacterEncoding("UTF-8");
        String correo = request.getParameter("correo");
        String clave = request.getParameter("clave");

        String host = System.getenv("MYSQLHOST");
        String port = System.getenv("MYSQLPORT");
        String db = System.getenv("MYSQLDATABASE");
        String usuario = System.getenv("MYSQLUSER");
        String password = System.getenv("MYSQLPASSWORD");
        String url = "jdbc:mysql://" + host + ":" + port + "/" + db
                   + "?useSSL=false&allowPublicKeyRetrieval=true&characterEncoding=UTF-8";

        try {
            Class.forName("com.mysql.cj.jdbc.Driver");
            Connection conn = DriverManager.getConnection(url, usuario, password);

            Statement st = conn.createStatement();
            st.executeUpdate("CREATE TABLE IF NOT EXISTS usuarios ("
                + "id_usuario INT AUTO_INCREMENT PRIMARY KEY, "
                + "correo VARCHAR(100) NOT NULL UNIQUE, "
                + "clave VARCHAR(100) NOT NULL)");
            st.executeUpdate("INSERT IGNORE INTO usuarios (correo, clave) "
                + "VALUES ('admin@correo.com', '1234')");
            st.close();

            PreparedStatement ps = conn.prepareStatement(
                "SELECT COUNT(*) FROM usuarios WHERE correo = ? AND clave = ?");
            ps.setString(1, correo.trim());
            ps.setString(2, clave.trim());
            ResultSet rs = ps.executeQuery();
            rs.next();
            boolean existe = rs.getInt(1) > 0;
            rs.close();
            ps.close();
            conn.close();

            if (existe) {
                session.setAttribute("usuario", correo.trim());
                response.setStatus(302);
                response.setHeader("Location", "bienvenido.jsp");
                return;
            } else {
                mensaje = "Correo o contraseña incorrectos";
            }
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
<style>html,body{margin:0;padding:0;}body{overscroll-behavior:none;}::-webkit-scrollbar{display:none;}</style>
<script src="https://cdn.tailwindcss.com"></script>
<script>
tailwind.config={theme:{extend:{colors:{"on-surface":"#131b2e","primary":"#070235","secondary":"#4e45d5","surface-container":"#eaedff","surface-container-high":"#e2e7ff","tertiary-container":"#2a006b","surface":"#faf8ff","surface-container-low":"#f2f3ff","surface-container-lowest":"#ffffff","on-surface-variant":"#47464f","on-primary":"#ffffff","primary-container":"#1e1b4b","secondary-container":"#6860ef","on-secondary-container":"#fffbff","secondary-fixed":"#e3dfff","outline":"#787680","error":"#ba1a1a","surface-variant":"#dae2fd","outline-variant":"#c8c5d0"},fontFamily:{"sans":["Plus Jakarta Sans"]}}}};
</script>
</head>
<body class="bg-surface text-on-surface min-h-screen antialiased font-sans" style="font-family:'Plus Jakarta Sans',sans-serif;">
<div class="min-h-screen w-full flex flex-col lg:flex-row bg-surface">

  <!-- Panel izquierdo -->
  <div class="relative w-full lg:w-5/12 xl:w-1/2 bg-gradient-to-br from-primary via-primary-container to-tertiary-container text-white p-8 md:p-14 lg:p-16 flex flex-col justify-between overflow-hidden shadow-xl">
    <div class="absolute -top-32 -left-32 w-96 h-96 rounded-full bg-secondary-container/20 blur-3xl pointer-events-none"></div>
    <div class="absolute -bottom-40 -right-20 w-96 h-96 rounded-full bg-secondary/25 blur-3xl pointer-events-none"></div>

    <div class="relative z-10">
      <div class="flex items-center gap-3.5 mb-10">
        <div class="w-12 h-12 rounded-xl bg-white/10 backdrop-blur-md p-1.5 shadow-md flex items-center justify-center">
          <span class="material-symbols-outlined text-white text-[28px]">shield_lock</span>
        </div>
        <div>
          <div class="flex items-center gap-2">
            <span class="text-lg font-semibold tracking-tight text-white">Aegis ID</span>
            <span class="px-2 py-0.5 rounded-full bg-secondary-container text-on-secondary-container text-[11px] font-semibold uppercase tracking-wider">Enterprise</span>
          </div>
          <p class="text-xs text-surface-container-high/80">Plataforma Unificada de Identidad</p>
        </div>
      </div>

      <div class="max-w-xl space-y-4">
        <div class="inline-flex items-center gap-2 px-3 py-1.5 rounded-full bg-white/10 backdrop-blur-md text-surface-container-high text-xs font-semibold">
          <span class="w-2 h-2 rounded-full bg-emerald-400 animate-pulse"></span>
          Protocolo de Cero Confianza (Zero-Trust v4.2)
        </div>
        <h1 class="text-4xl font-bold leading-tight tracking-tight text-white">
          Seguridad y control en un solo lugar
        </h1>
        <p class="text-base leading-relaxed text-surface-container-high/90">
          Accede a tu plataforma empresarial con encriptación de grado bancario, autenticación multifactor y protección biométrica avanzada.
        </p>
      </div>
    </div>

    <div class="relative z-10 my-10 space-y-4">
      <div class="grid grid-cols-2 sm:grid-cols-3 gap-3">
        <div class="bg-white/10 backdrop-blur-sm rounded-xl p-4 shadow-sm">
          <div class="text-xl font-bold text-white">99.99%</div>
          <div class="text-[11px] font-semibold text-surface-container-high/75">Disponibilidad SLA</div>
        </div>
        <div class="bg-white/10 backdrop-blur-sm rounded-xl p-4 shadow-sm">
          <div class="text-xl font-bold text-white">ISO 27001</div>
          <div class="text-[11px] font-semibold text-surface-container-high/75">SOC2 Tipo II Compliant</div>
        </div>
        <div class="col-span-2 sm:col-span-1 bg-white/10 backdrop-blur-sm rounded-xl p-4 shadow-sm">
          <div class="text-xl font-bold text-white">+50K</div>
          <div class="text-[11px] font-semibold text-surface-container-high/75">Equipos protegidos</div>
        </div>
      </div>

      <div class="bg-white/15 backdrop-blur-md rounded-xl p-4 shadow-md flex items-start gap-3.5">
        <div class="w-10 h-10 rounded-full bg-secondary-fixed flex-shrink-0 flex items-center justify-center">
          <span class="material-symbols-outlined text-secondary text-[22px]">person</span>
        </div>
        <div class="min-w-0 flex-1">
          <p class="text-xs italic text-white leading-snug">
            "La mejor experiencia de autenticación y gestión de accesos que hemos implementado en la compañía."
          </p>
          <div class="mt-1 text-[11px]">
            <span class="font-semibold text-secondary-fixed">Elena Morales</span>
            <span class="text-surface-container-high/70"> • Directora de Ciberseguridad, GlobalFin</span>
          </div>
        </div>
      </div>
    </div>

    <div class="relative z-10 pt-4 flex flex-col sm:flex-row sm:items-center justify-between gap-3 text-surface-container-high/80 text-xs font-semibold">
      <div class="flex items-center gap-2">
        <span class="h-2 w-2 rounded-full bg-emerald-400"></span>
        <span class="text-white">Todos los sistemas operacionales</span>
      </div>
      <div class="font-normal text-surface-container-high/70">© 2026 Aegis ID Corporation</div>
    </div>
  </div>

  <!-- Panel derecho: formulario -->
  <div class="w-full lg:w-7/12 xl:w-1/2 flex items-center justify-center p-6 sm:p-10 md:p-14 lg:p-16 bg-surface">
    <div class="w-full max-w-[480px] py-4">

      <div class="mb-8">
        <div class="flex items-center justify-between mb-2">
          <span class="px-2.5 py-1 rounded-md bg-surface-container-high text-[11px] text-secondary font-semibold">Acceso Seguro SSL</span>
          <div class="flex items-center gap-1.5 text-on-surface-variant text-[11px] font-semibold">
            <span class="material-symbols-outlined text-[16px] text-secondary">lock</span>
            <span>TLS 1.3 256-bit</span>
          </div>
        </div>
        <h2 class="text-3xl font-bold tracking-tight text-on-surface">Bienvenido de nuevo</h2>
        <p class="text-sm text-on-surface-variant mt-1.5">Ingresa tus credenciales autorizadas para acceder a la consola corporativa.</p>
      </div>

      <div class="grid grid-cols-2 gap-3 mb-6">
        <button type="button" class="h-[50px] px-4 rounded-xl bg-white shadow-sm hover:shadow-md transition-all flex items-center justify-center gap-3 hover:bg-surface-container-low">
          <svg class="w-5 h-5" viewBox="0 0 24 24">
            <path d="M23.745 12.27c0-.7-.06-1.4-.19-2.07H12v4.51h6.6c-.29 1.52-1.14 2.82-2.4 3.68v3.05h3.88c2.27-2.09 3.665-5.17 3.665-9.17z" fill="#4285F4"></path>
            <path d="M12 24c3.24 0 5.95-1.08 7.93-2.91l-3.88-3.05c-1.08.72-2.45 1.16-4.05 1.16-3.12 0-5.77-2.1-6.72-4.93H1.25v3.15C3.26 21.36 7.33 24 12 24z" fill="#34A853"></path>
            <path d="M5.28 14.27c-.25-.72-.38-1.49-.38-2.27s.13-1.55.38-2.27V6.58H1.25C.45 8.18 0 9.99 0 12s.45 3.82 1.25 5.42l4.03-3.15z" fill="#FBBC05"></path>
            <path d="M12 4.75c1.77 0 3.35.61 4.6 1.8l3.42-3.42C17.95 1.19 15.24 0 12 0 7.33 0 3.26 2.64 1.25 6.58l4.03 3.15c.95-2.83 3.6-4.98 6.72-4.98z" fill="#EA4335"></path>
          </svg>
          <span class="text-sm font-semibold text-on-surface">Google</span>
        </button>
        <button type="button" class="h-[50px] px-4 rounded-xl bg-white shadow-sm hover:shadow-md transition-all flex items-center justify-center gap-3 hover:bg-surface-container-low">
          <svg class="w-5 h-5 fill-current" viewBox="0 0 24 24">
            <path d="M18.71 19.5c-.83 1.24-1.71 2.45-3.05 2.47-1.34.03-1.77-.79-3.29-.79-1.53 0-2 .77-3.27.82-1.31.05-2.3-1.32-3.14-2.53C4.25 17 2.94 12.45 4.7 9.39c.87-1.52 2.43-2.48 4.12-2.51 1.28-.02 2.5.87 3.29.87.78 0 2.26-1.07 3.81-.91.65.03 2.47.26 3.64 1.98-.09.06-2.17 1.28-2.15 3.81.03 3.02 2.65 4.03 2.68 4.04-.03.07-.42 1.44-1.38 2.83M15.97 6.37c.63-.76 1.05-1.82.93-2.88-.91.04-2.02.61-2.67 1.37-.58.67-1.09 1.74-.95 2.78 1.02.08 2.06-.51 2.69-1.27z"></path>
          </svg>
          <span class="text-sm font-semibold text-on-surface">Apple</span>
        </button>
      </div>

      <div class="relative flex items-center justify-center mb-6">
        <div class="w-full h-px bg-surface-container-high"></div>
        <span class="absolute bg-surface px-4 text-xs text-on-surface-variant font-medium">o continúa con tu correo institucional</span>
      </div>

      <!-- FORMULARIO CONECTADO A LA BASE DE DATOS -->
      <form method="post" action="login.jsp" class="space-y-4" id="loginForm">

        <% if (!mensaje.isEmpty()) { %>
        <div class="p-3 rounded-lg text-sm font-semibold text-center" style="background:#ffdad6;color:#93000a;">
          <%= mensaje %>
        </div>
        <% } %>

        <div>
          <label class="text-xs text-on-surface font-semibold flex items-center gap-1 mb-1.5" for="email">
            Correo Electrónico Corporativo <span class="text-error font-bold">*</span>
          </label>
          <div class="relative flex items-center rounded-xl bg-white shadow-sm focus-within:shadow-md focus-within:ring-2 focus-within:ring-secondary/40">
            <span class="material-symbols-outlined text-on-surface-variant text-[20px] ml-4 pointer-events-none">mail</span>
            <input class="w-full h-[52px] bg-transparent pl-3 pr-4 text-on-surface placeholder:text-outline text-sm outline-none"
                   id="email" name="correo" placeholder="tu.nombre@empresa.com" required type="email"/>
          </div>
        </div>

        <div>
          <div class="flex items-center justify-between mb-1.5">
            <label class="text-xs text-on-surface font-semibold flex items-center gap-1" for="password">
              Contraseña <span class="text-error font-bold">*</span>
            </label>
            <a class="text-xs font-semibold text-secondary hover:underline" href="#recuperar">¿Olvidaste tu contraseña?</a>
          </div>
          <div class="relative flex items-center rounded-xl bg-white shadow-sm focus-within:shadow-md focus-within:ring-2 focus-within:ring-secondary/40">
            <span class="material-symbols-outlined text-on-surface-variant text-[20px] ml-4 pointer-events-none">lock</span>
            <input class="w-full h-[52px] bg-transparent pl-3 pr-12 text-on-surface placeholder:text-outline text-sm outline-none"
                   id="password" name="clave" placeholder="••••••••••••" required type="password"/>
            <button type="button" aria-label="Mostrar u ocultar contraseña"
                    class="absolute right-3.5 p-1 rounded-lg text-on-surface-variant hover:text-on-surface hover:bg-surface-container-low"
                    onclick="togglePasswordVisibility()">
              <span class="material-symbols-outlined text-[20px] align-middle" id="passwordEyeIcon">visibility</span>
            </button>
          </div>
        </div>

        <div class="flex items-center justify-between gap-3 pt-1">
          <label class="inline-flex items-center gap-2.5 cursor-pointer select-none">
            <input checked class="w-4 h-4 rounded accent-secondary cursor-pointer" id="rememberDevice" type="checkbox"/>
            <span class="text-xs text-on-surface">Recordar este dispositivo por 30 días</span>
          </label>
          <button type="button" class="inline-flex items-center gap-1.5 text-xs font-semibold text-secondary hover:underline">
            <span class="material-symbols-outlined text-[18px]">key</span>
            <span>Usar Llave de Seguridad</span>
          </button>
        </div>

        <div class="pt-2">
          <button type="submit" id="submitLoginBtn"
                  class="w-full h-[52px] rounded-xl bg-gradient-to-r from-primary-container via-secondary to-primary-container text-white text-sm font-semibold shadow-md hover:shadow-lg hover:brightness-105 active:scale-[0.99] transition-all flex items-center justify-center gap-2.5">
            <span>Iniciar Sesión</span>
            <span class="material-symbols-outlined text-[20px]">arrow_forward</span>
          </button>
        </div>
      </form>

      <div class="mt-7 p-4 rounded-xl bg-surface-container-low shadow-sm flex items-center justify-between gap-3">
        <div class="flex items-center gap-3">
          <div class="w-10 h-10 rounded-lg bg-white shadow-sm flex items-center justify-center text-secondary">
            <span class="material-symbols-outlined text-[24px]">qr_code_scanner</span>
          </div>
          <div>
            <div class="text-sm font-bold text-on-surface">Acceso Express con Móvil o Passkey</div>
            <div class="text-xs text-on-surface-variant">Escanea desde tu app Aegis Authenticator</div>
          </div>
        </div>
        <button type="button" class="px-3.5 py-1.5 rounded-lg bg-white shadow-sm text-xs font-semibold text-secondary whitespace-nowrap">Generar QR</button>
      </div>

      <div class="mt-8 text-center">
        <p class="text-sm text-on-surface-variant">
          ¿Aún no tienes cuenta institucional?
          <a class="font-bold text-secondary hover:underline ml-1" href="#registro">Regístrate gratis</a>
        </p>
      </div>

      <div class="mt-10 pt-6 flex flex-wrap items-center justify-between gap-4 text-xs text-on-surface-variant">
        <div class="flex flex-wrap items-center gap-4">
          <a class="hover:underline" href="#ayuda">Centro de Ayuda</a>
          <span class="text-outline-variant">•</span>
          <a class="hover:underline" href="#privacidad">Privacidad</a>
          <span class="text-outline-variant">•</span>
          <a class="hover:underline" href="#terminos">Términos</a>
        </div>
        <div class="inline-flex items-center gap-1.5 px-2.5 py-1 rounded-lg bg-surface-container-high text-[11px] font-semibold text-on-surface">
          <span class="material-symbols-outlined text-[16px]">language</span>
          <span>Español (ES)</span>
        </div>
      </div>

    </div>
  </div>
</div>

<script>
  function togglePasswordVisibility() {
    var input = document.getElementById('password');
    var icon = document.getElementById('passwordEyeIcon');
    if (input.type === 'password') {
      input.type = 'text';
      icon.textContent = 'visibility_off';
    } else {
      input.type = 'password';
      icon.textContent = 'visibility';
    }
  }
</script>
</body>
</html>
