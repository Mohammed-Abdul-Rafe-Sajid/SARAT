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
        <div id="incois-header" style="width:100%;height:115px;overflow: auto">
            <div id="incois-logo" align="center" style="width:15%;padding-left:2px;float:left">
                <a href="http://www.incois.gov.in/portal/index.jsp" title="SARAT"><img style="width:90%;height:95%" src="logo.png" alt="" id="incois-logo-desktop" ></a>
            </div>
            <div id="incois-logo_right" style="width:10%;float:right">
<!--                    <label><fmt:message key="header.label.languageswitcher"/>:</label>-->
                <div align="right" style="padding-top:-30px">
                    <form>
                        <select id="language" name="language" onchange="submit()" style="width:90px">
                            <option value="en" ${language == 'en' ? 'selected' : ''}>English</option>             
                            <option value="te" ${language == 'te' ? 'selected' : ''}>తెలుగు</option>
                            <option value="hi" ${language == 'hi' ? 'selected' : ''}>हिंदी</option>
                            <option value="be" ${language == 'be' ? 'selected' : ''}>বাংলা</option>
                            <option value="gu" ${language == 'gu' ? 'selected' : ''}>ગુજરાતી</option>
                        </select>
                    </form>
                </div>
            </div>
            <div align="center" style="width:75%;float:center">
                <h1 style="font:48px Arial, Verdana, Helvetica, sans-serif; font-weight:bold;color:#060761;padding-top: 0px;margin-top: 0px">SARAT</h1>
                <!-- <h5 style="font-family:Verdana, Helvetica, sans-serif; font-weight:normal; font-size:14px; color:#b1b0b0; margin-left:19%; font-weight:bold;">Earth System Sciences Organisation (ESSO)</h5> -->
                <h2 style="font:30px Arial, Verdana, Helvetica, sans-serif;font-weight:normal;color:#191970;margin-bottom:5px;margin-top: -2px;padding: 0px"><fmt:message key="header.sarat.title"/></h2>
            </div>

            <!--            <div align="right" style="height:22px">
                            <form>
                                <label><fmt:message key="header.label.languageswitcher"/>:</label>
                                <select id="language" name="language" onchange="submit()">
                                    <option value="en" ${language == 'en' ? 'selected' : ''}>English</option>             
                                    <option value="te" ${language == 'te' ? 'selected' : ''}>తెలుగు</option>
                                    <option value="hi" ${language == 'hi' ? 'selected' : ''}>हिंदी</option>
                                </select>
                            </form>
                        </div>-->
        </div>
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
<%--<div class="page">
    <div id="header">        
        <image src="Images/incois_header_logo.png" alt="INCOIS-LOGO" align="center" style="width:100%;"/>
        <center style="height:25px"> <h1 id="headline" style="alignment-adjust: central">Search and Rescue Aided Tool(SARAT) </h1></center>
        <br>  
        <div id='cssmenu'>
            <ul>
                <li class='active'><a href='Main.jsp'><span>Home</span></a></li>
                <li><a href='login.jsp'><span>About</span></a></li>
<!--                <li><a href='Registration.jsp'><span>Registration</span></a></li>-->
                <li><a href='Feedback.jsp'><span>FeedBack</span></a></li>
                <li class='last'><a href='logout.jsp'><span>logout</span></a></li>
            </ul>
        </div>                              
    </div>
</div> --%>