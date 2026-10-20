<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@page import="aegisid.repository.ClienteRepository"%>
<%@page import="java.util.List"%>
<%@page import="java.util.Map"%>
<%
    // 1. Validar sesión activa
    String usuarioSesion = (String) session.getAttribute("usuario");
    if (usuarioSesion == null) {
        response.sendRedirect("login.jsp");
        return;
    }

    String mensaje = "";
    String tipoMensaje = "";
    ClienteRepository repo = new ClienteRepository();

    // Variables para el formulario de edición de clientes
    String editId = "";
    String editNombre = "";
    String editCorreo = "";
    String editTelefono = "";
    String editDireccion = "";
    boolean modoEdicion = false;

    try {
        String accion = request.getParameter("accion");
        if ("crear".equalsIgnoreCase(accion)) {
            repo.crear(
                request.getParameter("nombre"),
                request.getParameter("correo"),
                request.getParameter("telefono"),
                request.getParameter("direccion")
            );
            mensaje = "Cliente registrado exitosamente.";
            tipoMensaje = "success";
        } else if ("actualizar".equalsIgnoreCase(accion)) {
            repo.actualizar(
                request.getParameter("id_cliente"),
                request.getParameter("nombre"),
                request.getParameter("correo"),
                request.getParameter("telefono"),
                request.getParameter("direccion")
            );
            mensaje = "Cliente actualizado correctamente.";
            tipoMensaje = "success";
        } else if ("eliminar".equalsIgnoreCase(accion)) {
            repo.eliminar(request.getParameter("id"));
            mensaje = "Cliente eliminado correctamente.";
            tipoMensaje = "success";
        } else if ("preeditar".equalsIgnoreCase(accion)) {
            String idEdit = request.getParameter("id");
            List<Map<String, String>> todos = repo.listarTodos();
            for (Map<String, String> c : todos) {
                if (c.get("id_cliente").equals(idEdit)) {
                    editId = c.get("id_cliente");
                    editNombre = c.get("nombre");
                    editCorreo = c.get("correo");
                    editTelefono = c.get("telefono") != null ? c.get("telefono") : "";
                    editDireccion = c.get("direccion") != null ? c.get("direccion") : "";
                    modoEdicion = true;
                    break;
                }
            }
        }
    } catch (Exception e) {
        mensaje = "Error en base de datos: " + e.getMessage();
        tipoMensaje = "error";
    }
%>
<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Aegis ID - Gestión de Clientes</title>
    <link href="https://fonts.googleapis.com/css2?family=Plus+Jakarta+Sans:wght@400;500;600;700&display=swap" rel="stylesheet"/>
    <link href="https://fonts.googleapis.com/css2?family=Material+Symbols+Outlined:wght,FILL@100..700,0..1&display=swap" rel="stylesheet"/>
    <style>html,body{margin:0;padding:0;}body{overscroll-behavior:none;}::-webkit-scrollbar{display:none;}</style>
    <script src="https://cdn.tailwindcss.com"></script>
    <script>
    tailwind.config={theme:{extend:{colors:{"on-surface":"#131b2e","primary":"#070235","secondary":"#4e45d5","surface-container":"#eaedff","surface":"#faf8ff","surface-container-low":"#f2f3ff","error":"#ba1a1a"}}}}
    </script>
