class ToodledoAccount

  attr_accessor :client_id, :client_secret, :state, :scope, :auth_url

  def initialize(client_id=nil, client_secret=nil, state=nil, scope=nil)
    @client_id = client_id || "rubytest"
    @client_secret = client_secret || "api52a63b3a4d028"
    @state = state || "xyz"
    @scope = scope || "basic tasks"

    authorization_url = "https://api.toodledo.com/3/account/authorize.php"
    @auth_url = URI.escape(authorization_url + "?response_type=code&client_id=" + @client_id + "&state=" + @state + "&scope=" + @scope)
  end

  def client_params
    params = {
      :site => @auth_url,
      :authorize_url => @auth_url,
      :token_url => "https://api.toodledo.com/3/account/token.php"
    }
  end

  def resource_url
    "https://api.toodledo.com/3/account/get.php?"
  end

end
