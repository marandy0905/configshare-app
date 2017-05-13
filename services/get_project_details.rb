require 'http'

# Returns all projects belonging to an account
class GetProjectDetails
  def initialize(config)
    @config = config
  end

  def call(project_id:, auth_token:)
    response = HTTP.auth("Bearer #{auth_token}")
                   .get("#{@config.API_URL}/projects/#{project_id}")
    response.code == 200 ? extract_project_details(response.parse) : nil
  end

  private

  def extract_project_details(project_data)
    configurations = project_data['relationships']['configurations']
    config_files = configurations.map do |config_file|
      { 'id' => config_file['id'] }.merge(config_file['attributes'])
    end

    { 'id' => project_data['id'], 'configurations' => config_files }
      .merge(project_data['attributes'])
      .merge(project_data['relationships'])
  end
end
