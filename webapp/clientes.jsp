<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@page import="com.aegisid.repository.ClienteRepository"%>
<%@page import="java.util.List"%>
<%@page import="java.util.Map"%>
<%
    // Validar sesión activa
    String usuarioSesion = (String) session.getAttribute("usuario");
    if (usuarioSesion == null) {
        response.sendRedirect("login.jsp");
        return;
    }

    String mensaje = "";
    String tipoMensaje = "";
    ClienteRepository repo = new ClienteRepository();

    // Variables para edición
    String editId = "", editNombre = "", editCorreo = "", editTelefono = "", editDireccion = "";
    boolean modoEdicion = false;

    try {
        String accion = request.getParameter("accion");
        if ("crear".equalsIgnoreCase(accion)) {
            repo.crear(request.getParameter("nombre"), request.getParameter("correo"), request.getParameter("telefono"), request.getParameter("direccion"));
            mensaje = "Cliente registrado exitosamente.";
            tipoMensaje = "success";
        } else if ("actualizar".equalsIgnoreCase(accion)) {
            repo.actualizar(request.getParameter("id_cliente"), request.getParameter("nombre"), request.getParameter("correo"), request.getParameter("telefono"), request.getParameter("direccion"));
            mensaje = "Cliente actualizado correctamente.";
            tipoMensaje = "success";
        } else if ("eliminar".equalsIgnoreCase(accion)) {
            repo.eliminar(request.getParameter("id"));
            mensaje = "Cliente eliminado correctamente.";
            tipoMensaje = "success";
        } else if ("preeditar".equalsIgnoreCase(accion)) {
            // Cargar datos específicos para edición
            String idEdit = request.getParameter("id");
            List<Map<String, String>> todos = repo.listarTodos();
            for(Map<String, String> c : todos) {
                if(c.get("id_cliente").equals(idEdit)) {
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
