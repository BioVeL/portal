class ApplicationController < ActionController::Base

  protect_from_forgery
  helper_method :current_user  
  helper_method :login_required  

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
