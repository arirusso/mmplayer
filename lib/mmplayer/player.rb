require "mmplayer/player/invoker"
require "mmplayer/player/messenger"
require "mmplayer/player/state"
require "mmplayer/player/wrapper"

module MMPlayer

  module Player

    def self.new(*args)
      ::MMPlayer::Player::Wrapper.new(*args)
    end

  end

end
