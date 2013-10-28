
module TavernaPlayer
  class ServiceCredentialsController < TavernaPlayer::ApplicationController

    before_filter :authenticate_user!
    before_filter :admin_required

    include TavernaPlayer::Concerns::Controllers::ServiceCredentialsController

  end
end
