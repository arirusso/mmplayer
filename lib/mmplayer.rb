# libs
require "forwardable"
require "midi-eye"
require "mplayer-ruby"
require "scale"
require "unimidi"

# modules
require "mmplayer/midi"
require "mmplayer/player"

# classes
require "mmplayer/context"

module MMPlayer

  VERSION = "0.0.1"

  def self.new(*args, &block)
    Context.new(*args, &block)
  end

end
