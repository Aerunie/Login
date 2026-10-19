<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@page import="java.sql.*"%>
<%
    String usuarioSesion = (String) session.getAttribute("usuario");
    if (usuarioSesion == null) { response.sendRedirect("login.jsp"); return; }

    String host = System.getenv("MYSQLHOST") != null ? System.getenv("MYSQLHOST") : "localhost";
    String port = System.getenv("MYSQLPORT") != null ? System.getenv("MYSQLPORT") : "3306";
    String db = System.getenv("MYSQLDATABASE") != null ? System.getenv("MYSQLDATABASE") : "AegisID_DB";
    String usuarioDb = System.getenv("MYSQLUSER") != null ? System.getenv("MYSQLUSER") : "root";
    String passwordDb = System.getenv("MYSQLPASSWORD") != null ? System.getenv("MYSQLPASSWORD") : "";
    String url = "jdbc:mysql://" + host + ":" + port + "/" + db + "?useSSL=false&allowPublicKeyRetrieval=true&characterEncoding=UTF-8";

    int totalUsuarios = 0, totalClientes = 0, totalProveedores = 0, totalProductos = 0, totalVentas = 0;
    double ingresosTotales = 0.0;

    try {
        Connection c = DriverManager.getConnection(url, usuarioDb, passwordDb);
        Statement s = c.createStatement();
        ResultSet rs;
        
        rs = s.executeQuery("SELECT COUNT(*) FROM usuarios"); if(rs.next()) totalUsuarios = rs.getInt(1); rs.close();
        rs = s.executeQuery("SELECT COUNT(*) FROM clientes"); if(rs.next()) totalClientes = rs.getInt(1); rs.close();
        rs = s.executeQuery("SELECT COUNT(*) FROM proveedores"); if(rs.next()) totalProveedores = rs.getInt(1); rs.close();
        rs = s.executeQuery("SELECT COUNT(*) FROM productos"); if(rs.next()) totalProductos = rs.getInt(1); rs.close();
        rs = s.executeQuery("SELECT COUNT(*), SUM(total) FROM ventas"); if(rs.next()) { totalVentas = rs.getInt(1); ingresosTotales = rs.getDouble(2); } rs.close();
        
        s.close(); c.close();
    } catch(Exception e) {}
