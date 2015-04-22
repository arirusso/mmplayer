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
require "mmplayer/numbers"

# classes
require "mmplayer/context"
require "mmplayer/midi"
require "mmplayer/player"

module MMPlayer

  VERSION = "0.0.1"

  def self.new(*args, &block)
    Context.new(*args, &block)
  end

end
