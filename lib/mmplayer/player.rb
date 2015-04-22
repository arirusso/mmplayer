module MMPlayer

  module Player

    def play(file)
      player(:file => file).load_file(file)
    end

    def active?
      !player.nil? && !player.stdout.gets.nil?
    end

    def repeat
      if player.nil?
        @player_options[:repeat] = true
      else
        player.loop(:forever)
      end
    end

    private

    def player(options = {})
      if @player.nil?
        unless (file = options[:file]).nil?
          @player = MPlayer::Slave.new(file, @player_options[:start])
          repeat unless @player_options[:repeat].nil?
          @player_options = nil
        end
      end
      @player
    end

  end

end
