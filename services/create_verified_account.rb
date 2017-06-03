# frozen_string_literal: true

require 'http'

# Returns an authenticated user, or nil
class CreateVerifiedAccount
  def initialize(config)
    @config = config
  end

  def call(username:, email:, password:)
    message = { username: username,
                email: email,
                password: password }

    response = HTTP.post("#{@config.API_URL}/accounts/",
                         json: { data: message,
                                 signature: SecureMessage.sign(message) })
    response.code == 201 ? true : false
  end
end
