process.env.NODE_TLS_REJECT_UNAUTHORIZED = "0"; //disable ssl check

var express = require('express'),
app = express();
var oauth2_server = 'to be filled'; // Ex https://www.yoursever.com/cerberus"

var oauth2 = require('simple-oauth2')({
  clientID: 'to be filled',
  clientSecret: 'to be filled',
  site: oauth2_server,
  tokenPath: '/oauth/token'
});

var userInfoApi = oauth2_server + '/api/user.info.json?access_token=';

var Client = require('node-rest-client').Client;
rest_client = new Client();

var url = require('url');

var token;

// Initial page redirecting to Github
app.get('/auth', function (req, res) {
  var url_callback = url.format({protocol:req.protocol,slashes:true,host:req.header('Host'),pathname:'/callback'})
  var authorization_uri = oauth2.authCode.authorizeURL({
    redirect_uri:  url_callback,
    scope: 'notifications',
    state: 'callbackcall'
  });
  res.redirect(authorization_uri);
});


// Callback service parsing the authorization token and asking for the access token
app.get('/callback', function (req, res) {
  var code = req.query.code;
  var url_callback = url.format({protocol:req.protocol,slashes:true,host:req.header('Host'),pathname:'/callback'})
  oauth2.authCode.getToken({
    code: code,
    redirect_uri: url_callback
  }, saveToken);

  function saveToken(error, result) {
    if (error) { console.log('Access Token Error', error.message); }
    //var token = oauth2.accessToken.create(result);
    token = result.access_token;
    var api_request = userInfoApi + token;
    console.log("DEBUG==========================", api_request);
    rest_client.registerMethod("getUserInfo",api_request,"GET")
    rest_client.methods.getUserInfo(function(data,response){
    // parsed response body as js object
    console.log(data);
    res.send(data);
  });
  }
});

app.get('/', function (req, res) {
  res.send('<h2> <a href="/auth">click here to authentify</a> <h2>');
});

app.listen(3000);

console.log('Express server started on port 3000');