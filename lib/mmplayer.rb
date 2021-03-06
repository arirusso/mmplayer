# MMPlayer
# Control MPlayer with MIDI
#
# (c)2015-2017 Ari Russo
# Apache 2.0 License

# libs
require "forwardable"
require "midi-eye"
require "mplayer-ruby"
require "scale"
require "timeout"
require "unimidi"

# modules
require "mmplayer/helper/numbers"
require "mmplayer/instructions"
require "mmplayer/midi"
require "mmplayer/player"
require "mmplayer/thread"

# classes
require "mmplayer/context"

module MMPlayer

  VERSION = "0.0.12"

  # Shortcut to Context constructor
  def self.new(*args, &block)
    Context.new(*args, &block)
  end

end
