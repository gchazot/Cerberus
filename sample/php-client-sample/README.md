Pre-requisites:

* Have a PHP Server
* Informations to access the Cerberus server

Edit the file oauth2-client.php and update the following values:

```
CLIENT_ID, CLIENT_SECRET, SERVICE_URI and REDIRECT_URI
```

Start your PHP server and go to:

```
http://<hostname>/oauth2-client.php
```

The result you should obtain is an Array presenting some of your personal information:

Eg:
```
Array (
	[name] => John DOE
    [firstname] => John
    [lastname] => DOE
    [login] => jdoe
    [email] => jdoe@company.com
    )
```