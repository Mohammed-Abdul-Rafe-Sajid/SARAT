<%-- 
    Document   : output
    Created on : Oct 30, 2015, 12:44:02 PM
    Author     : Venkat Reddy
--%>
<%@page contentType="text/html" pageEncoding="UTF-8"%>
<html>
    <head>
        <meta charset="UTF-8">
        <script src="Js/script.js"></script>
        <script src="Js/Registrionvalidation.js"></script>
        <script src="Js/Formvalidation.js"></script>
        <link rel="stylesheet" href="Css/bootstrap.min.css">
        <link rel="stylesheet" href="Css/Menustyles.css">
        <script src="Js/jquery-1.10.2.js"></script>
        <title>ESSO-INCOIS SARAT Registration</title>
        <link rel="stylesheet" href="Css/style.css" type="text/css">
        <style type="text/css">
            .right_inner1 .heading{
                text-align: center;
                width: 100%;
                padding: 8px 0px;
                font-family: "Candara", Arial, Helvetica, sans-serif;
                font-size: 18px;
                color: #005680;
                text-transform: uppercase;               
                font-weight: 600;
            }
        </style>
        <script>
            /* functionality to check weather User entered Mail-Id available or not*/
            $(document).ready(function () {
                $("#mail_id").blur(function () {
                    // var mail_id = event.target.mail_id;
                    var mail_id = document.getElementById("mail_id").value;
                    // alert(document.getElementById("mail_id").value);
                    $.get('MailCheck', {"mail_id": mail_id},
                    function (resp) { // on sucess
                        $("#email_availability").html(resp);
                    }).fail(function () { // on failure
                        alert("Request failed.");
                    });
                });
            });
        </script>
    </head>
    <body>
        <div id="background">
            <%@include file="Header.jsp" %>
            <div class="contentpage">
                <!-- div for contact page elements -->
                <% String error = "";
                    String message = request.getParameter("message");
                    if (message != null) {
                        error = message;
                    } else {
                        error = "";
                    }
                %> 

                <!--                <center style="font-size:22px;color:gray;padding-bottom:10px">User Registration</center>-->
                <div style="padding-top:25px;padding-right: 50px" align="center">
                    <div class="right_inner1" style="width:50%;">
                        
                            <div class="heading" style="border-radius: 5px;">
                                <fmt:message key="reg.title" />
                            </div>
                        </div>
                    </div>
                <form name="registration_form" id="registration_form" class="form-horizontal" action="Registration"  method="post" onsubmit="return validate()" style="font-size: medium">
                    <fieldset>
                        <div class="form-group">
                            <center>
                                <p style="color:red">
                                    <%=error%> 
                                </p>     
                            </center>
                        </div>
                        <!-- Mail-Id Text Field-->
                        <div class="form-group">
                            <label class="col-md-4 control-label" for="mail_id"><fmt:message key="reg.label.mailid" />:<font color="red">*</font></label>  
                            <div class="col-md-4">
                                <input id="mail_id" name="mail_id" type="text"  placeholder="Enter your Email-id" class="form-control input-md">
                            </div>
                            <div id="email_availability">
                            </div>
                        </div>
                        <!-- Password input-->
                        <div class="form-group">
                            <label class="col-md-4 control-label" for="password"><fmt:message key="reg.label.password" />:<font color="red">*</font></label>
                            <div class="col-md-4">
                                <input id="password" name="password" type="password" placeholder="Enter you password" class="form-control input-md" >
                            </div>
                        </div>
                        <!-- Password input-->
                        <div class="form-group">
                            <label class="col-md-4 control-label" for="confirm_password"><fmt:message key="reg.label.passwordconfirmation"/>:<font color="red">*</font></label>
                            <div class="col-md-4">
                                <input id="confirm_password" name="confirm_password" type="password" placeholder="Re-Enter your password" class="form-control input-md" >
                            </div>
                        </div>

                        <!-- Field for Full Name-->
                        <div class="form-group">
                            <label class="col-md-4 control-label" for="name"><fmt:message key="reg.label.fullname"/><font color="red">*</font></label>  
                            <div class="col-md-4">
                                <input id="name" name="name" type="text" placeholder="Enter your name" class="form-control input-md" >
                            </div>
                        </div>
                        <!-- Input Field for Designation-->
                        <div class="form-group">
                            <label class="col-md-4 control-label" for="designation"><fmt:message key="reg.label.designation"/>:<font color="red">*</font></label>  
                            <div class="col-md-4">
                                <input id="designation" name="designation" type="text" placeholder="Enter your Designation" class="form-control input-md" >
                            </div>
                        </div>
                        <!-- Input Field for Organization-->
                        <div class="form-group">
                            <label class="col-md-4 control-label" for="organization"><fmt:message key="reg.lable.organization"/>:<font color="red">*</font></label>  
                            <div class="col-md-4">
                                <input id="organization" name="organization" type="text" placeholder="Enter your Organization" class="form-control input-md" >
                            </div>
                        </div>
                        <!-- Input Field for Address-->
                        <div class="form-group">
                            <label class="col-md-4 control-label" for="address:"><fmt:message key="reg.label.address"/>:<font color="red">*</font></label>
                            <div class="col-md-4">                     
                                <textarea class="form-control" id="address" name="address"></textarea>
                            </div>
                        </div>

                        <!-- Text input-->
                        <div class="form-group">
                            <label class="col-md-4 control-label" for="mobile"><fmt:message key="reg.label.mobilenumber"/>:<font color="red">*</font></label>  
                            <div class="col-md-4">
                                <input  type="text" id="mobile_num" name="mobile_num" placeholder="Enter your Mobile Number" class="form-control input-md">

                            </div>
                        </div>
                        <br>
                        <!-- Input Field for Mobile Number -->
                        <div class="form-group">
                            <label class="col-md-4 control-label" for="submit"></label>
                            <div class="col-md-8">
                                <button id="submit" name="submit" class="btn btn-success"><fmt:message key="reg.button.submit"/></button>&nbsp;&nbsp;&nbsp
                                <fmt:message key="reg.button.reset" var="reset" />
                                <input type="reset" value="${reset}" id="reset" name="reset" class="btn btn-danger">
                            </div>
                        </div>
                    </fieldset>
                    <!-- Script for form Validation-->
                    <script  type="text/javascript">
                        var frmvalidator = new Validator("registration_form");
                        frmvalidator.EnableFocusOnError(true);                     
                        frmvalidator.addValidation("mail_id", "req", "Please enter Email");
                        frmvalidator.addValidation("mail_id", "email", "Please enter valid Email");
                        frmvalidator.addValidation("password", "minlen=8", "password atleast 8 characters");
                        frmvalidator.addValidation("confirm_password", "req", "Please enter confirm password");
                        frmvalidator.addValidation("confirm_password", "eqelmnt=password", "The confirmed password is not same as password");
                        frmvalidator.addValidation("name", "req", "Please enter your Full name");
                        frmvalidator.addValidation("name", "alpha_s", "Please enter your Full name");
                        frmvalidator.addValidation("designation", "req", "Please enter your Designation");
                        frmvalidator.addValidation("organization", "req", "Please enter your organization name");
                        frmvalidator.addValidation("address", "req", "Please fill your address");
                        frmvalidator.addValidation("mobile_num", "numeric", "mobile shold be digits only");
                        frmvalidator.addValidation("mobile_num", "req", "Please enter your mobile number");
                        frmvalidator.addValidation("mobile_num", "maxlen=10", "mobile number should not less than 10 digits");
                        frmvalidator.addValidation("mobile_num", "minlen=10", "mobile number should not more than 10 digits");
                    </script>
                </form>
            </div>
            <center>©INCOIS search and Rescue. All Rights Reserved</center>
        </div>

    </body> 
</html>