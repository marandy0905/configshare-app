require 'sinatra'

# Base class for ConfigShare Web Application
class ShareConfigurationsApp < Sinatra::Base
  get '/account/:username/projects/?' do
    if current_account?(params)
      @projects = GetAllProjects.new(settings.config)
                                .call(current_account: @current_account,
                                      auth_token: @auth_token)
    end

    @projects ? slim(:projects_all) : redirect('/accounts/login')
  end

  get '/account/:username/projects/:project_id/?' do
    if current_account?(params)
      @project = GetProjectDetails.new(settings.config)
                                  .call(project_id: params[:project_id],
                                        auth_token: @auth_token)
      if @project
        slim(:project)
      else
        flash[:error] = 'We cannot find this project in your account'
        redirect "/account/#{params[:username]}/projects"
      end
    else
      redirect '/login'
    end
  end

  post '/account/:username/projects/:project_id/collaborators/?' do
    halt_if_incorrect_user(params)

    collaborator = AddCollaboratorToProject.call(
      collaborator_email: params[:email],
      project_id: params[:project_id],
      auth_token: session[:auth_token])

    if collaborator
      account_info = "#{collaborator['username']} (#{collaborator['email']})"
      flash[:notice] = "Added #{account_info} to the project"
    else
      flash[:error] = "Could not add #{params['email']} to the project"
    end

    redirect back
  end

  post '/account/:username/projects/?' do
    halt_if_incorrect_user(params)

    projects_url = "/account/#{@current_account['username']}/projects"

    new_project_data = NewProject.call(params)
    if new_project_data.failure?
      flash[:error] = new_project_data.messages.values.join('; ')
      redirect projects_url
    else
      begin
        new_project = CreateNewProject.call(
          auth_token: session[:auth_token],
          owner: @current_account,
          new_project: new_project_data.to_h)
        flash[:notice] = 'Your new project has been created! '\
                         ' Now add configurations and invite collaborators.'
        redirect projects_url + "/#{new_project['id']}"
      rescue => e
        flash[:error] = 'Something went wrong -- we will look into it!'
        logger.error "NEW_PROJECT FAIL: #{e}"
        redirect "/account/#{@current_account['username']}/projects"
      end
    end
  end
end
