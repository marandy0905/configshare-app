require 'sinatra'

# Base class for ConfigShare Web Application
class ShareConfigurationsApp < Sinatra::Base
  get '/account/:username/projects/:project_id/configurations/?' do
    project_url = "/account/#{@current_account['username']}/projects/#{params[:project_id]}"
    redirect project_url
  end

  get '/account/:username/projects/:project_id/configurations/:config_id' do
    halt_if_incorrect_user(params)

    begin
      @project_url = "/account/#{@current_account['username']}/projects/#{params[:project_id]}"
      @config_file = GetConfigurationDetails.call(
        auth_token: session[:auth_token],
        project_id: params[:project_id],
        configuration_id: params[:config_id])

      slim :configuration
    rescue => e
      logger.error "GET CONFIG FAILED: #{e}"
      flash[:error] = 'Could not get that configuration file'
      redirect @project_url
    end
  end

  post '/account/:username/projects/:project_id/configurations' do
    halt_if_incorrect_user(params)

    project_url = "/account/#{@current_account['username']}/projects/#{params[:project_id]}"
    new_config_data = NewConfiguration.call(params)

    if new_config_data.failure?
      flash[:error] = 'Configuration details invalid: ' +
                      new_config_data.messages.values.join('; ')
      redirect project_url
    else
      begin
        new_config = CreateNewConfiguration.call(
          auth_token: session[:auth_token],
          account: @current_account,
          project_id: params[:project_id],
          configuration_data: new_config_data.to_h)
        flash[:notice] = 'Here is your new configuration file!'
        redirect project_url + "/configurations/#{new_config['id']}"
      rescue => e
        flash[:error] = 'Something went wrong -- we will look into it!'
        logger.error "NEW CONFIGURATION FAIL: #{e}"
        redirect project_url
      end
    end
  end
end
