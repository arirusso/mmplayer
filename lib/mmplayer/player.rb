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

    private

    def ensure_player(file)
      @player ||= MPlayer::Slave.new(file, :options => @flags)
    end

  end

end
