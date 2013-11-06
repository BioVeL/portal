
module TavernaPlayer
  class RunsController < TavernaPlayer::ApplicationController
    before_filter :authenticate_user!, :except => [ :new, :create, :show,
      :index, :cancel, :read_interaction, :write_interaction ]

    include TavernaPlayer::Concerns::Controllers::RunsController

    after_filter :set_user, :only => :create

    private

    def find_runs
      select = {}
      select[:workflow_id] = params[:workflow_id] if params[:workflow_id]

      unless current_user_admin?
        select[:embedded] = false
        select[:user_id] = current_user.nil? ? nil : current_user.id
      end

      @runs = Run.where(select).all
    end

    def find_run
      @run = Run.find(params[:id])
      authenticate_user! if current_user.nil? && !@run.user_id.nil?
    end

    def set_user
      return if @run.embedded?
      @run.user = current_user
      @run.save
    end
  end
end