</head>
<body class="bg-surface text-on-surface min-h-screen font-sans" style="font-family:'Plus Jakarta Sans',sans-serif;">

    <!-- Barra Superior -->
    <header class="bg-primary text-white shadow-md">
        <div class="max-w-7xl mx-auto px-6 h-20 flex items-center justify-between">
            <div class="flex items-center gap-3">
                <a href="bienvenido.jsp" class="w-10 h-10 rounded-xl bg-white/10 flex items-center justify-center hover:bg-white/20 transition-all">
                    <span class="material-symbols-outlined text-white text-[24px]">arrow_back</span>
                </a>
                <div>
                    <h1 class="text-lg font-bold tracking-tight">Módulo 4: Gestión de Clientes</h1>
                    <p class="text-xs text-indigo-200">Cartera y control de datos comerciales</p>
                </div>
            </div>
            
            <div class="flex items-center gap-4">
                <div class="text-right hidden sm:block">
                    <div class="text-xs text-indigo-200">Conectado como:</div>
                    <div class="text-sm font-semibold text-white"><%= usuarioSesion %></div>
                </div>
                <a href="bienvenido.jsp?accion=salir" class="px-4 py-2 rounded-xl bg-red-600/20 hover:bg-red-600 text-red-200 hover:text-white text-xs font-semibold transition-all border border-red-500/30 flex items-center gap-2">
                    <span class="material-symbols-outlined text-[18px]">logout</span>
                    <span>Salir</span>
                </a>
            </div>
        </div>
    </header>

    <!-- Contenido Principal -->
    <main class="max-w-7xl mx-auto px-6 py-10">

        <% if (!mensaje.isEmpty()) { %>
        <div class="mb-6 p-4 rounded-xl text-sm font-semibold text-center <% if("error".equals(tipoMensaje)) { %> bg-red-100 text-red-800 border border-red-300 <% } else { %> bg-emerald-50 text-emerald-800 border border-emerald-200 <% } %>">
            <%= mensaje %>
        </div>
        <% } %>

        <div class="grid grid-cols-1 lg:grid-cols-3 gap-8">
            
            <!-- Formulario dinámico (Crear o Modificar Cliente) -->
            <div class="bg-white p-6 rounded-2xl shadow-sm border border-slate-100 h-fit">
                <h2 class="text-xl font-bold text-slate-900 mb-1"><%= modoEdicion ? "Modificar Cliente" : "Registrar Nuevo Cliente" %></h2>
                <p class="text-xs text-slate-500 mb-6"><%= modoEdicion ? "Actualiza la información del cliente seleccionado." : "Añade nuevos datos a la cartera de clientes." %></p>

                <form method="post" action="clientes.jsp" class="space-y-4">
                    <input type="hidden" name="accion" value="<%= modoEdicion ? "actualizar" : "crear" %>">
                    <% if (modoEdicion) { %>
                    <input type="hidden" name="id_cliente" value="<%= editId %>">
                    <% } %>

                    <div>
                        <label class="text-xs text-slate-700 font-semibold block mb-1.5">Nombre / Razón Social</label>
                        <input type="text" name="nombre" required placeholder="Ej. Empresa SAC o Juan Pérez" value="<%= editNombre %>"
                               class="w-full h-[46px] px-4 rounded-xl border border-slate-200 text-sm outline-none focus:ring-2 focus:ring-secondary/40"/>
                    </div>

                    <div>
                        <label class="text-xs text-slate-700 font-semibold block mb-1.5">Correo Electrónico</label>
                        <input type="email" name="correo" required placeholder="cliente@correo.com" value="<%= editCorreo %>"
                               class="w-full h-[46px] px-4 rounded-xl border border-slate-200 text-sm outline-none focus:ring-2 focus:ring-secondary/40"/>
                    </div>

                    <div>
                        <label class="text-xs text-slate-700 font-semibold block mb-1.5">Teléfono / Celular</label>
                        <input type="text" name="telefono" placeholder="+51 999 999 999" value="<%= editTelefono %>"
                               class="w-full h-[46px] px-4 rounded-xl border border-slate-200 text-sm outline-none focus:ring-2 focus:ring-secondary/40"/>
                    </div>

                    <div>
                        <label class="text-xs text-slate-700 font-semibold block mb-1.5">Dirección Comercial</label>
                        <input type="text" name="direccion" placeholder="Av. Principal 123, Lima" value="<%= editDireccion %>"
                               class="w-full h-[46px] px-4 rounded-xl border border-slate-200 text-sm outline-none focus:ring-2 focus:ring-secondary/40"/>
                    </div>

                    <div class="flex gap-3 pt-2">
                        <button type="submit" class="flex-1 h-[48px] rounded-xl bg-secondary hover:bg-indigo-700 text-white font-semibold text-sm shadow-md transition-all flex items-center justify-center gap-2">
                            <span class="material-symbols-outlined text-[20px]"><%= modoEdicion ? "save" : "person_add" %></span>
                            <span><%= modoEdicion ? "Actualizar Cliente" : "Guardar Cliente" %></span>
                        </button>
                        <% if (modoEdicion) { %>
                        <a href="clientes.jsp" class="px-4 h-[48px] rounded-xl bg-slate-100 hover:bg-slate-200 text-slate-700 font-semibold text-sm transition-all flex items-center justify-center">
                            Cancelar
                        </a>
                        <% } %>
                    </div>
                </form>
            </div>

            <!-- Listado de Clientes (Tabla CRUD) -->
            <div class="lg:col-span-2 bg-white p-6 rounded-2xl shadow-sm border border-slate-100">
                <h2 class="text-xl font-bold text-slate-900 mb-1">Cartera de Clientes</h2>
                <p class="text-xs text-slate-500 mb-6">Listado general de clientes registrados en el sistema.</p>

                <div class="overflow-x-auto">
                    <table class="w-full text-left border-collapse">
                        <thead>
                            <tr class="border-b border-slate-100 text-xs text-slate-400 uppercase tracking-wider">
                                <th class="py-3 px-4 font-semibold">ID</th>
                                <th class="py-3 px-4 font-semibold">NOMBRE</th>
                                <th class="py-3 px-4 font-semibold">CONTACTO</th>
                                <th class="py-3 px-4 font-semibold">ESTADO</th>
                                <th class="py-3 px-4 font-semibold text-center">ACCIONES</th>
                            </tr>
                        </thead>
                        <tbody class="text-sm divide-y divide-slate-100">
                            <%
                                try {
                                    List<Map<String, String>> listaClientes = repo.listarTodos();
                                    for (Map<String, String> cl : listaClientes) {
                                        String idCl = cl.get("id_cliente");
                                        String nomCl = cl.get("nombre");
                                        String corCl = cl.get("correo");
                                        String telCl = cl.get("telefono") != null ? cl.get("telefono") : "-";
                                        String estCl = cl.get("estado") != null ? cl.get("estado") : "Activo";
                            %>
                            <tr class="hover:bg-slate-50/50">
                                <td class="py-3.5 px-4 text-slate-600 font-medium">#<%= idCl %></td>
                                <td class="py-3.5 px-4 text-slate-900 font-semibold"><%= nomCl %></td>
                                <td class="py-3.5 px-4 text-xs text-slate-600">
                                    <div><%= corCl %></div>
                                    <div class="text-slate-400"><%= telCl %></div>
                                </td>
                                <td class="py-3.5 px-4">
                                    <span class="px-2.5 py-1 rounded-full bg-blue-50 text-blue-600 text-xs font-semibold"><%= estCl %></span>
                                </td>
                                <td class="py-3.5 px-4 text-center">
                                    <div class="flex items-center justify-center gap-2">
                                        <!-- Botón Editar -->
                                        <a href="clientes.jsp?accion=preeditar&id=<%= idCl %>" 
                                           class="inline-flex items-center justify-center w-8 h-8 rounded-lg bg-indigo-50 text-secondary hover:bg-indigo-100 transition-all" title="Modificar">
                                            <span class="material-symbols-outlined text-[18px]">edit</span>
                                        </a>
                                        <!-- Botón Eliminar -->
                                        <a href="clientes.jsp?accion=eliminar&id=<%= idCl %>" 
                                           onclick="return confirm('¿Estás seguro de eliminar este cliente?');"
                                           class="inline-flex items-center justify-center w-8 h-8 rounded-lg bg-red-50 text-red-600 hover:bg-red-100 transition-all" title="Eliminar">
                                            <span class="material-symbols-outlined text-[18px]">delete</span>
                                        </a>
                                    </div>
                                </td>
                            </tr>
                            <%
                                    }
                                } catch(Exception ex) {
                            %>
                            <tr>
                                <td colspan="5" class="py-4 text-center text-red-500 text-xs">Error al cargar listado: <%= ex.getMessage() %></td>
                            </tr>
                            <% } %>
                        </tbody>
                    </table>
                </div>
            </div>

        </div>
    </main>

</body>
</html>
