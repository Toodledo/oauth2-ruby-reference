# https://github.com/intridea/oauth2/
require 'oauth2'

# Global variables

# For testing purposes, copy auth_code and state from the following:
# https://api.toodledo.com/3/playground.php

auth_code = "0b38d627809d2efadc19a66590e945f8178a8825"
state = "52a200bee3282"

# Credentials

client_id = ""
client_secret = ""

scope = "basic tasks"

# Constant
authorization_url = "https://api.toodledo.com/3/account/authorize.php"

site = URI.escape(authorization_url + "?response_type=code&client_id=" + client_id + "&state=" + state + "&scope=" + scope)

# Build up oauth2 client params

params = {
  :site => site,
  :authorize_url => site,
  :token_url => "https://api.toodledo.com/3/account/token.php"
  }

begin
  # Request token
  client = OAuth2::Client.new(client_id, client_secret, params)
  token = client.auth_code.get_token(auth_code)

  # Referesh token example
  token = token.refresh!

  # Get resource
  resource = token.get('/3/account/get.php?', :params => { 'f' => 'json' })
  response = JSON.parse(resource.body)
  puts response["userid"]
rescue OAuth2::Error => e
  puts e.response.parsed['errorDesc']
end
