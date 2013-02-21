class ApplicationController < ActionController::Base
  protect_from_forgery
  helper_method :current_user  
  helper_method :login_required  
  helper_method :admin_required
  helper_method :user_signed_in?
  helper_method :active_link?
   
  private 
  # Identify the user currently logged in 
  def current_user  
    #@current_user ||= User.find(session[:user_id]) if session[:user_id]  
    @current_user ||= User.find_by_auth_token( cookies[:auth_token]) if cookies[:auth_token]
  end

  # detect if a user is logged in
  def login_required
    #if session[:user_id].nil?
    if cookies[:auth_token].nil?  
      flash[:error] = 'This content is available only for registered users'
      redirect_to '/log_in'
    end
  end

  # detect if a user is logged in as administrator
  def admin_required
    #if session[:user_id].nil? || current_user.nil? || !current_user.admin?
    if cookies[:auth_token].nil? || current_user.nil? || !current_user.admin?
      flash[:error] = 'This content is only for system administrator'
      redirect_to '/log_in'  
    end
  end
  
  def user_signed_in?
    cu = current_user
    if cu.nil? then false else true end
  end

  def active_link?(url)
    uri = URI.parse(url)
    response = nil
    if !uri.host.nil? && !uri.port.nil?
      Net::HTTP.start(uri.host, uri.port) { |http|
        response = http.head(uri.path.size > 0 ? uri.path : "/")
      }  
    end
    return response.nil? ? false : true
  end
end
