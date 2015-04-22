module MMPlayer

  class Player

    def initialize(options = {})
      @flags = "-fixed-vo -idle"
      @flags += " #{options[:flags]}" unless options[:flags].nil?
    end

    def play(file)
      ensure_player(file)
      @player.load_file(file) unless @player.nil?
    end

    def active?
      !@player.nil? && !@player.stdout.gets.nil?
    end

    def progress
      time = {
        :length => nil,
        :position => nil
      }
      while time.values.compact.count < 2
        thread = Thread.new do
          time[:length] = @player.get("time_length").strip.to_f
          time[:position] = @player.get("time_pos").strip.to_f
        end
        if time.values.compact.count < 2
          thread.kill
          sleep(0.005)
        end
      end
      time[:percent] = ((time[:position] / time[:length]) * 100).round
      time
    end


    def method_missing(method, *args, &block)
      if @player.respond_to?(method)
        @player.send(method, *args, &block)
      else
        super
      end
    end

    def respond_to_missing?(method, include_private = false)
      super || @player.respond_to?(method)
    end

    private

    def ensure_player(file)
      @player ||= MPlayer::Slave.new(file, :options => @flags)
    end

  end

end
