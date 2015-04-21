require 'oauth'
class ClientApplication < ActiveRecord::Base
  
  belongs_to :role
  
  has_many :tokens, :class_name => "OauthToken"
  has_many :access_tokens
  has_many :oauth2_verifiers
  has_many :oauth_tokens
  
  before_validation :generate_keys, on: :create
  
  validates_presence_of :name, :url, :callback_url, :key, :secret, :poc
  
  validates_uniqueness_of :key
  
  validates_format_of :url,          with:    /\Ahttp(s?):\/\/(\w+:{0,1}\w*@)?(\S+)(:[0-9]+)?(\/|\/([\w#!:.?+=&%@!\-\/]))?/i,                    message: "address badly formatted."
  validates_format_of :support_url,  with:    /\Ahttp(s?):\/\/(\w+:{0,1}\w*@)?(\S+)(:[0-9]+)?(\/|\/([\w#!:.?+=&%@!\-\/]))?/i, allow_blank: true, message: "address badly formatted."
  validates_format_of :callback_url, with:    /\Ahttp(s?):\/\/(\w+:{0,1}\w*@)?(\S+)(:[0-9]+)?(\/|\/([\w#!:.?+=&%@!\-\/]))?/i,                    message: "address badly formatted."

  attr_accessor :token_callback_url

  def self.find_token(token_key)
    token = OauthToken.find_by_token(token_key, :include => :client_application)
    if token && token.authorized?
      token
    else
      nil
    end
  end

  def self.verify_request(request, options = {}, &block)
    begin
      signature = OAuth::Signature.build(request, options, &block)
      return false unless OauthNonce.remember(signature.request.nonce, signature.request.timestamp)
      value = signature.verify
      value
    rescue OAuth::Signature::UnknownSignatureMethod => e
      false
    end
  end

  def oauth_server
    @oauth_server ||= OAuth::Server.new(URL_OAUTH2_SERVER)
  end

  def credentials
    @oauth_client ||= OAuth::Consumer.new(key, secret)
  end

  # If your application requires passing in extra parameters handle it here
  def create_request_token(params={})
    RequestToken.create :client_application => self, :callback_url=>self.token_callback_url
  end

  protected
  def generate_keys
    self.key = OAuth::Helper.generate_key(40)[0,40]
    self.secret = OAuth::Helper.generate_key(40)[0,40]
  end

  # The method returns for some attributes the text label to be used into views.
  public
  def self.attribute_text_label(attr)
    case attr
      when :poc
        "Point Of Contact"
      when :name
         "Name"
      when :url
         "Main Application URL"
      when :callback_url
         "Callback URL"
      when :support_url
         "Support URL"
      when :key
        "Consumer Key"
      when :secret
        "Consumer Secret"
      else
        "Unknown text label"
    end
  end

end
