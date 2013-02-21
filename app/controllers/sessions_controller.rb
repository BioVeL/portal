class SessionsController < ApplicationController
  def new
  end
  # Create a new session 
  def create  
    user = User.authenticate(params[:name], params[:password])  
    if user  
      #session[:user_id] = user.id 
      if params[:remember_me] 
        cookies.permanent[:auth_token] = user.auth_token
      else
        cookies[:auth_token] = user.auth_token  
      end
      redirect_to root_url, 
        :notice => "Logged in as #{User.find(user.id).name}"  
    else  
      flash[:error] = "Invalid user name or password"  
      render "new"   
    end  
  end  
  # Destroy the session after log out
  def destroy  
    #session[:user_id] = nil  
    cookies.delete(:auth_token)
    redirect_to root_url, :notice => "Logged out!"  
  end  
end
