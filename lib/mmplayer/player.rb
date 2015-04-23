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
    # @return [Hash]
    def progress
      time = poll_mplayer_progress
      time[:percent] = get_percentage(time)
      time
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

    def get_percentage(report)
      percent = (time[:position] / time[:length]) * 100
      percent.round
    end

    def poll_mplayer_progress
      time = {
        :length => nil,
        :position => nil
      }
      while time.values.compact.count < 2
        thread = Thread.new do
          time[:length] = poll_mplayer_value("time_length")
          time[:position] = poll_mplayer_value("time_pos")
        end
        if time.values.compact.count < 2
          thread.kill
          sleep(0.005)
        end
        thread.kill
      end
      time
    end

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
