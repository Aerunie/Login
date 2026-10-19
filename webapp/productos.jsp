<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@page import="java.sql.*"%>
<%
    String usuarioSesion = (String) session.getAttribute("usuario");
    if (usuarioSesion == null) { response.sendRedirect("login.jsp"); return; }

    String mensaje = ""; String tipoMensaje = "";
    String editId = "", editNombre = "", editCategoria = "", editPrecio = "", editStock = "";
    boolean modoEdicion = false;

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

        st.executeUpdate("CREATE TABLE IF NOT EXISTS productos ("
            + "id_producto INT AUTO_INCREMENT PRIMARY KEY, "
            + "nombre VARCHAR(150) NOT NULL, "
            + "categoria VARCHAR(100) NOT NULL, "
            + "precio DECIMAL(10,2) NOT NULL, "
            + "stock INT NOT NULL, "
            + "estado VARCHAR(15) DEFAULT 'Disponible')");

        String accion = request.getParameter("accion");
        if ("crear".equalsIgnoreCase(accion)) {
            PreparedStatement ps = conn.prepareStatement("INSERT INTO productos (nombre, categoria, precio, stock, estado) VALUES (?, ?, ?, ?, 'Disponible')");
            ps.setString(1, request.getParameter("nombre"));
            ps.setString(2, request.getParameter("categoria"));
            ps.setDouble(3, Double.parseDouble(request.getParameter("precio")));
            ps.setInt(4, Integer.parseInt(request.getParameter("stock")));
            ps.executeUpdate(); ps.close();
            mensaje = "Producto registrado exitosamente."; tipoMensaje = "success";
        } else if ("actualizar".equalsIgnoreCase(accion)) {
            PreparedStatement ps = conn.prepareStatement("UPDATE productos SET nombre = ?, categoria = ?, precio = ?, stock = ? WHERE id_producto = ?");
            ps.setString(1, request.getParameter("nombre"));
            ps.setString(2, request.getParameter("categoria"));
            ps.setDouble(3, Double.parseDouble(request.getParameter("precio")));
            ps.setInt(4, Integer.parseInt(request.getParameter("stock")));
            ps.setString(5, request.getParameter("id_producto"));
            ps.executeUpdate(); ps.close();
            mensaje = "Producto actualizado correctamente."; tipoMensaje = "success";
        } else if ("eliminar".equalsIgnoreCase(accion)) {
            PreparedStatement ps = conn.prepareStatement("DELETE FROM productos WHERE id_producto = ?");
            ps.setString(1, request.getParameter("id"));
            ps.executeUpdate(); ps.close();
            mensaje = "Producto eliminado correctamente."; tipoMensaje = "success";
        } else if ("preeditar".equalsIgnoreCase(accion)) {
            PreparedStatement ps = conn.prepareStatement("SELECT * FROM productos WHERE id_producto = ?");
            ps.setString(1, request.getParameter("id"));
            ResultSet rs = ps.executeQuery();
            if (rs.next()) {
                editId = rs.getString("id_producto");
                editNombre = rs.getString("nombre");
                editCategoria = rs.getString("categoria");
                editPrecio = rs.getString("precio");
                editStock = rs.getString("stock");
                modoEdicion = true;
            }
            rs.close(); ps.close();
        }
        st.close(); conn.close();
    } catch (Exception e) { mensaje = "Error: " + e.getMessage(); tipoMensaje = "error"; }
%>
<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8"><meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Aegis ID - Mercadería y Productos</title>
    <link href="https://fonts.googleapis.com/css2?family=Plus+Jakarta+Sans:wght@400;500;600;700&display=swap" rel="stylesheet"/>
    <link href="https://fonts.googleapis.com/css2?family=Material+Symbols+Outlined:wght,FILL@100..700,0..1&display=swap" rel="stylesheet"/>
    <style>html,body{margin:0;padding:0;}body{overscroll-behavior:none;}::-webkit-scrollbar{display:none;}</style>
    <script src="https://cdn.tailwindcss.com"></script>
    <script>
    tailwind.config={theme:{extend:{colors:{"on-surface":"#131b2e","primary":"#070235","secondary":"#4e45d5","surface-container":"#eaedff","surface":"#faf8ff","surface-container-low":"#f2f3ff","error":"#ba1a1a"}}}}
    </script>
