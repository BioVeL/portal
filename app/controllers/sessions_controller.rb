class SessionsController < ApplicationController
  def new
  end
  # Create a new session 
  def create  
    user = User.authenticate(params[:name], params[:password])  
    if user  
      session[:user_id] = user.id  
      redirect_to root_url, :notice => "Logged in!"  
    else  
      flash.now.alert = "Invalid user name or password"  
      render "new"  
    end  
  end  
  # Destroy the session after log out
  def destroy  
    session[:user_id] = nil  
    redirect_to root_url, :notice => "Logged out!"  
  end  
end
