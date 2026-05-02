<%-- 
    Document   : index
    Created on : Jun 20, 2016, 5:30:37 PM
    Author     : Administrator
--%>

<%@page contentType="text/html" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<!--<html>
    <head>
        <meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
        <meta http-equiv="Refresh" content="100;url=login.jsp">
    </head>
    <body>
    <center><img src="Images/SARAT_2.png" style="width:80%;height:80%"></center>
    </body>
</html>-->

<!DOCTYPE html>
<html>
<head>
    <meta http-equiv="Refresh" content="15;url=home.jsp">
<style>
  * {
    padding: 0;
    margin: 0;
  }
  .fit { /* set relative picture size */
    max-width: 100%;
    max-height: 100%;
  }
  .center {
    display: block;
    margin: auto;
  }
</style>
</head>
<body>

    <img class="center fit" src="logo.png" onclick="location.href='home.jsp'" >    
<script src="https://code.jquery.com/jquery-latest.js"></script>
<script type="text/javascript" language="JavaScript">
  function set_body_height() { // set body height = window height
    $('body').height($(window).height());
  }
  $(document).ready(function() {
    $(window).bind('resize', set_body_height);
    set_body_height();
  });
</script>

</body>
</html>
