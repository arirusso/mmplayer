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
require "mmplayer/midi"
require "mmplayer/player"

# classes
require "mmplayer/context"
require "mmplayer/midi/message_handler"
require "mmplayer/midi/wrapper"
require "mmplayer/player/messenger"
require "mmplayer/player/state"
require "mmplayer/player/wrapper"

module MMPlayer

  VERSION = "0.0.7"

  # Shortcut to Context constructor
  def self.new(*args, &block)
    Context.new(*args, &block)
  end

end
