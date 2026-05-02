<%-- 
    Document   : login
    Created on : Sep 24, 2015, 1:36:52 PM
    Author     : Administrator
--%>
<%@page contentType="text/html" pageEncoding="UTF-8"%>
<html>
    <head>
        <meta charset="UTF-8">
        <title>Search and Rescue login page</title>
        <!--  <link rel="stylesheet" href="Css/Menustyles.css">-->

        <script src="Js/Formvalidation.js"></script>
        <script src="Js/jquery-1.10.2.js"></script>
        <link rel="stylesheet" href="Css/style.css" type="text/css">
        <link rel="stylesheet" href="Css/jquery-ui.css" />
        <script>
            function SignUp()
            {
                document.loginForm.action = "Registration.jsp";
                document.loginForm.submit();             // Submit the page
                return true;
            }
            function SignIn()
            {
                if ($(".email").val() === "") {
                    alert($(".email").val());
                    $(".email").focus();
                    $(".errorBox").html("Please Enter your username");
                    return false;
                }
                if ($("#password").val() === "") {
                    $("#password").focus();
                    $("#errorBox").html("Please Enter your Password");
                    return false;
                }
                else {
                    document.loginForm.action = "Check.jsp";
                    document.loginForm.submit();
                    return true;
                }
            }
        </script>
        
    </head>
    <body style="background:#076fc8;">
        <div id="background" >
            <%@include file="Header.jsp" %>
            <div class="contentpage" style="border:thin #fbf9ee groove" align="center">
                <%--<div style="border:thin #fbf9ee groove" align="center">--%>
                <div id="contents">
                    <% String error = "";
                        String message = request.getParameter("message");
                        if (message != null) {
                            error =message;
                        } else {
                            error = "";
                        }
                    %> 
                    <br/>  
                    <form method="post" name="loginForm"> 
                        <div id="errorBox"></div>
                        <span style="color:red;font-size:16px"><%=error%>
                        </span>
                        <br/>
                        <table>
                            <tr>
                                <td>
                                    <fmt:message key="login.label.username" />:<font color="red">*&nbsp;&nbsp;&nbsp;</font>
                                </td>
                                <td colspan="2">
                                    <input type="text" name="email" id="email" required/><br/><br/>
                                </td>
                            </tr>
                            <tr>
                                <td>
                                    &nbsp;&nbsp;<fmt:message key="login.label.password" />:<font color="red">*</font>
                                </td>
                                <td colspan="2">
                                    <input type="password" name="password" id="password" required/>
                                </td>
                            </tr>
                            <tr>
                                <td colspan="3">
                                    <br>
                                </td>
                            </tr>
                            <tr>
                                <td colspan="3">
                                </td>
                            </tr>
                            <tr>
                                <td></td>
                                <td>
                                    <fmt:message key="login.button.signin" var="login" />

                                    <input type="submit" value="${login}" onclick="SignIn()"//>

                                </td>
                                <td style="padding-left: 15px">
                                    <fmt:message key="login.button.signup" var="signup" />

                                    <input type="submit" value="${signup}" onclick="SignUp()">

                                </td>
                            </tr> 
                            <tr>
                                <td colspan="3">
                                    <br>
                                </td>
                            </tr>
                            <tr>
                                <td></td>
                                <td colspan="2">
                                    <a href="ForgotPassword.jsp" class=""><fmt:message key="login.label.forgotpassword"/> ?</a>

                                </td>

                            </tr>
                        </table>
                        <br/>
                        <br/>  
                    </form>          
                </div>
            </div>
            <%--</div>--%>
            <center>©INCOIS search and Rescue. All Rights Reserved</center>
        </div>
    </body>
</html>