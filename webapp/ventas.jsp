<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@page import="java.sql.*"%>
<%
    String usuarioSesion = (String) session.getAttribute("usuario");
    if (usuarioSesion == null) { response.sendRedirect("login.jsp"); return; }

    String mensaje = ""; String tipoMensaje = "";
    String host = System.getenv("MYSQLHOST") != null ? System.getenv("MYSQLHOST") : "localhost";
    String port = System.getenv("MYSQLPORT") != null ? System.getenv("MYSQLPORT") : "3306";
    String db = System.getenv("MYSQLDATABASE") != null ? System.getenv("MYSQLDATABASE") : "AegisID_DB";
    String usuarioDb = System.getenv("MYSQLUSER") != null ? System.getenv("MYSQLUSER") : "root";
    String passwordDb = System.getenv("MYSQLPASSWORD") != null ? System.getenv("MYSQLPASSWORD") : "";
    String url = "jdbc:mysql://" + host + ":" + port + "/" + db + "?useSSL=false&allowPublicKeyRetrieval=true&characterEncoding=UTF-8";

    try {
        Class.forName("com.mysql.cj.jdbc.Driver");
        Connection conn = DriverManager.getConnection(url, usuarioDb, passwordDb);
        Statement st = conn.createStatement();

        st.executeUpdate("CREATE TABLE IF NOT EXISTS ventas ("
            + "id_venta INT AUTO_INCREMENT PRIMARY KEY, "
            + "cliente VARCHAR(150) NOT NULL, "
            + "total DECIMAL(10,2) NOT NULL, "
            + "metodo_pago VARCHAR(50) NOT NULL, "
            + "fecha TIMESTAMP DEFAULT CURRENT_TIMESTAMP)");

        String accion = request.getParameter("accion");
        if ("registrar".equalsIgnoreCase(accion)) {
            PreparedStatement ps = conn.prepareStatement("INSERT INTO ventas (cliente, total, metodo_pago) VALUES (?, ?, ?)");
            ps.setString(1, request.getParameter("cliente"));
            ps.setDouble(2, Double.parseDouble(request.getParameter("total")));
            ps.setString(3, request.getParameter("metodo_pago"));
            ps.executeUpdate(); ps.close();
            mensaje = "Venta procesada y registrada exitosamente."; tipoMensaje = "success";
        } else if ("eliminar".equalsIgnoreCase(accion)) {
            PreparedStatement ps = conn.prepareStatement("DELETE FROM ventas WHERE id_venta = ?");
            ps.setString(1, request.getParameter("id"));
            ps.executeUpdate(); ps.close();
            mensaje = "Venta anulada correctamente."; tipoMensaje = "success";
        }
        st.close(); conn.close();
    } catch (Exception e) { mensaje = "Error: " + e.getMessage(); tipoMensaje = "error"; }
%>
<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8"><meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Aegis ID - Módulo de Ventas</title>
    <link href="https://fonts.googleapis.com/css2?family=Plus+Jakarta+Sans:wght@400;500;600;700&display=swap" rel="stylesheet"/>
    <link href="https://fonts.googleapis.com/css2?family=Material+Symbols+Outlined:wght,FILL@100..700,0..1&display=swap" rel="stylesheet"/>
    <script src="https://cdn.tailwindcss.com"></script>
    <script>tailwind.config={theme:{extend:{colors:{"on-surface":"#131b2e","primary":"#070235","secondary":"#4e45d5","surface":"#faf8ff"}}}};.</script>
