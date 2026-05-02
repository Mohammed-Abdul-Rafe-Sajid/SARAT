<%-- 
    Document   : login
    Created on : Sep 24, 2015, 1:36:52 PM
    Author     : Administrator
--%>
<%@page import="java.sql.PreparedStatement"%>
<%@page import="com.constants.Constants"%>
<%@page import="java.sql.ResultSet"%>
<%@page import="java.sql.DriverManager"%>
<%@page import="java.sql.Statement"%>
<%@page import="java.sql.Connection"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%
    String message = "The username or Password is incoreect.";
    String userid = request.getParameter("email");
    String pwd = request.getParameter("password");
     //Class.forName(Constants.db_driver);
     //Connection con = DriverManager.getConnection(Constants.db_url,Constants.db_username,Constants.db_password);
    Connection con = new Constants().db_connection();
    PreparedStatement st = con.prepareStatement("select * from t_users where mail_id=? and password=?");
    st.setString(1, userid);
    st.setString(2, pwd);
    ResultSet rs;
    rs=st.executeQuery();
  //rs = st.executeQuery("select * from t_users where mail_id='" + userid + "' and password='" + pwd + "'");
    if (rs.next()) {
        session.setAttribute("userid", userid);
        rs.close();
        st.close();
        con.close();
        response.sendRedirect("Main.jsp");
    } else {
        rs.close();
        st.close();
        con.close();
        response.sendRedirect("login.jsp?message=" + message);
    }
%>

