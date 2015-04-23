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
      if !!options[:background]
        @player_thread = Thread.new do
          begin
            activate
          rescue Exception => exception
            Thread.main.raise(exception)
          end
        end
        true
      else
        activate
        true
      end
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

    private

    # Start the player
    # @return [Boolean]
    def activate
      @midi.start
      loop until @player.active?
      while @player.active?
        sleep(0.5)
        unless @progress_callback.nil? || (progress = @player.progress).nil?
          @progress_callback.call(progress)
        end
      end
      true
    end

  end

end
