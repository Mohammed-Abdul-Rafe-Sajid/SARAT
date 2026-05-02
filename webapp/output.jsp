<%-- 
    Document   : output
    Created on : Oct 30, 2015, 12:44:02 PM
    Author     : Administrator
--%>
<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<c:set var="language" value="${not empty param.language ? param.language : not empty language ? language : pageContext.request.locale}" scope="session" />
<fmt:setLocale value="${language}" />
<fmt:setBundle basename="text" />
<%@page import="java.sql.Time"%>
<%@page import="java.util.GregorianCalendar"%>
<%@page import="java.util.Calendar"%>
<%@page import="java.util.Date"%>
<%@page import="java.text.SimpleDateFormat"%>
<html>
    <head>
        <meta charset="UTF-8">
        <link rel="stylesheet" href="Css/Menustyles.css">
        <title>SARAT Model Output</title>
        <link rel="stylesheet" href="Css/style.css" type="text/css">
        <script src="Js/jquery-1.10.2.js"></script>
        <script src="Js/script.js"></script>
        
        <script>
        <fmt:message key="output.fail" var="modelfail" />
        <fmt:message key="output.land"  var="onland"/>
        <fmt:message key="output.donthave" var="noinputs"/>
        $(document).ready(function () {
            document.getElementById("language").disabled=true;
            /*alert(<%= "'" + session.getAttribute("userid") + "'"%>);
            var hash,invar;
            var todaydate="",req_id="";
            var hashes = window.location.href.slice(window.location.href.indexOf('?') + 1).split('&');
            if(hashes.length>0){
                    hash = hashes[0].split('=');invar = hash[1];
                    todaydate = invar;
                    hash = hashes[0].split('=');invar = hash[1];
                    req_id = invar;
            }*/
            $.ajax({
                url: 'Modelrun',
                data: {
                    request_id:<%=request.getParameter("request_id")%>
                },
                success: function (responseText) {
                    var result = responseText.toString().substring(7, 8);
                    if (result === '0')
                        $("#contents").replaceWith("<br><center><font size='5'>${modelfail}</font></center>");
                    if (result === '2')
                        $("#contents").replaceWith("<br><center><font size='5'>${onland}</font></center>");
                    if (result === '3')
                        $("#contents").replaceWith("<br><center><font size='5'>${noinputs}<font color=red size=24><%="'" + request.getParameter("request_id") + "'" +" id"%></font></font></center>");
                    if (result === '1')
                        window.location.href = "Output_Test.jsp?request_id="+<%=request.getParameter("request_id")%>;
                }   // $("#contents").html("<p>Due to some model error your request can't be processed</p>"
            });
        });
    </script>
    </head>
    <body>
        <div id="background">
            <%@include file="Login_Header.jsp" %>
            <div class="contentpage">
                <!-- div for contact page elements -->
                <div id="contents">
                    <%
                        if ((session.getAttribute("userid") == null) || (session.getAttribute("userid") == "")) {
                    %>
                    <br/>
                    <%       String message = "please login";
                            response.sendRedirect("login.jsp?message=" + message);
                            return;
                        }
                    %>
                    <center > <h2 style="font-size:22px;color:gray;padding-bottom:25px"> <fmt:message key="output.runmessage" />.<br><span style="font-size:16px;color:red">Please Don't Refresh the page</span></h2>
                        <br><image src="Images/please_wait.gif" height="200" alt="Please wait for result"/> 
                    </center>                    
                </div>
                <div id="result">
                </div>
            </div>
            <center>©INCOIS search and Rescue. All Rights Reserved</center>
        </div>
    </body> 
</html>