require "mmplayer/midi/message_handler"
require "mmplayer/midi/wrapper"

module MMPlayer

  module MIDI

    def self.new(*args)
      ::MMPlayer::MIDI::Wrapper.new(*args)
    end

  end

end
