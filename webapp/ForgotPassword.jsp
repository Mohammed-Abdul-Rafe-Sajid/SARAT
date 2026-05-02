
<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<c:set var="language" value="${not empty param.language ? param.language : not empty language ? language : pageContext.request.locale}" scope="session" />
<fmt:setLocale value="${language}" />
<fmt:setBundle basename="text" />
<html>
    <head>
        <meta charset="UTF-8">
        <title>Search and Rescue login page</title>
        <script src="Js/Formvalidation.js"></script>
        <script src="Js/jquery-1.10.2.js"></script>
        <link rel="stylesheet" href="Css/jquery-ui.css" />
        <link rel="stylesheet" href="Css/style.css" type="text/css">
        <script>
            function PasswordRecovery()
            {
                <fmt:message key="forgotpwd.alert.mailidabscent" var="mailidabscent"/>
                <fmt:message key="forgotpwd.alert.fail" var="fail"/>
                <fmt:message key="forgotpwd.alert.success" var="success"/>
                var mailid = $("#email").val();
                if ($("#email").val() === "") {
                    $("#email").focus();
                    $("#errorBox").replaceWith("<center><font size='4' color='red'>${mailidabscent}</font></center>");
                    return false;
                }
                else {
                    console.log("Calling PasswordRecovery with mailid = " + mailid);
                    $.ajax({
                        type: "POST",
                        url: 'PasswordRecovery',
                        data: {
                            username: mailid
                        },
                        success: function (responseText) {
                            
                            var result = responseText.toString().substring(7, 8);
                            if (result === '0')
                                $("#errorBox").replaceWith("<br><center><font size='4' color='red'> '" + mailid + "' </font>${fail}</center>");
                            if (result === '1')
                                $("#errorBox").replaceWith("<br><center><font size='4'>${success}'<font color='red' size='4'>" + mailid + " '</font></center>");
                            if (result === '2')
                                $("#errorBox").replaceWith("<br><center><font size='4' color='red'> Failure while sending password recovery email to '" + mailid + "' </font></center>");
                        }
                    });
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
                        String Password = request.getParameter("password");
                        if (Password != null && Password.equals("0")) {
                            error = "";
                        } else {
                            error = "";
                        }
                    %> 
                    <br/>  
                    <div id="errorBox">
                        <font style="font-weight: 30"><fmt:message key="forgotpwd.alert.help" /></font>
                    </div>
                    <br/>
                    <table>
                        <tr>
                            <td colspan="3">
                            </td>
                        </tr>  
                        <tr>
                            <td colspan="3">
                                <br/>
                            </td>
                        </tr>  
                        <tr>
                            <td>
                                <fmt:message key="forgotpwd.label.registeredmailid" />:<font color="red">*&nbsp;&nbsp;&nbsp;</font>
                            </td>
                            <td colspan="2">
                                <input type="text" name="email" id="email"/><br/><br/>
                            </td>
                        </tr>   
                        <tr>
                            <td colspan="3" align="center" >
                                <fmt:message key="forgotpwd.button.submit" var="submit" />
                                <input type="submit" value="${submit}" onclick="PasswordRecovery();
                                        this.diable = true" >
                            </td>
                        </tr> 
                    </table>
                    <br/>
                    <br/> 
                </div>
            </div>
            <%--</div>--%>
            <center>©INCOIS search and Rescue. All Rights Reserved</center>
        </div>
    </body>
</html>