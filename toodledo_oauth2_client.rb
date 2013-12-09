require './toodledo_oauth2'

# Global variables

# For testing purposes, copy auth_code and state from the following:
# https://api.toodledo.com/3/playground.php

auth_code = "5c3c2c1e97207751a74e50c7f133fcc61e4e7b91"
state = "52a5eb8e245f2"

# Constant
resource_url = "https://api.toodledo.com/3/account/get.php"

# Basic functionality

# 1. Instantiate new connection to OAuth server
toodledo = ToodledoOAuth2.new(0,0,'hello', 123, state)

# 2. Redirect user to this url (testing code skipped)
# User needs to accept terms
# Copy auth code
puts "Auth URL: #{toodledo.authURL}"

# Manual process
# Copy auth code and state from the following:
#   https://api.toodledo.com/3/playground.php

# 3. Get access and refresh tokens based on auth code
response = toodledo.accessToken(auth_code, state)
access_token = response["access_token"]

if access_token
	puts "Access Token: #{access_token}"

	refresh_token = response["refresh_token"]
	puts "Refresh Token: #{refresh_token}"

	# 4. Get access token based on refresh token
	response = toodledo.accessTokenRefresh(refresh_token)
	access_token = response["access_token"]
	puts "Access Token from Refresh Token: #{access_token}"

	# 5. Get resources based on access token
	resource = toodledo.resource(resource_url, access_token)
	puts "User Id: #{resource['userid']}"
else
	puts response["errorDesc"]
end
