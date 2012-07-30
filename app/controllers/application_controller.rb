class ApplicationController < ActionController::Base

  protect_from_forgery
  helper_method :current_user  
  helper_method :login_required  

  $server = nil;
  $server_uri = "http://localhost:8080/ts24"
  $server_user = "taverna"
  $server_pass = "taverna"

  $credentials = T2Server::HttpBasic.new("taverna", "taverna")

  # Scrub sensitive parameters from your log
  # filter_parameter_logging :password
  def check_server()
    if (!defined?($server) || ($server == nil)) #then
      #settings = YAML.load(IO.read(File.join(File.dirname(__FILE__), "config.yaml")))      #if settings
      #  $server_uri = settings['server_uri']
        begin
         $server = T2Server::Server.new($server_uri)
        rescue Exception => e  
          $server = nil
          redirect_to '/no_configuration'
        end
      #else
      #  redirect_to '/no_configuration'
    end
  end

  private 
  # Identify the user currently logged in 
  def current_user  
    @current_user ||= User.find(session[:user_id]) if session[:user_id]  
  end

  # detect if a user is logged in
  def login_required
    if session[:user_id].nil? 
      redirect_to '/log_in'
    end
  end

end
