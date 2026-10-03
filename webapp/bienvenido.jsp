<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%
    String usuario = (String) session.getAttribute("usuario");
    if (usuario == null) {
        response.setStatus(302);
        response.setHeader("Location", "login.jsp");
        return;
    }
    if ("salir".equals(request.getParameter("accion"))) {
        session.invalidate();
        response.setStatus(302);
        response.setHeader("Location", "login.jsp");
        return;
    }
%>
<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <title>Bienvenido</title>
</head>
<body style="font-family: Arial, sans-serif; text-align: center; margin-top: 80px;">
    <h1>¡Bienvenido!</h1>
    <p>Iniciaste sesión como: <b><%= usuario %></b></p>
    <p><a href="bienvenido.jsp?accion=salir">Cerrar sesión</a></p>
</body>
</html>
