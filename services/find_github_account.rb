require 'http'

# Returns an authenticated user, or nil
class FindAuthenticatedGithubAccount
  def initialize(config)
    @config = config
  end

  def call(code)
    access_token = get_access_token(code)
    get_sso_account_from_api(access_token)
  end

  def get_access_token(code)
    HTTP.headers(accept: 'application/json')
        .post('https://github.com/login/oauth/access_token',
              form: { client_id: @config.GH_CLIENT_ID,
                      client_secret: @config.GH_CLIENT_SECRET,
                      code: code })
        .parse['access_token']
  end

  def get_sso_account_from_api(access_token)
    response = HTTP.headers(accept: 'application/json')
                   .get("#{@config.API_URL}/github_account?access_token=#{access_token}")
    puts "SSO: #{response.parse}"
    response.code == 200 ? response.parse : nil
  end
end
