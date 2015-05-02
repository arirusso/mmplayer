# MMPlayer
# Control MPlayer with MIDI
#
# (c)2015 Ari Russo
# Apache 2.0 License

# libs
require "forwardable"
require "midi-eye"
require "mplayer-ruby"
require "scale"
require "unimidi"

# modules
require "mmplayer/helper/numbers"
require "mmplayer/instructions/midi"
require "mmplayer/instructions/player"

# classes
require "mmplayer/context"
require "mmplayer/message_handler"
require "mmplayer/midi"
require "mmplayer/player"

module MMPlayer

  VERSION = "0.0.3"

  # Shortcut to Context constructor
  def self.new(*args, &block)
    Context.new(*args, &block)
  end

end
