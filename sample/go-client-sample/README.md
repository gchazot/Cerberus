Pre-requisites:

* Have Go installed
* Have credentials to use Cerberus

Edit the file cerberus-go.go and update the following values:

```
clientID, clientSecret, oauth_server
```

Compile your Go file
Execute the file generated

```
http://<hostname>:<port>/
```

The result you should obtain is an Array presenting some of your personal information:

Eg:

```

Array (
	[name] => John DOE
    [firstname] => John
    [lastname] => DOE
    [login] => jdoe
    [email] => John.doe@cerberus.com
    )

```