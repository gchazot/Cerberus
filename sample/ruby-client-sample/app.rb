require 'sinatra'
require 'oauth2'
require 'json'
enable :sessions

#To use this consumer test application, just run:
#bundle install
#bundle exec ruby app.rb

OAUTH2_CLIENT_ID  =   "to be filled"
OAUTH2_KEY        =   "to be filled"
OAUTH2_SERVER     =   "to be filled" # Ex https://www.yoursever.com/cerberus"

def client
  OAuth2::Client.new(OAUTH2_CLIENT_ID,
                     OAUTH2_KEY,
                     :site => OAUTH2_SERVER,
                     :authorize_url => OAUTH2_SERVER + '/oauth/authorize',
                     :token_url => OAUTH2_SERVER + '/oauth/token',
                     :ssl => {
                      :verify_mode => OpenSSL::SSL::VERIFY_NONE #This allows to not verify the certificate
                     }
  )
end

get "/" do
  erb :index
end

get "/auth/test" do
  redirect client.auth_code.authorize_url(:redirect_uri => redirect_uri)
end

get '/callback' do
  access_token = client.auth_code.get_token(params[:code], :redirect_uri => redirect_uri)
  session[:access_token] = access_token.token
  @message = "Successfully authenticated with the server"
  erb :authenticated
end

get '/user/:name' do

  if params[:name] == "belongs_to_group"
    @message = get_response("user.#{params[:name]}?group_name=#{params[:group_name]}")
  else
    @message = get_response("user.#{params[:name]}")
  end
  
  erb :result
end

get '/authenticated' do
  erb :authenticated
end

def get_response(url)
  access_token = OAuth2::AccessToken.new(client, session[:access_token])
  JSON.parse(access_token.get(OAUTH2_SERVER + "/api/#{url}").body)
end


def redirect_uri
  uri = URI.parse(request.url)
  uri.path = '/callback'
  uri.query = nil
  uri.to_s
end
