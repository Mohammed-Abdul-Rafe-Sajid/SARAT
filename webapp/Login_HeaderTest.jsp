<%-- 
    Document   : HeaderTest
    Created on : Jun 23, 2016, 2:41:51 PM
    Author     : Administrator
--%>
<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<c:set var="language" value="${not empty param.language ? param.language : not empty language ? language : pageContext.request.locale}" scope="session" />
<fmt:setLocale value="${language}" />
<fmt:setBundle basename="text" />
<div class="page">
    <link rel="stylesheet" href="Css/style.css" type="text/css">
    <link rel="stylesheet" href="Css/general.css">
    <link rel="stylesheet" href="Css/bootstrap.min.css">
    <div id="header">
        <table style="width:100%;">
            <tr>
                <td style="width:20%;padding-left: 10px">
                    <img class="box" src="logo.png" alt="" id="incois-logo-desktop" style="width:65%;height:10%" >
                </td>
                <td style="width:80%;padding: 0px;margin: 0px;text-align: right" valign="top">
                    <table style="width:100%;>
                           <tr>
                           <td style="text-align:right;" valign="bottom">

                           <form>
                            <select id="language" name="language" onchange="submit()" style="font-size: 12px" >
                                <option value="en" ${language == 'en' ? 'selected' : ''}>English</option>             
                                <option value="te" ${language == 'te' ? 'selected' : ''}>తెలుగు</option>
                                <option value="hi" ${language == 'hi' ? 'selected' : ''}>हिंदी</option>
                                <option value="be" ${language == 'be' ? 'selected' : ''}>বাংলা</option>
                                <option value="gu" ${language == 'gu' ? 'selected' : ''}>ગુજરાતી</option>
                                <option value="or" ${language == 'or' ? 'selected' : ''}>ଓରିୟା</option>
                            </select>
                        </form>
                </td>
            </tr>
            <tr>
                <td style="padding-left: 25px;" valign="top">
                    <h1 style="font:30px Arial, Verdana, Helvetica, sans-serif; font-weight:bold;color:#060761;padding-top:0px;color:#191970;margin-top:-10px;margin-bottom: 0px"><fmt:message key="header.sarat.title"/></h1>
                    <h5 style="font-family:Verdana, Helvetica, sans-serif; font-weight:normal; font-size:15px; margin-left:15%;color:#b1b0b0;font-weight:bold;padding-top: -10px;margin-top:0px;margin-bottom: 0px">(<fmt:message key="header.sarat.tagline"/>)</h5>
                </td>
            </tr>                        

        </table>
        </td>
        </tr>
        </table>
        <nav class="navbar navbar-default navbar-static-top">
            <div id="navbar" class="navbar-collapse collapse ">
                <ul class="nav navbar-nav">
                    <li class=" dropdown"><a href="Main.jsp" class=""><fmt:message key="menu.newrequest" /></a></li>
                    <li class=" dropdown"><a href="welcome.jsp" class=""><fmt:message key="menu.oldrequest" /></a></li>
                    <li class=" dropdown"><a href="Feedback.jsp" class=""><fmt:message key="menu.feedback" /></a></li>
                    <li class=" dropdown"><a href="logout.jsp" class=""><fmt:message key="menu.logout" /></a></li>
                </ul>  
            </div>
        </nav>        
    </div>
</div>