</head>
<body class="bg-surface text-on-surface min-h-screen font-sans" style="font-family:'Plus Jakarta Sans',sans-serif;">
    <header class="bg-primary text-white shadow-md">
        <div class="max-w-7xl mx-auto px-6 h-20 flex items-center justify-between">
            <div class="flex items-center gap-3">
                <a href="bienvenido.jsp" class="w-10 h-10 rounded-xl bg-white/10 flex items-center justify-center hover:bg-white/20 transition-all"><span class="material-symbols-outlined text-white text-[24px]">arrow_back</span></a>
                <div><h1 class="text-lg font-bold">Módulo 7: Ventas y Facturación</h1><p class="text-xs text-indigo-200">Procesamiento de órdenes</p></div>
            </div>
            <a href="bienvenido.jsp?accion=salir" class="px-4 py-2 rounded-xl bg-red-600/20 hover:bg-red-600 text-red-200 text-xs font-semibold border border-red-500/30 flex items-center gap-2">Cerrar Sesión</a>
        </div>
    </header>
    <main class="max-w-7xl mx-auto px-6 py-10">
        <% if (!mensaje.isEmpty()) { %><div class="mb-6 p-4 rounded-xl text-sm font-semibold text-center <%= "error".equals(tipoMensaje) ? "bg-red-100 text-red-800" : "bg-emerald-50 text-emerald-800" %>"><%= mensaje %></div><% } %>
        <div class="grid grid-cols-1 lg:grid-cols-3 gap-8">
            <div class="bg-white p-6 rounded-2xl shadow-sm border border-slate-100 h-fit">
                <h2 class="text-xl font-bold mb-1">Registrar Nueva Venta</h2>
                <form method="post" action="ventas.jsp" class="space-y-4 mt-4">
                    <input type="hidden" name="accion" value="registrar">
                    <div><label class="text-xs font-semibold block mb-1">Cliente / Razón Social</label><input type="text" name="cliente" required placeholder="Nombre del cliente" class="w-full h-[46px] px-4 rounded-xl border border-slate-200 text-sm outline-none focus:ring-2 focus:ring-secondary/40"/></div>
                    <div><label class="text-xs font-semibold block mb-1">Monto Total ($)</label><input type="number" step="0.01" name="total" required placeholder="0.00" class="w-full h-[46px] px-4 rounded-xl border border-slate-200 text-sm outline-none focus:ring-2 focus:ring-secondary/40"/></div>
                    <div>
                        <label class="text-xs font-semibold block mb-1">Método de Pago</label>
                        <select name="metodo_pago" class="w-full h-[46px] px-4 rounded-xl border border-slate-200 text-sm outline-none focus:ring-2 focus:ring-secondary/40 bg-white">
                            <option value="Tarjeta de Crédito">Tarjeta de Crédito</option>
                            <option value="Transferencia Bancaria">Transferencia Bancaria</option>
                            <option value="Efectivo">Efectivo</option>
                            <option value="Yape / Plin">Yape / Plin</option>
                        </select>
                    </div>
                    <button type="submit" class="w-full h-[48px] rounded-xl bg-secondary text-white font-semibold text-sm shadow-md hover:bg-indigo-700 transition-all">Procesar Venta</button>
                </form>
            </div>
            <div class="lg:col-span-2 bg-white p-6 rounded-2xl shadow-sm border border-slate-100">
                <h2 class="text-xl font-bold mb-4">Historial de Ventas</h2>
                <div class="overflow-x-auto">
                    <table class="w-full text-left border-collapse">
                        <thead><tr class="border-b text-xs text-slate-400 uppercase"><th class="py-3 px-4">ID</th><th class="py-3 px-4">CLIENTE</th><th class="py-3 px-4">MÉTODO PAGO</th><th class="py-3 px-4">TOTAL</th><th class="py-3 px-4 text-center">ACCIONES</th></tr></thead>
                        <tbody class="text-sm divide-y">
                            <% try {
                                Connection c = DriverManager.getConnection(url, usuarioDb, passwordDb);
                                Statement s = c.createStatement(); ResultSet r = s.executeQuery("SELECT * FROM ventas ORDER BY id_venta DESC");
                                while(r.next()) {
                            %>
                            <tr class="hover:bg-slate-50">
                                <td class="py-3 px-4">#<%= r.getString("id_venta") %></td>
                                <td class="py-3 px-4 font-semibold"><%= r.getString("cliente") %></td>
                                <td class="py-3 px-4"><span class="px-2 py-1 rounded bg-emerald-50 text-emerald-700 text-xs font-semibold"><%= r.getString("metodo_pago") %></span></td>
                                <td class="py-3 px-4 font-bold text-slate-800">$<%= r.getString("total") %></td>
                                <td class="py-3 px-4 text-center">
                                    <a href="ventas.jsp?accion=eliminar&id=<%= r.getString("id_venta") %>" onclick="return confirm('¿Anular esta venta?');" class="p-1.5 rounded bg-red-50 text-red-600 inline-block"><span class="material-symbols-outlined text-[16px]">delete</span></a>
                                </td>
                            </tr>
                            <% } r.close(); s.close(); c.close(); } catch(Exception e) { %><tr><td colspan="5" class="text-center text-red-500 py-4 text-xs">Error al cargar ventas</td></tr><% } %>
                        </tbody>
                    </table>
                </div>
            </div>
        </div>
    </main>
</body>
</html>
