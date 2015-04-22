module MMPlayer

  class Player

    def initialize(command_line_options)
      @start_options = command_line_options
    end

    def play(file)
      player(:file => file).load_file(file)
    end

    def active?
      !player.nil? && !player.stdout.gets.nil?
    end

    def repeat
      @player_options[:repeat] = true
    end

    private

    def player(options = {})
      if @player.nil?
        unless (file = options[:file]).nil?
          @player = MPlayer::Slave.new(file, :options => @start_options)
        end
      end
      @player
    end

  end

end
