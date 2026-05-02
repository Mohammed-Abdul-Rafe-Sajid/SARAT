<%-- 
    Document   : Feedback
    Created on : Dec 23, 2015, 4:25:33 PM
    Author     : Administrator
--%>
<%@page import="com.constants.MissingObject"%>
<%@page import="java.lang.String"%>
<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@page import="java.sql.PreparedStatement"%>
<%@page import="com.constants.Constants"%>
<%@page import="java.sql.ResultSet"%>
<%@page import="java.sql.DriverManager"%>
<%@page import="java.sql.Statement"%>
<%@page import="java.sql.Connection"%>
<html>
    <head>
        <meta charset="UTF-8">
        <script src="Js/Formvalidation.js"></script>
        <link rel="stylesheet" href="Css/bootstrap.min.css">
        <link rel="stylesheet" href="Css/Menustyles.css">
        <link rel="stylesheet" href="Css/jquery-ui.css" />
        <script src="Js/jquery-1.10.2.js"></script>
        <script src="Js/jquery-ui.js"></script>
        <title>SARAT FeedBack page</title>
        <link rel="stylesheet" href="Css/style.css" type="text/css">
        <style type="text/css">
            .row{

                width:100%;
            }
            .clickable{
                cursor: pointer;   
            }

            .panel-heading div {
                margin-top: -18px;
                font-size: 15px;
            }
            .panel-heading div span{
                margin-left:5px;
            }
            .panel-body{
                display: none;
            }
            .close-btn { 
                border: 2px solid #c2c2c2;
                float:right;
                position: relative;
                padding: 1px 5px;
                top: -10px;
                background-color: #605F61;
                right: -10px; 
                border-radius: 20px;                
            }
            .close-btn a {
                font-size: 15px;
                font-weight: bold;
                color: white;
                text-decoration: none;
            }

        </style>>
        <script>
                    var request_id
                    $(document).ready(function (){
            request_id = <%=request.getParameter("request_id")%>;
                    if (request_id == null){
            $("#requestDetails").hide();
                    $("#userSection").css("width", "100%");
            }
            else{

            $("#userSection").css("width", "50%");
                    $("#requestDetails").show();
            }
            });
                    function change() {
                    request_id = document.history_form.request_id.value;
                            if (document.history_form.request_id.value != "")
                    {
                    $("#topdf").attr("href", "data/pdf/bulletein-" + document.history_form.request_id.value + ".pdf");                    
                    $("#tomap").attr("href", "Output_Test.jsp?request_id=" + document.history_form.request_id.value);
                    }
                    else {
                    $("#topdf").removeAttr("href");
                            $("#tomap").removeAttr("href");
                    }
                    }
                    $('#request_id').change(function () {
                    request_id = document.history_form.request_id.value;
//                            alert(data/pdf/bulletein-" + $(this).val() + ".pdf");
                            $("#topdf").attr("href", "data/pdf/bulletein-" + $(this).val() + ".pdf");
                    });
                            function showRequestDetails()
                            {    if (request_id != null){
                            window.location.replace("welcome.jsp?request_id=" + request_id);
                                    $("#userSection").css("width", "50%");
                                    $("#userSection").css("float", "left");
                                    $("#requestDetails").show();
                            } else{
                            window.location.replace("welcome.jsp");
                                    $("#userSection").css("width", "50%");
                                    $("#userSection").css("float", "center");
                                    $("#requestDetails").hide();
                            }

                            }
                    function closeDetails()
                    {
                    alert("close Details function called");
                            window.location.replace("welcome.jsp");
                            $("#userSection").css("width", "100%");
                            $("#requestDetails").hide();
                    }

        </script>
    </head>
    <body>
        <div id="background">
            <%@include file="Login_Header.jsp" %>
            <div class="contentpage">
                <%
                    if ((session.getAttribute("userid") == null) || (session.getAttribute("userid") == "")) {
                %>
                <br/>
                <%       String message = "please login";
                        response.sendRedirect("login.jsp?message=" + message);
                        return;
                    }
                %>
                <div id="contents" style="width:100%;align:center">
                    <div id="userSection" style="width:50%;float:left">
                        <center style="font-size:22px;color:gray;padding-bottom:25px"></center> 
                        <form class="form-horizontal" name="history_form" id="history_form" action="Feedbacksubmitted.jsp"  method="post">
                            <center><h4 style="padding:20px;color:navy"> *<fmt:message key="welcome.label.instruction"/></h4></center>
                            <!-- Select Basic -->
                            <%
                                Connection con = new Constants().db_connection();
                                PreparedStatement pst = con.prepareStatement("select request_id from t_requests where request_id in (select request_id from t_results where output_status=1) and mail_id=?");
                                pst.setString(1, session.getAttribute("userid").toString());
                                ResultSet res = pst.executeQuery();
                                if (!res.next()) {

                                } else {%>
                            <div class="form-group">
                                <label class="col-md-4 control-label" for="request_id"><fmt:message key="welcome.label.selectrequest" />:<font color="red">*</font></label>
                                <div class="col-md-4">
                                    <select id="request_id" name="request_id" class="form-control" onchange="change()" required="">
                                        <option value="">select your request Id</option>
                                        <%  do {
                                                String reqId = res.getString("request_id");
                                        %><option value="<%=reqId%>"><%=reqId%></option>
                                        <%
                                            } while (res.next());
                                        %>
                                    </select>
                                </div>
                            </div>
                            <div class="form-group">
                                <label class="col-md-4 control-label" for="singlebutton"></label>
                                <div class="col-md-4">
                                    <blink> <a role="button" id="topdf" name="topdf" target="_blank"><fmt:message key="welcome.label.pdf"/></a></blink>
                                </div>
                            </div>
                            <div class="form-group">
                                <label class="col-md-4 control-label" for="singlebutton"></label>
                                <div class="col-md-4">
                                    <blink> <a id="tomap" post="true" name="tomap" role="button" target="_blank"><fmt:message key="welcome.label.gis" /></a></blink>
                                </div>
                            </div>

                            <div class="form-group">
                                <label class="col-md-4 control-label" for="singlebutton"></label>
                                <div class="col-md-4">
                                    <blink> <a role="button" href="Main.jsp"><fmt:message key="menu.newrequest"/></a></blink>
                                </div>
                            </div>
                            <div class="form-group">
                                <label class="col-md-4 control-label" for="singlebutton"></label>
                                <div class="col-md-4">
                                    <blink> <a role="button" onclick="showRequestDetails()"><fmt:message key="welcome.label.checktourequestdetails"/></a></blink>
                                </div>
                            </div>
                            <%
                                }
                            %>
                        </form>
                        </br></br>
                    </div>
                    <div id="requestDetails" style="width:50%;float:left;padding:10px;border-width: 5px;">
                        <%
                            String request_id = request.getParameter("request_id");
                            System.out.println(request_id);
                            Connection usercon = new Constants().db_connection();
                            PreparedStatement userpst = con.prepareStatement("select * from t_requests where request_id=?");
                            userpst.setString(1, request_id);
                            ResultSet userres = userpst.executeQuery();
                            while (userres.next()) {
                        %>
                        <span class="close-btn"><a href="#" onclick="closeDetails()">X</a></span>
                        <div class="row">
                            <div class="panel panel-primary">
                                <div class="panel-heading">
                                    <h3 class="panel-title" style="text-align:center"><fmt:message key="welcome.label.requestdetails" /></h3>
                                </div>
                                <table class="table table-hover" id="dev-table">
                                    <thead>
                                        <tr>
                                            <th><fmt:message key="welcome.label.requestid" /></th>
                                            <td><%=userres.getString("request_id")%></td>
                                        </tr>
                                    </thead>
                                    <tbody>
                                        <tr>	
                                            <th><fmt:message key="wlecome.lable.requestdate"/></th>
                                            <td><%=userres.getString("request_date")%></td>
                                        </tr>
                                        <tr>
                                            <th><fmt:message key="main.label.object"/></th>
                                            <td><%=MissingObject.missingObjectName(Integer.parseInt(userres.getString("missed_object").toString()))%></td>
                                        </tr>
                                        <tr>
                                            <th><fmt:message key="main.panel.positon"/></th>
                                            <td><fmt:message key="main.label.latitude"/>:<%=userres.getString("Loc_lat")%></br>
                                                <fmt:message key="main.label.longitude"/>:<%=userres.getString("Loc_long")%>
                                            </td>
                                        </tr>
                                        <tr>
                                            <th><fmt:message key="main.label.lasttime"/></th>
                                            <td><%=userres.getString("miss_date_from")%></td>
                                        </tr>
                                        <tr>
                                            <th><fmt:message key="main.label.searchtime"/></th>
                                            <td><%=userres.getString("miss_date_to")%></td>
                                        </tr>
                                    </tbody>
                                </table>
                            </div>
                        </div>
                        <% }%>
                    </div>
                </div>
            </div>
            <center>©INCOIS search and Rescue. All Rights Reserved</center>
        </div>
    </body> 
</html>