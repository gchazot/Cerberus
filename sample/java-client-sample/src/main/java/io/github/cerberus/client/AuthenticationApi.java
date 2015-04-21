package io.github.cerberus.client;

import org.scribe.builder.api.DefaultApi20;
import org.scribe.extractors.AccessTokenExtractor;
import org.scribe.extractors.JsonTokenExtractor;
import org.scribe.model.OAuthConfig;
import org.scribe.utils.OAuthEncoder;

public class AuthenticationApi extends DefaultApi20 {
  private static final String AUTHORIZATION_URL = "/oauth/authorize?client_id=%s&response_type=code&redirect_uri=%s";

  private String serviceURL;

  public void setServiceURL(String serviceURL) {
    this.serviceURL = serviceURL;
  }

  public String getServiceURL() {
    return this.serviceURL;
  }

  @Override
  public String getAccessTokenEndpoint() {
    return serviceURL + "/oauth/token?grant_type=authorization_code";
  }

  @Override
  public String getAuthorizationUrl(OAuthConfig config) {
    return String.format(serviceURL + AUTHORIZATION_URL, config.getApiKey(), OAuthEncoder.encode(config.getCallback()));
  }

  @Override
  public AccessTokenExtractor getAccessTokenExtractor() {
    return new JsonTokenExtractor();
  }
}
