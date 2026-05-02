<%-- 
    Document   : Feedbacksubmitted
    Created on : Dec 24, 2015, 2:22:38 PM
    Author     : Administrator
--%>
<%@page import="com.constants.Constants"%>
<%@page import="com.constants.MailSending"%>
<%@page import="java.sql.ResultSet"%>
<%@page import="java.sql.DriverManager"%>
<%@page import="java.sql.Statement"%>
<%@page import="java.sql.Connection"%>
<%@page import="java.sql.Connection"%>
<%@page contentType="text/html" pageEncoding="UTF-8"%>
<html>
    <head>
        <meta charset="UTF-8">
        <script src="Js/Formvalidation.js"></script>
        <link rel="stylesheet" href="Css/bootstrap.min.css">
        <link rel="stylesheet" href="Css/Menustyles.css">
        <script src="Js/jquery-1.10.2.js"></script>
        <title>SARAT FeedBack submission</title>
        <link rel="stylesheet" href="Css/style.css" type="text/css">
    </head>
    <body>
        <div id="background">
            <%@include file="Login_Header.jsp" %>
            <div class="contentpage" style="min-height: 100px;">
                <%
                    if ((session.getAttribute("userid") == null) || (session.getAttribute("userid") == "")) {
                %>
                <br/>
                <%       String message = "please login";
                        response.sendRedirect("login.jsp?message=" + message);
                        return;
                    }
                %>
                <%
                    String mail_id = request.getParameter("mail_id");
                    String name = request.getParameter("name");
                    String designantion = request.getParameter("designantion");
                    String organization = request.getParameter("organization");
                    String feedback = request.getParameter("feedback");
                    String suggestions = request.getParameter("suggestions");
                    Connection con = new Constants().db_connection();
                    Statement st = con.createStatement();

                    int recordes_inserted = st.executeUpdate("insert into t_feedback values('" + mail_id + "','" + name + "','" +designantion + "','" + organization + "','" + feedback + "','" + suggestions + "')");
                    if (recordes_inserted >= 1) {
                        try
                        {
                           (new MailSending()).SendIntimation(name,mail_id,"Feedback From:"+name,"FeedBack:\n"+feedback+"\nSuggestion:\n"+suggestions); 
                        }catch(Exception e){
                        
                        }
                %>
                <br>
                <center>
                    <strong>
                         <font style="font-size: 18px;color:gray"><fmt:message key="feedback.label.success1" />.</font><br>
                            <font style="font-weight: bold;font-size: 18px;"><fmt:message key="feedback.label.success2" /></font>
                    </strong>
                </center>
                <%
                } else {
                      
                      response.sendRedirect("Feedback.jsp");
                }
                %>
            </div>
            <center>©INCOIS search and Rescue. All Rights Reserved</center>
        </div>

    </body> 
</html>