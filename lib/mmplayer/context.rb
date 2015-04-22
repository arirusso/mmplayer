module MMPlayer

  class Context

    extend Forwardable

    def_delegators :@midi, :cc, :note
    def_delegators :@player, :active?, :play, :repeat

    def initialize(midi_input, command_line_options, &block)
      @midi = MIDI.new(midi_input)
      @player = Player.new(command_line_options)
      instance_eval(&block) if block_given?
    end

    def channel(num)
      @midi.channel = num
    end

    def start
      @midi.start
      loop until @player.active?
    end

    def percent(num)
      Scale.transform(num).from(0..127).to(0..100)
    end

  end

end
