<%@ page language="java" contentType="text/csv; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*" %>
<%
response.setHeader("Content-Disposition", "attachment; filename=\"students.csv\"");

Connection conn = null;
PreparedStatement pstmt = null;
ResultSet rs = null;

try {
    Class.forName("com.mysql.cj.jdbc.Driver");
    conn = DriverManager.getConnection(
        "jdbc:mysql://localhost:3306/student_management",
        "root",
        "anhquan3107"
    );
    String sql = "SELECT id, student_code, full_name, email, major FROM students ORDER BY id DESC";
    pstmt = conn.prepareStatement(sql);
    rs = pstmt.executeQuery();

    out.println("ID,Student Code,Full Name,Email,Major");

    while (rs.next()) {
        out.println(
            rs.getInt("id") + "," +
            rs.getString("student_code") + "," +
            rs.getString("full_name") + "," +
            rs.getString("email") + "," +
            rs.getString("major") + ","
        );
    }

} catch (ClassNotFoundException e) {
    out.println("Error: JDBC Driver not found!");
    e.printStackTrace();
} catch (SQLException e) {
    out.println("Database Error: " + e.getMessage());
    e.printStackTrace();
} finally {
    try {
        if (rs != null) rs.close();
        if (pstmt != null) pstmt.close();
        if (conn != null) conn.close();
    } catch (SQLException e) {
        e.printStackTrace();
    }
}
%>
