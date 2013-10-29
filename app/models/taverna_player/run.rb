
module TavernaPlayer
  class Run < ActiveRecord::Base
    include TavernaPlayer::Concerns::Models::Run

    belongs_to :user
  end
end
