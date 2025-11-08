<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*" %>
<%
String[] ids = request.getParameterValues("selectedIds");

if (ids == null || ids.length == 0) {
    response.sendRedirect("list_students.jsp?error=No students selected for deletion");
    return;
}

Connection conn = null;
PreparedStatement pstmt = null;

try {
    Class.forName("com.mysql.cj.jdbc.Driver");
    conn = DriverManager.getConnection(
        "jdbc:mysql://localhost:3306/student_management",
        "root",
        "anhquan3107"
    );
    StringBuilder sb = new StringBuilder();
    for (int i = 0; i < ids.length; i++) {
        sb.append("?");
        if (i < ids.length - 1) sb.append(",");
    }
    String placeholders = sb.toString();
    String sql = "DELETE FROM students WHERE id IN (" + placeholders + ")";
    pstmt = conn.prepareStatement(sql);

    for (int i = 0; i < ids.length; i++) {
        pstmt.setInt(i + 1, Integer.parseInt(ids[i]));
    }

    int rowsDeleted = pstmt.executeUpdate();

    if (rowsDeleted > 0) {
        response.sendRedirect("list_students.jsp?message=Selected students deleted successfully");
    } else {
        response.sendRedirect("list_students.jsp?error=No records deleted");
    }

} catch (ClassNotFoundException e) {
    response.sendRedirect("list_students.jsp?error=JDBC Driver not found");
    e.printStackTrace();
} catch (SQLException e) {
    response.sendRedirect("list_students.jsp?error=Database Error: " + e.getMessage());
    e.printStackTrace();
} finally {
    try {
        if (pstmt != null) pstmt.close();
        if (conn != null) conn.close();
    } catch (SQLException e) {
        e.printStackTrace();
    }
}
%>
