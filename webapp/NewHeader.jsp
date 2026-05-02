<%-- 
    Document   : NewHeader.jsp
    Created on : Nov 3, 2015, 4:15:28 PM
    Author     : Administrator
--%>
<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<c:set var="language" value="${not empty param.language ? param.language : not empty language ? language : pageContext.request.locale}" scope="session" />
<fmt:setLocale value="${language}" />
<fmt:setBundle basename="text" />
<div class="page">
    <link rel="stylesheet" href="Css/general.css">
    <link rel="stylesheet" href="Css/bootstrap.min.css">
    <div id="header">
        <div id="incois-header">
            <div style="padding-left: 20px;width:20%" align="left">
                <a href="http://www.incois.gov.in/portal/index.jsp" title="ESSO"><img src="Images/SARAT_2.png"  style="width:20%;height:20%" alt="" id="incois-logo-desktop" ></a>
            </div>           
          <div>
               <h1 align="center" style="font:28px Arial, Verdana, Helvetica, sans-serif;font-weight: bold;color:#191970;margin-right:15%;margin-left:19%;"><fmt:message key="header.sarat.title"/></h1> 
            </div>  
                      
            <div align="right" style="height:22px">
                <form>
                    <label>Language Switcher:</label>
                    <select id="language" name="language" onchange="submit()">
                        <option value="en" ${language == 'en' ? 'selected' : ''}>English</option>             
                        <option value="te" ${language == 'te' ? 'selected' : ''}>తెలుగు</option>
                        <option value="hi" ${language == 'hi' ? 'selected' : ''}>हिंदी</option>
                    </select>
                </form>
            </div>
        </div>
        
    </div>
            <nav class="navbar navbar-default navbar-static-top">
            <div id="navbar" class="navbar-collapse collapse ">
                <ul class="nav navbar-nav">
                    <li class=" dropdown"><a href="login.jsp" class=""><fmt:message key="menu.home" /></a></li>
                    <li class=" dropdown"><a href="login.jsp" class=""><fmt:message key="menu.about" /></a></li>
                    <li class=" dropdown"><a href="Registration.jsp" class=""><fmt:message key="menu.registration" /></a></li>
                    <li class=" dropdown"><a href="Contact.jsp" class=""><fmt:message key="menu.contactus" /></a></li>
                </ul>  
            </div>
        </nav>
</div>     