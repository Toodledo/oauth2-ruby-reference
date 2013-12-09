require 'faraday' # Used to establish basic authentication connections over https
require 'json' # Used to decode responses from server

# This is a simple class for authenticating with Toodledo.com's API V3
# http://api.toodledo.com/3/
#
# This is just an example. You will want to modify this for your needs.

class ToodledoOAuth2

	# Class Variables
	# Use credentials that you registered at api.toodledo.com
	@@client_id = ""
	@@client_secret = ""

	@@scope = "basic tasks"

	@@authorization_url = "https://api.toodledo.com/3/account/authorize.php"
	@@token_url = "https://api.toodledo.com/3/account/token.php"

	attr_accessor :app_version, :os_version, :device_name, :device_id, :state

	def initialize(app_version=0, os_version=0, device_name='', device_id='', state)
		@app_version = app_version
		@os_version = os_version
		@device_name = device_name
		@device_id = device_id
		@state = state #"xyz"
	end

	# Authorization url that you will need to redirect your user to
	def authURL
		url = @@authorization_url 
		url += "?response_type=code&client_id=" + @@client_id
		url += "&state=" + self.state
		url += "&scope=" + @@scope
		URI.escape(url)
	end

	# Exchanges an authorization code for an access_token and refresh_token
	def accessToken(auth_code, state)
		return nil unless @state == state

		params = {
			:grant_type => "authorization_code",
			:code => auth_code,
			:vers => @app_version,
			:os => @os_version,
			:device => @device_name,
			:udid => @device_id
		}

		conn = Faraday.new(nil, :ssl => {
		  :ca_file => '/Users/aartola/Sites/kitebin/search/certs/ca-bundle.crt'
		})

		conn.basic_auth(@@client_id, @@client_secret)

		response = conn.post(@@token_url, params)

		return JSON.parse(response.env[:body])
	end

	# Exchanges a refresh token for an access_token and new refresh_token
	def accessTokenRefresh(refresh_token)
		return nil unless @state == state

		params = {
			:grant_type => "refresh_token",
			:refresh_token => refresh_token,
			:vers => @app_version,
			:os => @os_version,
			:device => @device_name,
			:udid => @device_id
		}

		conn = Faraday.new(nil, :ssl => {
		  :ca_file => '/Users/aartola/Sites/kitebin/search/certs/ca-bundle.crt'
		})

		conn.basic_auth(@@client_id, @@client_secret)

		response = conn.post(@@token_url, params)

		return JSON.parse(response.env[:body])
	end

	# Uses an access token to request something from the API
	def resource(resource_url, access_token)
		url = resource_url + "?access_token=" + access_token

		conn = Faraday.new(nil, :ssl => {
		  :ca_file => '/Users/aartola/Sites/kitebin/search/certs/ca-bundle.crt'
		})

		response = conn.get(url)

		return JSON.parse(response.env[:body])
	end
end
