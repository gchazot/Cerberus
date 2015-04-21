package io.github.cerberus.client;

import static java.util.logging.Level.FINE;

import java.io.IOException;
import java.io.InputStreamReader;
import java.io.UnsupportedEncodingException;
import java.net.MalformedURLException;
import java.net.URL;
import java.net.URLEncoder;
import java.util.logging.Logger;

import org.scribe.builder.ServiceBuilder;
import org.scribe.model.OAuthRequest;
import org.scribe.model.Response;
import org.scribe.model.Token;
import org.scribe.model.Verb;
import org.scribe.model.Verifier;
import org.scribe.oauth.OAuthService;

import com.google.gson.Gson;
import com.google.gson.JsonObject;
import com.google.gson.JsonParser;
import org.apache.commons.io.IOUtils;

public class AuthenticationApiService {

  private static final String UTF_8 = "UTF-8";

  private static final Logger LOGGER = Logger.getLogger(AuthenticationApiService.class.getName());

  private OAuthService service;

  private String serviceURL;

  private static AuthenticationApiService instance;

  private AuthenticationApiService(String serviceURL, String apiKey, String apiSecret, String callback) {
    this.serviceURL = serviceURL;
    AuthenticationApi api = new AuthenticationApi();
    api.setServiceURL(serviceURL);
    ServiceBuilder builder = new ServiceBuilder().provider(api).apiKey(apiKey).apiSecret(apiSecret).callback(callback);
    service = builder.build();
  }

  public static AuthenticationApiService getInstance(String serviceURL, String apiKey, String apiSecret, String callback) {
    if (instance == null) {
      instance = new AuthenticationApiService(serviceURL, apiKey, apiSecret, callback);
    }
    return instance;
  }

  public Token createRequestToken() {
    return service.getRequestToken();
  }

  public String createAuthorizationCodeURL(Token requestToken) {
    return service.getAuthorizationUrl(requestToken);
  }

  public Token getTokenByAuthorizationCode(String code, Token requestToken) {
    Verifier v = new Verifier(code);

    return service.getAccessToken(requestToken, v);
  }

  public User getUserByToken(Token accessToken) {
    OAuthRequest request = new OAuthRequest(Verb.GET, serviceURL + "/api/user.info.json");
    service.signRequest(accessToken, request);
    Response response = request.send();
    String json = response.getBody();
    Gson gson = new Gson();
    User userResponse = gson.fromJson(json, User.class);

    if (userResponse != null) {
      return userResponse;
    }
    return null;
  }

  public User getUserByUsername(String username) {
    InputStreamReader reader = null;
    try {
      URL url = new URL(serviceURL + "/api/users/" + URLEncoder.encode(username, UTF_8).replace("+", "%20") + ".json");
      reader = new InputStreamReader(url.openStream(), UTF_8);
      Gson gson = new Gson();
      return gson.fromJson(reader, User.class);
    } catch (UnsupportedEncodingException e) {
      handleUsernameError(username, e);
    } catch (MalformedURLException e) {
      handleUsernameError(username, e);
    } catch (IOException e) {
      handleUsernameError(username, e);
    } finally {
      IOUtils.closeQuietly(reader);
    }
    return null;
  }

  private void handleUsernameError(String username, Exception e) {
    LOGGER.log(FINE, "Failed to look up user " + username, e);
  }

  public Boolean belongsToGroup(String serviceURL, Token accessToken, String group) {
    try {
      OAuthRequest request = new OAuthRequest(Verb.GET, serviceURL + "/api/user.belongs_to_group.json?group_name=" + group);
      service.signRequest(accessToken, request);
      Response response = request.send();
      String json = response.getBody();
      JsonParser parser = new JsonParser();
      JsonObject jo = (JsonObject) parser.parse(json);
      return jo.get("result").getAsBoolean();
    } catch (Exception e) {
      LOGGER.log(FINE, "Failed to check if current user belongs to the group " + group, e);
    }
    return false;
  }

  public Boolean isAUserBelongsToGroup(String serviceURL, String username, String groupname) {
    String json;
    try {
      URL url = new URL(serviceURL + "/api/users/" + username + "/belongs_to_group.json?group_name=" + groupname);
      json = IOUtils.toString(url.openStream());
      JsonParser parser = new JsonParser();
      JsonObject jo = (JsonObject) parser.parse(json);
      return jo.get("result").getAsBoolean();
    } catch (Exception e) {
      LOGGER.log(FINE, "Failed to check groups for user " + username, e);
    }
    return false;
  }

}
