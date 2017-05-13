require 'http'

# Returns all projects belonging to an account
class GetAllProjects
  def initialize(config)
    @config = config
  end

  def call(current_account:, auth_token:)
    response = HTTP.auth("Bearer #{auth_token}")
                   .get("#{@config.API_URL}/accounts/#{current_account['id']}/projects")
    response.code == 200 ? extract_projects(response.parse) : nil
  end

  private

  def extract_projects(projects)
    projects['data'].map do |proj|
      { id: proj['id'],
        name: proj['attributes']['name'],
        repo_url: proj['attributes']['repo_url'] }
    end
  end
end
