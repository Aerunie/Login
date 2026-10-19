package com.aegisid.repository;

import com.aegisid.config.DatabaseConnection;
import java.sql.*;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

public class ClienteRepository {

    public ClienteRepository() {
        asegurarTabla();
    }

    private void asegurarTabla() {
        String sql = "CREATE TABLE IF NOT EXISTS clientes ("
                   + "id_cliente INT AUTO_INCREMENT PRIMARY KEY, "
                   + "nombre VARCHAR(150) NOT NULL, "
                   + "correo VARCHAR(100) NOT NULL UNIQUE, "
                   + "telefono VARCHAR(20), "
                   + "direccion VARCHAR(200), "
                   + "estado VARCHAR(15) DEFAULT 'Activo')";
        try (Connection conn = DatabaseConnection.getInstance().getConnection();
             Statement st = conn.createStatement()) {
            st.executeUpdate(sql);
        } catch (SQLException e) {
            e.printStackTrace();
        }
    }

    public void crear(String nombre, String correo, String telefono, String direccion) throws SQLException {
        String sql = "INSERT INTO clientes (nombre, correo, telefono, direccion, estado) VALUES (?, ?, ?, ?, 'Activo')";
        try (Connection conn = DatabaseConnection.getInstance().getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, nombre);
            ps.setString(2, correo);
            ps.setString(3, telefono);
            ps.setString(4, direccion);
            ps.executeUpdate();
        }
    }

    public void actualizar(String id, String nombre, String correo, String telefono, String direccion) throws SQLException {
        String sql = "UPDATE clientes SET nombre = ?, correo = ?, telefono = ?, direccion = ? WHERE id_cliente = ?";
        try (Connection conn = DatabaseConnection.getInstance().getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, nombre);
            ps.setString(2, correo);
            ps.setString(3, telefono);
            ps.setString(4, direccion);
            ps.setString(5, id);
            ps.executeUpdate();
        }
    }

    public void eliminar(String id) throws SQLException {
        String sql = "DELETE FROM clientes WHERE id_cliente = ?";
        try (Connection conn = DatabaseConnection.getInstance().getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, id);
            ps.executeUpdate();
        }
    }

    public List<Map<String, String>> listarTodos() throws SQLException {
        List<Map<String, String>> lista = new ArrayList<>();
        String sql = "SELECT id_cliente, nombre, correo, telefono, direccion, estado FROM clientes";
        try (Connection conn = DatabaseConnection.getInstance().getConnection();
             Statement st = conn.createStatement();
             ResultSet rs = st.executeQuery(sql)) {
            while (rs.next()) {
                Map<String, String> map = new HashMap<>();
                map.put("id_cliente", rs.getString("id_cliente"));
                map.put("nombre", rs.getString("nombre"));
                map.put("correo", rs.getString("correo"));
                map.put("telefono", rs.getString("telefono"));
                map.put("direccion", rs.getString("direccion"));
                map.put("estado", rs.getString("estado"));
                lista.add(map);
            }
        }
        return lista;
    }
}