%>
<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8"><meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Aegis ID - Reportería y OLAP</title>
    <link href="https://fonts.googleapis.com/css2?family=Plus+Jakarta+Sans:wght@400;500;600;700&display=swap" rel="stylesheet"/>
    <link href="https://fonts.googleapis.com/css2?family=Material+Symbols+Outlined:wght,FILL@100..700,0..1&display=swap" rel="stylesheet"/>
    <script src="https://cdn.tailwindcss.com"></script>
    <script>tailwind.config={theme:{extend:{colors:{"on-surface":"#131b2e","primary":"#070235","secondary":"#4e45d5","surface":"#faf8ff"}}}};.</script>
    <style>
        @media print {
            header, .no-print { display: none !important; }
            body { background: white !important; color: black !important; }
            .shadow-sm, .shadow-md { box-shadow: none !important; border: 1px solid #cbd5e1 !important; }
        }
    </style>
</head>
<body class="bg-surface text-on-surface min-h-screen font-sans" style="font-family:'Plus Jakarta Sans',sans-serif;">
    <header class="bg-primary text-white shadow-md">
        <div class="max-w-7xl mx-auto px-6 h-20 flex items-center justify-between">
            <div class="flex items-center gap-3">
                <a href="bienvenido.jsp" class="w-10 h-10 rounded-xl bg-white/10 flex items-center justify-center hover:bg-white/20 transition-all"><span class="material-symbols-outlined text-white text-[24px]">arrow_back</span></a>
                <div><h1 class="text-lg font-bold">Módulo 8: Reportería y OLAP</h1><p class="text-xs text-indigo-200">Informes ejecutivos</p></div>
            </div>
            <div class="flex items-center gap-3">
                <button onclick="window.print()" class="no-print px-4 py-2 rounded-xl bg-emerald-600 hover:bg-emerald-700 text-white text-xs font-semibold transition-all shadow-sm flex items-center gap-2">
                    <span class="material-symbols-outlined text-[18px]">picture_as_pdf</span>
                    <span>Exportar a PDF</span>
                </button>
                <a href="bienvenido.jsp?accion=salir" class="no-print px-4 py-2 rounded-xl bg-red-600/20 hover:bg-red-600 text-red-200 text-xs font-semibold border border-red-500/30 flex items-center gap-2">Salir</a>
            </div>
        </div>
    </header>
    <main class="max-w-7xl mx-auto px-6 py-10">
        <div class="mb-8 flex flex-col sm:flex-row sm:items-center justify-between gap-4">
            <div>
                <h2 class="text-2xl font-bold tracking-tight">Reporte General del Sistema</h2>
                <p class="text-xs text-slate-500 mt-1">Consolidado métrico de todas las áreas empresariales de Aegis ID Enterprise.</p>
            </div>
            <div class="text-xs text-slate-500 font-semibold bg-white px-4 py-2 rounded-xl border border-slate-200 shadow-sm">
                Generado por: <span class="text-secondary"><%= usuarioSesion %></span>
            </div>
        </div>

        <div class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-6 mb-8">
            <div class="bg-white p-6 rounded-2xl shadow-sm border border-slate-100">
                <div class="text-xs text-slate-400 font-semibold mb-1">Ingresos Totales</div>
                <div class="text-2xl font-bold text-emerald-600">$<%= String.format("%.2f", ingresosTotales) %></div>
                <div class="text-[11px] text-slate-400 mt-1"><%= totalVentas %> transacciones registradas</div>
            </div>
            <div class="bg-white p-6 rounded-2xl shadow-sm border border-slate-100">
                <div class="text-xs text-slate-400 font-semibold mb-1">Usuarios Activos</div>
                <div class="text-2xl font-bold text-secondary"><%= totalUsuarios %></div>
                <div class="text-[11px] text-slate-400 mt-1">Cuentas con acceso al sistema</div>
            </div>
            <div class="bg-white p-6 rounded-2xl shadow-sm border border-slate-100">
                <div class="text-xs text-slate-400 font-semibold mb-1">Cartera de Clientes</div>
                <div class="text-2xl font-bold text-blue-600"><%= totalClientes %></div>
                <div class="text-[11px] text-slate-400 mt-1">Empresas y personas registradas</div>
            </div>
            <div class="bg-white p-6 rounded-2xl shadow-sm border border-slate-100">
                <div class="text-xs text-slate-400 font-semibold mb-1">Inventario Actual</div>
                <div class="text-2xl font-bold text-amber-600"><%= totalProductos %></div>
                <div class="text-[11px] text-slate-400 mt-1">Productos y mercadería disponible</div>
            </div>
        </div>

        <div class="bg-white p-8 rounded-2xl shadow-sm border border-slate-100">
            <h3 class="text-lg font-bold mb-4">Resumen de Cobertura Operativa</h3>
            <div class="space-y-4 text-sm">
                <div class="flex justify-between py-2 border-b border-slate-100">
                    <span class="text-slate-600 font-medium">Módulo 3 (Usuarios Registrados)</span>
                    <span class="font-bold text-slate-900"><%= totalUsuarios %> registros</span>
                </div>
                <div class="flex justify-between py-2 border-b border-slate-100">
                    <span class="text-slate-600 font-medium">Módulo 4 (Clientes Corporativos)</span>
                    <span class="font-bold text-slate-900"><%= totalClientes %> registros</span>
                </div>
                <div class="flex justify-between py-2 border-b border-slate-100">
                    <span class="text-slate-600 font-medium">Módulo 5 (Proveedores Asociados)</span>
                    <span class="font-bold text-slate-900"><%= totalProveedores %> registros</span>
                </div>
                <div class="flex justify-between py-2 border-b border-slate-100">
                    <span class="text-slate-600 font-medium">Módulo 6 (Productos en Stock)</span>
                    <span class="font-bold text-slate-900"><%= totalProductos %> registros</span>
                </div>
                <div class="flex justify-between py-2">
                    <span class="text-slate-600 font-medium">Módulo 7 (Ventas Procesadas)</span>
                    <span class="font-bold text-slate-900"><%= totalVentas %> operaciones</span>
                </div>
            </div>
        </div>
    </main>
</body>
</html>
