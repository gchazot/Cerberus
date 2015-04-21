package io.github.cerberus.client;

import java.io.File;

import org.apache.commons.configuration.Configuration;
import org.apache.commons.configuration.ConfigurationException;
import org.apache.commons.configuration.DefaultConfigurationBuilder;

public class ServiceConfiguration {

  private static class ServiceConfigurationHolder {
    private final static ServiceConfiguration instance = new ServiceConfiguration();
  }

  public static ServiceConfiguration getInstance() {
    return ServiceConfigurationHolder.instance;
  }

  private Configuration config;

  private ServiceConfiguration() {
    try {
      DefaultConfigurationBuilder builder = new DefaultConfigurationBuilder();
      builder.setFile(new File("config.xml"));
      config = builder.getConfiguration(true);
    } catch (ConfigurationException e) {
      throw new RuntimeException(e);
    }
  }

  public String getCallback() {
    return config.getString("callback");
  }

  public String getClientId() {
    return config.getString("clientId");
  }

  public String getClientSecret() {
    return config.getString("clientSecret");
  }

  public String getServiceUrl() {
    return config.getString("serviceUrl");
  }
}
