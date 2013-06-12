class UsersController < ApplicationController
  before_filter :admin_required, :except => [:new, :create]
  def index
    @biovel_users = User.all
    guest = User.new(:name=>'Guest') #the guest user
    guest.id = 0
    guest.user_statistic = UserStatistic.where(:user_id=>0)[0]
    @biovel_users << guest
    @user_statistic = UserStatistic.all 
  end

  def new  
    @user = User.new  
  end  
    
  def create  
    @user = User.new(params[:user])  
    if @user.save  
      redirect_to root_url, 
        :notice=>"You are now Registered, Login to start using BioVeL Portal!"  
    else  
      render "new"  
    end  
  end 
  # GET /workflows/1/edit
  def edit
    @user = User.find(params[:id])
  end
  def update
    @user = User.find(params[:id])
     
    respond_to do |format|
      if @user.update_attributes(params[:user])
        format.html { redirect_to '/users', :notice => 'User was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render :action => "edit" }
        format.json { render :json => @workflow.errors, :status => :unprocessable_entity }
      end
    end
  end
end
