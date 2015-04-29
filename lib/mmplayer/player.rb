module MMPlayer

  # Wrapper for MPlayer functionality
  class Player

    # @param [Hash] options
    # @option options [String] :flags MPlayer command-line flags to use on startup
    def initialize(options = {})
      @flags = "-fixed-vo -idle"
      @flags += " #{options[:flags]}" unless options[:flags].nil?
      @messenger = Messenger.new
    end

    # Play a media file
    # @param [String] file
    # @return [Boolean]
    def play(file)
      ensure_player(file)
      if @player.nil?
        false
      else
        @player.load_file(file)
        true
      end
    end

    # Is MPlayer active?
    # @return [Boolean]
    def active?
      !@player.nil? && !@player.stdout.gets.nil?
    end

    # Media progress information
    # eg {
    #  :length => 90.3,
    #  :percent => 44,
    #  :position => 40.1
    # }
    # Length and position are in seconds
    # @return [Hash, nil]
    def progress
      unless (time = poll_mplayer_progress).nil?
        time[:percent] = get_percentage(time)
        time
      end
    end

    # Shortcut to send a message to the MPlayer
    # @return [Object]
    def mplayer_send(method, *args, &block)
      if @player.nil? && MPlayer::Slave.method_defined?(method)
        # warn
      else
        @messenger.send_message { @player.send(method, *args, &block) }
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
      @player_thread.kill
      true
    end

    private

    # Get progress percentage from the MPlayer report
    def get_percentage(report)
      percent = (report[:position] / report[:length]) * 100
      percent.round
    end

    # Poll MPlayer for progress information
    def poll_mplayer_progress
      time = nil
      @messenger.send_message do
        time = {
          :length => get_mplayer_float("time_length"),
          :position => get_mplayer_float("time_pos")
        }
      end
      time
    end

    # Poll a single MPlayer value for the given key
    def get_mplayer_float(key)
      @player.get(key).strip.to_f
    end

    # Ensure that the MPlayer process is invoked
    # @param [String] file The media file to invoke MPlayer with
    # @return [MPlayer::Slave]
    def ensure_player(file)
      if @player.nil? && @player_thread.nil?
        @player_thread = Thread.new do
          begin
            @player = MPlayer::Slave.new(file, :options => @flags)
          rescue Exception => exception
            Thread.main.raise(exception)
          end
        end
        @player_thread.abort_on_exception = true
      end
    end

    # Handle sending MPlayer messages
    class Messenger

      FREQUENCY_LIMIT = 0.1 # Throttle messages to 1 per this number seconds

      def initialize
        @messages = []
      end

      # Send mplayer a message asynch
      # @return [Hash, nil]
      def send_message(&block)
        timestamp = Time.now.to_f
        # Throttled messages are disregarded
        if @messages.empty? || !throttle?(timestamp, @messages.last[:timestamp])
          thread = Thread.new do
            begin
              yield
            rescue Exception => exception
              Thread.main.raise(exception)
            end
          end
          thread.abort_on_exception = true
          record_message(thread, timestamp)
        end
      end

      private

      # Should adding a message be throttled for the given timestamp?
      # @param [Float] timestamp
      # @param [Float] last_timestamp
      # @return [Boolean]
      def throttle?(timestamp, last_timestamp)
        timestamp - last_timestamp <= FREQUENCY_LIMIT
      end

      # Record that a message has been sent
      # @param [Thread] thread
      # @param [Float] timestamp
      # @return [Hash]
      def record_message(thread, timestamp)
        message = {
          :thread => thread,
          :timestamp => timestamp
        }
        @messages << message
        message
      end

    end

  end

end
