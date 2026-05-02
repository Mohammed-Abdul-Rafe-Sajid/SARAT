<%-- 
    Document   : login
    Created on : Sep 24, 2015, 1:36:52 PM
    Author     : Administrator
--%>
<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<c:set var="language" value="${not empty param.language ? param.language : not empty language ? language : pageContext.request.locale}" scope="session" />
<fmt:setLocale value="${language}" />
<fmt:setBundle basename="text" />
<html>
    <head>
        <meta charset="UTF-8">
        <title>Search and Rescue Home</title>

        <!--  <link rel="stylesheet" href="Css/Menustyles.css">-->
        <script src="Js/Formvalidation.js"></script>
        <script type="text/javascript" src="//code.jquery.com/jquery-1.11.3.min.js"></script>
        <script type="text/javascript" src="Js/jquery.validate.js"></script>
        <script>
             <fmt:message key="home.error.email" var="enteremail" />
            <fmt:message key="home.error.password" var="enterpassword"/>
            $(function () {
                $("#loginform").validate({
                    rules: {
                        email: "required",
                        password: "required",
                    },
                    errorPlacement: function (error, element) {
                        error.insertAfter(element);

                    },
                    messages: {
                        email:"${enteremail}",
                        password: "${enterpassword}"
                    },
                    submitHandler: function (form) {
                        document.loginform.action = "Check.jsp";
                        document.loginform.submit();
                    }
                });
            });
        </script>
        <style type="text/css">
            .footer {
                background-color:#92D4F3;
                padding: 0.5em 0;
                text-align: center;
                width: 80%;
                margin: 0 auto;
                border-radius: 0px 0px 5px 5px;

                /* height: 3px; */
                /* color: White;*/
            }
            .footer p {
                color: #777;
                font-size: 0.95em;
                font-weight: 200;
                text-align: center;
                line-height: 1em;
                font-family: Verdana;
            }
            label.error {
                display:red;
                color:red;
                width:100%;

            }
            p {
                line-height:10px;
                display: block;
                -webkit-margin-before: 1em;
                -webkit-margin-after: 1em;
                -webkit-margin-start: 0px;
                -webkit-margin-end: 0px;
            }
            .left_img {
                float: left;
                margin:0 15px 8px 0;
                overflow: hidden;
            }
            .dividerHeading,
            .widget_title{
                margin-bottom: 25px;
            }
            .dividerHeading h4,
            .widget_title h4{
                font-size: 21px;
                font-weight: normal;
                padding: 0 0 10px;
                position: relative;
                text-transform: capitalize;
            }

            .dividerHeading h4::before,
            .widget_title h4::before{
                background: #727CB6;
                border-radius: 0 5px 5px 0;
                bottom: -1.5px;
                content: "";
                height: 2px;
                left: 0;
                position: absolute;
                width: 50px;
            }

            .dividerHeading.text-center{
                margin-bottom: 45px;
            }

            .dividerHeading.text-center h4{
                font-size: 25px;
            }
            .dividerHeading.text-center h4::before{
                display: block;
                position: relative;
                margin: 0 auto;
                bottom: -40px;
            }
            .dividerHeading.text-center > span{
                font-size: 18px;
                color: #868889;
                display: block;
                margin: 15px 0 30px;
            }

            .btn-default{
                background:#727CB6;
                //color:#fff;
                border:none;
                border-radius:2px;
                transition:all 0.3s ease-in-out;
                -webkit-transition:all 0.3s ease-in-out;
                -moz-transition:all 0.3s ease-in-out;
                -ms-transition:all 0.3s ease-in-out;
                -o-transition:all 0.3s ease-in-out;
            }
            .btn-default:hover{
                background:#444A6D;
                // color:#fff;
            }

        </style>


        <script src="Js/jquery.imagecursorzoom.js"></script>
        <script>
            $(function () {
                $('IMG.box').imageCursorZoom();
                // $('IMG.box').imageCursorZoom({parent:function(){ return $(this).parent(); }});
            });
        </script>
        <link rel="stylesheet" href="Css/jquery-ui.css" />
        <link rel="stylesheet" href="Css/bootstrap.min.css"/>
        <link rel="stylesheet" href="Css/style.css" type="text/css">
        <link rel="stylesheet" href="Css/font-awesome.css" type="text/css">

    </head>
    <body style="background:#076fc8;">
        <div id="background" >
            <%@include file="Header.jsp" %>
            <div class="contentpage" style="border:thin #fbf9ee groove">
                <%--<div style="border:thin #fbf9ee groove" align="center">--%>
                <div id="contents">  
                    <section class="content about">
                        <div class="container">
                            <div class="row sub_content">
                                <div class="who">
                                    <div class="col-lg-8 col-md-8 col-sm-8">
                                        <div class="dividerHeading">
                                            <h4><span><fmt:message key="home.aboutsarat"/></span></h4>
                                        </div>
                                        <img class="left_img img-thumbnail" src="Images/1_1.jpg" alt="about img">
                                        <p>ESSO-INCOIS (under the MoES) has successfully developed a Search And Rescue Aid Tool (SARAT) for facilitating the search and rescue operations in the seas to locate individuals/vessels in distress in the shortest possible time. This has been initiated and developed under the Make in India program. The tool uses model ensembling that accounts for uncertainties in the initial location as well as last known time of the missing object, to locate the person or object with high probability. The movement of the missing objects are governed mainly by the currents and winds. The tool is based on model currents derived from very high resolution Regional Ocean Modelling System run operationally on High Performance Computers at INCOIS.</p>
                                        <p>The user has the option to select upto 60 types of missing objects (based on shape and buoyancy). Users can select a specific point where the object was last seen using the interactive map or they can also select a coastal location, distance travelled and bearing angle so that the last known location of the missing object is estimated. The results generated are displayed in an interactive map depicting the probable area to be searched and is also sent as a text message to emails/Mobile Phones. All the requests and responses are provided in languages of the coastal states so that local fishermen can use it immediately to search their fellow fishermen in distress.</p>
                                        <p>This tool is also available as a mobile application for the users</p>
                                    </div>
                                    <div class="col-lg-4 col-md-4 col-sm-4">
                                        <div class="dividerHeading">
                                            <h4><span><fmt:message key="home.loginhere"/></span></h4>
                                        </div>                   
                                        <% String error = "";
                                            String message = request.getParameter("message");
                                            if (message != null) {
                                                error = message;
                                            } else {
                                                error = "";
                                            }
                                        %> 
                                        <div id="errorBox">

                                        </div>
                                        <span style="color:red;font-size:16px"><%=error%>
                                        </span>
                                        <form id="loginform" method="post" name="loginform" action="">
                                            <div class="form-group">
                                                <div class="input-group">
                                                    <fmt:message key="login.label.registeredmail" var="registeredmail" />
                                                    <span class="input-group-addon"><i class="fa fa-user"></i></span>
                                                    <input type="text" class="form-control" placeholder="${registeredmail}" id="email"  name="email">
                                                </div>
                                            </div>
                                            <div class="form-group">
                                                <div class="input-group">
                                                    <fmt:message key="login.label.password" var="password" />
                                                    <span class="input-group-addon"><i class="fa fa-lock"></i></span>
                                                    <input type="password" class="form-control" placeholder="${password}" id="password" name="password">
                                                </div>
                                            </div>
                                            <div class="form-group">
                                                <div class="checkbox">
                                                    <label>
                                                        <input type="checkbox"> <fmt:message key="home.rememberme"/>
                                                    </label>
                                                </div>
                                            </div>
                                            <div class="form-group">
                                                <fmt:message key="login.button.signin" var="login" />
                                                <input type="submit" value="${login}"></button>
                                                &nbsp;&nbsp;
                                                <fmt:message key="login.button.signup" var="signup" />
                                                <input type="submit" value="${signup}" onclick="location.href = 'Registration.jsp'">                                                                                  
                                            </div>
                                            <div class="form-group">
                                                <a href="ForgotPassword.jsp" class=""><fmt:message key="login.label.forgotpassword"/>?</a>
                                            </div>
                                        </form>
                                    </div>
                                </div></div></div></div>


            </div>
            <div class="footer">
                <table width="100%">
                    <tr>
                        <td style="width: 20%" align="left">
                            <img src="Images/esso.png" alt="NIC" height="50%" />&nbsp;
                        </td>
                        <td style="width: 60%">
                            <p>
                                <fmt:message key="home.footer.incois.label"/>:<fmt:message key="home.incois.name"/>.

                                <!--                                    <br />
                                -->
                            </p>
                        </td>
                        <td style="width: 20%" align="right">
                            <img src="Images/logo.png" alt="NIC" width="50%" />&nbsp;
                        </td>
                    </tr>
                </table>
            </div>                     
        </div>
        <%--</div>--%>
    <center></center>
</div>
</body>
</html>