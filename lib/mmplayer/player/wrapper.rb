module MMPlayer

  module Player

    # Wrapper for MPlayer functionality
    class Wrapper

      attr_reader :player, :state

      # @param [Hash] options
      # @option options [String] :flags MPlayer command-line flags to use on startup
      def initialize(options = {})
        @invoker = Invoker.new(options)
        @messenger = Messenger.new
        @callback = {}
        @state = State.new
        @threads = []
      end

      # Play a media file
      # @param [String] file
      # @return [Boolean]
      def play(file)
        @player ||= @invoker.ensure_invoked(file, @state)
        if @player.nil?
          false
        else
          @threads << ::MMPlayer::Thread.new do
            @player.load_file(file)
            handle_start
          end
          true
        end
      end

      # Is MPlayer active?
      # @return [Boolean]
      def active?
        !(@player ||= @invoker.player).nil?
      end

      # Toggles pause
      # @return [Boolean]
      def pause
        @state.toggle_pause
        @player.pause
        @state.pause?
      end

      # Handle events while the player is running
      # @return [Boolean]
      def playback_loop
        loop do
          if handle_progress?
            @threads << ::MMPlayer::Thread.new { handle_progress }
          end
          handle_eof if handle_eof?
          sleep(0.05)
        end
        true
      end

      # Add a callback to be called when progress is updated during playback
      # @param [Proc] block
      # @return [Boolean]
      def add_progress_callback(&block)
        @callback[:progress] = block
        true
      end

      # Add a callback to be called at the end of playback of a media file
      # @param [Proc] block
      # @return [Boolean]
      def add_end_of_file_callback(&block)
        @callback[:end_of_file] = block
        true
      end

      # Shortcut to send a message to the MPlayer
      # @return [Object]
      def mplayer_send(method, *args, &block)
        if @player.nil? && MPlayer::Slave.method_defined?(method)
          # warn
        else
          @messenger.send_message do
            @player.send(method, *args, &block)
          end
        end
      end

      # Does the MPlayer respond to the given message?
      # @return [Boolean]
      def mplayer_respond_to?(method, include_private = false)
        (@player.nil? && MPlayer::Slave.method_defined?(method)) ||
        @player.respond_to?(method)
      end

      # Cause MPlayer to exit
      # @return [Boolean]
      def quit
        @player.quit
        @threads.each(&:kill)
        @invoker.destroy
        true
      end

      private

      def handle_progress?
        @state.progressing? && progress_callback?
      end

      def progress_callback?
        !@callback[:progress].nil?
      end

      def eof_callback?
        !@callback[:end_of_file].nil?
      end

      def handle_eof?
        eof? && eof_callback?
      end

      # Has the end of a media file been reached?
      # @return [Boolean]
      def eof?
        @state.eof_reached? && get_player_output.size < 1
      end

      # Get player output from stdout
      def get_player_output
        @player.stdout.gets.inspect.strip.gsub(/(\\n|[\\"])/, '').strip
      end

      def handle_progress
        poll_mplayer_progress do |time|
          time[:percent] = get_percentage(time)
          # do the check again for thread safety
          @callback[:progress].call(time) if handle_progress?
        end
      end

      # Handle the end of playback for a single media file
      def handle_eof
        # do this check again for thread safety
        if @state.eof_reached?
          STDOUT.flush
          @callback[:end_of_file].call
          @state.handle_eof
        end
        true
      end

      # Handle the beginning of playback for a single media file
      def handle_start
        loop until get_player_output.size > 1
        @state.handle_start
      end

      # Get progress percentage from the MPlayer report
      def get_percentage(report)
        percent = (report[:position] / report[:length]) * 100
        percent.round
      end

      # Poll MPlayer for progress information
      # Media progress information
      # eg {
      #  :length => 90.3,
      #  :percent => 44,
      #  :position => 40.1
      # }
      # Length and position are in seconds
      def poll_mplayer_progress(&block)
        time = nil
        @messenger.send_message do
          time = {
            :length => get_mplayer_float("time_length"),
            :position => get_mplayer_float("time_pos")
          }
          yield(time)
        end
        time
      end

      # Poll a single MPlayer value for the given key
      def get_mplayer_float(key)
        result = @player.get(key)
        result.strip.to_f
      end

    end

  end
end
