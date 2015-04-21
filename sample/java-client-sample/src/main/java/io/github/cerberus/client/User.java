package io.github.cerberus.client;

import java.io.Serializable;

import com.google.gson.annotations.SerializedName;

public class User implements Serializable {

  private static final long serialVersionUID = 1145127511574140086L;

  @SerializedName("login")
  public String username;

  @SerializedName("firstname")
  public String firstName;

  @SerializedName("lastname")
  public String lastName;

  @SerializedName("name")
  public String fullName;

  @SerializedName("email")
  public String email;

}
