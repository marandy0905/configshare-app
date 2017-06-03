# frozen_string_literal: true

require 'http'

# Returns an authenticated user, or nil
class FindAuthenticatedAccount
  def initialize(config)
    @config = config
  end

  def call(username:, password:)
    message = { username: username, password: password }
    response = HTTP.post("#{@config.API_URL}/accounts/authenticate",
                         json: { data: message,
                                 signature: SecureMessage.sign(message) })
    response.code == 200 ? response.parse : nil
  end
end
