require './models/account'
require 'sinatra'
require 'oauth2'
require 'json'

enable :sessions

get '/' do
  account = ToodledoAccount.new

  client = OAuth2::Client.new(account.client_id, account.client_secret, account.client_params)
  token = session[:token]
  opts = {
    :refresh_token => session[:refresh_token]
  }

  @code = request["code"]

  begin
    if token
      # Instantiate token based on token session string
      @token = OAuth2::AccessToken.new(client, token, opts)
    elsif @code
      # Request token
      @token = client.auth_code.get_token(@code)
    end
  rescue OAuth2::Error => e
    puts e.inspect
    @error = e.response.parsed['errorDesc']
  end

  if @token
    session[:token] = @token.token
    session[:refresh_token] = @token.refresh_token

    resource = @token.get('/3/account/get.php?', :params => { 'f' => 'json' })
    response = JSON.parse(resource.body)
    @email = response["email"]
  end

  @client_id = account.client_id
  @session = session

  erb :index
end

get '/authorize' do
  account = ToodledoAccount.new

  redirect account.auth_url
end

get '/refresh' do
  account = ToodledoAccount.new

  client = OAuth2::Client.new(account.client_id, account.client_secret, account.client_params)
  token = session[:token]
  opts = {
    :refresh_token => session[:refresh_token]
  }

  @token = OAuth2::AccessToken.new(client, token, opts)

  # Referesh token example
  begin
    @token = @token.refresh!
    session[:token] = @token.token
    session[:refresh_token] = @token.refresh_token
  rescue Exception => e
    @error = e.inspect
  end

  redirect "/"
end

get '/clear' do
  session.clear

  redirect "/"
end
