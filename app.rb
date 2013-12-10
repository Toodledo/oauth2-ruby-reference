require 'sinatra'
require 'oauth2'
require 'json'

enable :sessions

get '/' do
  @client_id = "rubytest"
  client_secret = "api52a63b3a4d028"

  @code = request["code"]
  state = "xyz"

  scope = "basic tasks"

  # Constant
  authorization_url = "https://api.toodledo.com/3/account/authorize.php"
  site = URI.escape(authorization_url + "?response_type=code&client_id=" + @client_id + "&state=" + state + "&scope=" + scope)

  params = {
    :site => site,
    :authorize_url => site,
    :token_url => "https://api.toodledo.com/3/account/token.php"
  }

  client = OAuth2::Client.new(@client_id, client_secret, params)
  token = session[:token]
  opts = {
    :refresh_token => session[:refresh_token]
  }

  if token
    begin
      @token = OAuth2::AccessToken.new(client, token, opts)
    rescue OAuth2::Error => e
      @error = e.response.parsed['errorDesc']
    end
  elsif @code
    begin
      # Request token
      @token = client.auth_code.get_token(@code)
    rescue OAuth2::Error => e
      @error = e.response.parsed['errorDesc']
    end
  end

  if @token
    puts @token.inspect
    session[:token] = @token.token
    session[:refresh_token] = @token.refresh_token

    resource = @token.get('/3/account/get.php?', :params => { 'f' => 'json' })
    response = JSON.parse(resource.body)
    @email = response["email"]
  end

  @session = session

  erb :index
end

get '/authorize' do
  @client_id = "rubytest"
  state = "xyz"
  scope = "basic tasks"

  # Constant
  authorization_url = "https://api.toodledo.com/3/account/authorize.php"
  site = URI.escape(authorization_url + "?response_type=code&client_id=" + @client_id + "&state=" + state + "&scope=" + scope)

  redirect site
end

get '/refresh' do
  @client_id = "rubytest"
  client_secret = "api52a63b3a4d028"

  state = "xyz"
  scope = "basic tasks"

  # Constant
  authorization_url = "https://api.toodledo.com/3/account/authorize.php"
  site = URI.escape(authorization_url + "?response_type=code&client_id=" + @client_id + "&state=" + state + "&scope=" + scope)

  params = {
    :site => site,
    :authorize_url => site,
    :token_url => "https://api.toodledo.com/3/account/token.php"
  }

  client = OAuth2::Client.new(@client_id, client_secret, params)
  token = session[:token]
  opts = {
    :refresh_token => session[:refresh_token]
  }

  @token = OAuth2::AccessToken.new(client, token, opts)

  puts @token.inspect

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