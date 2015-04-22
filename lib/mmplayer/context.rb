module MMPlayer

  class Context

    include MIDI
    include Numbers
    include Player

    def initialize(midi_input, player_options = {}, &block)
      @midi_input = midi_input
      @player_options = {
        :start => player_options
      }
      instance_eval(&block) if block_given?
    end

    def start
      start_midi
      loop until player
    end

    def method_missing(method, *args, &block)
      if player.respond_to?(method)
        player.send(method, *args, &block)
      else
        super
      end
    end

    def respond_to_missing?(method, include_private = false)
      super || player.respond_to?(method)
    end

  end

end
