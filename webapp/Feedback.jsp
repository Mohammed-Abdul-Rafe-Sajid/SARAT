<%-- 
    Document   : Feedback
    Created on : Dec 23, 2015, 4:25:33 PM
    Author     : Administrator
--%>
<%@page contentType="text/html" pageEncoding="UTF-8"%>
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
        <script>
            $(document).ready(function(){
                $("#mail_id").val(<%= "'" + session.getAttribute("userid") + "'"%>);
            });
            $(function() {
            $( "#mail_id" ).tooltip({
               position: {
                  my: "center bottom",
                  at: "center top-10",
                  collision: "none"
               }
            });
         });
         $(function() {
            $( "#name" ).tooltip({
               position: {
                  my: "center bottom",
                  at: "center top-10",
                  collision: "none"
               }
            });
         });
         $(function() {
            $( "#designation" ).tooltip({
               position: {
                  my: "center bottom",
                  at: "center top-10",
                  collision: "none"
               }
            });
         });
         $(function() {
            $( "#organization" ).tooltip({
               position: {
                  my: "center bottom",
                  at: "center top-10",
                  collision: "none"
               }
            });
         });
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
                <center style="font-size:22px;color:gray;padding-bottom:25px"><fmt:message key="feedback.title" /></center> 
                <form class="form-horizontal" name="feedback_form" id="feedback_form" action="Feedbacksubmitted.jsp"  method="post">
                    <fieldset>
                        <!-- Email-Id-->
                        <div class="form-group">
                            <label class="col-md-4 control-label" for="mail_id"><fmt:message key="feedback.label.emailid" />:<font color="red">*</font></label>  
                            <div class="col-md-5">
                                <input id="mail_id" name="mail_id" type="text" placeholder="Email-Id" class="form-control input-md" title="Enter a valid email-id">
                            </div>
                        </div>
                        <!-- Full Name-->
                        <div class="form-group">
                            <label class="col-md-4 control-label" for="name"><fmt:message key="feedback.label.fullname" />:<font color="red">*</font></label>  
                            <div class="col-md-5">
                                <input id="name" name="name" type="text" placeholder="Full Name" class="form-control input-md" required="" title="Enter your full Name">
                            </div>
                        </div>
                        <!-- Full Name-->
                        <div class="form-group">
                            <label class="col-md-4 control-label" for="designation"><fmt:message key="feedback.label.designation" />:<font color="red">*</font></label>  
                            <div class="col-md-5">
                                <input id="designation" name="designation" type="text" placeholder="Your designation" class="form-control input-md" required="" title="Enter your Designation">
                            </div>
                        </div>
                        <!-- Organization-->
                        <div class="form-group">
                            <label class="col-md-4 control-label" for="organization"><fmt:message key="feedback.label.organization" />:<font color="red">*</font></label>  
                            <div class="col-md-5">
                                <input id="organization" name="organization" type="text" placeholder="Organization Name" class="form-control input-md" required="" title="Enter your Organization Name">
                            </div>
                        </div>
                        <!-- Feedback -->
                        <div class="form-group">
                            <label class="col-md-4 control-label" for="feedback"><fmt:message key="feedback.label.feedback" />:<font color="red">*</font></label>
                            <div class="col-md-4">                     
                                <textarea class="form-control" id="feedback" name="feedback">How useful is the forecast gives to you?</textarea>
                            </div>
                        </div>
                        <!-- Suggestions -->
                        <div class="form-group">
                            <label class="col-md-4 control-label" for="suggestions"><fmt:message key="feedback.label.suggestions" />:<font color="red">*</font></label>
                            <div class="col-md-4">                     
                                <textarea class="form-control" id="suggestions" name="suggestions">Suggestions to improve the service</textarea>
                            </div>
                        </div>
                        <!-- Button -->
                        <div class="form-group">
                            <label class="col-md-4 control-label" for="Feedbacksubmit"></label>
                            <div class="col-md-4">
                                <button id="Feedbacksubmit" name="Feedbacksubmit" class="btn btn-primary" onClick="this.form.submit(); this.disabled=true; this.value='Sending…'; "><fmt:message key="feedback.button.submit" /></button>
                            </div>
                        </div>
                        <div style="padding-left:10%">
                            <strong><font color="red" style="font-size: 20px">*</font></strong><font style="font-weight: bold;font-size: 16px;color: gray"><fmt:message key="feedback.label.alert"/></font> 
                            <br>
                            <br>
                        </div>
                    </fieldset>
                    <!-- Script for form Validation-->
                    <script  type="text/javascript">
                        var frmvalidator = new Validator("feedback_form");
                        frmvalidator.EnableFocusOnError(true);
                        frmvalidator.addValidation("mail_id", "req", "Please enter Email");
                        frmvalidator.addValidation("name", "req", "Please enter you name");
                        frmvalidator.addValidation("organization", "req", "Please enter your organization Name");
                        frmvalidator.addValidation("feedback", "req", "Please Enter your feedback on this service");
                        frmvalidator.addValidation("suggestions", "req", "Please Enter your Suggestions on this service");
                        frmvalidator.addValidation("designation", "req", "Please Enter your Suggestions on this service");    
                    </script>
                </form>
            </div>
            <center>©INCOIS search and Rescue. All Rights Reserved</center>
        </div>

    </body> 
</html>