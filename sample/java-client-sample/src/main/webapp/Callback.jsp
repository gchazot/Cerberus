<%@page contentType="text/html" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<!-- Latest compiled and minified CSS -->
<link rel="stylesheet" href="https://maxcdn.bootstrapcdn.com/bootstrap/3.3.1/css/bootstrap.min.css">

<!-- Optional theme -->
<link rel="stylesheet" href="https://maxcdn.bootstrapcdn.com/bootstrap/3.3.1/css/bootstrap-theme.min.css">

<!-- Latest compiled and minified JavaScript -->
<script src="https://maxcdn.bootstrapcdn.com/bootstrap/3.3.1/js/bootstrap.min.js"></script>
<html>
    <head>
        <meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
        <title>call back page</title>
    </head>
    <body>
        <div class="container">
            <h2>Information from Cerberus :</h2>
            <p>User <span class="label label-success">${user_full_name}</span> with Login <span class="label label-success">${user_login}</span> has 
                email <span class="label label-success">${user_email}</span> requested the private 
                access token <span class="label label-success">${access_token}</span> with the access code <span class="label label-success">${access_code}</span></p>
        </div>
    </body>
</html>
