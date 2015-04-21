Pre-requisites:

* Have Nodejs and npm installed
* Have credentials to use Cerberus

Edit the file cerberus-nodejs.js and update the following values:

```
clientID, clientSecret
```

Start your nodejs server and go to:

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

Bonus:

Run the client in Docker:

```
#git clone <this repo> docker-js

#cd docker-js

#docker build -t="mybuild" .

#docker run -d -p 8888:3000 mybuild
```

Now you have the server instance up on http://localhost:8888
