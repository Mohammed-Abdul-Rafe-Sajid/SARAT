<%-- 
    Document   : Contact
    Created on : Sep 24, 2015, 2:21:53 PM
    Author     : Administrator
--%>
<%@page contentType="text/html" pageEncoding="UTF-8"%>
<html>
    <head>
        <meta charset="UTF-8">
        <title>Search and Rescue Contact page</title>
        <link rel="stylesheet" href="Css/Menustyles.css">
        <link rel="stylesheet" href="Css/bootstrap.min.css">
        <link rel="stylesheet" href="Css/jquery-ui.css" />
        <script src="Js/Formvalidation.js"></script>
        <script src="Js/script.js"></script>
        <script src="Js/jquery-1.10.2.js"></script>
        <script src="Js/jquery-ui.js"></script>
        <link rel="stylesheet" href="Css/style.css" type="text/css">
        <style type="text/css">
            #f_caption {
                width: 100%;
                color: #6d1956;
                font-size: 24px;
                font-family: "FreestyleScript", Arial, Helvetica, sans-serif;
                font-weight: bold;
                margin-bottom: 18px;
                margin-top: 18px;
                text-transform: uppercase;
            }
            .right_inner1{
                width: 97%;
                margin-top: 0px;
            }
            .right_inner1 .heading{
                text-align: center;
                width: 100%;
                padding: 8px 0px;
                font-family: "Candara", Arial, Helvetica, sans-serif;
                font-size: 18px;
                color: #005680;
                text-transform: uppercase;
                border-bottom: 1px solid #D6D6D6;
                font-weight: 600;
                background-color:#EFEFEF;
            }
            .right_inner1{
                width: 97%;
                margin-top: 0px;
            }
            .right_inner1 .heading{
                text-align: center;
                width: 100%;
                padding: 8px 0px;
                font-family: "Candara", Arial, Helvetica, sans-serif;
                font-size: 18px;
                color: #005680;
                text-transform: uppercase;
                border-bottom: 1px solid #D6D6D6;
                font-weight: 600;
                background-color:#EFEFEF;
            }
        </style>
        <script type="text/javascript">
            $(function () {
                $("#mail_id").tooltip({
                    position: {
                        my: "center bottom",
                        at: "right right-10",
                        collision: "none"
                    }
                });
            });
            $(function () {
                $("#name").tooltip({
                    position: {
                        my: "center bottom",
                        at: "right right-10",
                        collision: "none"
                    }
                });
            });
            $(function () {
                $("#subject").tooltip({
                    position: {
                        my: "center bottom",
                        at: "right right-10",
                        collision: "none"
                    }
                });
            });
            $(function () {
                $("#message").tooltip({
                    position: {
                        my: "center bottom",
                        at: "right right-10",
                        collision: "none"
                    }
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
                <div id="contents">
                    <div id="f_caption">
                        <div class="heading" style="font-size:32px;text-align:center;color:#A82F00"><img src="Images/rimg.png" align="bottom"> &nbsp; <fmt:message key="contact.title" /> &nbsp; <img src="Images/limg.png" align="bottom"></div>
                    </div>
                    <!-- <div style="float:left;width:50%">
                        <div class="right_inner1" style="background-color:#F9F9F9">
                            <div class="heading"> <fmt:message key="contact.label.address" /></div>
                        </div>
                        <h3><fmt:message key="contact.label.incois"/></h3>
                        <span style="font-size: 21px;font-weight: bold"><fmt:message key="contact.label.address" />:</span><br><fmt:message key="contact.addr.oceanvalley" />,<br> <fmt:message key="contact.addr.pragathinagar" /> (BO), <fmt:message key="contact.addr.nizampet" /> (SO),<br><fmt:message key="contact.addr.hyd" />-500090<br>
                        <span><fmt:message key="contact.addr.tele" />:</span> +91-40-23895000 
                        <br>
                        <span><fmt:message key="contact.addr.fax" />:</span> +91-40-23892910
                        <br>
                        <span style="color:blue;text-decoration:underline;">Mail-Id:</span> director@incois.gov.in                 
                    </div> -->
                    <div style="float:left;width:50%">
                        <div class="right_inner1" style="background-color:#F9F9F9">
                            <div class="heading"> <fmt:message key="contact.label.address" /></div>
                        </div>
                        <h3><fmt:message key="contact.label.incois"/></h3>
                        <!--
                        <span style="font-size: 21px;font-weight: bold"><fmt:message key="contact.label.address" />:</span><br><fmt:message key="contact.addr.oceanvalley" />,<br> <fmt:message key="contact.addr.pragathinagar" /> (BO), <fmt:message key="contact.addr.nizampet" /> (SO),<br><fmt:message key="contact.addr.hyd" />-500090<br>
                        <span><fmt:message key="contact.addr.tele" />:</span> +91-40-23895000 
                        <br>
                        <span><fmt:message key="contact.addr.fax" />:</span> +91-40-23892910
                        <br>
                        <span style="color:blue;text-decoration:underline;">Mail-Id:</span> director@incois.gov.in    
                        -->
                        <span style="font-size: 21px;font-weight: bold">Address:</span><br/>
                        Operational Duty Scientist <br/>
                        Operational Ocean Services (OOS), OMARS<br/>
                        Indian National Centre for Ocean Information Services (INCOIS)<br/>
                        Ocean Valley, Pragathi Nagar (BO), Nizampet (SO) <br/>
                        Ministry of Earth Sciences, Hyderabad -500090<br/>
                        <span style="color:blue;text-decoration:underline;">Email:</span> osf@incois.gov.in
                        <br/>
                        <span style="color:blue;text-decoration:underline;">Contact no: </span>040-23886034/23895011
                    </div>
                    <div style="float:left;width:50%;border-right:none;float:right;background-color:#FAFAFA" class="right">
                        <div class="right_inner1" style="background-color:#FAFAFA">
                            <div class="heading">
                                <fmt:message key="contact.label.enquiryform"/>
                            </div>
                        </div>
                        <br><br>
                        <form action="Contact" method="post" class="form-horizontal" name="contact_form" style="font-size: medium"> 
                            <!-- Name input-->
                            <div class="form-group">
                                <label class="col-md-4 control-label" for="name"><fmt:message key="contact.label.fullname"/>:<font color="red">*</font></label>  
                                <div class="col-md-4">
                                    <input id="name" name="name" type="text" placeholder="" class="form-control input-md" required="" title="Enter ur full Name">
                                </div>
                            </div>
                            <!-- Mail_id input-->
                            <div class="form-group">
                                <label class="col-md-4 control-label" for="mail_id"><fmt:message key="contact.label.email"/>:<font color="red">*</font></label>  
                                <div class="col-md-4">
                                    <input id="mail_id" name="mail_id" type="text" placeholder="" class="form-control input-md" required="" title="Enter a valid mail-id">
                                </div>
                            </div>
                            <!-- Subject input-->
                            <div class="form-group">
                                <label class="col-md-4 control-label" for="subject" ><fmt:message key="contact.label.subject"/>:<font color="red">*</font></label>  
                                <div class="col-md-4">
                                    <input id="subject" name="subject" type="text" placeholder="" class="form-control input-md" required="" title="Enter Subject">
                                </div>
                            </div>
                            <!-- Message Text Area -->
                            <div class="form-group">
                                <label class="col-md-4 control-label" for="message"><fmt:message key="contact.label.message"/>:<font color="red">*</font></label>
                                <div class="col-md-4">                     
                                    <textarea class="form-control" id="message" name="message" title="Write a Message">any Query?</textarea>
                                </div>
                            </div>
                            <!-- Button -->
                            <div class="form-group">
                                <label class="col-md-4 control-label" for="submit"></label>
                                <div class="col-md-4">
                                    <button id="submit" name="submit" class="btn btn-primary" onClick="this.form.submit(); this.disabled=true; this.value='Sending…';"><fmt:message key="contact.button.sendmessage"/></button>
                                </div>
                            </div>
                        </form>
                        <script  type="text/javascript">
                            var frmvalidator = new Validator("contact_form");
                            frmvalidator.EnableFocusOnError(true);
                            frmvalidator.addValidation("mail_id", "req", "Please enter Email");
                            frmvalidator.addValidation("name", "req", "Please enter you name");
                            frmvalidator.addValidation("subject", "req", "Please enter Subject");
                            frmvalidator.addValidation("message", "req", "Please Enter Message");
                        </script>
                    </div>
                    <center>
                        <p style="color:green">
                            <%=error%> 
                        </p>     
                    </center>
                </div>
            </div>
            <center>©INCOIS search and Rescue. All Rights Reserved</center>
        </div>
    </body>
</html>