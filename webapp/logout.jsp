<%-- 
    Document   : logout
    Created on : Dec 15, 2015, 11:01:15 AM
    Author     : Administrator
--%>
<%@ page contentType="text/html; charset=UTF-8" %>
<%@ page import="java.util.*"%>
<%@ page import="javax.servlet.*" %>
<%@ page import="javax.servlet.http.*" %>
<html>
    <head>
        <title>Logout</title>
    </head>
    <body>
        <%session.invalidate();%>
        <%      response.sendRedirect("home.jsp");
        %>
    </body>
</html>