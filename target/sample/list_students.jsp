<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*" %>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>Student List</title>
    <style>
        body {
            font-family: Arial, sans-serif;
            margin: 20px;
            background-color: #f5f5f5;
        }
        h1 { color: #333; }
        .message {
            padding: 10px;
            margin-bottom: 20px;
            border-radius: 5px;
        }
        .success {
            background-color: #d4edda;
            color: #155724;
            border: 1px solid #c3e6cb;
        }
        .error {
            background-color: #f8d7da;
            color: #721c24;
            border: 1px solid #f5c6cb;
        }
        .btn {
            display: inline-block;
            padding: 10px 20px;
            margin-bottom: 20px;
            background-color: #007bff;
            color: white;
            text-decoration: none;
            border-radius: 5px;
        }
        table {
            width: 100%;
            border-collapse: collapse;
            background-color: white;
        }
        th {
            background-color: #007bff;
            color: white;
            padding: 12px;
            text-align: left;
        }
        td {
            padding: 10px;
            border-bottom: 1px solid #ddd;
        }
        tr:hover { background-color: #f8f9fa; }
        .action-link {
            color: #007bff;
            text-decoration: none;
            margin-right: 10px;
        }
        .delete-link { color: #dc3545; }

        .table-responsive {
            overflow-x: auto;
        }

        @media (max-width: 768px) {
            table {
                font-size: 12px;
            }
            th, td {
                padding: 5px;
            }
        }
    </style>
</head>
<body>
    <%!
    public int getTotalRecords() {
        int total = 0;
        Connection conn = null;
        Statement stmt = null;
        ResultSet rs = null;
        try {
            Class.forName("com.mysql.cj.jdbc.Driver");
            conn = DriverManager.getConnection(
                "jdbc:mysql://localhost:3306/student_management",
                "root",
                "anhquan3107"
            );
            String countSql = "SELECT COUNT(*) FROM students";
            stmt = conn.createStatement();
            rs = stmt.executeQuery(countSql);
            if (rs.next()) {
                total = rs.getInt(1);
            }
        } catch (Exception e) {
            e.printStackTrace();
        } finally {
            try { if (rs != null) rs.close(); } catch (SQLException ignored) {}
            try { if (stmt != null) stmt.close(); } catch (SQLException ignored) {}
            try { if (conn != null) conn.close(); } catch (SQLException ignored) {}
        }
        return total;
    }
    %>
    <%
        String sortBy = request.getParameter("sort");
        String order  = request.getParameter("order");
        if (sortBy == null) sortBy = "id";
        if (order  == null) order  = "desc";
    %>
    <h1>📚 Student Management System</h1>
    
    <% if (request.getParameter("message") != null) { %>
        <div class="message success">
            <span class="icon">✓</span>
            <%= request.getParameter("message") %>
        </div>
    <% } %>

    <% if (request.getParameter("error") != null) { %>
        <div class="message error">
            <span class="icon">✗</span>
            <%= request.getParameter("error") %>
        </div>
    <% } %>

    <form action="list_students.jsp" method="GET">
        <input type="text" name="keyword" placeholder="Search by name or code...">
        <button type="submit">Search</button>
        <a href="list_students.jsp">Clear</a>
    </form>
    <br>

    <a href="add_student.jsp" class="btn">➕ Add New Student</a>
    <form action="bulk_delete.jsp" method="POST" onsubmit="return confirm('Delete selected students?')">
        <button type="submit" class="btn delete-btn">🗑️ Delete Selected</button>
    
    <div class="table-responsive">
    <table>
        <thead>
            <tr>
                <th><input type="checkbox" id="selectAll" onclick="toggleAll(this)"></th>
                <th>ID</th>
                <th>Student Code</th>
                <th><a href="list_students.jsp?sort=full_name&order=<%= ("asc".equals(order) ? "desc" : "asc") %>">Full Name</a></th>
                <th>Email</th>
                <th>Major</th>
                <th><a href="list_students.jsp?sort=created_at&order=<%= ("asc".equals(order) ? "desc" : "asc") %>">Created At</a></th>
                <th>Actions</th>
            </tr>
        </thead>
        <tbody>
<%
    Connection conn = null;
    PreparedStatement pstmt = null;
    ResultSet rs = null;
            // Get page number from URL (default = 1)
    String pageParam = request.getParameter("page");
    int currentPage = (pageParam != null) ? Integer.parseInt(pageParam) : 1;

        // Records per page
    int recordsPerPage = 10;

        // Calculate offset
    int offset = (currentPage - 1) * recordsPerPage;

        // Get total records for pagination
    int totalRecords = getTotalRecords(); // You need to implement this
    int totalPages = (int) Math.ceil((double) totalRecords / recordsPerPage);
    
    try {
        Class.forName("com.mysql.cj.jdbc.Driver");
        
        conn = DriverManager.getConnection(
            "jdbc:mysql://localhost:3306/student_management",
            "root",
            "anhquan3107"
        );

        String sql = "";
        String keyword = request.getParameter("keyword");
        if (keyword != null && !keyword.isEmpty()) {
            // Search query with LIKE operator
            sql = "SELECT * FROM students WHERE full_name LIKE ? OR student_code LIKE ? OR major LIKE ? ORDER BY " + sortBy + " " + order + " LIMIT ? OFFSET ?";
            pstmt = conn.prepareStatement(sql);
            pstmt.setString(1, "%" + keyword + "%");
            pstmt.setString(2, "%" + keyword + "%");
            pstmt.setString(3, "%" + keyword + "%");
            pstmt.setInt(4, recordsPerPage); 
            pstmt.setInt(5, offset);  
        } else {
        // Normal query
            sql = "SELECT * FROM students ORDER BY " + sortBy + " " + order + " LIMIT ? OFFSET ?";
            pstmt = conn.prepareStatement(sql);
            pstmt.setInt(1, recordsPerPage); 
            pstmt.setInt(2, offset);   
        }
        rs = pstmt.executeQuery();
        
        while (rs.next()) {
            int id = rs.getInt("id");
            String studentCode = rs.getString("student_code");
            String fullName = rs.getString("full_name");
            String email = rs.getString("email");
            String major = rs.getString("major");
            Timestamp createdAt = rs.getTimestamp("created_at");
%>
            <tr>
                <td><input type="checkbox" name="selectedIds" value="<%= id %>"></td>
                <td><%= id %></td>
                <td><%= studentCode %></td>
                <td><%= fullName %></td>
                <td><%= email != null ? email : "N/A" %></td>
                <td><%= major != null ? major : "N/A" %></td>
                <td><%= createdAt %></td>
                <td>
                    <a href="edit_student.jsp?id=<%= id %>" class="action-link">✏️ Edit</a>
                    <a href="delete_student.jsp?id=<%= id %>" 
                       class="action-link delete-link"
                       onclick="return confirm('Are you sure?')">🗑️ Delete</a>
                </td>
            </tr>
<%
        }
    } catch (ClassNotFoundException e) {
        out.println("<tr><td colspan='7'>Error: JDBC Driver not found!</td></tr>");
        e.printStackTrace();
    } catch (SQLException e) {
        out.println("<tr><td colspan='7'>Database Error: " + e.getMessage() + "</td></tr>");
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
        </tbody>
    </table>
    </div>
    </form>
    <div class="pagination">
    <% if (currentPage > 1) { %>
        <a href="list_students.jsp?page=<%= currentPage - 1 %>">Previous</a>
    <% } %>
    
    <% for (int i = 1; i <= totalPages; i++) { %>
        <% if (i == currentPage) { %>
            <strong><%= i %></strong>
        <% } else { %>
            <a href="list_students.jsp?page=<%= i %>"><%= i %></a>
        <% } %>
    <% } %>
    
    <% if (currentPage < totalPages) { %>
        <a href="list_students.jsp?page=<%= currentPage + 1 %>">Next</a>
    <% } %>
</div>

    <a href="export_csv.jsp" class="btn">Export to CSV</a>

    <script>
        setTimeout(function() {
            var messages = document.querySelectorAll('.message');
            messages.forEach(function(msg) {
            msg.style.display = 'none';
        });
        }, 3000);
    </script>
    <script>
        function toggleAll(source) {
            const checkboxes = document.querySelectorAll('input[name="selectedIds"]');
            checkboxes.forEach(cb => cb.checked = source.checked);
        }
    </script>
</body>
</html>
