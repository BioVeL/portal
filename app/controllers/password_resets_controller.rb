class PasswordResetsController < ApplicationController
  def new
  end

  def create
    user = User.find_by_email(params[:email])
    user.send_password_reset if user
    redirect_to root_url, :notice => "Password reset instructions sent to email"
  end
  
  def edit
    @user = User.find_by_password_reset_token!(params[:id])
  end



def update
  @user = User.find_by_password_reset_token!(params[:id])
    if @user.password_reset_sent_at < 2.hours.ago
      flash[:error] = "Password reset token has expired" + 
                      " Please request a new reset email"
      redirect_to new_password_reset_path 
    elsif @user.update_attributes(params[:user])
      redirect_to root_url, :notice => "Password has been reset"
    else
      render :edit
    end
  end


end
