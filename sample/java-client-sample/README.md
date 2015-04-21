#Cerberus Java Client
This projects provides a Java client to Cerberus.

## See this sample in action
Edit src/main/resources/cerberus.properties
Fill in Cerberus required informations (serviceUrl, clientId, clientSecret)

Start the server using mvn jetty:run

Browse your server with http://localhost:8080
Click on the links and watch the magic happen !

## Usage
### Step 1 : redirecting to the authentication service

	String serviceUrl = "<your_service_url>";
	String clientId = "ogsjdgiosfjogif";
	String clientSecret = "fidjsgiojsodjdiogfj";
	String callback = "<your_application_callback_url>";
	
	AuthenticationApiService service = AuthenticationApiService.getInstance(serviceUrl, clientId, clientSecret, callback);
	String redirectURL = service.createAuthorizationCodeURL(null);
	// Redirect to the new URL
	[...]
	
### Step 2 : Get the authorization code back

	String serviceUrl = "<your_service_url>";
	String clientId = "ogsjdgiosfjogif";
	String clientSecret = "fidjsgiojsodjdiogfj";
	String callback = "<your_application_callback_url>";
    
    String code = httpRequest.getParameter("code");

	AuthenticationApiService service = AuthenticationApiService.getInstance(serviceUrl, clientId, clientSecret);
	Token accessToken = service.getTokenByAuthorizationCode(code, null);
	User userByToken = service.getUserByToken(accessToken);
	if (userByToken == null) {
		redirect403();
	}
	assertEquals("username", userByToken.username);
	assertEquals("fullName", userByToken.fullname);
	assertEquals("firstName.lastName@company.com", userByToken.email);
	[...]
