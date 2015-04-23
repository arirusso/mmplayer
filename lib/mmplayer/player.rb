module MMPlayer

  class Player

    # @param [Hash] options
    # @option options [String] :flags MPlayer command-line flags to use on startup
    def initialize(options = {})
      @flags = "-fixed-vo -idle"
      @flags += " #{options[:flags]}" unless options[:flags].nil?
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
      @player.send(method, *args, &block)
    end

    # Does the MPlayer respond to the given message?
    # @return [Boolean]
    def mplayer_respond_to?(method, include_private = false)
      @player.respond_to?(method)
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
      thread = Thread.new do
        begin
          time = {
            :length => poll_mplayer_value("time_length"),
            :position => poll_mplayer_value("time_pos")
          }
        rescue Exception => exception
          Thread.main.raise(exception)
        end
      end
      sleep(0.001)
      thread.kill
      time
    end

    # Poll a single MPlayer value for the given key
    def poll_mplayer_value(key)
      @player.get(key).strip.to_f
    end

    # Ensure that the MPlayer process is invoked
    # @param [String] file The media file to invoke MPlayer with
    # @return [MPlayer::Slave]
    def ensure_player(file)
      @player ||= MPlayer::Slave.new(file, :options => @flags)
    end

  end

end
