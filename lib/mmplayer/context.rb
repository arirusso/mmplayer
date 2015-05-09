module MMPlayer

  # DSL context for interfacing an instance of MPlayer with MIDI
  class Context

    include Helper::Numbers
    include Instructions::MIDI
    include Instructions::Player

    attr_reader :midi, :player

    # @param [UniMIDI::Input] midi_input
    # @param [Hash] options
    # @option options [String] :mplayer_flags The command-line flags to invoke MPlayer with
    # @option options [Fixnum] :receive_channel (also: :rx_channel) A MIDI channel to subscribe to. By default, responds to all
    # @yield
    def initialize(midi_input, options = {}, &block)
      @midi = MIDI.new(midi_input, :receive_channel => options[:receive_channel] || options[:rx_channel])
      @player = Player.new(:flags => options[:mplayer_flags])
      instance_eval(&block) if block_given?
    end

    # Start listening for MIDI
    # Note that MPlayer will start when Context#play (aka Instructions::Player#play) is called
    # @param [Hash] options
    # @option options [Boolean] :background Whether to run in a background thread
    # @return [Boolean]
    def start(options = {})
      @midi.start
      @playback_thread = playback_loop
      @playback_thread.join unless !!options[:background]
      true
    end

    # Stop the player
    # @return [Boolean]
    def stop
      @midi.stop
      @player.quit
      true
    end

    private

    # Main playback loop
    def playback_loop
      ::MMPlayer::Thread.new do
        until @player.active?
          sleep(0.1)
        end
        @player.playback_loop
      end
    end

  end

end