</head>
<body class="bg-surface text-on-surface min-h-screen font-sans" style="font-family:'Plus Jakarta Sans',sans-serif;">
    <header class="bg-primary text-white shadow-md">
        <div class="max-w-7xl mx-auto px-6 h-20 flex items-center justify-between">
            <div class="flex items-center gap-3">
                <a href="bienvenido.jsp" class="w-10 h-10 rounded-xl bg-white/10 flex items-center justify-center hover:bg-white/20 transition-all"><span class="material-symbols-outlined text-white text-[24px]">arrow_back</span></a>
                <div><h1 class="text-lg font-bold tracking-tight">Módulo 6: Inventario y Productos</h1><p class="text-xs text-indigo-200">Control de stock y mercadería</p></div>
            </div>
            <a href="bienvenido.jsp?accion=salir" class="px-4 py-2 rounded-xl bg-red-600/20 hover:bg-red-600 text-red-200 hover:text-white text-xs font-semibold transition-all border border-red-500/30 flex items-center gap-2">
                <span class="material-symbols-outlined text-[18px]">logout</span>
                <span>Salir</span>
            </a>
        </div>
    </header>
    <main class="max-w-7xl mx-auto px-6 py-10">
        <% if (!mensaje.isEmpty()) { %><div class="mb-6 p-4 rounded-xl text-sm font-semibold text-center <%= "error".equals(tipoMensaje) ? "bg-red-100 text-red-800 border border-red-300" : "bg-emerald-50 text-emerald-800 border border-emerald-200" %>"><%= mensaje %></div><% } %>
        <div class="grid grid-cols-1 lg:grid-cols-3 gap-8">
            <div class="bg-white p-6 rounded-2xl shadow-sm border border-slate-100 h-fit">
                <h2 class="text-xl font-bold text-slate-900 mb-1"><%= modoEdicion ? "Modificar Producto" : "Nuevo Producto" %></h2>
                <p class="text-xs text-slate-500 mb-6"><%= modoEdicion ? "Actualiza la información del ítem." : "Añade nuevos productos al catálogo." %></p>
                <form method="post" action="productos.jsp" class="space-y-4">
                    <input type="hidden" name="accion" value="<%= modoEdicion ? "actualizar" : "crear" %>">
                    <% if (modoEdicion) { %><input type="hidden" name="id_producto" value="<%= editId %>"><% } %>
                    <div><label class="text-xs text-slate-700 font-semibold block mb-1.5">Nombre del Producto</label><input type="text" name="nombre" required value="<%= editNombre %>" placeholder="Ej. Laptop HP 15" class="w-full h-[46px] px-4 rounded-xl border border-slate-200 text-sm outline-none focus:ring-2 focus:ring-secondary/40"/></div>
                    <div><label class="text-xs text-slate-700 font-semibold block mb-1.5">Categoría</label><input type="text" name="categoria" required value="<%= editCategoria %>" placeholder="Ej. Equipos de Cómputo" class="w-full h-[46px] px-4 rounded-xl border border-slate-200 text-sm outline-none focus:ring-2 focus:ring-secondary/40"/></div>
                    <div><label class="text-xs text-slate-700 font-semibold block mb-1.5">Precio Unitario ($)</label><input type="number" step="0.01" name="precio" required value="<%= editPrecio %>" placeholder="0.00" class="w-full h-[46px] px-4 rounded-xl border border-slate-200 text-sm outline-none focus:ring-2 focus:ring-secondary/40"/></div>
                    <div><label class="text-xs text-slate-700 font-semibold block mb-1.5">Stock Disponible</label><input type="number" name="stock" required value="<%= editStock %>" placeholder="0" class="w-full h-[46px] px-4 rounded-xl border border-slate-200 text-sm outline-none focus:ring-2 focus:ring-secondary/40"/></div>
                    <button type="submit" class="w-full h-[48px] rounded-xl bg-secondary hover:bg-indigo-700 text-white font-semibold text-sm shadow-md transition-all flex items-center justify-center gap-2">
                        <span class="material-symbols-outlined text-[20px]"><%= modoEdicion ? "save" : "add_box" %></span>
                        <span><%= modoEdicion ? "Actualizar Producto" : "Guardar Producto" %></span>
                    </button>
                </form>
            </div>
            <div class="lg:col-span-2 bg-white p-6 rounded-2xl shadow-sm border border-slate-100">
                <h2 class="text-xl font-bold text-slate-900 mb-1">Catálogo de Inventario</h2>
                <p class="text-xs text-slate-500 mb-6">Listado general de mercadería y stock registrado.</p>
                <div class="overflow-x-auto">
                    <table class="w-full text-left border-collapse">
                        <thead><tr class="border-b border-slate-100 text-xs text-slate-400 uppercase tracking-wider"><th class="py-3 px-4 font-semibold">ID</th><th class="py-3 px-4 font-semibold">PRODUCTO</th><th class="py-3 px-4 font-semibold">CATEGORÍA</th><th class="py-3 px-4 font-semibold">PRECIO</th><th class="py-3 px-4 font-semibold">STOCK</th><th class="py-3 px-4 font-semibold text-center">ACCIONES</th></tr></thead>
                        <tbody class="text-sm divide-y divide-slate-100">
                            <% try {
                                Connection c = DriverManager.getConnection(url, usuarioDb, passwordDb);
                                Statement s = c.createStatement(); ResultSet r = s.executeQuery("SELECT * FROM productos");
                                while(r.next()) {
                            %>
                            <tr class="hover:bg-slate-50/50">
                                <td class="py-3.5 px-4 text-slate-600 font-medium">#<%= r.getString("id_producto") %></td>
                                <td class="py-3.5 px-4 text-slate-900 font-semibold"><%= r.getString("nombre") %></td>
                                <td class="py-3.5 px-4"><span class="px-2.5 py-1 rounded-full bg-amber-50 text-amber-700 text-xs font-semibold"><%= r.getString("categoria") %></span></td>
                                <td class="py-3.5 px-4 font-bold text-slate-800">$<%= r.getString("precio") %></td>
                                <td class="py-3.5 px-4"><span class="px-2.5 py-1 rounded-full bg-slate-100 text-slate-800 text-xs font-bold"><%= r.getString("stock") %> un.</span></td>
                                <td class="py-3.5 px-4 text-center">
                                    <div class="flex items-center justify-center gap-2">
                                        <a href="productos.jsp?accion=preeditar&id=<%= r.getString("id_producto") %>" class="inline-flex items-center justify-center w-8 h-8 rounded-lg bg-indigo-50 text-secondary hover:bg-indigo-100 transition-all"><span class="material-symbols-outlined text-[18px]">edit</span></a>
                                        <a href="productos.jsp?accion=eliminar&id=<%= r.getString("id_producto") %>" onclick="return confirm('¿Eliminar producto?');" class="inline-flex items-center justify-center w-8 h-8 rounded-lg bg-red-50 text-red-600 hover:bg-red-100 transition-all"><span class="material-symbols-outlined text-[18px]">delete</span></a>
                                    </div>
                                </td>
                            </tr>
                            <% } r.close(); s.close(); c.close(); } catch(Exception e) { %><tr><td colspan="6" class="text-center text-red-500 py-4 text-xs">Error al cargar inventario: <%= e.getMessage() %></td></tr><% } %>
                        </tbody>
                    </table>
                </div>
            </div>
        </div>
    </main>
</body>
</html>
