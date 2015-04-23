module MMPlayer

  class Context

    include Helper::Numbers
    include Instructions::MIDI
    include Instructions::Player

    attr_reader :midi, :player

    # @param [UniMIDI::Input] midi_input
    # @param [Hash] options
    # @option options [String] :mplayer_flags The command-line flags to invoke MPlayer with
    # @yield
    def initialize(midi_input, options = {}, &block)
      @midi = MIDI.new(midi_input)
      @player = Player.new(:flags => options[:mplayer_flags])
      instance_eval(&block) if block_given?
    end

    # Start the player
    # @param [Hash] options
    # @option options [Boolean] :background Whether to run in a background thread
    # @return [Boolean]
    def start(options = {})
      @midi.start
      unless !!options[:background]
        loop { sleep(0.1) } until @player.active?
        loop { sleep(0.1) } while @player.active?
      end
      true
    end

    def progress(&block)
      @progress_callback = block
    end

    # Stop the player
    # @return [Boolean]
    def stop
      @midi.stop
      @player.quit
      @player_thread.kill unless @player_thread.nil?
      true
    end

  end

end
